<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth_middleware.php';
require_once __DIR__ . '/../../utils/response.php';
require_once __DIR__ . '/../../utils/validator.php';

// Authenticate and require user role
$user = AuthMiddleware::requireRole(['user']);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$data = json_decode(file_get_contents("php://input"), true);

// Validate input
$required = ['category_id', 'description', 'priority'];
if (!Validator::validateRequired($data, $required)) {
    Response::error('Missing required fields', 400);
}

$category_id = filter_var($data['category_id'], FILTER_VALIDATE_INT);
$description = Validator::sanitize($data['description']);
$priority = Validator::sanitize($data['priority']);

// Validate priority
if (!Validator::isValidPriority($priority)) {
    Response::error('Invalid priority. Must be Low, Medium, or High', 400);
}

// Validate category_id
if (!$category_id) {
    Response::error('Invalid category ID', 400);
}

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Verify category exists and get name
    $checkQuery = "SELECT id, category_name FROM categories WHERE id = :category_id";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':category_id', $category_id);
    $checkStmt->execute();
    
    if ($checkStmt->rowCount() === 0) {
        Response::error('Category not found', 404);
    }
    
    $category = $checkStmt->fetch();
    $category_name = $category['category_name'];

    // Auto-Assignment Logic
    $assignee_id = null;
    $status = 'Pending';

    // Find available engineer with matching specialization
    // Load balancing: Select engineer with fewest active complaints
    $engQuery = "SELECT u.id, COUNT(c.id) as active_complaints 
                 FROM users u 
                 LEFT JOIN complaints c ON u.id = c.assignee_id AND c.status != 'Resolved'
                 WHERE u.role = 'engineer' 
                 AND u.status = 'approved' 
                 AND u.specialization = :category_name
                 GROUP BY u.id
                 ORDER BY active_complaints ASC
                 LIMIT 1";
                 
    $engStmt = $conn->prepare($engQuery);
    $engStmt->bindParam(':category_name', $category_name);
    $engStmt->execute();
    
    if ($engStmt->rowCount() > 0) {
        $engineer = $engStmt->fetch(PDO::FETCH_ASSOC);
        $assignee_id = $engineer['id'];
        $status = 'In Progress'; // Automatically set to In Progress when assigned
    }

    // Insert complaint
    $query = "INSERT INTO complaints (user_id, category_id, assignee_id, description, priority, status) 
              VALUES (:user_id, :category_id, :assignee_id, :description, :priority, :status)";
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $user['user_id']);
    $stmt->bindParam(':category_id', $category_id);
    $stmt->bindParam(':assignee_id', $assignee_id);
    $stmt->bindParam(':description', $description);
    $stmt->bindParam(':priority', $priority);
    $stmt->bindParam(':status', $status);
    
    if ($stmt->execute()) {
        $complaint_id = $conn->lastInsertId();
        
        Response::success('Complaint registered successfully', [
            'complaint_id' => $complaint_id,
            'status' => $status,
            'assigned_engineer_id' => $assignee_id
        ], 201);
    } else {
        Response::error('Failed to register complaint', 500);
    }
    
} catch (PDOException $e) {
    error_log("Create Complaint Error: " . $e->getMessage());
    Response::error('Failed to register complaint', 500);
}
?>
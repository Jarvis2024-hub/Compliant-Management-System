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

    // Auto-assignment Logic
    // Find approved engineer with matching specialization
    $engineerQuery = "SELECT id FROM users WHERE role = 'engineer' AND status = 'approved' AND specialization = :specialization ORDER BY RAND() LIMIT 1";
    $engStmt = $conn->prepare($engineerQuery);
    $engStmt->bindValue(':specialization', $category_name);
    $engStmt->execute();
    $engineer = $engStmt->fetch();

    $assignee_id = null;
    $status = 'Pending';
    if ($engineer) {
        $assignee_id = $engineer['id'];
        $status = 'In Progress'; // Automatically set to In Progress if assigned? Requirement says "Assign automatically... If none available -> mark pending". Implicitly if assigned, maybe status should be Pending but assigned? Standard is usually Pending until Engineer accepts. But requirement says "Assign automatically". Let's keep status 'Pending' or strictly follow "If none available -> mark pending". It implies if available -> mark something else? Or usually Assigned is a state. But status ENUM is 'Pending', 'In Progress', 'Resolved'. I'll keep it 'Pending' or set to 'In Progress' if assigned? 
        // "When complaint created: ... Assign automatically ... If none available -> mark pending".
        // This suggests if assigned, it might NOT be pending? 
        // But let's stick to 'Pending' as safe default, or 'In Progress' if the user meant "Assigned". 
        // Without an 'Assigned' status, 'Pending' is best. The engineer will see it.
        // Actually, if I assign it, the engineer sees it. 'Pending' means waiting for resolution.
        // I will keep status as 'Pending' even if assigned, unless I change it.
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
<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth_middleware.php';
require_once __DIR__ . '/../../utils/response.php';

// Authenticate user
$user = AuthMiddleware::authenticate();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

if (!isset($_GET['id'])) {
    Response::error('Complaint ID is required', 400);
}

$complaint_id = filter_var($_GET['id'], FILTER_VALIDATE_INT);

if (!$complaint_id) {
    Response::error('Invalid complaint ID', 400);
}

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    $query = "SELECT 
                c.id,
                c.description,
                c.priority,
                c.status,
                c.created_at,
                cat.category_name,
                u.name as user_name,
                u.email as user_email,
                ar.response as admin_response,
                ar.created_at as response_date
              FROM complaints c
              INNER JOIN categories cat ON c.category_id = cat.id
              INNER JOIN users u ON c.user_id = u.id
              LEFT JOIN admin_responses ar ON c.id = ar.complaint_id
              WHERE c.id = :complaint_id";
    
    // Add role-based filtering
    if ($user['role'] === 'user') {
        $query .= " AND c.user_id = :user_id";
    }
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':complaint_id', $complaint_id);
    
    if ($user['role'] === 'user') {
        $stmt->bindParam(':user_id', $user['user_id']);
    }
    
    $stmt->execute();
    
    if ($stmt->rowCount() === 0) {
        Response::error('Complaint not found', 404);
    }
    
    $complaint = $stmt->fetch();
    
    Response::success('Complaint details retrieved successfully', [
        'complaint' => $complaint
    ]);
    
} catch (PDOException $e) {
    error_log("Complaint Details Error: " . $e->getMessage());
    Response::error('Failed to fetch complaint details', 500);
}
?>
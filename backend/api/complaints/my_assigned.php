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

// Authenticate and require engineer role
$user = AuthMiddleware::requireRole(['engineer']);

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
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
                c.user_id,
                u.name as user_name,
                cat.category_name,
                ar.response as admin_response
              FROM complaints c
              INNER JOIN categories cat ON c.category_id = cat.id
              INNER JOIN users u ON c.user_id = u.id
              LEFT JOIN admin_responses ar ON c.id = ar.complaint_id
              WHERE c.assignee_id = :engineer_id
              ORDER BY c.created_at DESC";
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':engineer_id', $user['user_id']);
    $stmt->execute();
    
    $complaints = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    Response::success('Assigned complaints retrieved successfully', $complaints);
    
} catch (PDOException $e) {
    error_log("My Assigned Complaints Error: " . $e->getMessage());
    Response::error('Failed to fetch assigned complaints', 500);
}
?>

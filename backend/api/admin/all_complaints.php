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

// Authenticate and require admin role
$user = AuthMiddleware::requireRole(['admin']);

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Optional filters
    $status = isset($_GET['status']) ? $_GET['status'] : null;
    $priority = isset($_GET['priority']) ? $_GET['priority'] : null;
    
    $query = "SELECT 
                c.id,
                c.description,
                c.priority,
                c.status,
                c.created_at,
                cat.category_name,
                u.name as user_name,
                u.email as user_email,
                ar.response as admin_response
              FROM complaints c
              INNER JOIN categories cat ON c.category_id = cat.id
              INNER JOIN users u ON c.user_id = u.id
              LEFT JOIN admin_responses ar ON c.id = ar.complaint_id
              WHERE 1=1";
    
    if ($status) {
        $query .= " AND c.status = :status";
    }
    
    if ($priority) {
        $query .= " AND c.priority = :priority";
    }
    
    $query .= " ORDER BY c.created_at DESC";
    
    $stmt = $conn->prepare($query);
    
    if ($status) {
        $stmt->bindParam(':status', $status);
    }
    
    if ($priority) {
        $stmt->bindParam(':priority', $priority);
    }
    
    $stmt->execute();
    
    $complaints = $stmt->fetchAll();
    
    // Get statistics
    $statsQuery = "SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending,
                    SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) as in_progress,
                    SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) as resolved
                   FROM complaints";
    
    $statsStmt = $conn->prepare($statsQuery);
    $statsStmt->execute();
    $stats = $statsStmt->fetch();
    
    Response::success('All complaints retrieved successfully', [
        'complaints' => $complaints,
        'statistics' => $stats
    ]);
    
} catch (PDOException $e) {
    error_log("All Complaints Error: " . $e->getMessage());
    Response::error('Failed to fetch complaints', 500);
}
?>
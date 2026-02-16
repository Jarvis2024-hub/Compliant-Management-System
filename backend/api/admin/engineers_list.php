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
require_once __DIR__ . '/../../utils/validator.php';

// Authenticate - Admin only (or maybe engineer/user too? Code says admin screen)
// Let's allow 'admin' for sure.
$user = AuthMiddleware::requireRole(['admin']);

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

$category = isset($_GET['category']) ? trim($_GET['category']) : '';

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Robust query: Case insensitive, trimmed matching
    $query = "SELECT id, name, email, specialization, status 
              FROM users 
              WHERE role = 'engineer' 
              AND status = 'approved'";
              
    if (!empty($category)) {
        $query .= " AND LOWER(TRIM(specialization)) = LOWER(TRIM(:category))";
    }
    
    // Add ordering
    $query .= " ORDER BY name ASC";
    
    $stmt = $conn->prepare($query);
    
    if (!empty($category)) {
        $stmt->bindParam(':category', $category);
    }
    
    $stmt->execute();
    $engineers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Return standard response format
    Response::success('Engineers retrieved successfully', $engineers);
    
} catch (PDOException $e) {
    error_log("Get Engineers Error: " . $e->getMessage());
    Response::error('Failed to fetch engineers', 500);
}
?>

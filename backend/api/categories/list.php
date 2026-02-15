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

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    $query = "SELECT id, category_name FROM categories ORDER BY category_name ASC";
    $stmt = $conn->prepare($query);
    $stmt->execute();
    
    $categories = $stmt->fetchAll();
    
    Response::success('Categories retrieved successfully', [
        'categories' => $categories
    ]);
    
} catch (PDOException $e) {
    error_log("Category List Error: " . $e->getMessage());
    Response::error('Failed to fetch categories', 500);
}
?>
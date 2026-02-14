<?php
// api/admin/reject_user.php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../../middleware/auth_middleware.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../utils/response.php';

$user = AuthMiddleware::requireRole(['admin']);

$input = json_decode(file_get_contents("php://input"), true);

if (!isset($input['user_id'])) {
    Response::error('User ID is required', 400);
}

$user_id = $input['user_id'];

try {
    $db = new Database();
    $conn = $db->getConnection();

    $stmt = $conn->prepare("UPDATE users SET status = 'rejected' WHERE id = :id");
    if ($stmt->execute([':id' => $user_id])) {
        Response::success('User rejected successfully');
    } else {
        Response::error('Failed to reject user', 500);
    }

} catch (PDOException $e) {
    Response::error('Database error: ' . $e->getMessage(), 500);
}
?>

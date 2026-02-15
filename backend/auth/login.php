<?php
// auth/login.php
ob_start();
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../php-error.log');

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    ob_clean();
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/jwt_handler.php';
require_once __DIR__ . '/../utils/response.php';
require_once __DIR__ . '/../utils/validator.php';

set_exception_handler(function($e) {
    if (ob_get_length()) ob_clean();
    Response::error("Internal Server Error: " . $e->getMessage(), 500);
});

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$input = file_get_contents("php://input");
$data = json_decode($input, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    Response::error('Invalid JSON format', 400);
}

$required = ['email', 'password'];
if (!Validator::validateRequired($data, $required)) {
    Response::error('Missing required fields', 400);
}

$email = Validator::sanitizeEmail($data['email']);
$password = $data['password'];

try {
    $db = new Database();
    $conn = $db->getConnection();

    if (!$conn) {
        Response::error("Database connection failed", 500);
    }

    $stmt = $conn->prepare("SELECT id, name, email, password, role, status FROM users WHERE email = :email");
    $stmt->execute([':email' => $email]);
    
    if ($stmt->rowCount() === 0) {
        Response::error('Invalid email or password', 401);
    }

    $user = $stmt->fetch();

    // Verify Password
    // Note: Google users have null password. If password is provided but in DB it's null, they must login with Google.
    // Or we can allow them to set a password? For now, if null, fail.
    if ($user['password'] === null) {
        Response::error('Please login with Google', 400);
    }

    if (!password_verify($password, $user['password'])) {
        Response::error('Invalid email or password', 401);
    }

    // Check Status
    if ($user['status'] !== 'approved') {
        Response::error('Account pending admin approval.', 403);
    }

    // Generate Request Token
    $token = JWTHandler::generateToken($user['id'], $user['role'], $user['email']);

    Response::success('Login successful', [
        'token' => $token,
        'user' => [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'role' => $user['role'],
            'status' => $user['status']
        ]
    ]);

} catch (PDOException $e) {
    error_log("Login Error: " . $e->getMessage());
    Response::error("Login failed: Internal Error", 500);
}
?>

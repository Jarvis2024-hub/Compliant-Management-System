<?php
// auth/register.php
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
require_once __DIR__ . '/../utils/response.php';
require_once __DIR__ . '/../utils/validator.php';

// Global Exception Handler
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

// Validation
$required = ['name', 'email', 'password', 'role'];
if (!Validator::validateRequired($data, $required)) {
    Response::error('Missing required fields', 400);
}

$name = Validator::sanitize($data['name']);
$email = Validator::sanitizeEmail($data['email']);
$password = $data['password']; // Password will be hashed, so sanitize carefully or just hash.
$role = Validator::sanitize($data['role']);
$specialization = isset($data['specialization']) ? Validator::sanitize($data['specialization']) : null;

if (!Validator::isValidEmail($email)) {
    Response::error('Invalid email format', 400);
}

if (!in_array($role, ['user', 'engineer', 'admin'])) {
    Response::error('Invalid role', 400);
}

if ($role === 'engineer' && empty($specialization)) {
    Response::error('Specialization is required for engineers', 400);
}

// Determine Status
$status = 'approved'; // Default for users
if ($role === 'engineer' || $role === 'admin') {
    $status = 'pending';
}

try {
    $db = new Database();
    $conn = $db->getConnection();

    // Check if email exists
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = :email");
    $stmt->execute([':email' => $email]);
    if ($stmt->rowCount() > 0) {
        Response::error('Email already exists', 409);
    }

    // Insert User
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    
    $query = "INSERT INTO users (name, email, password, role, specialization, status) VALUES (:name, :email, :password, :role, :specialization, :status)";
    $stmt = $conn->prepare($query);
    $params = [
        ':name' => $name,
        ':email' => $email,
        ':password' => $passwordHash,
        ':role' => $role,
        ':specialization' => $specialization,
        ':status' => $status
    ];
    
    if ($stmt->execute($params)) {
        $message = "Registration successful.";
        if ($status === 'pending') {
            $message .= " Your account is pending admin approval.";
            Response::success($message, null, 201);
        } else {
            // Can optionally return login token here, but usually register just says OK
            Response::success($message, null, 201);
        }
    } else {
        Response::error('Registration failed', 500);
    }

} catch (PDOException $e) {
    error_log("Register Error: " . $e->getMessage());
    Response::error("Registration failed: Database Error", 500);
}
?>

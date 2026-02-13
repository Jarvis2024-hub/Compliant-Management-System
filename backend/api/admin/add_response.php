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

// Authenticate and require admin role
$user = AuthMiddleware::requireRole(['admin']);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$data = json_decode(file_get_contents("php://input"), true);

// Validate input
$required = ['complaint_id', 'response'];
if (!Validator::validateRequired($data, $required)) {
    Response::error('Missing required fields', 400);
}

$complaint_id = filter_var($data['complaint_id'], FILTER_VALIDATE_INT);
$response = Validator::sanitize($data['response']);

if (!$complaint_id) {
    Response::error('Invalid complaint ID', 400);
}

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Check if complaint exists
    $checkQuery = "SELECT id FROM complaints WHERE id = :complaint_id";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':complaint_id', $complaint_id);
    $checkStmt->execute();
    
    if ($checkStmt->rowCount() === 0) {
        Response::error('Complaint not found', 404);
    }
    
    // Check if response already exists
    $checkResponseQuery = "SELECT id FROM admin_responses WHERE complaint_id = :complaint_id";
    $checkResponseStmt = $conn->prepare($checkResponseQuery);
    $checkResponseStmt->bindParam(':complaint_id', $complaint_id);
    $checkResponseStmt->execute();
    
    if ($checkResponseStmt->rowCount() > 0) {
        // Update existing response
        $updateQuery = "UPDATE admin_responses 
                        SET response = :response, created_at = CURRENT_TIMESTAMP 
                        WHERE complaint_id = :complaint_id";
        $stmt = $conn->prepare($updateQuery);
    } else {
        // Insert new response
        $insertQuery = "INSERT INTO admin_responses (complaint_id, response) 
                        VALUES (:complaint_id, :response)";
        $stmt = $conn->prepare($insertQuery);
    }
    
    $stmt->bindParam(':complaint_id', $complaint_id);
    $stmt->bindParam(':response', $response);
    
    if ($stmt->execute()) {
        Response::success('Response added successfully', [
            'complaint_id' => $complaint_id
        ]);
    } else {
        Response::error('Failed to add response', 500);
    }
    
} catch (PDOException $e) {
    error_log("Add Response Error: " . $e->getMessage());
    Response::error('Failed to add response', 500);
}
?>
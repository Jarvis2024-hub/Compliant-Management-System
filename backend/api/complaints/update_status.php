<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: PUT');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth_middleware.php';
require_once __DIR__ . '/../../utils/response.php';
require_once __DIR__ . '/../../utils/validator.php';

// Authenticate and require admin or engineer role
$user = AuthMiddleware::requireRole(['admin', 'engineer']);

if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    Response::error('Method not allowed', 405);
}

$data = json_decode(file_get_contents("php://input"), true);

// Validate input
$required = ['complaint_id', 'status'];
if (!Validator::validateRequired($data, $required)) {
    Response::error('Missing required fields', 400);
}

$complaint_id = filter_var($data['complaint_id'], FILTER_VALIDATE_INT);
$status = Validator::sanitize($data['status']);

// Validate status
if (!Validator::isValidStatus($status)) {
    Response::error('Invalid status. Must be Pending, In Progress, or Resolved', 400);
}

if (!$complaint_id) {
    Response::error('Invalid complaint ID', 400);
}

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Check if complaint exists and ownership if engineer
    $checkQuery = "SELECT id, assignee_id FROM complaints WHERE id = :complaint_id";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':complaint_id', $complaint_id);
    $checkStmt->execute();
    
    if ($checkStmt->rowCount() === 0) {
        Response::error('Complaint not found', 404);
    }

    $complaint = $checkStmt->fetch(PDO::FETCH_ASSOC);

    // Security: If user is engineer, they must be the assignee
    if ($user['role'] === 'engineer') {
        if ($complaint['assignee_id'] != $user['user_id']) {
            Response::error('Unauthorized. You can only update your assigned complaints.', 403);
        }
    }
    
    // Update status
    $query = "UPDATE complaints SET status = :status WHERE id = :complaint_id";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':status', $status);
    $stmt->bindParam(':complaint_id', $complaint_id);
    
    if ($stmt->execute()) {
        Response::success('Complaint status updated successfully', [
            'complaint_id' => $complaint_id,
            'new_status' => $status
        ]);
    } else {
        Response::error('Failed to update status', 500);
    }
    
} catch (PDOException $e) {
    error_log("Update Status Error: " . $e->getMessage());
    Response::error('Failed to update status', 500);
}
?>
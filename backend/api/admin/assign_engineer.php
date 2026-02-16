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

// Authenticate - Admin only
$user = AuthMiddleware::requireRole(['admin']);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($data['complaint_id']) || !isset($data['engineer_id'])) {
    Response::error('Missing complaint_id or engineer_id', 400);
}

$complaint_id = filter_var($data['complaint_id'], FILTER_VALIDATE_INT);
$engineer_id = filter_var($data['engineer_id'], FILTER_VALIDATE_INT);

if (!$complaint_id || !$engineer_id) {
    Response::error('Invalid ID format', 400);
}

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // 1. Verify Engineer exists and is approved
    $engStmt = $conn->prepare("SELECT id, name, email FROM users WHERE id = :id AND role = 'engineer' AND status = 'approved'");
    $engStmt->execute([':id' => $engineer_id]);
    $engineer = $engStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$engineer) {
        Response::error('Engineer not found or not approved', 404);
    }

    // 2. Verify Complaint exists
    $compStmt = $conn->prepare("SELECT id FROM complaints WHERE id = :id");
    $compStmt->execute([':id' => $complaint_id]);
    
    if ($compStmt->rowCount() === 0) {
        Response::error('Complaint not found', 404);
    }
    
    // 3. Update Complaint (Assign & Set Status)
    $updateQuery = "UPDATE complaints 
                    SET assignee_id = :eng_id, 
                        status = 'In Progress' 
                    WHERE id = :comp_id"; // Always set to In Progress on assignment? Yes per previous logic.
                    
    $stmt = $conn->prepare($updateQuery);
    $stmt->bindParam(':eng_id', $engineer_id);
    $stmt->bindParam(':comp_id', $complaint_id);
    
    if ($stmt->execute()) {
        error_log("Manual Assignment Configured: Complaint #$complaint_id assigned to Engineer #$engineer_id by Admin #" . $user['user_id']);
        
        Response::success('Engineer assigned successfully', [
            'complaint_id' => $complaint_id,
            'assigned_engineer_id' => $engineer_id,
            'engineer_name' => $engineer['name'],
            'status' => 'In Progress'
        ]);
    } else {
        Response::error('Failed to assign engineer', 500);
    }
    
} catch (PDOException $e) {
    error_log("Assign Engineer Error: " . $e->getMessage());
    Response::error('Failed to assign engineer', 500);
}
?>

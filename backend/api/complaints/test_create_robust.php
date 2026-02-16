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

// MOCKING AUTH AND REQUEST FOR TESTING
$user = ['user_id' => 1];
$category_id = 99; // Will be set in loop
$description = "Test Desc";
$priority = "High";

// Test Categories
$test_cases = [3]; // ID 3 is Network

foreach ($test_cases as $cat_id) {
    echo "Testing Category ID: $cat_id\n";
    $category_id = $cat_id;


try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Verify category exists and get name
    $checkQuery = "SELECT id, category_name FROM categories WHERE id = :category_id";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':category_id', $category_id);
    $checkStmt->execute();
    
    if ($checkStmt->rowCount() === 0) {
        Response::error('Category not found', 404);
    }
    
    $category = $checkStmt->fetch();
    $category_name = $category['category_name'];

    // Auto-assignment Logic (PHP-based matching for robustness)
    $stmt = $conn->query("SELECT id, name, email, specialization FROM users WHERE role = 'engineer' AND status = 'approved'");
    $available_engineers = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $engineer = null;
    $target_spec = strtolower(trim($category_name));

    // 1. Strict Match
    foreach ($available_engineers as $eng) {
        if (strtolower(trim($eng['specialization'])) === $target_spec) {
            $engineer = $eng;
            break; // Found one
        }
    }

    // 2. Loose Match if strict failed
    if (!$engineer) {
        foreach ($available_engineers as $eng) {
            $eng_spec = strtolower(trim($eng['specialization']));
            // flexible matching: 'network' matches 'network engineer' or vice versa
            if (strpos($eng_spec, $target_spec) !== false || strpos($target_spec, $eng_spec) !== false) {
                $engineer = $eng;
                break;
            }
        }
    }

    // Debug Log and Assignment Logic
    $assignee_id = null;
    $status = 'Pending';
    

    if ($engineer) {
        $assignee_id = $engineer['id'];
        $status = 'In Progress'; // Auto-set to In Progress (or Assigned, check enum)
        // Check Enum: 'Pending', 'In Progress', 'Resolved'. 
        // 'Assigned' is not in the Enum based on schema.sql (lines 33). Defaulting to 'In Progress' or keeping 'Pending' with assignee_id?
        // Schema: status ENUM('Pending', 'In Progress', 'Resolved') DEFAULT 'Pending'
        // Plan: If assigned, set to 'In Progress' to indicate action has started? Or keep 'Pending' until engineer accepts?
        // User request is "auto assignment". 
        // Let's set to 'Pending' but with assignee_id, OR 'In Progress'. 
        // Existing code set it to 'In Progress'. I will keep it 'In Progress' for now as it implies active handling.
        error_log("Auto-Assignment Success: Assigned to Engineer ID: " . $engineer['id'] . " (" . $engineer['name'] . ") for Category: '$category_name'");
    } else {
        error_log("Auto-Assignment Failed: No approved engineer found for Category: '$category_name' (normalized).");
        // Optional: Fallback to a default admin or super-engineer? No, leave unassigned for Admin to handle.
    }

    // Insert complaint
    $query = "INSERT INTO complaints (user_id, category_id, assignee_id, description, priority, status) 
              VALUES (:user_id, :category_id, :assignee_id, :description, :priority, :status)";
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $user['user_id']);
    $stmt->bindParam(':category_id', $category_id);
    $stmt->bindParam(':assignee_id', $assignee_id);
    $stmt->bindParam(':description', $description);
    $stmt->bindParam(':priority', $priority);
    $stmt->bindParam(':status', $status);
    
    if ($stmt->execute()) {
        $complaint_id = $conn->lastInsertId();
        
        Response::success('Complaint registered successfully', [
            'complaint_id' => $complaint_id,
            'status' => $status,
            'assigned_engineer_id' => $assignee_id
        ], 201);
    } else {
        Response::error('Failed to register complaint', 500);
    }
    
} catch (PDOException $e) {
    error_log("Create Complaint Error: " . $e->getMessage());
    Response::error('Failed to register complaint', 500);
}
?>
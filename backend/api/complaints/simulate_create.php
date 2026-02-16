<?php
// SIMULATION SCRIPT FOR CREATE COMPLAINT
// Refactored from create.php to bypass AuthMiddleware for testing purposes
// This ensures the LOGIC of assignment and INSERTION works correctly.

header('Content-Type: text/plain');
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../utils/response.php';
require_once __DIR__ . '/../../utils/validator.php';

// MOCK USER
$user = ['user_id' => 1, 'role' => 'user']; // Assuming user ID 1 exists and is a user.

// TEST DATA
$test_cases = [
    ['category' => 'Network', 'desc' => 'Internet is down', 'priority' => 'High'],
    ['category' => 'Plumbing', 'desc' => 'Pipe leaking', 'priority' => 'Medium'],
    ['category' => 'Hardware', 'desc' => 'Mouse broken', 'priority' => 'Low']
];

echo "--- STARTING SIMULATION ---\n";

try {
    $db = new Database();
    $conn = $db->getConnection();

    foreach ($test_cases as $test) {
        echo "\nTesting Category: " . $test['category'] . "\n";
        
        // 1. Get Category ID
        $stmt = $conn->prepare("SELECT id FROM categories WHERE category_name = ?");
        $stmt->execute([$test['category']]);
        $cat = $stmt->fetch();
        
        if (!$cat) {
            echo "[ERROR] Category not found in DB\n";
            continue;
        }
        
        $category_id = $cat['id'];
        $category_name = $test['category'];
        $description = $test['desc'];
        $priority = $test['priority'];
        
        // 2. Auto-Assignment Logic (EXACT COPY FROM create.php)
        $engineerQuery = "SELECT id, name FROM users 
                          WHERE role = 'engineer' 
                          AND status = 'approved' 
                          AND LOWER(TRIM(specialization)) = LOWER(TRIM(:specialization)) 
                          ORDER BY RAND() LIMIT 1";
                          
        $engStmt = $conn->prepare($engineerQuery);
        $engStmt->bindValue(':specialization', $category_name);
        $engStmt->execute();
        $engineer = $engStmt->fetch();

        $assignee_id = null;
        $status = 'Pending';
        
        if ($engineer) {
            $assignee_id = $engineer['id'];
            $status = 'In Progress';
            echo "[MATCHED] Engineer: " . $engineer['name'] . " (ID: " . $engineer['id'] . ")\n";
        } else {
            echo "[FAILED] No engineer found (Unexpected!)\n";
        }

        // 3. Insert Complaint
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
            echo "[SUCCESS] Complaint Created! ID: $complaint_id. Assigned To: " . ($assignee_id ? $assignee_id : 'NULL') . "\n";
            
            // 4. Verify in DB
            $verify = $conn->query("SELECT assignee_id, status FROM complaints WHERE id = $complaint_id")->fetch();
            echo "[VERIFY DB] AssigneeID: " . $verify['assignee_id'] . " | Status: " . $verify['status'] . "\n";
            
        } else {
            echo "[ERROR] Insert Failed\n";
        }
    }

} catch (Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}
echo "\n--- SIMULATION END ---\n";
?>

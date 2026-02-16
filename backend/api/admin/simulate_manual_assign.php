<?php
// SIMULATION FOR MANUAL ASSIGNMENT LOGIC
header('Content-Type: text/plain');
require_once __DIR__ . '/../../config/database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    echo "--- 1. TEST LIST ENGINEERS (Category: Network) ---\n";
    
    $category = 'Network'; // Test filter
    $query = "SELECT id, name, email, specialization, status 
              FROM users 
              WHERE role = 'engineer' 
              AND status = 'approved'";
    
    // Simulate API logic
    if (!empty($category)) {
        $query .= " AND LOWER(TRIM(specialization)) = LOWER(TRIM(:category))";
    }
    $query .= " ORDER BY name ASC";
    
    $stmt = $conn->prepare($query);
    $stmt->bindValue(':category', $category);
    $stmt->execute();
    $engineers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (count($engineers) > 0) {
        echo "[SUCCESS] Found " . count($engineers) . " engineers for '$category'.\n";
        print_r($engineers[0]); // Show first match
        $engineer_id = $engineers[0]['id'];
    } else {
        die("[FAILURE] No engineers found for '$category'. Cannot proceed.\n");
    }

    echo "\n--- 2. TEST ASSIGN ENGINEER ---\n";
    
    // Get a complaint to assign
    $complaint = $conn->query("SELECT id FROM complaints WHERE category_id = (SELECT id FROM categories WHERE category_name = '$category') LIMIT 1")->fetch();
    if (!$complaint) {
        die("No complaint found for '$category' to test assignment.\n");
    }
    $complaint_id = $complaint['id'];
    
    echo "Assigning Engineer ID $engineer_id to Complaint ID $complaint_id...\n";
    
    // Simulate Assign Logic
    $updateQuery = "UPDATE complaints 
                    SET assignee_id = :eng_id, 
                        status = 'In Progress' 
                    WHERE id = :comp_id";
                    
    $stmt = $conn->prepare($updateQuery);
    $stmt->bindValue(':eng_id', $engineer_id);
    $stmt->bindValue(':comp_id', $complaint_id);
    
    if ($stmt->execute()) {
        echo "[SUCCESS] Assignment Executed.\n";
        
        // Verify
        $verify = $conn->query("SELECT assignee_id, status FROM complaints WHERE id = $complaint_id")->fetch();
        echo "[VERIFY DB] AssigneeID: " . $verify['assignee_id'] . " | Status: " . $verify['status'] . "\n";
        
        if ($verify['assignee_id'] == $engineer_id && $verify['status'] == 'In Progress') {
            echo "[PASS] Manual Assignment Verified.\n";
        } else {
            echo "[FAIL] Database not updated correctly.\n";
        }
    } else {
        echo "[FAIL] Update query failed.\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>

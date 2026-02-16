<?php
// SIMULATION FOR DETAILS.PHP QUERY
header('Content-Type: text/plain');
require_once __DIR__ . '/../../config/database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Get the latest complaint ID created by simulate_create.php
    $lastIdParams = $conn->query("SELECT MAX(id) FROM complaints")->fetch(PDO::FETCH_COLUMN);
    $complaint_id = $lastIdParams;

    echo "--- TESTING DETAILS QUERY FOR ID: $complaint_id ---\n";

    // EXACT QUERY FROM details.php (Updated)
    $query = "SELECT 
                c.id,
                c.description,
                c.priority,
                c.status,
                c.created_at,
                cat.category_name,
                u.name as user_name,
                u.email as user_email,
                assignee.name as engineer_name,
                c.assignee_id,
                ar.response as admin_response,
                ar.created_at as response_date
              FROM complaints c
              INNER JOIN categories cat ON c.category_id = cat.id
              INNER JOIN users u ON c.user_id = u.id
              LEFT JOIN users assignee ON c.assignee_id = assignee.id
              LEFT JOIN admin_responses ar ON c.id = ar.complaint_id
              WHERE c.id = :complaint_id";
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':complaint_id', $complaint_id);
    $stmt->execute();
    
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    print_r($result);
    
    if (isset($result['engineer_name']) && !empty($result['engineer_name'])) {
        echo "\n[SUCCESS] Engineer Name is present: " . $result['engineer_name'] . "\n";
    } else {
        echo "\n[FAILURE] Engineer Name is MISSING!\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>

<?php
header('Content-Type: text/plain');
require_once __DIR__ . '/../../config/database.php';

// HARDCODED ID FOR TESTING
// In previous steps we saw Sathish (ID 10) matched Electrical.
// We also saw Network Engineer (ID 19) matched Network.
// Let's test for ALL engineer IDs that have assigned complaints.

try {
    $db = new Database();
    $conn = $db->getConnection();

    echo "--- CHECKING ASSIGNED COMPLAINTS ---\n";
    
    // 1. Check which engineers have complaints assigned
    $sql = "SELECT assignee_id, COUNT(*) as count FROM complaints WHERE assignee_id IS NOT NULL GROUP BY assignee_id";
    $stmt = $conn->query($sql);
    $assignments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($assignments)) {
        echo "No complaints are currently assigned to anyone.\n";
    } else {
        foreach ($assignments as $a) {
            echo "Engineer ID: " . $a['assignee_id'] . " has " . $a['count'] . " complaints.\n";
            
            // 2. Simulate my_assigned.php query for this engineer
            echo "  -> Fetching details for Engineer ID " . $a['assignee_id'] . "...\n";
            
            $query = "SELECT 
                        c.id, c.description, c.status, cat.category_name
                      FROM complaints c
                      INNER JOIN categories cat ON c.category_id = cat.id
                      WHERE c.assignee_id = :engineer_id";
                      
            $detStmt = $conn->prepare($query);
            $detStmt->execute([':engineer_id' => $a['assignee_id']]);
            $results = $detStmt->fetchAll(PDO::FETCH_ASSOC);
            
            foreach ($results as $r) {
                echo "     - [{$r['id']}] {$r['category_name']}: {$r['description']} ({$r['status']})\n";
            }
        }
    }
    
    echo "\n--- CHECKING USERS TABLE FOR ENGINEER LOGIN ---\n";
    $engs = $conn->query("SELECT id, name, email FROM users WHERE role='engineer'")->fetchAll(PDO::FETCH_ASSOC);
    foreach ($engs as $e) {
        echo "ID: {$e['id']} | Email: {$e['email']} | Name: {$e['name']}\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>

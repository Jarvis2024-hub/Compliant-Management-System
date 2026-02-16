<?php
header('Content-Type: text/plain'); 
require_once __DIR__ . '/../../config/database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    echo "--- ENGINEERS DUMP ---\n";
    $stm = $conn->query("SELECT id, name, role, specialization, status FROM users WHERE role = 'engineer'");
    $engineers = $stm->fetchAll(PDO::FETCH_ASSOC);
    print_r($engineers);
    echo "--- END DUMP ---\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>

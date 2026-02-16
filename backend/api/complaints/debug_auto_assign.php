<?php
header('Content-Type: text/plain');
require_once __DIR__ . '/../../config/database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();

    echo "--- CATEGORIES ---\n";
    $stmt = $conn->query("SELECT * FROM categories");
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($categories as $c) {
        echo "ID: {$c['id']}, Name: '{$c['category_name']}'\n";
    }

    echo "\n--- ENGINEERS ---\n";
    $stmt = $conn->query("SELECT id, name, email, role, specialization, status FROM users WHERE role = 'engineer'");
    $engineers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($engineers as $e) {
        echo "ID: {$e['id']}, Name: '{$e['name']}', Spec: '{$e['specialization']}', Status: '{$e['status']}'\n";
    }

    echo "\n--- TEST MATCHING ---\n";
    foreach ($categories as $cat) {
        $catName = trim($cat['category_name']);
        
        $sql = "SELECT id, name FROM users 
                WHERE role = 'engineer' 
                AND status = 'approved' 
                AND LOWER(TRIM(specialization)) = LOWER(TRIM(:spec))";
        
        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':spec', $catName);
        $stmt->execute();
        $match = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($match) {
            echo "[MATCH] Category '$catName' -> Engineer '{$match['name']}' (ID: {$match['id']})\n";
        } else {
            echo "[FAIL]  Category '$catName' -> No matching engineer found.\n";
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>

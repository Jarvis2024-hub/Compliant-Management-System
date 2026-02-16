<?php
header('Content-Type: text/plain'); // Use plain text for easy reading in terminal/browser

require_once __DIR__ . '/../../config/database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();

    echo "--- DEBUG START ---\n\n";

    // 1. Fetch All Categories
    echo "1. CATEGORIES:\n";
    $stm = $conn->query("SELECT * FROM categories");
    $categories = $stm->fetchAll(PDO::FETCH_ASSOC);
    foreach ($categories as $cat) {
        echo "ID: {$cat['id']} | Name: '{$cat['category_name']}'\n";
    }
    echo "\n";

    // 2. Fetch All Engineers
    echo "2. ENGINEERS (role='engineer', status='approved'):\n";
    $stm = $conn->query("SELECT id, name, email, specialization FROM users WHERE role = 'engineer' AND status = 'approved'");
    $engineers = $stm->fetchAll(PDO::FETCH_ASSOC);
    if (empty($engineers)) {
        echo "WARNING: No approved engineers found!\n";
    } else {
        foreach ($engineers as $eng) {
            echo "ID: {$eng['id']} | Name: {$eng['name']} | Specialization: '{$eng['specialization']}'\n";
        }
    }
    echo "\n";

    // 3. Test Matching Logic
    echo "3. MATCHING TESTS:\n";
    foreach ($categories as $cat) {
        $catName = $cat['category_name'];
        echo "Checking for Category: '$catName' ... ";

        // ORIGINAL LOGIC
        $sqlOriginal = "SELECT count(*) as count FROM users WHERE role = 'engineer' AND status = 'approved' AND specialization = :spec";
        $stmt = $conn->prepare($sqlOriginal);
        $stmt->bindValue(':spec', $catName);
        $stmt->execute();
        $countOriginal = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

        // ROBUST LOGIC (Case Insensitive + Trim)
        $sqlRobust = "SELECT count(*) as count FROM users WHERE role = 'engineer' AND status = 'approved' AND LOWER(TRIM(specialization)) = LOWER(TRIM(:spec))";
        $stmt = $conn->prepare($sqlRobust);
        $stmt->bindValue(':spec', $catName);
        $stmt->execute();
        $countRobust = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

        if ($countOriginal > 0) {
            echo "[PASS] (Original Logic: Found $countOriginal)\n";
        } elseif ($countRobust > 0) {
            echo "[FAIL] -> [PASS with Fix] (Original: 0, Robust: $countRobust)\n";
            
            // Show what matched
            $sqlMatch = "SELECT specialization FROM users WHERE role = 'engineer' AND status = 'approved' AND LOWER(TRIM(specialization)) = LOWER(TRIM(:spec))";
            $stmt = $conn->prepare($sqlMatch);
            $stmt->bindValue(':spec', $catName);
            $stmt->execute();
            $matches = $stmt->fetchAll(PDO::FETCH_COLUMN);
            echo "   Matched against: '" . implode("', '", $matches) . "'\n";

        } else {
            echo "[FAIL] (No engineers even with robust matching)\n";
        }
    }

    echo "\n--- DEBUG END ---\n";

} catch (PDOException $e) {
    echo "Database Error: " . $e->getMessage();
}
?>

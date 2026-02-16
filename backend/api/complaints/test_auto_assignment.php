<?php
header('Content-Type: text/plain');
require_once __DIR__ . '/../../config/database.php';

echo "=== AUTO-ASSIGNMENT DEBUG ===\n\n";

try {
    $db = new Database();
    $conn = $db->getConnection();

    // Test for "Plumbing" category
    $test_category = "Plumbing";
    
    echo "1. Testing Category: '$test_category'\n";
    echo "-----------------------------------\n";
    
    // Get category ID
    $stmt = $conn->prepare("SELECT id, category_name FROM categories WHERE category_name = ?");
    $stmt->execute([$test_category]);
    $category = $stmt->fetch();
    
    if (!$category) {
        echo "ERROR: Category not found!\n";
        exit;
    }
    
    echo "Category ID: {$category['id']}\n";
    echo "Category Name: '{$category['category_name']}'\n\n";
    
    // Get all approved engineers
    echo "2. All Approved Engineers:\n";
    echo "-----------------------------------\n";
    $stmt = $conn->query("SELECT id, name, email, specialization FROM users WHERE role = 'engineer' AND status = 'approved'");
    $engineers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($engineers)) {
        echo "ERROR: No approved engineers found!\n";
        exit;
    }
    
    foreach ($engineers as $eng) {
        echo "ID: {$eng['id']} | Name: {$eng['name']} | Spec: '{$eng['specialization']}'\n";
    }
    
    echo "\n3. Testing Matching Logic:\n";
    echo "-----------------------------------\n";
    
    $category_name = $category['category_name'];
    $target_spec = strtolower(trim($category_name));
    echo "Target (normalized): '$target_spec'\n\n";
    
    // Strict match
    $matched = null;
    foreach ($engineers as $eng) {
        $eng_spec = strtolower(trim($eng['specialization']));
        echo "Comparing '$eng_spec' === '$target_spec': ";
        if ($eng_spec === $target_spec) {
            echo "MATCH!\n";
            $matched = $eng;
            break;
        } else {
            echo "no match\n";
        }
    }
    
    // Fuzzy match if strict failed
    if (!$matched) {
        echo "\nStrict match failed. Trying fuzzy match...\n";
        foreach ($engineers as $eng) {
            $eng_spec = strtolower(trim($eng['specialization']));
            $contains1 = strpos($eng_spec, $target_spec) !== false;
            $contains2 = strpos($target_spec, $eng_spec) !== false;
            
            echo "Checking '$eng_spec': contains='$target_spec'? " . ($contains1 ? 'YES' : 'NO');
            echo " | '$target_spec' contains='$eng_spec'? " . ($contains2 ? 'YES' : 'NO');
            
            if ($contains1 || $contains2) {
                echo " -> FUZZY MATCH!\n";
                $matched = $eng;
                break;
            } else {
                echo "\n";
            }
        }
    }
    
    echo "\n4. Final Result:\n";
    echo "-----------------------------------\n";
    if ($matched) {
        echo "SUCCESS: Would assign to Engineer ID {$matched['id']} ({$matched['name']})\n";
        echo "Status would be set to: In Progress\n";
    } else {
        echo "FAILURE: No engineer found for category '$category_name'\n";
        echo "Status would remain: Pending\n";
    }
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
?>

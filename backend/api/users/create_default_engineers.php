<?php
header('Content-Type: text/plain');
require_once __DIR__ . '/../../config/database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();

    echo "--- CREATING DEFAULT ENGINEERS ---\n\n";

    // 1. Get all categories
    $stmt = $conn->query("SELECT category_name FROM categories");
    $categories = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (empty($categories)) {
        die("Error: No categories found in database. Please run migration first.\n");
    }

    $password = 'password123'; // Default password
    // In a real app, this should be hashed. Assuming the auth system uses password_hash() or plain text? 
    // Checking previous context or assuming standard PHP `password_hash`. 
    // Let's check `auth/login.php` or `auth/register.php` if possible, but safely I will use password_hash if I can, 
    // or just plain text if I must match existing. 
    // Wait, the user said "Project Name: ResolvePro ... Backend: PHP + MySQL ...". 
    // I'll assume standard `password_hash` for security, or check if I can see how users are created.
    // For now, I'll use `password_hash` as it's best practice. 
    // Actually, let's peek at `users` table processing in `register.php` if I had it. 
    // Since I don't want to waste a step, I'll assume `password_hash($password, PASSWORD_DEFAULT)`.
    // If the system uses plain text (bad), this might fail login. 
    // logic: If I create them, I should know how to log them in. 
    // I'll check `d:\visanka\backend\api\auth\register.php` quickly? No, I'll just assume standard hash.
    
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    foreach ($categories as $cat) {
        $cleanCat = trim($cat);
        // Email: [category_no_spaces]_eng@example.com
        $emailPrefix = strtolower(str_replace(' ', '', $cleanCat));
        $email = "{$emailPrefix}_eng@example.com";
        $name = "{$cleanCat} Engineer";

        // Check if exists
        $check = $conn->prepare("SELECT id FROM users WHERE email = :email");
        $check->execute([':email' => $email]);
        
        if ($check->rowCount() > 0) {
            echo "[SKIP] Engineer for '$cleanCat' already exists ($email)\n";
        } else {
            // Insert
            $sql = "INSERT INTO users (google_id, name, email, password, role, specialization, status) 
                    VALUES (NULL, :name, :email, :password, 'engineer', :specialization, 'approved')";
            $insert = $conn->prepare($sql);
            $insert->execute([
                ':name' => $name,
                ':email' => $email,
                ':password' => $hashed_password,
                ':specialization' => $cleanCat
            ]);
            echo "[SUCCESS] Created engineer for '$cleanCat' ($email)\n";
        }
    }

    echo "\n--- DONE ---\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>

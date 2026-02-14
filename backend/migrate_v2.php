<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();

    if (!$conn) {
        die("Connection failed");
    }

    echo "Starting database migration...\n";

    // 1. Update users table structure
    // We use a safe approach: check if column exists before adding, or just use brute force with try-catch for individual queries if 'IF NOT EXISTS' isn't supported for older MySQL.
    // Since we want to be robust, we'll try to run ALTERs.

    // Modify role column to include 'engineer'
    try {
        $conn->exec("ALTER TABLE users MODIFY COLUMN role ENUM('user', 'admin', 'engineer') DEFAULT 'user'");
        echo "Updated role enum.\n";
    } catch (PDOException $e) {
        echo "Role enum update check: " . $e->getMessage() . "\n";
    }

    // Add password
    try {
        $conn->exec("ALTER TABLE users ADD COLUMN password VARCHAR(255) NULL AFTER email");
        echo "Added password column.\n";
    } catch (PDOException $e) { /* Ignore if exists */ }

    // Add google_id (ensure it's nullable/compatible if not already) - Schema says it is UNIQUE NOT NULL, but valid for email users it should be NULLable or handled? 
    // The requirement says: "google_id (nullable for email users)". 
    // ORIGINAL SCHEMA: `google_id VARCHAR(255) UNIQUE NOT NULL`
    // WE NEED TO CHANGE IT TO NULLABLE.
    try {
        $conn->exec("ALTER TABLE users MODIFY COLUMN google_id VARCHAR(255) NULL");
        echo "Modified google_id to be nullable.\n";
    } catch (PDOException $e) {
        echo "google_id modify failed: " . $e->getMessage() . "\n";
    }

    // Add specialization
    try {
        $conn->exec("ALTER TABLE users ADD COLUMN specialization VARCHAR(100) NULL");
        echo "Added specialization column.\n";
    } catch (PDOException $e) { /* Ignore */ }

    // Add status
    try {
        $conn->exec("ALTER TABLE users ADD COLUMN status ENUM('pending', 'approved', 'rejected') DEFAULT 'approved'");
        echo "Added status column.\n";
    } catch (PDOException $e) { /* Ignore */ }


    // 2. Update complaints table
    try {
        $conn->exec("ALTER TABLE complaints ADD COLUMN assignee_id INT NULL");
        $conn->exec("ALTER TABLE complaints ADD CONSTRAINT fk_assignee FOREIGN KEY (assignee_id) REFERENCES users(id) ON DELETE SET NULL");
        echo "Added assignee_id to complaints.\n";
    } catch (PDOException $e) { 
        // Ignore duplicate key name errors usually
    }

    // 3. Insert Default Super Admin
    $email = 'admin@cms.com';
    $password = password_hash('Admin@123', PASSWORD_BCRYPT);
    $role = 'admin';
    $status = 'approved';
    $name = 'Super Admin';

    // Check if exists
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->rowCount() == 0) {
        $insert = $conn->prepare("INSERT INTO users (name, email, password, role, status) VALUES (:name, :email, :password, :role, :status)");
        $insert->execute([
            ':name' => $name,
            ':email' => $email,
            ':password' => $password,
            ':role' => $role,
            ':status' => $status
        ]);
        echo "Super Admin created.\n";
    } else {
        echo "Super Admin already exists.\n";
    }
    
    // 4. Create Categories if not exist (The SQL file has them, but let's ensure 'Civil' etc are there as per requirements)
    $categories = ['Plumbing', 'Electrical', 'Carpentry', 'Painting', 'Cleaning', 'AC Repair', 'Civil'];
    $insertCat = $conn->prepare("INSERT IGNORE INTO categories (category_name) VALUES (:name)");
    foreach ($categories as $cat) {
        $insertCat->execute([':name' => $cat]);
    }
    echo "Categories updated.\n";

    echo "Migration completed successfully.\n";

} catch (Exception $e) {
    echo "Migration Error: " . $e->getMessage() . "\n";
}

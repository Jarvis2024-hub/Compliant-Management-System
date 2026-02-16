<?php
// 1. Start Output Buffering IMMEDIATELY to catch any stray whitespace or warnings
ob_start();

// 2. Enable Error Reporting but Prevent HTML Output
error_reporting(E_ALL);
ini_set('display_errors', 0); // Crucial: Don't let PHP print errors to output
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../php-error.log');

// 3. Set Headers immediately (will be sent when buffer is flushed)
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// 4. Handle Preflight Request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // Clear buffer before sensing
    ob_clean();
    http_response_code(200);
    exit();
}

// 5. Global Exception/Error Handler to always return JSON
function globalExceptionHandler($e) {
    if (ob_get_length()) ob_clean(); // Clear buffer
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal Server Error: ' . $e->getMessage()
    ]);
    exit();
}
set_exception_handler('globalExceptionHandler');

// Capture fatal errors
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error && ($error['type'] === E_ERROR || $error['type'] === E_PARSE || $error['type'] === E_CORE_ERROR || $error['type'] === E_COMPILE_ERROR)) {
        if (ob_get_length()) ob_clean(); // Clear buffer
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Fatal Error: ' . $error['message']
        ]);
    }
});

// 6. Build Safe Dependency Loading
try {
    $paths = [
        __DIR__ . '/../config/database.php',
        __DIR__ . '/jwt_handler.php',
        __DIR__ . '/../utils/response.php',
        __DIR__ . '/../utils/validator.php'
    ];

    foreach ($paths as $path) {
        if (!file_exists($path)) {
            throw new Exception("Missing required file: " . basename($path));
        }
        require_once $path;
    }
} catch (Throwable $e) {
    globalExceptionHandler($e);
}

// 7. Main Logic Class
class GoogleAuth {
    private $conn;

    public function __construct() {
        $db = new Database();
        $this->conn = $db->getConnection();
        
        if ($this->conn === null) {
            // Log error is already handled in Database class, just return error response
            Response::error('Database connection failed', 500);
        }
    }

    public function authenticate() {
        // Ensure POST method
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            Response::error('Method not allowed', 405);
            return;
        }

        // 8. Safe JSON Decoding
        $input = file_get_contents("php://input");
        if (empty($input)) {
            Response::error('Empty request body', 400);
            return;
        }

        $data = json_decode($input, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            Response::error('Invalid JSON format', 400);
            return;
        }

        // 9. Validate Required Fields
        $required = ['google_id', 'email', 'name', 'role'];
        if (!Validator::validateRequired($data, $required)) {
            Response::error('Missing required fields', 400);
            return;
        }

        $google_id = Validator::sanitize($data['google_id']);
        $email     = Validator::sanitizeEmail($data['email']);
        $name      = Validator::sanitize($data['name']);
        $role      = Validator::sanitize($data['role']);

        if (!in_array($role, ['user', 'admin'])) {
            Response::error('Invalid role. Must be user or admin', 400);
            return;
        }

        if (!Validator::isValidEmail($email)) {
             Response::error('Invalid email format', 400);
             return;
        }

        try {
            // Check if user exists
            $stmt = $this->conn->prepare("SELECT id, name, email, role, status FROM users WHERE google_id = :google_id OR email = :email");
            $stmt->bindParam(':google_id', $google_id);
            $stmt->bindParam(':email', $email);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                // User Found
                $user = $stmt->fetch();
                
                // Verify API role request matches DB role
                if ($user['role'] !== $role) {
                    Response::error('Role mismatch. Account exists as ' . $user['role'], 403);
                    return;
                }

                // Check Status
                if ($user['status'] === 'pending') {
                     Response::error('Your account is pending approval from the administrator.', 403); // Specific message
                     return;
                }
                
                if ($user['status'] === 'rejected') {
                     Response::error('Your account has been rejected.', 403);
                     return;
                }

                if ($user['status'] !== 'approved') {
                     Response::error('Account status invalid.', 403);
                     return;
                }

                $token = $this->generateTokenSafe($user['id'], $user['role'], $user['email']);

                Response::success('Login successful', [
                    'token' => $token,
                    'user'  => $user
                ]);

            } else {
                // Determine Status
                // Default 'approved' only for 'user' role. 
                // Admin and Engineer must be 'pending' approval.
                $status = ($role === 'user') ? 'approved' : 'pending';

                $insertStmt = $this->conn->prepare("INSERT INTO users (google_id, name, email, role, status) VALUES (:google_id, :name, :email, :role, :status)");
                $insertStmt->bindParam(':google_id', $google_id);
                $insertStmt->bindParam(':name', $name);
                $insertStmt->bindParam(':email', $email);
                $insertStmt->bindParam(':role', $role);
                $insertStmt->bindParam(':status', $status);

                if ($insertStmt->execute()) {
                    $user_id = $this->conn->lastInsertId();
                    
                    if ($status === 'pending') {
                        Response::success('Registration successful. Your account is pending admin approval.', null, 201);
                    } else {
                        $token = $this->generateTokenSafe($user_id, $role, $email);
                        Response::success('Registration successful', [
                            'token' => $token,
                            'user'  => [
                                'id'    => $user_id,
                                'name'  => $name,
                                'email' => $email,
                                'role'  => $role,
                                'status' => $status
                            ]
                        ], 201);
                    }
                } else {
                    Response::error('Registration failed', 500);
                }
            }

        } catch (Throwable $e) {
            // DB Error or Logic Error
            error_log("Auth Error: " . $e->getMessage());
            Response::error("Authentication failed: Internal Error", 500);
        }
    }

    private function generateTokenSafe($id, $role, $email) {
        try {
            if (class_exists('JWTHandler')) {
                return JWTHandler::generateToken($id, $role, $email);
            }
        } catch (Throwable $e) {
            error_log("JWT Generation Failed: " . $e->getMessage());
        }

        // Fallback Dummy Token if JWT fails (to prevent empty response crash)
        return "dummy_token_" . base64_encode($id . "_" . time());
    }
}

// 10. Execute Safe
try {
    $auth = new GoogleAuth();
    $auth->authenticate();
} catch (Throwable $e) {
    globalExceptionHandler($e);
}
?>
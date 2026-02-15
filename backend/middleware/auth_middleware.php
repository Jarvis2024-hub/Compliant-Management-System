<?php
require_once __DIR__ . '/../auth/jwt_handler.php';
require_once __DIR__ . '/../utils/response.php';

class AuthMiddleware
{
    /**
     * Read Authorization header safely (ALL environments)
     */
    /**
     * Read Authorization header safely (ALL environments)
     */
    private static function getAuthorizationHeader()
    {
        $headers = null;
        
        if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            return trim($_SERVER['HTTP_AUTHORIZATION']);
        }
        
        if (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
             return trim($_SERVER['REDIRECT_HTTP_AUTHORIZATION']);
        }

        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            // Server-side fix for header case sensitivity and missing auth header
            $headers = array_change_key_case($headers, CASE_UPPER);
            if (isset($headers['AUTHORIZATION'])) {
                return trim($headers['AUTHORIZATION']);
            }
        }
        
        // DEBUGGING: Log all headers to see what we are receiving
        error_log("--- Incoming Request ---\n");
        error_log("URI: " . $_SERVER['REQUEST_URI']);
        error_log("Method: " . $_SERVER['REQUEST_METHOD']);
        if (function_exists('apache_request_headers')) {
             error_log("Apache Headers: " . print_r(apache_request_headers(), true));
        }
        error_log("SERVER Variables: " . print_r($_SERVER, true));
        error_log("------------------------\n");

        return null;
    }

    /**
     * Authenticate JWT
     */
    public static function authenticate()
    {
        $authHeader = self::getAuthorizationHeader();

        if (!$authHeader) {
            Response::error('Authorization header missing', 401);
            exit();
        }

        // Expect: Bearer <token>
        if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            Response::error('Invalid authorization format', 401);
            exit();
        }

        $jwt = $matches[1];
        $decoded = JWTHandler::validateToken($jwt);

        if (!$decoded || !isset($decoded['data'])) {
            Response::error('Invalid or expired token', 401);
            exit();
        }

        // 5. Verify User Status in Database (Strict Mode)
        try {
            require_once __DIR__ . '/../config/database.php';
            $db = new Database();
            $conn = $db->getConnection();
            
            $stmt = $conn->prepare("SELECT status FROM users WHERE id = :id");
            $stmt->execute([':id' => $decoded['data']['user_id']]);
            $user = $stmt->fetch();

            if (!$user || $user['status'] !== 'approved') {
                 Response::error('Account pending approval or suspended.', 403);
                 exit();
            }
        } catch (Exception $e) {
            // If DB checks fail, deny access for security
            Response::error('Authentication verification failed', 500);
            exit();
        }

        return $decoded['data']; // user_id, role, email
    }

    /**
     * Role-based authorization
     */
    public static function requireRole(array $allowed_roles)
    {
        $user = self::authenticate();

        if (!isset($user['role']) || !in_array($user['role'], $allowed_roles)) {
            Response::error('Unauthorized access. Insufficient permissions', 403);
            exit();
        }

        return $user;
    }
}
?>

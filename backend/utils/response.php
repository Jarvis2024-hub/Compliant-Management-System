<?php
class Response {
    
    public static function success($message, $data = null, $status_code = 200) {
        // Clear any previous output (warnings, spaces, etc.)
        if (ob_get_length()) ob_clean();
        
        http_response_code($status_code);
        
        $response = [
            'success' => true,
            'message' => $message
        ];
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        $json = json_encode($response);
        if ($json === false) {
            self::jsonError();
        }
        
        echo $json;
        exit();
    }
    
    public static function error($message, $status_code = 400, $errors = null) {
        // Clear any previous output
        if (ob_get_length()) ob_clean();
        
        http_response_code($status_code);
        
        $response = [
            'success' => false,
            'message' => $message
        ];
        
        if ($errors !== null) {
            $response['errors'] = $errors;
        }
        
        $json = json_encode($response);
        if ($json === false) {
            self::jsonError();
        }
        
        echo $json;
        exit();
    }

    private static function jsonError() {
        // Fallback if JSON encoding fails
        if (ob_get_length()) ob_clean();
        http_response_code(500);
        echo '{"success":false,"message":"Internal Server Error (JSON Encoding Failed)"}';
        exit();
    }
}
?>
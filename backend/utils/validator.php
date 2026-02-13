<?php
class Validator {
    
    public static function validateRequired($data, $fields) {
        foreach ($fields as $field) {
            if (!isset($data[$field]) || empty(trim($data[$field]))) {
                return false;
            }
        }
        return true;
    }
    
    public static function sanitize($data) {
        return htmlspecialchars(strip_tags(trim($data)));
    }
    
    public static function sanitizeEmail($email) {
        return filter_var(trim($email), FILTER_SANITIZE_EMAIL);
    }
    
    public static function isValidEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL);
    }
    
    public static function isValidPriority($priority) {
        $valid_priorities = ['Low', 'Medium', 'High'];
        return in_array($priority, $valid_priorities);
    }
    
    public static function isValidStatus($status) {
        $valid_statuses = ['Pending', 'In Progress', 'Resolved'];
        return in_array($status, $valid_statuses);
    }
}
?>
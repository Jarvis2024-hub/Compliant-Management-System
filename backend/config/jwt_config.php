<?php
class JWTConfig {
    private static $secret_key;
    private static $issuer;
    private static $audience;
    private static $expiry_time = 86400; // 24 hours

    public static function init() {
        self::$secret_key = getenv('JWT_SECRET') ?: 'your_secret_key_change_in_production';
        self::$issuer = getenv('JWT_ISSUER') ?: 'complaint_management_system';
        self::$audience = getenv('JWT_AUDIENCE') ?: 'complaint_management_app';
    }

    public static function getSecretKey() {
        if (!self::$secret_key) {
            self::init();
        }
        return self::$secret_key;
    }

    public static function getIssuer() {
        if (!self::$issuer) {
            self::init();
        }
        return self::$issuer;
    }

    public static function getAudience() {
        if (!self::$audience) {
            self::init();
        }
        return self::$audience;
    }

    public static function getExpiryTime() {
        return self::$expiry_time;
    }
}
?>
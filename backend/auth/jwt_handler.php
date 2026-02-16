<?php
require_once __DIR__ . '/../config/jwt_config.php';

class JWTHandler {
    
    public static function generateToken($user_id, $role, $email) {
        JWTConfig::init();
        
        $issued_at = time();
        $expiration_time = $issued_at + JWTConfig::getExpiryTime();
        
        $header = json_encode([
            'typ' => 'JWT',
            'alg' => 'HS256'
        ]);
        
        $payload = json_encode([
            'iss' => JWTConfig::getIssuer(),
            'aud' => JWTConfig::getAudience(),
            'iat' => $issued_at,
            'exp' => $expiration_time,
            'data' => [
                'user_id' => $user_id,
                'role' => $role,
                'email' => $email
            ]
        ]);
        
        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);
        
        $signature = hash_hmac(
            'sha256',
            $base64UrlHeader . "." . $base64UrlPayload,
            JWTConfig::getSecretKey(),
            true
        );
        
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        $jwt = $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
        
        return $jwt;
    }
    
    public static function validateToken($jwt) {
        if (empty($jwt)) {
            return false;
        }
        
        JWTConfig::init();
        
        $tokenParts = explode('.', $jwt);
        
        if (count($tokenParts) !== 3) {
            return false;
        }
        
        $header = base64_decode(strtr($tokenParts[0], '-_', '+/'));
        $payload = base64_decode(strtr($tokenParts[1], '-_', '+/'));
        $signatureProvided = $tokenParts[2];
        
        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);
        
        $signature = hash_hmac(
            'sha256',
            $base64UrlHeader . "." . $base64UrlPayload,
            JWTConfig::getSecretKey(),
            true
        );
        
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        if ($base64UrlSignature !== $signatureProvided) {
            return false;
        }
        
        $payloadData = json_decode($payload, true);
        
        if (!isset($payloadData['exp']) || $payloadData['exp'] < time()) {
            return false;
        }
        
        return $payloadData;
    }
    
    private static function base64UrlEncode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
?>
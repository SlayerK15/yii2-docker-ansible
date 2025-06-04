<?php
/**
 * Asset Proxy Script
 * 
 * This script serves static assets (CSS, JS, images) with proper MIME types
 * when using nginx as a reverse proxy to Docker containers.
 * 
 * Place this file at: web/asset-proxy.php
 */

error_reporting(0); // Suppress PHP errors for clean output

$assetPath = $_SERVER["ASSET_PATH"] ?? $_SERVER["REQUEST_URI"];
$filePath = "/var/www/html/web" . $assetPath;

// Security check - prevent directory traversal
if (strpos($assetPath, "..") !== false) {
    http_response_code(403);
    die("Access denied");
}

// Check if file exists and is readable
if (!file_exists($filePath)) {
    http_response_code(404);
    die("File not found: " . $filePath);
}

if (!is_file($filePath)) {
    http_response_code(403);
    die("Not a file: " . $filePath);
}

if (!is_readable($filePath)) {
    http_response_code(403);
    die("File not readable: " . $filePath);
}

// Set proper MIME type based on file extension
$ext = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
$mimeTypes = [
    "css" => "text/css",
    "js" => "application/javascript",
    "png" => "image/png",
    "jpg" => "image/jpeg",
    "jpeg" => "image/jpeg",
    "gif" => "image/gif",
    "ico" => "image/x-icon",
    "svg" => "image/svg+xml",
    "woff" => "font/woff",
    "woff2" => "font/woff2",
    "ttf" => "font/ttf",
    "eot" => "application/vnd.ms-fontobject"
];

$mimeType = $mimeTypes[$ext] ?? "application/octet-stream";

// Set headers BEFORE any output
header("Content-Type: " . $mimeType);
header("Content-Length: " . filesize($filePath));

// Cache headers for static assets
if (in_array($ext, ["css", "js", "png", "jpg", "jpeg", "gif", "ico", "svg", "woff", "woff2", "ttf", "eot"])) {
    header("Cache-Control: public, max-age=31536000"); // 1 year
    header("Expires: " . gmdate("D, d M Y H:i:s", time() + 31536000) . " GMT");
}

// Set success status explicitly
http_response_code(200);

// Output the file
readfile($filePath);
exit(0);
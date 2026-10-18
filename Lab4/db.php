<?php
// db.php - shared by all PHP endpoints: session, DB connection, JSON helper.
// XAMPP defaults: user root, empty password.
session_start();
header('Content-Type: application/json');

function json_out($data) {
    echo json_encode($data);
    exit;
}

$host = "localhost";
$user = "root";
$pass = "";
$dbname = "registration";

mysqli_report(MYSQLI_REPORT_OFF);          // return errors instead of throwing
$conn = @new mysqli($host, $user, $pass, $dbname);
if ($conn->connect_error) {
    json_out(['success' => false, 'errors' => ['Database connection failed: ' . $conn->connect_error]]);
}
$conn->set_charset("utf8mb4");

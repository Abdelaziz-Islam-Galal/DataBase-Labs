<?php
// check_email.php?email=... - tells the page whether the email is already registered
require 'db.php';

$email = trim($_GET['email'] ?? '');
$stmt = $conn->prepare("SELECT 1 FROM user WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
json_out(['exists' => $stmt->get_result()->num_rows > 0]);

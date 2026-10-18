<?php
// login.php - receives email + password (POST), returns JSON
require 'db.php';

$errors   = [];
$email    = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

if ($email === '')    $errors[] = "Email is empty.";
elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) $errors[] = "Email format is not valid.";
if ($password === '') $errors[] = "Password is empty.";

if (!$errors) {
    // Select the user by email and (MD5-hashed) password
    $hash = md5($password);
    $stmt = $conn->prepare("SELECT user_id, name FROM user WHERE email = ? AND password = ?");
    $stmt->bind_param("ss", $email, $hash);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();

    if ($row) {
        $_SESSION['user_id'] = $row['user_id'];
        $_SESSION['name']    = $row['name'];
        json_out(['success' => true]);
    }
    $errors[] = "Incorrect email or password.";
}
json_out(['success' => false, 'errors' => $errors]);

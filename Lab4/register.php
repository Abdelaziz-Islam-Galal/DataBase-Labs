<?php
// register.php - receives name, email, password, confirm_password (POST), returns JSON
require 'db.php';

$errors   = [];
$name     = trim($_POST['name'] ?? '');
$email    = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';
$confirm  = $_POST['confirm_password'] ?? '';

if ($name === '')     $errors[] = "Name is empty.";
if ($email === '')    $errors[] = "Email is empty.";
elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) $errors[] = "Email format is not valid.";
if ($password === '') $errors[] = "Password is empty.";
if ($confirm === '')  $errors[] = "Confirm password is empty.";
if ($password !== '' && $confirm !== '' && $password !== $confirm)
    $errors[] = "Password and confirm password do not match.";

// Email must be unique
if (!$errors) {
    $stmt = $conn->prepare("SELECT 1 FROM user WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) $errors[] = "Email Already Exists";
}

// Insert the new user (password saved as MD5)
if (!$errors) {
    $hash = md5($password);
    $stmt = $conn->prepare("INSERT INTO user (email, name, password) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $email, $name, $hash);
    if ($stmt->execute()) {
        $_SESSION['user_id'] = $conn->insert_id;
        $_SESSION['name']    = $name;
        json_out(['success' => true]);
    }
    $errors[] = "Could not save the account. Please try again.";
}
json_out(['success' => false, 'errors' => $errors]);

<?php
// session.php - returns the logged-in user's name; ?logout=1 ends the session
session_start();
header('Content-Type: application/json');

if (isset($_GET['logout'])) {
    session_destroy();
    echo json_encode(['loggedIn' => false]);
    exit;
}

if (isset($_SESSION['name'])) {
    echo json_encode(['loggedIn' => true, 'name' => $_SESSION['name']]);
} else {
    echo json_encode(['loggedIn' => false]);
}

<?php
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

$conn = new mysqli("localhost", "root", "", "flutter_app");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "DB connection failed"]);
    exit();
}

$worker_id = $_POST['worker_id'] ?? '';
if (empty($worker_id)) {
    echo json_encode(["status" => "error", "message" => "Missing worker_id"]);
    exit();
}

$stmt = $conn->prepare("SELECT id, name, email, phone FROM tbl_users WHERE id = ?");
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    $user = $result->fetch_assoc();
    echo json_encode(["status" => "success", "user" => $user]);
} else {
    echo json_encode(["status" => "error", "message" => "User not found"]);
}

$stmt->close();
$conn->close();
?>

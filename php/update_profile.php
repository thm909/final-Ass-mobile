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
$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone'] ?? '';

if (empty($worker_id) || empty($name) || empty($email)) {
    echo json_encode(["status" => "error", "message" => "Missing required fields"]);
    exit();
}


$checkEmail = $conn->prepare("SELECT id FROM tbl_users WHERE email = ? AND id != ?");
$checkEmail->bind_param("si", $email, $worker_id);
$checkEmail->execute();
$checkEmail->store_result();

if ($checkEmail->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Email already in use by another user"]);
    $checkEmail->close();
    exit();
}
$checkEmail->close();

// ✅ Step 2: 执行更新
$stmt = $conn->prepare("UPDATE tbl_users SET name = ?, email = ?, phone = ? WHERE id = ?");
$stmt->bind_param("sssi", $name, $email, $phone, $worker_id);

if ($stmt->execute()) {
    $stmt2 = $conn->prepare("SELECT id, name, email, phone FROM tbl_users WHERE id = ?");
    $stmt2->bind_param("i", $worker_id);
    $stmt2->execute();
    $result = $stmt2->get_result();

    if ($result && $result->num_rows > 0) {
        $user = $result->fetch_assoc();
        echo json_encode(["status" => "success", "user" => $user]);
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }

    $stmt2->close();
} else {
    echo json_encode(["status" => "error", "message" => "Update failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

<?php
// ❗确保没有前置空格或换行
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Connect DB
$conn = new mysqli("localhost", "root", "", "flutter_app");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "DB connection failed"]);
    exit();
}

// Get POST
$id = isset($_POST['id']) ? intval($_POST['id']) : 0;
$updated_text = $_POST['updated_text'] ?? '';

if ($id <= 0 || empty($updated_text)) {
    echo json_encode(["status" => "error", "message" => "Missing id or updated_text"]);
    exit();
}

// Update
$stmt = $conn->prepare("UPDATE tbl_submissions SET submission_text = ? WHERE id = ?");
$stmt->bind_param("si", $updated_text, $id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Submission updated"]);
} else {
    echo json_encode(["status" => "error", "message" => "Update failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

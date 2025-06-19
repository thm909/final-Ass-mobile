<?php
header('Content-Type: application/json');
include 'db.php';

if (!isset($_POST['worker_id']) || empty($_POST['worker_id'])) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Missing worker_id'
    ]);
    exit();
}

$worker_id = intval($_POST['worker_id']);

$sql = "SELECT 
            s.id, -- ✅ only use id
            s.work_id, 
            s.worker_id, 
            s.submission_text, 
            s.submitted_at, 
            w.title AS task_title 
        FROM tbl_submissions s 
        JOIN tbl_works w ON s.work_id = w.id 
        WHERE s.worker_id = ? 
        ORDER BY s.submitted_at DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

$submissions = [];
while ($row = $result->fetch_assoc()) {
    $submissions[] = $row;
}

echo json_encode([
    'status' => 'success',
    'submissions' => $submissions
]);
?>

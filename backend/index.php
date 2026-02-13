<?php
header('Content-Type: application/json');

$response = [
    'success' => true,
    'message' => 'Complaint Management System API',
    'version' => '1.0.0',
    'endpoints' => [
        'auth' => [
            'POST /auth/google_auth.php' => 'Google OAuth Login/Register'
        ],
        'categories' => [
            'GET /api/categories/list.php' => 'Get all categories'
        ],
        'complaints' => [
            'POST /api/complaints/create.php' => 'Create new complaint (User)',
            'GET /api/complaints/list.php' => 'Get user complaints (User)',
            'GET /api/complaints/details.php?id={id}' => 'Get complaint details',
            'PUT /api/complaints/update_status.php' => 'Update complaint status (Admin)'
        ],
        'admin' => [
            'GET /api/admin/all_complaints.php' => 'Get all complaints (Admin)',
            'POST /api/admin/add_response.php' => 'Add admin response (Admin)'
        ]
    ]
];

echo json_encode($response, JSON_PRETTY_PRINT);
?>
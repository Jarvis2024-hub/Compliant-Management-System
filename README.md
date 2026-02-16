# Complaint Management System (Mobile Application)

## 📌 Project Overview
This project is a **Complaint Management System** designed to streamline the process of reporting, tracking, and resolving facility-related issues (e.g., Plumbing, Electrical, IT). It bridges the gap between users, administrators, and maintenance engineers through a unified mobile interface.

**Problem Statement:**  
Traditional complaint handling often relies on manual logs or disjointed communication, leading to delays, lack of transparency, and unresolved issues.

**Purpose:**  
To provide a digital platform where:
- **Users** can easily report and track issues.
- **Admins** can oversee operations and manage assignments.
- **Engineers** can receive tasks and update statuses in real-time.

---

## 🚀 Features

### 👤 User Features
- **Secure Authentication**: Google Sign-In and Email/Password login.
- **Complaint Registration**: Submit complaints with category, priority, and description.
- **Status Tracking**: Real-time updates (Pending, Assigned, In Progress, Resolved).
- **History**: View past complaints and admin responses.

### 🛠 Engineer Features
- **Job Dashboard**: View assigned complaints.
- **Status Updates**: Mark complaints as "In Progress" or "Resolved".
- **Specialization-Based Assignment**: Automatically receive tasks matching their expertise.

### 🛡 Admin Features
- **Master Dashboard**: Overview of all complaints and their statuses.
- **Manual Assignment**: Override auto-assignment to assign specific engineers.
- **User Management**: Approve or reject new engineer/user registrations.
- **Response System**: Add official responses to complaints.

---

## 💻 Tech Stack

- **Frontend**: Flutter (Android Application)
- **Backend**: Core PHP (REST API, no framework)
- **Database**: MySQL (Relational Schema)
- **Server**: PHP Built-in Server (Development)

---

## 📂 Folder Structure

```
/
├── backend/               # PHP REST API & Database Scripts
│   ├── api/               # API Endpoints (admin, complaints, etc.)
│   ├── config/            # Database Connection
│   ├── database.sql       # Complete Database Schema & Seed Data
│   └── ...
├── complaint_mgmt_App/    # Flutter Mobile Application
│   ├── lib/               # Dart Source Code
│   │   ├── main.dart      # App Entry Point
│   │   ├── models/        # Data Models
│   │   ├── screens/       # UI Screens (User, Admin, Engineer)
│   │   ├── services/      # API Integration Logic
│   │   └── widgets/       # Reusable UI Components
│   └── pubspec.yaml       # Dependencies
└── requirements.txt       # Project Prerequisites
```

---

## ⚙️ Database Setup

1.  **Install XAMPP** (or any MySQL server).
2.  Start **Apache** and **MySQL** in XAMPP Control Panel.
3.  Open phpMyAdmin (`http://localhost/phpmyadmin`).
4.  Create a new database named `complaint_management`.
5.  **Import** the `backend/database.sql` file:
    - Click "Import" tab.
    - Choose File -> `backend/database.sql`.
    - Click "Go".
    *This creates the tables and inserts default admin/engineer accounts.*

### Default Credentials

The `database.sql` file seeds the database with the following accounts.  
**All Passwords are:** `password123`

| Role | Email | Specialization |
| :--- | :--- | :--- |
| **Admin** | `admin@example.com` | N/A |
| **Engineer** | `plumbing_eng@example.com` | Plumbing |
| **Engineer** | `electrical_eng@example.com` | Electrical |
| **Engineer** | `network_eng@example.com` | Network |
| **Engineer** | `software_eng@example.com` | Software |
| **Engineer** | `civil_eng@example.com` | Civil |

*(See `backend/database.sql` for the full list of engineers)*

---

## 🚀 How to Run Backend

The app utilizes the local PHP built-in server for simplicity.

1.  Open a terminal/command prompt.
2.  Navigate to the backend directory:
    ```bash
    cd D:\visanka\backend
    ```
3.  Start the server on port 8000:
    ```bash
    C:\xampp\php\php.exe -S 0.0.0.0:8000
    ```
    *(Adjust path to `php.exe` if necessary)*

> **Note:**
> - `0.0.0.0` allows access from external devices (like the Android Emulator).
> - Android Emulator uses `10.0.2.2` to access localhost.
> - Physical devices require using your PC's local IP (e.g., `192.168.1.X`).

---

## 📱 How to Run Flutter App

1.  Navigate to the app directory:
    ```bash
    cd D:\visanka\complaint_mgmt_App
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  **Important:** Check `lib/utils/constants.dart` (or `api_constants.dart`) to ensure the `baseUrl` matches your backend IP (default is distinct for Emulator vs Physical).
4.  Run the app:
    ```bash
    flutter run
    ```

---

## 🧭 How to Navigate the App

### 1. User Flow
- **Register** a new account (Wait for admin approval if required) or **Login** with Google.
- Tap **"+"** to create a complaint. select Category (e.g., Electrical) and Priority.
- View the complaint in the **"My Complaints"** list.
- Watch the status change from *Pending* -> *In Progress* -> *Resolved*.

### 2. Admin Flow
- Login as Admin.
- **Dashboard**: View tiles for Total, Pending, and Resolved complaints.
- **Complaints Manager**:
    - **Unassigned Tab**: See new complaints. Click to view details and **Manually Assign** an engineer if needed.
    - **Assigned Tab**: Track active jobs.
- **User Management**: Approve pending engineer registrations.

### 3. Engineer Flow
- Login as Engineer (e.g., `plumbing_eng@example.com` / `password123`).
- **Dashboard**: See complaints assigned to you (either automatically by category or manually by Admin).
- Open a complaint and use **"Update Status"** to mark it as *In Progress* or *Resolved*.

---

## 🔒 Security Measures

- **Password Hashing**: All passwords are hashed using `password_hash()` (BCrypt) before storage.
- **Prepared Statements**: All SQL queries use PDO prepared statements to prevent SQL Injection.
- **Input Sanitization**: User inputs are validated and sanitized to prevent XSS.
- **Role-Based Access Control**: Middleware ensures Users cannot access Admin APIs and vice-versa.

---

## 📝 Development Notes

- **Branching**: Followed a feature-branch workflow (feature/auth, feature/admin-dashboard).
- **Architecture**: Modular separation of concerns (Services for API, Models for Data, Screens for UI).
- **Challenges**:
    - Configuring CORS for the PHP built-in server to accept Flutter requests.
    - Handling asynchronous Google Sign-In flow with custom backend verification.
    - Implementing the logic to filter "Assigned" vs "Unassigned" complaints effectively on the frontend.

---

*Verified for Mini Project Submission - 2026*

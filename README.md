# Complaint Management System (Group 5)

Start-to-end solution for managing institution complaints with Role-Based Access Control. Built with **Flutter** (Frontend) and **PHP/MySQL** (Backend).

![Project Status](https://img.shields.io/badge/Status-Completed-success)
![Tech Stack](https://img.shields.io/badge/Stack-Flutter%20|%20PHP%20|%20MySQL-blue)

## 📌 Optimization & Features
The system streamlines the complaint resolution process by connecting Users, Admins, and Engineers in a seamless workflow.

### Key Features
- **Secure Authentication**: JWT-based login with Google Sign-In & Email/Password.
- **Role-Based Access**:
  - **User**: Register complaints, track status, view history.
  - **Admin**: Approve/Reject users, oversee all complaints, generate reports.
  - **Engineer**: View assigned tasks, update status (In Progress/Resolved).
- **Intelligent Auto-Assignment**: Complaints are automatically routed to the relevant engineer based on category (IT, Electrical, Civil) and workload.
- **Real-time Status Tracking**: Users get live updates on their complaint progress.

---

## 🛠 Tech Stack

| Component | Technology | Description |
|-----------|------------|-------------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile application. |
| **Backend** | Native PHP | REST API with PDO & JWT Middleware. |
| **Database** | MySQL | Relational database for storing users, complaints, and logs. |
| **Security** | Bcrypt & JWT | Password hashing and token-based session management. |

---

## 📂 Repository Structure

```
/
├── backend/            # PHP API & Logic
│   ├── api/            # Endpoints (auth, complaints, admin)
│   ├── config/         # Database connection
│   └── utils/          # Helper functions (JWT, Response)
├── flutter_app/        # Mobile App Code
│   ├── lib/
│   │   ├── screens/    # UI Pages
│   │   ├── services/   # API Integration
│   │   └── widgets/    # Reusable UI components
├── database/           # SQL Import Files
└── docs/               # Documentation & Assets
```

---

## 🚀 Setup Instructions

### 1. Backend Setup
1.  Import `database/schema.sql` into your MySQL database (Create DB: `complaint_management`).
2.  Configure `backend/config/database.php` with your DB credentials.
3.  Host the `backend` folder on a PHP server (XAMPP/Apache).

### 2. Frontend Setup
1.  Ensure **Flutter SDK** is installed.
2.  Navigate to `flutter_app/`.
3.  Run `flutter pub get` to install dependencies.
4.  Update `lib/config/api_config.dart` with your local IP address.
5.  Run `flutter run`.

---

## 👥 Team & Roles (Group 5)

| Role | Responsibilities |
|------|------------------|
| **Backend Core** | API Architecture, Auth Logic, Security implementation. |
| **Backend Database** | Schema Design, SQL Optimization, Data Integrity. |
| **Flutter UI** | Screen Design, Widget implementation, UX Flow. |
| **Flutter Integration** | API Connectivity, State Management, Documentation. |

---

## 📸 Screenshots
*(Add screenshots of Login, Dashboard, and Admin Panel here)*

---
*Created for Academic Evaluation 2026*

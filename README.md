#Complaint Management System (Group 5)

Start-to-end solution for managing institution complaints with Role-Based Access Control. Built with **Flutter** (Frontend) and **PHP/MySQL** (Backend).

![Project Status](https://img.shields.io/badge/Status-Completed-success)
![Tech Stack](https://img.shields.io/badge/Stack-Flutter%20|%20PHP%20|%20MySQL-blue)

---

## 📌 Optimization & Features

The system streamlines the complaint resolution process by connecting Users, Admins, and Engineers in a seamless workflow.

### 🔹 Key Features

- **Secure Authentication**
  - JWT-based login
  - Google Sign-In
  - Email/Password login

- **Role-Based Access**
  - **User**: Register complaints, track status, view history.
  - **Admin**: Approve/Reject users, oversee all complaints.
  - **Engineer**: View assigned tasks, update complaint status.

- **Intelligent Auto-Assignment**
  - Complaints are automatically routed to the relevant engineer
  - Assignment based on specialization and workload

- **Real-Time Status Tracking**
  - Users can monitor complaint progress instantly

---

## 🛠 Tech Stack

| Component | Technology | Description |
|------------|------------|-------------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile application |
| **Backend** | Native PHP | REST API using PDO & JWT Middleware |
| **Database** | MySQL | Relational database |
| **Security** | Bcrypt & JWT | Password hashing + token-based authentication |

---

## 📂 Repository Structure

/
├── backend/ # PHP API & Logic
│ ├── api/
│ ├── config/
│ └── utils/
├── flutter_app/ # Mobile Application
│ ├── lib/
│ │ ├── screens/
│ │ ├── services/
│ │ └── widgets/
├── database/ # SQL Schema
├── docs/ # Screenshots & Diagrams
├── README.md
└── SUBMISSION_GUIDE.md


---

## 🚀 Setup Instructions

### 1️⃣ Backend Setup

1. Create database: `complaint_management`
2. Import `database/schema.sql`
3. Configure `backend/config/database.php`
4. Run backend using:
php -S 0.0.0.0:8000


---

### 2️⃣ Flutter Setup

1. Navigate to `flutter_app/`
2. Run:
flutter pub get

3. Update `api_config.dart` with correct backend URL
4. Run:
flutter run


---

## 👥 Team Roles – Group 5

| Role | Responsibility |
|------|----------------|
| Backend Core | API logic, JWT, Authentication |
| Backend Support/DB | Database schema, SQL integrity |
| Flutter UI | Screens, UX design |
| Flutter Integration | API connectivity, testing |

---

## 📸 Screenshots

(Add Login, Dashboard, Admin, Engineer Screenshots in `/docs`)

---

### 📌 Academic Submission 2026

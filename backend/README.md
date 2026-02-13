# Complaint Management System (CMS) Upgrade

## 🚀 Upgrade Features
This system has been upgraded to include:
- **Dual Login**: Support for both Email/Password and Google Login.
- **Strict Approval Logic**: Engineers and Admins require Super Admin approval before accessing the system.
- **Auto-Assignment**: Complaints are automatically assigned to Engineers based on their specialization.
- **Default Super Admin**: A built-in super admin account to manage approvals.

---

## 🔑 Default Super Admin Credentials
Use these credentials to log in and approve pending users:

- **Email**: `admin@cms.com`
- **Password**: `Admin@123`

> **Note**: This account is auto-approved and cannot be deleted.

---

## 🛡️ System Role Rules

### 1. User
- **Registration**: Auto-approved immediately.
- **Access**: Can create complaints and view their own history.
- **Login**: Email/Password or Google.

### 2. Engineer
- **Registration**: Status set to **PENDING** upon registration.
- **Access**: Cannot log in until approved by an Admin.
- **Specialization**: Must select a specialization (e.g., Plumbing, Electrical) during registration.
- **Work**: Automatically assigned complaints matching their specialization.

### 3. Admin
- **Registration**: Status set to **PENDING** upon registration.
- **Access**: Cannot log in until approved by an Admin (or Super Admin).
- **Capabilities**: Manage users (Approve/Reject), view all complaints, reassign tasks.

---

## 🔄 Admin Approval Flow
1. **Pending Users**: New Engineers and Admins sign up but get a "Pending Approval" message.
2. **Review**: Super Admin (or any approved Admin) logs in.
3. **Action**: Admin uses the dashboard (API endpoints) to:
    - `GET /api/admin/pending_users.php` - View list of pending accounts.
    - `POST /api/admin/approve_user.php` - Approve a user (Status -> Approved).
    - `POST /api/admin/reject_user.php` - Reject a user (Status -> Rejected).
4. **Access Granted**: Once approved, the user can log in and receive a JWT.

---

## 🛠️ API Endpoints

### Authentication
- `POST /auth/register.php` - Register new user.
- `POST /auth/login.php` - Email/Password Login.
- `POST /auth/google_auth.php` - Google Login.

### Admin
- `GET /api/admin/pending_users.php` - List pending users.
- `POST /api/admin/approve_user.php` - Approve user.
- `POST /api/admin/reject_user.php` - Reject user.

### Complaints
- `POST /api/complaints/create.php` - Create complaint (with auto-assignment).

---

## 📂 Database Updates
The database schema has been updated to support:
- `password` column for email login.
- `specialization` for engineers.
- `status` ('pending', 'approved', 'rejected') for access control.
- `assignee_id` in complaints table for auto-assignment.

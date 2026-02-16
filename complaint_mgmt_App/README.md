# ResolvePro - Smart Complaint Resolution System

## 🚀 Project Overview
ResolvePro is an enterprise-grade complaint management system featuring a premium Flutter UI and a robust PHP/MySQL backend.

## 👥 Role-Based Access
- **Admin**: Overall system management, user approvals, and manual engineer assignment.
- **Engineer**: Manage assigned tasks based on specialization.
- **User**: Register complaints and track resolution status.

## 🛠 Default Staff Credentials (For Testing)

| Role | Category/Specialization | Email | Password |
| :--- | :--- | :--- | :--- |
| **Admin** | System Admin | admin@resolvepro.com | admin123 |
| **Engineer** | AC Repair | ac@resolvepro.com | pass1234 |
| **Engineer** | Plumbing | plumbing@resolvepro.com | pass1234 |
| **Engineer** | Electrical | electric@resolvepro.com | pass1234 |
| **Engineer** | Hardware | hardware@resolvepro.com | pass1234 |
| **Engineer** | Network | network@resolvepro.com | pass1234 |
| **Engineer** | Software | software@resolvepro.com | pass1234 |
| **Engineer** | General | general@resolvepro.com | pass1234 |

## ⚙️ Automatic Assignment Logic
Complaints are automatically assigned to an engineer whose **Specialization** matches the **Complaint Category**.
- If a match is found: Status = `Assigned`.
- If no match found: Status = `Pending Assignment` (Notifies Admin).

## 📱 Getting Started
1. Run `flutter pub get`
2. Ensure backend is running at the URL specified in `lib/config/api_config.dart`.
3. Run `flutter run`

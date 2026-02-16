# ResolvePro – Smart Complaint Resolution System

A role-based complaint management system built to streamline issue reporting and resolution in organizational environments. This project was developed as a mini-project to demonstrate full-stack mobile application development with Flutter and PHP.

## Overview

ResolvePro is designed to solve a common problem in colleges, offices, and residential complexes: inefficient complaint handling. Traditional methods like email chains or manual registers often lead to lost complaints, unclear accountability, and delayed responses. This system provides a centralized platform where users can register complaints, track their status in real-time, and receive timely updates.

The system implements role-based access control with three distinct user types:
- **Users** can submit complaints and monitor their progress
- **Engineers** receive assigned complaints based on their specialization and update resolution status
- **Admins** have oversight of all complaints and can manually reassign tasks when needed

## Why This Project?

During development, I encountered several real-world challenges that made this more than just a theoretical exercise. The auto-assignment logic, for instance, initially had issues where complaints weren't being assigned to the right engineers. Debugging that taught me a lot about database relationships and query optimization. I also had to rethink the authentication flow multiple times to balance security with user experience.

The goal was to create something that could actually be deployed in a real environment, not just a proof-of-concept. That meant focusing on security (password hashing, input validation), usability (intuitive UI, clear status indicators), and maintainability (clean code structure, proper error handling).

## Core Features

### Authentication & Authorization
- Dual login support: Email/Password and Google Sign-In
- Role-based access control (User, Engineer, Admin)
- Approval workflow for Engineer and Admin accounts
- JWT-based session management
- Secure password hashing with bcrypt

### Complaint Management
- Category-based complaint registration (Plumbing, Electrical, Network, etc.)
- Priority levels (Low, Medium, High)
- Automatic engineer assignment based on specialization
- Manual reassignment capability for admins
- Real-time status tracking (Pending, In Progress, Resolved)
- Detailed complaint history and timeline

### Role-Specific Dashboards
- **User Dashboard**: View submitted complaints, track status, create new complaints
- **Engineer Dashboard**: View assigned complaints, update status, manage workload
- **Admin Dashboard**: Overview of all complaints, reassignment controls, user management

### Smart Assignment System
One of the more complex features was implementing automatic assignment. When a user submits a complaint, the system:
1. Identifies the complaint category
2. Finds all approved engineers with matching specialization
3. Assigns to the engineer with the fewest active complaints
4. Falls back to general engineers if no specialist is available

This required careful database design and some trial-and-error to get right.

## Technology Stack

### Frontend
- **Flutter 3.x** - Cross-platform mobile framework
- **Dart 3.x** - Programming language
- **Provider** - State management
- **HTTP** - API communication
- **Google Sign-In** - OAuth authentication
- **Shared Preferences** - Local storage

### Backend
- **PHP 8.x** - Server-side logic (no framework, plain PHP)
- **MySQL 8.x** - Relational database
- **PDO** - Database abstraction with prepared statements
- **JWT** - Token-based authentication
- **PHP Built-in Server** - Development server

### Development Tools
- **XAMPP** - MySQL database management (phpMyAdmin)
- **Android Studio / VS Code** - IDE
- **Git** - Version control

## Project Structure

```
d:\visanka\
├── complaint_mgmt_App/          # Flutter mobile application
│   ├── lib/
│   │   ├── config/              # API configuration
│   │   ├── models/              # Data models
│   │   ├── screens/             # UI screens
│   │   ├── services/            # API services
│   │   └── widgets/             # Reusable components
│   ├── android/                 # Android platform files
│   ├── ios/                     # iOS platform files
│   └── pubspec.yaml             # Flutter dependencies
│
├── backend/                     # PHP REST API
│   ├── api/
│   │   ├── complaints/          # Complaint endpoints
│   │   ├── categories/          # Category endpoints
│   │   └── users/               # User management
│   ├── auth/                    # Authentication logic
│   ├── config/                  # Database configuration
│   ├── middleware/              # Auth middleware
│   ├── utils/                   # Helper functions
│   └── start_server.bat         # Server startup script
│
├── database/
│   └── schema.sql               # Database schema and seed data
│
└── docs/
    └── complaint management system.mp4  # Demo video
```

## Database Setup

### Step 1: Create Database

1. Start XAMPP and ensure **MySQL** is running (Apache is not needed)
2. Open phpMyAdmin at `http://localhost/phpmyadmin`
3. Create a new database named `complaint_management`
4. Click on the **Import** tab
5. Select the file `d:\visanka\database\schema.sql`
6. Click **Go** to import the schema and default data

### Step 2: Configure Database Connection

1. Navigate to `d:\visanka\backend\config\`
2. Open `database.php`
3. Update credentials if needed (default XAMPP has no password for root):

```php
$host = 'localhost';
$db_name = 'complaint_management';
$username = 'root';
$password = '';  // Leave empty for default XAMPP
```

The schema includes default categories (Plumbing, Electrical, Network, etc.) and creates the necessary tables with proper foreign key relationships.

## Running the Backend

I'm running the backend using PHP's built-in server rather than XAMPP's Apache. This gives more control and is simpler for development.

### Method 1: Using PHP Built-in Server (Recommended)

This is my current setup and what I recommend:

1. Open Command Prompt or PowerShell
2. Navigate to the backend directory:
   ```cmd
   cd D:\visanka\backend
   ```
3. Start the PHP server:
   ```cmd
   C:\xampp\php\php.exe -S 0.0.0.0:8000
   ```

The backend will now be accessible at:
```
http://localhost:8000
```

**Important**: When configuring the Flutter app, use this as your API base URL:
```dart
static const String baseUrl = 'http://localhost:8000';
```

For testing on a physical Android device, use your computer's local IP address (e.g., `http://192.168.1.x:8000`).

**Note**: `0.0.0.0` allows connections from other devices on your network, which is useful for testing on physical devices. If you only need localhost access, you can use `localhost:8000` instead.

### Method 2: Using Batch File

For convenience, I've included a batch file that automates the server startup:

```cmd
cd D:\visanka\backend
start_server.bat
```

This runs the same command as Method 1.

### Method 3: Using XAMPP Apache (Alternative)

If you prefer using XAMPP's Apache server:

1. Copy the `backend` folder to `C:\xampp\htdocs\`
2. Start Apache in XAMPP Control Panel
3. Access the backend at:
   ```
   http://localhost/backend/
   ```
4. Update Flutter's API config to:
   ```dart
   static const String baseUrl = 'http://localhost/backend';
   ```

I found the built-in server approach cleaner for development, but both methods work fine.

## Running the Flutter App

### Step 1: Install Dependencies

Navigate to the Flutter app directory and install packages:

```cmd
cd D:\visanka\complaint_mgmt_App
flutter pub get
```

### Step 2: Configure API Base URL

Before running the app, verify the API configuration:

1. Open `lib/config/api_config.dart`
2. Ensure `baseUrl` matches your backend setup:

```dart
// For Android Emulator with PHP built-in server
static const String baseUrl = 'http://10.0.2.2:8000';

// For physical device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.x:8000';
```

**Note**: `10.0.2.2` is a special IP that Android emulators use to access the host machine's `localhost`.

### Step 3: Run the Application

**Ensure the backend server is running first**, then:

```cmd
flutter run
```

If you have multiple devices connected, Flutter will prompt you to select one. Choose your emulator or physical device.

### Troubleshooting

- **Connection refused**: Make sure the backend server is running and the API URL is correct
- **Database errors**: Verify MySQL is running and credentials in `config/database.php` are correct
- **Google Sign-In issues**: This requires proper SHA-1 fingerprint configuration in Google Cloud Console (optional for basic testing)

## Security Implementation

Security was a priority throughout development:

### Password Security
- All passwords are hashed using `password_hash()` with bcrypt algorithm
- Password verification uses `password_verify()` for constant-time comparison
- No passwords are stored in plain text

### SQL Injection Prevention
- All database queries use PDO prepared statements
- User input is never directly concatenated into SQL queries
- Parameterized queries throughout the codebase

### Authentication & Authorization
- JWT tokens for stateless authentication
- Role-based access control enforced on every API endpoint
- Middleware validates tokens and user roles before processing requests

### Input Validation
- Server-side validation for all user inputs
- Email format validation
- Required field checks
- Data type verification

### Error Handling
- Generic error messages to avoid information leakage
- Detailed errors logged server-side for debugging
- Graceful failure handling in the Flutter app

## Testing Credentials

The system auto-generates default engineer accounts for each category during database setup:

| Category   | Email                        | Password    |
|------------|------------------------------|-------------|
| Plumbing   | plumbing_eng@example.com     | password123 |
| Electrical | electrical_eng@example.com   | password123 |
| Network    | network_eng@example.com      | password123 |
| Hardware   | hardware_eng@example.com     | password123 |
| AC Repair  | acrepair_eng@example.com     | password123 |
| Software   | software_eng@example.com     | password123 |
| General    | general_eng@example.com      | password123 |
| Carpentry  | carpentry_eng@example.com    | password123 |
| Painting   | painting_eng@example.com     | password123 |
| Cleaning   | cleaning_eng@example.com     | password123 |
| Civil      | civil_eng@example.com        | password123 |
| Facility   | facility_eng@example.com     | password123 |
| Other      | other_eng@example.com        | password123 |

You can create regular user accounts through the app's registration flow. Admin accounts need to be created manually in the database or promoted from existing users.

## Git & Version Control

The project uses Git for version control with a feature-based branching strategy:

- `main` - Stable production code
- `backend-core` - API and authentication development
- `backend-support` - Database and configuration
- `flutter-ui` - UI screens and widgets
- `flutter-integration` - API integration and state management

Commits follow conventional commit format:
```
feat(scope): description
fix(scope): description
docs: description
```

This made it easier to track changes and collaborate, even though I was working solo for most of it.

## API Endpoints Reference

### Authentication
- `POST /auth/google_auth.php` - Google Sign-In / Register
- `POST /auth/login.php` - Email/Password login
- `POST /auth/register.php` - User registration

### Complaints
- `POST /api/complaints/create.php` - Create new complaint
- `GET /api/complaints/list.php` - Get user's complaints
- `GET /api/complaints/list_all.php` - Get all complaints (Admin/Engineer)
- `PUT /api/complaints/update_status.php` - Update complaint status
- `PUT /api/complaints/reassign.php` - Reassign complaint (Admin)

### Categories
- `GET /api/categories/list.php` - Get all categories

### Users
- `GET /api/users/list_engineers.php` - Get all engineers (Admin)
- `PUT /api/users/update_status.php` - Approve/Reject users (Admin)

## Lessons Learned

Building this project taught me several valuable lessons:

1. **Database design matters**: Getting the relationships right from the start saved a lot of refactoring later
2. **Error handling is crucial**: Spent a lot of time making sure the app doesn't crash on network errors or invalid data
3. **Testing is not optional**: The auto-assignment bug would have been caught earlier with proper testing
4. **Documentation helps future you**: Coming back to code after a few days made me appreciate good comments
5. **Security is a mindset**: Had to constantly think about what could go wrong and how to prevent it

## Future Enhancements

If I continue developing this, potential improvements include:

- Push notifications for complaint status updates
- File attachment support for complaints
- Analytics dashboard for admins
- Rating system for engineer performance
- Complaint escalation after timeout
- Email notifications
- Dark mode for the mobile app

## License

This project was developed for educational purposes as part of a mini-project submission.

---

**Developed by**: Group 5  
**Project Duration**: February 2026  
**Tech Stack**: Flutter + PHP + MySQL

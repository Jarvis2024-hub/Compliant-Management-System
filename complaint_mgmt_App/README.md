# Complaint Management System

A mobile application for managing user complaints with role-based access control.

## Technology Stack
- **Frontend**: Flutter
- **Backend**: Plain PHP (No framework)
- **Database**: MySQL
- **Authentication**: Google OAuth
- **Authorization**: JWT Tokens

## Features
- Role-based authentication (User/Admin)
- Google Sign-In integration
- Complaint registration and tracking
- Admin complaint management
- Real-time status updates

## Installation

### Backend Setup
1. Clone repository
2. Import `database.sql` to MySQL
3. Configure database credentials in `config/database.php`
4. Set JWT secret in `config/jwt_config.php`
5. Deploy to PHP server (Apache/Nginx)

### Frontend Setup
1. Install Flutter SDK
2. Run `flutter pub get`
3. Update API URL in `lib/config/api_config.dart`
4. Configure Google Sign-In (see Google Console setup)
5. Run `flutter run`

## Google OAuth Setup
1. Go to Google Cloud Console
2. Create new project
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized domains
6. Download configuration files

## Database Schema
- users (id, google_id, name, email, role)
- categories (id, category_name)
- complaints (id, user_id, category_id, description, priority, status)
- admin_responses (id, complaint_id, response)

## API Endpoints
See Postman collection for complete API documentation

## Team Roles
- Backend Lead: API architecture, authentication
- Backend Support: Database design, queries
- Flutter Developer: UI/UX implementation
- Integration: API integration, testing

## Testing
Use Postman collection provided in `/postman` folder

## License
Academic Project - Not for production use
# How to Run the Complaint Management System

This guide will walk you through setting up and running the Complaint Management System, which consists of a PHP backend and a Flutter mobile application.

## Prerequisites

1.  **XAMPP/WAMP/MAMP**: A local server environment to run PHP and MySQL.
    -   Download XAMPP: [https://www.apachefriends.org/index.html](https://www.apachefriends.org/index.html)
2.  **Flutter SDK**: To run the mobile application.
    -   Install Flutter: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
3.  **Code Editor**: VS Code or Android Studio.

---

## Step 1: Backend Setup

1.  **Locate Project Files**:
    -   Navigate to `d:\visanka\complaint-management-backend`.

2.  **Start Local Server**:
    -   Open XAMPP Control Panel.
    -   Start **Apache** and **MySQL**.

3.  **Deploy Backend**:
    -   Copy the `complaint-management-backend` folder to your XAMPP `htdocs` directory (usually `C:\xampp\htdocs`).
    -   **Important**: If you keep it in `d:\visanka`, you must configure a virtual host or alias in Apache to point to this directory.
    -   *Simpler approach*: Copy the folder to `C:\xampp\htdocs\complaint-management-backend`.

4.  **Database Setup**:
    -   Open your browser and go to `http://localhost/phpmyadmin`.
    -   Create a new database named `complaint_management`.
    -   Click on the **Import** tab.
    -   Choose the file `d:\visanka\complaint-management-backend\database.sql`.
    -   Click **Go** to import the schema and default data.

5.  **Configure Database Connection**:
    -   Open `config/database.php` in the backend folder.
    -   Update the credentials if your MySQL password is not empty (default XAMPP has no password for `root`).

---

## Step 2: Frontend Setup

1.  **Navigate to App Directory**:
    -   Open a terminal/command prompt.
    -   Go to `d:\visanka\complaint_mgmt_App`.

2.  **Install Dependencies**:
    -   Run the following command to download required packages:
        ```bash
        flutter pub get
        ```

3.  **Configure API URL**:
    -   Open `lib/config/api_config.dart`.
    -   The `baseUrl` is set to `http://10.0.2.2/visanka/complaint-management-backend`.
    -   **Note**: `10.0.2.2` is a special IP address for the Android emulator to access your computer's `localhost`.
    -   If you moved the backend to `htdocs`, update the URL to:
        ```dart
        static const String baseUrl = 'http://10.0.2.2/complaint-management-backend';
        ```
    -   If testing on a physical device, use your computer's local IP address (e.g., `192.168.1.x`).

---

## Step 3: Running the App

1.  **Start Emulator**:
    -   Launch an Android emulator from Android Studio.

2.  **Run the App**:
    -   In your terminal (inside `complaint_mgmt_App`), run:
        ```bash
        flutter run
        ```

---

## Troubleshooting

-   **Connection Refused**: Ensure Apache and MySQL are running in XAMPP. Check if the URL in `api_config.dart` matches your server path.
-   **Database Error**: Check `config/database.php` credentials. Ensure the database `complaint_management` exists and tables are imported.
-   **Google Sign-In**: This requires a SHA-1 fingerprint configuration in the Google Cloud Console. For local testing without valid credentials, you might need to bypass auth or configure it properly with your keystore.

## API Endpoints (For Reference)

-   **POST** `/auth/google_auth.php`: Login/Register
-   **GET** `/api/categories/list.php`: Get categories
-   **POST** `/api/complaints/create.php`: Create complaint
-   **GET** `/api/complaints/list.php`: Get user complaints
-   **PUT** `/api/complaints/update_status.php`: Admin update status

# Professional GitHub Submission Guide
**Group 5: Complaint Management System**

This guide outlines the standards for repository structure, branching, and submission to ensure a professional evaluation.

---

## 1. Repository Structure
We have structured the repository to clearly separate concerns, making it easy for evaluators to navigate.

```
/ (Root)
├── backend/            # PHP API logic, config, and utilities
├── flutter_app/        # Flutter mobile application source code
├── database/           # SQL dumps and schema diagrams
├── docs/               # Screenshots, diagrams, and project report
├── .gitignore          # Files to exclude from Git
├── README.md           # Main project overview for evaluators
└── SUBMISSION_GUIDE.md # (This file) Git workflow and submission standards
```

### Why this structure?
- **backend/**: Isolates server-side logic from the client app.
- **flutter_app/**: Contains the standard Flutter project structure (`lib`, `android`, `ios`).
- **database/**: Ensures the DB schema is versioned and easily importable.
- **docs/**: Keeps documentation separate from code, cleaner for review.

---

## 2. Branch Strategy
To demonstrate teamwork and organized development, use the following branch strategy:

| Branch Name          | Purpose | Who Pushes? |
|----------------------|---------|-------------|
| `main`               | **Stable, Production Code.** Only merge here when verified. | Team Lead |
| `backend-core`       | API, Auth, and Database logic updates. | Backend Devs |
| `flutter-ui`         | UI Screens, Widgets, and Design changes. | Flutter UI Devs |
| `flutter-integration`| Connecting UI with API, State Management. | Integration Dev |

### Merge Workflow
1.  Work on your specific branch (e.g., `flutter-ui`).
2.  Test changes locally.
3.  Create a **Pull Request (PR)** to `main` (even if you are the only one approving, it shows process).
4.  Merge only working code.

---

## 3. Commit Standards
Follow **Conventional Commits** to show professionalism.

**Format:** `type(scope): description`

### Types:
- `feat`: New feature (e.g., `feat(auth): add google login`)
- `fix`: Bug fix (e.g., `fix(api): resolve json error`)
- `docs`: Documentation (e.g., `docs: update readme`)
- `style`: Formatting, missing semicolons (no code change)
- `refactor`: Code change that neither fixes a bug nor adds a feature

**Examples:**
- `feat(ui): add engineer dashboard screen`
- `fix(db): correct complaint status column type`
- `chore: clean up unused test files`

❌ **bad:** "fixed bug", "update", "final code"

---

## 4. Pre-Submission Checklist

Before the final push, ensure:
- [ ] **No Hardcoded Secrets**: Ensure API keys (if any) are environmental variables or documented placeholders.
- [ ] **Clean Code**: Remove commented-out code blocks and `print()`/`echo` debug statements.
- [ ] **Database Dump**: Export the latest structure + sample data to `database/schema.sql`.
- [ ] **README**: Ensure all setup steps are accurate.
- [ ] **.gitignore**: Verify `vendor/`, `build/`, `.idea/` are ignored.

---

## 5. Evaluation & Viva Guide

### What Evaluators Look For:
1.  **Code Organization**: Separation of backend/frontend (Achieved).
2.  **Security**: Password hashing (bcrypt), SQL Injection prevention (Prepared Statements), Auth checks.
3.  **Completeness**: Does the flow work from User -> Admin -> Engineer -> User?
4.  **Team Contribution**: Git history showing multiple contributors (or distinct branches).

### Common Viva Questions:
- **Q: How do you handle security?**
  - *A: We use JWT for stateless authentication, bcrypt for password hashing, and PDO prepared statements to prevent SQL injection.*
- **Q: How does the auto-assignment work?**
  - *A: The backend logic checks the complaint category and assigns it to an engineer specialized in that category with the fewest active tasks.*
- **Q: Why Flutter and PHP?**
  - *A: Flutter allows for a cross-platform native experience, while PHP provides a lightweight, widely-supported backend environment perfect for this scale.*

---

## 6. Final Git Command Sequence (Execution)

Run these commands to set up the repository from your current local folder:

```bash
# 1. Initialize Git (if not done)
git init

# 2. Add all files
git add .

# 3. Initial Commit
git commit -m "chore: initial project structure setup"

# 4. Create Branches (Simulated for submission)
git branch backend-core
git branch flutter-ui
git branch flutter-integration

# 5. Add Remote (Replace URL)
git remote add origin https://github.com/YourUsername/Complaint-Management-System.git

# 6. Push
git push -u origin main
```

-- Database Creation
CREATE DATABASE IF NOT EXISTS complaint_management;
USE complaint_management;

-- Users Table
-- Stores all users: Regular Users, Admins, Engineers
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    google_id VARCHAR(255) UNIQUE NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NULL,
    role ENUM('user', 'admin', 'engineer') DEFAULT 'user',
    specialization VARCHAR(100) NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
-- Lookup table for complaint categories
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- Complaints Table
-- Main table for storing complaints
CREATE TABLE IF NOT EXISTS complaints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    assignee_id INT NULL,
    description TEXT NOT NULL,
    priority ENUM('Low', 'Medium', 'High') NOT NULL,
    status ENUM('Pending', 'In Progress', 'Resolved') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (assignee_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Admin Responses Table
-- Stores responses from admins to complaints
CREATE TABLE IF NOT EXISTS admin_responses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    response TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE
);

-- Insert Default Categories
INSERT INTO categories (category_name) VALUES 
('Plumbing'), 
('Electrical'), 
('Carpentry'), 
('Painting'), 
('Cleaning'), 
('AC Repair'), 
('Civil'), 
('Hardware'), 
('Software'), 
('Network'), 
('Facility'), 
('Other')
ON DUPLICATE KEY UPDATE category_name = category_name;

-- Insert Default Admin User
-- Password: password123
INSERT INTO users (name, email, password, role, status) VALUES 
('Super Admin', 'admin@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'admin', 'approved')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Insert Default Engineers
-- Password: password123
INSERT INTO users (name, email, password, role, specialization, status) VALUES
('Plumbing Engineer', 'plumbing_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Plumbing', 'approved'),
('Electrical Engineer', 'electrical_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Electrical', 'approved'),
('Network Engineer', 'network_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Network', 'approved'),
('Hardware Engineer', 'hardware_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Hardware', 'approved'),
('AC Repair Engineer', 'acrepair_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'AC Repair', 'approved'),
('Software Engineer', 'software_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Software', 'approved'),
('General Engineer', 'general_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'General', 'approved'),
('Carpentry Engineer', 'carpentry_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Carpentry', 'approved'),
('Painting Engineer', 'painting_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Painting', 'approved'),
('Cleaning Engineer', 'cleaning_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Cleaning', 'approved'),
('Civil Engineer', 'civil_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Civil', 'approved'),
('Facility Engineer', 'facility_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Facility', 'approved'),
('Other Engineer', 'other_eng@example.com', '$2y$10$vyCO18TU2GW622SYP2u3zOKm1kg0AwlE7XxhD1GhXG5C5331QlT02', 'engineer', 'Other', 'approved');

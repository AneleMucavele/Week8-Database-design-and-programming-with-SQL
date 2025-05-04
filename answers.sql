CREATE DATABASE Clinic_booking_systemdb
USE Clinic_booking_systemdb

-- 1. Specializations
CREATE TABLE Specializations (
    specialization_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Doctors
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    specialization_id INT,
    FOREIGN KEY (specialization_id) REFERENCES Specializations(specialization_id)
);

-- 3. Patients
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE
);

-- 4. Appointments
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    reason TEXT,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- 5. Treatments (Many-to-Many: Appointments <-> Treatments)
CREATE TABLE Treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    cost DECIMAL(10,2) NOT NULL
);

CREATE TABLE Appointment_Treatments (
    appointment_id INT,
    treatment_id INT,
    PRIMARY KEY (appointment_id, treatment_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id),
    FOREIGN KEY (treatment_id) REFERENCES Treatments(treatment_id)
);

-- Sample Data

-- Specializations
INSERT INTO Specializations (name) VALUES
('Surgeon'), ('Psychology'), ('Pediatrics'), ('Family Medicine');

-- Doctors
INSERT INTO Doctors (name, email, phone, specialization_id) VALUES
('Dr. Amber Rose', 'amber.rose@clinic.com', '0811111111', 1),
('Dr. Andile Dlamini', 'andile.dlamini@clinic.com', '0822222222', 2),
('Dr. Sam Khumalo', 'sam.khumalo@clinic.com', '0833333333', 4);

-- Patients
INSERT INTO Patients (name, dob, gender, email, phone) VALUES
('Brian Nkomo', '1998-04-11', 'Male', 'brian.nkomo@example.com', '0723456789'),
('Nontombi Nzima', '1999-07-03', 'Female', 'nontombi.nzima@example.com', '0712345678');

-- Appointments
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, reason) VALUES
(1, 1, '2025-05-10 10:00:00', 'Regular check-up'),
(2, 2, '2025-05-11 14:30:00', 'Skin rash');

-- Treatments
INSERT INTO Treatments (name, cost) VALUES
('Blood Test', 300.00),
('ECG', 500.00),
('Skin Cream', 150.00);

-- Appointment_Treatments
INSERT INTO Appointment_Treatments (appointment_id, treatment_id) VALUES
(1, 1), (1, 2),
(2, 3);


-- QUESTION 2

-- Create database
CREATE DATABASE contact_book;

USE contact_book;

-- Users table
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Contacts table
CREATE TABLE Contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

-- create a folder on bash
mkdir contact-book-api && cd contact-book-api

-- initialize project 
npm init -y

-- install dependencies
npm install express mysql2 body-parser

-- create API Files
-- index.js

const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const app = express();
const port = 3000;

app.use(bodyParser.json());

// MySQL Connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'your_password',
    database: 'contact_book'
});

db.connect(err => {
    if (err) throw err;
    console.log("Connected to MySQL database.");
});

// Routes

// Create a new user
app.post('/users', (req, res) => {
    const { name, email } = req.body;
    db.query('INSERT INTO Users (name, email) VALUES (?, ?)', [name, email], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ id: results.insertId, name, email });
    });
});

// Get all contacts for a user
app.get('/users/:id/contacts', (req, res) => {
    const userId = req.params.id;
    db.query('SELECT * FROM Contacts WHERE user_id = ?', [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Create a new contact
app.post('/contacts', (req, res) => {
    const { user_id, name, phone, email } = req.body;
    db.query('INSERT INTO Contacts (user_id, name, phone, email) VALUES (?, ?, ?, ?)', 
        [user_id, name, phone, email], 
        (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(201).json({ id: results.insertId, user_id, name, phone, email });
    });
});

// Update a contact
app.put('/contacts/:id', (req, res) => {
    const contactId = req.params.id;
    const { name, phone, email } = req.body;
    db.query('UPDATE Contacts SET name = ?, phone = ?, email = ? WHERE id = ?', 
        [name, phone, email, contactId], 
        (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ message: 'Contact updated' });
    });
});

// Delete a contact
app.delete('/contacts/:id', (req, res) => {
    const contactId = req.params.id;
    db.query('DELETE FROM Contacts WHERE id = ?', [contactId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Contact deleted' });
    });
});

// Start server
app.listen(port, () => {
    console.log(`API is running at http://localhost:${port}`);
});

-- run API
node index.js


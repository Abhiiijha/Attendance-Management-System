-- ==============================
-- CREATE DATABASE
-- ==============================
CREATE DATABASE attendance_db;
USE attendance_db;
-- ==============================
-- STUDENTS TABLE
-- ==============================
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    hostel_status ENUM('Hostel', 'Dayscholar') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- FACULTY TABLE
-- ==============================
CREATE TABLE faculty (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- SUBJECTS TABLE
-- ==============================
CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    faculty_id INT,
    branch VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (faculty_id) REFERENCES faculty(id) ON DELETE SET NULL
);

-- ==============================
-- ATTENDANCE TABLE
-- ==============================
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    attendance_percentage DECIMAL(5,2) NOT NULL,
    date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
);

-- ==============================
-- INSERT SAMPLE DATA
-- ==============================

INSERT INTO students (name, branch, year, gender, hostel_status) VALUES
('John Doe', 'CSE', 2, 'Male', 'Hostel'),
('Jane Smith', 'CSE', 2, 'Female', 'Hostel'),
('Sam Wilson', 'CSE', 3, 'Male', 'Dayscholar'),
('Sarah Johnson', 'AI', 3, 'Female', 'Hostel'),
('Steve Rogers', 'AI', 3, 'Male', 'Dayscholar'),
('Samantha Lee', 'AI', 2, 'Female', 'Hostel'),
('Tony Stark', 'CSE', 3, 'Male', 'Dayscholar'),
('Natasha Romanoff', 'CSE', 2, 'Female', 'Hostel'),
('Bruce Banner', 'AI', 3, 'Male', 'Hostel'),
('Wanda Maximoff', 'AI', 2, 'Female', 'Dayscholar'),
('Scott Lang', 'CSE', 3, 'Male', 'Dayscholar'),
('Stephen Strange', 'AI', 3, 'Male', 'Dayscholar');

INSERT INTO faculty (name, department) VALUES
('Dr. Arjun Kumar', 'CSE'),
('Dr. Priya Sharma', 'CSE'),
('Dr. Rajesh Patel', 'AI'),
('Dr. Meera Gupta', 'AI'),
('Dr. Vikram Singh', 'CSE');

INSERT INTO subjects (name, faculty_id, branch) VALUES
('DBMS', 1, 'CSE'),
('DBMS', 1, 'AI'),
('JAVA', 1, 'CSE'),
('JAVA', 1, 'AI'),
('JAVA', 2, 'CSE'),
('JAVA', 2, 'AI'),
('Python', 3, 'CSE'),
('Machine Learning', 3, 'AI'),
('Web Development', 4, 'CSE'),
('Deep Learning', 4, 'AI'),
('Data Structures', 5, 'CSE'),
('Algorithms', 5, 'CSE');

-- RANDOM ATTENDANCE DATA
INSERT INTO attendance (student_id, subject_id, attendance_percentage)
SELECT s.id, sub.id, ROUND(60 + RAND()*35,2)
FROM students s
CROSS JOIN subjects sub;

-- ==============================
-- QUERIES (ALL 12)
-- ==============================

-- 1. Students >75% in DBMS for AI
SELECT s.*
FROM students s
JOIN attendance a ON s.id = a.student_id
JOIN subjects sub ON a.subject_id = sub.id
WHERE sub.name = 'DBMS'
AND s.branch = 'AI'
AND a.attendance_percentage > 75;

-- 2. 3rd year >80% in JAVA by Arjun Sir
SELECT s.*
FROM students s
JOIN attendance a ON s.id = a.student_id
JOIN subjects sub ON a.subject_id = sub.id
JOIN faculty f ON sub.faculty_id = f.id
WHERE sub.name = 'JAVA'
AND f.name = 'Dr. Arjun Kumar'
AND s.year = 3
AND a.attendance_percentage > 80;

-- 3. Faculties teaching DBMS
SELECT DISTINCT f.*
FROM faculty f
JOIN subjects s ON f.id = s.faculty_id
WHERE s.name = 'DBMS';

-- 4. Faculties teaching >2 subjects in CSE
SELECT f.*, COUNT(s.id) AS subject_count
FROM faculty f
JOIN subjects s ON f.id = s.faculty_id
WHERE s.branch = 'CSE'
GROUP BY f.id
HAVING COUNT(s.id) > 2;

-- 5. Faculties teaching >3 subjects overall
SELECT f.*, COUNT(s.id) AS subject_count
FROM faculty f
JOIN subjects s ON f.id = s.faculty_id
GROUP BY f.id
HAVING COUNT(s.id) > 3;

-- 6. Students >75% in at least 2 subjects
SELECT s.*, COUNT(a.subject_id) AS subject_count
FROM students s
JOIN attendance a ON s.id = a.student_id
WHERE a.attendance_percentage > 75
GROUP BY s.id
HAVING COUNT(a.subject_id) >= 2;

-- 7. Count shortage (<65%) in CSE
SELECT COUNT(DISTINCT s.id) AS count
FROM students s
JOIN attendance a ON s.id = a.student_id
WHERE s.branch = 'CSE'
AND a.attendance_percentage < 65;

-- 8. Shortage count by department
SELECT s.branch, COUNT(DISTINCT s.id) AS count
FROM students s
JOIN attendance a ON s.id = a.student_id
WHERE a.attendance_percentage < 65
GROUP BY s.branch;

-- 9. Female shortage in CSE
SELECT COUNT(DISTINCT s.id) AS count
FROM students s
JOIN attendance a ON s.id = a.student_id
WHERE s.branch = 'CSE'
AND s.gender = 'Female'
AND a.attendance_percentage < 65;

-- 10. 2nd year female hostel shortage
SELECT COUNT(DISTINCT s.id) AS count
FROM students s
JOIN attendance a ON s.id = a.student_id
WHERE s.year = 2
AND s.gender = 'Female'
AND s.hostel_status = 'Hostel'
AND a.attendance_percentage < 65;

-- 11. Male AI 3rd year dayscholar starting with S
SELECT *
FROM students
WHERE branch = 'AI'
AND year = 3
AND gender = 'Male'
AND hostel_status = 'Dayscholar'
AND name LIKE 'S%';

-- 12. >90% in ALL subjects (CSE & AI)
SELECT s.*
FROM students s
WHERE s.branch IN ('CSE', 'AI')
AND NOT EXISTS (
    SELECT 1
    FROM attendance a
    WHERE a.student_id = s.id
    AND a.attendance_percentage <= 90
);
-- ============================================================
-- Final Project: University Course Management System
-- ============================================================

CREATE DATABASE IF NOT EXISTS university_course_management;
USE university_course_management;


-- ============================================================
-- SCHEMA
-- ============================================================

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    BirthDate DATE,
    EnrollmentDate DATE
);

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100),
    DepartmentID INT,
    Credits INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- NOTE: the given field list for Instructors did NOT include a Salary
-- column, but Query 8 explicitly asks for "the maximum salary of
-- instructors in the Computer Science department" - that query cannot
-- run without a Salary column. A Salary column is added here as the
-- minimum change needed to make Query 8 executable (see README for
-- full explanation).
CREATE TABLE Instructors (
    InstructorID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    DepartmentID INT,
    Salary DECIMAL(10, 2),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);


-- ============================================================
-- SAMPLE DATA (exactly as given in the project document)
-- ============================================================

INSERT INTO Departments (DepartmentID, DepartmentName) VALUES
(1, 'Computer Science'),
(2, 'Mathematics');

INSERT INTO Students (StudentID, FirstName, LastName, Email, BirthDate, EnrollmentDate) VALUES
(1, 'John', 'Doe', 'john.doe@email.com', '2000-01-15', '2022-08-01'),
(2, 'Jane', 'Smith', 'jane.smith@email.com', '1999-05-25', '2021-08-01');

INSERT INTO Courses (CourseID, CourseName, DepartmentID, Credits) VALUES
(101, 'Introduction to SQL', 1, 3),
(102, 'Data Structures', 2, 4);

-- Salary values are placeholders, added only to support Query 8
-- (see note on the Instructors table above)
INSERT INTO Instructors (InstructorID, FirstName, LastName, Email, DepartmentID, Salary) VALUES
(1, 'Alice', 'Johnson', 'alice.johnson@univ.com', 1, 75000.00),
(2, 'Bob', 'Lee', 'bob.lee@univ.com', 2, 68000.00);

INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, EnrollmentDate) VALUES
(1, 1, 101, '2022-08-01'),
(2, 2, 102, '2021-08-01');


-- ============================================================
-- QUERIES TO PERFORM
-- ============================================================

-- ------------------------------------------------------------
-- 1. Perform CRUD Operations on all tables
-- ------------------------------------------------------------

-- Departments
INSERT INTO Departments (DepartmentID, DepartmentName) VALUES (3, 'Physics');
SELECT * FROM Departments;
UPDATE Departments SET DepartmentName = 'Applied Mathematics' WHERE DepartmentID = 2;
DELETE FROM Departments WHERE DepartmentID = 3;

-- Students
INSERT INTO Students (StudentID, FirstName, LastName, Email, BirthDate, EnrollmentDate)
VALUES (3, 'Mira', 'Patel', 'mira.patel@email.com', '2001-03-10', '2023-08-01');
SELECT * FROM Students;
UPDATE Students SET Email = 'john.doe2@email.com' WHERE StudentID = 1;
DELETE FROM Students WHERE StudentID = 3;

-- Courses
INSERT INTO Courses (CourseID, CourseName, DepartmentID, Credits)
VALUES (103, 'Database Systems', 1, 3);
SELECT * FROM Courses;
UPDATE Courses SET Credits = 4 WHERE CourseID = 101;
DELETE FROM Courses WHERE CourseID = 103;

-- Instructors
INSERT INTO Instructors (InstructorID, FirstName, LastName, Email, DepartmentID, Salary)
VALUES (3, 'Carol', 'Smith', 'carol.smith@univ.com', 1, 71000.00);
SELECT * FROM Instructors;
UPDATE Instructors SET DepartmentID = 2 WHERE InstructorID = 1;
DELETE FROM Instructors WHERE InstructorID = 3;

-- Enrollments
INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, EnrollmentDate)
VALUES (3, 1, 102, '2023-01-10');
SELECT * FROM Enrollments;
UPDATE Enrollments SET EnrollmentDate = '2023-01-15' WHERE EnrollmentID = 3;
DELETE FROM Enrollments WHERE EnrollmentID = 3;


-- ------------------------------------------------------------
-- 2. Retrieve students who enrolled after 2022
-- ------------------------------------------------------------

SELECT * FROM Students
WHERE EnrollmentDate > '2022-12-31';


-- ------------------------------------------------------------
-- 3. Retrieve courses offered by the Mathematics department
--    with a limit of 5 courses
-- ------------------------------------------------------------

SELECT c.*
FROM Courses c
JOIN Departments d ON c.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Mathematics'
LIMIT 5;


-- ------------------------------------------------------------
-- 4. Get the number of students enrolled in each course,
--    filtering for courses with more than 5 students
-- ------------------------------------------------------------
-- Note: with only 2 sample enrollments, this returns zero rows -
-- the query is still structurally correct.

SELECT CourseID, COUNT(StudentID) AS student_count
FROM Enrollments
GROUP BY CourseID
HAVING COUNT(StudentID) > 5;


-- ------------------------------------------------------------
-- 5. Find students who are enrolled in both Introduction to SQL
--    and Data Structures
-- ------------------------------------------------------------

SELECT s.*
FROM Students s
WHERE s.StudentID IN (
    SELECT e.StudentID FROM Enrollments e
    JOIN Courses c ON e.CourseID = c.CourseID
    WHERE c.CourseName = 'Introduction to SQL'
)
AND s.StudentID IN (
    SELECT e.StudentID FROM Enrollments e
    JOIN Courses c ON e.CourseID = c.CourseID
    WHERE c.CourseName = 'Data Structures'
);


-- ------------------------------------------------------------
-- 6. Find students who are either enrolled in Introduction to SQL
--    or Data Structures
-- ------------------------------------------------------------

SELECT DISTINCT s.*
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE c.CourseName IN ('Introduction to SQL', 'Data Structures');


-- ------------------------------------------------------------
-- 7. Calculate the average number of credits for all courses
-- ------------------------------------------------------------

SELECT AVG(Credits) AS avg_credits FROM Courses;


-- ------------------------------------------------------------
-- 8. Find the maximum salary of instructors in the
--    Computer Science department
-- ------------------------------------------------------------

SELECT MAX(i.Salary) AS max_salary
FROM Instructors i
JOIN Departments d ON i.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Computer Science';


-- ------------------------------------------------------------
-- 9. Count the number of students enrolled in each department
-- ------------------------------------------------------------

SELECT d.DepartmentName, COUNT(e.StudentID) AS student_count
FROM Departments d
JOIN Courses c ON d.DepartmentID = c.DepartmentID
JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY d.DepartmentName;


-- ------------------------------------------------------------
-- 10. INNER JOIN: Retrieve students and their corresponding courses
-- ------------------------------------------------------------

SELECT s.FirstName, s.LastName, c.CourseName
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN Courses c ON e.CourseID = c.CourseID;


-- ------------------------------------------------------------
-- 11. LEFT JOIN: Retrieve all students and their corresponding
--     courses, if any
-- ------------------------------------------------------------

SELECT s.FirstName, s.LastName, c.CourseName
FROM Students s
LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
LEFT JOIN Courses c ON e.CourseID = c.CourseID;


-- ------------------------------------------------------------
-- 12. Subquery: Find students enrolled in courses that have
--     more than 10 students
-- ------------------------------------------------------------
-- Note: with only 2 sample enrollments, this returns zero rows -
-- the query is still structurally correct.

SELECT *
FROM Students
WHERE StudentID IN (
    SELECT StudentID FROM Enrollments
    WHERE CourseID IN (
        SELECT CourseID FROM Enrollments
        GROUP BY CourseID
        HAVING COUNT(StudentID) > 10
    )
);


-- ------------------------------------------------------------
-- 13. Extract the year from the EnrollmentDate of students
-- ------------------------------------------------------------

SELECT StudentID, FirstName, LastName, YEAR(EnrollmentDate) AS EnrollmentYear
FROM Students;


-- ------------------------------------------------------------
-- 14. Concatenate the instructor's first and last name
-- ------------------------------------------------------------

SELECT InstructorID, CONCAT(FirstName, ' ', LastName) AS FullName
FROM Instructors;


-- ------------------------------------------------------------
-- 15. Calculate the running total of students enrolled in courses
-- ------------------------------------------------------------

SELECT EnrollmentID, StudentID, CourseID, EnrollmentDate,
    COUNT(*) OVER (ORDER BY EnrollmentDate) AS running_total_students
FROM Enrollments;


-- ------------------------------------------------------------
-- 16. Label students as 'Senior' or 'Junior' based on year of
--     enrollment (Senior if enrollment date is more than 4 years
--     from the current date, otherwise Junior)
-- ------------------------------------------------------------

SELECT StudentID, FirstName, LastName, EnrollmentDate,
    CASE
        WHEN EnrollmentDate <= DATE_SUB(CURDATE(), INTERVAL 4 YEAR) THEN 'Senior'
        ELSE 'Junior'
    END AS StudentLabel
FROM Students;

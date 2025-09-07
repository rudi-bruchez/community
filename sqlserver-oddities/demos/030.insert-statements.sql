INSERT INTO dbo.complaint (
    complaint_id, attendee_id, attendee_name, attendee_email, 
    course_id, course_title, trainer_name, date, complaint_order, 
    complaint_type, complaint_details, severity_level, status, 
    resolution_notes, resolved_by, resolved_date, ip_address
) VALUES
(1, 101, 'Alice Martin', 'alice.martin@example.com', 201, 'SQL Basics', 'John Smith', '2025-07-01', 1, 1, 'Room too cold', 2, 'Open', NULL, NULL, NULL, '192.168.1.10'),
(2, 102, 'Bob Taylor', 'bob.taylor@example.com', 202, 'Advanced SQL', 'Maria Lopez', '2025-07-01', 2, 2, 'Projector not working', 3, 'Resolved', 'Replaced projector', 'SupportTeam', '2025-07-02', '192.168.1.11'),
(3, 103, 'Charlie Young', 'charlie.young@example.com', 203, 'Data Warehousing', 'Michael Chen', '2025-07-02', 1, 1, 'Coffee ran out', 1, 'Closed', 'Catering notified', 'Anna Lee', '2025-07-02', '192.168.1.12'),
(4, 104, 'Diana Evans', 'diana.evans@example.com', 204, 'Python for Data', 'Laura Becker', '2025-07-02', 2, 2, 'Instructor spoke too fast', 2, 'Open', NULL, NULL, NULL, '192.168.1.13'),
(5, 105, 'Ethan Clark', 'ethan.clark@example.com', 205, 'Machine Learning', 'John Smith', '2025-07-03', 1, 3, 'Slides not shared', 2, 'Pending', NULL, NULL, NULL, '192.168.1.14'),
(6, 106, 'Fiona Adams', 'fiona.adams@example.com', 201, 'SQL Basics', 'John Smith', '2025-07-03', 2, 1, 'Too noisy outside', 1, 'Closed', 'Changed room', 'AdminTeam', '2025-07-04', '192.168.1.15'),
(7, 107, 'George Harris', 'george.harris@example.com', 202, 'Advanced SQL', 'Maria Lopez', '2025-07-04', 1, 2, 'WiFi not working', 3, 'Resolved', 'Router reset', 'ITDesk', '2025-07-04', '192.168.1.16'),
(8, 108, 'Hannah Scott', 'hannah.scott@example.com', 203, 'Data Warehousing', 'Michael Chen', '2025-07-04', 2, 1, 'Session started late', 2, 'Open', NULL, NULL, NULL, '192.168.1.17'),
(9, 109, 'Ian Walker', 'ian.walker@example.com', 204, 'Python for Data', 'Laura Becker', '2025-07-05', 1, 3, 'Examples too basic', 2, 'Pending', NULL, NULL, NULL, '192.168.1.18'),
(10, 110, 'Julia Roberts', 'julia.roberts@example.com', 205, 'Machine Learning', 'John Smith', '2025-07-05', 2, 2, 'Room too small', 3, 'Closed', 'Bigger room allocated', 'AdminTeam', '2025-07-06', '192.168.1.19'),
(11, 111, 'Kevin Turner', 'kevin.turner@example.com', 201, 'SQL Basics', 'John Smith', '2025-07-06', 1, 1, 'Chairs uncomfortable', 1, 'Open', NULL, NULL, NULL, '192.168.1.20'),
(12, 112, 'Laura White', 'laura.white@example.com', 202, 'Advanced SQL', 'Maria Lopez', '2025-07-06', 2, 2, 'Air conditioning too cold', 2, 'Resolved', 'Adjusted temperature', 'SupportTeam', '2025-07-06', '192.168.1.21'),
(13, 113, 'Mike Brown', 'mike.brown@example.com', 203, 'Data Warehousing', 'Michael Chen', '2025-07-07', 1, 3, 'Handouts missing', 2, 'Pending', NULL, NULL, NULL, '192.168.1.22'),
(14, 114, 'Nina Lewis', 'nina.lewis@example.com', 204, 'Python for Data', 'Laura Becker', '2025-07-07', 2, 1, 'Instructor skipped exercises', 3, 'Open', NULL, NULL, NULL, '192.168.1.23'),
(15, 115, 'Oscar Hall', 'oscar.hall@example.com', 205, 'Machine Learning', 'John Smith', '2025-07-08', 1, 1, 'Not enough practice time', 2, 'Closed', 'Extended session', 'Trainer', '2025-07-09', '192.168.1.24'),
(16, 116, 'Paula King', 'paula.king@example.com', 201, 'SQL Basics', 'John Smith', '2025-07-08', 2, 2, 'Projectors flickered', 2, 'Resolved', 'Replaced cable', 'ITDesk', '2025-07-09', '192.168.1.25'),
(17, 117, 'Quentin Allen', 'quentin.allen@example.com', 202, 'Advanced SQL', 'Maria Lopez', '2025-07-09', 1, 3, 'Too many attendees', 3, 'Pending', NULL, NULL, NULL, '192.168.1.26'),
(18, 118, 'Rachel Moore', 'rachel.moore@example.com', 203, 'Data Warehousing', 'Michael Chen', '2025-07-09', 2, 2, 'Instructor difficult to understand', 3, 'Open', NULL, NULL, NULL, '192.168.1.27'),
(19, 119, 'Sam Wilson', 'sam.wilson@example.com', 204, 'Python for Data', 'Laura Becker', '2025-07-10', 1, 1, 'Breaks too short', 1, 'Closed', 'Breaks extended', 'AdminTeam', '2025-07-10', '192.168.1.28'),
(20, 120, 'Tina Green', 'tina.green@example.com', 205, 'Machine Learning', 'John Smith', '2025-07-10', 2, 3, 'Audio issues', 3, 'Resolved', 'Microphones replaced', 'SupportTeam', '2025-07-11', '192.168.1.29');
-- End of insert statements
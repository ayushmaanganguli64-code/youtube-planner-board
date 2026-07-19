DROP DATABASE IF EXISTS youtube_planner;
CREATE DATABASE youtube_planner;
USE youtube_planner;

CREATE TABLE video_projects (
    video_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('Idea', 'Scripting', 'Filming', 'Editing', 'Published') DEFAULT 'Idea',
    publish_date DATE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table to store script notes or outlines for individual videos
CREATE TABLE project_notes (
    note_id INT PRIMARY KEY AUTO_INCREMENT,
    video_id INT NOT NULL,
    note_text TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (video_id) REFERENCES video_projects(video_id) ON DELETE CASCADE
);

-- Table to log historical performance analytics for published videos
CREATE TABLE video_analytics (
    snapshot_id INT PRIMARY KEY AUTO_INCREMENT,
    video_id INT NOT NULL,
    log_date DATE NOT NULL,
    views INT DEFAULT 0,
    watch_time_hours DECIMAL(10, 2) DEFAULT 0.00,
    subscribers_gained INT DEFAULT 0,
    FOREIGN KEY (video_id) REFERENCES video_projects(video_id) ON DELETE CASCADE,
    CONSTRAINT unique_video_date UNIQUE (video_id, log_date) 
);

-- Insert sample video pipeline items
INSERT INTO video_projects (title, description, status, publish_date) VALUES 
('10 Time Management Hacks for Devs', 'A video breaking down Pomodoro, time-blocking, and IDE shortcuts.', 'Published', '2026-06-15'),
('Why I Switched from Python to Java', 'Comparing ecosystem, speed, and static typing benefits.', 'Published', '2026-06-20'),
('Building a Kanban Board from Scratch', 'Coding a vanilla JavaScript drag-and-drop board.', 'Editing', NULL),
('My Desk Setup Tour 2026', 'Showcasing minimalist coding setup and productivity gear.', 'Scripting', NULL),
('SQL Optimization Secrets', 'Deep dive into indexes, execution plans, and joins.', 'Idea', NULL);

-- Insert sample notes for the active production files
INSERT INTO project_notes (video_id, note_text) VALUES 
(3, 'Intro: Show the finished project first to hook the viewer.'),
(3, 'Section 1: Setup HTML grid container. Section 2: Write event listeners.'),
(4, 'Gear list: Mechanical keyboard, 4K monitor, and desk shelf link.');

-- Insert a history tracking analytics for the first video
INSERT INTO video_analytics (video_id, log_date, views, watch_time_hours, subscribers_gained) VALUES 
(1, '2026-06-16', 150, 12.50, 5),
(1, '2026-06-17', 420, 35.20, 14),
(1, '2026-06-18', 890, 78.10, 32);

-- Query to see your videos
SELECT * FROM video_projects;

-- CareerAssistClean - Run ENTIRE script (Ctrl+A, Execute)
CREATE DATABASE IF NOT EXISTS career_assist_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE career_assist_db;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS applications, recommendations, chat_history, skill_gaps, learning_paths, resume_score;
DROP TABLE IF EXISTS job_skills, user_skills, resumes, jobs, api_jobs, scraped_jobs, skill_resources, skills, users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('STUDENT','HR') NOT NULL DEFAULT 'STUDENT',
  phone VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE resume_score (
  score_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  score INT NOT NULL,
  analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_resume_score_user (user_id, analyzed_at)
);

CREATE TABLE resumes (
  resume_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  extracted_text TEXT,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE skills (
  skill_id INT AUTO_INCREMENT PRIMARY KEY,
  skill_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE user_skills (
  user_id INT NOT NULL,
  skill_id INT NOT NULL,
  PRIMARY KEY (user_id, skill_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);

CREATE TABLE jobs (
  job_id INT AUTO_INCREMENT PRIMARY KEY,
  hr_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  company VARCHAR(150) NOT NULL,
  location VARCHAR(150),
  description TEXT,
  requirements TEXT,
  salary_range VARCHAR(100),
  status ENUM('ACTIVE','CLOSED') DEFAULT 'ACTIVE',
  posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hr_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE job_skills (
  job_id INT NOT NULL, skill_id INT NOT NULL,
  PRIMARY KEY (job_id, skill_id),
  FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
  FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);

CREATE TABLE api_jobs (
  api_job_id INT AUTO_INCREMENT PRIMARY KEY,
  external_id VARCHAR(100), title VARCHAR(200) NOT NULL,
  company VARCHAR(150), location VARCHAR(150), description TEXT,
  skills TEXT, job_url VARCHAR(500), source VARCHAR(50) DEFAULT 'ADZUNA',
  fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE scraped_jobs (
  scraped_job_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL, company VARCHAR(150), location VARCHAR(150),
  skills TEXT, job_url VARCHAR(500), source_site VARCHAR(100),
  scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE applications (
  application_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, job_id INT, api_job_id INT, scraped_job_id INT,
  job_source ENUM('INTERNAL','API','SCRAPED') DEFAULT 'INTERNAL',
  status VARCHAR(20) NOT NULL DEFAULT 'APPLIED',
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE recommendations (
  recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, job_id INT, match_percentage DECIMAL(5,2),
  missing_skills TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE chat_history (
  chat_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, role ENUM('USER','ASSISTANT') NOT NULL,
  message TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE skill_gaps (
  gap_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, job_id INT, target_title VARCHAR(200),
  gap_percentage DECIMAL(5,2), required_skills TEXT,
  acquired_skills TEXT, missing_skills TEXT,
  analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE learning_paths (
  path_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, skill_name VARCHAR(100),
  level_stage VARCHAR(32) NOT NULL DEFAULT 'BEGINNER',
  title VARCHAR(200), resource_url VARCHAR(500), platform VARCHAR(50),
  practice_platforms VARCHAR(1500),
  sort_order INT DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE skill_resources (
  resource_id INT AUTO_INCREMENT PRIMARY KEY,
  skill_name VARCHAR(100), level_stage VARCHAR(20),
  title VARCHAR(200), resource_url VARCHAR(500), platform VARCHAR(50)
);

INSERT INTO skills (skill_name) VALUES
('Java'),('Python'),('JavaScript'),('SQL'),('Spring Boot'),('React'),('HTML'),('CSS'),
('Node.js'),('Git'),('Docker'),('AWS'),('REST API'),('MongoDB'),('Excel'),('Power BI'),
('CCNA'),('Networking'),('Routing'),('Switching'),('Linux');

INSERT INTO skill_resources (skill_name,level_stage,title,resource_url,platform) VALUES
('Java','BEGINNER','Java Programming Full Course','https://www.youtube.com/watch?v=eIrMbAQSU34','YouTube'),
('Java','INTERMEDIATE','Java OOP & Collections Playlist','https://www.youtube.com/playlist?list=PLQVdddLvB1DU3f27sQ82aUEqeODdAS0U','YouTube'),
('Java','ADVANCED','Spring Boot Full Course','https://www.youtube.com/watch?v=9SGDpanIA8g','YouTube'),
('Java','PROJECTS','Java Project-Based Tutorials','https://www.youtube.com/playlist?list=PLd3UqWTnYXOsJplFnUYQ9x4C5sCZtVj4','YouTube'),
('Python','BEGINNER','Python for Beginners Playlist','https://www.youtube.com/playlist?list=PL6gx4Cwl9DGAjkwJocd-hyXDzhiMoCQ48','YouTube'),
('Python','INTERMEDIATE','Official Python Tutorial','https://docs.python.org/3/tutorial/','Documentation'),
('Python','ADVANCED','Django Getting Started','https://docs.djangoproject.com/en/stable/intro/','Documentation'),
('Python','PROJECTS','Python Projects Playlist','https://www.youtube.com/playlist?list=PLryHKhjQyA3n6hErAxn0bH0DZQtj56J63','YouTube'),
('React','BEGINNER','React Official Learn','https://react.dev/learn','Documentation'),
('React','INTERMEDIATE','React Hooks Playlist','https://www.youtube.com/playlist?list=PL4cUxeIkcSxu9co_afYcnWumHrAQHiuG','YouTube'),
('React','ADVANCED','React Patterns & Performance','https://react.dev/learn/thinking-in-react','Documentation'),
('React','PROJECTS','React Portfolio Projects','https://www.frontendmentor.io/challenges?languages=javascript,html,css','Projects'),
('SQL','BEGINNER','SQL Tutorial (W3Schools)','https://www.w3schools.com/sql/','Documentation'),
('SQL','INTERMEDIATE','SQL Intermediate Playlist','https://www.youtube.com/playlist?list=PLHrAJOruV9zS4xNImaYZ7v9FWzT8q_n9','YouTube'),
('SQL','ADVANCED','PostgreSQL Tutorial','https://www.postgresql.org/docs/current/tutorial.html','Documentation'),
('SQL','PROJECTS','SQL Practice & Exercises','https://www.sql-practice.com/','Labs'),
('CCNA','BEGINNER','CCNA 200-301 Complete Course','https://www.youtube.com/playlist?list=PLxbMC_OWrlCdM1hXj7E8cwz7uD0n7L8gK','YouTube'),
('CCNA','INTERMEDIATE','Cisco Packet Tracer Labs','https://www.netacad.com/cisco-packet-tracer','Labs'),
('CCNA','ADVANCED','CCNA Exam Topics Guide','https://www.cisco.com/c/en/us/training-events/training-certifications/exams/exam-listings/ccna-200-301.html','Documentation'),
('CCNA','PROJECTS','Packet Tracer Practice Labs','https://www.packettracernetwork.com/labs/','Labs');

INSERT INTO users (full_name,email,password_hash,role,phone) VALUES
('HR Admin','hr@careerassist.com','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','HR','9999999999'),
('Demo Student','student@careerassist.com','ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f','STUDENT','8888888888');

INSERT INTO jobs (hr_id,title,company,location,description,requirements,salary_range) VALUES
(1,'Java Developer','TechCorp','Bangalore','Java enterprise apps','Java,Spring Boot,SQL','8-12 LPA'),
(1,'Full Stack Developer','WebSolutions','Hyderabad','Web apps','JavaScript,React,Node.js','10-15 LPA'),
(1,'Data Analyst','Analytics Pro','Mumbai','Data reports','SQL,Python,Excel','6-9 LPA'),
(1,'Network Engineer','NetCore','Pune','LAN/WAN and routing','CCNA,Networking,Routing,Switching,Linux','5-8 LPA');

INSERT INTO job_skills SELECT 1, skill_id FROM skills WHERE skill_name IN ('Java','Spring Boot','SQL');
INSERT INTO job_skills SELECT 2, skill_id FROM skills WHERE skill_name IN ('JavaScript','React','Node.js');
INSERT INTO job_skills SELECT 3, skill_id FROM skills WHERE skill_name IN ('SQL','Python','Excel');
INSERT INTO job_skills SELECT 4, skill_id FROM skills WHERE skill_name IN ('CCNA','Networking','Routing','Switching','Linux');

SHOW TABLES;

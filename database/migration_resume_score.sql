-- Run if career_assist_db already exists without resume_score table
USE career_assist_db;

CREATE TABLE IF NOT EXISTS resume_score (
  score_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  score INT NOT NULL,
  analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_resume_score_user (user_id, analyzed_at)
);application id 598fced0
appication key  6598583db968488dcf5642cbad6e9b3b
-- CareerAssist Migration: Multiple Resume Upload support
USE career_assist_db;

-- Add is_latest column if it doesn't exist
ALTER TABLE resumes ADD COLUMN IF NOT EXISTS is_latest TINYINT(1) DEFAULT 0;

-- Add file_type column if it doesn't exist
ALTER TABLE resumes ADD COLUMN IF NOT EXISTS file_type VARCHAR(100) DEFAULT NULL;

-- Mark the most recent resume for each user as the latest
UPDATE resumes r 
SET is_latest = 1 
WHERE r.resume_id = (
    SELECT MAX(r2.resume_id) 
    FROM (SELECT * FROM resumes) r2 
    WHERE r2.user_id = r.user_id
);

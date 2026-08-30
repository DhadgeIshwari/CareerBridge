-- Skill Practice Hub: extend learning_paths for READ + PRACTICE stages
USE career_assist_db;

ALTER TABLE learning_paths
  MODIFY COLUMN level_stage VARCHAR(32) NOT NULL DEFAULT 'BEGINNER';

ALTER TABLE learning_paths
  ADD COLUMN practice_platforms VARCHAR(1500) NULL AFTER platform;

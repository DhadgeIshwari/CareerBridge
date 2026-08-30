-- Application tracker statuses (run on existing DB)
USE career_assist_db;

ALTER TABLE applications MODIFY status VARCHAR(20) NOT NULL DEFAULT 'APPLIED';

UPDATE applications SET status = 'APPLIED' WHERE status = 'PENDING';
UPDATE applications SET status = 'INTERVIEW' WHERE status = 'SHORTLISTED';
UPDATE applications SET status = 'SELECTED' WHERE status = 'ACCEPTED';

package com.careerassist.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.careerassist.model.*;
import com.careerassist.util.DBUtil;
import com.careerassist.util.TimeAgoUtil;

public class CareerDAO {

    public User findUserByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        }
        return null;
    }

    public User findUserById(int id) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT * FROM users WHERE user_id=?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        }
        return null;
    }

    public boolean insertUser(User u) throws SQLException {
        String sql = "INSERT INTO users(full_name,email,password_hash,role,phone) VALUES(?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getFullName()); ps.setString(2, u.getEmail());
            ps.setString(3, u.getPasswordHash()); ps.setString(4, u.getRole()); ps.setString(5, u.getPhone());
            return ps.executeUpdate() > 0;
        }
    }

    public List<User> listStudents() throws SQLException {
        return listUsers("STUDENT");
    }

    public List<User> searchStudents(String skill) throws SQLException {
        String sql = "SELECT DISTINCT u.* FROM users u JOIN user_skills us ON u.user_id=us.user_id JOIN skills s ON us.skill_id=s.skill_id WHERE u.role='STUDENT' AND s.skill_name LIKE ?";
        List<User> list = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, "%" + skill + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapUser(rs));
        }
        return list;
    }

    private List<User> listUsers(String role) throws SQLException {
        List<User> list = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT * FROM users WHERE role=? ORDER BY full_name")) {
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapUser(rs));
        }
        return list;
    }

    public int countStudents() throws SQLException {
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM users WHERE role='STUDENT'")) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public void saveResume(int userId, String fileName, String path, String text, String fileType) throws SQLException {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                // Set all older resumes for this user as NOT latest
                try (PreparedStatement ps = c.prepareStatement("UPDATE resumes SET is_latest = 0 WHERE user_id = ?")) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }

                // Insert new resume as latest
                String sql = "INSERT INTO resumes(user_id,file_name,file_path,extracted_text,file_type,is_latest) VALUES(?,?,?,?,?,1)";
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, fileName);
                    ps.setString(3, path);
                    ps.setString(4, text);
                    ps.setString(5, fileType);
                    ps.executeUpdate();
                }
                c.commit();
            } catch (SQLException e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public List<Resume> listResumes(int userId) throws SQLException {
        List<Resume> list = new ArrayList<>();
        String sql = "SELECT * FROM resumes WHERE user_id = ? ORDER BY uploaded_at DESC";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Resume r = new Resume();
                    r.setResumeId(rs.getInt("resume_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setFileName(rs.getString("file_name"));
                    r.setFilePath(rs.getString("file_path"));
                    r.setExtractedText(rs.getString("extracted_text"));
                    r.setUploadedAt(rs.getTimestamp("uploaded_at"));
                    r.setLatest(rs.getInt("is_latest") == 1);
                    r.setFileType(rs.getString("file_type"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public Resume getResumeById(int resumeId, int userId) throws SQLException {
        String sql = "SELECT * FROM resumes WHERE resume_id = ? AND user_id = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, resumeId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Resume r = new Resume();
                    r.setResumeId(rs.getInt("resume_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setFileName(rs.getString("file_name"));
                    r.setFilePath(rs.getString("file_path"));
                    r.setExtractedText(rs.getString("extracted_text"));
                    r.setUploadedAt(rs.getTimestamp("uploaded_at"));
                    r.setLatest(rs.getInt("is_latest") == 1);
                    r.setFileType(rs.getString("file_type"));
                    return r;
                }
            }
        }
        return null;
    }

    public void deleteResume(int resumeId, int userId) throws SQLException {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                // Check if the resume being deleted is the latest one
                boolean wasLatest = false;
                try (PreparedStatement ps = c.prepareStatement("SELECT is_latest FROM resumes WHERE resume_id = ? AND user_id = ?")) {
                    ps.setInt(1, resumeId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            wasLatest = rs.getInt("is_latest") == 1;
                        }
                    }
                }

                // Delete the resume
                try (PreparedStatement ps = c.prepareStatement("DELETE FROM resumes WHERE resume_id = ? AND user_id = ?")) {
                    ps.setInt(1, resumeId);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }

                // If it was the latest, promote the next most recent resume (if any) to is_latest = 1
                if (wasLatest) {
                    try (PreparedStatement ps = c.prepareStatement(
                            "UPDATE resumes SET is_latest = 1 WHERE user_id = ? ORDER BY uploaded_at DESC LIMIT 1")) {
                        ps.setInt(1, userId);
                        ps.executeUpdate();
                    }
                }
                c.commit();
            } catch (SQLException e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public String getLatestResumeSummary(int userId, int maxChars) throws SQLException {
        String sql = "SELECT extracted_text FROM resumes WHERE user_id=? AND is_latest=1 ORDER BY uploaded_at DESC LIMIT 1";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) return null;
            String text = rs.getString(1);
            if (text == null || text.isBlank()) return null;
            String compact = text.replaceAll("\\s+", " ").trim();
            if (compact.length() <= maxChars) return compact;
            return compact.substring(0, maxChars).trim() + "…";
        }
    }

    public void clearUserSkills(int userId) throws SQLException {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM user_skills WHERE user_id=?")) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public void saveUserSkills(int userId, List<String> skills) throws SQLException {
        for (String sk : skills) {
            int sid = getOrCreateSkill(sk);
            try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("INSERT IGNORE INTO user_skills(user_id,skill_id) VALUES(?,?)")) {
                ps.setInt(1, userId); ps.setInt(2, sid); ps.executeUpdate();
            }
        }
    }

    public List<String> getUserSkills(int userId) throws SQLException {
        List<String> list = new ArrayList<>();
        String sql = "SELECT s.skill_name FROM skills s JOIN user_skills us ON s.skill_id=us.skill_id WHERE us.user_id=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(rs.getString(1));
        }
        return list;
    }

    private int getOrCreateSkill(String name) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT skill_id FROM skills WHERE skill_name=?")) {
            ps.setString(1, name);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("INSERT INTO skills(skill_name) VALUES(?)", Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.executeUpdate();
            ResultSet k = ps.getGeneratedKeys();
            if (k.next()) return k.getInt(1);
        }
        throw new SQLException("Skill create failed");
    }

    public List<Job> listActiveJobs() throws SQLException {
        List<Job> jobs = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery("SELECT * FROM jobs WHERE status='ACTIVE' ORDER BY posted_at DESC")) {
            while (rs.next()) { Job j = mapJob(rs); j.setSkills(getJobSkills(j.getJobId())); jobs.add(j); }
        }
        return jobs;
    }

    public List<Job> listHrJobs(int hrId) throws SQLException {
        List<Job> jobs = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT * FROM jobs WHERE hr_id=? ORDER BY posted_at DESC")) {
            ps.setInt(1, hrId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) { Job j = mapJob(rs); j.setSkills(getJobSkills(j.getJobId())); jobs.add(j); }
        }
        return jobs;
    }

    public Job getJob(int jobId) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT * FROM jobs WHERE job_id=?")) {
            ps.setInt(1, jobId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) { Job j = mapJob(rs); j.setSkills(getJobSkills(jobId)); return j; }
        }
        return null;
    }

    public int insertJob(Job j) throws SQLException {
        String sql = "INSERT INTO jobs(hr_id,title,company,location,description,requirements,salary_range,status,job_type,experience_level,application_deadline,domain) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, j.getHrId()); ps.setString(2, j.getTitle()); ps.setString(3, j.getCompany());
            ps.setString(4, j.getLocation()); ps.setString(5, j.getDescription()); ps.setString(6, j.getRequirements());
            ps.setString(7, j.getSalaryRange()); ps.setString(8, j.getStatus() != null ? j.getStatus() : "ACTIVE");
            ps.setString(9, j.getJobType()); ps.setString(10, j.getExperienceLevel()); ps.setString(11, j.getApplicationDeadline()); ps.setString(12, j.getDomain());
            ps.executeUpdate();
            ResultSet k = ps.getGeneratedKeys();
            if (k.next()) {
                int id = k.getInt(1);
                saveJobSkills(id, j.getSkills());
                return id;
            }
        }
        throw new SQLException("Job insert failed");
    }

    public void updateJob(Job j) throws SQLException {
        String sql = "UPDATE jobs SET title=?,company=?,location=?,description=?,requirements=?,salary_range=?,status=?,job_type=?,experience_level=?,application_deadline=?,domain=? WHERE job_id=? AND hr_id=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, j.getTitle()); ps.setString(2, j.getCompany()); ps.setString(3, j.getLocation());
            ps.setString(4, j.getDescription()); ps.setString(5, j.getRequirements()); ps.setString(6, j.getSalaryRange());
            ps.setString(7, j.getStatus()); ps.setString(8, j.getJobType()); ps.setString(9, j.getExperienceLevel()); ps.setString(10, j.getApplicationDeadline()); ps.setString(11, j.getDomain());
            ps.setInt(12, j.getJobId()); ps.setInt(13, j.getHrId());
            ps.executeUpdate();
            deleteJobSkills(j.getJobId());
            saveJobSkills(j.getJobId(), j.getSkills());
        }
    }

    public void deleteJob(int jobId, int hrId) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("DELETE FROM jobs WHERE job_id=? AND hr_id=?")) {
            ps.setInt(1, jobId); ps.setInt(2, hrId); ps.executeUpdate();
        }
    }

    private List<String> getJobSkills(int jobId) throws SQLException {
        List<String> list = new ArrayList<>();
        String sql = "SELECT s.skill_name FROM skills s JOIN job_skills js ON s.skill_id=js.skill_id WHERE js.job_id=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, jobId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(rs.getString(1));
        }
        return list;
    }

    private void saveJobSkills(int jobId, List<String> skills) throws SQLException {
        if (skills == null) return;
        for (String sk : skills) {
            try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("INSERT INTO job_skills(job_id,skill_id) VALUES(?,?)")) {
                ps.setInt(1, jobId); ps.setInt(2, getOrCreateSkill(sk)); ps.executeUpdate();
            }
        }
    }

    private void deleteJobSkills(int jobId) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("DELETE FROM job_skills WHERE job_id=?")) {
            ps.setInt(1, jobId); ps.executeUpdate();
        }
    }

    public void saveSkillGap(SkillGap g) throws SQLException {
        String sql = "INSERT INTO skill_gaps(user_id,job_id,target_title,gap_percentage,required_skills,acquired_skills,missing_skills) VALUES(?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, g.getUserId());
            if (g.getJobId() != null) ps.setInt(2, g.getJobId()); else ps.setNull(2, Types.INTEGER);
            ps.setString(3, g.getTargetTitle()); ps.setDouble(4, g.getGapPercentage());
            ps.setString(5, g.getRequiredSkills()); ps.setString(6, g.getAcquiredSkills()); ps.setString(7, g.getMissingSkills());
            ps.executeUpdate();
        }
    }

    public SkillGap getLatestGap(int userId) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT * FROM skill_gaps WHERE user_id=? ORDER BY analyzed_at DESC LIMIT 1")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapGap(rs);
        }
        return null;
    }

    public void saveResumeScore(int userId, int score) throws SQLException {
        String sql = "INSERT INTO resume_score(user_id, score) VALUES(?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, score);
            ps.executeUpdate();
        }
    }

    public ResumeScore getLatestResumeScore(int userId) throws SQLException {
        String sql = "SELECT user_id, score, analyzed_at FROM resume_score WHERE user_id=? ORDER BY analyzed_at DESC LIMIT 1";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ResumeScore s = new ResumeScore();
                s.setUserId(rs.getInt("user_id"));
                s.setScore(rs.getInt("score"));
                Timestamp t = rs.getTimestamp("analyzed_at");
                s.setAnalyzedAt(t != null ? t.toString() : "");
                return s;
            }
        }
        return null;
    }

    public void clearRecommendations(int userId) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("DELETE FROM recommendations WHERE user_id=?")) {
            ps.setInt(1, userId); ps.executeUpdate();
        }
    }

    public void saveRecommendation(int userId, int jobId, double pct, String missing) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("INSERT INTO recommendations(user_id,job_id,match_percentage,missing_skills) VALUES(?,?,?,?)")) {
            ps.setInt(1, userId); ps.setInt(2, jobId); ps.setDouble(3, pct); ps.setString(4, missing); ps.executeUpdate();
        }
    }

    public void apply(Application a) throws SQLException {
        String status = a.getStatus() != null && !a.getStatus().isBlank() ? a.getStatus() : "APPLIED";
        String sql = "INSERT INTO applications(user_id,job_id,api_job_id,scraped_job_id,job_source,status) VALUES(?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, a.getUserId());
            setIntOrNull(ps, 2, a.getJobId()); setIntOrNull(ps, 3, a.getApiJobId()); setIntOrNull(ps, 4, a.getScrapedJobId());
            ps.setString(5, a.getJobSource()); ps.setString(6, status); ps.executeUpdate();
        }
    }

    public void updateApplicationStatus(int appId, int userId, String status) throws SQLException {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE applications SET status=? WHERE application_id=? AND user_id=?")) {
            ps.setString(1, status);
            ps.setInt(2, appId);
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    public Set<String> listAppliedJobKeys(int userId) throws SQLException {
        Set<String> keys = new HashSet<>();
        String sql = "SELECT job_source, job_id, api_job_id, scraped_job_id FROM applications WHERE user_id=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String src = rs.getString("job_source");
                int j = rs.getInt("job_id");
                if (!rs.wasNull()) keys.add(src + ":" + j);
                int aj = rs.getInt("api_job_id");
                if (!rs.wasNull()) keys.add(src + ":" + aj);
                int sj = rs.getInt("scraped_job_id");
                if (!rs.wasNull()) keys.add(src + ":" + sj);
            }
        }
        return keys;
    }

    public List<Application> listApplications(int userId) throws SQLException {
        return listApps("WHERE a.user_id=" + userId);
    }

    public List<Application> listAllApplications() throws SQLException {
        return listApps("");
    }

    private List<Application> listApps(String where) throws SQLException {
        List<Application> list = new ArrayList<>();
        String sql = "SELECT a.*,u.full_name student_name,COALESCE(j.title,aj.title,sj.title) job_title,COALESCE(j.company,aj.company,sj.company) company FROM applications a JOIN users u ON a.user_id=u.user_id LEFT JOIN jobs j ON a.job_id=j.job_id LEFT JOIN api_jobs aj ON a.api_job_id=aj.api_job_id LEFT JOIN scraped_jobs sj ON a.scraped_job_id=sj.scraped_job_id " + where + " ORDER BY a.applied_at DESC";
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery(sql)) {
            while (rs.next()) list.add(mapApp(rs));
        }
        return list;
    }

    public void updateAppStatus(int appId, String status) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("UPDATE applications SET status=? WHERE application_id=?")) {
            ps.setString(1, status); ps.setInt(2, appId); ps.executeUpdate();
        }
    }

    public void saveChat(int userId, String role, String msg) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("INSERT INTO chat_history(user_id,role,message) VALUES(?,?,?)")) {
            ps.setInt(1, userId); ps.setString(2, role); ps.setString(3, msg); ps.executeUpdate();
        }
    }

    public List<ChatMsg> listChat(int userId) throws SQLException {
        List<ChatMsg> list = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT role,message FROM chat_history WHERE user_id=? ORDER BY created_at")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(new ChatMsg(rs.getString(1), rs.getString(2)));
        }
        return list;
    }

    public void clearLearningPaths(int userId) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("DELETE FROM learning_paths WHERE user_id=?")) {
            ps.setInt(1, userId); ps.executeUpdate();
        }
    }

    public void saveLearningPath(int userId, LearningItem item, int order) throws SQLException {
        saveLearningPath(userId, item, order, null);
    }

    public void saveLearningPath(int userId, LearningItem item, int order, String practicePlatforms) throws SQLException {
        String sql = "INSERT INTO learning_paths(user_id,skill_name,level_stage,title,resource_url,platform,practice_platforms,sort_order) VALUES(?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, item.getSkillName());
            ps.setString(3, item.getLevelStage());
            ps.setString(4, item.getTitle());
            ps.setString(5, item.getResourceUrl());
            ps.setString(6, item.getPlatform());
            ps.setString(7, practicePlatforms);
            ps.setInt(8, order);
            ps.executeUpdate();
        } catch (SQLException ex) {
            if (isUnknownColumn(ex, "practice_platforms")) {
                try (Connection c = DBUtil.getConnection();
                     PreparedStatement ps = c.prepareStatement(
                             "INSERT INTO learning_paths(user_id,skill_name,level_stage,title,resource_url,platform,sort_order) VALUES(?,?,?,?,?,?,?)")) {
                    ps.setInt(1, userId);
                    ps.setString(2, item.getSkillName());
                    ps.setString(3, item.getLevelStage());
                    ps.setString(4, item.getTitle());
                    ps.setString(5, item.getResourceUrl());
                    ps.setString(6, item.getPlatform());
                    ps.setInt(7, order);
                    ps.executeUpdate();
                }
            } else {
                throw ex;
            }
        }
    }

    public List<LearningItem> listLearningPaths(int userId) throws SQLException {
        List<LearningItem> list = new ArrayList<>();
        String sql = "SELECT skill_name,level_stage,title,resource_url,platform,practice_platforms FROM learning_paths WHERE user_id=? ORDER BY skill_name,sort_order";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                LearningItem li = new LearningItem();
                li.setSkillName(rs.getString(1));
                li.setLevelStage(rs.getString(2));
                li.setTitle(rs.getString(3));
                li.setResourceUrl(rs.getString(4));
                li.setPlatform(rs.getString(5));
                li.setPracticePlatforms(rs.getString(6));
                list.add(li);
            }
        } catch (SQLException ex) {
            if (isUnknownColumn(ex, "practice_platforms")) {
                try (Connection c = DBUtil.getConnection();
                     PreparedStatement ps = c.prepareStatement(
                             "SELECT skill_name,level_stage,title,resource_url,platform FROM learning_paths WHERE user_id=? ORDER BY skill_name,sort_order")) {
                    ps.setInt(1, userId);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        LearningItem li = new LearningItem();
                        li.setSkillName(rs.getString(1));
                        li.setLevelStage(rs.getString(2));
                        li.setTitle(rs.getString(3));
                        li.setResourceUrl(rs.getString(4));
                        li.setPlatform(rs.getString(5));
                        list.add(li);
                    }
                }
            } else {
                throw ex;
            }
        }
        return list;
    }

    private static boolean isUnknownColumn(SQLException ex, String column) {
        String msg = ex.getMessage();
        return msg != null && msg.toLowerCase().contains("unknown column") && msg.toLowerCase().contains(column.toLowerCase());
    }

    public List<LearningItem> listResourcesForSkill(String skill) throws SQLException {
        List<LearningItem> list = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT skill_name,level_stage,title,resource_url,platform FROM skill_resources WHERE skill_name LIKE ?")) {
            ps.setString(1, "%" + skill + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                LearningItem li = new LearningItem();
                li.setSkillName(rs.getString(1)); li.setLevelStage(rs.getString(2)); li.setTitle(rs.getString(3));
                li.setResourceUrl(rs.getString(4)); li.setPlatform(rs.getString(5));
                list.add(li);
            }
        }
        return list;
    }

    public List<ExtJob> listApiJobs() throws SQLException {
        List<ExtJob> list = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery("SELECT * FROM api_jobs ORDER BY fetched_at DESC LIMIT 30")) {
            while (rs.next()) list.add(mapExt(rs, "api"));
        }
        return list;
    }

    public ExtJob getApiJob(int apiJobId) throws SQLException {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM api_jobs WHERE api_job_id=?")) {
            ps.setInt(1, apiJobId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapExt(rs, "api");
        }
        return null;
    }

    public ExtJob getScrapedJob(int scrapedJobId) throws SQLException {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM scraped_jobs WHERE scraped_job_id=?")) {
            ps.setInt(1, scrapedJobId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapExt(rs, "scraped");
        }
        return null;
    }

    public boolean hasApplied(int userId, String feedType, int refId) throws SQLException {
        return listAppliedJobKeys(userId).contains(feedType + ":" + refId);
    }

    public int upsertApiJob(ExtJob j) throws SQLException {
        if (j.getExternalId() != null && apiJobExists(j.getExternalId())) return 0;
        String sql = "INSERT INTO api_jobs(external_id,title,company,location,description,skills,job_url,source) VALUES(?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, j.getExternalId());
            ps.setString(2, j.getTitle());
            ps.setString(3, j.getCompany());
            ps.setString(4, j.getLocation());
            ps.setString(5, j.getDescription() != null ? j.getDescription() : "");
            ps.setString(6, j.getSkills());
            ps.setString(7, j.getUrl());
            ps.setString(8, j.getSource() != null ? j.getSource() : "ADZUNA");
            ps.executeUpdate();
            ResultSet k = ps.getGeneratedKeys();
            if (k.next()) return k.getInt(1);
        }
        return 0;
    }

    public boolean apiJobExists(String externalId) throws SQLException {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT 1 FROM api_jobs WHERE external_id=? LIMIT 1")) {
            ps.setString(1, externalId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }

    public int saveApiJob(ExtJob j) throws SQLException {
        return upsertApiJob(j);
    }

    public List<ExtJob> listScrapedJobs() throws SQLException {
        List<ExtJob> list = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery("SELECT * FROM scraped_jobs ORDER BY scraped_at DESC LIMIT 30")) {
            while (rs.next()) list.add(mapExt(rs, "scraped"));
        }
        return list;
    }

    public int upsertScrapedJob(ExtJob j) throws SQLException {
        if (j.getExternalId() != null && scrapedJobExists(j.getTitle(), j.getCompany())) return 0;
        String sql = "INSERT INTO scraped_jobs(title,company,location,skills,job_url,source_site) VALUES(?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, j.getTitle());
            ps.setString(2, j.getCompany());
            ps.setString(3, j.getLocation());
            ps.setString(4, j.getSkills());
            ps.setString(5, j.getUrl());
            ps.setString(6, j.getSource() != null ? j.getSource() : "SCRAPED");
            ps.executeUpdate();
            ResultSet k = ps.getGeneratedKeys();
            if (k.next()) return k.getInt(1);
        }
        return 0;
    }

    public boolean scrapedJobExists(String title, String company) throws SQLException {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT 1 FROM scraped_jobs WHERE title=? AND company=? LIMIT 1")) {
            ps.setString(1, title);
            ps.setString(2, company);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }

    public int saveScrapedJob(ExtJob j) throws SQLException {
        return upsertScrapedJob(j);
    }

    public int countJobs() throws SQLException {
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM jobs")) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countApplications() throws SQLException {
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM applications")) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countPendingApps() throws SQLException {
        try (Connection c = DBUtil.getConnection();
             ResultSet rs = c.createStatement().executeQuery(
                     "SELECT COUNT(*) FROM applications WHERE status IN ('PENDING','APPLIED')")) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countShortlisted() throws SQLException {
        try (Connection c = DBUtil.getConnection();
             ResultSet rs = c.createStatement().executeQuery(
                     "SELECT COUNT(*) FROM applications WHERE status IN ('SELECTED','INTERVIEW')")) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public List<User> listStudentsWithSkills() throws SQLException {
        return listStudents();
    }

    public String getStudentSkillsSummary(int userId) throws SQLException {
        List<String> skills = getUserSkills(userId);
        return skills.isEmpty() ? "No skills extracted" : String.join(", ", skills);
    }

    public Integer getStudentAtsScore(int userId) throws SQLException {
        ResumeScore rs = getLatestResumeScore(userId);
        return rs != null ? rs.getScore() : null;
    }

    private void setIntOrNull(PreparedStatement ps, int idx, Integer val) throws SQLException {
        if (val == null) ps.setNull(idx, Types.INTEGER); else ps.setInt(idx, val);
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id")); u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email")); u.setPasswordHash(rs.getString("password_hash"));
        u.setRole(rs.getString("role")); u.setPhone(rs.getString("phone"));
        return u;
    }

    private Job mapJob(ResultSet rs) throws SQLException {
        Job j = new Job();
        j.setJobId(rs.getInt("job_id")); j.setHrId(rs.getInt("hr_id"));
        j.setTitle(rs.getString("title")); j.setCompany(rs.getString("company"));
        j.setLocation(rs.getString("location")); j.setDescription(rs.getString("description"));
        j.setRequirements(rs.getString("requirements"));        j.setSalaryRange(rs.getString("salary_range"));
        j.setStatus(rs.getString("status"));
        j.setPostedAt(rs.getTimestamp("posted_at"));
        
        try { j.setJobType(rs.getString("job_type")); } catch (Exception ignore) {}
        try { j.setExperienceLevel(rs.getString("experience_level")); } catch (Exception ignore) {}
        try { j.setApplicationDeadline(rs.getString("application_deadline")); } catch (Exception ignore) {}
        try { j.setDomain(rs.getString("domain")); } catch (Exception ignore) {}
        
        return j;
    }

    private SkillGap mapGap(ResultSet rs) throws SQLException {
        SkillGap g = new SkillGap();
        g.setGapId(rs.getInt("gap_id")); g.setUserId(rs.getInt("user_id"));
        int jid = rs.getInt("job_id"); g.setJobId(rs.wasNull() ? null : jid);
        g.setTargetTitle(rs.getString("target_title")); g.setGapPercentage(rs.getDouble("gap_percentage"));
        g.setRequiredSkills(rs.getString("required_skills")); g.setAcquiredSkills(rs.getString("acquired_skills"));
        g.setMissingSkills(rs.getString("missing_skills"));
        return g;
    }

    private Application mapApp(ResultSet rs) throws SQLException {
        Application a = new Application();
        a.setApplicationId(rs.getInt("application_id")); a.setUserId(rs.getInt("user_id"));
        int j = rs.getInt("job_id"); a.setJobId(rs.wasNull() ? null : j);
        int aj = rs.getInt("api_job_id"); a.setApiJobId(rs.wasNull() ? null : aj);
        int sj = rs.getInt("scraped_job_id"); a.setScrapedJobId(rs.wasNull() ? null : sj);
        a.setJobSource(rs.getString("job_source")); a.setStatus(rs.getString("status"));
        a.setStudentName(rs.getString("student_name")); a.setJobTitle(rs.getString("job_title"));
        a.setCompany(rs.getString("company"));
        Timestamp t = rs.getTimestamp("applied_at");
        a.setAppliedAt(t != null ? t.toString() : "");
        return a;
    }

    private ExtJob mapExt(ResultSet rs, String type) throws SQLException {
        ExtJob e = new ExtJob();
        Timestamp posted;
        if ("api".equals(type)) {
            e.setId(rs.getInt("api_job_id"));
            e.setExternalId(rs.getString("external_id"));
            e.setTitle(rs.getString("title"));
            e.setCompany(rs.getString("company"));
            e.setLocation(rs.getString("location"));
            e.setSkills(rs.getString("skills"));
            e.setDescription(rs.getString("description"));
            e.setUrl(rs.getString("job_url"));
            e.setSource(rs.getString("source"));
            posted = rs.getTimestamp("fetched_at");
        } else {
            e.setId(rs.getInt("scraped_job_id"));
            e.setTitle(rs.getString("title"));
            e.setCompany(rs.getString("company"));
            e.setLocation(rs.getString("location"));
            e.setSkills(rs.getString("skills"));
            e.setUrl(rs.getString("job_url"));
            e.setSource(rs.getString("source_site"));
            posted = rs.getTimestamp("scraped_at");
        }
        e.setPostedLabel(TimeAgoUtil.formatPosted(posted));
        return e;
    }

    public int countActiveJobs() throws SQLException {
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM jobs WHERE status='ACTIVE'")) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countActiveHrJobs(int hrId) throws SQLException {
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM jobs WHERE status='ACTIVE' AND hr_id=?")) {
            ps.setInt(1, hrId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public Double getAverageAtsScore() throws SQLException {
        try (Connection c = DBUtil.getConnection(); ResultSet rs = c.createStatement().executeQuery("SELECT AVG(score) FROM resume_score")) {
            return rs.next() ? (rs.wasNull() ? null : rs.getDouble(1)) : null;
        }
    }

    public List<java.util.Map<String, Object>> getRecentCandidates(int limit) throws SQLException {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.email, r.file_name, r.uploaded_at " +
                     "FROM users u " +
                     "JOIN resumes r ON u.user_id = r.user_id " +
                     "WHERE u.role='STUDENT' AND r.is_latest = 1 " +
                     "ORDER BY r.uploaded_at DESC LIMIT ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("userId", rs.getInt("user_id"));
                map.put("fullName", rs.getString("full_name"));
                map.put("email", rs.getString("email"));
                map.put("fileName", rs.getString("file_name"));
                map.put("uploadedAt", rs.getTimestamp("uploaded_at"));
                list.add(map);
            }
        }
        return list;
    }

    public List<Job> getRecentJobs(int limit) throws SQLException {
        List<Job> jobs = new ArrayList<>();
        String sql = "SELECT * FROM jobs ORDER BY posted_at DESC LIMIT ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                jobs.add(mapJob(rs));
            }
        }
        return jobs;
    }
}

package com.careerassist.service;

import java.io.File;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.careerassist.dao.CareerDAO;
import com.careerassist.model.Application;
import com.careerassist.model.ApplyPreview;
import com.careerassist.model.CareerContext;
import com.careerassist.model.CareerRefreshResult;
import com.careerassist.model.ChatResponse;
import com.careerassist.model.Job;
import com.careerassist.model.JobFeedItem;
import com.careerassist.model.ResumeScore;
import com.careerassist.model.JobDomain;
import com.careerassist.model.ExtJob;
import com.careerassist.model.LearningItem;
import com.careerassist.model.PracticeLink;
import com.careerassist.model.SkillGap;
import com.careerassist.model.SkillLearningHub;
import com.careerassist.model.User;
import com.careerassist.util.AppUtil;
import com.careerassist.util.AppUtil.AtsScoreResult;
import com.careerassist.util.JobRelevanceEngine;
import com.careerassist.util.LearningResourceCatalog;
import com.careerassist.util.PracticePlatformCatalog;
import com.careerassist.util.PdfUtil;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

public class CareerService {

    private final CareerDAO dao = new CareerDAO();
    private final JobFeedService jobFeedService = new JobFeedService();
    private final CareerContextService contextService = new CareerContextService();
    private final CareerAIService aiService = new CareerAIService();

    public CareerContextService getContextService() { return contextService; }

    public String validateRegistration(User u, String pass, String confirm) {
        if (u.getFullName() == null || u.getFullName().isBlank()) return "Name required";
        
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        if (u.getEmail() == null || !u.getEmail().matches(emailRegex)) {
            return "Please enter a valid email address";
        }
        
        String passRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$";
        if (pass == null || !pass.matches(passRegex)) {
            return "Password must be at least 8 characters, with 1 uppercase, 1 lowercase, 1 number, and 1 special character.";
        }
        
        if (!pass.equals(confirm)) return "Passwords mismatch";
        if (u.getRole() == null || (!"STUDENT".equals(u.getRole()) && !"HR".equals(u.getRole()))) {
            return "Invalid account type. Choose Student or HR.";
        }
        
        try {
            if (dao.findUserByEmail(u.getEmail()) != null) return "Email exists";
        } catch (Exception e) {
            return e.getMessage();
        }
        return null;
    }

    public String register(User u, String pass, String confirm) {
        String err = validateRegistration(u, pass, confirm);
        if (err != null) return err;

        try {
            u.setPasswordHash(AppUtil.hashPassword(pass));
            dao.insertUser(u);
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public User login(String email, String pass, String role) {
        try {
            if (loginWithMessage(email, pass, role) != null) return null;
            return dao.findUserByEmail(email.trim());
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Validates credentials and that users.role matches the selected portal (STUDENT or HR).
     * @return null on success, otherwise an error message for the UI
     */
    public String loginWithMessage(String email, String pass, String role) {
        if (email == null || email.isBlank()) return "Email is required.";
        if (pass == null || pass.isBlank()) return "Password is required.";
        if (role == null || (!"STUDENT".equals(role) && !"HR".equals(role))) {
            return "Invalid portal. Choose Student or HR login.";
        }
        try {
            User u = dao.findUserByEmail(email.trim());
            if (u == null || !AppUtil.checkPassword(pass, u.getPasswordHash())) {
                return "Invalid email or password.";
            }
            if (!role.equals(u.getRole())) {
                if ("HR".equals(role)) {
                    return "This account is not registered as HR. Use the Student login portal.";
                }
                return "This account is registered as HR. Please use the HR login portal.";
            }
            return null;
        } catch (Exception e) {
            return "Login failed. Please try again.";
        }
    }

    // ===================== FIXED METHOD =====================
    public String uploadResume(int userId, Part part, String basePath) {

        if (part == null || part.getSize() == 0) return "No file";

        String name = part.getSubmittedFileName();
        if (name == null) return "Invalid file name";

        String low = name.toLowerCase();
        if (!low.endsWith(".pdf") && !low.endsWith(".txt"))
            return "Upload PDF or TXT resume only";

        try {
            File dir = new File(basePath, "uploads");
            dir.mkdirs();

            String ext = low.endsWith(".txt") ? ".txt" : ".pdf";
            File f = new File(dir, userId + "_" + System.currentTimeMillis() + ext);
            part.write(f.getAbsolutePath());

            String text = PdfUtil.extractText(f);
            if (text == null || text.isBlank()) {
                return "Could not extract text from resume";
            }

            List<String> skills = AppUtil.normalizeSkills(AppUtil.extractSkills(text));
            String fileType = part.getContentType();

            dao.saveResume(userId, name, f.getAbsolutePath(), text, fileType);
            dao.clearUserSkills(userId);
            dao.saveUserSkills(userId, skills);
            calculateAndSaveResumeScore(userId);
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public List<com.careerassist.model.Resume> getResumeHistory(int userId) {
        try {
            return dao.listResumes(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public String deleteResume(int resumeId, int userId) {
        try {
            dao.deleteResume(resumeId, userId);
            List<com.careerassist.model.Resume> remaining = dao.listResumes(userId);
            if (!remaining.isEmpty()) {
                // There are still resumes left; promote the new latest one's skills
                com.careerassist.model.Resume newLatest = remaining.get(0);
                List<String> skills = AppUtil.normalizeSkills(AppUtil.extractSkills(newLatest.getExtractedText()));
                dao.clearUserSkills(userId);
                dao.saveUserSkills(userId, skills);
                calculateAndSaveResumeScore(userId);
            } else {
                // No resumes left at all, clear user skills and set resume score to 0
                dao.clearUserSkills(userId);
                dao.saveResumeScore(userId, 0);
            }
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public SkillGap analyzeGap(int userId, int jobId) throws Exception {
        Job job = dao.getJob(jobId);
        if (job == null) return null;

        List<String> userSkills = dao.getUserSkills(userId);
        List<String> req = job.getSkills().isEmpty()
                ? AppUtil.parseList(job.getRequirements())
                : job.getSkills();

        return buildGap(userId, jobId, job.getTitle(), userSkills, req);
    }

    public SkillGap analyzeGapCustom(int userId, String title, String reqCsv) throws Exception {
        return buildGap(userId, null, title, dao.getUserSkills(userId), AppUtil.parseList(reqCsv));
    }

    private SkillGap buildGap(int userId, Integer jobId, String title,
                              List<String> user, List<String> req) throws Exception {

        double match = AppUtil.matchPercent(user, req);
        List<String> miss = AppUtil.missing(user, req);

        List<String> acq = new ArrayList<>();
        for (String r : req)
            if (!miss.contains(r)) acq.add(r);

        SkillGap g = new SkillGap();
        g.setUserId(userId);
        g.setJobId(jobId);
        g.setTargetTitle(title);
        g.setGapPercentage(100 - match);
        g.setRequiredSkills(String.join(", ", req));
        g.setAcquiredSkills(String.join(", ", acq));
        g.setMissingSkills(String.join(", ", miss));

        dao.saveSkillGap(g);
        calculateAndSaveResumeScore(userId);
        return g;
    }

    /**
     * Computes ATS score (0–100) from matched/missing skills and job relevance, persists to resume_score.
     */
    public ResumeScore calculateAndSaveResumeScore(int userId) throws Exception {
        List<String> skills = dao.getUserSkills(userId);
        SkillGap gap = dao.getLatestGap(userId);
        double bestJobMatch = computeBestJobMatchPct(userId);

        AtsScoreResult result = AppUtil.calculateAtsScore(skills, gap, bestJobMatch);
        dao.saveResumeScore(userId, result.score);

        ResumeScore stored = dao.getLatestResumeScore(userId);
        if (stored != null) {
            stored.setMatchedPoints(result.matchedPoints);
            stored.setMissingPoints(result.missingPoints);
            stored.setJobRelevancePoints(result.jobRelevancePoints);
            stored.setMatchedSkillCount(result.matchedSkillCount);
            stored.setMissingSkillCount(result.missingSkillCount);
        }
        return stored;
    }

    public ResumeScore getResumeScore(int userId) throws Exception {
        ResumeScore stored = dao.getLatestResumeScore(userId);
        if (stored == null) return null;

        List<String> skills = dao.getUserSkills(userId);
        SkillGap gap = dao.getLatestGap(userId);
        double bestJobMatch = computeBestJobMatchPct(userId);
        AtsScoreResult result = AppUtil.calculateAtsScore(skills, gap, bestJobMatch);

        stored.setMatchedPoints(result.matchedPoints);
        stored.setMissingPoints(result.missingPoints);
        stored.setJobRelevancePoints(result.jobRelevancePoints);
        stored.setMatchedSkillCount(result.matchedSkillCount);
        stored.setMissingSkillCount(result.missingSkillCount);
        return stored;
    }

    /** Best domain-filtered job match % without writing recommendations. */
    public double computeBestJobMatchPct(int userId) throws Exception {
        List<String> userSkills = dao.getUserSkills(userId);
        JobDomain userDomain = AppUtil.detectUserDomain(userSkills);
        double best = 0;

        for (Job j : dao.listActiveJobs()) {
            List<String> req = j.getSkills().isEmpty()
                    ? AppUtil.parseList(j.getRequirements())
                    : j.getSkills();
            if (!JobRelevanceEngine.passesFilter(userSkills, req, j.getTitle(), j.getDescription(), userDomain)) {
                continue;
            }
            best = Math.max(best, AppUtil.matchPercent(userSkills, req));
        }
        for (JobFeedItem item : jobFeedService.buildLiveFeed(userId, userSkills)) {
            best = Math.max(best, item.getMatchPct());
        }
        return best;
    }

    /** Auto skill-gap for highest-scoring relevant job (internal or external). */
    public SkillGap analyzeGapForBestJob(int userId) throws Exception {
        List<String> userSkills = dao.getUserSkills(userId);
        if (userSkills.isEmpty()) return null;

        JobDomain userDomain = AppUtil.detectUserDomain(userSkills);
        List<JobRelevanceEngine.ScoredJob> candidates = new ArrayList<>();

        for (Job j : dao.listActiveJobs()) {
            List<String> req = j.getSkills().isEmpty()
                    ? AppUtil.parseList(j.getRequirements()) : j.getSkills();
            double pct = AppUtil.matchPercent(userSkills, req);
            candidates.add(new JobRelevanceEngine.ScoredJob(
                    "INTERNAL", j.getJobId(), j.getTitle(), req, pct,
                    AppUtil.classifyJobDomain(j.getTitle(), j.getDescription(), req)));
        }
        for (ExtJob e : dao.listApiJobs()) {
            List<String> req = JobRelevanceEngine.jobSkillsOrExtract(e.getSkills(), e.getTitle(), e.getDescription());
            candidates.add(new JobRelevanceEngine.ScoredJob(
                    "API", e.getId(), e.getTitle(), req,
                    AppUtil.matchPercent(userSkills, req),
                    AppUtil.classifyJobDomain(e.getTitle(), e.getDescription(), req)));
        }
        for (ExtJob e : dao.listScrapedJobs()) {
            List<String> req = JobRelevanceEngine.jobSkillsOrExtract(e.getSkills(), e.getTitle(), e.getDescription());
            candidates.add(new JobRelevanceEngine.ScoredJob(
                    "SCRAPED", e.getId(), e.getTitle(), req,
                    AppUtil.matchPercent(userSkills, req),
                    AppUtil.classifyJobDomain(e.getTitle(), e.getDescription(), req)));
        }

        JobRelevanceEngine.ScoredJob best = JobRelevanceEngine.findBestMatch(userSkills, userDomain, candidates);
        if (best == null) return null;

        Integer jobId = "INTERNAL".equals(best.feedType()) ? best.refId() : null;
        return buildGap(userId, jobId, best.title(), userSkills, best.jobSkills());
    }

    public void ensureAutoSkillGap(int userId) throws Exception {
        if (dao.getLatestGap(userId) == null) {
            analyzeGapForBestJob(userId);
        }
    }

    public List<Job> recommendJobs(int userId) throws Exception {
        return recommendJobs(userId, null);
    }

    private List<Job> getHigherLevelJobs(JobDomain domain, String targetTitle) {
        List<Job> jobs = new ArrayList<>();
        
        Job j1 = new Job();
        j1.setJobId(-101);
        j1.setCompany("Enterprise Solutions");
        j1.setLocation("Remote / Bangalore");
        j1.setSalaryRange("18-25 LPA");
        j1.setStatus("ACTIVE");
        
        Job j2 = new Job();
        j2.setJobId(-102);
        j2.setCompany("ScaleUp Systems");
        j2.setLocation("Hybrid / Mumbai");
        j2.setSalaryRange("22-30 LPA");
        j2.setStatus("ACTIVE");

        switch (domain) {
            case FRONTEND -> {
                j1.setTitle("Senior Frontend Engineer (React/TypeScript)");
                j1.setDescription("Lead frontend development of our core enterprise products. Architect scalable component libraries and optimize web performance.");
                j1.setRequirements("JavaScript, React, HTML, CSS, Git, System Design, Webpack, Performance Tuning");
                j1.setSkills(List.of("JavaScript", "React", "HTML", "CSS", "Git", "System Design", "Webpack", "Performance Tuning"));

                j2.setTitle("Frontend Technical Lead");
                j2.setDescription("Drive front-end technology roadmap, mentor engineers, and design micro-frontends at scale.");
                j2.setRequirements("JavaScript, React, HTML, CSS, Git, System Design, Micro-Frontends, Team Leadership");
                j2.setSkills(List.of("JavaScript", "React", "HTML", "CSS", "Git", "System Design", "Micro-Frontends", "Team Leadership"));
            }
            case DEVOPS -> {
                j1.setTitle("Senior DevOps & Site Reliability Engineer (SRE)");
                j1.setDescription("Manage large-scale Kubernetes clusters. Implement automated CI/CD GitOps pipelines and high-availability systems.");
                j1.setRequirements("Linux, Docker, AWS, Kubernetes, Git, Terraform, SRE, Prometheus");
                j1.setSkills(List.of("Linux", "Docker", "AWS", "Kubernetes", "Git", "Terraform", "SRE", "Prometheus"));

                j2.setTitle("DevOps Architect / Infrastructure Lead");
                j2.setDescription("Design secure, resilient multi-cloud architectures. Set enterprise-wide DevOps standards and infrastructure-as-code patterns.");
                j2.setRequirements("Linux, Docker, AWS, Kubernetes, Git, Terraform, Cloud Security, Multi-Cloud Architecture");
                j2.setSkills(List.of("Linux", "Docker", "AWS", "Kubernetes", "Git", "Terraform", "Cloud Security", "Multi-Cloud Architecture"));
            }
            case NETWORKING -> {
                j1.setTitle("Senior Network Architect");
                j1.setDescription("Architect secure WAN/LAN infrastructures and SD-WAN networks for global data centers.");
                j1.setRequirements("CCNA, Networking, Routing, Switching, Linux, CCNP, SD-WAN, Network Security");
                j1.setSkills(List.of("CCNA", "Networking", "Routing", "Switching", "Linux", "CCNP", "SD-WAN", "Network Security"));

                j2.setTitle("Principal Infrastructure & Network Lead");
                j2.setDescription("Lead network engineering team, define multi-site hybrid-cloud enterprise connectivity standards.");
                j2.setRequirements("CCNA, Networking, Routing, Switching, Linux, CCIE, Hybrid-Cloud Networking, Infrastructure Automation");
                j2.setSkills(List.of("CCNA", "Networking", "Routing", "Switching", "Linux", "CCIE", "Hybrid-Cloud Networking", "Infrastructure Automation"));
            }
            case DATA -> {
                j1.setTitle("Senior Data Engineer / Analyst");
                j1.setDescription("Build and scale enterprise-grade data warehouse and ETL pipelines. Design analytical models to guide business strategy.");
                j1.setRequirements("SQL, Python, Excel, Power BI, Big Data, ETL Pipelines, Snowflake, PySpark");
                j1.setSkills(List.of("SQL", "Python", "Excel", "Power BI", "Big Data", "ETL Pipelines", "Snowflake", "PySpark"));

                j2.setTitle("Lead Data Scientist & Analytics Architect");
                j2.setDescription("Lead data scientists and analyst teams. Architect advanced ML pipelines and drive analytics roadmap.");
                j2.setRequirements("SQL, Python, Excel, Power BI, Machine Learning, Predictive Modeling, Team Leadership, Analytics Architecture");
                j2.setSkills(List.of("SQL", "Python", "Excel", "Power BI", "Machine Learning", "Predictive Modeling", "Team Leadership", "Analytics Architecture"));
            }
            default -> {
                j1.setTitle("Senior Software Engineer (Backend/Microservices)");
                j1.setDescription("Design and build high-throughput microservices. Architect distributed message queues, database schemas, and optimize REST APIs.");
                j1.setRequirements("Java, Spring Boot, SQL, REST API, Git, System Design, Microservices, Redis");
                j1.setSkills(List.of("Java", "Spring Boot", "SQL", "REST API", "Git", "System Design", "Microservices", "Redis"));

                j2.setTitle("Backend Technical Lead / Architect");
                j2.setDescription("Lead development of next-generation distributed platforms. Define technical architecture and design resilient databases.");
                j2.setRequirements("Java, Spring Boot, SQL, REST API, Git, System Design, Microservices, Distributed Systems, Cloud Architecture");
                j2.setSkills(List.of("Java", "Spring Boot", "SQL", "REST API", "Git", "System Design", "Microservices", "Distributed Systems", "Cloud Architecture"));
            }
        }
        
        jobs.add(j1);
        jobs.add(j2);
        return jobs;
    }

    public List<Job> recommendJobs(int userId, HttpServletRequest req) throws Exception {
        List<String> userSkills = dao.getUserSkills(userId);
        CareerContext careerCtx = req != null ? contextService.getContext(req, userId) : null;
        JobDomain roleDomain = careerCtx != null
                ? careerCtx.getRoleDomainEnum() : AppUtil.detectUserDomain(userSkills);
        double minMatch = careerCtx != null ? CareerContextService.ROLE_FEED_MIN_MATCH : JobRelevanceEngine.MIN_MATCH_PCT;

        dao.clearRecommendations(userId);

        List<Job> jobs = dao.listActiveJobs();
        List<Job> recommended = new ArrayList<>();

        for (Job j : jobs) {
            List<String> reqSkills = j.getSkills().isEmpty()
                    ? AppUtil.parseList(j.getRequirements())
                    : j.getSkills();

            if (!JobRelevanceEngine.passesFilterForRoleContext(userSkills, reqSkills,
                    j.getTitle(), j.getDescription(), roleDomain, minMatch)) {
                j.setMatchPct(0);
                continue;
            }

            double pct = AppUtil.matchPercent(userSkills, reqSkills);
            j.setMatchPct(pct);

            if (pct >= minMatch) {
                dao.saveRecommendation(
                        userId,
                        j.getJobId(),
                        pct,
                        String.join(", ", AppUtil.missing(userSkills, reqSkills))
                );
                recommended.add(j);
            }
        }

        recommended.sort(Comparator.comparingDouble(Job::getMatchPct).reversed());

        boolean isJobReady = false;
        SkillGap latestGap = null;
        try {
            latestGap = dao.getLatestGap(userId);
            if (latestGap != null && (latestGap.getMissingSkills() == null || latestGap.getMissingSkills().trim().isEmpty())) {
                isJobReady = true;
            }
        } catch (Exception e) {
            // Ignore
        }

        if (isJobReady) {
            List<Job> seniorJobs = getHigherLevelJobs(roleDomain, latestGap != null ? latestGap.getTargetTitle() : "Software Developer");
            for (Job sj : seniorJobs) {
                double pct = AppUtil.matchPercent(userSkills, sj.getSkills());
                sj.setMatchPct(pct);
                try {
                    dao.saveRecommendation(
                            userId,
                            sj.getJobId(),
                            pct,
                            String.join(", ", AppUtil.missing(userSkills, sj.getSkills()))
                    );
                } catch (Exception e) {
                    // Ignore
                }
                recommended.add(sj);
            }
            recommended.sort(Comparator.comparingDouble(Job::getMatchPct).reversed());
        }

        return recommended;
    }

    /** Match % buckets for dashboard chart: 40-50, 50-60, 60-70, 70-80, 80+. */
    public int[] getMatchDistribution(int userId, HttpServletRequest req) throws Exception {
        int[] buckets = new int[5];
        for (JobFeedItem j : getLiveJobFeed(userId, req)) {
            double m = j.getMatchPct();
            if (m < 50) buckets[0]++;
            else if (m < 60) buckets[1]++;
            else if (m < 70) buckets[2]++;
            else if (m < 80) buckets[3]++;
            else buckets[4]++;
        }
        return buckets;
    }

    public List<String> getTopMissingSkills(int userId, int limit) throws Exception {
        SkillGap gap = dao.getLatestGap(userId);
        if (gap == null || gap.getMissingSkills() == null) return List.of();
        List<String> miss = AppUtil.parseList(gap.getMissingSkills());
        return miss.size() <= limit ? miss : miss.subList(0, limit);
    }

    public void afterResumeUpload(HttpServletRequest req, int userId) throws Exception {
        contextService.afterResumeUpload(req, userId);
    }

    public CareerRefreshResult setSelectedJobRole(HttpServletRequest req, int userId,
                                                   String roleOption) throws Exception {
        Integer jobId = null;
        String domain = null;
        if (roleOption != null && roleOption.startsWith("job:")) {
            jobId = Integer.parseInt(roleOption.substring(4));
        } else if (roleOption != null && roleOption.startsWith("domain:")) {
            domain = roleOption.substring(7);
        } else if (roleOption != null && !roleOption.isBlank()) {
            domain = roleOption;
        }
        return contextService.applyRoleChange(req, userId, jobId, domain);
    }

    public ChatResponse chat(int userId, String msg, HttpServletRequest req) throws Exception {
        if (msg == null || msg.isBlank()) {
            ChatResponse empty = new ChatResponse();
            empty.setType("HELP");
            empty.setTitle("Career mentor");
            empty.setSummary("Ask about skills, job matches, or what to learn next — I use your live profile.");
            empty.setReply(empty.getSummary());
            return empty;
        }

        dao.saveChat(userId, "USER", msg.trim());
        var profile = aiService.buildProfile(userId, req);
        ChatResponse response = aiService.advise(msg.trim(), profile);
        dao.saveChat(userId, "ASSISTANT", response.getReply());
        return response;
    }

    public List<LearningItem> generateLearningPath(int userId, HttpServletRequest req) throws Exception {
        CareerContext ctx = contextService.getContext(req, userId);
        SkillGap gap = contextService.getSkillGapForContext(userId, ctx);
        contextService.regenerateLearningPath(userId, gap);
        return dao.listLearningPaths(userId);
    }

    public List<SkillLearningHub> getSkillLearningHubs(int userId, HttpServletRequest req) throws Exception {
        CareerContext ctx = contextService.getContext(req, userId);
        return contextService.getLearningHubs(userId, ctx);
    }

    public String refreshJobFeed(ServletContext ctx, int userId, HttpServletRequest req) throws Exception {
        CareerContext careerCtx = contextService.getContext(req, userId);
        return contextService.refreshExternalJobs(ctx, userId, careerCtx);
    }

    public List<JobFeedItem> getLiveJobFeed(int userId, HttpServletRequest req) throws Exception {
        CareerContext ctx = contextService.getContext(req, userId);
        return contextService.getJobFeed(userId, ctx);
    }

    public SkillGap getContextSkillGap(int userId, HttpServletRequest req) throws Exception {
        CareerContext ctx = contextService.getContext(req, userId);
        return contextService.getSkillGapForContext(userId, ctx);
    }

    /** Builds the internal apply review page (no external redirect). */
    public ApplyPreview buildApplyPreview(int userId, String feedType, int refId) throws Exception {
        if (feedType == null || feedType.isBlank()) {
            throw new IllegalArgumentException("Job type is required.");
        }
        feedType = feedType.trim().toUpperCase();

        List<String> userSkills = dao.getUserSkills(userId);
        ApplyPreview p = new ApplyPreview();
        p.setFeedType(feedType);
        p.setRefId(refId);
        p.setUserSkills(userSkills);
        p.setResumeSummary(dao.getLatestResumeSummary(userId, 320));
        p.setAlreadyApplied(dao.hasApplied(userId, feedType, refId));

        List<String> required = new ArrayList<>();

        switch (feedType) {
            case "INTERNAL" -> {
                Job job = dao.getJob(refId);
                if (job == null) return null;
                p.setTitle(job.getTitle());
                p.setCompany(job.getCompany());
                p.setLocation(job.getLocation());
                p.setSource("CareerAssist");
                p.setDescription(job.getDescription());
                required = job.getSkills().isEmpty()
                        ? AppUtil.parseList(job.getRequirements()) : job.getSkills();
            }
            case "API" -> {
                ExtJob job = dao.getApiJob(refId);
                if (job == null) return null;
                fillFromExtJob(p, job);
                required = AppUtil.parseList(job.getSkills());
            }
            case "SCRAPED" -> {
                ExtJob job = dao.getScrapedJob(refId);
                if (job == null) return null;
                fillFromExtJob(p, job);
                required = AppUtil.parseList(job.getSkills());
            }
            default -> throw new IllegalArgumentException("Unknown job type: " + feedType);
        }

        double match = AppUtil.matchPercent(userSkills, required);
        List<String> missing = AppUtil.missing(userSkills, required);
        List<String> matched = new ArrayList<>();
        for (String r : required) {
            if (!missing.contains(r)) matched.add(r);
        }

        p.setMatchPct(match);
        p.setMatchedSkills(matched);
        p.setMissingSkills(missing);
        p.setWhyRecommended(buildWhyRecommended(userSkills, match, matched, missing, p.getTitle()));
        return p;
    }

    private static void fillFromExtJob(ApplyPreview p, ExtJob job) {
        p.setTitle(job.getTitle());
        p.setCompany(job.getCompany());
        p.setLocation(job.getLocation());
        p.setSource(job.getSource() != null ? job.getSource() : "External");
        p.setDescription(job.getDescription());
        p.setExternalUrl(job.getUrl());
    }

    private static String buildWhyRecommended(List<String> userSkills, double match,
                                              List<String> matched, List<String> missing, String title) {
        if (userSkills == null || userSkills.isEmpty()) {
            return "Upload your resume to unlock personalized match scores and skill-based recommendations.";
        }
        StringBuilder sb = new StringBuilder();
        if (match >= 75) {
            sb.append("Strong fit for ").append(title != null ? title : "this role")
                    .append(" — your resume aligns well with required skills.");
        } else if (match >= 50) {
            sb.append("Moderate fit — you already cover several requirements; closing skill gaps will improve your odds.");
        } else {
            sb.append("Stretch role — useful for growth; focus on missing skills before applying widely.");
        }
        if (!matched.isEmpty()) {
            sb.append(" You match: ").append(String.join(", ", matched)).append(".");
        }
        if (!missing.isEmpty() && missing.size() <= 5) {
            sb.append(" Priority upskilling: ").append(String.join(", ", missing)).append(".");
        }
        JobDomain domain = AppUtil.detectUserDomain(userSkills);
        sb.append(" Recommendations stay within your ").append(domain.name().replace('_', ' ')).append(" career domain.");
        return sb.toString();
    }

    /** Records application as APPLIED and returns display title for success page. */
    public String submitInternalApplication(int userId, String feedType, int refId) throws Exception {
        ApplyPreview preview = buildApplyPreview(userId, feedType, refId);
        if (preview == null) throw new IllegalArgumentException("Job not found.");
        if (preview.isAlreadyApplied()) {
            return preview.getTitle();
        }
        trackApplication(userId, feedType, refId);
        return preview.getTitle();
    }

    /** Tracks application in DB as APPLIED. */
    public void trackApplication(int userId, String feedType, int refId) throws Exception {
        Application app = new Application();
        app.setUserId(userId);
        app.setJobSource(feedType);
        app.setStatus("APPLIED");
        switch (feedType) {
            case "INTERNAL" -> app.setJobId(refId);
            case "API" -> app.setApiJobId(refId);
            case "SCRAPED" -> app.setScrapedJobId(refId);
            default -> throw new IllegalArgumentException("Unknown job type");
        }
        dao.apply(app);
    }

    /** Resolves legacy apply params (source + jobId/apiId/scrapedId) to feedType + refId. */
    public static String[] resolveApplyParams(String feedType, String refId,
                                              String source, String jobId, String apiId, String scrapedId) {
        if (feedType != null && !feedType.isBlank() && refId != null && !refId.isBlank()) {
            return new String[] { feedType.trim().toUpperCase(), refId.trim() };
        }
        if (source == null || source.isBlank()) return null;
        String src = source.trim().toUpperCase();
        return switch (src) {
            case "INTERNAL" -> jobId != null && !jobId.isBlank()
                    ? new String[] { "INTERNAL", jobId.trim() } : null;
            case "API" -> apiId != null && !apiId.isBlank()
                    ? new String[] { "API", apiId.trim() } : null;
            case "SCRAPED" -> scrapedId != null && !scrapedId.isBlank()
                    ? new String[] { "SCRAPED", scrapedId.trim() } : null;
            default -> null;
        };
    }

    public void updateApplicationStatus(int userId, int applicationId, String status) throws Exception {
        if (!isValidAppStatus(status)) {
            throw new IllegalArgumentException("Invalid status");
        }
        dao.updateApplicationStatus(applicationId, userId, status);
    }

    public static boolean isValidAppStatus(String status) {
        return "APPLIED".equals(status) || "INTERVIEW".equals(status)
                || "REJECTED".equals(status) || "SELECTED".equals(status);
    }

    public void seedSampleExternalJobs() throws Exception {
        ExtJob j1 = new ExtJob();
        j1.setExternalId("sample-1");
        j1.setTitle("Software Engineer");
        j1.setCompany("Infosys");
        j1.setLocation("Bangalore");
        j1.setSkills("Java, SQL");
        j1.setUrl("https://example.com/1");
        j1.setSource("ADZUNA");
        dao.upsertApiJob(j1);

        ExtJob j2 = new ExtJob();
        j2.setExternalId("indeed-sample-1");
        j2.setTitle("React Developer");
        j2.setCompany("TCS");
        j2.setLocation("Chennai");
        j2.setSkills("React, JavaScript");
        j2.setUrl("https://example.com/2");
        j2.setSource("INDEED");
        dao.upsertScrapedJob(j2);
    }

    public CareerDAO getDao() {
        return dao;
    }
}
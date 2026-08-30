package com.careerassist.service;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.careerassist.dao.CareerDAO;
import com.careerassist.model.CareerContext;
import com.careerassist.model.CareerRefreshResult;
import com.careerassist.model.Job;
import com.careerassist.model.JobDomain;
import com.careerassist.model.JobFeedItem;
import com.careerassist.model.LearningItem;
import com.careerassist.model.SkillGap;
import com.careerassist.model.SkillLearningHub;
import com.careerassist.util.AppUtil;
import com.careerassist.util.JobRelevanceEngine;
import com.careerassist.util.LearningResourceCatalog;
import com.careerassist.util.PracticePlatformCatalog;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Central job-role context: skill gap, learning paths, and job feed all react to the selected target role.
 */
public class CareerContextService {

    public static final double ROLE_FEED_MIN_MATCH = 40.0;

    private static final Map<JobDomain, String> DOMAIN_ROLE_TITLES = new EnumMap<>(JobDomain.class);
    private static final Map<JobDomain, List<String>> DOMAIN_REQUIRED_SKILLS = new EnumMap<>(JobDomain.class);

    static {
        DOMAIN_ROLE_TITLES.put(JobDomain.NETWORKING, "Network Engineer");
        DOMAIN_ROLE_TITLES.put(JobDomain.BACKEND, "Backend Developer");
        DOMAIN_ROLE_TITLES.put(JobDomain.FRONTEND, "Frontend Developer");
        DOMAIN_ROLE_TITLES.put(JobDomain.DEVOPS, "DevOps Engineer");
        DOMAIN_ROLE_TITLES.put(JobDomain.DATA, "Data Analyst");
        DOMAIN_ROLE_TITLES.put(JobDomain.FULL_STACK, "Full Stack Developer");
        DOMAIN_ROLE_TITLES.put(JobDomain.SALES, "Sales Executive");
        DOMAIN_ROLE_TITLES.put(JobDomain.MARKETING, "Marketing Specialist");
        DOMAIN_ROLE_TITLES.put(JobDomain.FACULTY, "Research Associate / Trainer");
        DOMAIN_ROLE_TITLES.put(JobDomain.GENERAL, "Software Developer");

        DOMAIN_REQUIRED_SKILLS.put(JobDomain.NETWORKING,
                List.of("CCNA", "Networking", "Routing", "Switching", "Linux"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.BACKEND,
                List.of("Java", "Spring Boot", "SQL", "REST API", "Git"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.FRONTEND,
                List.of("JavaScript", "React", "HTML", "CSS", "Git"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.DEVOPS,
                List.of("Linux", "Docker", "AWS", "Kubernetes", "Git"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.DATA,
                List.of("SQL", "Python", "Excel", "Power BI"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.FULL_STACK,
                List.of("Java", "JavaScript", "React", "SQL", "HTML", "CSS", "Git", "Spring Boot"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.SALES,
                List.of("Sales", "Lead Generation", "CRM", "Negotiation", "Customer Relationship Management"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.MARKETING,
                List.of("Marketing", "SEO", "Social Media", "Content Creation"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.FACULTY,
                List.of("Teaching", "Research", "Machine Learning", "Data Analysis"));
        DOMAIN_REQUIRED_SKILLS.put(JobDomain.GENERAL,
                List.of("Java", "SQL", "Git", "JavaScript"));
    }

    private final CareerDAO dao = new CareerDAO();
    private final JobFeedService jobFeedService = new JobFeedService();

    public CareerContext getContext(HttpServletRequest req, int userId) throws Exception {
        HttpSession session = req.getSession(false);
        if (session != null) {
            Object stored = session.getAttribute(AppUtil.SESSION_CAREER_CONTEXT);
            if (stored instanceof CareerContext ctx && ctx.getTargetTitle() != null) {
                return ctx;
            }
        }
        CareerContext initialized = initializeDefaultContext(userId);
        saveContext(req, initialized);
        return initialized;
    }

    public void saveContext(HttpServletRequest req, CareerContext ctx) {
        req.getSession(true).setAttribute(AppUtil.SESSION_CAREER_CONTEXT, ctx);
    }

    /** User changed target role — recalculates gap, learning path, and refreshes feed filter. */
    public CareerRefreshResult applyRoleChange(HttpServletRequest req, int userId,
                                               Integer jobId, String domainKey) throws Exception {
        List<String> userSkills = dao.getUserSkills(userId);
        CareerContext ctx;

        if (jobId != null && jobId > 0) {
            Job job = dao.getJob(jobId);
            if (job == null) {
                throw new IllegalArgumentException("Job role not found.");
            }
            ctx = CareerContext.fromJob(job, userSkills);
        } else if (domainKey != null && !domainKey.isBlank()) {
            JobDomain domain = parseDomain(domainKey);
            List<String> reqSkills = DOMAIN_REQUIRED_SKILLS.getOrDefault(domain, DOMAIN_REQUIRED_SKILLS.get(JobDomain.GENERAL));
            String title = DOMAIN_ROLE_TITLES.getOrDefault(domain, domain.name());
            ctx = CareerContext.fromDomain(domain, title, reqSkills, userSkills);
        } else {
            throw new IllegalArgumentException("Select a job role or career domain.");
        }

        SkillGap gap = computeAndPersistSkillGap(userId, ctx, userSkills);
        ctx.setReadinessPct(Math.round((100 - gap.getGapPercentage()) * 10.0) / 10.0);

        int learningCount = regenerateLearningPath(userId, gap);
        saveContext(req, ctx);

        List<JobFeedItem> feed = getJobFeed(userId, ctx);

        CareerRefreshResult result = new CareerRefreshResult();
        result.setContext(ctx);
        result.setGap(gap);
        result.setFeed(feed);
        result.setLearningItemCount(learningCount);
        result.setMessage("Updated target role: " + ctx.getTargetTitle()
                + " · " + feed.size() + " jobs (≥" + (int) ROLE_FEED_MIN_MATCH + "% match)"
                + " · " + learningCount + " learning resources");
        return result;
    }

    public SkillGap computeAndPersistSkillGap(int userId, CareerContext ctx, List<String> userSkills)
            throws Exception {
        List<String> req = ctx.getRequiredSkills();
        if (req.isEmpty()) {
            req = DOMAIN_REQUIRED_SKILLS.get(ctx.getRoleDomainEnum());
        }
        return persistGap(userId, ctx.getJobId(), ctx.getTargetTitle(), userSkills, req);
    }

    public SkillGap getSkillGapForContext(int userId, CareerContext ctx) throws Exception {
        return computeAndPersistSkillGap(userId, ctx, dao.getUserSkills(userId));
    }

    public List<JobFeedItem> getJobFeed(int userId, CareerContext ctx) throws Exception {
        List<String> userSkills = dao.getUserSkills(userId);
        return jobFeedService.buildLiveFeed(userId, userSkills, ctx);
    }

    public String refreshExternalJobs(ServletContext servletCtx, int userId, CareerContext ctx) throws Exception {
        JobDomain domain = ctx.getRoleDomainEnum();
        List<String> userSkills = dao.getUserSkills(userId);
        return jobFeedService.refreshLiveFeed(servletCtx, userSkills, domain);
    }

    private List<LearningItem> getAdvancedGrowthItems(JobDomain domain, String targetTitle) {
        List<LearningItem> items = new ArrayList<>();
        
        LearningItem sysDesign = new LearningItem();
        sysDesign.setSkillName("Advanced Growth: " + (targetTitle != null ? targetTitle : "Software Developer"));
        sysDesign.setLevelStage("ADVANCED");
        
        LearningItem interviewPrep = new LearningItem();
        interviewPrep.setSkillName("Advanced Growth: " + (targetTitle != null ? targetTitle : "Software Developer"));
        interviewPrep.setLevelStage("ADVANCED");
        
        LearningItem certs = new LearningItem();
        certs.setSkillName("Advanced Growth: " + (targetTitle != null ? targetTitle : "Software Developer"));
        certs.setLevelStage("ADVANCED");
        
        LearningItem projects = new LearningItem();
        projects.setSkillName("Advanced Growth: " + (targetTitle != null ? targetTitle : "Software Developer"));
        projects.setLevelStage("ADVANCED");

        switch (domain) {
            case SALES -> {
                sysDesign.setTitle("Enterprise Sales Strategy & Pipeline Design");
                sysDesign.setResourceUrl("https://www.salesforce.com/in/learning-centre/sales/");
                sysDesign.setPlatform("Salesforce Center");

                interviewPrep.setTitle("Sales & Account Management Role-play & Interview Masterclass");
                interviewPrep.setResourceUrl("https://www.youtube.com/playlist?list=PL44tZ2f-e8b2gM7lM5wRszn0P9wY5Z3tT");
                interviewPrep.setPlatform("YouTube");

                certs.setTitle("Salesforce Certified Administrator / HubSpot Certified");
                certs.setResourceUrl("https://trailhead.salesforce.com/en/credentials/administrator");
                certs.setPlatform("Salesforce");

                projects.setTitle("Client Acquisition Campaign & Revenue Analysis");
                projects.setResourceUrl("https://github.com/topics/sales-dashboard");
                projects.setPlatform("GitHub");
            }
            case MARKETING -> {
                sysDesign.setTitle("Integrated Marketing Communication & Brand Strategy");
                sysDesign.setResourceUrl("https://www.coursera.org/specializations/integrated-marketing-communications");
                sysDesign.setPlatform("Coursera");

                interviewPrep.setTitle("Digital Marketing Portfolio & Growth Case Study Prep");
                interviewPrep.setResourceUrl("https://acadmium.com/");
                interviewPrep.setPlatform("Acadmium");

                certs.setTitle("Google Digital Marketing & E-commerce Professional Certificate");
                certs.setResourceUrl("https://grow.google/certificates/digital-marketing-ecommerce/");
                certs.setPlatform("Google");

                projects.setTitle("SEO Audit & Social Media Campaign Analysis");
                projects.setResourceUrl("https://github.com/topics/seo-analyzer");
                projects.setPlatform("GitHub");
            }
            case FACULTY -> {
                sysDesign.setTitle("Curriculum Design & Pedagogy in Higher Education");
                sysDesign.setResourceUrl("https://www.coursera.org/specializations/higher-education-pedagogy");
                sysDesign.setPlatform("Coursera");

                interviewPrep.setTitle("Teaching Demonstration & Academic Job Interview Prep");
                interviewPrep.setResourceUrl("https://career.berkeley.edu/phds/academic-job-search/academic-job-interviewing/");
                interviewPrep.setPlatform("Berkeley Career Center");

                certs.setTitle("Certified Online Instructor (COI) / AWS Academy Accredited");
                certs.setResourceUrl("https://aws.amazon.com/training/aws-academy/");
                certs.setPlatform("AWS Academy");

                projects.setTitle("Academic Research Paper / Technical Training Material Design");
                projects.setResourceUrl("https://arxiv.org/");
                projects.setPlatform("arXiv");
            }
            case FRONTEND -> {
                sysDesign.setTitle("Frontend System Design & Architecture");
                sysDesign.setResourceUrl("https://github.com/careercup/frontend-system-design");
                sysDesign.setPlatform("GitHub");

                interviewPrep.setTitle("GreatFrontEnd — Frontend Coding Interview Prep");
                interviewPrep.setResourceUrl("https://www.greatfrontend.com/");
                interviewPrep.setPlatform("GreatFrontEnd");

                certs.setTitle("Meta Front-End Developer Professional Certificate");
                certs.setResourceUrl("https://www.coursera.org/professional-certificates/meta-front-end-developer");
                certs.setPlatform("Coursera");

                projects.setTitle("Advanced Frontend Framework & Micro-Frontends");
                projects.setResourceUrl("https://github.com/micro-frontends-org/micro-frontends");
                projects.setPlatform("GitHub");
            }
            case DEVOPS -> {
                sysDesign.setTitle("Site Reliability Engineering (SRE) & Distributed Infrastructure");
                sysDesign.setResourceUrl("https://sre.google/sre-book/table-of-contents/");
                sysDesign.setPlatform("Google SRE Book");

                interviewPrep.setTitle("DevOps & SRE Interview Prep & Exercises");
                interviewPrep.setResourceUrl("https://github.com/bregman-arie/devops-exercises");
                interviewPrep.setPlatform("GitHub");

                certs.setTitle("Certified Kubernetes Administrator (CKA) / AWS DevOps Pro");
                certs.setResourceUrl("https://aws.amazon.com/certification/certified-devops-engineer-professional/");
                certs.setPlatform("AWS & CNCF");

                projects.setTitle("Production-Grade GitOps Pipeline with Kubernetes & ArgoCD");
                projects.setResourceUrl("https://github.com/argoproj/argo-cd");
                projects.setPlatform("ArgoCD");
            }
            case NETWORKING -> {
                sysDesign.setTitle("Enterprise WAN/LAN Network Architecture & SD-WAN Design");
                sysDesign.setResourceUrl("https://www.cisco.com/c/en/us/solutions/design-guides.html");
                sysDesign.setPlatform("Cisco Design Guides");

                interviewPrep.setTitle("Network Engineer Technical Interview Masterclass");
                interviewPrep.setResourceUrl("https://www.youtube.com/playlist?list=PLDZbR2u6k5t4pQG5N076LqL-Z1gY1r1_K");
                interviewPrep.setPlatform("YouTube");

                certs.setTitle("Cisco Certified Network Professional (CCNP) Enterprise");
                certs.setResourceUrl("https://www.cisco.com/c/en/us/training-events/training-certifications/certifications/professional/ccnp-enterprise.html");
                certs.setPlatform("Cisco");

                projects.setTitle("Multi-Site Hybrid Cloud Infrastructure & Simulation");
                projects.setResourceUrl("https://www.gns3.com/");
                projects.setPlatform("GNS3");
            }
            case DATA -> {
                sysDesign.setTitle("Data Warehouse & Big Data Pipelines Design");
                sysDesign.setResourceUrl("https://github.com/dunnhumby/data-engineering-roadmap");
                sysDesign.setPlatform("GitHub");

                interviewPrep.setTitle("Advanced SQL & Data Analytics Interview Prep");
                interviewPrep.setResourceUrl("https://www.stratascratch.com/");
                interviewPrep.setPlatform("StrataScratch");

                certs.setTitle("Microsoft Certified: Power BI Data Analyst / Google Data Engineer");
                certs.setResourceUrl("https://learn.microsoft.com/en-us/credentials/certifications/power-bi-data-analyst-associate/");
                certs.setPlatform("Microsoft & Google");

                projects.setTitle("End-to-End Analytics Dashboard & Predictive ML Pipeline");
                projects.setResourceUrl("https://www.kaggle.com/code");
                projects.setPlatform("Kaggle");
            }
            default -> {
                sysDesign.setTitle("System Design Primer & Distributed Systems");
                sysDesign.setResourceUrl("https://github.com/donnemartin/system-design-primer");
                sysDesign.setPlatform("GitHub");

                interviewPrep.setTitle("LeetCode Blind 75 / NeetCode Coding Interview Prep");
                interviewPrep.setResourceUrl("https://neetcode.io/practice");
                interviewPrep.setPlatform("NeetCode");

                certs.setTitle("Oracle Certified Professional: Java Developer / AWS Developer Associate");
                certs.setResourceUrl("https://education.oracle.com/oracle-certified-professional-java-se-17-developer/trackp_OCPJAV17");
                certs.setPlatform("Oracle & AWS");

                projects.setTitle("High-Throughput Distributed Microservices Architecture");
                projects.setResourceUrl("https://github.com/microservices-one/microservices-ref-arch");
                projects.setPlatform("GitHub");
            }
        }
        
        items.add(sysDesign);
        items.add(interviewPrep);
        items.add(certs);
        items.add(projects);
        return items;
    }

    public int regenerateLearningPath(int userId, SkillGap gap) throws Exception {
        if (gap == null) {
            dao.clearLearningPaths(userId);
            return 0;
        }

        dao.clearLearningPaths(userId);
        int order = 0;

        if (gap.getMissingSkills() == null || gap.getMissingSkills().trim().isEmpty()) {
            JobDomain domain = gap.getTargetTitle() != null
                    ? AppUtil.classifyJobDomain(gap.getTargetTitle(), null, AppUtil.parseList(gap.getRequiredSkills()))
                    : JobDomain.GENERAL;
            
            List<LearningItem> advItems = getAdvancedGrowthItems(domain, gap.getTargetTitle());
            for (LearningItem li : advItems) {
                dao.saveLearningPath(userId, li, order++, null);
            }
            return order;
        }

        JobDomain domain = gap.getTargetTitle() != null
                ? AppUtil.classifyJobDomain(gap.getTargetTitle(), null, AppUtil.parseList(gap.getRequiredSkills()))
                : JobDomain.GENERAL;

        for (String sk : AppUtil.parseList(gap.getMissingSkills())) {
            if (!skillMatchesDomain(sk, domain)) {
                continue;
            }
            SkillLearningHub hub = LearningResourceCatalog.buildSkillHub(sk, dao.listResourcesForSkill(sk));
            String practiceCsv = hub.getPracticePlatforms();
            for (LearningItem li : hub.getLearnItems()) {
                dao.saveLearningPath(userId, li, order++, practiceCsv);
            }
            for (LearningItem li : hub.getReadItems()) {
                dao.saveLearningPath(userId, li, order++, practiceCsv);
            }
            for (LearningItem li : LearningResourceCatalog.buildPracticeItems(sk)) {
                dao.saveLearningPath(userId, li, order++, practiceCsv);
            }
        }
        return order;
    }

    public List<SkillLearningHub> getLearningHubs(int userId, CareerContext ctx) throws Exception {
        SkillGap gap = dao.getLatestGap(userId);
        if (gap == null) {
            gap = computeAndPersistSkillGap(userId, ctx, dao.getUserSkills(userId));
        }
        List<LearningItem> paths = dao.listLearningPaths(userId);
        if (paths.isEmpty()) {
            regenerateLearningPath(userId, gap);
            paths = dao.listLearningPaths(userId);
        }
        return assembleHubs(paths);
    }

    public CareerContext initializeDefaultContext(int userId) throws Exception {
        List<String> userSkills = dao.getUserSkills(userId);
        if (userSkills.isEmpty()) {
            JobDomain d = JobDomain.GENERAL;
            return CareerContext.fromDomain(d, DOMAIN_ROLE_TITLES.get(d),
                    DOMAIN_REQUIRED_SKILLS.get(d), userSkills);
        }

        Job best = null;
        double bestPct = -1;
        JobDomain userDomain = AppUtil.detectUserDomain(userSkills);

        for (Job j : dao.listActiveJobs()) {
            List<String> req = j.getSkills().isEmpty()
                    ? AppUtil.parseList(j.getRequirements()) : j.getSkills();
            JobDomain jd = AppUtil.classifyJobDomain(j.getTitle(), j.getDescription(), req);
            if (userDomain != JobDomain.GENERAL && jd != userDomain && userDomain != JobDomain.FULL_STACK) {
                continue;
            }
            double pct = AppUtil.matchPercent(userSkills, req);
            if (pct > bestPct) {
                bestPct = pct;
                best = j;
            }
        }

        if (best != null && bestPct >= 20) {
            CareerContext ctx = CareerContext.fromJob(best, userSkills);
            persistGap(userId, best.getJobId(), best.getTitle(), userSkills, ctx.getRequiredSkills());
            return ctx;
        }

        List<String> req = DOMAIN_REQUIRED_SKILLS.get(userDomain);
        CareerContext ctx = CareerContext.fromDomain(userDomain, DOMAIN_ROLE_TITLES.get(userDomain), req, userSkills);
        persistGap(userId, null, ctx.getTargetTitle(), userSkills, req);
        return ctx;
    }

    public void afterResumeUpload(HttpServletRequest req, int userId) throws Exception {
        CareerContext ctx = initializeDefaultContext(userId);
        SkillGap gap = dao.getLatestGap(userId);
        if (gap == null) {
            gap = computeAndPersistSkillGap(userId, ctx, dao.getUserSkills(userId));
        }
        regenerateLearningPath(userId, gap);
        saveContext(req, ctx);
    }

    /** Selectable roles for UI: domain templates + active internal jobs. */
    public Map<String, String> listRoleOptions(int userId) throws Exception {
        Map<String, String> options = new LinkedHashMap<>();
        for (JobDomain d : List.of(JobDomain.NETWORKING, JobDomain.FULL_STACK, JobDomain.BACKEND,
                JobDomain.FRONTEND, JobDomain.DEVOPS, JobDomain.DATA)) {
            options.put("domain:" + d.name(), DOMAIN_ROLE_TITLES.get(d));
        }
        for (Job j : dao.listActiveJobs()) {
            options.put("job:" + j.getJobId(), j.getTitle() + " — " + j.getCompany());
        }
        return options;
    }

    public static String selectedOptionValue(CareerContext ctx) {
        if (ctx == null) return "";
        if (ctx.getJobId() != null) return "job:" + ctx.getJobId();
        if (ctx.getRoleDomain() != null) return "domain:" + ctx.getRoleDomain();
        return "";
    }

    private SkillGap persistGap(int userId, Integer jobId, String title,
                                List<String> user, List<String> req) throws Exception {
        double match = AppUtil.matchPercent(user, req);
        List<String> miss = AppUtil.missing(user, req);
        List<String> acq = new ArrayList<>();
        for (String r : req) {
            if (!miss.contains(r)) acq.add(r);
        }

        SkillGap g = new SkillGap();
        g.setUserId(userId);
        g.setJobId(jobId);
        g.setTargetTitle(title);
        g.setGapPercentage(100 - match);
        g.setRequiredSkills(String.join(", ", req));
        g.setAcquiredSkills(String.join(", ", acq));
        g.setMissingSkills(String.join(", ", miss));
        dao.saveSkillGap(g);
        return g;
    }

    private static boolean skillMatchesDomain(String skill, JobDomain domain) {
        if (domain == JobDomain.GENERAL || domain == JobDomain.FULL_STACK) return true;
        JobDomain skillDomain = AppUtil.classifyJobDomain(null, null, List.of(skill));
        return skillDomain == domain || skillDomain == JobDomain.GENERAL
                || domain == JobDomain.FULL_STACK;
    }

    private static JobDomain parseDomain(String key) {
        return JobDomain.valueOf(key.trim().toUpperCase());
    }

    private List<SkillLearningHub> assembleHubs(List<LearningItem> all) {
        Map<String, SkillLearningHub> map = new LinkedHashMap<>();
        for (LearningItem li : all) {
            String sk = li.getSkillName() != null ? li.getSkillName() : "General";
            SkillLearningHub hub = map.computeIfAbsent(sk, k -> {
                SkillLearningHub h = new SkillLearningHub();
                h.setSkillName(k);
                return h;
            });
            if (li.isLearnStage()) hub.getLearnItems().add(li);
            else if (li.isReadStage()) hub.getReadItems().add(li);
            else if (li.isPracticeStage()) {
                hub.getPracticeLinks().add(new com.careerassist.model.PracticeLink(
                        li.getTitle(), li.getResourceUrl(),
                        li.getPlatform() != null ? li.getPlatform().replace("Practice · ", "") : "Practice"));
            }
        }
        for (SkillLearningHub hub : map.values()) {
            if (hub.getPracticeLinks().isEmpty()) {
                var links = PracticePlatformCatalog.forSkill(hub.getSkillName());
                hub.setPracticeLinks(links);
                hub.setPracticePlatforms(PracticePlatformCatalog.toCsv(links));
            }
        }
        return new ArrayList<>(map.values());
    }
}

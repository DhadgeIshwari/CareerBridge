package com.careerassist.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

import com.careerassist.model.JobDomain;
import com.careerassist.model.SkillGap;
import com.careerassist.model.User;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class AppUtil {
    public static final String SESSION_USER = "user";
    public static final String SESSION_CAREER_CONTEXT = "careerContext";

    /**
     * Keyword-based NLP rules: canonical skill name, resume keywords (longest phrases first),
     * optional phrases that suppress the whole rule when present (unrelated domains).
     */
    private static final SkillKeywordRule[] SKILL_KEYWORD_RULES = {
        rule("JavaScript", "javascript", "ecmascript", "typescript"),
        rule("Java", "java se", "java ee", "j2ee", "jdk", "jvm", "hibernate", "jsp", "servlet", "java"),
        rule("Python", "python", "django", "flask"),
        rule("SQL", "sql server", "microsoft sql", "pl/sql", "t-sql", "mysql", "postgresql", "postgres", "sqlite", "sql"),
        rule("Spring Boot", "spring boot"),
        rule("Spring", "spring framework", "spring mvc"),
        rule("AWS", "amazon web services", "amazon aws", "aws ec2", "aws s3", "aws lambda", "aws"),
        rule("Linux", "linux", "ubuntu", "centos", "red hat", "rhel", "debian", "unix shell"),
        rule("CCNA", "ccna", "cisco certified network associate", "cisco certified"),
        rule("Networking", "computer networking", "network engineer", "network administrator",
                "network administration", "network engineering", "tcp/ip", "tcp ip", "lan/wan", "osi model"),
        ruleEx("Networking", "social networking", "networking"),
        rule("Routing", "routing protocol", "routing protocols", "ip routing", "static routing",
                "dynamic routing", "ospf", "bgp", "eigrp", "ripv2", "routing and switching"),
        ruleEx("Routing", "routing number", "routing"),
        rule("Switching", "network switching", "layer 2 switching", "switching and routing",
                "routing and switching", "vlan", "spanning tree", "stp protocol"),
        ruleEx("Switching", "context switching", "switching"),
        rule("Node.js", "node.js", "nodejs"),
        rule("React", "react", "reactjs", "react.js"),
        rule("HTML", "html", "html5"),
        rule("CSS", "css", "css3"),
        rule("Git", "git", "github", "gitlab"),
        rule("Docker", "docker", "kubernetes", "k8s"),
        rule("MongoDB", "mongodb", "mongo db"),
        rule("REST API", "rest api", "restful api", "restful"),
        rule("Excel", "microsoft excel", "ms excel", "excel"),
        rule("Power BI", "power bi", "powerbi"),
        rule("Kubernetes", "kubernetes", "k8s", "helm"),
        rule("DevOps", "devops", "dev ops", "ci/cd", "ci cd", "infrastructure as code"),
        rule("Machine Learning", "machine learning", "deep learning", "tensorflow", "pytorch", "scikit-learn"),
        rule("Cisco", "cisco networking", "cisco ios", "cisco certified", "cisco"),
        // Sales
        rule("Sales", "sales", "inside sales", "direct sales", "corporate sales"),
        rule("Lead Generation", "lead generation", "cold calling", "prospecting"),
        rule("CRM", "crm", "salesforce", "hubspot CRM", "zoho CRM", "customer relationship management system"),
        rule("Negotiation", "negotiation", "deal closing", "contract negotiation"),
        rule("Customer Relationship Management", "customer relationship", "customer relationships", "client relations", "client relationship"),
        // Marketing
        rule("Marketing", "marketing", "digital marketing", "brand marketing", "product marketing"),
        rule("SEO", "seo", "search engine optimization", "search engine optimisation", "google analytics", "sem"),
        rule("Social Media", "social media", "social media marketing", "smm", "content marketing"),
        rule("Content Creation", "content creation", "copywriting", "blogging", "graphic design"),
        // Faculty
        rule("Teaching", "teaching", "lecturing", "tutoring", "pedagogy", "instructional", "classroom management", "trainer"),
        rule("Research", "research", "academic research", "scientific research", "publications", "paper writing"),
        rule("Data Analysis", "data analysis", "data analytics", "statistical analysis", "statistical data analysis")
    };

    private static final Set<String> NETWORKING_SKILLS = Set.of(
            "ccna", "networking", "routing", "switching", "linux", "cisco");
    private static final Set<String> BACKEND_SKILLS = Set.of(
            "java", "spring boot", "spring", "python", "sql", "mongodb", "rest api", "hibernate", "jsp", "servlet");
    private static final Set<String> FRONTEND_SKILLS = Set.of(
            "javascript", "react", "html", "css", "node.js");
    private static final Set<String> DEVOPS_SKILLS = Set.of(
            "aws", "docker", "linux", "kubernetes", "devops", "git");
    private static final Set<String> FULL_STACK_SKILLS = Set.of(
            "java", "javascript", "spring boot", "spring", "react", "node.js", "html", "css",
            "git", "docker", "aws", "mongodb", "rest api");
    private static final Set<String> DATA_SKILLS = Set.of(
            "sql", "python", "excel", "power bi", "machine learning");
    private static final Set<String> SALES_SKILLS = Set.of(
            "sales", "lead generation", "crm", "negotiation", "customer relationship management");
    private static final Set<String> MARKETING_SKILLS = Set.of(
            "marketing", "seo", "social media", "content creation");
    private static final Set<String> FACULTY_SKILLS = Set.of(
            "teaching", "research", "machine learning", "data analysis");

    private static final String[][] DOMAIN_TITLE_KEYWORDS = {
            { "NETWORKING", "network engineer", "network administrator", "network admin",
                    "network technician", "ccna", "cisco", "routing and switching", "networking", "noc engineer" },
            { "BACKEND", "backend developer", "backend engineer", "java developer", "spring boot",
                    "api developer", "server-side", "microservices" },
            { "FRONTEND", "frontend developer", "front-end", "react developer", "ui developer", "ux engineer" },
            { "DEVOPS", "devops", "site reliability", "sre", "cloud engineer", "platform engineer", "infrastructure" },
            { "FULL_STACK", "full stack", "fullstack", "software engineer", "web developer" },
            { "DATA", "data analyst", "data scientist", "data engineer", "business analyst",
                    "analytics", "bi developer", "power bi", "machine learning" },
            { "SALES", "sales executive", "business development executive", "account manager", "sales representative", "sales manager" },
            { "MARKETING", "marketing executive", "digital marketing specialist", "seo specialist", "marketing manager" },
            { "FACULTY", "technical trainer", "research associate", "lecturer", "professor", "teacher", "academic tutor" },
    };

    private static final JobDomain[] DOMAIN_TIE_PRIORITY = {
            JobDomain.NETWORKING, JobDomain.DEVOPS, JobDomain.BACKEND,
            JobDomain.FRONTEND, JobDomain.DATA, JobDomain.FULL_STACK,
            JobDomain.SALES, JobDomain.MARKETING, JobDomain.FACULTY
    };

    private AppUtil() {}

    public static String hashPassword(String p) {
        try {
            byte[] b = MessageDigest.getInstance("SHA-256").digest(p.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte x : b) sb.append(String.format("%02x", x));
            return sb.toString();
        } catch (Exception e) { throw new RuntimeException(e); }
    }

    public static boolean checkPassword(String p, String hash) { return hashPassword(p).equals(hash); }

    public static User getUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (User) s.getAttribute(SESSION_USER);
    }

    public static void setUser(HttpServletRequest req, User u) {
        jakarta.servlet.http.HttpSession old = req.getSession(false);
        if (old != null) {
            old.invalidate();
        }
        jakarta.servlet.http.HttpSession session = req.getSession(true);
        session.setAttribute(SESSION_USER, u);
    }

    public static void logout(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s != null) s.invalidate();
    }

    public static List<String> extractSkills(String text) {
        List<String> found = new ArrayList<>();
        if (text == null || text.isBlank()) return found;

        String normalized = normalizeResumeText(text);
        Set<String> detected = new LinkedHashSet<>();

        for (SkillKeywordRule skillRule : SKILL_KEYWORD_RULES) {
            if (skillRule.matches(normalized)) {
                detected.add(skillRule.canonical);
            }
        }

        found.addAll(detected);
        return normalizeSkills(found);
    }

    /** Canonical skill names for DB storage (synonym collapse). */
    public static List<String> normalizeSkills(List<String> skills) {
        LinkedHashSet<String> out = new LinkedHashSet<>();
        if (skills == null) return new ArrayList<>();
        for (String s : skills) {
            if (s == null || s.isBlank()) continue;
            out.add(canonicalSkill(s.trim()));
        }
        return new ArrayList<>(out);
    }

    public static String canonicalSkill(String skill) {
        if (skill == null || skill.isBlank()) return skill;
        String k = skill.toLowerCase(Locale.ROOT);
        if (k.contains("cisco") || k.equals("ccna")) return "CCNA";
        if (k.contains("network") && !k.contains("social")) return "Networking";
        if (k.equals("spring") || k.contains("spring boot")) return "Spring Boot";
        if (k.equals("js") || k.equals("es6")) return "JavaScript";
        if (k.equals("k8s")) return "Kubernetes";
        if (k.equals("amazon web services")) return "AWS";
        for (SkillKeywordRule r : SKILL_KEYWORD_RULES) {
            if (r.canonical.equalsIgnoreCase(skill.trim())) return r.canonical;
        }
        return skill.trim();
    }

    public static List<String> matched(List<String> user, List<String> req) {
        Set<String> u = new HashSet<>();
        for (String s : user) u.add(s.toLowerCase(Locale.ROOT));
        List<String> hit = new ArrayList<>();
        for (String r : req) {
            if (u.contains(r.toLowerCase(Locale.ROOT))) hit.add(r);
        }
        return hit;
    }

    public static boolean hasSkillOverlap(List<String> user, List<String> req) {
        return !matched(user, req).isEmpty();
    }

    private static String normalizeResumeText(String text) {
        return text.toLowerCase(Locale.ROOT).replaceAll("\\s+", " ").trim();
    }

    private static boolean keywordPresent(String text, String keyword) {
        String escaped = Pattern.quote(keyword.toLowerCase(Locale.ROOT));
        Pattern boundary = Pattern.compile("(?<![a-z0-9./-])" + escaped + "(?![a-z0-9./-])");
        return boundary.matcher(text).find();
    }

    private static SkillKeywordRule rule(String canonical, String... keywords) {
        return new SkillKeywordRule(canonical, keywords, null);
    }

    private static SkillKeywordRule ruleEx(String canonical, String excludePhrase, String... keywords) {
        return new SkillKeywordRule(canonical, keywords, new String[] { excludePhrase.toLowerCase(Locale.ROOT) });
    }

    private static final class SkillKeywordRule {
        final String canonical;
        final String[] keywords;
        final String[] excludeIfPresent;

        SkillKeywordRule(String canonical, String[] keywords, String[] excludeIfPresent) {
            this.canonical = canonical;
            this.keywords = keywords;
            this.excludeIfPresent = excludeIfPresent;
        }

        boolean matches(String normalizedText) {
            if (excludeIfPresent != null) {
                for (String ex : excludeIfPresent) {
                    if (normalizedText.contains(ex)) return false;
                }
            }
            for (String kw : keywords) {
                if (keywordPresent(normalizedText, kw)) return true;
            }
            return false;
        }
    }

    public static List<String> parseList(String csv) {
        List<String> list = new ArrayList<>();
        if (csv == null) return list;
        for (String p : csv.split("[,;]")) {
            String t = p.trim();
            if (!t.isEmpty()) list.add(t);
        }
        return list;
    }

    public static double matchPercent(List<String> user, List<String> req) {
        if (req.isEmpty()) return 0;
        Set<String> u = new HashSet<>();
        for (String s : user) u.add(s.toLowerCase(Locale.ROOT));
        int m = 0;
        for (String r : req) if (u.contains(r.toLowerCase(Locale.ROOT))) m++;
        return Math.round(m * 10000.0 / req.size()) / 100.0;
    }

    public static List<String> missing(List<String> user, List<String> req) {
        Set<String> u = new HashSet<>();
        for (String s : user) u.add(s.toLowerCase(Locale.ROOT));
        List<String> miss = new ArrayList<>();
        for (String r : req) if (!u.contains(r.toLowerCase(Locale.ROOT))) miss.add(r);
        return miss;
    }

    /**
     * ATS-style resume score (0–100) from matched skills, missing skills, and job relevance.
     * Weights: matched 40%, missing coverage 30%, job relevance 30%.
     */
    public static AtsScoreResult calculateAtsScore(List<String> userSkills, SkillGap gap, double bestJobMatchPct) {
        int matchedCount = 0;
        int missingCount = 0;
        int requiredCount = 0;

        int matchedPts;
        int missingPts;

        if (gap != null && gap.getRequiredSkills() != null && !gap.getRequiredSkills().isBlank()) {
            List<String> required = parseList(gap.getRequiredSkills());
            List<String> acquired = parseList(gap.getAcquiredSkills());
            List<String> missing = parseList(gap.getMissingSkills());
            requiredCount = required.size();
            matchedCount = acquired.size();
            missingCount = missing.size();

            if (requiredCount > 0) {
                matchedPts = (int) Math.round(40.0 * matchedCount / requiredCount);
                missingPts = (int) Math.round(30.0 * (1.0 - (double) missingCount / requiredCount));
            } else {
                matchedPts = Math.min(40, userSkills.size() * 7);
                missingPts = missingCount == 0 ? 30 : 15;
            }
        } else {
            matchedCount = userSkills.size();
            matchedPts = Math.min(40, matchedCount * 7);
            missingPts = userSkills.isEmpty() ? 0 : 25;
        }

        int jobPts = (int) Math.round(Math.min(30.0, Math.max(0, bestJobMatchPct) * 0.30));
        int total = Math.min(100, matchedPts + missingPts + jobPts);

        return new AtsScoreResult(total, matchedPts, missingPts, jobPts, matchedCount, missingCount);
    }

    public static final class AtsScoreResult {
        public final int score;
        public final int matchedPoints;
        public final int missingPoints;
        public final int jobRelevancePoints;
        public final int matchedSkillCount;
        public final int missingSkillCount;

        public AtsScoreResult(int score, int matchedPoints, int missingPoints, int jobRelevancePoints,
                              int matchedSkillCount, int missingSkillCount) {
            this.score = score;
            this.matchedPoints = matchedPoints;
            this.missingPoints = missingPoints;
            this.jobRelevancePoints = jobRelevancePoints;
            this.matchedSkillCount = matchedSkillCount;
            this.missingSkillCount = missingSkillCount;
        }
    }

    /** Chart payload for dashboard radar and progress visualizations. */
    public static SkillChartData buildSkillChartData(List<String> userSkills, SkillGap gap) {
        List<String> labels = new ArrayList<>();
        List<Integer> userScores = new ArrayList<>();
        List<Integer> requiredScores = new ArrayList<>();
        double overallMatch = 0;

        if (gap != null && gap.getRequiredSkills() != null && !gap.getRequiredSkills().isBlank()) {
            overallMatch = Math.round((100 - gap.getGapPercentage()) * 10.0) / 10.0;
            Set<String> acquired = new HashSet<>();
            for (String s : parseList(gap.getAcquiredSkills())) {
                acquired.add(s.toLowerCase(Locale.ROOT));
            }
            for (String req : parseList(gap.getRequiredSkills())) {
                labels.add(req);
                userScores.add(acquired.contains(req.toLowerCase(Locale.ROOT)) ? 100 : 0);
                requiredScores.add(100);
            }
        } else if (userSkills != null && !userSkills.isEmpty()) {
            overallMatch = 100;
            for (String skill : userSkills) {
                labels.add(skill);
                userScores.add(100);
                requiredScores.add(100);
            }
        }

        return new SkillChartData(labels, userScores, requiredScores, overallMatch);
    }

    public static final class SkillChartData {
        public final List<String> labels;
        public final List<Integer> userScores;
        public final List<Integer> requiredScores;
        public final double overallMatchPct;

        public SkillChartData(List<String> labels, List<Integer> userScores,
                              List<Integer> requiredScores, double overallMatchPct) {
            this.labels = labels;
            this.userScores = userScores;
            this.requiredScores = requiredScores;
            this.overallMatchPct = overallMatchPct;
        }
    }

    /** Infers the student's primary career domain from resume-extracted skills. */
    public static JobDomain detectUserDomain(List<String> userSkills) {
        if (userSkills == null || userSkills.isEmpty()) return JobDomain.GENERAL;
        Map<JobDomain, Integer> scores = scoreDomainsFromSkills(userSkills);
        return topDomain(scores);
    }

    /** Classifies a job into a domain using title, description, and required skills. */
    public static JobDomain classifyJobDomain(String title, String description, List<String> requiredSkills) {
        Map<JobDomain, Integer> scores = new EnumMap<>(JobDomain.class);
        for (JobDomain d : JobDomain.values()) {
            if (d != JobDomain.GENERAL) scores.put(d, 0);
        }

        if (requiredSkills != null) {
            for (String skill : requiredSkills) {
                JobDomain skillDomain = domainForSkill(skill);
                if (skillDomain != JobDomain.GENERAL) {
                    scores.merge(skillDomain, 2, Integer::sum);
                }
            }
        }

        String text = ((title == null ? "" : title) + " " + (description == null ? "" : description))
                .toLowerCase(Locale.ROOT);
        for (String[] entry : DOMAIN_TITLE_KEYWORDS) {
            JobDomain domain = JobDomain.valueOf(entry[0]);
            for (int i = 1; i < entry.length; i++) {
                if (text.contains(entry[i])) {
                    scores.merge(domain, 3, Integer::sum);
                }
            }
        }

        return topDomain(scores);
    }

    /**
     * Same-domain jobs pass when match/overlap rules are met.
     * Cross-domain only when match ≥ 70%.
     */
    public static boolean allowJobForUser(JobDomain userDomain, JobDomain jobDomain, double matchPct) {
        if (userDomain == JobDomain.GENERAL || jobDomain == JobDomain.GENERAL) {
            return matchPct >= JobRelevanceEngine.MIN_MATCH_PCT;
        }
        if (userDomain == jobDomain) return true;
        if (userDomain == JobDomain.FULL_STACK && (jobDomain == JobDomain.BACKEND || jobDomain == JobDomain.FRONTEND)) {
            return true;
        }
        if (jobDomain == JobDomain.FULL_STACK && (userDomain == JobDomain.BACKEND || userDomain == JobDomain.FRONTEND)) {
            return true;
        }
        return matchPct >= JobRelevanceEngine.CROSS_DOMAIN_MIN_PCT;
    }

    /** @deprecated use {@link #allowJobForUser} */
    public static boolean allowRecommendation(JobDomain userDomain, JobDomain jobDomain) {
        return allowJobForUser(userDomain, jobDomain, 100);
    }

    public static String searchKeywordsForDomain(JobDomain domain) {
        return switch (domain) {
            case NETWORKING -> "network engineer CCNA";
            case BACKEND -> "java spring backend developer";
            case FRONTEND -> "react frontend developer";
            case DEVOPS -> "devops aws docker";
            case DATA -> "data analyst python sql";
            case FULL_STACK -> "full stack developer";
            case SALES -> "sales executive business development client manager";
            case MARKETING -> "marketing manager digital seo brand";
            case FACULTY -> "teacher lecturer trainer scientific research associate";
            default -> "software developer";
        };
    }

    private static Map<JobDomain, Integer> scoreDomainsFromSkills(List<String> skills) {
        Map<JobDomain, Integer> scores = new EnumMap<>(JobDomain.class);
        for (JobDomain d : JobDomain.values()) {
            if (d != JobDomain.GENERAL) scores.put(d, 0);
        }
        for (String skill : skills) {
            JobDomain domain = domainForSkill(skill);
            if (domain != JobDomain.GENERAL) {
                scores.merge(domain, 1, Integer::sum);
            }
        }
        return scores;
    }

    private static JobDomain domainForSkill(String skill) {
        if (skill == null || skill.isBlank()) return JobDomain.GENERAL;
        String key = canonicalSkill(skill).toLowerCase(Locale.ROOT);
        if (NETWORKING_SKILLS.contains(key)) return JobDomain.NETWORKING;
        if (DEVOPS_SKILLS.contains(key)) return JobDomain.DEVOPS;
        if (DATA_SKILLS.contains(key)) return JobDomain.DATA;
        if (BACKEND_SKILLS.contains(key)) return JobDomain.BACKEND;
        if (FRONTEND_SKILLS.contains(key)) return JobDomain.FRONTEND;
        if (FULL_STACK_SKILLS.contains(key)) return JobDomain.FULL_STACK;
        if (SALES_SKILLS.contains(key)) return JobDomain.SALES;
        if (MARKETING_SKILLS.contains(key)) return JobDomain.MARKETING;
        if (FACULTY_SKILLS.contains(key)) return JobDomain.FACULTY;
        return JobDomain.GENERAL;
    }

    private static JobDomain topDomain(Map<JobDomain, Integer> scores) {
        JobDomain best = JobDomain.GENERAL;
        int bestScore = 0;
        for (JobDomain domain : DOMAIN_TIE_PRIORITY) {
            int score = scores.getOrDefault(domain, 0);
            if (score >= bestScore) {
                bestScore = score;
                best = domain;
            }
        }
        return bestScore > 0 ? best : JobDomain.GENERAL;
    }

}

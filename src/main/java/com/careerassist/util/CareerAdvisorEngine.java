package com.careerassist.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import com.careerassist.model.ChatResponse;
import com.careerassist.model.ChatSection;
import com.careerassist.model.JobDomain;
import com.careerassist.model.SkillGap;

/**
 * Context-aware career advisor: uses resume skills, skill gap, and career domain
 * to produce structured guidance (not simple keyword replies).
 */
public final class CareerAdvisorEngine {

    private enum Intent {
        GREETING, CAREER, ROADMAP, READINESS, SKILLS, RESUME, INTERVIEW, JOBS, HELP, OVERVIEW
    }

    public static final class AdvisorContext {
        public final List<String> skills;
        public final SkillGap latestGap;
        public final JobDomain domain;
        public final double readinessPct;
        public final boolean hasSkills;
        public final boolean hasGap;

        public AdvisorContext(List<String> skills, SkillGap latestGap, JobDomain domain) {
            this.skills = skills != null ? skills : List.of();
            this.latestGap = latestGap;
            this.domain = domain != null ? domain : JobDomain.GENERAL;
            this.hasSkills = !this.skills.isEmpty();
            this.hasGap = latestGap != null && latestGap.getTargetTitle() != null;
            this.readinessPct = hasGap
                    ? Math.round((100 - latestGap.getGapPercentage()) * 10.0) / 10.0
                    : (hasSkills ? 0 : 0);
        }
    }

    private CareerAdvisorEngine() {}

    public static ChatResponse advise(String userMessage, AdvisorContext ctx) {
        Intent intent = detectIntent(userMessage);
        ChatResponse response = switch (intent) {
            case GREETING -> buildGreeting(ctx);
            case CAREER -> buildCareerSuggestions(ctx);
            case ROADMAP -> buildLearningRoadmap(ctx);
            case READINESS -> buildJobReadiness(ctx);
            case SKILLS -> buildSkillImprovement(ctx);
            case RESUME -> buildResumeAdvice(ctx);
            case INTERVIEW -> buildInterviewAdvice(ctx);
            case JOBS -> buildJobGuidance(ctx);
            case HELP -> buildHelp(ctx);
            case OVERVIEW -> buildOverview(ctx);
        };
        response.setReply(formatPlainText(response));
        return response;
    }

    private static Intent detectIntent(String raw) {
        String m = raw == null ? "" : raw.toLowerCase(Locale.ROOT);

        if (matches(m, "hi", "hello", "hey", "good morning", "good evening")) return Intent.GREETING;
        if (matches(m, "help", "what can you", "how do you", "commands")) return Intent.HELP;

        int career = score(m, "career", "role", "path", "domain", "suggest", "direction", "become", "aspiring");
        int roadmap = score(m, "roadmap", "learn", "learning", "course", "study", "training", "curriculum", "upskill");
        int readiness = score(m, "ready", "readiness", "prepared", "qualify", "match", "fit", "eligible", "percent");
        int skills = score(m, "improve", "gap", "missing", "weak", "strengthen", "upgrade", "skill");
        int resume = score(m, "resume", "cv", "upload");
        int interview = score(m, "interview", "star", "behavioral");
        int jobs = score(m, "job", "apply", "recommend", "opening", "hiring");

        int max = Math.max(career, Math.max(roadmap, Math.max(readiness, Math.max(skills, Math.max(resume, Math.max(interview, jobs))))));
        if (max == 0) return Intent.OVERVIEW;
        if (max == career) return Intent.CAREER;
        if (max == roadmap) return Intent.ROADMAP;
        if (max == readiness) return Intent.READINESS;
        if (max == skills) return Intent.SKILLS;
        if (max == resume) return Intent.RESUME;
        if (max == interview) return Intent.INTERVIEW;
        return Intent.JOBS;
    }

    private static int score(String m, String... keywords) {
        int s = 0;
        for (String k : keywords) {
            if (m.contains(k)) s += k.length() > 4 ? 2 : 1;
        }
        return s;
    }

    private static boolean matches(String m, String... phrases) {
        for (String p : phrases) {
            if (m.contains(p)) return true;
        }
        return false;
    }

    private static ChatResponse buildGreeting(AdvisorContext ctx) {
        ChatResponse r = base("GREETING", "Welcome to your career advisor");
        if (!ctx.hasSkills) {
            r.setSummary("Upload your resume first so I can personalize guidance to your skills and goals.");
            r.getHighlights().add("Upload resume → Skills extracted automatically");
            r.getHighlights().add("Run Skill Gap Analysis on a target role");
        } else {
            r.setSummary("I have your skill profile loaded. Ask about careers, learning paths, job readiness, or skill gaps.");
            r.getHighlights().add("Skills on file: " + String.join(", ", ctx.skills));
            r.getHighlights().add("Domain: " + formatDomain(ctx.domain));
            if (ctx.hasGap) {
                r.getHighlights().add(String.format("%.0f%% ready for %s", ctx.readinessPct, ctx.latestGap.getTargetTitle()));
            }
        }
        r.getSections().add(new ChatSection("Quick prompts", List.of(
                "What careers fit my skills?",
                "Build my learning roadmap",
                "Am I job-ready for my target role?",
                "How can I improve my weak skills?")));
        return r;
    }

    private static ChatResponse buildHelp(AdvisorContext ctx) {
        ChatResponse r = base("HELP", "How I can help");
        r.setSummary("I'm your AI career advisor. I use your resume skills and latest gap analysis to give tailored answers.");
        r.getSections().add(new ChatSection("Topics", List.of(
                "Career suggestions — roles aligned to your domain and skills",
                "Learning roadmap — staged plan for missing or priority skills",
                "Job readiness — match % vs a target role from gap analysis",
                "Skill improvement — focused tips on gaps and next steps",
                "Resume & interview — practical prep using your profile")));
        if (ctx.hasSkills) {
            r.getSections().add(new ChatSection("Your context", "Skills: " + String.join(", ", ctx.skills)));
        }
        return r;
    }

    private static ChatResponse buildOverview(AdvisorContext ctx) {
        ChatResponse r = base("OVERVIEW", "Your career snapshot");
        if (!ctx.hasSkills) {
            r.setSummary("No resume skills found yet. Upload a resume to unlock personalized advice.");
            r.getSections().add(new ChatSection("Next step", "Go to Dashboard → Upload resume (PDF or TXT)."));
            return r;
        }

        r.setSummary(String.format("Based on %d skills in %s, here is a quick snapshot.", ctx.skills.size(), formatDomain(ctx.domain)));
        r.getHighlights().add("Top skills: " + String.join(", ", ctx.skills));

        if (ctx.hasGap) {
            r.getHighlights().add(String.format("%.0f%% ready for %s", ctx.readinessPct, ctx.latestGap.getTargetTitle()));
            if (ctx.latestGap.getMissingSkills() != null && !ctx.latestGap.getMissingSkills().isBlank()) {
                r.getHighlights().add("Focus areas: " + ctx.latestGap.getMissingSkills());
            }
        } else {
            r.getHighlights().add("Run Skill Gap Analysis to measure readiness for a specific role.");
        }

        r.getSections().add(new ChatSection("Suggested actions", List.of(
                "Ask: \"What careers fit my skills?\"",
                "Ask: \"Build my learning roadmap\"",
                "Visit Job Recommendations for domain-matched roles")));
        return r;
    }

    private static ChatResponse buildCareerSuggestions(AdvisorContext ctx) {
        ChatResponse r = base("CAREER", "Career suggestions");
        if (!ctx.hasSkills) {
            r.setSummary("Upload your resume so I can map skills to realistic career paths.");
            return r;
        }

        List<String> roles = suggestedRoles(ctx);
        r.setSummary(String.format("Your profile aligns with the %s domain. These roles fit your current skills:",
                formatDomain(ctx.domain)));
        r.getSections().add(new ChatSection("Recommended roles", roles));
        r.getSections().add(new ChatSection("Why this fits",
                "Detected skills: " + String.join(", ", ctx.skills) + ". "
                        + "Explore matching jobs under Recommendations (filtered to your domain)."));

        if (ctx.hasGap && ctx.latestGap.getTargetTitle() != null) {
            r.getSections().add(new ChatSection("Target role progress",
                    String.format("You analyzed %s — %.0f%% skill alignment. Closing gaps opens more senior options.",
                            ctx.latestGap.getTargetTitle(), ctx.readinessPct)));
        }
        return r;
    }

    private static List<String> suggestedRoles(AdvisorContext ctx) {
        return switch (ctx.domain) {
            case NETWORKING -> List.of(
                    "Network Engineer", "NOC Engineer", "Network Administrator",
                    "CCNA / Routing & Switching Specialist", "Linux Network Technician");
            case DATA -> List.of(
                    "Data Analyst", "Business Intelligence Analyst", "Junior Data Scientist",
                    "Reporting Analyst", "SQL / Analytics Developer");
            case FULL_STACK -> List.of(
                    "Java Developer", "Full Stack Developer", "Backend Engineer",
                    "React / Frontend Developer", "Software Engineer (Web)");
            case SALES -> List.of(
                    "Sales Executive", "Business Development Executive", "Account Manager",
                    "Sales Representative", "Corporate Accounts Specialist");
            case MARKETING -> List.of(
                    "Marketing Executive", "Digital Marketing Specialist", "SEO Specialist",
                    "Social Media Manager", "Product Marketing Coordinator");
            case FACULTY -> List.of(
                    "Technical Trainer", "Research Associate", "Academic Tutor",
                    "Lecturer", "Instructional Designer");
            default -> List.of(
                    "Technology Associate", "Junior Software Developer",
                    "IT Support Specialist", "Technical Analyst");
        };
    }

    private static ChatResponse buildLearningRoadmap(AdvisorContext ctx) {
        ChatResponse r = base("ROADMAP", "Learning roadmap");
        List<String> focus = new ArrayList<>();

        if (ctx.hasGap && ctx.latestGap.getMissingSkills() != null && !ctx.latestGap.getMissingSkills().isBlank()) {
            focus.addAll(AppUtil.parseList(ctx.latestGap.getMissingSkills()));
            r.setSummary("Staged plan to close gaps for " + ctx.latestGap.getTargetTitle() + ":");
        } else if (ctx.hasSkills) {
            focus.addAll(ctx.skills);
            r.setSummary("Progressive upskilling plan based on your current resume skills:");
        } else {
            r.setSummary("Upload a resume or run gap analysis to generate a targeted roadmap.");
            r.getSections().add(new ChatSection("Next step", "Dashboard → Skill Gap Analysis → Generate Learning Path."));
            return r;
        }

        for (String skill : focus) {
            List<String> stages = new ArrayList<>();
            for (String level : LearningResourceCatalog.LEVEL_STAGES) {
                stages.add(level + " — curated " + skill + " resources");
            }
            r.getSections().add(new ChatSection(skill, stages));
        }

        r.getHighlights().add("Use Learning Path page to open curated links per skill & stage.");
        r.getHighlights().add("Order: BEGINNER → INTERMEDIATE → ADVANCED → PROJECTS");
        return r;
    }

    private static ChatResponse buildJobReadiness(AdvisorContext ctx) {
        ChatResponse r = base("READINESS", "Job readiness feedback");
        if (!ctx.hasGap) {
            r.setSummary("No skill gap analysis on file. Pick a job or enter required skills to measure readiness.");
            r.getSections().add(new ChatSection("How to measure", List.of(
                    "Student → Skill Gap Analysis → select a job",
                    "Re-run after uploading an updated resume",
                    "Then ask again for readiness feedback")));
            if (ctx.hasSkills) {
                r.getHighlights().add("Current skills: " + String.join(", ", ctx.skills));
            }
            return r;
        }

        SkillGap g = ctx.latestGap;
        double match = ctx.readinessPct;
        String verdict = match >= 75 ? "Strong fit — polish gaps and apply."
                : match >= 50 ? "Moderate fit — prioritize missing skills before applying."
                : "Early stage — build fundamentals in missing areas first.";

        r.setSummary(String.format("%.0f%% ready for %s. %s", match, g.getTargetTitle(), verdict));
        r.getHighlights().add("Acquired: " + (blank(g.getAcquiredSkills()) ? "—" : g.getAcquiredSkills()));
        r.getHighlights().add("Missing: " + (blank(g.getMissingSkills()) ? "None — great job!" : g.getMissingSkills()));
        r.getHighlights().add("Gap to close: " + String.format("%.0f%%", g.getGapPercentage()));

        r.getSections().add(new ChatSection("Readiness checklist", List.of(
                match >= 60 ? "✓ Core skills largely in place" : "○ Strengthen core required skills",
                blank(g.getMissingSkills()) ? "✓ No critical missing skills" : "○ Complete learning path for missing skills",
                "○ Practice 1–2 portfolio or lab projects",
                "○ Tailor resume bullets to " + g.getTargetTitle())));
        return r;
    }

    private static ChatResponse buildSkillImprovement(AdvisorContext ctx) {
        ChatResponse r = base("SKILLS", "Skill improvement tips");
        if (!ctx.hasSkills) {
            r.setSummary("Upload your resume to identify strengths and improvement areas.");
            return r;
        }

        if (ctx.hasGap && !blank(ctx.latestGap.getMissingSkills())) {
            r.setSummary("Priority skills to improve for " + ctx.latestGap.getTargetTitle() + ":");
            for (String skill : AppUtil.parseList(ctx.latestGap.getMissingSkills())) {
                r.getSections().add(new ChatSection(skill, improvementTips(skill, ctx.domain)));
            }
        } else {
            r.setSummary("Maintain momentum on your current stack and add depth:");
            for (String skill : ctx.skills) {
                r.getSections().add(new ChatSection(skill, improvementTips(skill, ctx.domain)));
            }
        }

        r.getHighlights().add("Generate Learning Path for hands-on resources per skill.");
        return r;
    }

    private static List<String> improvementTips(String skill, JobDomain domain) {
        String key = skill.toLowerCase(Locale.ROOT);
        if (Set.of("ccna", "networking", "routing", "switching", "linux").contains(key)) {
            return List.of(
                    "Lab on Packet Tracer / GNS3 weekly",
                    "Practice subnetting and VLAN scenarios",
                    "Pair with CCNA-style revision quizzes");
        }
        if (Set.of("java", "spring boot", "spring").contains(key)) {
            return List.of(
                    "Build one REST API project with Spring Boot",
                    "Add unit tests and GitHub README",
                    "Review OOP, collections, and exception handling");
        }
        if (Set.of("sql", "python", "excel", "power bi").contains(key)) {
            return List.of(
                    "Complete analytics project with real dataset",
                    "Document insights in a one-page report",
                    "Practice joins, aggregations, and visualization");
        }
        if (Set.of("react", "javascript", "node.js", "html", "css").contains(key)) {
            return List.of(
                    "Ship a small frontend project to GitHub",
                    "Focus on responsive layout and component reuse",
                    "Add one feature using async API calls");
        }
        if (Set.of("sales", "lead generation", "crm", "negotiation", "customer relationship management").contains(key)) {
            return List.of(
                    "Practice elevator pitches and cold calling scenarios",
                    "Complete Salesforce Trailhead or HubSpot certifications",
                    "Do a role-play negotiation exercise weekly");
        }
        if (Set.of("marketing", "seo", "social media", "content creation").contains(key)) {
            return List.of(
                    "Perform an SEO audit on a small local business website",
                    "Create a sample content calendar and social media ad mockups",
                    "Track conversion metrics and Google Analytics reports");
        }
        if (Set.of("teaching", "research", "machine learning", "data analysis").contains(key)) {
            return List.of(
                    "Design a 1-hour lesson plan or lecture presentation",
                    "Read 2 recent scientific or academic research papers in your field",
                    "Build a machine learning pipeline or statistical analysis notebook");
        }
        return List.of(
                "Follow BEGINNER → PROJECTS stages in Learning Path",
                "Apply skill in a mini project within 2 weeks",
                "Teach concept to a peer to solidify understanding");
    }

    private static ChatResponse buildResumeAdvice(AdvisorContext ctx) {
        ChatResponse r = base("RESUME", "Resume guidance");
        r.setSummary("Tailor your resume to your " + formatDomain(ctx.domain) + " target roles.");
        r.getSections().add(new ChatSection("Structure", List.of(
                "Lead with a 2-line summary mentioning your top 3 skills",
                "Use action verbs: Built, Designed, Implemented, Optimized",
                "Quantify impact (%, time saved, users served)")));
        if (ctx.hasSkills) {
            r.getSections().add(new ChatSection("Skills to highlight",
                    "Ensure these appear in a dedicated Skills section: " + String.join(", ", ctx.skills)));
        }
        if (ctx.hasGap && !blank(ctx.latestGap.getMissingSkills())) {
            r.getSections().add(new ChatSection("Gap awareness",
                    "Do not claim missing skills yet: " + ctx.latestGap.getMissingSkills()
                            + ". List them after completing your learning path."));
        }
        return r;
    }

    private static ChatResponse buildInterviewAdvice(AdvisorContext ctx) {
        ChatResponse r = base("INTERVIEW", "Interview preparation");
        r.setSummary("Prepare stories that prove your technical skills and role fit.");
        r.getSections().add(new ChatSection("STAR method", List.of(
                "Situation — context of the project or challenge",
                "Task — your responsibility",
                "Action — tools/skills you used (tie to your stack)",
                "Result — measurable outcome")));
        if (ctx.hasSkills) {
            r.getSections().add(new ChatSection("Skills to reference in answers",
                    String.join(", ", ctx.skills)));
        }
        if (ctx.hasGap) {
            r.getSections().add(new ChatSection("For target role: " + ctx.latestGap.getTargetTitle(), List.of(
                    "Prepare 1 example per acquired skill",
                    "Honestly address learning plan for: " + nullSafe(ctx.latestGap.getMissingSkills(), "remaining gaps"))));
        }
        return r;
    }

    private static ChatResponse buildJobGuidance(AdvisorContext ctx) {
        ChatResponse r = base("JOBS", "Job search guidance");
        if (!ctx.hasSkills) {
            r.setSummary("Upload resume first — recommendations are filtered to your career domain.");
            return r;
        }
        r.setSummary("Use domain-aware recommendations (" + formatDomain(ctx.domain) + ") to avoid cross-domain matches.");
        r.getSections().add(new ChatSection("Workflow", List.of(
                "Dashboard → review matched jobs & match %",
                "Recommendations → apply when match ≥ 60%",
                "Skill Gap → refresh analysis before each batch of applications")));
        if (ctx.hasGap) {
            r.getHighlights().add(String.format("Target %s: %.0f%% ready — improve missing skills before mass applying.",
                    ctx.latestGap.getTargetTitle(), ctx.readinessPct));
        }
        return r;
    }

    private static ChatResponse base(String type, String title) {
        ChatResponse r = new ChatResponse();
        r.setType(type);
        r.setTitle(title);
        return r;
    }

    private static String formatDomain(JobDomain d) {
        return d.name().replace('_', ' ');
    }

    private static boolean blank(String s) {
        return s == null || s.isBlank();
    }

    private static String nullSafe(String s, String fallback) {
        return blank(s) ? fallback : s;
    }

    private static String formatPlainText(ChatResponse r) {
        StringBuilder sb = new StringBuilder();
        sb.append(r.getTitle()).append("\n\n");
        if (r.getSummary() != null) sb.append(r.getSummary()).append("\n\n");
        for (String h : r.getHighlights()) {
            sb.append("• ").append(h).append("\n");
        }
        if (!r.getHighlights().isEmpty()) sb.append("\n");
        for (ChatSection sec : r.getSections()) {
            sb.append(sec.getHeading()).append("\n");
            if (sec.getBody() != null && !sec.getBody().isBlank()) {
                sb.append(sec.getBody()).append("\n");
            }
            for (String item : sec.getItems()) {
                sb.append("  - ").append(item).append("\n");
            }
            sb.append("\n");
        }
        return sb.toString().trim();
    }
}

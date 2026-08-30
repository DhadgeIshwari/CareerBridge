package com.careerassist.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.careerassist.dao.CareerDAO;
import com.careerassist.model.CareerAIProfile;
import com.careerassist.model.CareerContext;
import com.careerassist.model.ChatResponse;
import com.careerassist.model.ChatSection;
import com.careerassist.model.JobFeedItem;
import com.careerassist.model.SkillGap;
import com.careerassist.util.AppUtil;
import com.careerassist.util.JobRelevanceEngine;

/**
 * Data-driven career mentor — responses built from resume, skill gap, selected role, jobs, and learning paths.
 */
public class CareerAIService {

    private enum ResponseKind {
        SKILL_ADVICE, JOB_RECOMMENDATION, LEARNING_GUIDANCE, OVERVIEW,
        NETWORKING_ADVICE, CERTIFICATION_ADVICE, RESUME_ANALYSIS, GREETING
    }

    private final CareerContextService contextService = new CareerContextService();
    private final CareerDAO dao = new CareerDAO();

    public CareerAIProfile buildProfile(int userId, jakarta.servlet.http.HttpServletRequest req) throws Exception {
        CareerAIProfile p = new CareerAIProfile();
        CareerContext ctx = contextService.getContext(req, userId);

        p.setResumeSkills(dao.getUserSkills(userId));
        p.setCareerContext(ctx);
        p.setTargetRoleTitle(ctx.getTargetTitle());
        p.setRoleDomainLabel(JobRelevanceEngine.formatDomain(ctx.getRoleDomainEnum()));
        p.setReadinessPct(ctx.getReadinessPct());

        SkillGap gap = contextService.getSkillGapForContext(userId, ctx);
        p.setSkillGap(gap);
        if (gap != null && gap.getMissingSkills() != null) {
            p.setMissingSkills(AppUtil.parseList(gap.getMissingSkills()));
        }

        List<JobFeedItem> feed = contextService.getJobFeed(userId, ctx);
        p.setMatchedJobs(feed.size() > 5 ? feed.subList(0, 5) : feed);

        for (var hub : contextService.getLearningHubs(userId, ctx)) {
            p.getLearningSkills().add(hub.getSkillName());
        }

        return p;
    }

    public ChatResponse advise(String message, CareerAIProfile profile) {
        if (message == null || message.isBlank()) {
            return emptyPrompt();
        }

        ResponseKind kind = classify(message);
        ChatResponse r = switch (kind) {
            case GREETING             -> greetingResponse(message);
            case SKILL_ADVICE         -> skillAdvice(profile, message);
            case JOB_RECOMMENDATION  -> jobRecommendation(profile, message);
            case LEARNING_GUIDANCE   -> learningGuidance(profile);
            case NETWORKING_ADVICE   -> networkingAdvice(profile);
            case CERTIFICATION_ADVICE-> certificationAdvice(profile);
            case RESUME_ANALYSIS     -> resumeAnalysis(profile);
            default                  -> overview(profile);
        };
        r.setReply(formatReply(r));
        return r;
    }

    private ResponseKind classify(String raw) {
        String m = raw.trim().toLowerCase(Locale.ROOT);
        // Greeting / social phrases — handle before any career keyword checks
        if (isGreeting(m)) return ResponseKind.GREETING;
        if (contains(m, "network", "connect", "linkedin", "referral", "outreach", "community")) {
            return ResponseKind.NETWORKING_ADVICE;
        }
        if (contains(m, "cert", "certification", "credential", "exam")) {
            return ResponseKind.CERTIFICATION_ADVICE;
        }
        if (contains(m, "resume", "extracted", "skills in my resume", "missing in my resume", "ats", "score")) {
            return ResponseKind.RESUME_ANALYSIS;
        }
        if (contains(m, "learn next", "what should i learn", "weak skill", "improve", "gap")) {
            return ResponseKind.SKILL_ADVICE;
        }
        if (contains(m, "roadmap", "learning path", "course", "study", "practice hub", "resource")) {
            return ResponseKind.LEARNING_GUIDANCE;
        }
        if (contains(m, "job", "apply", "recommend", "match", "ready", "fit", "opening")) {
            return ResponseKind.JOB_RECOMMENDATION;
        }
        if (contains(m, "skill", "gap")) {
            return ResponseKind.SKILL_ADVICE;
        }
        return ResponseKind.OVERVIEW;
    }

    /** Returns true for pure greetings, farewells, and gratitude phrases. */
    private boolean isGreeting(String m) {
        // Exact short greetings
        if (m.matches("^(hi|hey|hello|howdy|hiya|yo|sup|greetings)[!.?\\s]*$")) return true;
        // "how are you" variants
        if (m.contains("how are you") || m.contains("how r u") || m.contains("how do you do")) return true;
        // Gratitude
        if (m.matches("^(thank you|thanks|thank u|thx|ty|cheers)[!.?\\s]*$")) return true;
        // Farewells
        if (m.matches("^(bye|goodbye|see you|cya|take care)[!.?\\s]*$")) return true;
        return false;
    }

    /** Warm conversational reply for greetings — no career data lookup. */
    private ChatResponse greetingResponse(String m) {
        ChatResponse r = new ChatResponse();
        r.setType("GREETING");
        boolean isThanks = m.contains("thank") || m.contains("thx") || m.contains("ty") || m.contains("cheers");
        boolean isBye    = m.contains("bye") || m.contains("goodbye") || m.contains("see you") || m.contains("cya");
        boolean isHowAreYou = m.contains("how are you") || m.contains("how r u") || m.contains("how do you do");

        if (isThanks) {
            r.setTitle("You're Welcome! 😊");
            r.setSummary("Feel free to ask me anything about your resume, skills, jobs, or career growth. I'm here whenever you need guidance!");
        } else if (isBye) {
            r.setTitle("Goodbye! 👋");
            r.setSummary("Good luck on your career journey! Come back anytime you need help with your resume, skills, or job search.");
        } else if (isHowAreYou) {
            r.setTitle("I'm doing great! 😊");
            r.setSummary("I'm here to help you with your career journey and job preparation. What would you like help with today?");
            r.setHighlights(new ArrayList<>(java.util.Arrays.asList(
                "Analyze my resume & ATS score",
                "Find jobs matching my profile",
                "Build a learning path",
                "Identify skill gaps"
            )));
        } else {
            r.setTitle("Hi there! 👋");
            r.setSummary("I'm your Career AI Assistant. I can help you with resume analysis, ATS improvement, learning paths, and job recommendations.");
            r.setHighlights(new ArrayList<>(java.util.Arrays.asList(
                "What jobs match my profile?",
                "Why is my ATS score low?",
                "What should I learn next?",
                "How can I improve my resume?"
            )));
        }
        return r;
    }

    private ChatResponse networkingAdvice(CareerAIProfile p) {
        ChatResponse r = new ChatResponse();
        r.setType("NETWORKING_ADVICE");
        r.setTitle("Networking & Career Strategy");
        r.setSummary("Building professional connections is crucial in today's job market. Here is a domain-specific strategy for " + safe(p.getTargetRoleTitle()) + ":");

        var domain = p.getCareerContext() != null ? p.getCareerContext().getRoleDomainEnum() : com.careerassist.model.JobDomain.GENERAL;
        if (domain == null) domain = com.careerassist.model.JobDomain.GENERAL;
        switch (domain) {
            case NETWORKING -> {
                r.getHighlights().add("• Cisco Communities: Engage on the Cisco Learning Network & forums.");
                r.getHighlights().add("• Network Forums: Participate in Reddit's r/networking and r/ccna.");
                r.getHighlights().add("• Packet Tracer Projects: Share custom Packet Tracer lab designs on GitHub.");
            }
            case SALES -> {
                r.getHighlights().add("• Sales Communities: Join National Association of Sales Professionals (NASP).");
                r.getHighlights().add("• LinkedIn Social Selling: Share tips on B2B client acquisition and CRM strategies.");
                r.getHighlights().add("• Industry Conferences: Attend local business development and sales networking events.");
            }
            case MARKETING -> {
                r.getHighlights().add("• AMA Association: Participate in American Marketing Association communities.");
                r.getHighlights().add("• Digital Marketing Portfolios: Share growth marketing case studies on LinkedIn/Medium.");
                r.getHighlights().add("• Marketing Forums: Engage in r/digitalmarketing and SEO subreddits.");
            }
            case FACULTY -> {
                r.getHighlights().add("• Academic Networks: Register and connect on ResearchGate and Google Scholar.");
                r.getHighlights().add("• Teacher Forums: Join global educator communities and pedagogy groups.");
                r.getHighlights().add("• Seminars & Workshops: Attend and present papers at academic conferences.");
            }
            default -> {
                r.getHighlights().add("• GitHub & Open Source: Contribute to active repositories. Put your projects out there!");
                r.getHighlights().add("• LinkedIn Outreach: Connect with tech leads in " + safe(p.getRoleDomainLabel()) + " at target companies.");
                r.getHighlights().add("• Tech Meetups: Attend local tech meetups and developer conferences.");
            }
        }
        r.getSections().add(new ChatSection("Quick Action Plan", List.of(
            "Update your LinkedIn headline to specify your focus: '" + safe(p.getTargetRoleTitle()) + " | Passionate about " + safe(p.getRoleDomainLabel()) + "'",
            "Send personalized connection requests to 5 developers in your field weekly."
        )));
        return r;
    }

    private ChatResponse certificationAdvice(CareerAIProfile p) {
        ChatResponse r = new ChatResponse();
        r.setType("CERTIFICATION_ADVICE");
        r.setTitle("Recommended Certifications");
        r.setSummary("Industry credentials validate your skill set to recruiters. For a " + safe(p.getTargetRoleTitle()) + " role, consider these:");

        var domain = p.getCareerContext() != null ? p.getCareerContext().getRoleDomainEnum() : com.careerassist.model.JobDomain.GENERAL;
        if (domain == null) domain = com.careerassist.model.JobDomain.GENERAL;
        switch (domain) {
            case NETWORKING -> {
                r.getHighlights().add("• Cisco CCNA (200-301): Essential foundational cert for all networking roles.");
                r.getHighlights().add("• Cisco CCNP Enterprise: Advanced certification for routing & switching expertise.");
                r.getHighlights().add("• CompTIA Network+: Good vendor-neutral alternative for network concepts.");
            }
            case DEVOPS -> {
                r.getHighlights().add("• AWS Certified Cloud Practitioner / Solutions Architect Associate.");
                r.getHighlights().add("• Certified Kubernetes Administrator (CKA): High value for container orchestration.");
                r.getHighlights().add("• HashiCorp Certified: Terraform Associate for infrastructure as code.");
            }
            case DATA -> {
                r.getHighlights().add("• Microsoft Certified: Power BI Data Analyst Associate.");
                r.getHighlights().add("• Google Data Analytics Professional Certificate.");
                r.getHighlights().add("• Databricks Certified Associate Developer / Data Engineer.");
            }
            case FRONTEND -> {
                r.getHighlights().add("• Meta Front-End Developer Professional Certificate (Coursera).");
                r.getHighlights().add("• W3Schools Frontend Certifications (HTML, CSS, JavaScript).");
            }
            case SALES -> {
                r.getHighlights().add("• Salesforce Certified Administrator: Validate CRM and sales admin capabilities.");
                r.getHighlights().add("• Certified Sales Professional (CSP): Demonstrates core sales knowledge.");
                r.getHighlights().add("• HubSpot Sales Software Certification.");
            }
            case MARKETING -> {
                r.getHighlights().add("• Google Analytics Certification (GA4): Essential for digital marketing analytics.");
                r.getHighlights().add("• HubSpot Inbound Marketing Certification.");
                r.getHighlights().add("• Meta Certified Digital Marketing Associate.");
            }
            case FACULTY -> {
                r.getHighlights().add("• Certified Online Instructor (COI): Best for digital teaching methods.");
                r.getHighlights().add("• AWS Academy Accredited Educator: Excellent credentials for technical trainers.");
                r.getHighlights().add("• Harvard Higher Education Teaching Certificate.");
            }
            default -> {
                r.getHighlights().add("• Oracle Certified Professional: Java SE Developer.");
                r.getHighlights().add("• Spring Certified Professional.");
                r.getHighlights().add("• AWS Certified Solutions Architect.");
            }
        }
        r.getSections().add(new ChatSection("Why Certifications Matter", List.of(
            "They pass through applicant tracking systems (ATS) searching for specific credential codes.",
            "They show dedication to continuous learning and self-improvement."
        )));
        return r;
    }

    private ChatResponse resumeAnalysis(CareerAIProfile p) {
        ChatResponse r = new ChatResponse();
        r.setType("RESUME_ANALYSIS");
        r.setTitle("Resume Skill Analysis & ATS Feedback");
        if (!p.hasResume()) {
            r.setSummary("Upload a resume to analyze your skills and get actionable ATS suggestions.");
            return r;
        }

        r.setSummary("Here is an overview of how your resume aligns with " + safe(p.getTargetRoleTitle()) + " requirements:");
        r.getHighlights().add("• Extracted skills (" + p.getResumeSkills().size() + "): " + String.join(", ", limitList(p.getResumeSkills(), 8)));
        r.getHighlights().add("• Target readiness score: " + fmt(p.getReadinessPct()) + "%");

        if (p.getMissingSkills().isEmpty()) {
            r.getHighlights().add("• Perfect fit! Your resume contains all the essential skills required for this role.");
        } else {
            r.getHighlights().add("• Missing critical keywords: " + String.join(", ", limitList(p.getMissingSkills(), 5)));
            r.getSections().add(new ChatSection("ATS Improvement Tips", List.of(
                "Integrate missing keywords: '" + String.join(", ", limitList(p.getMissingSkills(), 3)) + "' naturally into your project descriptions.",
                "Ensure your contact details and links (GitHub, LinkedIn) are clearly readable in text format.",
                "Avoid complex columns or charts in your PDF format, as some ATS parsers ignore them."
            )));
        }
        return r;
    }

    private ChatResponse skillAdvice(CareerAIProfile p, String question) {
        ChatResponse r = new ChatResponse();
        r.setType("SKILL_ADVICE");

        if (!p.hasResume()) {
            r.setTitle("Upload resume first");
            r.setSummary("I need your extracted resume skills to give personalized skill advice.");
            r.getHighlights().add("Go to Dashboard → Upload resume (PDF/TXT)");
            return r;
        }

        r.setTitle("Skill advice for " + safe(p.getTargetRoleTitle()));
        SkillGap gap = p.getSkillGap();

        if (contains(question.toLowerCase(Locale.ROOT), "missing", "which skill", "gap")) {
            if (p.getMissingSkills().isEmpty()) {
                r.setSummary("For " + safe(p.getTargetRoleTitle()) + ", your resume already covers the core required skills.");
                r.getHighlights().add("Readiness: " + fmt(p.getReadinessPct()) + "%");
                r.getHighlights().add("Resume skills: " + String.join(", ", p.getResumeSkills()));
            } else {
                r.setSummary("Skills missing for your selected role (" + safe(p.getTargetRoleTitle()) + "):");
                for (String sk : p.getMissingSkills()) {
                    r.getHighlights().add("• " + sk);
                }
                r.getSections().add(new ChatSection("Why this matters",
                        List.of("Recruiters filter on these keywords for " + safe(p.getRoleDomainLabel()) + " roles.",
                                "Closing these gaps should raise your match score above "
                                        + (int) CareerContextService.ROLE_FEED_MIN_MATCH + "%.")));
            }
        } else if (contains(question.toLowerCase(Locale.ROOT), "shortlist", "not getting", "reject")) {
            r.setSummary(buildShortlistExplanation(p));
            r.getHighlights().add("Selected role: " + safe(p.getTargetRoleTitle()));
            r.getHighlights().add("Current readiness: " + fmt(p.getReadinessPct()) + "%");
            if (!p.getMissingSkills().isEmpty()) {
                r.getHighlights().add("Top gaps: " + String.join(", ", limitList(p.getMissingSkills(), 4)));
            }
        } else {
            r.setSummary("Based on your resume vs " + safe(p.getTargetRoleTitle()) + ":");
            if (gap != null) {
                r.getHighlights().add("Acquired: " + nullToDash(gap.getAcquiredSkills()));
                r.getHighlights().add("Still needed: " + nullToDash(gap.getMissingSkills()));
            }
            r.getSections().add(new ChatSection("Next step",
                    List.of("Open Practice Hub → regenerate learning path for missing skills.",
                            "Practice labs daily for your weakest missing skill.")));
        }
        return r;
    }

    private ChatResponse jobRecommendation(CareerAIProfile p, String question) {
        ChatResponse r = new ChatResponse();
        r.setType("JOB_RECOMMENDATION");
        r.setTitle("Job match insights");

        if (!p.hasResume()) {
            r.setSummary("Upload a resume so I can explain job matches against real listings.");
            return r;
        }

        r.setSummary("Job feed is filtered to **" + safe(p.getRoleDomainLabel()) + "** roles with ≥"
                + (int) CareerContextService.ROLE_FEED_MIN_MATCH + "% skill match for **"
                + safe(p.getTargetRoleTitle()) + "**.");

        r.getHighlights().add("Your readiness for this role: " + fmt(p.getReadinessPct()) + "%");

        if (p.getMatchedJobs().isEmpty()) {
            r.getHighlights().add("No listings passed the filter yet — refresh jobs after selecting your target role.");
            r.getSections().add(new ChatSection("How to improve matches", List.of(
                    "Lower gaps: " + (p.getMissingSkills().isEmpty() ? "already strong" : String.join(", ", p.getMissingSkills())),
                    "Switch target role from the role selector if you are exploring another domain.")));
        } else {
            r.getSections().add(new ChatSection("Top matches in your feed", jobLines(p.getMatchedJobs())));
            if (!p.getMissingSkills().isEmpty()) {
                r.getSections().add(new ChatSection("Before you apply",
                        List.of("Upskill on: " + String.join(", ", limitList(p.getMissingSkills(), 3)),
                                "Tailor resume bullets to mirror each job's required skills.")));
            }
        }

        if (contains(question.toLowerCase(Locale.ROOT), "why", "not", "shortlist")) {
            r.getSections().add(0, new ChatSection("Shortlisting factors",
                    List.of(buildShortlistExplanation(p))));
        }
        return r;
    }

    private ChatResponse learningGuidance(CareerAIProfile p) {
        ChatResponse r = new ChatResponse();
        r.setType("LEARNING_GUIDANCE");
        r.setTitle("Learning path guidance");

        if (!p.hasGap() || p.getMissingSkills().isEmpty()) {
            r.setSummary("You have few gaps for " + safe(p.getTargetRoleTitle())
                    + ". Deepen existing skills via Practice Hub labs.");
            r.getHighlights().add("Resume skills: " + String.join(", ", limitList(p.getResumeSkills(), 6)));
            return r;
        }

        r.setSummary("Recommended learning order for **" + safe(p.getTargetRoleTitle()) + "** (missing skills first):");
        int n = 1;
        for (String sk : limitList(p.getMissingSkills(), 6)) {
            r.getHighlights().add(n++ + ". " + sk + " — Learn / Read / Practice sections in Practice Hub");
        }

        r.getSections().add(new ChatSection("How paths are built", List.of(
                "Only skills missing for your **selected job role** are included.",
                "Resources are filtered to the " + safe(p.getRoleDomainLabel()) + " domain.",
                "Each skill has curated videos, docs, and practice platforms (LeetCode, HTB, etc.).")));

        if (!p.getLearningSkills().isEmpty()) {
            r.getSections().add(new ChatSection("Active in your hub",
                    List.of("Paths generated for: " + String.join(", ", p.getLearningSkills()))));
        } else {
            r.getSections().add(new ChatSection("Action",
                    List.of("Click Regenerate on Practice Hub after changing your target role.")));
        }
        return r;
    }

    private ChatResponse overview(CareerAIProfile p) {
        ChatResponse r = new ChatResponse();
        r.setType("OVERVIEW");
        r.setTitle("Your career snapshot");

        if (!p.hasResume()) {
            r.setSummary("Upload your resume, pick a target role, and I will personalize all guidance.");
            return r;
        }

        r.setSummary("Live profile for **" + safe(p.getTargetRoleTitle()) + "** (" + safe(p.getRoleDomainLabel()) + ").");
        r.getHighlights().add("Resume skills (" + p.getResumeSkills().size() + "): "
                + String.join(", ", limitList(p.getResumeSkills(), 8)));
        r.getHighlights().add("Role readiness: " + fmt(p.getReadinessPct()) + "%");
        if (!p.getMissingSkills().isEmpty()) {
            r.getHighlights().add("Priority gaps: " + String.join(", ", limitList(p.getMissingSkills(), 5)));
        }
        r.getHighlights().add("Jobs in feed (≥" + (int) CareerContextService.ROLE_FEED_MIN_MATCH + "% match): "
                + p.getMatchedJobs().size());

        r.getSections().add(new ChatSection("Ask me", List.of(
                "What should I learn next?",
                "Why am I not getting shortlisted?",
                "Which skill is missing for this job?")));
        return r;
    }

    private String buildShortlistExplanation(CareerAIProfile p) {
        if (p.getReadinessPct() < 50) {
            return "Your match for " + safe(p.getTargetRoleTitle()) + " is "
                    + fmt(p.getReadinessPct()) + "% — recruiters often screen below 50% keyword overlap. "
                    + "Focus on missing skills before mass applying.";
        }
        if (!p.getMissingSkills().isEmpty()) {
            return "You are " + fmt(p.getReadinessPct()) + "% ready, but ATS may still miss: "
                    + String.join(", ", limitList(p.getMissingSkills(), 4))
                    + ". Add these to resume projects and complete Practice Hub paths.";
        }
        if (p.getMatchedJobs().isEmpty()) {
            return "No high-match jobs in feed — refresh listings or confirm your selected role matches your domain.";
        }
        return "Profile looks competitive (" + fmt(p.getReadinessPct()) + "%). "
                + "If not shortlisted, improve project proof for: " + String.join(", ", limitList(p.getResumeSkills(), 3))
                + " and tailor each application.";
    }

    private static List<String> jobLines(List<JobFeedItem> jobs) {
        List<String> lines = new ArrayList<>();
        for (JobFeedItem j : jobs) {
            lines.add(j.getTitle() + " @ " + j.getCompany() + " — " + fmt(j.getMatchPct()) + "% match");
        }
        return lines;
    }

    private ChatResponse emptyPrompt() {
        ChatResponse r = new ChatResponse();
        r.setType("HELP");
        r.setTitle("Career mentor");
        r.setSummary("Ask a question about skills, jobs, or learning — answers use your live database profile.");
        return r;
    }

    private static String formatReply(ChatResponse r) {
        StringBuilder sb = new StringBuilder();
        if (r.getTitle() != null) sb.append(r.getTitle()).append("\n\n");
        if (r.getSummary() != null) sb.append(r.getSummary().replace("**", "")).append("\n");
        for (String h : r.getHighlights()) sb.append("\n").append(h.replace("**", ""));
        for (ChatSection sec : r.getSections()) {
            sb.append("\n\n").append(sec.getHeading()).append(":\n");
            if (sec.getBody() != null) sb.append(sec.getBody()).append("\n");
            if (sec.getItems() != null) {
                for (String item : sec.getItems()) sb.append("• ").append(item).append("\n");
            }
        }
        return sb.toString().trim();
    }

    private static boolean contains(String m, String... phrases) {
        for (String p : phrases) if (m.contains(p)) return true;
        return false;
    }

    private static String safe(String s) { return s == null || s.isBlank() ? "your target role" : s; }
    private static String fmt(double d) { return String.format("%.0f", d); }
    private static String nullToDash(String s) { return s == null || s.isBlank() ? "—" : s; }

    private static List<String> limitList(List<String> list, int max) {
        return list.size() <= max ? list : list.subList(0, max);
    }
}

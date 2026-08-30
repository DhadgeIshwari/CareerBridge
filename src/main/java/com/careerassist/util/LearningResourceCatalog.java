package com.careerassist.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.careerassist.model.LearningItem;
import com.careerassist.model.PracticeLink;
import com.careerassist.model.SkillLearningHub;

/**
 * Curated YouTube playlists, official docs, and structured labs per skill and level.
 * Used when the database has no (or incomplete) skill_resources rows.
 */
public final class LearningResourceCatalog {

    public static final String[] LEVEL_STAGES = {
            "BEGINNER", "INTERMEDIATE", "ADVANCED", "PROJECTS"
    };

    public static final String[] READ_STAGES = { "READ_DOC", "READ_BOOK" };

    private static final Map<String, String> SKILL_ALIASES = Map.ofEntries(
            Map.entry("spring boot", "Spring Boot"),
            Map.entry("spring", "Spring Boot"),
            Map.entry("node.js", "Node.js"),
            Map.entry("rest api", "REST API"),
            Map.entry("power bi", "Power BI"),
            Map.entry("javascript", "JavaScript"),
            Map.entry("mongodb", "MongoDB"),
            Map.entry("ccna", "CCNA")
    );

    private static final Map<String, Map<String, CuratedLink>> CATALOG = new HashMap<>();
    private static final Map<String, Map<String, CuratedLink>> READ_CATALOG = new HashMap<>();

    static {
        skill("General",
                link("BEGINNER", "freeCodeCamp Curriculum", "https://www.freecodecamp.org/learn/", "freeCodeCamp"),
                link("INTERMEDIATE", "Developer Roadmaps", "https://roadmap.sh/", "Roadmap"),
                link("ADVANCED", "MDN Web Docs", "https://developer.mozilla.org/en-US/docs/Learn", "Documentation"),
                link("PROJECTS", "Project-Based Learning List", "https://github.com/practical-tutorials/project-based-learning", "GitHub"));

        skill("Java",
                link("BEGINNER", "Java Programming Full Course", "https://www.youtube.com/watch?v=eIrMbAQSU34", "YouTube"),
                link("INTERMEDIATE", "Java OOP & Collections Playlist", "https://www.youtube.com/playlist?list=PLQVdddLvB1DU3f27sQ82aUEqeODdAS0U", "YouTube"),
                link("ADVANCED", "Spring Boot Full Course", "https://www.youtube.com/watch?v=9SGDpanIA8g", "YouTube"),
                link("PROJECTS", "Java Project-Based Tutorials", "https://www.youtube.com/playlist?list=PLd3UqWTnYXOsJplFnUYQ9x4C5sCZtVj4", "YouTube"));

        skill("Python",
                link("BEGINNER", "Python for Beginners Playlist", "https://www.youtube.com/playlist?list=PL6gx4Cwl9DGAjkwJocd-hyXDzhiMoCQ48", "YouTube"),
                link("INTERMEDIATE", "Official Python Tutorial", "https://docs.python.org/3/tutorial/", "Documentation"),
                link("ADVANCED", "Django Getting Started", "https://docs.djangoproject.com/en/stable/intro/", "Documentation"),
                link("PROJECTS", "Python Projects Playlist", "https://www.youtube.com/playlist?list=PLryHKhjQyA3n6hErAxn0bH0DZQtj56J63", "YouTube"));

        skill("JavaScript",
                link("BEGINNER", "JavaScript Basics Playlist", "https://www.youtube.com/playlist?list=PLWKjhRpqy5vl3AVdEoERDWCO4DzR1MKX", "YouTube"),
                link("INTERMEDIATE", "The Modern JavaScript Tutorial", "https://javascript.info/", "Documentation"),
                link("ADVANCED", "Advanced JavaScript Playlist", "https://www.youtube.com/playlist?list=PL4cUxeIkcSxu9co_afYcnWumHrAQHiuG", "YouTube"),
                link("PROJECTS", "Frontend Mentor Challenges", "https://www.frontendmentor.io/challenges", "Projects"));

        skill("SQL",
                link("BEGINNER", "SQL Tutorial (W3Schools)", "https://www.w3schools.com/sql/", "Documentation"),
                link("INTERMEDIATE", "SQL Intermediate Playlist", "https://www.youtube.com/playlist?list=PLHrAJOruV9zS4xNImaYZ7v9FWzT8q_n9", "YouTube"),
                link("ADVANCED", "PostgreSQL Tutorial", "https://www.postgresql.org/docs/current/tutorial.html", "Documentation"),
                link("PROJECTS", "SQL Practice & Exercises", "https://www.sql-practice.com/", "Labs"));

        skill("Spring Boot",
                link("BEGINNER", "Spring Boot Getting Started", "https://spring.io/guides/gs/spring-boot/", "Documentation"),
                link("INTERMEDIATE", "Spring Boot Full Stack Playlist", "https://www.youtube.com/playlist?list=PLqq-6Dgznn1dfeTEE91zg8llgYVV-47Qg", "YouTube"),
                link("ADVANCED", "Spring Guides Library", "https://spring.io/guides", "Documentation"),
                link("PROJECTS", "Spring Boot Sample Projects", "https://github.com/spring-projects/spring-boot/tree/main/spring-boot-samples", "GitHub"));

        skill("React",
                link("BEGINNER", "React Official Learn", "https://react.dev/learn", "Documentation"),
                link("INTERMEDIATE", "React Hooks Playlist", "https://www.youtube.com/playlist?list=PL4cUxeIkcSxu9co_afYcnWumHrAQHiuG", "YouTube"),
                link("ADVANCED", "React Patterns & Performance", "https://react.dev/learn/thinking-in-react", "Documentation"),
                link("PROJECTS", "React Portfolio Projects", "https://www.frontendmentor.io/challenges?languages=javascript,html,css", "Projects"));

        skill("Node.js",
                link("BEGINNER", "Node.js Full Course", "https://www.youtube.com/watch?v=TlB_eWDSMt4", "YouTube"),
                link("INTERMEDIATE", "Node.js Learn Track", "https://nodejs.org/en/learn", "Documentation"),
                link("ADVANCED", "Express.js Guide", "https://expressjs.com/en/starter/installing.html", "Documentation"),
                link("PROJECTS", "Node.js Projects Playlist", "https://www.youtube.com/playlist?list=PL_cUvB5W7ypkIG0PD0co90K6EgCH0RCqO", "YouTube"));

        skill("AWS",
                link("BEGINNER", "AWS Cloud Practitioner Playlist", "https://www.youtube.com/playlist?list=PLit1JEhC-9cMaeNkAb9S9VNEn2Zh6X4VJ", "YouTube"),
                link("INTERMEDIATE", "AWS Hands-On Tutorials", "https://aws.amazon.com/getting-started/hands-on/", "Labs"),
                link("ADVANCED", "AWS Architecture Whitepapers", "https://docs.aws.amazon.com/whitepapers/latest/aws-overview/", "Documentation"),
                link("PROJECTS", "AWS Workshops", "https://workshops.aws/", "Labs"));

        skill("Linux",
                link("BEGINNER", "Linux Command Line Playlist", "https://www.youtube.com/playlist?list=PLCBAA659E02170298", "YouTube"),
                link("INTERMEDIATE", "Linux Journey", "https://linuxjourney.com/", "Documentation"),
                link("ADVANCED", "Linux System Administration Playlist", "https://www.youtube.com/playlist?list=PLS_XUvxSzdWv_LyKbXyJ-P6yVn_E4F042", "YouTube"),
                link("PROJECTS", "OverTheWire Bandit Labs", "https://overthewire.org/wargames/bandit/", "Labs"));

        skill("CCNA",
                link("BEGINNER", "CCNA 200-301 Complete Course", "https://www.youtube.com/playlist?list=PLxbMC_OWrlCdM1hXj7E8cwz7uD0n7L8gK", "YouTube"),
                link("INTERMEDIATE", "Cisco Packet Tracer Labs", "https://www.netacad.com/cisco-packet-tracer", "Labs"),
                link("ADVANCED", "CCNA Exam Topics Guide", "https://www.cisco.com/c/en/us/training-events/training-certifications/exams/exam-listings/ccna-200-301.html", "Documentation"),
                link("PROJECTS", "Packet Tracer Practice Labs", "https://www.packettracernetwork.com/labs/", "Labs"));

        skill("Networking",
                link("BEGINNER", "Computer Networking Full Course", "https://www.youtube.com/watch?v=qiQR5rTSshw", "YouTube"),
                link("INTERMEDIATE", "Networking Fundamentals Playlist", "https://www.youtube.com/playlist?list=PL79B972913681A418", "YouTube"),
                link("ADVANCED", "TCP/IP Deep Dive", "https://www.cloudflare.com/learning/network-layer/what-is-tcp-ip/", "Documentation"),
                link("PROJECTS", "Network Simulation Labs", "https://www.netacad.com/cisco-packet-tracer", "Labs"));

        skill("Routing",
                link("BEGINNER", "IP Routing Fundamentals", "https://www.youtube.com/watch?v=8xX2qnqXQYw", "YouTube"),
                link("INTERMEDIATE", "CCNA Routing Labs Playlist", "https://www.youtube.com/playlist?list=PLxbMC_OWrlCdM1hXj7E8cwz7uD0n7L8gK", "YouTube"),
                link("ADVANCED", "BGP Routing Tutorial", "https://www.cloudflare.com/learning/security/glossary/what-is-bgp/", "Documentation"),
                link("PROJECTS", "GNS3 Routing Labs", "https://www.gns3.com/software/download/", "Labs"));

        skill("Switching",
                link("BEGINNER", "VLANs & Switching Basics", "https://www.youtube.com/watch?v=5B72RqAEBGA", "YouTube"),
                link("INTERMEDIATE", "Layer 2 Switching Playlist", "https://www.youtube.com/playlist?list=PLxbMC_OWrlCdM1hXj7E8cwz7uD0n7L8gK", "YouTube"),
                link("ADVANCED", "Spanning Tree Protocol Guide", "https://www.cisco.com/c/en/us/support/docs/lan-switching/spanning-tree-protocol/5234-5.html", "Documentation"),
                link("PROJECTS", "Switch Configuration Labs", "https://www.packettracernetwork.com/labs/", "Labs"));

        skill("HTML",
                link("BEGINNER", "HTML Full Course", "https://www.youtube.com/watch?v=pQN-pnXPaVg", "YouTube"),
                link("INTERMEDIATE", "MDN HTML Guide", "https://developer.mozilla.org/en-US/docs/Web/HTML", "Documentation"),
                link("ADVANCED", "Semantic HTML & Accessibility", "https://web.dev/learn/html/", "Documentation"),
                link("PROJECTS", "Build a Personal Site", "https://www.frontendmentor.io/challenges?categories=page", "Projects"));

        skill("CSS",
                link("BEGINNER", "CSS Full Course", "https://www.youtube.com/watch?v=1PnVq36fHJk", "YouTube"),
                link("INTERMEDIATE", "CSS Flexbox & Grid", "https://css-tricks.com/snippets/css/a-guide-to-flexbox/", "Documentation"),
                link("ADVANCED", "Responsive Web Design", "https://web.dev/learn/css/", "Documentation"),
                link("PROJECTS", "CSS Layout Challenges", "https://www.frontendmentor.io/challenges?categories=layout", "Projects"));

        skill("Git",
                link("BEGINNER", "Git & GitHub for Beginners", "https://www.youtube.com/watch?v=RGOj5ywpRwg", "YouTube"),
                link("INTERMEDIATE", "Pro Git Book", "https://git-scm.com/book/en/v2", "Documentation"),
                link("ADVANCED", "Learn Git Branching", "https://learngitbranching.js.org/", "Labs"),
                link("PROJECTS", "Contributing to Open Source", "https://opensource.guide/how-to-contribute/", "Projects"));

        skill("Docker",
                link("BEGINNER", "Docker for Beginners", "https://www.youtube.com/watch?v=fqMOX6JJhGo", "YouTube"),
                link("INTERMEDIATE", "Docker Official Get Started", "https://docs.docker.com/get-started/", "Documentation"),
                link("ADVANCED", "Docker Compose Guide", "https://docs.docker.com/compose/", "Documentation"),
                link("PROJECTS", "Docker Sample Applications", "https://github.com/docker/awesome-compose", "GitHub"));

        skill("MongoDB",
                link("BEGINNER", "MongoDB University Learning Path", "https://learn.mongodb.com/learning-paths/mongodb-database-administrator-path", "MongoDB University"),
                link("INTERMEDIATE", "MongoDB CRUD Operations", "https://www.mongodb.com/docs/manual/tutorial/", "Documentation"),
                link("ADVANCED", "MongoDB Aggregation", "https://www.mongodb.com/docs/manual/aggregation/", "Documentation"),
                link("PROJECTS", "MongoDB Atlas Sample Apps", "https://www.mongodb.com/developer/products/atlas/sample-apps/", "Projects"));

        skill("REST API",
                link("BEGINNER", "REST API Concepts", "https://www.youtube.com/watch?v=-MTSQjw5DrM", "YouTube"),
                link("INTERMEDIATE", "REST API Design Guide", "https://restfulapi.net/", "Documentation"),
                link("ADVANCED", "OpenAPI Specification", "https://swagger.io/specification/", "Documentation"),
                link("PROJECTS", "Public APIs for Practice", "https://github.com/public-apis/public-apis", "GitHub"));

        skill("Excel",
                link("BEGINNER", "Excel for Beginners Playlist", "https://www.youtube.com/playlist?list=PLFAF4A3D2AE67FEA5", "YouTube"),
                link("INTERMEDIATE", "Excel Training (Microsoft)", "https://support.microsoft.com/en-us/office/excel-for-the-web-training-7e2ffb15-8334-4f0b-932b-39c82bafdc50", "Documentation"),
                link("ADVANCED", "Excel Dashboards Playlist", "https://www.youtube.com/playlist?list=PLFAF4A3D2AE67FEA5", "YouTube"),
                link("PROJECTS", "Kaggle Datasets for Analysis", "https://www.kaggle.com/datasets", "Projects"));

        skill("Power BI",
                link("BEGINNER", "Power BI Desktop Full Course", "https://www.youtube.com/watch?v=AGrl-H87pRU", "YouTube"),
                link("INTERMEDIATE", "Microsoft Power BI Training", "https://learn.microsoft.com/en-us/training/powerplatform/power-bi", "Documentation"),
                link("ADVANCED", "DAX in Power BI", "https://learn.microsoft.com/en-us/dax/dax-learn-overview", "Documentation"),
                link("PROJECTS", "Power BI Sample Reports", "https://learn.microsoft.com/en-us/power-bi/create-reports/sample-datasets", "Labs"));

        readSkill("Java",
                link("READ_DOC", "Java Documentation", "https://docs.oracle.com/en/java/", "Documentation"),
                link("READ_BOOK", "Effective Java (Guide)", "https://www.oreilly.com/library/view/effective-java/9780134685997/", "Book"));
        readSkill("Python",
                link("READ_DOC", "Python Official Docs", "https://docs.python.org/3/", "Documentation"),
                link("READ_BOOK", "Automate the Boring Stuff (Free)", "https://automatetheboringstuff.com/", "Book"));
        readSkill("JavaScript",
                link("READ_DOC", "MDN JavaScript Guide", "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide", "Documentation"),
                link("READ_BOOK", "Eloquent JavaScript (Free)", "https://eloquentjavascript.net/", "Book"));
        readSkill("Networking",
                link("READ_DOC", "Cisco Networking Basics", "https://www.cisco.com/c/en/us/solutions/enterprise-networks/what-is-networking.html", "Documentation"),
                link("READ_BOOK", "TCP/IP Illustrated (Overview)", "https://www.pearson.com/en-us/subject-catalog/p/tcp-ip-illustrated-volume-1/P200000003380", "Book"));
        readSkill("CCNA",
                link("READ_DOC", "CCNA Exam Topics", "https://www.cisco.com/c/en/us/training-events/training-certifications/exams/exam-listings/ccna-200-301.html", "Documentation"),
                link("READ_BOOK", "Cisco CCNA Official Cert Guide", "https://www.ciscopress.com/ccna", "Book"));
        readSkill("React",
                link("READ_DOC", "React Official Docs", "https://react.dev/learn", "Documentation"),
                link("READ_BOOK", "React Beta Docs (Deep Dive)", "https://react.dev/learn/thinking-in-react", "Book"));
        readSkill("SQL",
                link("READ_DOC", "PostgreSQL Tutorial", "https://www.postgresql.org/docs/current/tutorial.html", "Documentation"),
                link("READ_BOOK", "SQL for Data Analysis (Mode)", "https://mode.com/sql-tutorial/", "Book"));
        readSkill("Spring Boot",
                link("READ_DOC", "Spring Boot Reference", "https://docs.spring.io/spring-boot/docs/current/reference/html/", "Documentation"),
                link("READ_BOOK", "Spring Guides Library", "https://spring.io/guides", "Book"));
        readSkill("AWS",
                link("READ_DOC", "AWS Documentation", "https://docs.aws.amazon.com/", "Documentation"),
                link("READ_BOOK", "AWS Well-Architected Framework", "https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html", "Book"));
        readSkill("Machine Learning",
                link("READ_DOC", "scikit-learn User Guide", "https://scikit-learn.org/stable/user_guide.html", "Documentation"),
                link("READ_BOOK", "Google ML Crash Course Notes", "https://developers.google.com/machine-learning/crash-course", "Book"));
        readSkill("General",
                link("READ_DOC", "MDN Web Docs", "https://developer.mozilla.org/en-US/docs/Learn", "Documentation"),
                link("READ_BOOK", "freeCodeCamp Handbook", "https://www.freecodecamp.org/news/", "Book"));
    }

    private LearningResourceCatalog() {}

    /** Builds a full four-stage path, preferring database rows then catalog entries. */
    public static List<LearningItem> buildPath(String skillName, List<LearningItem> fromDatabase) {
        String canonical = canonicalSkill(skillName);
        Map<String, LearningItem> byStage = new LinkedHashMap<>();

        if (fromDatabase != null) {
            for (LearningItem item : fromDatabase) {
                if (item.getLevelStage() != null) {
                    byStage.put(item.getLevelStage().toUpperCase(Locale.ROOT), item);
                }
            }
        }

        Map<String, CuratedLink> curated = CATALOG.get(canonical);
        if (curated == null) {
            curated = CATALOG.get("General");
        }

        for (String stage : LEVEL_STAGES) {
            if (byStage.containsKey(stage)) continue;
            CuratedLink link = curated != null ? curated.get(stage) : null;
            if (link == null && CATALOG.containsKey("General")) {
                link = CATALOG.get("General").get(stage);
            }
            if (link != null) {
                LearningItem li = new LearningItem();
                li.setSkillName(skillName);
                li.setLevelStage(stage);
                li.setTitle(link.title);
                li.setResourceUrl(link.url);
                li.setPlatform(link.platform);
                byStage.put(stage, li);
            }
        }

        List<LearningItem> path = new ArrayList<>();
        for (String stage : LEVEL_STAGES) {
            LearningItem item = byStage.get(stage);
            if (item != null) path.add(item);
        }
        return path;
    }

    /** Full per-skill hub: Learn + Read + Practice recommendations. */
    public static SkillLearningHub buildSkillHub(String skillName, List<LearningItem> fromDatabase) {
        SkillLearningHub hub = new SkillLearningHub();
        hub.setSkillName(skillName);
        hub.setLearnItems(buildPath(skillName, fromDatabase));
        hub.setReadItems(buildReadPath(skillName));
        List<PracticeLink> practice = PracticePlatformCatalog.forSkill(skillName);
        hub.setPracticeLinks(practice);
        hub.setPracticePlatforms(PracticePlatformCatalog.toCsv(practice));
        return hub;
    }

    public static List<LearningItem> buildReadPath(String skillName) {
        String canonical = canonicalSkill(skillName);
        Map<String, CuratedLink> curated = READ_CATALOG.get(canonical);
        if (curated == null) curated = READ_CATALOG.get("General");
        List<LearningItem> path = new ArrayList<>();
        for (String stage : READ_STAGES) {
            CuratedLink link = curated != null ? curated.get(stage) : null;
            if (link == null) continue;
            LearningItem li = new LearningItem();
            li.setSkillName(skillName);
            li.setLevelStage(stage);
            li.setTitle(link.title);
            li.setResourceUrl(link.url);
            li.setPlatform(link.platform);
            path.add(li);
        }
        return path;
    }

    /** Practice rows persisted with level_stage PRACTICE. */
    public static List<LearningItem> buildPracticeItems(String skillName) {
        List<LearningItem> items = new ArrayList<>();
        for (PracticeLink p : PracticePlatformCatalog.forSkill(skillName)) {
            LearningItem li = new LearningItem();
            li.setSkillName(skillName);
            li.setLevelStage("PRACTICE");
            li.setTitle(p.getName());
            li.setResourceUrl(p.getUrl());
            li.setPlatform("Practice · " + (p.getDescription() != null ? p.getDescription() : "Hands-on"));
            items.add(li);
        }
        return items;
    }

    public static String canonicalSkill(String skillName) {
        if (skillName == null || skillName.isBlank()) return "General";
        String key = skillName.trim().toLowerCase(Locale.ROOT);
        if (CATALOG.containsKey(skillName.trim())) return skillName.trim();
        return SKILL_ALIASES.getOrDefault(key, skillName.trim());
    }

    private static void readSkill(String name, CuratedLink... links) {
        Map<String, CuratedLink> stages = new HashMap<>();
        for (CuratedLink link : links) {
            stages.put(link.stage, link);
        }
        READ_CATALOG.put(name, stages);
    }

    private static void skill(String name, CuratedLink... links) {
        Map<String, CuratedLink> stages = new HashMap<>();
        for (CuratedLink link : links) {
            stages.put(link.stage, link);
        }
        CATALOG.put(name, stages);
    }

    private static CuratedLink link(String stage, String title, String url, String platform) {
        return new CuratedLink(stage, title, url, platform);
    }

    private static final class CuratedLink {
        final String stage;
        final String title;
        final String url;
        final String platform;

        CuratedLink(String stage, String title, String url, String platform) {
            this.stage = stage;
            this.title = title;
            this.url = url;
            this.platform = platform;
        }
    }
}

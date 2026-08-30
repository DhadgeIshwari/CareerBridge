package com.careerassist.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.careerassist.model.PracticeLink;

/**
 * Skill-specific hands-on practice platforms for the Skill Practice Hub.
 */
public final class PracticePlatformCatalog {

    private static final Map<String, List<PracticeLink>> BY_SKILL = new HashMap<>();

    static {
        networking();
        javaFamily();
        webDev();
        pythonData();
        devops();
        generalFallback();
    }

    private PracticePlatformCatalog() {}

    public static List<PracticeLink> forSkill(String skillName) {
        String canonical = LearningResourceCatalog.canonicalSkill(skillName);
        List<PracticeLink> links = BY_SKILL.get(canonical);
        if (links != null && !links.isEmpty()) return copy(links);
        String key = skillName == null ? "" : skillName.trim().toLowerCase(Locale.ROOT);
        for (Map.Entry<String, List<PracticeLink>> e : BY_SKILL.entrySet()) {
            if (e.getKey().toLowerCase(Locale.ROOT).equals(key)) return copy(e.getValue());
        }
        return copy(BY_SKILL.get("General"));
    }

    public static String toCsv(List<PracticeLink> links) {
        if (links == null || links.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        for (PracticeLink p : links) {
            if (sb.length() > 0) sb.append(';');
            sb.append(p.getName()).append('|').append(p.getUrl());
        }
        return sb.toString();
    }

    public static List<PracticeLink> fromCsv(String csv) {
        List<PracticeLink> list = new ArrayList<>();
        if (csv == null || csv.isBlank()) return list;
        for (String part : csv.split(";")) {
            String t = part.trim();
            if (t.isEmpty()) continue;
            int pipe = t.indexOf('|');
            if (pipe > 0) {
                list.add(new PracticeLink(t.substring(0, pipe).trim(), t.substring(pipe + 1).trim(), "Practice"));
            }
        }
        return list;
    }

    private static List<PracticeLink> copy(List<PracticeLink> src) {
        List<PracticeLink> out = new ArrayList<>();
        if (src != null) out.addAll(src);
        return out;
    }

    private static void put(String skill, PracticeLink... links) {
        BY_SKILL.put(skill, List.of(links));
    }

    private static PracticeLink p(String name, String url, String desc) {
        return new PracticeLink(name, url, desc);
    }

    private static void networking() {
        put("CCNA",
                p("Cisco Packet Tracer Labs", "https://www.netacad.com/cisco-packet-tracer", "Official Cisco lab environment"),
                p("Cisco Networking Academy", "https://www.netacad.com/", "Structured networking labs & courses"),
                p("TryHackMe", "https://tryhackme.com", "Guided networking & security rooms"),
                p("Hack The Box", "https://www.hackthebox.com", "Hands-on network & security challenges"));
        put("Networking",
                p("TryHackMe", "https://tryhackme.com", "Networking fundamentals labs"),
                p("Hack The Box", "https://www.hackthebox.com", "Real-world network challenges"),
                p("Cisco Packet Tracer Labs", "https://www.netacad.com/cisco-packet-tracer", "Simulate LAN/WAN topologies"),
                p("NetAcad Labs", "https://www.netacad.com/", "Cisco NetAcad practice modules"));
        put("Routing",
                p("Cisco Packet Tracer Labs", "https://www.netacad.com/cisco-packet-tracer", "Routing protocol labs"),
                p("NetAcad Labs", "https://www.netacad.com/", "CCNA routing practice"),
                p("TryHackMe", "https://tryhackme.com", "Network routing rooms"));
        put("Switching",
                p("Cisco Packet Tracer Labs", "https://www.netacad.com/cisco-packet-tracer", "VLAN & STP labs"),
                p("NetAcad Labs", "https://www.netacad.com/", "Layer-2 switching labs"));
        put("Linux",
                p("OverTheWire Bandit", "https://overthewire.org/wargames/bandit/", "Linux CLI practice"),
                p("TryHackMe", "https://tryhackme.com", "Linux fundamentals rooms"),
                p("Hack The Box", "https://www.hackthebox.com", "Linux machine challenges"));
    }

    private static void javaFamily() {
        put("Java",
                p("LeetCode", "https://leetcode.com", "Algorithm & Java coding practice"),
                p("HackerRank", "https://www.hackerrank.com", "Java challenges & interview prep"),
                p("CodeChef", "https://www.codechef.com", "Competitive programming"));
        put("Spring Boot",
                p("LeetCode", "https://leetcode.com", "Backend coding interviews"),
                p("HackerRank", "https://www.hackerrank.com", "Java/Spring-style problems"),
                p("CodeChef", "https://www.codechef.com", "Timed coding practice"));
        put("SQL",
                p("HackerRank SQL", "https://www.hackerrank.com/domains/sql", "SQL query practice"),
                p("LeetCode Database", "https://leetcode.com/problemset/database/", "SQL interview questions"),
                p("SQL Practice", "https://www.sql-practice.com/", "Interactive SQL exercises"));
    }

    private static void webDev() {
        put("JavaScript",
                p("Frontend Mentor", "https://www.frontendmentor.io", "Real frontend briefs"),
                p("JavaScript30", "https://javascript30.com", "30 vanilla JS projects"),
                p("LeetCode", "https://leetcode.com", "JS algorithm practice"));
        put("React",
                p("Frontend Mentor", "https://www.frontendmentor.io", "React-friendly UI challenges"),
                p("LeetCode", "https://leetcode.com", "Frontend interview prep"));
        put("HTML",
                p("Frontend Mentor", "https://www.frontendmentor.io", "HTML/CSS layouts"),
                p("JavaScript30", "https://javascript30.com", "Project-based practice"));
        put("CSS",
                p("Frontend Mentor", "https://www.frontendmentor.io", "Responsive CSS challenges"),
                p("JavaScript30", "https://javascript30.com", "Styling + JS projects"));
        put("Node.js",
                p("LeetCode", "https://leetcode.com", "Backend JS problems"),
                p("HackerRank", "https://www.hackerrank.com", "Node.js challenges"),
                p("Frontend Mentor", "https://www.frontendmentor.io", "Full-stack UI projects"));
        put("REST API",
                p("HackerRank", "https://www.hackerrank.com", "API design exercises"),
                p("LeetCode", "https://leetcode.com", "System design & coding"));
    }

    private static void pythonData() {
        put("Python",
                p("Kaggle", "https://www.kaggle.com", "Datasets & notebooks"),
                p("Google Colab", "https://colab.research.google.com/", "Free GPU notebook practice"),
                p("HackerRank", "https://www.hackerrank.com/domains/python", "Python challenges"));
        put("Machine Learning",
                p("Kaggle", "https://www.kaggle.com", "ML competitions & datasets"),
                p("Google Colab", "https://colab.research.google.com/", "Train models in notebooks"));
        put("Excel",
                p("Kaggle", "https://www.kaggle.com/datasets", "Analyze real datasets in Excel/Sheets"),
                p("HackerRank", "https://www.hackerrank.com", "Data tasks"));
        put("Power BI",
                p("Kaggle", "https://www.kaggle.com/datasets", "Practice data modeling"),
                p("Microsoft Learn Samples", "https://learn.microsoft.com/en-us/power-bi/create-reports/sample-datasets", "Official sample reports"));
    }

    private static void devops() {
        put("AWS",
                p("AWS Hands-On Labs", "https://aws.amazon.com/getting-started/hands-on/", "Official AWS tutorials"),
                p("TryHackMe", "https://tryhackme.com", "Cloud security rooms"));
        put("Docker",
                p("Play with Docker", "https://labs.play-with-docker.com/", "Free Docker sandbox"),
                p("Katacoda Docker", "https://www.katacoda.com/courses/docker", "Interactive containers"));
        put("Kubernetes",
                p("KillerCoda Kubernetes", "https://killercoda.com/", "Interactive K8s scenarios"));
        put("DevOps",
                p("TryHackMe", "https://tryhackme.com", "DevOps & security labs"),
                p("AWS Hands-On Labs", "https://aws.amazon.com/getting-started/hands-on/", "Cloud practice"));
        put("Git",
                p("Learn Git Branching", "https://learngitbranching.js.org/", "Visual Git practice"),
                p("HackerRank", "https://www.hackerrank.com", "Git-aware coding"));
    }

    private static void generalFallback() {
        put("General",
                p("LeetCode", "https://leetcode.com", "General coding practice"),
                p("HackerRank", "https://www.hackerrank.com", "Skill assessments"),
                p("TryHackMe", "https://tryhackme.com", "Guided IT labs"));
    }
}

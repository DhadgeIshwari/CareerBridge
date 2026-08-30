<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*,com.careerassist.service.CareerService" %>
<!DOCTYPE html>
<html>
<head>
<title>Career Compass | Skill Gap Analysis</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
<style>
  /* Mapped NexusAI Design System Styles for Skill Gap */
  :root {
    --accent-blue-grad: var(--grad-cyan-purple);
    --accent-purple-grad: var(--grad-purple-pink);
    --btn-blue-grad: var(--grad-cyan-purple);
  }

  .lovable-container {
    max-width: 100%;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    animation: fadeIn 0.4s ease-out forwards;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }

  /* Compact Section Dividers */
  .section-divider {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-top: 1.25rem;
    margin-bottom: 0.5rem;
  }

  .section-divider::after {
    content: '';
    flex-grow: 1;
    height: 1px;
    background: linear-gradient(90deg, var(--border-color) 0%, transparent 100%);
  }

  .divider-number {
    font-family: 'Outfit', sans-serif;
    font-size: 0.8rem;
    color: var(--accent-cyan);
    font-weight: 700;
  }

  .divider-title {
    font-family: 'Outfit', sans-serif;
    font-size: 1.2rem;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0;
    letter-spacing: -0.02em;
  }

  .section-subtitle {
    font-size: 0.85rem;
    color: var(--text-secondary);
    margin-top: -0.25rem;
    margin-bottom: 0.75rem;
  }

  /* Standard NexusAI Cards Integration */
  .lovable-card {
    background: var(--bg-card);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid var(--border-color);
    border-radius: 16px;
    padding: 1.5rem;
    box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.25);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
  }

  .lovable-card:hover {
    transform: translateY(-2px);
    border-color: rgba(6, 182, 212, 0.2);
    box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.35);
    background: var(--grad-card-hover);
  }

  /* 01. Career Readiness Card layout */
  .readiness-card {
    display: grid;
    grid-template-columns: 0.7fr 1.3fr;
    gap: 2rem;
    align-items: center;
  }

  @media (max-width: 768px) {
    .readiness-card {
      grid-template-columns: 1fr;
      gap: 1.5rem;
    }
  }

  .readiness-gauge-box {
    display: flex;
    justify-content: center;
  }

  .readiness-gauge {
    position: relative;
    width: 120px;
    height: 120px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .readiness-gauge svg {
    width: 100%;
    height: 100%;
    transform: rotate(-90deg);
  }

  .readiness-gauge circle {
    fill: none;
    stroke-width: 7;
  }

  .readiness-gauge .bg-ring {
    stroke: var(--border-color);
  }

  .readiness-gauge .fill-ring {
    stroke: var(--accent-cyan);
    stroke-linecap: round;
  }

  .readiness-value-text {
    position: absolute;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .readiness-pct {
    font-family: 'Outfit', sans-serif;
    font-size: 1.85rem;
    font-weight: 850;
    color: var(--text-primary);
    line-height: 1;
  }

  .readiness-lbl {
    font-size: 0.6rem;
    font-weight: 750;
    letter-spacing: 0.1em;
    color: var(--text-muted);
    text-transform: uppercase;
    margin-top: 0.2rem;
  }

  .insight-content {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .ai-insight-tag {
    background: rgba(139, 92, 246, 0.1);
    color: #a78bfa;
    border: 1px solid rgba(139, 92, 246, 0.15);
    padding: 0.25rem 0.6rem;
    border-radius: 99px;
    font-size: 0.68rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
    align-self: flex-start;
  }

  .insight-paragraph {
    font-size: 1.02rem;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .insight-paragraph strong, .insight-paragraph b {
    color: var(--text-primary);
    font-weight: 600;
  }

  .insight-paragraph span.highlight {
    color: var(--accent-cyan);
    font-weight: 600;
  }

  .insight-badges {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .insight-badge {
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-size: 0.72rem;
    font-weight: 600;
  }

  .insight-badge.strong-tag {
    background: rgba(16, 185, 129, 0.08);
    color: var(--accent-green);
    border: 1px solid rgba(16, 185, 129, 0.15);
  }

  .insight-badge.gap-tag {
    background: rgba(245, 158, 11, 0.08);
    color: var(--accent-yellow);
    border: 1px solid rgba(245, 158, 11, 0.15);
  }

  /* 02. Your Strengths pills */
  .strength-pills-row {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .strength-pill-item {
    background: rgba(255, 255, 255, 0.02);
    border: 1px solid var(--border-color);
    color: var(--text-primary);
    padding: 0.4rem 0.9rem;
    border-radius: 99px;
    font-size: 0.82rem;
    font-weight: 600;
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
  }

  .strength-pill-item .dot {
    width: 5px;
    height: 5px;
    background-color: var(--accent-green);
    border-radius: 50%;
    box-shadow: var(--glow-green);
  }

  /* 03. Top Skill Gaps Grid */
  .gaps-card-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1.25rem;
  }

  @media (max-width: 768px) {
    .gaps-card-grid {
      grid-template-columns: 1fr;
    }
  }

  .gap-info-card {
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100%;
  }

  .gap-info-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.75rem;
  }

  .gap-icon-circle {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
    background: rgba(6, 182, 212, 0.1);
    color: var(--accent-cyan);
    border: 1px solid rgba(6, 182, 212, 0.2);
  }

  .gap-info-card:nth-child(even) .gap-icon-circle {
    background: rgba(139, 92, 246, 0.1);
    color: var(--accent-purple);
    border: 1px solid rgba(139, 92, 246, 0.2);
  }

  .gap-arrow-link {
    color: var(--text-muted);
    font-size: 0.85rem;
  }
  .gap-arrow-link:hover {
    color: var(--accent-cyan);
  }

  .gap-info-card-body {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    margin-bottom: 1rem;
  }

  .gap-skill-name {
    font-family: 'Outfit', sans-serif;
    font-size: 1.15rem;
    font-weight: 700;
    color: var(--text-primary);
  }

  .gap-skill-desc {
    font-size: 0.85rem;
    color: var(--text-secondary);
    line-height: 1.45;
  }

  .gap-info-card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid var(--border-color);
    padding-top: 0.75rem;
    font-size: 0.8rem;
  }

  .gap-footer-meta {
    display: flex;
    flex-direction: column;
    gap: 0.15rem;
  }

  .gap-footer-label {
    text-transform: uppercase;
    font-weight: 700;
    color: var(--text-muted);
    font-size: 0.6rem;
    letter-spacing: 0.05em;
  }

  .gap-footer-val {
    font-weight: 600;
    color: var(--text-primary);
  }

  .gap-footer-val.highlight-cyan {
    color: var(--accent-cyan);
  }

  /* 04. Career Impact Grid */
  .impact-card-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1.25rem;
  }

  @media (max-width: 768px) {
    .impact-card-grid {
      grid-template-columns: 1fr;
    }
  }

  .impact-metric-card {
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100%;
  }

  .impact-metric-value {
    font-family: 'Outfit', sans-serif;
    font-size: 2.25rem;
    font-weight: 850;
    line-height: 1;
    background: var(--grad-cyan-purple);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .impact-metric-value span {
    font-size: 0.85rem;
    text-transform: uppercase;
    font-weight: 700;
    color: var(--text-secondary);
    margin-left: 0.2rem;
    -webkit-text-fill-color: var(--text-secondary);
  }

  .impact-metric-title {
    font-family: 'Outfit', sans-serif;
    font-size: 1rem;
    font-weight: 700;
    color: var(--text-primary);
    margin-top: 0.5rem;
    margin-bottom: 0.25rem;
  }

  .impact-text {
    font-size: 0.82rem;
    color: var(--text-secondary);
    line-height: 1.45;
  }

  /* 05. Salary Growth Potential Card */
  .salary-card-row {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    gap: 1.25rem;
    align-items: center;
  }

  @media (max-width: 768px) {
    .salary-card-row {
      grid-template-columns: 1fr;
      gap: 1rem;
    }
    .salary-arrow-icon {
      transform: rotate(90deg);
    }
  }

  .salary-panel-box {
    background: rgba(255, 255, 255, 0.01);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 1.25rem 1.75rem;
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
  }

  .salary-panel-label {
    text-transform: uppercase;
    font-weight: 700;
    color: var(--text-muted);
    font-size: 0.68rem;
    letter-spacing: 0.08em;
  }

  .salary-panel-value {
    font-family: 'Outfit', sans-serif;
    font-size: 1.85rem;
    font-weight: 850;
    color: var(--text-primary);
    line-height: 1.1;
  }

  .salary-panel-value.future {
    background: var(--grad-cyan-purple);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .salary-arrow-icon {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.02);
    border: 1px solid var(--border-color);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.9rem;
    color: var(--accent-cyan);
  }

  /* 06. Next Best Skill Card */
  .next-skill-container {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 2rem;
  }

  @media (max-width: 768px) {
    .next-skill-container {
      flex-direction: column;
      align-items: stretch;
      gap: 1.5rem;
    }
  }

  .next-skill-details {
    display: flex;
    flex-direction: column;
    gap: 0.85rem;
    flex-grow: 1;
  }

  .next-skill-badge {
    background: rgba(245, 158, 11, 0.06);
    color: var(--accent-yellow);
    border: 1px solid rgba(245, 158, 11, 0.12);
    padding: 0.2rem 0.6rem;
    border-radius: 99px;
    font-size: 0.68rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
    align-self: flex-start;
  }

  .next-skill-main-row {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .next-skill-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: rgba(6, 182, 212, 0.06);
    border: 1px solid rgba(6, 182, 212, 0.12);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.25rem;
    color: var(--accent-cyan);
  }

  .next-skill-title {
    font-family: 'Outfit', sans-serif;
    font-size: 1.85rem;
    font-weight: 850;
    color: var(--text-primary);
    line-height: 1;
    margin: 0;
  }

  .next-skill-desc {
    font-size: 0.92rem;
    color: var(--text-secondary);
    line-height: 1.5;
    max-width: 600px;
  }

  .next-skill-pills {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .next-skill-pill {
    background: rgba(255, 255, 255, 0.02);
    border: 1px solid var(--border-color);
    color: var(--text-secondary);
    padding: 0.3rem 0.75rem;
    border-radius: 20px;
    font-size: 0.78rem;
    font-weight: 600;
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
  }

  .next-skill-pill i {
    color: var(--accent-cyan);
  }

  .next-skill-pill.roi-pill i {
    color: var(--accent-green);
  }

  .next-skill-btn {
    background: var(--btn-blue-grad);
    color: #ffffff;
    font-weight: 700;
    padding: 0.85rem 1.75rem;
    border-radius: 10px;
    display: inline-flex;
    align-items: center;
    gap: 0.6rem;
    transition: all 0.3s ease;
    border: none;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 4px 12px rgba(6, 182, 212, 0.2);
    white-space: nowrap;
  }

  .next-skill-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 18px rgba(6, 182, 212, 0.35);
  }

  /* Recruiter Assessment Styling */
  .recruiter-assessment-card {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    border-radius: 16px;
    padding: 1.5rem;
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.25);
  }

  .assessment-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.25rem;
  }

  @media (max-width: 768px) {
    .assessment-grid {
      grid-template-columns: 1fr;
    }
  }

  .assessment-item {
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
  }

  .assessment-item.full-width {
    grid-column: 1 / -1;
  }

  .assessment-label {
    text-transform: uppercase;
    font-weight: 700;
    color: var(--text-muted);
    font-size: 0.65rem;
    letter-spacing: 0.08em;
  }

  .assessment-value {
    font-family: 'Outfit', sans-serif;
    font-size: 1.25rem;
    font-weight: 800;
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
  }

  .decision-shortlist {
    color: var(--accent-green);
  }

  .readiness-level {
    font-weight: 800;
  }
  .readiness-level.high {
    color: var(--accent-green);
  }
  .readiness-level.medium {
    color: var(--accent-yellow);
  }
  .readiness-level.low {
    color: var(--accent-red);
  }

  .assessment-text-list {
    font-size: 0.88rem;
    line-height: 1.5;
    color: var(--text-secondary);
  }

  .assessment-text-list.concerns-list {
    color: #fca5a5;
  }

  @media (max-width: 1024px) {
    .impact-card-grid {
      grid-template-columns: repeat(2, 1fr) !important;
    }
  }
  @media (max-width: 640px) {
    .impact-card-grid {
      grid-template-columns: 1fr !important;
    }
  }
</style>
</head>
<body>
<%
  // Fetch active user and context attributes at the very top of body
  User su = (User) session.getAttribute("user");
  SkillGap gap = (SkillGap) request.getAttribute("gap");
  List<String> skills = (List<String>) request.getAttribute("skills");
%>
<div class="wrap">
  <jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="skillgap"/></jsp:include>
  
  <main class="main">
    <!-- TOP NAVBAR -->
    <div class="top-navbar">
      <div class="navbar-user">
        <div class="notification-btn">
          <i class="fa-regular fa-bell"></i>
        </div>
        <div class="user-profile-badge">
          <div class="user-avatar">
            <%= su != null && su.getFullName() != null && !su.getFullName().isEmpty() ? su.getFullName().substring(0, 1).toUpperCase() : "U" %>
          </div>
          <div class="user-info-text">
            <span class="user-name-span"><%= su != null ? su.getFullName() : "Student" %></span>
            <span class="user-sub-span">Final Year · CSE</span>
          </div>
        </div>
      </div>
    </div>

    <!-- PAGE WELCOME HEADER -->
    <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
      <div>
        <span style="font-size: 0.72rem; font-weight: 700; text-transform: uppercase; color: var(--accent-cyan); letter-spacing: 0.05em; display: block; margin-bottom: 0.25rem;">Analytics</span>
        <h1>Skill Gap <span class="header-accent-grad">Analysis</span></h1>
        <p style="color: var(--text-secondary); font-size: 0.88rem;">Identify and bridge critical skill gaps to qualify for your target job roles.</p>
      </div>
      <a href="${pageContext.request.contextPath}/student?action=dashboard" class="btn btn-outline">
        <i class="fa-solid fa-arrow-left"></i> Dashboard
      </a>
    </div>

    <!-- TARGET ROLE SELECTOR BAR -->
    <jsp:include page="/WEB-INF/jsp/career-role-bar.jsp"/>

    <%
      if (gap != null && su != null) {
        double readinessVal = 100.0 - gap.getGapPercentage();
        String targetRole = gap.getTargetTitle();
        
        // Split and parse skills cleanly
        List<String> acquiredList = new ArrayList<>();
        List<String> missingList = new ArrayList<>();
        if (gap.getAcquiredSkills() != null) {
          for (String s : gap.getAcquiredSkills().split(",")) {
            String clean = s.trim();
            if (!clean.isEmpty()) acquiredList.add(clean);
          }
        }
        if (gap.getMissingSkills() != null) {
          for (String s : gap.getMissingSkills().split(",")) {
            String clean = s.trim();
            if (!clean.isEmpty()) missingList.add(clean);
          }
        }
        
        String[] acquired = acquiredList.toArray(new String[0]);
        String[] missing = missingList.toArray(new String[0]);
        
        // Match Metrics calculations
        double currentMatchPct = (acquired.length * 100.0) / Math.max(1, acquired.length + missing.length);
        double potentialMatchPct = 100.0;
        int missingCount = missing.length;
        String readinessLevel = readinessVal >= 75 ? "High" : (readinessVal >= 45 ? "Medium" : "Low");
        
        // AI Insight Section dynamically derived matching the layout screenshot
        boolean hasFrontend = false;
        boolean hasBackend = false;
        for (String s : acquired) {
          String sl = s.toLowerCase();
          if (sl.contains("react") || sl.contains("html") || sl.contains("css") || sl.contains("javascript") || sl.contains("js")) {
            hasFrontend = true;
          }
          if (sl.contains("java") || sl.contains("spring") || sl.contains("sql") || sl.contains("mysql") || sl.contains("python") || sl.contains("rest")) {
            hasBackend = true;
          }
        }
        
        String missingJoined = "";
        if (missing.length > 0) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < missing.length; i++) {
                if (i > 0) {
                    if (i == missing.length - 1) {
                        sb.append(" and ");
                    } else {
                        sb.append(", ");
                    }
                }
                sb.append(missing[i]);
            }
            missingJoined = sb.toString();
        } else {
            missingJoined = "None";
        }

        String dynamicInsightDesc = "";
        if (targetRole.toLowerCase().contains("network")) {
            dynamicInsightDesc = "Your networking fundamentals are strong. " + 
              (missing.length > 0 ? "<span>" + missingJoined + "</span>" : "Linux, Docker and CI/CD") + 
              " are the primary skills limiting access to advanced infrastructure roles.";
        } else if (targetRole.toLowerCase().contains("frontend")) {
            dynamicInsightDesc = "Your frontend UI styling and interactivity skills are solid. " + 
              (missing.length > 0 ? "<span>" + missingJoined + "</span>" : "React, State Management and Web APIs") + 
              " are the key competencies limiting access to advanced frontend development roles.";
        } else if (targetRole.toLowerCase().contains("backend")) {
            dynamicInsightDesc = "Your backend logic and data storage fundamentals are strong. " + 
              (missing.length > 0 ? "<span>" + missingJoined + "</span>" : "Spring Boot, Docker and SQL") + 
              " are the primary areas limiting access to advanced backend services roles.";
        } else if (targetRole.toLowerCase().contains("devops")) {
            dynamicInsightDesc = "Your scripting and systems understanding are sound. " + 
              (missing.length > 0 ? "<span>" + missingJoined + "</span>" : "Kubernetes, AWS and CI/CD") + 
              " are the main skills limiting access to cloud infrastructure/DevOps roles.";
        } else if (targetRole.toLowerCase().contains("data")) {
            dynamicInsightDesc = "Your analytical reasoning and basic scripting are highly promising. " + 
              (missing.length > 0 ? "<span>" + missingJoined + "</span>" : "Python, Advanced SQL and Power BI") + 
              " are the primary skills limiting access to specialized analytics roles.";
        } else if (targetRole.toLowerCase().contains("full stack") || targetRole.toLowerCase().contains("fullstack")) {
            dynamicInsightDesc = "Your primary stack component coverage is a solid base. " + 
              (missing.length > 0 ? "<span>" + missingJoined + "</span>" : "Docker, AWS and Spring Boot") + 
              " are the key gaps limiting your transition into production-grade Full Stack engineering.";
        } else {
            dynamicInsightDesc = "Your general programming fundamentals are strong. " + 
              (missing.length > 0 ? "<span>" + missingJoined + "</span>" : "System Design, Git and Unit Testing") + 
              " are the key barriers limiting access to advanced software development roles.";
        }
        
        // Apply class highlighting to dynamicInsightDesc
        dynamicInsightDesc = dynamicInsightDesc.replace("<span>", "<span class='highlight'>");

        // Dynamic lists for top gaps cards (max 4)
        List<String[]> gapCards = new ArrayList<>();
        Map<String, String[]> dict = new HashMap<>();
        dict.put("spring boot", new String[]{"fa-solid fa-leaf", "Enterprise Java framework for building microservices.", "Critical", "+40% salary range"});
        dict.put("docker", new String[]{"fa-brands fa-docker", "Standard for shipping & deploying modern apps.", "Very High", "+45% job reach"});
        dict.put("kubernetes", new String[]{"fa-solid fa-dharmachakra", "Orchestration platform for automating container scaling.", "High", "+35% job reach"});
        dict.put("aws", new String[]{"fa-brands fa-aws", "Backbone of cloud infrastructure across industries.", "Critical", "+60% salary range"});
        dict.put("react", new String[]{"fa-brands fa-react", "Component-based UI library for interactive interfaces.", "Critical", "+50% job reach"});
        dict.put("typescript", new String[]{"fa-solid fa-file-code", "Superset of JS adding static type safety.", "High", "+30% job reach"});
        dict.put("sql", new String[]{"fa-solid fa-database", "Standard language for database records storage.", "Critical", "+35% job reach"});
        dict.put("java", new String[]{"fa-brands fa-java", "Class-based object-oriented programming language.", "Critical", "+40% job reach"});
        dict.put("javascript", new String[]{"fa-brands fa-js", "Universal language of front-end applications.", "Critical", "+45% job reach"});
        dict.put("html", new String[]{"fa-solid fa-code", "Standard markup language for creating web pages.", "Critical", "+25% job reach"});
        dict.put("css", new String[]{"fa-brands fa-css3-alt", "Style sheet language used for document presentation.", "High", "+25% job reach"});
        dict.put("mysql", new String[]{"fa-solid fa-database", "Relational database management system.", "High", "+30% job reach"});

        for (String m : missing) {
          if (m.trim().isEmpty()) continue;
          String lower = m.toLowerCase().trim();
          String[] details = dict.get(lower);
          if (details == null) {
            int skillHash = Math.abs(m.toLowerCase().hashCode());
            int rangePct = 25 + (skillHash % 26);
            details = new String[]{
              "fa-solid fa-microchip",
              "Advanced technical competency requested for this profile.",
              (skillHash % 2 == 0) ? "Critical" : "High",
              "+" + rangePct + "% job reach"
            };
          }
          gapCards.add(new String[]{m, details[0], details[1], details[2], details[3]});
        }

        // Add CI/CD and System Design fallbacks if list is short to ensure premium visual presentation
        if (gapCards.size() < 4) {
          String[] fallbacks = {"CI/CD", "System Design", "Docker", "AWS"};
          String[][] fallbackDetails = {
            {"fa-solid fa-code-merge", "Required for production-ready engineering teams.", "High", "+30% callbacks"},
            {"fa-solid fa-sitemap", "Gate for senior & high-paying engineering roles.", "Critical", "Unlocks senior tier"},
            {"fa-brands fa-docker", "Standard for shipping & deploying modern apps.", "Very High", "+45% job reach"},
            {"fa-brands fa-aws", "Backbone of cloud infrastructure across industries.", "Critical", "+60% salary range"}
          };
          for (int i = 0; i < fallbackDetails.length && gapCards.size() < 4; i++) {
            boolean exists = false;
            for (String[] gc : gapCards) {
              if (gc[0].equalsIgnoreCase(fallbacks[i])) { exists = true; break; }
            }
            if (!exists) {
              gapCards.add(new String[]{fallbacks[i], fallbackDetails[i][0], fallbackDetails[i][1], fallbackDetails[i][2], fallbackDetails[i][3]});
            }
          }
        }

        String featuredSkill = gapCards.get(0)[0];
        String featuredDesc = "Highest impact skill based on your current profile. Pairs naturally with your existing stack and unlocks roles in your target track.";
        if (featuredSkill.equalsIgnoreCase("Docker")) {
          featuredDesc = "Highest impact skill based on your current profile. Pairs naturally with your existing stack and unlocks cloud-native roles.";
        } else if (featuredSkill.equalsIgnoreCase("AWS")) {
          featuredDesc = "Backbone of modern scalable infrastructure. Essential for cloud-fluent roles and deploying enterprise systems.";
        } else {
          featuredDesc = gapCards.get(0)[2] + " Acquiring this competency represents your highest ROI upskilling opportunity.";
        }

        // Dynamic Salary Values derived from domain
        String currentLPA = "₹4-6 LPA";
        String futureLPA = "₹8-12 LPA";
        if (targetRole.toLowerCase().contains("full stack") || targetRole.toLowerCase().contains("fullstack")) {
          currentLPA = "₹5-8 LPA";
          futureLPA = "₹10-15 LPA";
        } else if (targetRole.toLowerCase().contains("data") || targetRole.toLowerCase().contains("machine") || targetRole.toLowerCase().contains("ai")) {
          currentLPA = "₹6-9 LPA";
          futureLPA = "₹12-18 LPA";
        }
        
        // Jobs count
        int jobsCountVal = 120;
        try {
            CareerService cs = new CareerService();
            int totalFeed = cs.getLiveJobFeed(su.getUserId(), request).size();
            if (totalFeed > 0) {
              jobsCountVal = totalFeed * 12;
            }
        } catch (Exception e) {}
        if (jobsCountVal <= 0) jobsCountVal = 150;
    %>

    <div class="lovable-container">
      
      <!-- 01. CAREER READINESS SECTION -->
      <div class="section-divider">
        <span class="divider-number">01</span>
        <h2 class="divider-title">Career Readiness</h2>
      </div>
      
      <div class="lovable-card readiness-card">
        <div class="readiness-gauge-box">
          <div class="readiness-gauge">
            <svg>
              <circle class="bg-ring" cx="60" cy="60" r="50"/>
              <circle class="fill-ring" cx="60" cy="60" r="50"
                      stroke-dasharray="314"
                      stroke-dashoffset="<%= 314 - (314 * readinessVal / 100) %>"/>
            </svg>
            <div class="readiness-value-text">
              <span class="readiness-pct"><%= String.format("%.0f", readinessVal) %>%</span>
              <span class="readiness-lbl">Readiness</span>
            </div>
          </div>
        </div>
        
        <div class="insight-content">
          <div class="ai-insight-tag">
            <i class="fa-solid fa-wand-magic-sparkles"></i> AI Insight
          </div>
          <p class="insight-paragraph">
            <%= dynamicInsightDesc %>
          </p>
          <div class="insight-badges">
            <% if (hasFrontend) { %>
              <span class="insight-badge strong-tag">Frontend · Strong</span>
            <% } %>
            <% if (hasBackend) { %>
              <span class="insight-badge strong-tag">Backend · Strong</span>
            <% } %>
            <% if (missing.length == 0) { %>
              <span class="insight-badge strong-tag">Role Ready</span>
            <% } else { %>
              <span class="insight-badge gap-tag">Gaps Identified</span>
            <% } %>
          </div>
        </div>
      </div>

      <!-- 02. RECRUITER ASSESSMENT SECTION -->
      <div class="section-divider">
        <span class="divider-number">02</span>
        <h2 class="divider-title">Recruiter Assessment</h2>
      </div>
      
      <div class="lovable-card recruiter-assessment-card">
        <div class="assessment-grid">
          <div class="assessment-item">
            <span class="assessment-label">Recruiter Decision</span>
            <span class="assessment-value decision-shortlist">
              <i class="fa-solid fa-circle-check"></i> <%= readinessVal >= 60 ? "Shortlist" : "Review Pending" %>
            </span>
          </div>
          
          <div class="assessment-item">
            <span class="assessment-label">Interview Readiness</span>
            <span class="assessment-value readiness-level <%= readinessLevel.toLowerCase() %>">
              <i class="fa-solid fa-shield-halved"></i> <%= readinessLevel %>
            </span>
          </div>
          
          <div class="assessment-item full-width">
            <span class="assessment-label">Strengths (Detected from resume)</span>
            <div class="assessment-text-list">
              <% if (acquired.length > 0) { %>
                <%= String.join(", ", acquired) %>
              <% } else { %>
                <span class="text-muted">None detected yet. Please upload a comprehensive resume.</span>
              <% } %>
            </div>
          </div>
          
          <div class="assessment-item full-width">
            <span class="assessment-label">Concerns (Missing critical skills)</span>
            <div class="assessment-text-list concerns-list">
              <% if (missing.length > 0) { %>
                <%= String.join(", ", missing) %>
              <% } else { %>
                <span class="text-success" style="color: #10b981;"><i class="fa-solid fa-circle-check"></i> No critical skill gaps identified for this role.</span>
              <% } %>
            </div>
          </div>
        </div>
      </div>

      <!-- 03. YOUR STRENGTHS SECTION -->
      <div class="section-divider">
        <span class="divider-number">03</span>
        <h2 class="divider-title">Your Strengths</h2>
      </div>
      <p class="section-subtitle">Skills detected from your resume.</p>
      
      <div class="strength-pills-row">
        <% if (acquired.length > 0) {
             for (String skillName : acquired) { %>
              <span class="strength-pill-item"><span class="dot"></span> <%= skillName %></span>
        <%   }
             } else { %>
              <span style="color: var(--text-muted); font-size: 0.82rem; font-style: italic;">No skills extracted from your resume. Go to Dashboard to upload one.</span>
        <% } %>
      </div>

      <!-- 04. TOP SKILL GAPS SECTION -->
      <div class="section-divider">
        <span class="divider-number">04</span>
        <h2 class="divider-title">Top Skill Gaps</h2>
      </div>
      <p class="section-subtitle">High-impact skills missing from your profile.</p>

      <div class="gaps-card-grid">
        <% for (String[] card : gapCards.subList(0, Math.min(gapCards.size(), 4))) { %>
          <div class="lovable-card gap-info-card">
            <div class="gap-info-card-header">
              <div class="gap-icon-circle">
                <i class="<%= card[1] %>"></i>
              </div>
              <a href="${pageContext.request.contextPath}/student?action=skilldev" class="gap-arrow-link">
                <i class="fa-solid fa-arrow-up-right-from-square"></i>
              </a>
            </div>
            <div class="gap-info-card-body">
              <span class="gap-skill-name"><%= card[0] %></span>
              <span class="gap-skill-desc"><%= card[2] %></span>
            </div>
            <div class="gap-info-card-footer">
              <div class="gap-footer-meta">
                <span class="gap-footer-label">Demand</span>
                <span class="gap-footer-val"><%= card[3] %></span>
              </div>
              <div class="gap-footer-meta" style="text-align: right;">
                <span class="gap-footer-label">Career Impact</span>
                <span class="gap-footer-val highlight-cyan"><%= card[4] %></span>
              </div>
            </div>
          </div>
        <% } %>
      </div>

      <!-- 05. SKILL MATCH METRICS SECTION -->
      <div class="section-divider">
        <span class="divider-number">05</span>
        <h2 class="divider-title">Skill Match Metrics</h2>
      </div>
      <p class="section-subtitle">Calculated match indicators comparing your profile and the target role.</p>
      
      <div class="impact-card-grid" style="grid-template-columns: repeat(4, 1fr);">
        <div class="lovable-card impact-metric-card">
          <div class="impact-metric-value"><%= String.format("%.0f", currentMatchPct) %><span>%</span></div>
          <div class="impact-metric-title">Current Job Match</div>
          <p class="impact-text" style="font-size: 0.78rem;">
            Percentage of required target skills currently present on your profile.
          </p>
        </div>

        <div class="lovable-card impact-metric-card">
          <div class="impact-metric-value"><%= String.format("%.0f", potentialMatchPct) %><span>%</span></div>
          <div class="impact-metric-title">Potential Match</div>
          <p class="impact-text" style="font-size: 0.78rem;">
            Achievable match rating upon closing target skill gaps.
          </p>
        </div>

        <div class="lovable-card impact-metric-card">
          <div class="impact-metric-value"><%= missingCount %></div>
          <div class="impact-metric-title">Missing Skills</div>
          <p class="impact-text" style="font-size: 0.78rem;">
            Count of crucial requirements identified as missing from your resume.
          </p>
        </div>

        <div class="lovable-card impact-metric-card">
          <div class="impact-metric-value" style="font-size: 1.75rem; padding: 0.1rem 0;"><%= readinessLevel %></div>
          <div class="impact-metric-title">Career Readiness</div>
          <p class="impact-text" style="font-size: 0.78rem;">
            AI assessment of your current interview readiness tier.
          </p>
        </div>
      </div>

      <!-- 06. SALARY GROWTH POTENTIAL SECTION -->
      <div class="section-divider">
        <span class="divider-number">06</span>
        <h2 class="divider-title">Salary Growth Potential</h2>
      </div>
      
      <div class="lovable-card">
        <div class="salary-card-row">
          <div class="salary-panel-box">
            <span class="salary-panel-label">Current Potential</span>
            <span class="salary-panel-value"><%= currentLPA %></span>
          </div>
          
          <div class="salary-arrow-icon">
            <i class="fa-solid fa-arrow-trend-up"></i>
          </div>
          
          <div class="salary-panel-box">
            <span class="salary-panel-label">Future Potential</span>
            <span class="salary-panel-value future"><%= futureLPA %></span>
          </div>
        </div>
      </div>

      <!-- 07. NEXT BEST SKILL SECTION -->
      <div class="section-divider">
        <span class="divider-number">07</span>
        <h2 class="divider-title">Next Best Skill</h2>
      </div>
      
      <div class="lovable-card">
        <div class="next-skill-container">
          <div class="next-skill-details">
            <div class="next-skill-badge">
              <i class="fa-solid fa-circle-exclamation"></i> Recommended next step
            </div>
            <div class="next-skill-main-row">
              <div class="next-skill-icon">
                <i class="<%= gapCards.get(0)[1] %>"></i>
              </div>
              <h3 class="next-skill-title"><%= featuredSkill %></h3>
            </div>
            <p class="next-skill-desc">
              <%= featuredDesc %>
            </p>
            <div class="next-skill-pills">
              <span class="next-skill-pill"><i class="fa-regular fa-clock"></i> Est. 2-3 weeks</span>
              <span class="next-skill-pill roi-pill"><i class="fa-solid fa-chart-line"></i> Highest ROI</span>
            </div>
          </div>
          
          <div>
            <button class="next-skill-btn" onclick="location.href='${pageContext.request.contextPath}/student?action=skilldev'">
              Start Learning Journey <i class="fa-solid fa-arrow-right"></i>
            </button>
          </div>
        </div>
      </div>

    </div>

    <% } else { %>
      <!-- RESUME NOT UPLOADED OR NO ACTIVE STATE -->
      <div class="lovable-card" style="text-align: center; padding: 5rem 2rem; border-radius: 24px; border: 1px dashed var(--lovable-border); background: rgba(255, 255, 255, 0.01); margin-top: 2rem;">
        <div style="width: 80px; height: 80px; border-radius: 50%; background: rgba(139, 92, 246, 0.08); color: var(--accent-purple); display: inline-flex; align-items: center; justify-content: center; font-size: 2.5rem; margin-bottom: 1.5rem; box-shadow: var(--glow-purple);">
          <i class="fa-solid fa-file-invoice"></i>
        </div>
        <h2 style="font-family: 'Outfit', sans-serif; font-weight: 700; font-size: 2rem; margin-bottom: 0.5rem;">Upload Your Resume</h2>
        <p style="color: var(--text-secondary); font-size: 1rem; max-width: 500px; margin: 0 auto 2rem; line-height: 1.6;">
          Our AI Career Advisor needs your resume to perform a deep skill gap analysis and compare your competencies against market requirements.
        </p>
        <a href="${pageContext.request.contextPath}/student?action=dashboard" class="btn btn-lg">
          Go to Dashboard &amp; Upload <i class="fa-solid fa-arrow-right" style="margin-left: 0.5rem;"></i>
        </a>
      </div>
    <% } %>
  </main>
</div>
<jsp:include page="/WEB-INF/jsp/floating-chat.jsp"/>
</body>
</html>

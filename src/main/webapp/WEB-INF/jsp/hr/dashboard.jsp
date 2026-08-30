<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Dashboard | CareerAssist HR</title>
  <jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
  <style>
    /* CSS additions for Cyan Glow and Glassmorphism */
    .glow-card {
      position: relative;
      border: 1px solid rgba(6, 182, 212, 0.15) !important;
      box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3), 0 0 15px rgba(6, 182, 212, 0.05) !important;
    }
    
    .glow-card:hover {
      border-color: rgba(6, 182, 212, 0.4) !important;
      box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.45), 0 0 25px rgba(6, 182, 212, 0.2) !important;
    }

    /* Stats Grid */
    .hr-stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    .hr-stat-card {
      background: var(--bg-card);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border-radius: 16px;
      padding: 1.5rem;
      position: relative;
      overflow: hidden;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      gap: 1.25rem;
    }

    .hr-stat-icon-wrap {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.35rem;
    }

    .hr-stat-info {
      display: flex;
      flex-direction: column;
    }

    .hr-stat-value {
      font-family: 'Outfit', sans-serif;
      font-size: 1.75rem;
      font-weight: 800;
      line-height: 1.2;
    }

    .hr-stat-label {
      font-size: 0.82rem;
      color: var(--text-secondary);
      font-weight: 500;
      margin-top: 0.15rem;
    }

    /* Second Row Layout */
    .grid-second-row {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    @media (max-width: 992px) {
      .grid-second-row {
        grid-template-columns: 1fr;
      }
    }

    /* Talent Overview Styles */
    .talent-overview-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 1rem;
      margin-top: 0.5rem;
    }

    .domain-mini-card {
      background: rgba(255, 255, 255, 0.02);
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 12px;
      padding: 1rem;
      transition: all 0.25s ease;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      min-height: 105px;
    }

    .domain-mini-card:hover {
      border-color: rgba(6, 182, 212, 0.3);
      background: rgba(6, 182, 212, 0.03);
      transform: translateY(-2px);
    }

    .domain-card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 0.5rem;
    }

    .domain-icon-box {
      width: 32px;
      height: 32px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(6, 182, 212, 0.1);
      color: var(--accent-cyan);
      font-size: 1rem;
    }

    .domain-pct {
      font-family: 'Outfit', sans-serif;
      font-size: 0.85rem;
      font-weight: 700;
      color: var(--accent-cyan);
    }

    .domain-name {
      font-family: 'Outfit', sans-serif;
      font-size: 0.9rem;
      font-weight: 600;
      color: var(--text-primary);
      margin-top: 0.25rem;
      margin-bottom: 0.15rem;
    }

    .domain-count {
      font-size: 0.75rem;
      color: var(--text-secondary);
    }

    .domain-progress-bar {
      height: 4px;
      background: rgba(255, 255, 255, 0.05);
      border-radius: 2px;
      overflow: hidden;
      margin-top: 0.5rem;
    }

    .domain-progress-fill {
      height: 100%;
      background: var(--grad-cyan-purple);
      border-radius: 2px;
    }

    /* Circular Score Progress chart */
    .circle-score-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 1rem 0;
    }

    .svg-circle-chart {
      width: 140px;
      height: 140px;
      transform: rotate(-90deg);
    }

    .svg-circle-bg {
      fill: none;
      stroke: rgba(255, 255, 255, 0.03);
      stroke-width: 10;
    }

    .svg-circle-fill {
      fill: none;
      stroke: url(#cyan-purple-grad);
      stroke-width: 10;
      stroke-linecap: round;
      stroke-dasharray: 377;
      stroke-dashoffset: 60; /* Displays 84% roughly */
      animation: progressAnim 1.5s ease-out forwards;
    }

    .score-overlay-text {
      position: absolute;
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
    }

    .score-number {
      font-family: 'Outfit', sans-serif;
      font-size: 1.85rem;
      font-weight: 900;
      color: var(--text-primary);
      line-height: 1;
    }

    .score-max {
      font-size: 0.75rem;
      color: var(--text-muted);
    }

    /* Third Row */
    .grid-third-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    @media (max-width: 768px) {
      .grid-third-row {
        grid-template-columns: 1fr;
      }
    }

    /* Skills Meters */
    .skill-meter-row {
      margin-bottom: 1rem;
    }

    .skill-meter-header {
      display: flex;
      justify-content: space-between;
      font-size: 0.82rem;
      font-weight: 600;
      margin-bottom: 0.35rem;
    }

    .skill-meter-bar {
      height: 6px;
      background: rgba(255, 255, 255, 0.05);
      border-radius: 3px;
      overflow: hidden;
    }

    .skill-meter-fill {
      height: 100%;
      border-radius: 3px;
      background: var(--grad-cyan-purple);
    }

    /* AI Insights Card styling */
    .insight-ai-box {
      background: rgba(139, 92, 246, 0.05);
      border: 1px dashed rgba(139, 92, 246, 0.2);
      border-radius: 12px;
      padding: 1rem;
      margin-bottom: 1rem;
      display: flex;
      gap: 0.85rem;
      align-items: flex-start;
    }

    .insight-ai-icon {
      color: var(--accent-purple);
      font-size: 1.15rem;
      margin-top: 0.15rem;
    }

    /* Tables Grid */
    .grid-fourth-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1.5rem;
    }

    @media (max-width: 1200px) {
      .grid-fourth-row {
        grid-template-columns: 1fr;
      }
    }

    /* Tables Styling */
    .table-container {
      overflow-x: auto;
    }

    .dashboard-table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
    }

    .dashboard-table th {
      padding: 0.75rem 1rem;
      font-size: 0.72rem;
      text-transform: uppercase;
      color: var(--text-muted);
      font-weight: 700;
      letter-spacing: 0.05em;
      border-bottom: 1px solid var(--border-color);
    }

    .dashboard-table td {
      padding: 0.9rem 1rem;
      font-size: 0.85rem;
      border-bottom: 1px solid rgba(255, 255, 255, 0.03);
      vertical-align: middle;
    }

    .dashboard-table tr:hover td {
      background: rgba(255, 255, 255, 0.01);
    }

    .tbl-avatar {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.04);
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 0.8rem;
    }

    .text-title {
      font-weight: 600;
      color: var(--text-primary);
      display: block;
    }

    .text-sub {
      font-size: 0.75rem;
      color: var(--text-secondary);
      display: block;
    }

    .tag-status {
      display: inline-block;
      padding: 0.2rem 0.5rem;
      border-radius: 6px;
      font-size: 0.7rem;
      font-weight: 700;
      text-transform: uppercase;
    }
  </style>
</head>
<body>
<div class="wrap">
  <jsp:include page="/WEB-INF/jsp/hr-nav.jsp"><jsp:param name="action" value="dashboard"/></jsp:include>

  <main class="main">
    <%
      User hrUser = (User) session.getAttribute("user");
      String hrName = hrUser != null ? hrUser.getFullName() : "Recruiter";
      String hrFirst = hrName.split(" ")[0];

      // Retrieve servlet variables
      Object studentsValObj = request.getAttribute("students");
      Object activeJobsValObj = request.getAttribute("activeJobs");
      Object appsValObj = request.getAttribute("apps");
      Object averageAtsValObj = request.getAttribute("averageAts");

      Integer studentsVal = studentsValObj != null ? (Integer) studentsValObj : null;
      Integer activeJobsVal = activeJobsValObj != null ? (Integer) activeJobsValObj : null;
      Integer appsVal = appsValObj != null ? (Integer) appsValObj : null;
      Double averageAtsVal = averageAtsValObj != null ? (Double) averageAtsValObj : null;

      String studentsText = (studentsVal != null && studentsVal > 0) ? String.valueOf(studentsVal) : "No data available";
      String activeJobsText = (activeJobsVal != null && activeJobsVal > 0) ? String.valueOf(activeJobsVal) : "No data available";
      String appsText = (appsVal != null && appsVal > 0) ? String.valueOf(appsVal) : "No data available";
      String averageAtsText = (averageAtsVal != null && averageAtsVal > 0) ? String.format("%.1f", averageAtsVal) : "No data available";

      // Dynamic Talent Overview categorization from database
      int fsCount = 0;
      int feCount = 0;
      int beCount = 0;
      int netCount = 0;
      int daCount = 0;
      int csCount = 0;
      int totalDomainClassified = 0;

      com.careerassist.dao.CareerDAO dynamicDao = new com.careerassist.service.CareerService().getDao();
      try {
        List<User> students = dynamicDao.listStudents();
        if (students != null) {
          for (User s : students) {
            List<String> studentSkills = dynamicDao.getUserSkills(s.getUserId());
            boolean isFs = false, isFe = false, isBe = false, isNet = false, isDa = false, isCs = false;
            
            for (String sk : studentSkills) {
              String skL = sk.toLowerCase();
              if (skL.contains("fullstack") || skL.contains("full stack") || skL.contains("mern") || skL.contains("mean") || skL.contains("django")) {
                isFs = true;
              }
              if (skL.contains("frontend") || skL.contains("front-end") || skL.contains("react") || skL.contains("angular") || skL.contains("vue") || skL.contains("html") || skL.contains("css") || skL.contains("javascript") || skL.contains("typescript")) {
                isFe = true;
              }
              if (skL.contains("backend") || skL.contains("back-end") || skL.contains("java") || skL.contains("spring") || skL.contains("springboot") || skL.contains("node") || skL.contains("express") || skL.contains("c#") || skL.contains("dotnet") || skL.contains("c++")) {
                isBe = true;
              }
              if (skL.contains("network") || skL.contains("cisco") || skL.contains("ccna") || skL.contains("dns") || skL.contains("tcp") || skL.contains("routing") || skL.contains("switching")) {
                isNet = true;
              }
              if (skL.contains("analytics") || skL.contains("analysis") || skL.contains("pandas") || skL.contains("numpy") || skL.contains("tableau") || skL.contains("power bi") || skL.contains("sql") || skL.contains("python")) {
                isDa = true;
              }
              if (skL.contains("security") || skL.contains("cyber") || skL.contains("pentest") || skL.contains("firewall") || skL.contains("hacking") || skL.contains("cryptography")) {
                isCs = true;
              }
            }
            
            if (isFs) { fsCount++; totalDomainClassified++; }
            else if (isFe) { feCount++; totalDomainClassified++; }
            else if (isBe) { beCount++; totalDomainClassified++; }
            
            if (isNet) { netCount++; totalDomainClassified++; }
            if (isDa) { daCount++; totalDomainClassified++; }
            if (isCs) { csCount++; totalDomainClassified++; }
          }
        }
      } catch (Exception e) {
        // Safe Catch
      }
    %>

    <!-- TOP NAVBAR -->
    <div class="top-navbar">
      <div>
        <span style="font-size: 0.72rem; font-weight: 700; text-transform: uppercase; color: var(--accent-cyan); letter-spacing: 0.05em; display: block; margin-bottom: 0.25rem;">Overview</span>
        <h1>HR <span class="header-accent-grad">Dashboard</span></h1>
      </div>
      <div class="navbar-user">
        <div class="notification-btn">
          <i class="fa-regular fa-bell"></i>
        </div>
        <div class="user-profile-badge">
          <div class="user-avatar">
            <%= hrFirst.substring(0, 1).toUpperCase() %>
          </div>
          <div class="user-info-text">
            <span class="user-name-span"><%= hrName %></span>
            <span class="user-sub-span">Talent Partner</span>
          </div>
        </div>
      </div>
    </div>

    <!-- FIRST ROW: STATS CARD GRID -->
    <div class="hr-stats-grid">
      <!-- Total Candidates -->
      <div class="hr-stat-card glow-card">
        <div class="hr-stat-icon-wrap" style="background: rgba(6, 182, 212, 0.1); border: 1px solid rgba(6, 182, 212, 0.2);">
          <i class="fa-solid fa-user-group" style="color: var(--accent-cyan);"></i>
        </div>
        <div class="hr-stat-info">
          <span class="hr-stat-value text-glow" style="color: var(--text-primary); font-size: <%= "No data available".equals(studentsText)? "1.05rem":"1.75rem"%>;"><%= studentsText %></span>
          <span class="hr-stat-label">Total Candidates</span>
        </div>
      </div>

      <!-- Active Jobs -->
      <div class="hr-stat-card glow-card">
        <div class="hr-stat-icon-wrap" style="background: rgba(139, 92, 246, 0.1); border: 1px solid rgba(139, 92, 246, 0.2);">
          <i class="fa-solid fa-briefcase" style="color: var(--accent-purple);"></i>
        </div>
        <div class="hr-stat-info">
          <span class="hr-stat-value" style="color: var(--text-primary); font-size: <%= "No data available".equals(activeJobsText)? "1.05rem":"1.75rem"%>;"><%= activeJobsText %></span>
          <span class="hr-stat-label">Active Jobs</span>
        </div>
      </div>

      <!-- Applications Received -->
      <div class="hr-stat-card glow-card">
        <div class="hr-stat-icon-wrap" style="background: rgba(217, 70, 239, 0.1); border: 1px solid rgba(217, 70, 239, 0.2);">
          <i class="fa-solid fa-file-signature" style="color: var(--accent-pink);"></i>
        </div>
        <div class="hr-stat-info">
          <span class="hr-stat-value" style="color: var(--text-primary); font-size: <%= "No data available".equals(appsText)? "1.05rem":"1.75rem"%>;"><%= appsText %></span>
          <span class="hr-stat-label">Applications Received</span>
        </div>
      </div>

      <!-- Average ATS Score -->
      <div class="hr-stat-card glow-card">
        <div class="hr-stat-icon-wrap" style="background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.2);">
          <i class="fa-solid fa-award" style="color: var(--accent-green);"></i>
        </div>
        <div class="hr-stat-info">
          <span class="hr-stat-value" style="color: var(--text-primary); font-size: <%= "No data available".equals(averageAtsText)? "1.05rem":"1.75rem"%>;"><%= averageAtsText %></span>
          <span class="hr-stat-label">Average ATS Score</span>
        </div>
      </div>
    </div>

    <!-- SECOND ROW: TALENT OVERVIEW & HIRING READINESS -->
    <div class="grid-second-row">
      <!-- Talent Overview Card -->
      <div class="card glow-card card-premium">
        <div class="card-title-row">
          <h3><i class="fa-solid fa-graduation-cap" style="color: var(--accent-cyan); margin-right: 0.5rem;"></i> Talent Overview</h3>
          <span style="font-size: 0.78rem; color: var(--text-secondary);">Resume Distribution by Domain</span>
        </div>

        <% if (totalDomainClassified == 0) { %>
          <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 3rem 1rem;">
            <i class="fa-regular fa-folder-open" style="font-size: 2.5rem; color: var(--text-muted); margin-bottom: 0.75rem;"></i>
            <p style="color: var(--text-muted); font-size: 0.9rem;">No data available</p>
          </div>
        <% } else { %>
          <div class="talent-overview-grid">
            <!-- Full Stack -->
            <div class="domain-mini-card">
              <div class="domain-card-header">
                <div class="domain-icon-box"><i class="fa-solid fa-laptop-code"></i></div>
                <span class="domain-pct"><%= Math.round((double)fsCount / totalDomainClassified * 100) %>%</span>
              </div>
              <div>
                <h4 class="domain-name">Full Stack</h4>
                <span class="domain-count"><%= fsCount %> Candidates</span>
              </div>
              <div class="domain-progress-bar">
                <div class="domain-progress-fill" style="width: <%= ((double)fsCount / totalDomainClassified * 100) %>%;"></div>
              </div>
            </div>

            <!-- Frontend -->
            <div class="domain-mini-card">
              <div class="domain-card-header">
                <div class="domain-icon-box"><i class="fa-solid fa-window-maximize"></i></div>
                <span class="domain-pct"><%= Math.round((double)feCount / totalDomainClassified * 100) %>%</span>
              </div>
              <div>
                <h4 class="domain-name">Frontend</h4>
                <span class="domain-count"><%= feCount %> Candidates</span>
              </div>
              <div class="domain-progress-bar">
                <div class="domain-progress-fill" style="width: <%= ((double)feCount / totalDomainClassified * 100) %>%;"></div>
              </div>
            </div>

            <!-- Backend -->
            <div class="domain-mini-card">
              <div class="domain-card-header">
                <div class="domain-icon-box"><i class="fa-solid fa-server"></i></div>
                <span class="domain-pct"><%= Math.round((double)beCount / totalDomainClassified * 100) %>%</span>
              </div>
              <div>
                <h4 class="domain-name">Backend</h4>
                <span class="domain-count"><%= beCount %> Candidates</span>
              </div>
              <div class="domain-progress-bar">
                <div class="domain-progress-fill" style="width: <%= ((double)beCount / totalDomainClassified * 100) %>%;"></div>
              </div>
            </div>

            <!-- Networking -->
            <div class="domain-mini-card">
              <div class="domain-card-header">
                <div class="domain-icon-box"><i class="fa-solid fa-network-wired"></i></div>
                <span class="domain-pct"><%= Math.round((double)netCount / totalDomainClassified * 100) %>%</span>
              </div>
              <div>
                <h4 class="domain-name">Networking</h4>
                <span class="domain-count"><%= netCount %> Candidates</span>
              </div>
              <div class="domain-progress-bar">
                <div class="domain-progress-fill" style="width: <%= ((double)netCount / totalDomainClassified * 100) %>%;"></div>
              </div>
            </div>

            <!-- Data Analytics -->
            <div class="domain-mini-card">
              <div class="domain-card-header">
                <div class="domain-icon-box"><i class="fa-solid fa-chart-line"></i></div>
                <span class="domain-pct"><%= Math.round((double)daCount / totalDomainClassified * 100) %>%</span>
              </div>
              <div>
                <h4 class="domain-name">Data Analytics</h4>
                <span class="domain-count"><%= daCount %> Candidates</span>
              </div>
              <div class="domain-progress-bar">
                <div class="domain-progress-fill" style="width: <%= ((double)daCount / totalDomainClassified * 100) %>%;"></div>
              </div>
            </div>

            <!-- Cyber Security -->
            <div class="domain-mini-card">
              <div class="domain-card-header">
                <div class="domain-icon-box"><i class="fa-solid fa-shield-halved"></i></div>
                <span class="domain-pct"><%= Math.round((double)csCount / totalDomainClassified * 100) %>%</span>
              </div>
              <div>
                <h4 class="domain-name">Cyber Security</h4>
                <span class="domain-count"><%= csCount %> Candidates</span>
              </div>
              <div class="domain-progress-bar">
                <div class="domain-progress-fill" style="width: <%= ((double)csCount / totalDomainClassified * 100) %>%;"></div>
              </div>
            </div>
          </div>
        <% } %>
      </div>

      <!-- Hiring Readiness Circular Score -->
      <div class="card glow-card card-premium" style="display: flex; flex-direction: column; align-items: center; justify-content: space-between;">
        <div class="card-title-row" style="width: 100%;">
          <h3><i class="fa-solid fa-chart-simple" style="color: var(--accent-purple); margin-right: 0.5rem;"></i> Hiring Readiness</h3>
        </div>

        <div class="circle-score-container" style="position: relative;">
          <svg class="svg-circle-chart">
            <defs>
              <linearGradient id="cyan-purple-grad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="var(--accent-cyan)"/>
                <stop offset="100%" stop-color="var(--accent-purple)"/>
              </linearGradient>
            </defs>
            <circle class="svg-circle-bg" cx="70" cy="70" r="60"/>
            <circle class="svg-circle-fill" cx="70" cy="70" r="60"/>
          </svg>
          <div class="score-overlay-text" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); display: flex; flex-direction: column; align-items: center;">
            <span class="score-number"><%= averageAtsVal != null && averageAtsVal > 0 ? String.format("%.0f%%", averageAtsVal) : "No data" %></span>
            <span class="score-max">Optimal</span>
          </div>
        </div>

        <p style="font-size: 0.78rem; text-align: center; color: var(--text-secondary); margin-top: 0.5rem;">
          Based on average candidate ATS scores across databases.
        </p>
      </div>
    </div>

    <!-- THIRD ROW: SKILLS & AI INSIGHTS -->
    <div class="grid-third-row">
      <!-- Top Skill Domains -->
      <div class="card glow-card">
        <div class="card-title-row">
          <h3><i class="fa-solid fa-brain" style="color: var(--accent-pink); margin-right: 0.5rem;"></i> Top Skill Domains</h3>
        </div>
        
        <% if (totalDomainClassified == 0) { %>
          <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 2rem 1rem;">
            <i class="fa-regular fa-folder-open" style="font-size: 2rem; color: var(--text-muted); margin-bottom: 0.5rem;"></i>
            <p style="color: var(--text-muted); font-size: 0.85rem;">No data available</p>
          </div>
        <% } else { %>
          <div class="skill-meter-row">
            <div class="skill-meter-header">
              <span>Software Development</span>
              <span style="color: var(--accent-cyan);"><%= Math.round((double)(fsCount + feCount + beCount) / totalDomainClassified * 100) %>% pool</span>
            </div>
            <div class="skill-meter-bar">
              <div class="skill-meter-fill" style="width: <%= ((double)(fsCount + feCount + beCount) / totalDomainClassified * 100) %>%; background: var(--grad-cyan-purple);"></div>
            </div>
          </div>

          <div class="skill-meter-row">
            <div class="skill-meter-header">
              <span>Data Science &amp; AI</span>
              <span style="color: var(--accent-pink);"><%= Math.round((double)daCount / totalDomainClassified * 100) %>% pool</span>
            </div>
            <div class="skill-meter-bar">
              <div class="skill-meter-fill" style="width: <%= ((double)daCount / totalDomainClassified * 100) %>%; background: var(--grad-purple-pink);"></div>
            </div>
          </div>

          <div class="skill-meter-row">
            <div class="skill-meter-header">
              <span>Networking &amp; Infrastructure</span>
              <span style="color: var(--accent-purple);"><%= Math.round((double)netCount / totalDomainClassified * 100) %>% pool</span>
            </div>
            <div class="skill-meter-bar">
              <div class="skill-meter-fill" style="width: <%= ((double)netCount / totalDomainClassified * 100) %>%; background: var(--grad-cyan-purple);"></div>
            </div>
          </div>

          <div class="skill-meter-row">
            <div class="skill-meter-header">
              <span>Cyber Security</span>
              <span style="color: var(--accent-yellow);"><%= Math.round((double)csCount / totalDomainClassified * 100) %>% pool</span>
            </div>
            <div class="skill-meter-bar">
              <div class="skill-meter-fill" style="width: <%= ((double)csCount / totalDomainClassified * 100) %>%; background: linear-gradient(135deg, var(--accent-purple) 0%, var(--accent-yellow) 100%);"></div>
            </div>
          </div>
        <% } %>
      </div>

      <!-- AI Insights -->
      <div class="card glow-card">
        <div class="card-title-row">
          <h3><i class="fa-solid fa-wand-magic-sparkles" style="color: var(--accent-cyan); margin-right: 0.5rem;"></i> AI Talent Insights</h3>
        </div>

        <% if (totalDomainClassified == 0) { %>
          <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 2rem 1rem;">
            <i class="fa-solid fa-microchip" style="font-size: 2rem; color: var(--text-muted); margin-bottom: 0.5rem;"></i>
            <p style="color: var(--text-muted); font-size: 0.85rem;">No data available</p>
          </div>
        <% } else { %>
          <div class="insight-ai-box">
            <div class="insight-ai-icon"><i class="fa-solid fa-bolt"></i></div>
            <div>
              <h4 style="font-size: 0.88rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">Candidate Pipeline Glow</h4>
              <p style="font-size: 0.78rem; color: var(--text-secondary); line-height: 1.4;">
                Full Stack &amp; Backend developers represent <%= Math.round((double)(fsCount + beCount) / totalDomainClassified * 100) %>% of the current talent database. Focus your sourcing activities accordingly.
              </p>
            </div>
          </div>

          <div class="insight-ai-box" style="background: rgba(6, 182, 212, 0.05); border-color: rgba(6, 182, 212, 0.2);">
            <div class="insight-ai-icon" style="color: var(--accent-cyan);"><i class="fa-solid fa-circle-info"></i></div>
            <div>
              <h4 style="font-size: 0.88rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">ATS Benchmark Summary</h4>
              <p style="font-size: 0.78rem; color: var(--text-secondary); line-height: 1.4;">
                The current average parsed resume compatibility matches at <%= averageAtsVal != null ? String.format("%.1f%%", averageAtsVal) : "N/A" %>. Candidate pool quality matches historical optimal levels.
              </p>
            </div>
          </div>
        <% } %>
      </div>
    </div>

    <!-- FOURTH ROW: RECENT CANDIDATES & RECENT JOBS -->
    <div class="grid-fourth-row">
      <!-- Recent Candidates Table -->
      <div class="card glow-card">
        <div class="card-title-row">
          <h3><i class="fa-solid fa-users" style="color: var(--accent-cyan); margin-right: 0.5rem;"></i> Recent Candidates</h3>
          <a href="${pageContext.request.contextPath}/hr?action=talent-pool" class="btn btn-sm btn-outline">View Pool</a>
        </div>
        
        <div class="table-container">
          <table class="dashboard-table">
            <thead>
              <tr>
                <th>Candidate</th>
                <th>Domain / Role</th>
                <th>ATS Score</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <%
                List<java.util.Map<String, Object>> recentCandidates = (List<java.util.Map<String, Object>>) request.getAttribute("recentCandidates");
                if (recentCandidates == null || recentCandidates.isEmpty()) {
              %>
                <tr>
                  <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 2rem;">No data available</td>
                </tr>
              <%
                } else {
                  for (java.util.Map<String, Object> candidate : recentCandidates) {
                    int cid = (Integer) candidate.get("userId");
                    String cname = (String) candidate.get("fullName");
                    String cemail = (String) candidate.get("email");
                    String cfile = (String) candidate.get("fileName");
                    
                    // Fetch ATS Score
                    Integer scoreVal = null;
                    try { scoreVal = dynamicDao.getStudentAtsScore(cid); } catch(Exception e){}
                    String scoreText = scoreVal != null ? String.valueOf(scoreVal) : "—";
                    
                    // Predict Role from skills
                    List<String> cskills = new ArrayList<>();
                    try { cskills = dynamicDao.getUserSkills(cid); } catch(Exception e){}
                    String predRole = "Candidate";
                    String skillString = "";
                    if (!cskills.isEmpty()) {
                      skillString = String.join(", ", cskills);
                      if (skillString.toLowerCase().contains("fullstack") || skillString.toLowerCase().contains("full stack")) predRole = "Full Stack Developer";
                      else if (skillString.toLowerCase().contains("frontend") || skillString.toLowerCase().contains("front-end")) predRole = "Frontend Developer";
                      else if (skillString.toLowerCase().contains("backend") || skillString.toLowerCase().contains("back-end")) predRole = "Backend Developer";
                      else if (skillString.toLowerCase().contains("network")) predRole = "Network Engineer";
                      else if (skillString.toLowerCase().contains("analyst") || skillString.toLowerCase().contains("analytics")) predRole = "Data Analyst";
                      else if (skillString.toLowerCase().contains("security") || skillString.toLowerCase().contains("cyber")) predRole = "Cyber Security Analyst";
                    }
                    
                    String initials = "";
                    if (cname != null && cname.length() > 0) {
                      String[] parts = cname.split(" ");
                      if (parts.length > 1) {
                        initials = parts[0].substring(0,1).toUpperCase() + parts[1].substring(0,1).toUpperCase();
                      } else {
                        initials = cname.substring(0, Math.min(2, cname.length())).toUpperCase();
                      }
                    } else {
                      initials = "C";
                    }
              %>
                  <tr>
                    <td>
                      <div style="display: flex; align-items: center; gap: 0.75rem;">
                        <div class="tbl-avatar" style="border: 1px solid var(--accent-cyan); color: var(--accent-cyan);"><%= initials %></div>
                        <div>
                          <span class="text-title"><%= cname %></span>
                          <span class="text-sub"><%= cemail %></span>
                        </div>
                      </div>
                    </td>
                    <td>
                      <span class="text-title"><%= predRole %></span>
                      <span class="text-sub" style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><%= skillString.isEmpty() ? "No skills extracted" : skillString %></span>
                    </td>
                    <td>
                      <strong style="color: var(--accent-cyan); font-family: 'Outfit'; font-size: 0.95rem;"><%= scoreText %></strong>
                    </td>
                    <td>
                      <span class="tag-status" style="background: rgba(6, 182, 212, 0.1); color: var(--accent-cyan);">Applied</span>
                    </td>
                  </tr>
              <%
                  }
                }
              %>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Recent Jobs Table -->
      <div class="card glow-card">
        <div class="card-title-row">
          <h3><i class="fa-solid fa-briefcase" style="color: var(--accent-purple); margin-right: 0.5rem;"></i> Active Job Postings</h3>
          <a href="${pageContext.request.contextPath}/hr?action=post-job" class="btn btn-sm btn-outline">Manage Jobs</a>
        </div>
        
        <div class="table-container">
          <table class="dashboard-table">
            <thead>
              <tr>
                <th>Job Title</th>
                <th>Location</th>
                <th>Applicants</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <%
                List<Job> dbRecentJobs = (List<Job>) request.getAttribute("recentJobs");
                if (dbRecentJobs == null || dbRecentJobs.isEmpty()) {
              %>
                <tr>
                  <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 2rem;">No data available</td>
                </tr>
              <%
                } else {
                  for (Job j : dbRecentJobs) {
                    // Count applications for this job
                    int jobAppsCount = 0;
                    try {
                      List<com.careerassist.model.Application> allApps = dynamicDao.listAllApplications();
                      for (com.careerassist.model.Application ap : allApps) {
                        if (ap.getJobId() != null && ap.getJobId() == j.getJobId()) {
                          jobAppsCount++;
                        }
                      }
                    } catch (Exception e){}
              %>
                  <tr>
                    <td>
                      <span class="text-title"><%= j.getTitle() %></span>
                      <span class="text-sub"><%= j.getCompany() %></span>
                    </td>
                    <td>
                      <span class="text-title"><%= j.getLocation() != null && !j.getLocation().isEmpty() ? j.getLocation() : "Remote" %></span>
                      <span class="text-sub"><%= j.getSalaryRange() != null && !j.getSalaryRange().isEmpty() ? j.getSalaryRange() : "Negotiable" %></span>
                    </td>
                    <td>
                      <strong style="color: var(--text-primary); font-family: 'Outfit';"><%= jobAppsCount %> Candidates</strong>
                    </td>
                    <td>
                      <span class="tag-status" style="background: rgba(16, 185, 129, 0.1); color: var(--accent-green);"><%= j.getStatus() %></span>
                    </td>
                  </tr>
              <%
                  }
                }
              %>
            </tbody>
          </table>
        </div>
      </div>
    </div>

  </main>
</div>
</body>
</html>

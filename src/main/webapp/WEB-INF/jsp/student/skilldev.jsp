<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Skill Hub | NexusAI</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
<style>
  /* ═══════════════════════════════════════════════
     TAB SYSTEM
  ═══════════════════════════════════════════════ */
  .hub-tabs {
    display: inline-flex;
    gap: 0.35rem;
    margin-bottom: 2rem;
    background: rgba(15, 22, 42, 0.6);
    border: 1px solid var(--border-color);
    padding: 0.3rem;
    border-radius: 9999px;
  }
  .hub-tab-btn {
    padding: 0.45rem 1.1rem;
    background: transparent;
    border: none;
    font-weight: 600;
    color: var(--text-secondary);
    cursor: pointer;
    transition: all 0.2s ease;
    font-size: 0.82rem;
    border-radius: 9999px;
    letter-spacing: 0.01em;
  }
  .hub-tab-btn:hover { color: var(--text-primary); }
  .hub-tab-btn.active {
    background: var(--grad-cyan-purple);
    color: #fff;
    box-shadow: 0 0 18px rgba(6,182,212,0.35);
  }
  .hub-tab-panel { display: none; animation: tabFadeIn 0.3s ease-out; }
  .hub-tab-panel.active { display: block; }
  @keyframes tabFadeIn {
    from { opacity: 0; transform: translateY(6px); }
    to   { opacity: 1; transform: translateY(0); }
  }

  /* ═══════════════════════════════════════════════
     CAREER JOURNEY MAP — FULL REDESIGN
  ═══════════════════════════════════════════════ */
  .cjm-wrapper {
    position: relative;
    background: #04060e;
    border-radius: 20px;
    border: 1px solid rgba(6,182,212,0.12);
    overflow: hidden;
    box-shadow: 0 0 60px rgba(6,182,212,0.04), 0 0 120px rgba(139,92,246,0.04);
  }

  /* Top bar like Google Maps header */
  .cjm-topbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.9rem 1.25rem;
    background: rgba(8,12,28,0.95);
    border-bottom: 1px solid rgba(255,255,255,0.06);
    backdrop-filter: blur(12px);
    z-index: 10;
    position: relative;
  }
  .cjm-topbar-left { display: flex; align-items: center; gap: 0.75rem; }
  .cjm-logo-pin {
    width: 32px; height: 32px;
    background: linear-gradient(135deg, #06b6d4, #8b5cf6);
    border-radius: 50% 50% 50% 0;
    transform: rotate(-45deg);
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
  }
  .cjm-logo-pin::after {
    content: '';
    width: 12px; height: 12px;
    background: #04060e;
    border-radius: 50%;
    transform: rotate(45deg);
  }
  .cjm-title-text h3 {
    font-family: 'Outfit', sans-serif;
    font-size: 1rem;
    font-weight: 700;
    color: var(--text-primary);
    line-height: 1.2;
  }
  .cjm-title-text span {
    font-size: 0.72rem;
    color: var(--text-secondary);
  }
  .cjm-route-pill {
    font-size: 0.68rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    padding: 0.22rem 0.65rem;
    border-radius: 20px;
  }
  .cjm-route-pill.demo {
    background: rgba(245,158,11,0.1);
    color: var(--accent-yellow);
    border: 1px solid rgba(245,158,11,0.25);
  }
  .cjm-route-pill.live {
    background: rgba(16,185,129,0.1);
    color: var(--accent-green);
    border: 1px solid rgba(16,185,129,0.25);
  }
  .cjm-zoom-controls {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
  .cjm-zoom-btn {
    width: 28px; height: 28px;
    background: rgba(255,255,255,0.06);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 6px;
    color: var(--text-primary);
    font-size: 1rem;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all 0.15s;
    font-weight: 700;
  }
  .cjm-zoom-btn:hover {
    background: rgba(6,182,212,0.15);
    border-color: rgba(6,182,212,0.4);
    color: var(--accent-cyan);
  }

  /* Map canvas area */
  .cjm-map-area {
    display: flex;
    height: 560px;
    position: relative;
    overflow: hidden;
    cursor: grab;
  }
  .cjm-map-area:active { cursor: grabbing; }

  /* SVG canvas for the actual map */
  .cjm-svg-canvas {
    flex: 1;
    overflow: hidden;
    position: relative;
  }
  #cjmSvg {
    width: 100%;
    height: 100%;
    display: block;
  }

  /* Right side detail panel */
  .cjm-detail-sidebar {
    width: 300px;
    flex-shrink: 0;
    background: rgba(8,12,28,0.97);
    border-left: 1px solid rgba(255,255,255,0.07);
    display: flex;
    flex-direction: column;
    overflow-y: auto;
    transition: transform 0.35s cubic-bezier(0.4,0,0.2,1);
  }
  .cjm-sidebar-placeholder {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 2rem 1.5rem;
    text-align: center;
    color: var(--text-secondary);
  }
  .cjm-sidebar-placeholder .pin-icon {
    width: 56px; height: 56px;
    background: radial-gradient(circle, rgba(139,92,246,0.15) 0%, transparent 70%);
    border: 1px solid rgba(139,92,246,0.2);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.5rem;
    margin: 0 auto 1.25rem;
    animation: pinBob 3s ease-in-out infinite;
  }
  @keyframes pinBob {
    0%,100% { transform: translateY(0); }
    50%      { transform: translateY(-6px); }
  }
  .cjm-sidebar-placeholder h4 {
    font-family: 'Outfit', sans-serif;
    font-size: 1rem;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 0.5rem;
  }
  .cjm-sidebar-placeholder p {
    font-size: 0.79rem;
    line-height: 1.55;
    color: var(--text-secondary);
  }

  /* Node detail pane */
  .cjm-node-detail {
    display: none;
    padding: 1.25rem;
    flex-direction: column;
    gap: 0;
    animation: tabFadeIn 0.25s ease-out;
  }
  .cjm-node-detail.visible { display: flex; }
  .cjm-node-detail-header {
    padding-bottom: 1rem;
    border-bottom: 1px solid rgba(255,255,255,0.07);
    margin-bottom: 1rem;
  }
  .cjm-milestone-chip {
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
    font-size: 0.65rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.07em;
    background: rgba(139,92,246,0.12);
    color: var(--accent-purple);
    border: 1px solid rgba(139,92,246,0.25);
    padding: 0.18rem 0.5rem;
    border-radius: 4px;
    margin-bottom: 0.5rem;
  }
  .cjm-node-detail-header h3 {
    font-family: 'Outfit', sans-serif;
    font-size: 1.3rem;
    font-weight: 800;
    color: #fff;
    line-height: 1.2;
  }
  .cjm-detail-section {
    margin-bottom: 1rem;
  }
  .cjm-detail-section-title {
    display: flex;
    align-items: center;
    gap: 0.4rem;
    font-size: 0.72rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--text-primary);
    margin-bottom: 0.4rem;
  }
  .cjm-detail-section-title i { font-size: 0.75rem; }
  .cjm-detail-section p {
    font-size: 0.8rem;
    color: var(--text-secondary);
    line-height: 1.55;
  }
  .cjm-detail-close {
    margin-top: auto;
    padding-top: 0.75rem;
    border-top: 1px solid rgba(255,255,255,0.06);
  }
  .cjm-detail-close button {
    width: 100%;
    padding: 0.55rem;
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 8px;
    color: var(--text-secondary);
    font-size: 0.78rem;
    cursor: pointer;
    transition: all 0.15s;
  }
  .cjm-detail-close button:hover {
    background: rgba(6,182,212,0.08);
    color: var(--accent-cyan);
    border-color: rgba(6,182,212,0.3);
  }

  /* Bottom status bar */
  .cjm-statusbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.55rem 1.25rem;
    background: rgba(8,12,28,0.9);
    border-top: 1px solid rgba(255,255,255,0.05);
    font-size: 0.72rem;
    color: var(--text-secondary);
    gap: 1rem;
  }
  .cjm-statusbar-item {
    display: flex;
    align-items: center;
    gap: 0.35rem;
  }
  .cjm-statusbar-item .dot {
    width: 6px; height: 6px;
    border-radius: 50%;
  }
  .cjm-statusbar-item .dot.green { background: var(--accent-green); }
  .cjm-statusbar-item .dot.cyan  { background: var(--accent-cyan);  }
  .cjm-statusbar-item .dot.purple { background: var(--accent-purple); }

  /* Minimap indicator */
  .cjm-minimap {
    position: absolute;
    bottom: 54px;
    right: 312px;
    width: 120px;
    height: 70px;
    background: rgba(4,6,14,0.85);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 8px;
    overflow: hidden;
    z-index: 5;
    pointer-events: none;
  }
  #cjmMinimapSvg {
    width: 100%;
    height: 100%;
  }

  /* SVG node styles (applied via JS but reference in CSS) */
  .cjm-map-node-group { cursor: pointer; }
  .cjm-map-node-group:hover .node-ring { transform: scale(1.2); }

  /* ═══════════════════════════════════════════════
     COURSE / CERT CARDS
  ═══════════════════════════════════════════════ */
  .cert-card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(272px, 1fr));
    gap: 1.1rem;
    margin-top: 1rem;
  }
  .cert-premium-card {
    background: var(--bg-card);
    border-radius: 16px;
    padding: 1.4rem 1.5rem;
    border: 1px solid var(--border-color);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    min-height: 190px;
    transition: all 0.22s ease;
    position: relative;
    overflow: hidden;
  }
  .cert-premium-card::before {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(135deg, rgba(6,182,212,0.03) 0%, transparent 60%);
    opacity: 0;
    transition: opacity 0.22s;
  }
  .cert-premium-card:hover { transform: translateY(-3px); border-color: rgba(6,182,212,0.2); }
  .cert-premium-card:hover::before { opacity: 1; }
  .cert-badge {
    align-self: flex-start;
    font-size: 0.63rem;
    font-weight: 700;
    text-transform: uppercase;
    background: rgba(6,182,212,0.1);
    color: var(--accent-cyan);
    padding: 0.18rem 0.45rem;
    border-radius: 5px;
    margin-bottom: 0.7rem;
    letter-spacing: 0.05em;
  }
  .cert-title {
    font-size: 1rem;
    font-weight: 700;
    margin-bottom: 0.45rem;
    color: var(--text-primary);
    line-height: 1.35;
  }
  .cert-desc {
    font-size: 0.78rem;
    color: var(--text-secondary);
    margin-bottom: 1.1rem;
    line-height: 1.5;
    flex: 1;
  }
  .cert-link {
    font-size: 0.78rem;
    font-weight: 700;
    color: var(--accent-cyan);
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    transition: gap 0.15s;
  }
  .cert-link:hover { gap: 0.5rem; }

  @media (max-width: 768px) {
    .cjm-map-area {
      flex-direction: column;
      height: 800px;
    }
    .cjm-detail-sidebar {
      width: 100%;
      height: 320px;
      border-left: none;
      border-top: 1px solid rgba(255,255,255,0.07);
    }
    .cjm-minimap {
      right: 20px;
      bottom: 340px;
    }
  }
</style>
</head>
<body>
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="skilldev"/></jsp:include>
<main class="main">
  <%
  User su = (User) session.getAttribute("user");
  SkillGap gap = (SkillGap) request.getAttribute("gap");
  List<String> skills = (List<String>) request.getAttribute("skills");
  List<SkillLearningHub> hubs = (List<SkillLearningHub>) request.getAttribute("hubs");
  List<String> resumeSkills = (List<String>) request.getAttribute("resumeSkills");

  CareerContext cctx = (CareerContext) request.getAttribute("careerContext");
  JobDomain currentDomain = cctx != null ? cctx.getRoleDomainEnum() : JobDomain.GENERAL;
  if (currentDomain == null) currentDomain = JobDomain.GENERAL;

  double overallMatch = 87.0;
  if (gap != null) {
    overallMatch = 100.0 - gap.getGapPercentage();
  }
  %>

  <!-- TOP NAVBAR -->
  <div class="top-navbar">
    <div class="navbar-user">
      <div class="notification-btn"><i class="fa-regular fa-bell"></i></div>
      <div class="user-profile-badge">
        <div class="user-avatar">
          <%= su != null && su.getFullName() != null && !su.getFullName().isEmpty() ? su.getFullName().substring(0,1).toUpperCase() : "U" %>
        </div>
        <div class="user-info-text">
          <span class="user-name-span"><%= su != null ? su.getFullName() : "Student" %></span>
          <span class="user-sub-span">Final Year · CSE</span>
        </div>
      </div>
    </div>
  </div>

  <!-- HEADER -->
  <div style="margin-bottom:2rem;">
    <h1>Skill Hub</h1>
    <p style="color:var(--text-secondary);font-size:0.88rem;">Personalized career navigation and skill development resources.</p>
  </div>

  <% if (session.getAttribute("msg") != null) { %>
    <div class="alert ok"><i class="fa-solid fa-circle-check"></i> <%= session.getAttribute("msg") %><% session.removeAttribute("msg"); %></div>
  <% } %>

  <!-- TABS -->
  <div class="hub-tabs">
    <button id="tab-btn-courses"    class="hub-tab-btn active" onclick="switchTab('courses-panel',this)">Courses</button>
    <button id="tab-btn-roadmap"    class="hub-tab-btn"        onclick="switchTab('roadmap-panel',this)">Roadmap</button>
    <button id="tab-btn-gap"        class="hub-tab-btn"        onclick="switchTab('gap-panel',this)">Skill Gap</button>
    <button id="tab-btn-practice"   class="hub-tab-btn"        onclick="switchTab('practice-panel',this)">Practice</button>
    <button id="tab-btn-cert"       class="hub-tab-btn"        onclick="switchTab('cert-panel',this)">Certifications</button>
    <button id="tab-btn-playlists"  class="hub-tab-btn"        onclick="switchTab('playlists-panel',this)">Playlists</button>
  </div>

  <!-- ══════════════════════════════════════════════════════
       PANEL 0: COURSES
  ══════════════════════════════════════════════════════ -->
  <div id="courses-panel" class="hub-tab-panel active">
    <div class="card" style="margin-bottom:1.5rem;">
      <h3>Curated Course Recommendations</h3>
      <p style="color:var(--text-secondary);font-size:0.85rem;margin-top:0.25rem;">
        Top-rated educational paths to build base concepts and master missing competencies in your target domain.
      </p>
    </div>
    <div class="cert-card-grid">
      <% if (currentDomain == JobDomain.DATA) { %>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-cyan);">
          <div>
            <span class="cert-badge">Beginner · Google</span>
            <h3 class="cert-title">Google Data Analytics Professional Certificate</h3>
            <p class="cert-desc">Learn spreadsheet analysis, SQL querying, Tableau visualizations, and R programming basics in this comprehensive foundational program.</p>
          </div>
          <a href="https://www.coursera.org/professional-certificates/google-data-analytics" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-purple);">
          <div>
            <span class="cert-badge">Intermediate · Udemy</span>
            <h3 class="cert-title">Python for Data Science &amp; Machine Learning</h3>
            <p class="cert-desc">Dive deep into NumPy, Pandas, Seaborn, Matplotlib, Scikit-Learn, TensorFlow, and more. A hands-on bootcamp with real-world datasets.</p>
          </div>
          <a href="https://www.udemy.com/course/python-for-data-science-and-machine-learning-bootcamp/" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-green);">
          <div>
            <span class="cert-badge">Beginner · IBM</span>
            <h3 class="cert-title">IBM Data Science Professional Certificate</h3>
            <p class="cert-desc">Master Python, SQL, data analysis, visualization, and machine learning models while working with databases and cloud tools.</p>
          </div>
          <a href="https://www.coursera.org/professional-certificates/ibm-data-science" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-yellow);">
          <div>
            <span class="cert-badge">Advanced · DataTalks</span>
            <h3 class="cert-title">Machine Learning Zoomcamp</h3>
            <p class="cert-desc">A rigorous, project-based engineering program focused on deploying machine learning models in production, deep learning, and Kubernetes integration.</p>
          </div>
          <a href="https://github.com/DataTalksClub/machine-learning-zoomcamp" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
      <% } else if (currentDomain == JobDomain.NETWORKING) { %>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-cyan);">
          <div>
            <span class="cert-badge">Beginner · Google</span>
            <h3 class="cert-title">Google IT Support Professional Certificate</h3>
            <p class="cert-desc">Understand network protocols, routing mechanisms, DNS configurations, troubleshooting, and modern system administration tools.</p>
          </div>
          <a href="https://www.coursera.org/professional-certificates/google-it-support" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-purple);">
          <div>
            <span class="cert-badge">Intermediate · Jeremy's IT Lab</span>
            <h3 class="cert-title">CCNA 200-301 Complete Course</h3>
            <p class="cert-desc">The most popular CCNA course covering IP routing protocols (OSPF, BGP), VLANs, subnetting, network security, and configuration drills.</p>
          </div>
          <a href="https://www.youtube.com/playlist?list=PLxbwEAP-dxKH1gTAFMDFyKiFJyU5cUMba" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-green);">
          <div>
            <span class="cert-badge">Beginner · CompTIA</span>
            <h3 class="cert-title">CompTIA Network+ Training Course</h3>
            <p class="cert-desc">Vendor-neutral networking fundamentals including topological layouts, wireless networking, network security, and infrastructure concepts.</p>
          </div>
          <a href="https://www.professormesser.com/network-plus/n10-008/n10-008-video-index/" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
      <% } else if (currentDomain == JobDomain.DEVOPS) { %>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-cyan);">
          <div>
            <span class="cert-badge">Beginner · KodeKloud</span>
            <h3 class="cert-title">DevOps Pre-Requisite Course</h3>
            <p class="cert-desc">Get comfortable with basic Linux terminal navigation, bash scripts, basic networking commands, and git repositories.</p>
          </div>
          <a href="https://kodekloud.com/courses/devops-pre-requisites-course/" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-purple);">
          <div>
            <span class="cert-badge">Intermediate · Academind</span>
            <h3 class="cert-title">Docker &amp; Kubernetes: The Practical Guide</h3>
            <p class="cert-desc">Build images, manage container networks, configure storage volumes, and deploy container clusters using Kubernetes pods and services.</p>
          </div>
          <a href="https://www.udemy.com/course/docker-kubernetes-the-practical-guide/" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-green);">
          <div>
            <span class="cert-badge">Beginner · HashiCorp</span>
            <h3 class="cert-title">Terraform Associate Tutorial &amp; Course</h3>
            <p class="cert-desc">Understand Infrastructure as Code principles, syntax, terraform state file management, and AWS resource orchestration blueprints.</p>
          </div>
          <a href="https://www.youtube.com/watch?v=V4nebHxPkL4" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-yellow);">
          <div>
            <span class="cert-badge">Intermediate · ZTM</span>
            <h3 class="cert-title">DevOps BootCamp: Linux, Docker, CI/CD</h3>
            <p class="cert-desc">A complete guide to automating building and deployment. Setup GitHub Actions pipelines, Linux servers, and microservice container configs.</p>
          </div>
          <a href="https://zerotomastery.io/courses/learn-devops-bootcamp/" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
      <% } else { %>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-cyan);">
          <div>
            <span class="cert-badge">Beginner · Udemy</span>
            <h3 class="cert-title">Java Programming Masterclass</h3>
            <p class="cert-desc">Acquire deep Java core knowledge, learn object-oriented design patterns, functional streams, collection libraries, and OOP fundamentals.</p>
          </div>
          <a href="https://www.udemy.com/course/java-the-complete-java-developer-course/" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-purple);">
          <div>
            <span class="cert-badge">Beginner · ZTM</span>
            <h3 class="cert-title">The Complete Web Developer in 2026</h3>
            <p class="cert-desc">Learn HTML, CSS, JavaScript, React, Node.js, Express, SQL, and Git. An immersive bootcamp to master full-stack software development.</p>
          </div>
          <a href="https://academy.zerotomastery.io/p/complete-web-developer-zero-to-mastery" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-green);">
          <div>
            <span class="cert-badge">Intermediate · Spring</span>
            <h3 class="cert-title">Spring Boot 3 &amp; Spring Framework 6</h3>
            <p class="cert-desc">Build web controllers, configure database connectivity with Hibernate/JPA, implement Spring Security, and structure cloud-native microservices.</p>
          </div>
          <a href="https://www.udemy.com/course/spring-framework-5-beginner-to-guru/" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
        <div class="cert-premium-card" style="border-left:4px solid var(--accent-yellow);">
          <div>
            <span class="cert-badge">Advanced · Coursera</span>
            <h3 class="cert-title">Software Architecture &amp; Design Patterns</h3>
            <p class="cert-desc">Learn how to model enterprise applications using clean design principles (SOLID), design patterns (creational, structural, behavioral), and architectural components.</p>
          </div>
          <a href="https://www.coursera.org/learn/software-architecture-design-patterns" target="_blank" rel="noopener" class="cert-link">Explore Course →</a>
        </div>
      <% } %>
    </div>
  </div>

  <!-- ══════════════════════════════════════════════════════
       PANEL 1: CAREER JOURNEY MAP (ROADMAP) — FULL REDESIGN
  ══════════════════════════════════════════════════════ -->
  <div id="roadmap-panel" class="hub-tab-panel">
    <div class="cjm-wrapper">

      <!-- Top bar -->
      <div class="cjm-topbar">
        <div class="cjm-topbar-left">
          <div class="cjm-logo-pin"></div>
          <div class="cjm-title-text">
            <h3>Career Journey Map</h3>
            <span>Your personalized skill route to destination role</span>
          </div>
          <% if (gap == null) { %>
            <span class="cjm-route-pill demo">Demo Route</span>
          <% } else { %>
            <span class="cjm-route-pill live">Live · Personalized</span>
          <% } %>
        </div>
        <div style="display:flex;align-items:center;gap:0.75rem;">
          <span id="cjm-node-count" style="font-size:0.72rem;color:var(--text-secondary);"></span>
          <div class="cjm-zoom-controls">
            <button class="cjm-zoom-btn" onclick="cjmZoom(1.2)" title="Zoom In">+</button>
            <button class="cjm-zoom-btn" onclick="cjmZoom(0.83)" title="Zoom Out">−</button>
          </div>
          <button class="cjm-zoom-btn" onclick="cjmResetView()" title="Reset View" style="width:auto;padding:0 0.5rem;font-size:0.7rem;letter-spacing:0.03em;">Reset</button>
        </div>
      </div>

      <!-- Map + Sidebar -->
      <div class="cjm-map-area" id="cjmMapArea">
        <!-- SVG Canvas -->
        <div class="cjm-svg-canvas">
          <svg id="cjmSvg" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <!-- Route gradient -->
              <linearGradient id="cjmRouteGrad" x1="0%" y1="100%" x2="100%" y2="0%">
                <stop offset="0%" stop-color="#10b981"/>
                <stop offset="40%" stop-color="#06b6d4"/>
                <stop offset="100%" stop-color="#8b5cf6"/>
              </linearGradient>
              <!-- Glow filter for nodes -->
              <filter id="cjmGlow" x="-50%" y="-50%" width="200%" height="200%">
                <feGaussianBlur stdDeviation="4" result="blur"/>
                <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
              </filter>
              <filter id="cjmGlowCyan" x="-50%" y="-50%" width="200%" height="200%">
                <feGaussianBlur stdDeviation="6" result="blur"/>
                <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
              </filter>
              <!-- Map grid pattern -->
              <pattern id="cjmGrid" width="40" height="40" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(255,255,255,0.025)" stroke-width="0.5"/>
              </pattern>
              <!-- Dot grid -->
              <pattern id="cjmDots" width="20" height="20" patternUnits="userSpaceOnUse">
                <circle cx="10" cy="10" r="0.8" fill="rgba(255,255,255,0.08)"/>
              </pattern>
              <!-- Milestone ring gradient -->
              <radialGradient id="mileFill" cx="50%" cy="50%" r="50%">
                <stop offset="0%" stop-color="rgba(139,92,246,0.25)"/>
                <stop offset="100%" stop-color="rgba(139,92,246,0.05)"/>
              </radialGradient>
              <!-- Clip path for path draw animation -->
              <clipPath id="cjmPathClip">
                <rect id="cjmPathClipRect" x="0" y="0" width="0" height="2000"/>
              </clipPath>
            </defs>
            <!-- Background layers -->
            <rect id="cjmBg" width="100%" height="100%" fill="#04060e"/>
            <rect id="cjmBgDots" width="100%" height="100%" fill="url(#cjmDots)"/>
            <rect id="cjmBgGrid" width="100%" height="100%" fill="url(#cjmGrid)"/>
            <!-- Transform group for zoom/pan -->
            <g id="cjmViewport">
              <g id="cjmPathsGroup"></g>
              <g id="cjmNodesGroup"></g>
            </g>
          </svg>
        </div>

        <!-- Right detail panel -->
        <div class="cjm-detail-sidebar" id="cjmSidebar">
          <div class="cjm-sidebar-placeholder" id="cjmPlaceholder">
            <div class="pin-icon">📍</div>
            <h4>Waypoint Inspector</h4>
            <p>Click any milestone node on the map to reveal the skill blueprint, recommended resources, projects to build, and interview relevance.</p>
          </div>
          <div class="cjm-node-detail" id="cjmNodeDetail">
            <div class="cjm-node-detail-header">
              <div class="cjm-milestone-chip" id="cjmMilestoneChip">Milestone 1</div>
              <h3 id="cjmNodeName">Skill Name</h3>
            </div>
            <div class="cjm-detail-section">
              <div class="cjm-detail-section-title">
                <i class="fa-solid fa-circle-question" style="color:var(--accent-cyan);"></i>
                Why Learn This?
              </div>
              <p id="cjmNodeWhy"></p>
            </div>
            <div class="cjm-detail-section">
              <div class="cjm-detail-section-title">
                <i class="fa-solid fa-book-open" style="color:var(--accent-purple);"></i>
                Recommended Resources
              </div>
              <p id="cjmNodeResources"></p>
            </div>
            <div class="cjm-detail-section">
              <div class="cjm-detail-section-title">
                <i class="fa-solid fa-laptop-code" style="color:var(--accent-green);"></i>
                Project to Build
              </div>
              <p id="cjmNodeProject"></p>
            </div>
            <div class="cjm-detail-section">
              <div class="cjm-detail-section-title">
                <i class="fa-solid fa-comments" style="color:var(--accent-yellow);"></i>
                Interview Relevance
              </div>
              <p id="cjmNodeInterview"></p>
            </div>
            <div class="cjm-detail-close">
              <button onclick="cjmCloseDetail()"><i class="fa-solid fa-xmark"></i> Close</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Minimap -->
      <div class="cjm-minimap" id="cjmMinimap">
        <svg id="cjmMinimapSvg" xmlns="http://www.w3.org/2000/svg">
          <rect width="100%" height="100%" fill="#04060e"/>
          <g id="cjmMinimapContent"></g>
        </svg>
      </div>

      <!-- Status bar -->
      <div class="cjm-statusbar">
        <div style="display:flex;gap:1.25rem;">
          <div class="cjm-statusbar-item"><span class="dot green"></span><span id="sbStart">Current Position</span></div>
          <div class="cjm-statusbar-item"><span class="dot cyan"></span><span>Skill Milestone</span></div>
          <div class="cjm-statusbar-item"><span class="dot purple"></span><span id="sbDest">Target Role</span></div>
        </div>
        <div style="display:flex;gap:1rem;align-items:center;">
          <% if (gap == null) { %>
            <span style="color:var(--accent-yellow);"><i class="fa-solid fa-circle-info" style="font-size:0.7rem;"></i> Demo route — upload resume to personalize</span>
          <% } else { %>
            <span style="color:var(--accent-green);"><i class="fa-solid fa-circle-check" style="font-size:0.7rem;"></i> Personalized from your resume</span>
          <% } %>
          <span>Scroll to zoom · Drag to pan · Click nodes</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ══════════════════════════════════════════════════════
       PANEL 2: SKILL GAP ANALYSIS
  ══════════════════════════════════════════════════════ -->
  <div id="gap-panel" class="hub-tab-panel">
    <% if (gap != null) {
         double match = 100 - gap.getGapPercentage();
         boolean isJobReady = "JOB_READY".equals(gap.getStatus());
    %>
    <div class="card card-premium">
      <div class="card-title-row">
        <div>
          <span class="tag tag-domain">Target Role</span>
          <h2 style="font-family:'Outfit';margin-top:0.25rem;"><%= gap.getTargetTitle() %></h2>
        </div>
        <div class="match-badge" data-tier="<%= match >= 70 ? "high" : (match >= 50 ? "mid" : "low") %>">
          <span class="match-badge-val"><%= String.format("%.0f", match) %>%</span>
          <span class="match-badge-lbl">ready</span>
        </div>
      </div>
      <div class="progress-track"><div class="progress-fill" style="width:<%= match %>%"></div></div>
      <% if (isJobReady) { %>
      <div style="margin-top:1.25rem;padding:0.9rem;background:rgba(16,185,129,0.1);border:1px solid var(--accent-green);border-radius:12px;display:flex;align-items:center;gap:0.65rem;">
        <span style="font-size:1.3rem;color:var(--accent-green);">🎉</span>
        <div style="color:var(--accent-green);font-size:0.9rem;font-weight:600;">
          Congratulations! You are officially <strong>JOB READY</strong> for this target role. Your resume fully matches the core required skills.
        </div>
      </div>
      <% } %>
      <div class="skill-row" style="margin-top:1.5rem;">
        <span class="skill-row-label">Matching Skills You Possess</span>
        <div class="skill-tags" style="margin-top:0.25rem;">
          <% if (gap.getAcquiredSkills() != null && !gap.getAcquiredSkills().isBlank()) {
               for (String s : gap.getAcquiredSkills().split(",")) { String t = s.trim(); if (!t.isEmpty()) { %>
          <span class="tag tag-ok"><i class="fa-solid fa-circle-check"></i> <%= t %></span>
          <% }}} else { %><span class="muted">None yet</span><% } %>
        </div>
      </div>
      <div class="skill-row" style="margin-top:1.25rem;">
        <span class="skill-row-label">Missing Target Skills</span>
        <div class="skill-tags" style="margin-top:0.25rem;">
          <% if (gap.getMissingSkills() != null && !gap.getMissingSkills().isBlank()) {
               for (String s : gap.getMissingSkills().split(",")) { String t = s.trim(); if (!t.isEmpty()) { %>
          <span class="tag tag-warn"><i class="fa-solid fa-triangle-exclamation"></i> <%= t %></span>
          <% }}} else { %>
          <span class="tag tag-ok">★ All requirements met!</span>
          <% } %>
        </div>
      </div>
      <div style="margin-top:1.5rem;display:flex;gap:0.5rem;flex-wrap:wrap;">
        <form method="post" action="${pageContext.request.contextPath}/student" style="display:inline;">
          <input type="hidden" name="action" value="learning">
          <button class="btn"><i class="fa-solid fa-rotate-right"></i> Regenerate Roadmap</button>
        </form>
      </div>
    </div>
    <% } else { %>
    <div class="card"><p class="muted">Please upload your resume on the dashboard to see your role gap analysis.</p></div>
    <% } %>
  </div>

  <!-- ══════════════════════════════════════════════════════
       PANEL 3: PRACTICE LABS
  ══════════════════════════════════════════════════════ -->
  <div id="practice-panel" class="hub-tab-panel">
    <div class="card" style="margin-bottom:1.5rem;">
      <h3>Interactive Coding &amp; Simulation Platforms</h3>
      <p style="color:var(--text-secondary);font-size:0.85rem;margin-top:0.25rem;">Apply your learning in live sandboxes, packet tracer simulations, or hacking labs tailored to your target domain.</p>
    </div>
    <%
    if (hubs != null && !hubs.isEmpty()) {
      for (SkillLearningHub hub : hubs) {
        List<PracticeLink> practice = hub.getPracticeLinks();
        if (practice != null && !practice.isEmpty()) {
    %>
    <div class="card" style="margin-bottom:1.25rem;border-left:4px solid var(--accent-green);">
      <h3 style="font-family:'Outfit';font-size:1.15rem;color:var(--accent-green);margin-bottom:0.5rem;"><%= hub.getSkillName() %> Practice Arenas</h3>
      <div class="practice-platform-grid" style="margin-top:0.75rem;">
        <% for (PracticeLink p : practice) { %>
        <a href="<%= p.getUrl() %>" target="_blank" rel="noopener noreferrer" class="practice-platform-card">
          <span class="practice-platform-name"><%= p.getName() %></span>
          <span class="practice-platform-desc"><%= p.getDescription() != null ? p.getDescription() : "Interactive hands-on sandbox labs." %></span>
          <span class="practice-platform-cta">Start Practicing <i class="fa-solid fa-chevron-right" style="font-size:0.75rem;"></i></span>
        </a>
        <% } %>
      </div>
    </div>
    <%
        }
      }
    } else {
    %>
    <div class="card" style="text-align:center;padding:2rem;color:var(--text-muted);">
      <i class="fa-solid fa-terminal" style="font-size:2.2rem;margin-bottom:0.5rem;opacity:0.4;"></i>
      <p>Regenerate your playlists in the Playlists tab to auto-map custom practice platform links.</p>
    </div>
    <% } %>
  </div>

  <!-- ══════════════════════════════════════════════════════
       PANEL 4: CERTIFICATIONS
  ══════════════════════════════════════════════════════ -->
  <div id="cert-panel" class="hub-tab-panel">
    <div class="card" style="margin-bottom:1.25rem;">
      <h3>Role-Based Industry Credentials</h3>
      <p style="color:var(--text-secondary);font-size:0.85rem;margin-top:0.25rem;">Stand out to recruiters by earning domain-specific certifications. Click links for official exam blueprints.</p>
    </div>
    <div class="cert-card-grid">
      <%
        class CertItem {
          String skill;
          String badge;
          String title;
          String desc;
          String link;
          CertItem(String s, String b, String t, String d, String l) {
            skill = s; badge = b; title = t; desc = d; link = l;
          }
        }
        
        List<CertItem> allCerts = new ArrayList<>();
        allCerts.add(new CertItem("Networking", "Foundational", "Cisco Certified Network Associate (CCNA 200-301)", "The premier industry cert validating routing, switching, IP services, security, and automation fundamentals.", "https://www.cisco.com/c/en/us/training-events/training-certifications/exams/exam-listings/ccna-200-301.html"));
        allCerts.add(new CertItem("CCNA", "Foundational", "Cisco Certified Network Associate (CCNA 200-301)", "The premier industry cert validating routing, switching, IP services, security, and automation fundamentals.", "https://www.cisco.com/c/en/us/training-events/training-certifications/exams/exam-listings/ccna-200-301.html"));
        allCerts.add(new CertItem("Cisco", "Foundational", "Cisco Certified Network Associate (CCNA 200-301)", "The premier industry cert validating routing, switching, IP services, security, and automation fundamentals.", "https://www.cisco.com/c/en/us/training-events/training-certifications/exams/exam-listings/ccna-200-301.html"));
        allCerts.add(new CertItem("Routing", "Advanced", "Cisco Certified Network Professional (CCNP Enterprise)", "Advanced enterprise network planning, dual-stack core architectures, and specialized routing structures.", "https://www.cisco.com/c/en/us/training-events/training-certifications/certifications/professional/ccnp-enterprise.html"));
        allCerts.add(new CertItem("Switching", "Advanced", "Cisco Certified Network Professional (CCNP Enterprise)", "Advanced enterprise network planning, dual-stack core architectures, and specialized routing structures.", "https://www.cisco.com/c/en/us/training-events/training-certifications/certifications/professional/ccnp-enterprise.html"));
        allCerts.add(new CertItem("Networking", "Intermediate", "CompTIA Network+", "Vendor-neutral credentials covering configuration, management, and troubleshooting of common network structures.", "https://www.comptia.org/certifications/network"));

        allCerts.add(new CertItem("Java", "Developer Foundations", "Oracle Certified Professional: Java SE Developer", "Validates core competency in building modular enterprises, collections, functional Java features, and thread safety.", "https://education.oracle.com/oracle-certified-professional-java-se-17-developer/pexam_1Z0-829"));
        allCerts.add(new CertItem("Spring Boot", "Spring Core", "Spring Certified Professional", "Proves deep architectural understanding of Spring, Spring Boot, auto-configurations, MVC, AOP, and JDBC security APIs.", "https://academy.vmware.com/credentials/spring-certified-professional.html"));
        allCerts.add(new CertItem("Spring", "Spring Core", "Spring Certified Professional", "Proves deep architectural understanding of Spring, Spring Boot, auto-configurations, MVC, AOP, and JDBC security APIs.", "https://academy.vmware.com/credentials/spring-certified-professional.html"));

        allCerts.add(new CertItem("React", "Frontend", "Meta Front-End Developer Professional Certificate", "Validates dynamic single page application design, React hooks, state management, component architecture, and API integration.", "https://www.coursera.org/professional-certificates/meta-front-end-developer"));
        allCerts.add(new CertItem("JavaScript", "Frontend", "Meta Front-End Developer Professional Certificate", "Validates dynamic single page application design, React hooks, state management, component architecture, and API integration.", "https://www.coursera.org/professional-certificates/meta-front-end-developer"));
        allCerts.add(new CertItem("HTML", "Frontend Foundations", "W3CX Front-End Web Developer Professional Certificate", "Covers advanced HTML5 features, CSS styling, web design principles, and modern responsive UI patterns.", "https://www.edx.org/professional-certificate/w3cx-front-end-web-developer"));
        allCerts.add(new CertItem("CSS", "Frontend Foundations", "W3CX Front-End Web Developer Professional Certificate", "Covers advanced HTML5 features, CSS styling, web design principles, and modern responsive UI patterns.", "https://www.edx.org/professional-certificate/w3cx-front-end-web-developer"));
        allCerts.add(new CertItem("Node.js", "Backend JS", "OpenJS Node.js Application Developer (JSNAD)", "Validates key skills in building REST APIs, asynchronous programming, security practices, and microservices on Node.js.", "https://training.linuxfoundation.org/certification/jsnad/"));

        allCerts.add(new CertItem("AWS", "Cloud Foundations", "AWS Certified Solutions Architect – Associate", "Industry-standard exam demonstrating technical expertise in designing well-architected systems on AWS.", "https://aws.amazon.com/certification/certified-solutions-architect-associate/"));
        allCerts.add(new CertItem("Docker", "Containers", "Certified Kubernetes Administrator (CKA)", "High-value, hands-on certification proving operational proficiency in deploying and debugging Kubernetes clusters.", "https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/"));
        allCerts.add(new CertItem("Kubernetes", "Containers", "Certified Kubernetes Administrator (CKA)", "High-value, hands-on certification proving operational proficiency in deploying and debugging Kubernetes clusters.", "https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/"));
        allCerts.add(new CertItem("DevOps", "Infrastructure as Code", "HashiCorp Certified: Terraform Associate", "Specialized credentials focused on infrastructure automation, deployment pipelines, and IaC patterns.", "https://www.hashicorp.com/certification/terraform-associate"));
        allCerts.add(new CertItem("Git", "Version Control", "GitHub Actions Certification", "Validates expertise in CI/CD automation, workflow optimization, and repository management with GitHub.", "https://resources.github.com/learn/certifications/"));
        allCerts.add(new CertItem("Linux", "SysAdmin", "Linux Foundation Certified System Administrator (LFCS)", "Validates the ability to design, install, configure, and manage Linux systems in enterprise environments.", "https://training.linuxfoundation.org/certification/linux-foundation-certified-system-administrator-lfcs/"));

        allCerts.add(new CertItem("Power BI", "BI & Analytics", "Microsoft Power BI Data Analyst Associate (PL-300)", "Demonstrates technical proficiency in cleaning, modeling, visualizing, and sharing business intelligence data in Power BI.", "https://learn.microsoft.com/en-us/credentials/certifications/power-bi-data-analyst-associate/"));
        allCerts.add(new CertItem("Excel", "BI & Analytics", "Microsoft Power BI Data Analyst Associate (PL-300)", "Demonstrates technical proficiency in cleaning, modeling, visualizing, and sharing business intelligence data in Power BI.", "https://learn.microsoft.com/en-us/credentials/certifications/power-bi-data-analyst-associate/"));
        allCerts.add(new CertItem("SQL", "Data Management", "Google Data Analytics Professional Certificate", "Validates hands-on knowledge in processing data via SQL, R, spreadsheets, and Tableau.", "https://grow.google/certificates/data-analytics/"));
        allCerts.add(new CertItem("Python", "Data & Scripting", "Google Data Analytics Professional Certificate", "Validates hands-on knowledge in processing data via SQL, R, spreadsheets, and Tableau.", "https://grow.google/certificates/data-analytics/"));
        allCerts.add(new CertItem("Machine Learning", "Machine Learning", "TensorFlow Developer Certificate", "Validates practical skills in building, training, and deploying deep learning models using TensorFlow and Keras APIs.", "https://www.tensorflow.org/certificate"));
        allCerts.add(new CertItem("Data Analytics", "Professional Certificate", "Google Data Analytics Professional Certificate", "Validates hands-on knowledge in processing data via SQL, R, spreadsheets, and Tableau.", "https://grow.google/certificates/data-analytics/"));

        List<String> reqSkills = cctx != null ? cctx.getRequiredSkills() : new ArrayList<>();
        List<CertItem> displayedCerts = new ArrayList<>();
        Set<String> addedTitles = new HashSet<>();
        
        if (reqSkills != null && !reqSkills.isEmpty()) {
            for (String rSkill : reqSkills) {
                String normalizedReq = rSkill.trim().toLowerCase();
                for (CertItem item : allCerts) {
                    if (item.skill.toLowerCase().equals(normalizedReq)) {
                        if (!addedTitles.contains(item.title)) {
                            displayedCerts.add(item);
                            addedTitles.add(item.title);
                        }
                    }
                }
            }
        }
        
        if (displayedCerts.isEmpty()) {
            for (CertItem item : allCerts) {
                boolean isNetworking = currentDomain == JobDomain.NETWORKING && (item.skill.equals("Networking") || item.skill.equals("CCNA") || item.skill.equals("Cisco"));
                boolean isDevOps = currentDomain == JobDomain.DEVOPS && (item.skill.equals("AWS") || item.skill.equals("Kubernetes") || item.skill.equals("DevOps"));
                boolean isData = currentDomain == JobDomain.DATA && (item.skill.equals("Power BI") || item.skill.equals("Data Analytics") || item.skill.equals("Machine Learning"));
                boolean isFrontend = currentDomain == JobDomain.FRONTEND && (item.skill.equals("React") || item.skill.equals("JavaScript") || item.skill.equals("HTML") || item.skill.equals("CSS"));
                boolean isBackendOrGeneral = (currentDomain == JobDomain.BACKEND || currentDomain == JobDomain.GENERAL || currentDomain == JobDomain.FULL_STACK) && (item.skill.equals("Java") || item.skill.equals("Spring Boot") || item.skill.equals("AWS"));
                
                if (isNetworking || isDevOps || isData || isFrontend || isBackendOrGeneral) {
                    if (!addedTitles.contains(item.title) && displayedCerts.size() < 3) {
                        displayedCerts.add(item);
                        addedTitles.add(item.title);
                    }
                }
            }
        }

        for (CertItem cert : displayedCerts) {
      %>
        <div class="cert-premium-card">
          <div>
            <span class="cert-badge"><%= cert.badge %></span>
            <h3 class="cert-title"><%= cert.title %></h3>
            <p class="cert-desc"><%= cert.desc %></p>
          </div>
          <a href="<%= cert.link %>" target="_blank" rel="noopener" class="cert-link">Exam Outline &amp; Guide →</a>
        </div>
      <%
        }
      %>
    </div>
  </div>

  <!-- ══════════════════════════════════════════════════════
       PANEL 5: PLAYLISTS
  ══════════════════════════════════════════════════════ -->
  <div id="playlists-panel" class="hub-tab-panel">
    <div class="card" style="margin-bottom:1.5rem;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:1rem;">
      <div>
        <h3 style="margin-bottom:0.25rem;">Personalized Curriculum</h3>
        <p style="color:var(--text-secondary);font-size:0.82rem;">Curated video playlists and documentation to close your missing skills.</p>
      </div>
      <form method="post" action="${pageContext.request.contextPath}/student">
        <input type="hidden" name="action" value="learning">
        <button class="btn btn-sm btn-g"><i class="fa-solid fa-wand-magic-sparkles"></i> Regenerate Playlists</button>
      </form>
    </div>
    <%
    if (hubs != null && !hubs.isEmpty()) {
      for (SkillLearningHub hub : hubs) {
    %>
    <section class="card" style="margin-bottom:1.5rem;">
      <div class="card-title-row" style="border-bottom:1px solid var(--border-color);padding-bottom:0.75rem;margin-bottom:1.25rem;">
        <h2 style="font-family:'Outfit';font-size:1.2rem;color:var(--accent-purple);"><%= hub.getSkillName() %></h2>
        <span class="tag tag-domain">Roadmap</span>
      </div>
      <div style="margin-bottom:1.5rem;">
        <h4 style="font-size:0.9rem;font-weight:700;color:var(--text-primary);margin-bottom:0.5rem;display:flex;align-items:center;gap:0.4rem;">
          <i class="fa-regular fa-square-caret-right" style="color:var(--accent-cyan);"></i> Video Tutorials
        </h4>
        <% if (hub.getLearnItems() != null && !hub.getLearnItems().isEmpty()) { %>
        <div class="hub-resource-grid">
          <% for (LearningItem item : hub.getLearnItems()) {
               String stage = item.getLevelStage() != null ? item.getLevelStage() : "";
               String label = "BEGINNER".equals(stage) ? "Beginner" : "INTERMEDIATE".equals(stage) ? "Intermediate" : "ADVANCED".equals(stage) ? "Advanced" : "PROJECTS".equals(stage) ? "Project" : stage;
          %>
          <div class="hub-resource-card hub-learn-card" style="display:flex;flex-direction:column;justify-content:space-between;min-height:140px;">
            <div>
              <span class="hub-stage-pill"><%= label %></span>
              <h4 style="font-size:0.85rem;margin-top:0.5rem;font-weight:600;line-height:1.4;"><%= item.getTitle() %></h4>
            </div>
            <div style="margin-top:1rem;display:flex;justify-content:space-between;align-items:center;">
              <span style="font-size:0.72rem;color:var(--text-muted);"><%= item.getPlatform() %></span>
              <a href="<%= item.getResourceUrl() %>" target="_blank" rel="noopener" class="btn btn-sm" style="padding:0.25rem 0.5rem;font-size:0.7rem;">Watch</a>
            </div>
          </div>
          <% } %>
        </div>
        <% } else { %><p class="muted" style="font-size:0.8rem;">No video learning paths currently generated.</p><% } %>
      </div>
      <div style="border-top:1px dashed var(--border-color);padding-top:1.25rem;">
        <h4 style="font-size:0.9rem;font-weight:700;color:var(--text-primary);margin-bottom:0.5rem;display:flex;align-items:center;gap:0.4rem;">
          <i class="fa-regular fa-file-lines" style="color:var(--accent-purple);"></i> References &amp; Guides
        </h4>
        <% if (hub.getReadItems() != null && !hub.getReadItems().isEmpty()) { %>
        <div class="hub-resource-grid">
          <% for (LearningItem item : hub.getReadItems()) {
               String label2 = "READ_DOC".equals(item.getLevelStage()) ? "Documentation" : "Reference Book";
          %>
          <div class="hub-resource-card hub-read-card" style="display:flex;flex-direction:column;justify-content:space-between;min-height:140px;">
            <div>
              <span class="hub-stage-pill hub-pill-read"><%= label2 %></span>
              <h4 style="font-size:0.85rem;margin-top:0.5rem;font-weight:600;line-height:1.4;"><%= item.getTitle() %></h4>
            </div>
            <div style="margin-top:1rem;display:flex;justify-content:space-between;align-items:center;">
              <span style="font-size:0.72rem;color:var(--text-muted);"><%= item.getPlatform() %></span>
              <a href="<%= item.getResourceUrl() %>" target="_blank" rel="noopener" class="btn btn-sm btn-outline" style="padding:0.25rem 0.5rem;font-size:0.7rem;">Read</a>
            </div>
          </div>
          <% } %>
        </div>
        <% } else { %><p class="muted" style="font-size:0.8rem;">No books or reference documents loaded.</p><% } %>
      </div>
    </section>
    <%
      }
    } else {
    %>
    <div class="card" style="text-align:center;padding:3rem 2rem;">
      <i class="fa-solid fa-wand-magic-sparkles" style="font-size:2.5rem;color:var(--accent-purple);opacity:0.4;margin-bottom:1rem;"></i>
      <h3 style="font-family:'Outfit';margin-bottom:0.5rem;">Build Your Curriculum</h3>
      <p style="color:var(--text-secondary);font-size:0.85rem;margin-bottom:1.25rem;">Click "Regenerate Playlists" above to construct dynamic roadmaps matching your skill gaps.</p>
    </div>
    <% } %>
  </div>

</main>
</div>

<script>
/* ═══════════════════════════════════════════════════════
   DATA PREPARATION FROM JSP
═══════════════════════════════════════════════════════ */
<%
  String targetTitle = gap != null ? gap.getTargetTitle() : "";
  String missingSkillsStr  = gap != null && gap.getMissingSkills()  != null ? gap.getMissingSkills()  : "";
  String acquiredSkillsStr = gap != null && gap.getAcquiredSkills() != null ? gap.getAcquiredSkills() : "";
%>
const CJM_TARGET_TITLE = "<%= targetTitle.replace("\"", "\\\"") %>";
const CJM_MISSING_SKILLS = [
  <% if (!missingSkillsStr.isBlank()) {
       String[] ms = missingSkillsStr.split(",");
       for (int i = 0; i < ms.length; i++) {
         out.print("\"" + ms[i].trim().replace("\"", "\\\"") + "\"");
         if (i < ms.length - 1) out.print(", ");
       }
     } %>
];
const CJM_ACQUIRED_SKILLS = [
  <% if (!acquiredSkillsStr.isBlank()) {
       String[] as2 = acquiredSkillsStr.split(",");
       for (int i = 0; i < as2.length; i++) {
         out.print("\"" + as2[i].trim().replace("\"", "\\\"") + "\"");
         if (i < as2.length - 1) out.print(", ");
       }
     } %>
];
const CJM_DOMAIN = '<%= currentDomain.name() %>';

/* ═══════════════════════════════════════════════════════
   DEMO ROUTES
═══════════════════════════════════════════════════════ */
const demoRoutes = {
  DATA: {
    role: 'Data Scientist',
    acquired: ['Python Basics', 'Excel'],
    missing: ['SQL', 'Pandas', 'Data Visualization', 'Statistics', 'Machine Learning', 'Spark']
  },
  NETWORKING: {
    role: 'Network Engineer',
    acquired: ['Networking Basics', 'TCP/IP'],
    missing: ['Routing & Switching', 'OSPF', 'BGP', 'Network Security', 'Network Automation', 'Ansible']
  },
  DEVOPS: {
    role: 'DevOps Engineer',
    acquired: ['Linux', 'Git'],
    missing: ['Bash', 'Docker', 'Kubernetes', 'Terraform', 'AWS', 'CI/CD']
  },
  GENERAL: {
    role: 'Full Stack Developer',
    acquired: ['HTML', 'CSS', 'JavaScript'],
    missing: ['React', 'Node.js', 'Express', 'SQL', 'Docker', 'AWS', 'System Design']
  }
};

let mapTargetTitle   = CJM_TARGET_TITLE;
let mapMissingSkills = [...CJM_MISSING_SKILLS];
let mapAcquiredSkills = [...CJM_ACQUIRED_SKILLS];

if (!mapTargetTitle || mapMissingSkills.length === 0) {
  const demo = demoRoutes[CJM_DOMAIN] || demoRoutes.GENERAL;
  mapTargetTitle    = demo.role;
  mapMissingSkills  = demo.missing;
  mapAcquiredSkills = demo.acquired;
}

/* ═══════════════════════════════════════════════════════
   SKILL DETAIL KNOWLEDGE BASE
═══════════════════════════════════════════════════════ */
const skillDB = {
  "java":               { why:"Java is the foundational enterprise programming language, widely utilized in large-scale server architectures, cloud services, and Android development.", resources:"Tim Buchalka's 'Java Programming Masterclass' on Udemy, Oracle Java Tutorials, and 'Effective Java' by Joshua Bloch.", project:"Build a multithreaded web server from scratch or implement an API gateway with rate-limiting using Java concurrency primitives.", interview:"Expect questions on memory management (JVM GC, stack vs heap), concurrency utilities, collection internals (HashMap internals), and SOLID design principles." },
  "python":             { why:"Python is the primary language for data engineering, machine learning, web scraping, and automated scripting due to its simple syntax and vast ecosystem.", resources:"Jose Portilla's 'Python for Data Science Bootcamp' on Udemy, Official Python documentation, and Real Python guides.", project:"Write a high-performance concurrent web scraper using asyncio, or build a data analysis dashboard using Pandas and Streamlit.", interview:"Expect questions on decorators, generators, list comprehensions, global interpreter lock (GIL) implications, and memory management." },
  "spring boot":        { why:"Spring Boot simplifies microservices creation by offering opinionated configurations, embedded servers, and comprehensive security integrations.", resources:"Baeldung Spring Boot Tutorials, Chad Darby's Spring & Hibernate course on Udemy, and Spring Guides.", project:"Develop an e-commerce backend microservice utilizing Spring Cloud Gateway, Eureka Service Registry, and Spring Security JWT authentication.", interview:"Expect questions on dependency injection, bean scopes, Spring Boot autoconfigurations, JPA transaction propagation, and MVC filter lifecycles." },
  "sql":                { why:"Relational database querying is essential for persisting, retrieving, and reporting business data across all technology stacks.", resources:"Mode Analytics SQL Tutorial, LeetCode SQL 50, and 'High Performance MySQL' book.", project:"Create a fully normalized database schema for a ride-sharing app and write optimized reporting queries involving complex window functions.", interview:"Expect questions on database normalization, index data structures (B-Trees), transaction isolation levels (ACID), and query optimization (EXPLAIN analysis)." },
  "docker":             { why:"Docker containerizes application stacks, guaranteeing consistency across local development, staging environments, and production clusters.", resources:"Maximilian Schwarzmüller's 'Docker & Kubernetes' course, Docker documentation, and Bret Fisher's Docker Mastery on Udemy.", project:"Write a multi-stage Dockerfile to build and package a React + Node + PostgreSQL application, optimizing image layer caching.", interview:"Expect questions on image layering, container isolation mechanisms (namespaces/cgroups), multi-stage builds, and docker-compose networking." },
  "kubernetes":         { why:"Kubernetes automates deployment, scaling, routing, and recovery of containerized applications in cloud-native production environments.", resources:"Mumshad Mannambeth's CKA course, Kubernetes official documentation, and interactive labs on Killercoda.", project:"Deploy a high-availability app cluster on minikube, including custom Ingress routing rules, ConfigMaps, Secrets, and Horizontal Pod Autoscaling.", interview:"Expect questions on cluster architecture components (control plane vs nodes), pod lifecycle, service routing (kube-proxy), and troubleshooting cluster states." },
  "aws":                { why:"Amazon Web Services is the dominant public cloud, offering secure, scalable infrastructure for hosting websites, databases, and microservices.", resources:"Stephane Maarek's AWS Solutions Architect Associate course, and AWS Architecture Center whitepapers.", project:"Deploy a serverless backend using AWS Lambda, API Gateway, and DynamoDB, structured with infrastructure as code.", interview:"Expect questions on VPC subnet routing, IAM least-privilege policies, S3 consistency model, and database scaling strategies." },
  "terraform":          { why:"Terraform allows provisioning and updating multi-provider cloud infrastructure safely and predictably using declarative configuration files.", resources:"HashiCorp Terraform Documentation, freeCodeCamp Terraform Course, and 'Terraform Up & Running' by Yevgeniy Brikman.", project:"Write reusable Terraform modules to provision a secure VPC, RDS database instance, and auto-scaling EC2 instances on AWS.", interview:"Expect questions on state file locking/backends, terraform plan vs apply cycle, resource dependency graphs, and handling secret credentials." },
  "git":                { why:"Git is the industry-standard version control system, allowing developer teams to collaborate, track history, and manage code releases.", resources:"Pro Git Book (free online), GitHub Learning Labs, and Atlassian Git Tutorials.", project:"Set up a git repository with pre-commit hooks that format code and run unit tests, and resolve complex rebasing conflicts in simulated team branches.", interview:"Expect questions on git rebase vs merge, git workflow models, git reflog, internal object storage (blobs, trees, commits), and cherry-picking." },
  "linux":              { why:"Linux is the operating system powering the vast majority of server infrastructure, cloud instances, and devops tooling globally.", resources:"Linux Journey tutorials, 'The Linux Command Line' book by William Shotts, and OverTheWire bandit wargames.", project:"Configure a secure Ubuntu VPS server, disable password logins, setup firewall rules (UFW), and write a bash script to automate database backups.", interview:"Expect questions on file permissions (chmod/chown), process signaling, system logging (journald), bash variable scopes, and text stream manipulators." },
  "bash":               { why:"Bash scripting enables developers to automate repetitive terminal operations, deploy code, and schedule maintenance scripts.", resources:"GNU Bash reference manual, ShellCheck for linting scripts, and YouTube bash tutorials.", project:"Create a deployment shell script that pulls from git, builds the docker image, updates the active container, and posts a status message to Discord.", interview:"Expect questions on shell execution environments, piping standard output vs standard error, parameter expansion, and error handling (set -e)." },
  "ci/cd":              { why:"Continuous Integration & Deployment automates code checking, building, and deployment, reducing delivery cycle time and production defects.", resources:"GitHub Actions documentation, GitLab CI/CD guides, and Jenkins pipeline tutorials.", project:"Configure a GitHub Actions pipeline that triggers on pull requests to run linters, compile tests, build a Docker image, and deploy to staging.", interview:"Expect questions on runner environments, secret environment variables, caching dependencies for speed, and pipeline triggers." },
  "react":              { why:"React is the most popular frontend library for building highly interactive, responsive, and component-driven user interfaces.", resources:"React Dev Documentation (react.dev), Epic React by Kent C. Dodds, and modern React courses.", project:"Build a dashboard application utilizing React Context, custom hooks for fetching data, and a charting library with dark-theme configurations.", interview:"Expect questions on Virtual DOM mechanisms, state vs props, useEffect cleanup functions, React reconciliation engine, and component performance memoization." },
  "node.js":            { why:"Node.js allows running JavaScript on the server, enabling full-stack developers to build fast, scalable, and non-blocking backends.", resources:"Node.js official docs, ZTM Node.js course, and 'Node.js Design Patterns' book.", project:"Build a real-time collaborative whiteboard app utilizing Express, Node, and WebSockets (Socket.io).", interview:"Expect questions on event-driven non-blocking I/O model, streams, buffer management, event emitter, and package dependencies management." },
  "javascript":         { why:"JavaScript is the programming language powering all client-side browser logic, dynamic page interactions, and asynchronous API communication.", resources:"MDN JavaScript guide, 'You Don't Know JS' book series by Kyle Simpson, and JavaScript.info.", project:"Write a client-side routing and state management library from scratch using custom events and the History API.", interview:"Expect questions on closures, prototypical inheritance, the event loop (microtasks/macrotasks), hoisting, and promises (async/await)." },
  "sql":                { why:"Relational database querying is essential for persisting, retrieving, and reporting business data across all technology stacks.", resources:"Mode Analytics SQL Tutorial, LeetCode SQL 50, and 'High Performance MySQL' book.", project:"Design a fully normalized database schema for a ride-sharing app with window function reporting queries.", interview:"Expect questions on normalization forms, B-Tree indexes, ACID transactions, and EXPLAIN plans." },
  "pandas":             { why:"Pandas is the core library for data cleaning, transformation, and structural modeling in Python data science workflows.", resources:"Pandas documentation, Kaggle Pandas courses.", project:"Load a messy database export of 1M rows, clean null values, normalize schema formats, and compile cohort analysis summaries.", interview:"Expect questions on Series vs DataFrames, vectorization performance, indexing/multi-indexing, and handling missing data." },
  "machine learning":   { why:"Machine Learning empowers systems to learn from data patterns, making predictions and decisions without explicit rule-based algorithms.", resources:"Andrew Ng's Machine Learning specialization, Scikit-Learn guides.", project:"Build and evaluate multiple classification models (Logistic Regression, Random Forest, XGBoost) to predict customer churn, optimizing hyperparameters.", interview:"Expect questions on bias-variance tradeoff, overfitting, feature engineering, loss functions, metrics (precision, recall, F1), and gradient descent." },
  "spark":              { why:"Apache Spark is the standard open-source unified engine for large-scale distributed data processing and machine learning analytics.", resources:"Databricks training materials, Spark docs.", project:"Write a PySpark script to ingest and aggregate web traffic log streams from cloud storage, running on a local cluster.", interview:"Expect questions on RDD vs DataFrames, lazy evaluation, shuffling, caching, and cluster resource managers." },
  "system design":      { why:"System Design teaches developers how to build large-scale, highly available, fault-tolerant, and distributed software systems.", resources:"ByteByteGo (Alex Xu), Designing Data-Intensive Applications by Martin Kleppmann.", project:"Draft a system architecture diagram and technical design doc detailing cache layers, load balancers, DB replication, and message queues for a video streaming platform.", interview:"Expect questions on horizontal vs vertical scaling, CAP theorem, caching strategies, load balancing algorithms, database sharding, and message queues." },
  "routing & switching":{ why:"Advanced routing and switching forms the backbone of enterprise networks, routing gigabytes of packets with redundancy and low latency.", resources:"Cisco CCNP Enterprise core blueprints, Packet Tracer lab simulations.", project:"Configure a corporate branch network in Packet Tracer with redundant OSPF routers, access lists, NAT, and EtherChannels.", interview:"Expect questions on routing table lookup, OSPF state machine, BGP path attributes, spanning tree protocol (STP), and VLAN trunking." },
  "ospf":               { why:"Open Shortest Path First is a link-state routing protocol standard used to dynamically calculate the shortest path for packets within an enterprise domain.", resources:"Cisco configuration guides, Jeremy's IT Lab videos.", project:"Set up a multi-area OSPF router topology, optimizing cost metrics and configuring route summarization.", interview:"Expect questions on link-state advertisements (LSAs), neighbor states, DR/BDR election, and area types." },
  "bgp":                { why:"Border Gateway Protocol is the routing protocol of the internet, routing traffic across autonomous systems (AS) on a global scale.", resources:"Cisco IP Routing guides.", project:"Simulate a multi-homed customer network establishing eBGP and iBGP peerings with multiple ISPs in a virtual lab.", interview:"Expect questions on path attributes (AS-PATH, Local Preference, MED), route selection algorithm, loop prevention, and peering requirements." },
  "ansible":            { why:"Ansible is an open-source IT automation tool that automates provisioning, configuration management, application deployment, and intra-service orchestration.", resources:"Ansible Documentation, Red Hat training resources.", project:"Build playbooks to automate system security hardening (disabling root login, setting firewall rules, patching packages) on a farm of virtual machines.", interview:"Expect questions on agentless architecture, inventory files, playbooks, roles, tasks, variables, and handler loops." },
  "network automation": { why:"Network Automation replaces manual CLI configurations with scripts, ensuring speed, consistency, and auditable network states.", resources:"Cisco DevNet Associate guidelines, Ansible for Networks documentation.", project:"Write an Ansible playbook to deploy VLAN configuration changes across a fleet of 10 virtual routers simultaneously, auditing active ports.", interview:"Expect questions on SSH-based network libraries (Paramiko, Netmiko), structured data formats (YAML/JSON), API frameworks, and Ansible playbooks." },
  "data visualization": { why:"Data Visualization translates raw datasets into compelling, interactive charts and dashboards that drive executive decision-making.", resources:"Matplotlib, Seaborn, and Plotly documentation; Tableau Public community tutorials.", project:"Create an interactive multi-panel dashboard from a public dataset using Plotly Dash, with drill-down filtering capabilities.", interview:"Expect questions on choosing the right chart type, color theory for accessibility, dashboard layout principles, and handling large datasets efficiently." },
  "statistics":         { why:"Statistical foundations are essential for interpreting model outputs, designing experiments, and making data-driven decisions with confidence.", resources:"Statistics and Probability on Khan Academy, 'Statistics' by Freedman/Pisani/Purves, and StatQuest YouTube series.", project:"Conduct an A/B test analysis on a product dataset, apply t-tests, chi-square tests, and report confidence intervals.", interview:"Expect questions on hypothesis testing, p-values, confidence intervals, distributions, central limit theorem, and correlation vs causation." },
  "network security":   { why:"Network security ensures organizational infrastructure is protected against unauthorized access, breaches, and data exfiltration.", resources:"CompTIA Security+ study materials, Cisco CCNA Security guides.", project:"Implement a zero-trust network segment using firewall ACLs, port security, 802.1X authentication, and IDS/IPS policies.", interview:"Expect questions on CIA triad, firewall types, encryption protocols (TLS/SSL), VPN configurations, and incident response procedures." },
  "express":            { why:"Express is the standard minimalist framework for routing, requests processing, and writing REST API endpoints in Node.js server apps.", resources:"ExpressJS website documentation, MDN Express tutorials.", project:"Design and implement a robust REST API backend with middleware pipelines for request validations, JWT validation, rate limiting, and global error logging.", interview:"Expect questions on middleware propagation (next()), router structures, CORS configuration, and body-parsing internals." }
};

function getSkillInfo(name) {
  const norm = name.toLowerCase().trim();
  const key = Object.keys(skillDB).find(k => norm.includes(k) || k.includes(norm));
  if (key) return skillDB[key];
  return {
    why:       "Mastering " + name + " is critical for closing your skill gap and aligning with modern standards for your target career role.",
    resources: "Official " + name + " documentation, community-guided learning modules, and interactive developer roadmaps on roadmap.sh.",
    project:   "Build a modular sandbox project integrating " + name + " functionality, demonstrating your capacity to configure, build, or deploy real-world implementations.",
    interview: "Prepare to discuss the core architecture of " + name + ", common configuration patterns, performance trade-offs, and debug workflows."
  };
}

/* ═══════════════════════════════════════════════════════
   CAREER JOURNEY MAP ENGINE
═══════════════════════════════════════════════════════ */
const CJM = {
  svg: null, viewport: null, pathsG: null, nodesG: null,
  mapArea: null, minimapSvg: null, minimapContent: null,
  scale: 1, tx: 0, ty: 0,
  isDragging: false, lastX: 0, lastY: 0,
  points: [], svgW: 0, svgH: 0,
  activeNodeIdx: -1,

  init() {
    this.svg          = document.getElementById('cjmSvg');
    this.viewport     = document.getElementById('cjmViewport');
    this.pathsG       = document.getElementById('cjmPathsGroup');
    this.nodesG       = document.getElementById('cjmNodesGroup');
    this.mapArea      = document.getElementById('cjmMapArea');
    this.minimapSvg   = document.getElementById('cjmMinimapSvg');
    this.minimapContent = document.getElementById('cjmMinimapContent');

    this._bindEvents();
    this._computeLayout();
    this._drawRoute();
    this._drawNodes();
    this._updateMinimap();
    this._updateStatusBar();
    this._animatePath();
  },

  _computeLayout() {
    const rect = this.svg.getBoundingClientRect();
    this.svgW = rect.width  || 700;
    this.svgH = rect.height || 560;

    const milestones = mapMissingSkills;
    const n = milestones.length;

    // Start: bottom-left, End: top-right
    const PAD = 90;
    const startX = PAD, startY = this.svgH - PAD;
    const endX   = this.svgW - PAD, endY = PAD + 20;

    this.points = [];

    // START NODE
    this.points.push({ x: startX, y: startY, type: 'start', label: 'Current Position', sublabel: mapAcquiredSkills.slice(0,3).join(', ') || 'Skill Baseline' });

    // MILESTONE NODES — sinusoidal snake path
    for (let i = 0; i < n; i++) {
      const t = (i + 1) / (n + 1);
      const baseX = startX + t * (endX - startX);
      const baseY = startY + t * (endY - startY);
      // Alternate left/right offset for curved feel
      const amp = Math.min(70, this.svgW * 0.08);
      const wave = Math.sin((i + 1) * Math.PI * 0.72) * amp;
      const offsetY = wave;
      this.points.push({
        x: baseX + (i % 2 === 0 ? 30 : -30),
        y: baseY + offsetY,
        type: 'milestone',
        label: milestones[i],
        idx: i + 1
      });
    }

    // DESTINATION NODE
    this.points.push({ x: endX, y: endY, type: 'destination', label: mapTargetTitle });
  },

  _buildPath() {
    const pts = this.points;
    if (pts.length < 2) return '';
    let d = "M " + pts[0].x + " " + pts[0].y;
    for (let i = 0; i < pts.length - 1; i++) {
      const a = pts[i], b = pts[i + 1];
      const cpx = (a.x + b.x) / 2;
      d += " C " + cpx + " " + a.y + ", " + cpx + " " + b.y + ", " + b.x + " " + b.y;
    }
    return d;
  },

  _ns(tag) { return document.createElementNS('http://www.w3.org/2000/svg', tag); },

  _drawRoute() {
    this.pathsG.innerHTML = '';
    const d = this._buildPath();

    // Shadow/glow path
    const shadow = this._ns('path');
    shadow.setAttribute('d', d);
    shadow.setAttribute('fill', 'none');
    shadow.setAttribute('stroke', 'rgba(6,182,212,0.08)');
    shadow.setAttribute('stroke-width', '22');
    shadow.setAttribute('stroke-linecap', 'round');
    this.pathsG.appendChild(shadow);

    // Road base
    const road = this._ns('path');
    road.setAttribute('d', d);
    road.setAttribute('fill', 'none');
    road.setAttribute('stroke', 'rgba(255,255,255,0.04)');
    road.setAttribute('stroke-width', '10');
    road.setAttribute('stroke-linecap', 'round');
    this.pathsG.appendChild(road);

    // Animated gradient route
    const route = this._ns('path');
    route.setAttribute('d', d);
    route.setAttribute('id', 'cjmRouteLine');
    route.setAttribute('fill', 'none');
    route.setAttribute('stroke', 'url(#cjmRouteGrad)');
    route.setAttribute('stroke-width', '3.5');
    route.setAttribute('stroke-linecap', 'round');
    route.setAttribute('stroke-dasharray', '10 8');
    route.style.animation = 'cjmDash 20s linear infinite';
    this.pathsG.appendChild(route);

    // Inject dash animation
    if (!document.getElementById('cjmDashStyle')) {
      const st = document.createElement('style');
      st.id = 'cjmDashStyle';
      st.textContent = "@keyframes cjmDash { to { stroke-dashoffset: -500; } }";
      document.head.appendChild(st);
    }
  },

  _drawNodes() {
    this.nodesG.innerHTML = '';
    this.points.forEach((p, idx) => {
      const g = this._ns('g');
      g.setAttribute('class', 'cjm-map-node-group');
      g.style.cursor = p.type === 'milestone' ? 'pointer' : 'default';

      if (p.type === 'start') {
        this._drawStartNode(g, p);
      } else if (p.type === 'destination') {
        this._drawDestNode(g, p);
      } else {
        this._drawMilestoneNode(g, p, idx);
      }

      this.nodesG.appendChild(g);
    });

    // Node count
    const count = this.points.filter(p => p.type === 'milestone').length;
    const el = document.getElementById('cjm-node-count');
    if (el) el.textContent = count + ' milestones';
  },

  _drawStartNode(g, p) {
    // Outer pulse ring
    const pulse = this._ns('circle');
    pulse.setAttribute('cx', p.x); pulse.setAttribute('cy', p.y); pulse.setAttribute('r', '22');
    pulse.setAttribute('fill', 'rgba(16,185,129,0.08)');
    pulse.setAttribute('stroke', 'rgba(16,185,129,0.2)'); pulse.setAttribute('stroke-width', '1');
    const pa = this._ns('animateTransform');
    pa.setAttribute('attributeName','transform'); pa.setAttribute('type','scale');
    pa.setAttribute('values','1;1.35;1'); pa.setAttribute('dur','2.5s'); pa.setAttribute('repeatCount','indefinite');
    pa.setAttribute('additive','sum');
    pulse.appendChild(pa); g.appendChild(pulse);

    // Main circle
    const c = this._ns('circle');
    c.setAttribute('cx', p.x); c.setAttribute('cy', p.y); c.setAttribute('r', '14');
    c.setAttribute('fill', '#04060e');
    c.setAttribute('stroke', '#10b981'); c.setAttribute('stroke-width', '2.5');
    c.setAttribute('filter', 'url(#cjmGlow)');
    g.appendChild(c);

    // Pin icon text
    const icon = this._ns('text');
    icon.setAttribute('x', p.x); icon.setAttribute('y', p.y + 5);
    icon.setAttribute('text-anchor', 'middle');
    icon.setAttribute('font-size', '14'); icon.setAttribute('fill', '#10b981');
    icon.textContent = '📍'; g.appendChild(icon);

    // Label
    this._addLabel(g, p.x, p.y + 32, p.label, '#10b981', '700', '0.78rem');
    if (p.sublabel) {
      this._addLabel(g, p.x, p.y + 46, p.sublabel, 'rgba(255,255,255,0.35)', '400', '0.65rem');
    }
  },

  _drawDestNode(g, p) {
    // Glow ring
    const glow = this._ns('circle');
    glow.setAttribute('cx', p.x); glow.setAttribute('cy', p.y); glow.setAttribute('r', '26');
    glow.setAttribute('fill', 'rgba(139,92,246,0.1)');
    glow.setAttribute('stroke', 'rgba(139,92,246,0.3)'); glow.setAttribute('stroke-width', '1.5');
    const ga = this._ns('animateTransform');
    ga.setAttribute('attributeName','transform'); ga.setAttribute('type','scale');
    ga.setAttribute('values','1;1.2;1'); ga.setAttribute('dur','3s'); ga.setAttribute('repeatCount','indefinite');
    ga.setAttribute('additive','sum');
    glow.appendChild(ga); g.appendChild(glow);

    // Inner circle
    const c = this._ns('circle');
    c.setAttribute('cx', p.x); c.setAttribute('cy', p.y); c.setAttribute('r', '16');
    c.setAttribute('fill', 'rgba(139,92,246,0.2)');
    c.setAttribute('stroke', '#8b5cf6'); c.setAttribute('stroke-width', '2.5');
    c.setAttribute('filter', 'url(#cjmGlowCyan)');
    g.appendChild(c);

    // Target icon
    const icon = this._ns('text');
    icon.setAttribute('x', p.x); icon.setAttribute('y', p.y + 5);
    icon.setAttribute('text-anchor', 'middle');
    icon.setAttribute('font-size', '16'); icon.textContent = '🎯';
    g.appendChild(icon);

    // Role label above
    this._addLabel(g, p.x, p.y - 28, '🏁 ' + p.label, '#8b5cf6', '800', '0.82rem');
    this._addLabel(g, p.x, p.y - 14, 'Destination Role', 'rgba(255,255,255,0.35)', '400', '0.66rem');
  },

  _drawMilestoneNode(g, p, globalIdx) {
    const colors = ['#06b6d4','#22d3ee','#67e8f9','#a5f3fc','#38bdf8','#818cf8','#c084fc'];
    const clr = colors[p.idx % colors.length];

    // Hover state via mouseover
    g.addEventListener('mouseenter', () => {
      ring.setAttribute('r', '17');
      ring.setAttribute('stroke-width', '3');
      ring.setAttribute('fill', 'rgba(6,182,212,0.12)');
      numTxt.setAttribute('fill', '#fff');
    });
    g.addEventListener('mouseleave', () => {
      if (this.activeNodeIdx !== p.idx) {
        ring.setAttribute('r', '13');
        ring.setAttribute('stroke-width', '2');
        ring.setAttribute('fill', '#0a0e1a');
        numTxt.setAttribute('fill', clr);
      }
    });

    // Outer ring
    const outerRing = this._ns('circle');
    outerRing.setAttribute('cx', p.x); outerRing.setAttribute('cy', p.y); outerRing.setAttribute('r', '19');
    outerRing.setAttribute('fill', 'rgba(6,182,212,0.06)');
    outerRing.setAttribute('stroke', 'rgba(6,182,212,0.12)'); outerRing.setAttribute('stroke-width', '1');
    g.appendChild(outerRing);

    // Main ring
    const ring = this._ns('circle');
    ring.setAttribute('cx', p.x); ring.setAttribute('cy', p.y); ring.setAttribute('r', '13');
    ring.setAttribute('fill', '#0a0e1a');
    ring.setAttribute('stroke', clr); ring.setAttribute('stroke-width', '2');
    ring.setAttribute('class', 'node-ring');
    ring.setAttribute('id', 'cjm-ring-' + p.idx);
    g.appendChild(ring);

    // Number label
    const numTxt = this._ns('text');
    numTxt.setAttribute('x', p.x); numTxt.setAttribute('y', p.y + 5);
    numTxt.setAttribute('text-anchor', 'middle');
    numTxt.setAttribute('font-size', '10'); numTxt.setAttribute('font-weight', '800');
    numTxt.setAttribute('fill', clr);
    numTxt.setAttribute('font-family', 'Outfit, sans-serif');
    numTxt.textContent = p.idx;
    g.appendChild(numTxt);

    // Skill label — offset alternating
    const labelSide = p.idx % 2 === 0 ? -1 : 1;
    const lx = p.x + labelSide * 28;
    const ly = p.y - 24;
    this._addLabel(g, lx, ly, p.label, 'rgba(255,255,255,0.75)', '600', '0.73rem');

    // Connector dot to path
    const dot = this._ns('circle');
    dot.setAttribute('cx', p.x); dot.setAttribute('cy', p.y);
    dot.setAttribute('r', '3.5'); dot.setAttribute('fill', clr);
    g.appendChild(dot);

    g.addEventListener('click', () => this._selectNode(p, g, ring, numTxt));
  },

  _addLabel(parent, x, y, text, fill, weight, size) {
    const t = this._ns('text');
    t.setAttribute('x', x); t.setAttribute('y', y);
    t.setAttribute('text-anchor', 'middle');
    t.setAttribute('fill', fill);
    t.setAttribute('font-size', size || '0.75rem');
    t.setAttribute('font-weight', weight || '600');
    t.setAttribute('font-family', 'Inter, sans-serif');
    t.setAttribute('pointer-events', 'none');
    // Wrap long text
    if (text.length > 16) {
      const words = text.split(' ');
      const line1 = words.slice(0, Math.ceil(words.length / 2)).join(' ');
      const line2 = words.slice(Math.ceil(words.length / 2)).join(' ');
      const ts1 = this._ns('tspan');
      ts1.setAttribute('x', x); ts1.setAttribute('dy', '0'); ts1.textContent = line1;
      const ts2 = this._ns('tspan');
      ts2.setAttribute('x', x); ts2.setAttribute('dy', '13'); ts2.textContent = line2;
      t.appendChild(ts1); t.appendChild(ts2);
    } else {
      t.textContent = text;
    }
    parent.appendChild(t);
  },

  _selectNode(p, g, ring, numTxt) {
    // Reset all rings
    document.querySelectorAll('.node-ring').forEach(r => {
      r.setAttribute('r', '13'); r.setAttribute('stroke-width', '2');
      r.setAttribute('fill', '#0a0e1a');
    });

    // Activate clicked ring
    ring.setAttribute('r', '17');
    ring.setAttribute('stroke-width', '3.5');
    ring.setAttribute('fill', 'rgba(6,182,212,0.15)');
    ring.setAttribute('stroke', '#06b6d4');
    numTxt.setAttribute('fill', '#fff');
    this.activeNodeIdx = p.idx;

    // Populate sidebar
    const info = getSkillInfo(p.label);
    document.getElementById('cjmPlaceholder').style.display = 'none';
    const detail = document.getElementById('cjmNodeDetail');
    detail.classList.add('visible');

    document.getElementById('cjmMilestoneChip').textContent = 'Milestone ' + p.idx;
    document.getElementById('cjmNodeName').textContent = p.label;
    document.getElementById('cjmNodeWhy').textContent = info.why;
    document.getElementById('cjmNodeResources').textContent = info.resources;
    document.getElementById('cjmNodeProject').textContent = info.project;
    document.getElementById('cjmNodeInterview').textContent = info.interview;
  },

  _animatePath() {
    // Animate path clip reveal
    const rect = document.getElementById('cjmPathClipRect');
    if (!rect) return;
    rect.setAttribute('width', '0');
    let w = 0;
    const target = this.svgW + 500;
    const step = () => {
      w += target / 60;
      if (w < target) { rect.setAttribute('width', w); requestAnimationFrame(step); }
      else { rect.setAttribute('width', target); }
    };
    setTimeout(() => requestAnimationFrame(step), 200);
  },

  _updateMinimap() {
    if (!this.minimapContent) return;
    this.minimapContent.innerHTML = '';
    const scaleX = 120 / this.svgW;
    const scaleY = 70  / this.svgH;
    const s = Math.min(scaleX, scaleY) * 0.85;

    // Draw minimap path
    const pts = this.points;
    if (pts.length < 2) return;
    let d = "M " + (pts[0].x * s + 6) + " " + (pts[0].y * s + 4);
    for (let i = 0; i < pts.length - 1; i++) {
      const a = pts[i], b = pts[i+1];
      const cpx = ((a.x + b.x)/2 * s) + 6;
      d += " C " + cpx + " " + (a.y * s + 4) + ", " + cpx + " " + (b.y * s + 4) + ", " + (b.x * s + 6) + " " + (b.y * s + 4);
    }
    const mp = document.createElementNS('http://www.w3.org/2000/svg','path');
    mp.setAttribute('d', d); mp.setAttribute('fill', 'none');
    mp.setAttribute('stroke', '#06b6d4'); mp.setAttribute('stroke-width', '1.5');
    mp.setAttribute('stroke-dasharray', '3 2');
    this.minimapContent.appendChild(mp);

    pts.forEach(p => {
      const mc = document.createElementNS('http://www.w3.org/2000/svg','circle');
      mc.setAttribute('cx', p.x*s+6); mc.setAttribute('cy', p.y*s+4);
      mc.setAttribute('r', p.type === 'milestone' ? '2.5' : '4');
      mc.setAttribute('fill', p.type === 'start' ? '#10b981' : p.type === 'destination' ? '#8b5cf6' : '#06b6d4');
      this.minimapContent.appendChild(mc);
    });
  },

  _updateStatusBar() {
    const sbStart = document.getElementById('sbStart');
    const sbDest  = document.getElementById('sbDest');
    if (sbStart && mapAcquiredSkills.length > 0) {
      sbStart.textContent = mapAcquiredSkills.slice(0,2).join(', ') + ' ···';
    }
    if (sbDest) sbDest.textContent = mapTargetTitle || 'Target Role';
  },

  _applyTransform() {
    this.viewport.setAttribute('transform', "translate(" + this.tx + "," + this.ty + ") scale(" + this.scale + ")");
  },

  _bindEvents() {
    // Scroll to zoom
    this.svg.addEventListener('wheel', e => {
      e.preventDefault();
      const delta = e.deltaY < 0 ? 1.1 : 0.91;
      this.scale = Math.min(3, Math.max(0.4, this.scale * delta));
      this._applyTransform();
    }, { passive: false });

    // Drag to pan
    this.svg.addEventListener('mousedown', e => {
      this.isDragging = true;
      this.lastX = e.clientX; this.lastY = e.clientY;
      this.svg.style.cursor = 'grabbing';
    });
    window.addEventListener('mousemove', e => {
      if (!this.isDragging) return;
      this.tx += e.clientX - this.lastX;
      this.ty += e.clientY - this.lastY;
      this.lastX = e.clientX; this.lastY = e.clientY;
      this._applyTransform();
    });
    window.addEventListener('mouseup', () => {
      this.isDragging = false;
      this.svg.style.cursor = 'grab';
    });

    // Touch support
    let lastTouchDist = 0;
    this.svg.addEventListener('touchstart', e => {
      if (e.touches.length === 1) {
        this.isDragging = true;
        this.lastX = e.touches[0].clientX;
        this.lastY = e.touches[0].clientY;
      } else if (e.touches.length === 2) {
        lastTouchDist = Math.hypot(
          e.touches[0].clientX - e.touches[1].clientX,
          e.touches[0].clientY - e.touches[1].clientY
        );
      }
    }, { passive: true });
    this.svg.addEventListener('touchmove', e => {
      if (e.touches.length === 1 && this.isDragging) {
        this.tx += e.touches[0].clientX - this.lastX;
        this.ty += e.touches[0].clientY - this.lastY;
        this.lastX = e.touches[0].clientX;
        this.lastY = e.touches[0].clientY;
        this._applyTransform();
      } else if (e.touches.length === 2) {
        const dist = Math.hypot(
          e.touches[0].clientX - e.touches[1].clientX,
          e.touches[0].clientY - e.touches[1].clientY
        );
        this.scale = Math.min(3, Math.max(0.4, this.scale * (dist / lastTouchDist)));
        lastTouchDist = dist;
        this._applyTransform();
      }
    }, { passive: true });
    this.svg.addEventListener('touchend', () => { this.isDragging = false; });
  }
};

function cjmZoom(factor) {
  CJM.scale = Math.min(3, Math.max(0.4, CJM.scale * factor));
  CJM._applyTransform();
}

function cjmResetView() {
  CJM.scale = 1; CJM.tx = 0; CJM.ty = 0;
  CJM._applyTransform();
}

function cjmCloseDetail() {
  document.getElementById('cjmNodeDetail').classList.remove('visible');
  document.getElementById('cjmPlaceholder').style.display = 'flex';
  document.querySelectorAll('.node-ring').forEach(r => {
    r.setAttribute('r', '13'); r.setAttribute('stroke-width', '2');
    r.setAttribute('fill', '#0a0e1a');
  });
  CJM.activeNodeIdx = -1;
}

/* ═══════════════════════════════════════════════════════
   TAB SWITCHER
═══════════════════════════════════════════════════════ */
let cjmInitialized = false;
function switchTab(panelId, btnEl) {
  document.querySelectorAll('.hub-tab-panel').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.hub-tab-btn').forEach(b => b.classList.remove('active'));
  const panel = document.getElementById(panelId);
  if (panel) panel.classList.add('active');
  btnEl.classList.add('active');
  sessionStorage.setItem('currentHubTab', panelId);

  if (panelId === 'roadmap-panel' && !cjmInitialized) {
    cjmInitialized = true;
    requestAnimationFrame(() => { requestAnimationFrame(() => { CJM.init(); }); });
  }
}

window.addEventListener('DOMContentLoaded', () => {
  const saved = sessionStorage.getItem('currentHubTab') || 'courses-panel';
  const btn = Array.from(document.querySelectorAll('.hub-tab-btn'))
    .find(b => b.getAttribute('onclick') && b.getAttribute('onclick').includes(saved));
  if (btn) { switchTab(saved, btn); }
  else {
    const firstBtn = document.querySelector('.hub-tab-btn');
    if (firstBtn) switchTab('courses-panel', firstBtn);
  }
});

window.addEventListener('resize', () => {
  if (cjmInitialized) {
    CJM._computeLayout();
    CJM._drawRoute();
    CJM._drawNodes();
    CJM._updateMinimap();
  }
});
</script>
<jsp:include page="/WEB-INF/jsp/floating-chat.jsp"/>
</body>
</html>
<!-- skilldev v3 -->

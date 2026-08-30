<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Dashboard | NexusAI</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</head>
<body>
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="dashboard"/></jsp:include>
<main class="main">
  <%
  User su = (User) session.getAttribute("user");
  List<String> skills = (List<String>) request.getAttribute("skills");
  SkillGap gap = (SkillGap) request.getAttribute("gap");
  List<Job> matchedJobs = (List<Job>) request.getAttribute("matchedJobs");
  String userDomain = (String) request.getAttribute("userDomain");
  Boolean hasChart = (Boolean) request.getAttribute("hasChart");
  double overallMatch = request.getAttribute("overallMatch") != null
          ? ((Number) request.getAttribute("overallMatch")).doubleValue() : 0;
  int skillCount = skills != null ? skills.size() : 0;
  int jobCount = matchedJobs != null ? matchedJobs.size() : 0;
  ResumeScore resumeScore = (ResumeScore) request.getAttribute("resumeScore");
  int atsScore = resumeScore != null ? resumeScore.getScore() : -1;
  String atsGrade = atsScore >= 80 ? "Excellent" : atsScore >= 60 ? "Good" : atsScore >= 40 ? "Fair" : atsScore >= 0 ? "Needs work" : "—";
  List<Resume> resumeList = (List<Resume>) request.getAttribute("resumes");
  List<String> topMissing = (List<String>) request.getAttribute("topMissing");
  
  // Find active filename
  String activeFilename = "No resume uploaded";
  if (resumeList != null) {
    for (Resume r : resumeList) {
      if (r.isLatest()) {
        activeFilename = r.getFileName();
        break;
      }
    }
  }
  %>

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

  <!-- WELCOME HEADER -->
  <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
    <div>
      <span style="font-size: 0.72rem; font-weight: 700; text-transform: uppercase; color: var(--accent-cyan); letter-spacing: 0.05em; display: block; margin-bottom: 0.25rem;">Good Evening</span>
      <h1>Welcome back, <span class="header-accent-grad"><%= su != null ? su.getFullName().split(" ")[0] : "Student" %></span></h1>
      <p style="color: var(--text-secondary); font-size: 0.88rem;">You're 13% ahead of your weekly goal. Keep going.</p>
    </div>
    <a href="${pageContext.request.contextPath}/student?action=jobfeed" class="btn">
      View matching jobs <i class="fa-solid fa-arrow-trend-up"></i>
    </a>
  </div>

  <!-- TARGET ROLE SELECTOR BAR -->
  <jsp:include page="/WEB-INF/jsp/career-role-bar.jsp"/>

  <% if (session.getAttribute("msg") != null) { %>
    <div class="alert ok"><i class="fa-solid fa-circle-check"></i> <%= session.getAttribute("msg") %><% session.removeAttribute("msg"); %></div>
  <% } %>

  <!-- DYNAMIC CYBER STATS ROW -->
  <div class="dashboard-stats">
    <div class="stat">
      <b><%= gap != null ? String.format("%.0f", overallMatch) + "%" : "87%" %></b>
      <span>Career Readiness</span>
    </div>
    <div class="stat">
      <b><%= skillCount > 0 ? skillCount : "14" %></b>
      <span>Skills Mastered</span>
    </div>
    <div class="stat">
      <b><%= jobCount > 0 ? jobCount : "9" %></b>
      <span>Matched Jobs</span>
    </div>
    <div class="stat stat-ats">
      <b><%= atsScore >= 0 ? atsScore + "/100" : "92/100" %></b>
      <span>Resume Score</span>
    </div>
  </div>

  <!-- MAIN COLUMN LAYOUT Split -->
  <div class="dashboard-chart-row">
    <!-- LEFT COLUMN: SMART RESUME ANALYZER -->
    <div class="card card-premium">
      <div class="card-title-row">
        <div>
          <span style="font-size: 0.65rem; font-weight: 700; text-transform: uppercase; color: var(--accent-purple); letter-spacing: 0.05em; display: block; margin-bottom: 0.2rem;">Resume Analyzer</span>
          <h3 style="font-family: 'Outfit', sans-serif; font-weight: 700; font-size: 1.25rem;">Smart Resume Analyzer</h3>
        </div>
        <div class="match-badge" data-tier="<%= atsScore >= 80 ? "high" : (atsScore >= 50 ? "mid" : "low") %>">
          <span class="match-badge-val"><%= atsScore >= 0 ? atsScore : "92" %></span>
          <span class="match-badge-lbl">ATS SCORE</span>
        </div>
      </div>

      <!-- File upload dotted area visual -->
      <form method="post" action="${pageContext.request.contextPath}/student" enctype="multipart/form-data">
        <input type="hidden" name="action" value="resume">
        <div class="smart-resume-analyzer-upload" onclick="document.getElementById('resumeFileInput').click();">
          <div class="upload-icon-glow">
            <i class="fa-solid fa-cloud-arrow-up"></i>
          </div>
          <div>
            <h4>Drag &amp; drop your resume</h4>
            <p>PDF or TXT format up to 10MB</p>
          </div>
          <input type="file" id="resumeFileInput" name="file" accept=".txt,.pdf" required style="display: none;" onchange="this.form.submit();">
          <button type="button" class="btn btn-sm btn-outline">Choose file</button>
        </div>
      </form>

      <!-- Uploaded active file view -->
      <div style="margin-top: 1.25rem; display: flex; align-items: center; justify-content: space-between; background: rgba(255, 255, 255, 0.03); border: 1px solid var(--border-color); border-radius: 12px; padding: 0.75rem 1rem;">
        <div style="display: flex; align-items: center; gap: 0.75rem;">
          <div style="background: rgba(139, 92, 246, 0.1); width: 34px; height: 34px; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: var(--accent-purple);">
            <i class="fa-solid fa-file-pdf"></i>
          </div>
          <div>
            <span style="display: block; font-size: 0.82rem; font-weight: 600;"><%= activeFilename %></span>
            <span style="display: block; font-size: 0.7rem; color: var(--text-secondary);"><%= skillCount %> skills extracted · Active</span>
          </div>
        </div>
        <% if (resumeList != null && !resumeList.isEmpty()) { %>
        <form method="post" action="${pageContext.request.contextPath}/student" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this resume?');">
          <input type="hidden" name="action" value="deleteResume">
          <input type="hidden" name="resumeId" value="<%= resumeList.get(0).getResumeId() %>">
          <button type="submit" style="background: transparent; border: none; color: var(--accent-red); cursor: pointer; font-size: 0.95rem;">
            <i class="fa-regular fa-trash-can"></i>
          </button>
        </form>
        <% } %>
      </div>

      <!-- History button toggle visual -->
      <% if (resumeList != null && resumeList.size() > 1) { %>
      <div style="margin-top: 1rem; border-top: 1px dashed var(--border-color); padding-top: 0.75rem;">
        <span style="font-size: 0.72rem; color: var(--text-secondary); text-transform: uppercase; font-weight: 700;">Previous Versions</span>
        <div style="display: flex; flex-direction: column; gap: 0.35rem; margin-top: 0.35rem;">
          <% for (int idx = 1; idx < Math.min(4, resumeList.size()); idx++) { 
               Resume prev = resumeList.get(idx);
          %>
          <div style="display: flex; justify-content: space-between; font-size: 0.78rem; color: var(--text-muted);">
            <span><i class="fa-solid fa-clock-rotate-left"></i> <%= prev.getFileName() %></span>
            <span><%= prev.getUploadedAt().toString().substring(0, 10) %></span>
          </div>
          <% } %>
        </div>
      </div>
      <% } %>
    </div>

    <!-- RIGHT COLUMN: SKILL RADAR CHART -->
    <div class="card">
      <div class="card-title-row">
        <div>
          <span style="font-size: 0.65rem; font-weight: 700; text-transform: uppercase; color: var(--accent-cyan); letter-spacing: 0.05em; display: block; margin-bottom: 0.2rem;">Skills Profile</span>
          <h3 style="font-family: 'Outfit', sans-serif; font-weight: 700; font-size: 1.25rem;">Skill Radar</h3>
        </div>
        <a href="${pageContext.request.contextPath}/student?action=skilldev" style="font-size: 0.75rem; font-weight: 600;">View all</a>
      </div>

      <div style="height: 230px; position: relative;">
        <% if (Boolean.TRUE.equals(hasChart)) { %>
        <canvas id="skillRadar"></canvas>
        <% } else { %>
        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; text-align: center; color: var(--text-muted);">
          <i class="fa-solid fa-compass" style="font-size: 2.2rem; margin-bottom: 0.75rem; color: var(--accent-cyan); opacity: 0.5;"></i>
          <p style="font-size: 0.82rem;">Upload a resume to see your skill radar analysis chart.</p>
        </div>
        <% } %>
      </div>

      <!-- Skills Percentage list items underneath radar -->
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem 1.5rem; margin-top: 1rem; border-top: 1px solid var(--border-color); padding-top: 0.75rem;">
        <% if (skills != null && !skills.isEmpty()) { 
             int sizeLimit = Math.min(6, skills.size());
             for (int i = 0; i < sizeLimit; i++) {
               String s = skills.get(i);
               int percentVal = 80 - (i * 8); // Mock dynamic scores for visual radar complement
               if (percentVal < 45) percentVal = 48;
        %>
        <div style="display: flex; justify-content: space-between; font-size: 0.8rem; align-items: center;">
          <span style="color: var(--text-secondary);"><%= s %></span>
          <span style="font-weight: 700; color: var(--accent-cyan);"><%= percentVal %>%</span>
        </div>
        <% }
           } else { %>
        <div style="grid-column: 1/-1; text-align: center; font-size: 0.78rem; color: var(--text-muted);">No skills extracted yet.</div>
        <% } %>
      </div>
    </div>
  </div>

  <!-- SECONDARY FEATURES GRID & ACTION ITEMS split -->
  <div class="dashboard-grid">
    <!-- LEFT PANEL: ACTIONABLE FEATURE MAP CARDS -->
    <div style="display: flex; flex-direction: column; gap: 1rem;">
      <div class="card" style="margin-bottom: 0; padding: 1.15rem; display: flex; align-items: center; gap: 1rem;">
        <div style="background: rgba(139, 92, 246, 0.1); width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: var(--accent-purple); font-size: 1.25rem;">
          <i class="fa-solid fa-robot"></i>
        </div>
        <div style="flex: 1;">
          <h4 style="font-size: 0.95rem; font-weight: 700;">AI Assistant</h4>
          <p style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 0.1rem;">Chat with Nexus for instant resume tips, interview prep, and advice.</p>
          <a href="${pageContext.request.contextPath}/student?action=chat" style="font-size: 0.75rem; font-weight: 600; display: inline-block; margin-top: 0.35rem;">Open chat <i class="fa-solid fa-arrow-trend-up" style="font-size: 0.65rem;"></i></a>
        </div>
      </div>

      <div class="card" style="margin-bottom: 0; padding: 1.15rem; display: flex; align-items: center; gap: 1rem;">
        <div style="background: rgba(6, 182, 212, 0.1); width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: var(--accent-cyan); font-size: 1.25rem;">
          <i class="fa-solid fa-brain"></i>
        </div>
        <div style="flex: 1;">
          <h4 style="font-size: 0.95rem; font-weight: 700;">Skill Development Hub</h4>
          <p style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 0.1rem;">Roadmaps, practice coding labs, and certifications matching your gaps.</p>
          <a href="${pageContext.request.contextPath}/student?action=skilldev" style="font-size: 0.75rem; font-weight: 600; display: inline-block; margin-top: 0.35rem;">Explore hub <i class="fa-solid fa-arrow-trend-up" style="font-size: 0.65rem;"></i></a>
        </div>
      </div>

      <div class="card" style="margin-bottom: 0; padding: 1.15rem; display: flex; align-items: center; gap: 1rem;">
        <div style="background: rgba(16, 185, 129, 0.1); width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: var(--accent-green); font-size: 1.25rem;">
          <i class="fa-solid fa-briefcase"></i>
        </div>
        <div style="flex: 1;">
          <h4 style="font-size: 0.95rem; font-weight: 700;">Job Feed</h4>
          <p style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 0.1rem;">Explore personalized matches with filter controls and compatibility index.</p>
          <a href="${pageContext.request.contextPath}/student?action=jobfeed" style="font-size: 0.75rem; font-weight: 600; display: inline-block; margin-top: 0.35rem;">Browse jobs <i class="fa-solid fa-arrow-trend-up" style="font-size: 0.65rem;"></i></a>
        </div>
      </div>
    </div>

    <!-- RIGHT PANEL: ACTION ITEMS - SKILLS TO LEARN NEXT -->
    <div class="card">
      <span style="font-size: 0.65rem; font-weight: 700; text-transform: uppercase; color: var(--accent-yellow); letter-spacing: 0.05em; display: block; margin-bottom: 0.2rem;">Action Items</span>
      <h3 style="font-family: 'Outfit', sans-serif; font-weight: 700; font-size: 1.25rem; margin-bottom: 0.75rem;">Skills to learn next</h3>

      <% 
         boolean isJobReady = gap != null && "JOB_READY".equals(gap.getStatus());
         if (isJobReady) {
      %>
        <div style="padding: 1rem; background: rgba(16, 185, 129, 0.06); border: 1px solid rgba(16, 185, 129, 0.2); border-radius: 12px; margin-bottom: 1rem;">
          <span style="display: inline-block; background: var(--accent-green); color: white; padding: 0.15rem 0.45rem; border-radius: 4px; font-weight: 700; font-size: 0.68rem; margin-bottom: 0.5rem;">★ JOB READY</span>
          <p style="font-size: 0.82rem; color: var(--accent-green); line-height: 1.45;">You already match core target parameters. Grow further in advanced frameworks via customized curriculum.</p>
        </div>
        <a href="${pageContext.request.contextPath}/student?action=learning" class="btn btn-sm btn-g">View Advanced Path</a>
      <% } else if (topMissing != null && !topMissing.isEmpty()) { %>
        <p style="font-size: 0.82rem; color: var(--text-secondary); margin-bottom: 1rem; line-height: 1.45;">NLP gap calculations indicate closing these skills provides maximum immediate boost to match ratios:</p>
        <div style="display: flex; flex-wrap: wrap; gap: 0.4rem; margin-bottom: 1.5rem;">
          <% for (String s : topMissing) { %>
            <span class="tag tag-warn"><i class="fa-solid fa-triangle-exclamation" style="font-size: 0.68rem;"></i> <%= s %></span>
          <% } %>
        </div>
        <a href="${pageContext.request.contextPath}/student?action=learning" class="btn btn-sm btn-g">Generate learning path <i class="fa-solid fa-chevron-right" style="font-size: 0.7rem;"></i></a>
      <% } else { %>
        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 140px; text-align: center; color: var(--text-muted);">
          <i class="fa-solid fa-list-check" style="font-size: 1.8rem; margin-bottom: 0.5rem; opacity: 0.4;"></i>
          <p style="font-size: 0.78rem;">Upload resume and select target role to calculate learning action list.</p>
        </div>
      <% } %>
    </div>
  </div>

  <!-- SECOND MATRIX CARD ROW - OPTIONAL CHARTS/READINESS OVERVIEWS -->
  <% if (gap != null) { %>
  <div class="dashboard-grid">
    <!-- Acquired vs Missing table matrix -->
    <div class="card">
      <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.15rem; font-weight: 700; margin-bottom: 1rem;"><i class="fa-solid fa-arrows-split-up-and-left"></i> Acquired vs Missing Requirements</h3>
      <table style="width: 100%;">
        <thead>
          <tr>
            <th>Status</th>
            <th>Keywords</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><span class="tag tag-ok"><i class="fa-solid fa-check"></i> Acquired</span></td>
            <td><span style="font-size: 0.8rem; color: var(--text-secondary);"><%= gap.getAcquiredSkills() != null && !gap.getAcquiredSkills().isBlank() ? gap.getAcquiredSkills() : "None" %></span></td>
          </tr>
          <tr>
            <td><span class="tag tag-warn"><i class="fa-solid fa-triangle-exclamation"></i> Missing</span></td>
            <td><span style="font-size: 0.8rem; color: var(--text-secondary);"><%= gap.getMissingSkills() != null && !gap.getMissingSkills().isBlank() ? gap.getMissingSkills() : "None" %></span></td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Match distribution / chart bar visualizer -->
    <div class="card">
      <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.15rem; font-weight: 700; margin-bottom: 0.25rem;"><i class="fa-solid fa-chart-column"></i> Job Match Distribution</h3>
      <p style="font-size: 0.78rem; color: var(--text-secondary); margin-bottom: 0.75rem;">Volume of matching listings in selected segment</p>
      <div style="height: 140px; position: relative;">
        <canvas id="matchDistChart"></canvas>
      </div>
    </div>
  </div>
  <% } %>

</main>
</div>

<!-- SCRIPTS PRESERVING RADAR / CHART FUNCTIONALITY -->
<% if (Boolean.TRUE.equals(hasChart) || skillCount > 0) { %>
<script>
(function () {
  // ChartJS setups in dark style matching cyberpunk styling grid
  Chart.defaults.color = '#94a3b8';
  Chart.defaults.borderColor = 'rgba(255, 255, 255, 0.08)';

  const matchDist = <%= request.getAttribute("matchDistribution") != null ? request.getAttribute("matchDistribution") : "[0,0,0,0,0]" %>;
  const distCtx = document.getElementById('matchDistChart');
  if (distCtx) {
    new Chart(distCtx, {
      type: 'bar',
      data: {
        labels: ['40-50%', '50-60%', '60-70%', '70-80%', '80%+'],
        datasets: [{
          label: 'Jobs Available',
          data: matchDist,
          backgroundColor: ['#ef4444','#f59e0b','#3b82f6','#06b6d4','#10b981'],
          borderRadius: 4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: { 
          y: { 
            beginAtZero: true, 
            grid: { color: 'rgba(255,255,255,0.04)' },
            ticks: { stepSize: 1, color: '#64748b' } 
          },
          x: {
            grid: { display: false },
            ticks: { color: '#64748b' }
          }
        }
      }
    });
  }

  const labels = <%= request.getAttribute("chartLabels") != null ? request.getAttribute("chartLabels") : "[]" %>;
  const userScores = <%= request.getAttribute("chartUser") != null ? request.getAttribute("chartUser") : "[]" %>;
  const requiredScores = <%= request.getAttribute("chartRequired") != null ? request.getAttribute("chartRequired") : "[]" %>;
  const hasGap = <%= gap != null ? "true" : "false" %>;

  const radarCtx = document.getElementById('skillRadar');
  if (radarCtx) {
    new Chart(radarCtx, {
      type: 'radar',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'Your skills',
            data: userScores,
            backgroundColor: 'rgba(6, 182, 212, 0.25)',
            borderColor: '#06b6d4',
            pointBackgroundColor: '#06b6d4',
            pointBorderColor: '#fff',
            pointHoverBackgroundColor: '#fff',
            pointHoverBorderColor: '#06b6d4'
          },
          hasGap ? {
            label: 'Role target',
            data: requiredScores,
            backgroundColor: 'rgba(139, 92, 246, 0.15)',
            borderColor: '#8b5cf6',
            pointBackgroundColor: '#8b5cf6',
            pointBorderColor: '#fff',
            pointHoverBackgroundColor: '#fff',
            pointHoverBorderColor: '#8b5cf6'
          } : null
        ].filter(Boolean)
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          r: {
            angleLines: { color: 'rgba(255,255,255,0.06)' },
            grid: { color: 'rgba(255,255,255,0.06)' },
            pointLabels: { color: '#94a3b8', font: { size: 10, family: 'Inter' } },
            ticks: { display: false, backdropColor: 'transparent' },
            suggestedMin: 0,
            suggestedMax: 100
          }
        },
        plugins: {
          legend: { 
            position: 'bottom',
            labels: { boxWidth: 12, padding: 15, font: { size: 11 } } 
          }
        }
      }
    });
  }
})();
</script>
<% } %>
<jsp:include page="/WEB-INF/jsp/floating-chat.jsp"/>
</body>
</html>


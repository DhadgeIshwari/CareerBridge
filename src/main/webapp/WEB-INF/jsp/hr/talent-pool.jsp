<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Talent Pool | CareerAssist HR</title>
  <jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
  <style>
    /* Premium Glassmorphism and Cyan Glow definitions */
    .glow-card {
      position: relative;
      border: 1px solid rgba(6, 182, 212, 0.15) !important;
      box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3), 0 0 15px rgba(6, 182, 212, 0.05) !important;
      cursor: pointer;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .glow-card:hover {
      transform: translateY(-4px) !important;
      border-color: rgba(6, 182, 212, 0.4) !important;
      box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.45), 0 0 25px rgba(6, 182, 212, 0.2) !important;
    }

    .talent-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 1.5rem;
      margin-top: 1.5rem;
    }

    .role-stats-row {
      display: flex;
      justify-content: space-between;
      border-top: 1px solid var(--border-color);
      padding-top: 1rem;
      margin-top: 1rem;
    }

    .role-stat-item {
      display: flex;
      flex-direction: column;
    }

    .role-stat-label {
      font-size: 0.68rem;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.05em;
      font-weight: 700;
    }

    .role-stat-value {
      font-family: 'Outfit', sans-serif;
      font-size: 1.1rem;
      font-weight: 700;
      margin-top: 0.15rem;
    }
  </style>
</head>
<body>
<div class="wrap">
  <jsp:include page="/WEB-INF/jsp/hr-nav.jsp"><jsp:param name="action" value="talent-pool"/></jsp:include>

  <main class="main">
    <%
      List<User> allStudents  = (List<User>) request.getAttribute("list");
      Map<Integer,Integer>       atsMap   = (Map<Integer,Integer>)       request.getAttribute("atsMap");
      Map<Integer,List<String>>  skillMap = (Map<Integer,List<String>>)  request.getAttribute("skillMap");
      Map<Integer,String>        roleMap  = (Map<Integer,String>)        request.getAttribute("roleMap");

      // Group students dynamically by their predicted role from the database
      Map<String, List<User>> roleCandidates = new LinkedHashMap<>();

      if (allStudents != null && roleMap != null) {
        for (User s : allStudents) {
          String role = roleMap.get(s.getUserId());
          if (role != null && !role.equals("Uncategorized") && !role.isBlank()) {
            roleCandidates.computeIfAbsent(role, k -> new ArrayList<>()).add(s);
          }
        }
      }
    %>

    <div class="hr-topbar">
      <div class="hr-topbar-left">
        <span class="hr-topbar-eyebrow">Recruiter Console</span>
        <h1 class="hr-page-title">Talent <span class="header-accent-grad">Overview Pool</span></h1>
        <p class="hr-page-sub">Skill-based candidate segments dynamically aggregated from resume database.</p>
      </div>
    </div>

    <!-- ROLE/DOMAIN CARDS GRID -->
    <% if (roleCandidates.isEmpty()) { %>
      <div class="hr-full-empty" style="padding: 5rem 2rem; display: flex; flex-direction: column; align-items: center; justify-content: center; background: var(--bg-card); border-radius: 16px; border: 1px solid var(--border-color); text-align: center; margin-top: 2rem;">
        <i class="fa-regular fa-folder-open" style="font-size: 3rem; color: var(--text-muted); margin-bottom: 1rem;"></i>
        <h3 style="font-family: 'Outfit'; font-size: 1.25rem;">No Dynamic Talent Segments</h3>
        <p style="color: var(--text-muted); font-size: 0.9rem; max-width: 420px; margin-top: 0.25rem;">
          No candidates have uploaded resumes or skills yet. Dynamic categorization is automatically compiled when skills are extracted.
        </p>
      </div>
    <% } else { %>
      <div class="talent-grid">
        <%
          for (Map.Entry<String, List<User>> entry : roleCandidates.entrySet()) {
            String roleName = entry.getKey();
            List<User> candidatesList = entry.getValue();
            int count = candidatesList.size();

            // Calculate average ATS/Resume score
            double totalAts = 0;
            int countAts = 0;
            for (User u : candidatesList) {
              Integer sc = atsMap != null ? atsMap.get(u.getUserId()) : null;
              if (sc != null) {
                totalAts += sc;
                countAts++;
              }
            }
            double avgAts = countAts > 0 ? (totalAts / countAts) : 0;
            String avgAtsText = avgAts > 0 ? String.format("%.0f/100", avgAts) : "—";
            
            // Choose dynamic icons based on role name
            String iconClass = "fa-solid fa-laptop-code";
            if ("Java Developer".equals(roleName)) iconClass = "fa-brands fa-java";
            else if ("Frontend Developer".equals(roleName)) iconClass = "fa-solid fa-window-maximize";
            else if ("Network Engineer".equals(roleName)) iconClass = "fa-solid fa-network-wired";
            else if ("Data Analyst".equals(roleName)) iconClass = "fa-solid fa-chart-pie";
            else if ("DevOps Engineer".equals(roleName)) iconClass = "fa-solid fa-server";
            else if ("Backend Developer".equals(roleName)) iconClass = "fa-solid fa-database";
            else if ("Cyber Security Analyst".equals(roleName)) iconClass = "fa-solid fa-shield-halved";
        %>
          <div class="card glow-card card-premium glass-panel-premium role-card-enhanced" onclick="window.location.href='${pageContext.request.contextPath}/hr?action=candidate-discovery&role=<%= java.net.URLEncoder.encode(roleName, "UTF-8") %>'">
            <div class="card-title-row" style="margin-bottom: 0.5rem;">
              <h3 style="font-size: 1.15rem; font-family: 'Outfit'; color: var(--text-primary); display: flex; align-items: center; gap: 0.65rem;">
                <i class="<%= iconClass %>" style="color: var(--accent-cyan);"></i> <%= roleName %>
              </h3>
              <span class="tag-status" style="background: rgba(6, 182, 212, 0.1); color: var(--accent-cyan); font-weight: 700;"><%= count %> Candidates</span>
            </div>
            
            <p style="font-size: 0.8rem; color: var(--text-secondary); line-height: 1.4; margin-bottom: 1.25rem;">
              Includes students matching requirements for <%= roleName %> domain, identified from resume parsing.
            </p>

            <div class="role-stats-row">
              <div class="role-stat-item">
                <span class="role-stat-label">Avg ATS Score</span>
                <span class="role-stat-value" style="color: var(--accent-cyan);"><%= avgAtsText %></span>
              </div>
            </div>
          </div>
        <% } %>
      </div>
    <% } %>

  </main>
</div>
</body>
</html>

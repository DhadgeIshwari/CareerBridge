<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Candidates | CareerAssist HR</title>
  <jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
  <jsp:include page="/WEB-INF/jsp/hr-nav.jsp"><jsp:param name="action" value="candidates"/></jsp:include>

  <main class="main">
    <%
      List<User> list = (List<User>) request.getAttribute("list");
      User viewUser   = (User) request.getAttribute("viewUser");
      List<String> viewSkills = (List<String>) request.getAttribute("viewSkills");
      Integer viewAts = (Integer) request.getAttribute("viewAts");
      SkillGap viewGap = (SkillGap) request.getAttribute("viewGap");
      String skillQuery = request.getParameter("skill");
      if (skillQuery == null) skillQuery = "";
    %>

    <div class="hr-topbar">
      <div class="hr-topbar-left">
        <span class="hr-topbar-eyebrow">Student Registry</span>
        <h1 class="hr-page-title"><span class="header-accent-grad">Candidates</span></h1>
        <p class="hr-page-sub">Search and review candidate profiles, extracted skills, and skill gap data.</p>
      </div>
    </div>

    <!-- SEARCH -->
    <div class="hr-search-wrap">
      <form method="get" action="${pageContext.request.contextPath}/hr" class="hr-search-form">
        <input type="hidden" name="action" value="candidates">
        <div class="hr-search-inner">
          <i class="fa-solid fa-magnifying-glass"></i>
          <input id="candidate-skill-search" name="skill" type="text"
                 placeholder="Search by skill e.g. Java, SQL, Python…"
                 value="<%=skillQuery%>" autocomplete="off">
          <button class="btn" type="submit"><i class="fa-solid fa-search"></i> Search</button>
          <% if (!skillQuery.isEmpty()) { %>
            <a href="${pageContext.request.contextPath}/hr?action=candidates" class="btn btn-outline">Clear</a>
          <% } %>
        </div>
      </form>
    </div>

    <!-- PROFILE DETAIL PANEL (when view= is set) -->
    <% if (viewUser != null) { %>
    <div class="card card-premium hr-profile-panel">
      <div class="hr-profile-header">
        <div class="hr-profile-avatar-lg">
          <%=viewUser.getFullName() != null && !viewUser.getFullName().isEmpty() ? viewUser.getFullName().substring(0,1).toUpperCase() : "?"%>
        </div>
        <div class="hr-profile-details">
          <h2 class="hr-profile-name"><%=viewUser.getFullName()%></h2>
          <span class="hr-profile-email"><i class="fa-solid fa-envelope"></i> <%=viewUser.getEmail()%></span>
          <% if (viewUser.getPhone() != null && !viewUser.getPhone().isEmpty()) { %>
            <span class="hr-profile-phone"><i class="fa-solid fa-phone"></i> <%=viewUser.getPhone()%></span>
          <% } %>
        </div>
        <% if (viewAts != null) {
            String atsCl = viewAts >= 80 ? "ats-badge-high" : viewAts >= 60 ? "ats-badge-mid" : "ats-badge-low";
        %>
        <div class="hr-profile-ats-ring <%=atsCl%>">
          <div class="hr-profile-ats-inner">
            <span class="hr-profile-ats-val"><%=viewAts%></span>
            <span class="hr-profile-ats-lbl">ATS Score</span>
          </div>
        </div>
        <% } else { %>
        <div class="hr-profile-ats-ring" style="border-color: var(--border-color);">
          <div class="hr-profile-ats-inner">
            <span class="hr-profile-ats-val" style="color:var(--text-muted);">—</span>
            <span class="hr-profile-ats-lbl">No Score</span>
          </div>
        </div>
        <% } %>
      </div>

      <div class="hr-profile-body">
        <div class="hr-profile-section">
          <h4 class="hr-profile-section-title"><i class="fa-solid fa-code" style="color:var(--accent-cyan)"></i> Extracted Skills</h4>
          <div class="hr-profile-skills">
            <% if (viewSkills != null && !viewSkills.isEmpty()) {
                for (String sk : viewSkills) { %>
                  <span class="tag tag-skill"><%=sk%></span>
            <%  }
              } else { %>
              <span style="color:var(--text-muted); font-size:0.85rem;">No skills found in resume yet.</span>
            <% } %>
          </div>
        </div>

        <% if (viewGap != null) { %>
        <div class="hr-profile-section">
          <h4 class="hr-profile-section-title"><i class="fa-solid fa-chart-simple" style="color:var(--accent-purple)"></i> Latest Skill Gap Analysis</h4>
          <div class="hr-gap-row">
            <div class="hr-gap-stat">
              <span class="hr-gap-stat-val"><%=String.format("%.0f", viewGap.getGapPercentage())%>%</span>
              <span class="hr-gap-stat-lbl">Gap</span>
            </div>
            <div class="hr-gap-info">
              <p><strong>Target Role:</strong> <%=viewGap.getTargetTitle() != null ? viewGap.getTargetTitle() : "—"%></p>
              <% if (viewGap.getMissingSkills() != null && !viewGap.getMissingSkills().isEmpty()) { %>
                <p style="margin-top:0.5rem;"><strong>Missing:</strong>
                  <% for (String ms : viewGap.getMissingSkills().split(",")) { %>
                    <span class="tag tag-warn"><%=ms.trim()%></span>
                  <% } %>
                </p>
              <% } %>
            </div>
          </div>
        </div>
        <% } %>

      </div>
    </div>
    <% } %>

    <!-- CANDIDATES TABLE -->
    <div class="card">
      <div class="card-title-row">
        <h3><i class="fa-solid fa-table-list" style="color:var(--accent-cyan); margin-right:0.5rem;"></i>
          All Candidates
          <% if (!skillQuery.isEmpty()) { %><span style="color:var(--text-muted); font-size:0.78rem; font-weight:400; margin-left:0.5rem;">— filtered by "<%=skillQuery%>"</span><% } %>
        </h3>
        <span style="color:var(--text-muted); font-size:0.82rem;"><%=list != null ? list.size() : 0%> student(s)</span>
      </div>

      <% if (list == null || list.isEmpty()) { %>
        <div class="hr-empty-state">
          <i class="fa-solid fa-user-slash"></i>
          <p>No candidates found<% if (!skillQuery.isEmpty()) { %> for skill "<%=skillQuery%>"<% } %>.</p>
        </div>
      <% } else { %>
      <div class="hr-table-wrapper">
        <table class="hr-table">
          <thead>
            <tr>
              <th>#</th>
              <th>Candidate</th>
              <th>Email</th>
              <th>Profile</th>
            </tr>
          </thead>
          <tbody>
            <% int idx = 1; for (User c : list) {
                String init = c.getFullName() != null && !c.getFullName().isEmpty() ? c.getFullName().substring(0,1).toUpperCase() : "?";
            %>
            <tr>
              <td class="hr-table-idx"><%=idx++%></td>
              <td>
                <div class="hr-table-user">
                  <div class="hr-table-avatar"><%=init%></div>
                  <span><%=c.getFullName()%></span>
                </div>
              </td>
              <td class="hr-table-email"><%=c.getEmail()%></td>
              <td>
                <a href="${pageContext.request.contextPath}/hr?action=candidates&view=<%=c.getUserId()%><%=!skillQuery.isEmpty()?"&skill="+java.net.URLEncoder.encode(skillQuery,"UTF-8"):""%>"
                   class="btn btn-sm">
                  <i class="fa-solid fa-eye"></i> View
                </a>
              </td>
            </tr>
            <% } %>
          </tbody>
        </table>
      </div>
      <% } %>
    </div>

  </main>
</div>
</body>
</html>

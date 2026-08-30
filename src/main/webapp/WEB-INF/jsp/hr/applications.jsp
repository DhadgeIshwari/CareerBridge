<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Applications | CareerAssist HR</title>
  <jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
  <jsp:include page="/WEB-INF/jsp/hr-nav.jsp"><jsp:param name="action" value="applications"/></jsp:include>

  <main class="main">
    <%
      List<Application> apps = (List<Application>) request.getAttribute("apps");
      String statusFilter = (String) request.getAttribute("statusFilter");
      if (statusFilter == null) statusFilter = "ALL";
    %>

    <div class="hr-topbar">
      <div class="hr-topbar-left">
        <span class="hr-topbar-eyebrow">Track & Manage</span>
        <h1 class="hr-page-title"><span class="header-accent-grad">Applications</span></h1>
        <p class="hr-page-sub">Review all incoming applications and update candidate statuses.</p>
      </div>
    </div>

    <!-- STATUS FILTER TABS -->
    <div class="hr-filter-tabs">
      <% String[] statuses = {"ALL","APPLIED","INTERVIEW","SELECTED","REJECTED"};
         for (String s : statuses) {
           boolean active = s.equals(statusFilter);
      %>
      <a href="${pageContext.request.contextPath}/hr?action=applications&status=<%=s%>"
         class="hr-filter-tab <%=active?"hr-filter-tab-active":""%>">
        <%=s.charAt(0) + s.substring(1).toLowerCase()%>
      </a>
      <% } %>
    </div>

    <!-- APPLICATIONS TABLE -->
    <div class="card">
      <div class="card-title-row">
        <h3>
          <i class="fa-solid fa-file-lines" style="color:var(--accent-cyan); margin-right:0.5rem;"></i>
          <%="ALL".equals(statusFilter) ? "All Applications" : statusFilter.charAt(0) + statusFilter.substring(1).toLowerCase() + " Applications"%>
        </h3>
        <span style="color:var(--text-muted); font-size:0.82rem;">
          <%=apps != null ? apps.size() : 0%> record(s)
        </span>
      </div>

      <% if (apps == null || apps.isEmpty()) { %>
        <div class="hr-empty-state">
          <i class="fa-regular fa-folder-open" style="font-size:2.5rem; opacity:0.3;"></i>
          <p>No applications found for the selected filter.</p>
        </div>
      <% } else { %>
      <div class="hr-table-wrapper">
        <table class="hr-table">
          <thead>
            <tr>
              <th>#</th>
              <th>Candidate</th>
              <th>Job Applied For</th>
              <th>Source</th>
              <th>Current Status</th>
              <th>Applied On</th>
              <th>Update</th>
            </tr>
          </thead>
          <tbody>
            <% int idx = 1; for (Application ap : apps) {
                String st = ap.getStatus() != null ? ap.getStatus() : "APPLIED";
                String stClass = "SELECTED".equals(st) ? "tag-ok" : "REJECTED".equals(st) ? "tag tag-r" : "INTERVIEW".equals(st) ? "tag-match" : "tag-skill";
                String init = ap.getStudentName() != null && !ap.getStudentName().isEmpty() ? ap.getStudentName().substring(0,1).toUpperCase() : "?";
                String appliedAt = ap.getAppliedAt() != null && ap.getAppliedAt().length() >= 10 ? ap.getAppliedAt().substring(0,10) : "—";
            %>
            <tr>
              <td class="hr-table-idx"><%=idx++%></td>
              <td>
                <div class="hr-table-user">
                  <div class="hr-table-avatar"><%=init%></div>
                  <span><%=ap.getStudentName() != null ? ap.getStudentName() : "Unknown"%></span>
                </div>
              </td>
              <td>
                <div style="display:flex; flex-direction:column; gap:0.15rem;">
                  <span style="font-weight:600; color:var(--text-primary);"><%=ap.getJobTitle() != null ? ap.getJobTitle() : "—"%></span>
                  <span style="font-size:0.75rem; color:var(--text-muted);"><%=ap.getCompany() != null ? ap.getCompany() : ""%></span>
                </div>
              </td>
              <td>
                <span class="tag" style="font-size:0.7rem;">
                  <%=ap.getJobSource() != null ? ap.getJobSource() : "INTERNAL"%>
                </span>
              </td>
              <td><span class="tag <%=stClass%>"><%=st%></span></td>
              <td style="color:var(--text-muted); font-size:0.82rem;"><%=appliedAt%></td>
              <td>
                <form method="post" action="${pageContext.request.contextPath}/hr"
                      class="hr-status-form">
                  <input type="hidden" name="action" value="applications">
                  <input type="hidden" name="appId" value="<%=ap.getApplicationId()%>">
                  <div class="hr-status-row">
                    <select name="status" class="hr-status-select" id="status-<%=ap.getApplicationId()%>">
                      <option value="APPLIED"   <%="APPLIED".equals(st)   ? "selected":""%>>Applied</option>
                      <option value="INTERVIEW" <%="INTERVIEW".equals(st) ? "selected":""%>>Interview</option>
                      <option value="SELECTED"  <%="SELECTED".equals(st)  ? "selected":""%>>Selected</option>
                      <option value="REJECTED"  <%="REJECTED".equals(st)  ? "selected":""%>>Rejected</option>
                    </select>
                    <button class="btn btn-sm" type="submit">
                      <i class="fa-solid fa-check"></i>
                    </button>
                  </div>
                </form>
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

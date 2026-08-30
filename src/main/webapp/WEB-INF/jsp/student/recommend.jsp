<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Recommendations</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="recommend"/></jsp:include>
<main class="main jobfeed-main">
  <jsp:include page="/WEB-INF/jsp/career-role-bar.jsp"/>
  <h1>Top Recommendations</h1>
  <p class="dashboard-sub">Jobs for your selected role</p>

  <div class="job-feed">
    <% List<JobFeedItem> feed = (List<JobFeedItem>) request.getAttribute("feed");
       if (feed != null && !feed.isEmpty()) {
         int n = 0;
         for (JobFeedItem j : feed) {
           if (n++ >= 12) break;
           String applyUrl = j.getApplyUrl();
    %>
    <article class="job-card-v2">
      <div class="job-card-head">
        <div>
          <h3><%= j.getTitle() %></h3>
          <p class="job-card-company"><%= j.getCompany() %></p>
        </div>
        <div class="match-badge" data-tier="<%= j.getMatchPct() >= 70 ? "high" : "mid" %>">
          <span class="match-badge-val"><%= String.format("%.0f", j.getMatchPct()) %>%</span>
          <span class="match-badge-lbl">match</span>
        </div>
      </div>
      <div class="job-card-meta">
        <span class="tag tag-domain"><%= j.getDomainLabel() %></span>
        <span class="tag tag-source"><%= j.getSource() %></span>
      </div>
      <% if (applyUrl != null && !applyUrl.isBlank()) { %>
      <a href="<%= applyUrl %>" target="_blank" rel="noopener noreferrer" class="btn btn-apply">Apply</a>
      <% } %>
    </article>
    <%   }
       } else {
         List<Job> jobs = (List<Job>) request.getAttribute("jobs");
         if (jobs != null && !jobs.isEmpty()) {
           for (Job j : jobs) { if (j.getMatchPct() < 40) continue; %>
    <div class="card"><h3><%= j.getTitle() %></h3><p><%= j.getCompany() %></p>
    <span class="tag tag-match"><%= String.format("%.0f", j.getMatchPct()) %>%</span></div>
    <%     }
         } else { %>
    <div class="card"><p class="muted">Upload resume and refresh job feed to see recommendations.</p></div>
    <%   }
       } %>
  </div>
</main>
</div>
<jsp:include page="/WEB-INF/jsp/floating-chat.jsp"/>
</body>
</html>

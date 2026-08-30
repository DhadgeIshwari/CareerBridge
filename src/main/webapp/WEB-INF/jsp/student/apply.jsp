<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Review &amp; Apply</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="jobfeed"/></jsp:include>
<main class="main apply-page">
<%
ApplyPreview p = (ApplyPreview) request.getAttribute("preview");
if (p == null) {
%>
<div class="card"><p class="muted">Job not found. <a href="${pageContext.request.contextPath}/student?action=jobfeed">Back to feed</a></p></div>
<% } else {
  List<String> matched = p.getMatchedSkills() != null ? p.getMatchedSkills() : List.of();
  List<String> missing = p.getMissingSkills() != null ? p.getMissingSkills() : List.of();
  List<String> userSkills = p.getUserSkills() != null ? p.getUserSkills() : List.of();
%>
<a href="${pageContext.request.contextPath}/student?action=jobfeed" class="apply-back muted">← Back to job feed</a>
<h1>Review before you apply</h1>
<p class="dashboard-sub">Stay in CareerAssist to track this application — open the external posting only when you choose.</p>

<div class="apply-hero card">
  <div class="apply-hero-top">
    <div>
      <h2><%= p.getTitle() %></h2>
      <p class="feed-meta"><strong><%= p.getCompany() %></strong>
        <% if (p.getLocation() != null && !p.getLocation().isBlank()) { %> · <%= p.getLocation() %><% } %>
      </p>
      <span class="tag"><%= p.getSource() %></span>
    </div>
    <div class="apply-match-ring">
      <span class="apply-match-value"><%= String.format("%.0f", p.getMatchPct()) %>%</span>
      <span class="apply-match-label">Match</span>
    </div>
  </div>
  <% if (p.getDescription() != null && !p.getDescription().isBlank()) { %>
  <p class="feed-desc"><%= p.getDescription().length() > 400 ? p.getDescription().substring(0, 400) + "…" : p.getDescription() %></p>
  <% } %>
</div>

<div class="apply-grid">
  <div class="card">
    <h3>Skills you have</h3>
    <% if (!matched.isEmpty()) { %>
    <div class="skill-tags">
      <% for (String s : matched) { %><span class="tag tag-ok"><%= s %></span><% } %>
    </div>
    <% } else if (!userSkills.isEmpty()) { %>
    <div class="skill-tags">
      <% for (String s : userSkills) { %><span class="tag tag-skill"><%= s %></span><% } %>
    </div>
    <p class="muted card-hint">No direct overlap with listed requirements — general resume skills shown.</p>
    <% } else { %>
    <p class="muted">Upload your resume to extract skills automatically.</p>
    <% } %>
  </div>

  <div class="card">
    <h3>Skills to develop</h3>
    <% if (!missing.isEmpty()) { %>
    <div class="skill-tags">
      <% for (String s : missing) { %><span class="tag tag-warn"><%= s %></span><% } %>
    </div>
    <% } else { %>
    <p class="tag tag-ok">You cover all listed requirements.</p>
    <% } %>
  </div>

  <div class="card apply-why">
    <h3>Why this job is recommended</h3>
    <p><%= p.getWhyRecommended() %></p>
  </div>

  <div class="card">
    <h3>Resume summary</h3>
    <% if (p.getResumeSummary() != null && !p.getResumeSummary().isBlank()) { %>
    <p class="apply-resume-summary"><%= p.getResumeSummary() %></p>
    <% } else { %>
    <p class="muted">No resume on file. <a href="${pageContext.request.contextPath}/student?action=dashboard">Upload resume</a> for NLP skill extraction and smarter matching.</p>
    <% } %>
  </div>
</div>

<div class="card apply-actions-card">
  <h3>Choose how to apply</h3>
  <% if (p.isAlreadyApplied()) { %>
  <p class="alert ok">You already track this application.</p>
  <a href="${pageContext.request.contextPath}/student?action=applications" class="btn btn-g">Open Apply Tracker</a>
  <% } else { %>
  <div class="apply-actions">
    <form method="post" action="${pageContext.request.contextPath}/student">
      <input type="hidden" name="action" value="applyConfirm">
      <input type="hidden" name="feedType" value="<%= p.getFeedType() %>">
      <input type="hidden" name="refId" value="<%= p.getRefId() %>">
      <button type="submit" class="btn btn-g">Apply internally (track application)</button>
    </form>
    <% if (p.getExternalUrl() != null && !p.getExternalUrl().isBlank()) { %>
    <a href="<%= p.getExternalUrl() %>" target="_blank" rel="noopener noreferrer" class="btn btn-outline">Open external job page</a>
    <% } %>
  </div>
  <p class="muted apply-hint">Internal apply saves status on your kanban board. External link opens the original listing in a new tab — you are never forced to leave CareerAssist first.</p>
  <% } %>
</div>
<% } %>
</main>
</div>
</body>
</html>

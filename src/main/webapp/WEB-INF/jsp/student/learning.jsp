<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Skill Practice Hub</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="learning"/></jsp:include>
<main class="main practice-hub-main">
  <jsp:include page="/WEB-INF/jsp/career-role-bar.jsp"/>

  <header class="hub-header">
    <h1>Skill Practice Hub</h1>
    <p class="dashboard-sub">Learn · Read · Practice — personalized paths from your resume and skill gap analysis</p>
  </header>

  <form method="post" action="${pageContext.request.contextPath}/student" class="hub-toolbar">
    <input type="hidden" name="action" value="learning">
    <button class="btn btn-g">Regenerate full roadmap</button>
    <a href="${pageContext.request.contextPath}/student?action=skillgap" class="btn btn-sm btn-outline">Update skill gap</a>
  </form>

  <% List<String> resumeSkills = (List<String>) request.getAttribute("resumeSkills");
     if (resumeSkills != null && !resumeSkills.isEmpty()) { %>
  <div class="card hub-resume-skills">
    <h3>Your resume skills</h3>
    <div class="skill-tags">
      <% for (String s : resumeSkills) { %><span class="tag tag-skill"><%= s %></span><% } %>
    </div>
  </div>
  <% } %>

<%
  List<SkillLearningHub> hubs = (List<SkillLearningHub>) request.getAttribute("hubs");
  if (hubs != null && !hubs.isEmpty()) {
    for (SkillLearningHub hub : hubs) {
%>

  <section class="card skill-hub-block">
    <div class="skill-hub-head">
      <h2><%= hub.getSkillName() %></h2>
      <span class="tag tag-domain">Skill roadmap</span>
    </div>

    <!-- LEARN -->
    <div class="hub-section hub-section-learn">
      <h3 class="hub-section-title"><span class="hub-icon">▶</span> Learn</h3>
      <p class="hub-section-hint">YouTube playlists, courses, and structured video learning</p>
      <% if (hub.getLearnItems() != null && !hub.getLearnItems().isEmpty()) { %>
      <div class="hub-resource-grid">
        <% for (LearningItem item : hub.getLearnItems()) {
             String stage = item.getLevelStage() != null ? item.getLevelStage() : "";
             String label;
             if ("BEGINNER".equals(stage)) label = "Beginner";
             else if ("INTERMEDIATE".equals(stage)) label = "Intermediate";
             else if ("ADVANCED".equals(stage)) label = "Advanced";
             else if ("PROJECTS".equals(stage)) label = "Project";
             else label = stage;
        %>
        <div class="hub-resource-card hub-learn-card">
          <span class="hub-stage-pill"><%= label %></span>
          <h4><%= item.getTitle() %></h4>
          <p class="muted"><%= item.getPlatform() %></p>
          <a href="<%= item.getResourceUrl() %>" target="_blank" rel="noopener" class="btn btn-sm">Open</a>
        </div>
        <% } %>
      </div>
      <% } else { %><p class="muted">No learn resources yet.</p><% } %>
    </div>

    <!-- READ -->
    <div class="hub-section hub-section-read">
      <h3 class="hub-section-title"><span class="hub-icon">📖</span> Read</h3>
      <p class="hub-section-hint">Official documentation and reference books</p>
      <% if (hub.getReadItems() != null && !hub.getReadItems().isEmpty()) { %>
      <div class="hub-resource-grid hub-read-grid">
        <% for (LearningItem item : hub.getReadItems()) {
             String label = "READ_DOC".equals(item.getLevelStage()) ? "Documentation" : "Book / Guide";
        %>
        <div class="hub-resource-card hub-read-card">
          <span class="hub-stage-pill hub-pill-read"><%= label %></span>
          <h4><%= item.getTitle() %></h4>
          <p class="muted"><%= item.getPlatform() %></p>
          <a href="<%= item.getResourceUrl() %>" target="_blank" rel="noopener" class="btn btn-sm btn-outline">Read</a>
        </div>
        <% } %>
      </div>
      <% } else { %><p class="muted">No read resources for this skill.</p><% } %>
    </div>

    <!-- PRACTICE -->
    <div class="hub-section hub-section-practice">
      <h3 class="hub-section-title"><span class="hub-icon">⚡</span> Practice this skill</h3>
      <p class="hub-section-hint">Real-world labs and coding platforms — apply what you learned</p>
      <% List<PracticeLink> practice = hub.getPracticeLinks();
         if (practice != null && !practice.isEmpty()) { %>
      <div class="practice-platform-grid">
        <% for (PracticeLink p : practice) { %>
        <a href="<%= p.getUrl() %>" target="_blank" rel="noopener noreferrer" class="practice-platform-card">
          <span class="practice-platform-name"><%= p.getName() %></span>
          <span class="practice-platform-desc"><%= p.getDescription() != null ? p.getDescription() : "Hands-on practice" %></span>
          <span class="practice-platform-cta">Start practicing →</span>
        </a>
        <% } %>
      </div>
      <% } else { %><p class="muted">Practice platforms loading from catalog…</p><% } %>
    </div>
  </section>

<%
    }
  } else {
%>

  <div class="card empty-feed-card">
    <h3>Build your practice hub</h3>
    <p class="muted">Upload your resume and run <a href="${pageContext.request.contextPath}/student?action=skillgap">skill gap analysis</a>, then click <strong>Regenerate full roadmap</strong>.</p>
  </div>

<%
  }
%>

</main>
</div>
</body>
</html>

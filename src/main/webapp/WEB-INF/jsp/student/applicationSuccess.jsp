<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Application tracked</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="applications"/></jsp:include>
<main class="main apply-success">
<%
String jobTitle = request.getParameter("job");
if (jobTitle == null || jobTitle.isBlank()) {
  Object msg = session.getAttribute("msg");
  if (msg != null) jobTitle = msg.toString().replaceFirst("^Application tracked: ", "");
}
%>
<div class="card apply-success-card">
  <div class="apply-success-icon">✓</div>
  <h1>Application tracked</h1>
  <% if (jobTitle != null && !jobTitle.isBlank()) { %>
  <p class="dashboard-sub"><strong><%= jobTitle %></strong> is on your Apply Tracker board.</p>
  <% } else { %>
  <p class="dashboard-sub">Your application was saved successfully.</p>
  <% } %>
  <% if (session.getAttribute("msg") != null) { %>
  <p class="muted"><%= session.getAttribute("msg") %><% session.removeAttribute("msg"); %></p>
  <% } %>
  <div class="apply-success-actions">
    <a href="${pageContext.request.contextPath}/student?action=applications" class="btn btn-g">View my applications</a>
    <a href="${pageContext.request.contextPath}/student?action=jobfeed" class="btn btn-outline">Browse more jobs</a>
    <a href="${pageContext.request.contextPath}/student?action=dashboard" class="btn btn-sm">Dashboard</a>
  </div>
</div>
</main>
</div>
</body>
</html>

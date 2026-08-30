<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.careerassist.model.User" %>
<%
    String ctx = request.getContextPath();
    String a = request.getParameter("action");
    if (a == null) a = "dashboard";
    User navUser = (User) session.getAttribute("user");
    String navName = navUser != null ? navUser.getFullName() : "HR";
    String navInitial = navName.length() > 0 ? navName.substring(0,1).toUpperCase() : "H";
%>
<aside class="side">
  <div>
    <div class="side-logo-area">
      <div class="side-logo-icon">
        <i class="fa-solid fa-briefcase"></i>
      </div>
      <div class="side-logo-text">
        <span class="side-logo-brand">CareerAssist</span>
        <span class="side-logo-role">Recruiter Portal</span>
      </div>
    </div>

    <nav class="side-links">
      <a href="<%=ctx%>/hr?action=dashboard"
         class="side-link <%="dashboard".equals(a)?"on":""%>"
         id="nav-dashboard">
        <span class="side-link-icon"><i class="fa-solid fa-chart-pie"></i></span>
        <span class="side-link-label">Dashboard</span>
        <%if("dashboard".equals(a)){%><span class="side-link-active-dot"></span><%}%>
      </a>
      <a href="<%=ctx%>/hr?action=talent-pool"
         class="side-link <%="talent-pool".equals(a)?"on":""%>"
         id="nav-talent-pool">
        <span class="side-link-icon"><i class="fa-solid fa-users"></i></span>
        <span class="side-link-label">Talent Pool</span>
        <%if("talent-pool".equals(a)){%><span class="side-link-active-dot"></span><%}%>
      </a>
      <a href="<%=ctx%>/hr?action=post-job"
         class="side-link <%="post-job".equals(a) || "jobs".equals(a)?"on":""%>"
         id="nav-post-job">
        <span class="side-link-icon"><i class="fa-solid fa-plus-circle"></i></span>
        <span class="side-link-label">Post Job</span>
        <%if("post-job".equals(a) || "jobs".equals(a)){%><span class="side-link-active-dot"></span><%}%>
      </a>
      <a href="<%=ctx%>/hr?action=messages"
         class="side-link <%="messages".equals(a)?"on":""%>"
         id="nav-messages">
        <span class="side-link-icon"><i class="fa-solid fa-envelope"></i></span>
        <span class="side-link-label">Messages</span>
        <%if("messages".equals(a)){%><span class="side-link-active-dot"></span><%}%>
      </a>
      <a href="<%=ctx%>/auth?action=logout"
         class="side-link"
         id="nav-logout">
        <span class="side-link-icon"><i class="fa-solid fa-arrow-right-from-bracket"></i></span>
        <span class="side-link-label">Logout</span>
      </a>
    </nav>
  </div>

  <div class="side-footer">
    <div class="side-user-chip">
      <div class="side-user-avatar"><%=navInitial%></div>
      <div class="side-user-info">
        <span class="side-user-name"><%=navName%></span>
        <span class="side-user-role">HR Recruiter</span>
      </div>
    </div>
  </div>
</aside>

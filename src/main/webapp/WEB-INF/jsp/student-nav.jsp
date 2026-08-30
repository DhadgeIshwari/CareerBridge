<%@ page import="com.careerassist.model.User, com.careerassist.model.SkillGap, com.careerassist.service.CareerService" %>
<% 
User su = (User) session.getAttribute("user"); 
String ctx = request.getContextPath(); 
String a = request.getParameter("action"); 
if (a == null) a = "dashboard"; 

double readinessVal = 87.0;
if (su != null) {
  try {
    CareerService cs = new CareerService();
    SkillGap gap = cs.getContextSkillGap(su.getUserId(), request);
    if (gap != null) {
      readinessVal = Math.round((100.0 - gap.getGapPercentage()) * 10.0) / 10.0;
    }
  } catch (Exception e) {
    // Fallback to default
  }
}
%>
<aside class="side">
  <div>
    <h3><i class="fa-solid fa-compass-drafting"></i> NexusAI</h3>
    <div class="side-links">
      <a href="<%=ctx%>/student?action=dashboard" class="<%=a.equals("dashboard")?"on":""%>">
        <i class="fa-solid fa-chart-pie"></i> Dashboard
      </a>
      <a href="<%=ctx%>/student?action=jobfeed" class="<%=a.equals("jobfeed")||a.equals("jobs")?"on":""%>">
        <i class="fa-solid fa-briefcase"></i> Job Feed
      </a>
      <a href="<%=ctx%>/student?action=skilldev" class="<%=a.equals("skilldev")||a.equals("learning")?"on":""%>">
        <i class="fa-solid fa-brain"></i> Skill Hub
      </a>
      <a href="<%=ctx%>/student?action=skillgap" class="<%=a.equals("skillgap")?"on":""%>">
        <i class="fa-solid fa-chart-bar"></i> Skill Gap Analysis
      </a>
      <a href="<%=ctx%>/student?action=recommend" class="<%=a.equals("recommend")?"on":""%>">
        <i class="fa-solid fa-star"></i> Top Picks
      </a>
      <a href="<%=ctx%>/auth?action=logout">
        <i class="fa-solid fa-right-from-bracket"></i> Logout
      </a>
    </div>
  </div>
  
  <div class="side-footer">
    <p><i class="fa-solid fa-user-circle"></i> <%=su!=null?su.getFullName():"Student"%></p>
    <div class="career-readiness-badge">
      <div class="readiness-text">Career Readiness: <%= String.format("%.0f", readinessVal) %>%</div>
      <div class="readiness-bar">
        <div class="readiness-fill" style="width: <%= readinessVal %>%"></div>
      </div>
    </div>
  </div>
</aside>

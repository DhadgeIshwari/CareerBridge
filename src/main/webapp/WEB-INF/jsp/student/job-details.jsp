<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Job Details | CareerAssist</title>
  <jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
  <jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="jobfeed"/></jsp:include>
  
  <main class="main">
    <%
      Job job = (Job) request.getAttribute("job");
      Double matchPct = (Double) request.getAttribute("matchPct");
      List<String> matchedSkills = (List<String>) request.getAttribute("matchedSkills");
      List<String> missingSkills = (List<String>) request.getAttribute("missingSkills");
      String initial = job.getCompany().substring(0, Math.min(2, job.getCompany().length())).toUpperCase();
      int colorHash = Math.abs(job.getCompany().hashCode()) % 4;
      String avatarGrad = colorHash == 1 ? "background: linear-gradient(135deg, #10b981 0%, #06b6d4 100%);" :
                          colorHash == 2 ? "background: linear-gradient(135deg, #ec4899 0%, #f43f5e 100%);" :
                          colorHash == 3 ? "background: linear-gradient(135deg, #f59e0b 0%, #d946ef 100%);" :
                          "background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);";
    %>
    
    <div style="margin-bottom: 2rem;">
      <a href="${pageContext.request.contextPath}/student?action=jobfeed" class="btn btn-sm btn-outline" style="border: none; padding: 0.5rem 0;">
        <i class="fa-solid fa-arrow-left"></i> Back to Job Feed
      </a>
    </div>

    <div class="card card-premium" style="padding: 2.5rem; position: relative; overflow: hidden;">
      <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 6px; border-radius: 4px 0 0 4px; 
        <%= matchPct >= 70 ? "background: var(--accent-cyan); box-shadow: var(--glow-cyan);" : (matchPct >= 50 ? "background: var(--accent-yellow);" : "background: var(--accent-red);") %>"></div>
      
      <div style="display: flex; gap: 1.5rem; align-items: flex-start; margin-bottom: 2rem;">
        <div style="<%= avatarGrad %> width: 72px; height: 72px; border-radius: 16px; display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 1.5rem; box-shadow: 0 4px 15px rgba(0,0,0,0.3);">
          <%= initial %>
        </div>
        <div style="flex: 1;">
          <h1 style="font-size: 1.8rem; margin: 0 0 0.5rem;"><%= job.getTitle() %></h1>
          <p style="font-size: 1.1rem; color: var(--text-secondary); margin: 0;">
            <i class="fa-solid fa-building"></i> <%= job.getCompany() %> &nbsp;
            <span style="color: var(--text-muted);">|</span> &nbsp;
            <i class="fa-solid fa-location-dot"></i> <%= job.getLocation() %>
          </p>
          <div style="margin-top: 1rem; display: flex; gap: 0.75rem; flex-wrap: wrap;">
            <span class="tag tag-domain"><%= job.getDomain() %></span>
            <span class="tag tag-time"><i class="fa-solid fa-briefcase"></i> <%= job.getJobType() != null ? job.getJobType() : "Full-time" %></span>
            <span class="tag" style="background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1);"><i class="fa-solid fa-indian-rupee-sign"></i> <%= job.getSalaryRange() != null ? job.getSalaryRange() : "Not Disclosed" %></span>
            <span class="tag" style="background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1);"><i class="fa-solid fa-layer-group"></i> <%= job.getExperienceLevel() != null ? job.getExperienceLevel() : "Entry Level" %></span>
          </div>
        </div>
        <div style="text-align: right;">
          <div class="match-badge" data-tier="<%= matchPct >= 70 ? "high" : (matchPct >= 50 ? "mid" : "low") %>" style="transform: scale(1.2); transform-origin: top right;">
            <span class="match-badge-val"><%= Math.round(matchPct) %>%</span>
            <span class="match-badge-lbl">match</span>
          </div>
          <div style="margin-top: 2rem;">
            <form action="${pageContext.request.contextPath}/student" method="post">
              <input type="hidden" name="action" value="apply-internal">
              <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
              <button type="submit" class="btn btn-apply" style="padding: 0.75rem 1.5rem; font-size: 1rem;"><i class="fa-solid fa-paper-plane"></i> Apply Now</button>
            </form>
          </div>
        </div>
      </div>

      <hr style="border: none; border-top: 1px solid var(--border-color); margin: 2rem 0;">

      <div style="background: rgba(139, 92, 246, 0.05); border: 1px solid rgba(139, 92, 246, 0.2); border-radius: 12px; padding: 1.5rem; margin-bottom: 2rem;">
        <h3 style="color: var(--accent-purple); margin: 0 0 1rem; display: flex; align-items: center; gap: 0.5rem;">
          <i class="fa-solid fa-wand-magic-sparkles"></i> Why this job was recommended
        </h3>
        <p style="margin: 0; line-height: 1.6; font-size: 1.05rem;">
          Recommended because your resume contains 
          <% if (matchedSkills.size() > 0) { %>
            <strong style="color: var(--accent-cyan);"><%= String.join(", ", matchedSkills) %></strong> 
          <% } else { %>
            basic foundation skills
          <% } %>
          which align with this <strong style="color: var(--accent-purple);"><%= job.getDomain() %></strong> role.
        </p>
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-bottom: 2.5rem;">
        <div>
          <h3 style="margin: 0 0 1rem; font-size: 1.1rem;"><i class="fa-solid fa-circle-check" style="color: var(--accent-cyan);"></i> Matched Skills</h3>
          <div class="skill-tags">
            <% if (matchedSkills.isEmpty()) { %>
              <span class="muted">No direct matches.</span>
            <% } else { for (String s : matchedSkills) { %>
              <span class="tag tag-ok" style="font-size: 0.9rem; padding: 0.4rem 0.8rem;"><%= s %></span>
            <% }} %>
          </div>
        </div>
        <div>
          <h3 style="margin: 0 0 1rem; font-size: 1.1rem;"><i class="fa-solid fa-triangle-exclamation" style="color: var(--accent-yellow);"></i> Missing Skills (To Learn)</h3>
          <div class="skill-tags">
            <% if (missingSkills.isEmpty()) { %>
              <span class="muted">You match all required skills!</span>
            <% } else { for (String s : missingSkills) { %>
              <span class="tag tag-warn" style="font-size: 0.9rem; padding: 0.4rem 0.8rem;"><%= s %></span>
            <% }} %>
          </div>
        </div>
      </div>

      <h3 style="margin: 0 0 1rem; font-size: 1.25rem;">Job Description</h3>
      <div style="line-height: 1.7; color: var(--text-secondary); white-space: pre-wrap; margin-bottom: 2rem;"><%= job.getDescription() %></div>
      
      <% if (job.getRequirements() != null && !job.getRequirements().isBlank()) { %>
      <h3 style="margin: 0 0 1rem; font-size: 1.25rem;">Requirements</h3>
      <div style="line-height: 1.7; color: var(--text-secondary); white-space: pre-wrap;"><%= job.getRequirements() %></div>
      <% } %>

    </div>
  </main>
</div>
</body>
</html>

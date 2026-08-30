<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Recommended Jobs | NexusAI</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="jobfeed"/></jsp:include>
<main class="main">
  <%
  User su = (User) session.getAttribute("user");
  List<String> skills = (List<String>) request.getAttribute("skills");
  List<JobFeedItem> feed = (List<JobFeedItem>) request.getAttribute("feed");
  %>

  <!-- TOP NAVBAR -->
  <div class="top-navbar">
    <div class="navbar-user">
      <div class="notification-btn">
        <i class="fa-regular fa-bell"></i>
      </div>
      <div class="user-profile-badge">
        <div class="user-avatar">
          <%= su != null && su.getFullName() != null && !su.getFullName().isEmpty() ? su.getFullName().substring(0, 1).toUpperCase() : "U" %>
        </div>
        <div class="user-info-text">
          <span class="user-name-span"><%= su != null ? su.getFullName() : "Student" %></span>
          <span class="user-sub-span">Final Year · CSE</span>
        </div>
      </div>
    </div>
  </div>



  <!-- PAGE HEADER -->
  <div class="feed-header" style="margin-bottom: 2rem;">
    <div>
      <span style="font-size: 0.72rem; font-weight: 700; text-transform: uppercase; color: var(--accent-cyan); letter-spacing: 0.05em; display: block; margin-bottom: 0.25rem;">Explore Careers</span>
      <h1>Recommended Jobs</h1>

    </div>
    <div class="feed-actions">
      <button type="button" class="btn btn-sm btn-outline" id="btnRefresh">
        <i class="fa-solid fa-rotate"></i> Refresh listings
      </button>
      <span class="feed-status muted" id="feedStatus" style="font-size: 0.75rem; margin-left: 0.5rem; color: var(--text-muted);"></span>
    </div>
  </div>

  <% if (request.getAttribute("feedMessage") != null) { %>
    <div class="alert ok"><i class="fa-solid fa-circle-check"></i> <%= request.getAttribute("feedMessage") %></div>
  <% } %>
  <% if (session.getAttribute("error") != null) { %>
    <div class="alert err"><i class="fa-solid fa-triangle-exclamation"></i> <%= session.getAttribute("error") %><% session.removeAttribute("error"); %></div>
  <% } %>

  <!-- DYNAMIC RESUME UPLOAD REQUIREMENT CHECK -->
  <% if (skills == null || skills.isEmpty()) { %>
    <div class="card" style="text-align: center; padding: 3rem 2rem;">
      <i class="fa-solid fa-file-invoice" style="font-size: 3rem; color: var(--accent-purple); opacity: 0.4; margin-bottom: 1rem;"></i>
      <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.3rem; font-weight: 700; margin-bottom: 0.5rem;">Upload your resume first</h3>
      <p style="color: var(--text-secondary); font-size: 0.88rem; max-width: 460px; margin: 0 auto 1.5rem; line-height: 1.5;">NLP extracts skills from your resume to show you matching jobs in your career domain.</p>
      <a href="${pageContext.request.contextPath}/student?action=dashboard" class="btn btn-g">Go to dashboard</a>
    </div>
  <% } else { %>
    <!-- INTERNAL JOB SEGMENTS -->
    <% 
      List<Job> recInt = (List<Job>) request.getAttribute("recommendedInternal");
      List<Job> expInt = (List<Job>) request.getAttribute("exploreInternal");
      boolean hasInternalJobs = (recInt != null && !recInt.isEmpty()) || (expInt != null && !expInt.isEmpty());
    %>

    <% if (!hasInternalJobs) { %>
      <div class="card" style="text-align: center; padding: 2.5rem 2rem; margin-bottom: 2rem;">
        <i class="fa-solid fa-magnifying-glass" style="font-size: 2.5rem; color: var(--accent-purple); opacity: 0.4; margin-bottom: 1rem;"></i>
        <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.15rem; font-weight: 700; margin-bottom: 0.5rem;">No matching internal jobs found</h3>
        <p style="color: var(--text-secondary); font-size: 0.88rem; max-width: 460px; margin: 0 auto; line-height: 1.5;">
          No HR-posted jobs match your resume skills and career domain. Check back later or explore external listings below.
        </p>
      </div>
    <% } %>

    <% if (recInt != null && !recInt.isEmpty()) { %>
      <div style="margin: 2rem 0 1rem; display: flex; align-items: center; gap: 0.75rem;">
        <i class="fa-solid fa-bullseye" style="color: var(--accent-cyan); font-size: 1.25rem;"></i>
        <h2 style="font-family: 'Outfit'; font-size: 1.25rem;">Recommended Internal Jobs</h2>
      </div>
      <section class="job-feed">
        <% for (Job j : recInt) { 
             String missing = String.join(", ", com.careerassist.util.AppUtil.missing(skills, j.getSkills() != null && !j.getSkills().isEmpty() ? j.getSkills() : Arrays.asList(j.getRequirements().split(","))));
             String matched = String.join(", ", com.careerassist.util.AppUtil.matched(skills, j.getSkills() != null && !j.getSkills().isEmpty() ? j.getSkills() : Arrays.asList(j.getRequirements().split(","))));
             String initial = j.getCompany().substring(0, Math.min(2, j.getCompany().length())).toUpperCase();
             int colorHash = Math.abs(j.getCompany().hashCode()) % 4;
             String avatarGrad = colorHash == 1 ? "background: linear-gradient(135deg, #10b981 0%, #06b6d4 100%);" :
                                colorHash == 2 ? "background: linear-gradient(135deg, #ec4899 0%, #f43f5e 100%);" :
                                colorHash == 3 ? "background: linear-gradient(135deg, #f59e0b 0%, #d946ef 100%);" :
                                "background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);";
        %>
        <article class="job-card-v2">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; border-radius: 4px 0 0 4px; 
            <%= j.getMatchPct() >= 70 ? "background: var(--accent-cyan); box-shadow: var(--glow-cyan);" : (j.getMatchPct() >= 50 ? "background: var(--accent-yellow);" : "background: var(--accent-red);") %>"></div>
          <div class="job-card-head">
            <div style="display: flex; gap: 1rem; align-items: flex-start;">
              <div style="<%= avatarGrad %> width: 46px; height: 46px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 1rem; box-shadow: 0 4px 10px rgba(0,0,0,0.25);">
                <%= initial %>
              </div>
              <div>
                <h3><%= j.getTitle() %></h3>
                <p class="job-card-company"><%= j.getCompany() %> <span style="color: var(--text-muted);">·</span> <i class="fa-solid fa-location-dot" style="font-size: 0.72rem;"></i> <%= j.getLocation() %></p>
              </div>
            </div>
            <div class="match-badge" data-tier="<%= j.getMatchPct() >= 70 ? "high" : (j.getMatchPct() >= 50 ? "mid" : "low") %>">
              <span class="match-badge-val"><%= Math.round(j.getMatchPct()) %>%</span>
              <span class="match-badge-lbl">match</span>
            </div>
          </div>
          <div class="job-card-meta" style="margin-left: 3.8rem;">
            <span class="tag tag-source" style="background: rgba(139, 92, 246, 0.15); color: var(--accent-purple); border-color: rgba(139, 92, 246, 0.3);"><i class="fa-solid fa-building-user"></i> Internal Opportunity</span>
            <span class="tag tag-domain"><%= j.getDomain() %></span>
            <span class="tag tag-time"><i class="fa-regular fa-clock" style="font-size: 0.7rem;"></i> <%= j.getJobType() != null ? j.getJobType() : "Full-time" %></span>
          </div>
          <div style="margin-left: 3.8rem; margin-top: 0.75rem;">
            <% if (!matched.isEmpty()) { %>
            <div class="skill-row"><span class="skill-row-label">Matched Skills</span>
              <div class="skill-tags">
                <% for (String t : matched.split(",")) { if (!t.trim().isEmpty()) { %><span class="tag tag-ok"><i class="fa-solid fa-circle-check" style="font-size: 0.68rem;"></i> <%= t.trim() %></span><% }} %>
              </div>
            </div>
            <% } %>
            <% if (!missing.isEmpty()) { %>
            <div class="skill-row"><span class="skill-row-label">Missing</span>
              <div class="skill-tags">
                <% for (String t : missing.split(",")) { if (!t.trim().isEmpty()) { %><span class="tag tag-warn"><i class="fa-solid fa-triangle-exclamation" style="font-size: 0.68rem;"></i> <%= t.trim() %></span><% }} %>
              </div>
            </div>
            <% } %>
          </div>
          <div class="job-card-foot" style="margin-left: 3.8rem;">
            <div style="display: flex; gap: 0.5rem; width: 100%; justify-content: flex-end;">
              <a href="${pageContext.request.contextPath}/student?action=job-details&jobId=<%= j.getJobId() %>" class="btn btn-sm btn-apply">View Details <i class="fa-solid fa-arrow-right" style="font-size: 0.7rem;"></i></a>
            </div>
          </div>
        </article>
        <% } %>
      </section>
    <% } %>

    <% if (expInt != null && !expInt.isEmpty()) { %>
      <div style="margin: 3rem 0 1rem; display: flex; align-items: center; gap: 0.75rem;">
        <i class="fa-solid fa-compass" style="color: var(--accent-purple); font-size: 1.25rem;"></i>
        <h2 style="font-family: 'Outfit'; font-size: 1.25rem;">Explore Opportunities</h2>
      </div>
      <section class="job-feed" style="opacity: 0.85;">
        <% for (Job j : expInt) { 
             String missing = String.join(", ", com.careerassist.util.AppUtil.missing(skills, j.getSkills() != null && !j.getSkills().isEmpty() ? j.getSkills() : Arrays.asList(j.getRequirements().split(","))));
             String matched = String.join(", ", com.careerassist.util.AppUtil.matched(skills, j.getSkills() != null && !j.getSkills().isEmpty() ? j.getSkills() : Arrays.asList(j.getRequirements().split(","))));
             String initial = j.getCompany().substring(0, Math.min(2, j.getCompany().length())).toUpperCase();
        %>
        <article class="job-card-v2" style="background: rgba(15, 23, 42, 0.4);">
          <div class="job-card-head">
            <div style="display: flex; gap: 1rem; align-items: flex-start;">
              <div style="background: var(--bg-body); border: 1px solid var(--border-color); width: 46px; height: 46px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: var(--text-primary); font-weight: 800; font-size: 1rem;">
                <%= initial %>
              </div>
              <div>
                <h3><%= j.getTitle() %></h3>
                <p class="job-card-company"><%= j.getCompany() %> <span style="color: var(--text-muted);">·</span> <i class="fa-solid fa-location-dot" style="font-size: 0.72rem;"></i> <%= j.getLocation() %></p>
              </div>
            </div>
            <div class="match-badge" data-tier="<%= j.getMatchPct() >= 70 ? "high" : (j.getMatchPct() >= 50 ? "mid" : "low") %>">
              <span class="match-badge-val"><%= Math.round(j.getMatchPct()) %>%</span>
              <span class="match-badge-lbl">match</span>
            </div>
          </div>
          <div class="job-card-meta" style="margin-left: 3.8rem;">
            <span class="tag tag-source"><i class="fa-solid fa-building-user"></i> Internal Opportunity</span>
            <span class="tag tag-domain"><%= j.getDomain() %></span>
          </div>
          <div class="job-card-foot" style="margin-left: 3.8rem;">
            <div style="display: flex; gap: 0.5rem; width: 100%; justify-content: flex-end;">
              <a href="${pageContext.request.contextPath}/student?action=job-details&jobId=<%= j.getJobId() %>" class="btn btn-sm btn-outline">View Details</a>
            </div>
          </div>
        </article>
        <% } %>
      </section>
    <% } %>

    <!-- EXTERNAL JOB FEED -->
    <% if (feed != null && !feed.isEmpty()) { %>
      <div style="margin: 3rem 0 1rem; display: flex; align-items: center; gap: 0.75rem;">
        <i class="fa-solid fa-globe" style="color: var(--text-muted); font-size: 1.25rem;"></i>
        <h2 style="font-family: 'Outfit'; font-size: 1.25rem;">External Job Feed</h2>
      </div>
      <section class="job-feed" id="jobFeed">
        <!-- Rendered by JS or original JSP loop -->
        <script>
          document.addEventListener("DOMContentLoaded", function() {
            renderFeed(<%= new com.google.gson.Gson().toJson(feed) %>);
          });
        </script>
      </section>
    <% } %>
  <% } %>
</main>
</div>

<script>
const ctx = '${pageContext.request.contextPath}';
const feedEl = document.getElementById('jobFeed');
const statusEl = document.getElementById('feedStatus');

function escapeHtml(s) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function skillTags(csv, cls, iconCls) {
  if (!csv) return '';
  return csv.split(',').map(s => s.trim()).filter(Boolean)
    .map(t => '<span class="tag '+cls+'"><i class="'+iconCls+'" style="font-size: 0.68rem;"></i> '+escapeHtml(t)+'</span>').join('');
}

function renderFeed(items) {
  if (!items || !items.length) {
    feedEl.innerHTML = '<div class="card" style="text-align: center; padding: 2rem; color: var(--text-muted);"><p>No relevant jobs found. Upload resume and refresh.</p></div>';
    return;
  }
  
  feedEl.innerHTML = items.map(j => {
    const tier = j.matchPct >= 70 ? 'high' : (j.matchPct >= 50 ? 'mid' : 'low');
    const loc = j.location ? '<span style="color: var(--text-muted);">·</span> <i class="fa-solid fa-location-dot" style="font-size: 0.72rem;"></i> ' + escapeHtml(j.location) : '';
    
    const bookmarkBtn = '<button type="button" class="btn btn-sm btn-outline" style="padding: 0.5rem 0.85rem;" title="Bookmark Listing"><i class="fa-regular fa-bookmark"></i></button>';
    const apply = j.applyUrl ? bookmarkBtn + '<a href="'+escapeHtml(j.applyUrl)+'" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-apply">Apply now <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 0.7rem;"></i></a>'
      : '<span class="muted" style="font-size: 0.78rem; display: flex; align-items: center; gap: 0.25rem;"><i class="fa-solid fa-lock" style="font-size: 0.7rem;"></i> Internal listing</span>';
      
    const desc = j.description ? '<p class="job-card-desc" style="margin-left: 3.8rem;">'+escapeHtml(j.description.length > 140 ? j.description.substring(0,140)+'…' : j.description)+'</p>' : '';
    const matched = j.matchedSkills ? '<div class="skill-row"><span class="skill-row-label">Matched Skills</span><div class="skill-tags">'+skillTags(j.matchedSkills,'tag-ok','fa-solid fa-circle-check')+'</div></div>' : '';
    const missing = j.missingSkills ? '<div class="skill-row"><span class="skill-row-label">Skill Gap</span><div class="skill-tags">'+skillTags(j.missingSkills,'tag-warn','fa-solid fa-triangle-exclamation')+'</div></div>' : '';
    const high = j.highMatch ? '<span class="tag tag-match-high">🔥 Top pick</span>' : '';
    
    const fBadge = j.freshnessBadge;
    let freshHtml = '';
    if (fBadge === 'NEW') {
      freshHtml = '<span class="tag tag-ok" style="font-weight: 700; border-radius: 4px;"><i class="fa-solid fa-bolt" style="font-size: 0.7rem;"></i> NEW</span>';
    } else if (fBadge === 'THIS_WEEK') {
      freshHtml = '<span class="tag tag-match" style="font-weight: 600; border-radius: 4px;">This Week</span>';
    }

    // Company Avatar initials
    let initial = "CO";
    if (j.company) {
      initial = j.company.substring(0, Math.min(2, j.company.length)).toUpperCase();
    }
    
    // Gradient calculations
    let hash = 0;
    if (j.company) {
      for (let charIdx = 0; charIdx < j.company.length; charIdx++) {
        hash = j.company.charCodeAt(charIdx) + ((hash << 5) - hash);
      }
    }
    const colorHash = Math.abs(hash) % 4;
    let avatarGrad = "background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);";
    if (colorHash === 1) avatarGrad = "background: linear-gradient(135deg, #10b981 0%, #06b6d4 100%);";
    if (colorHash === 2) avatarGrad = "background: linear-gradient(135deg, #ec4899 0%, #f43f5e 100%);";
    if (colorHash === 3) avatarGrad = "background: linear-gradient(135deg, #f59e0b 0%, #d946ef 100%);";

    const glowColor = j.matchPct >= 70 ? 'var(--accent-cyan)' : (j.matchPct >= 50 ? 'var(--accent-yellow)' : 'var(--accent-red)');
    const glowShadow = j.matchPct >= 70 ? 'box-shadow: var(--glow-cyan);' : '';

    return '<article class="job-card-v2" style="position: relative;">'
      +'<div style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; border-radius: 4px 0 0 4px; background: '+glowColor+'; '+glowShadow+'"></div>'
      +'<div class="job-card-head"><div style="display: flex; gap: 1rem; align-items: flex-start;">'
      +'<div style="'+avatarGrad+' width: 46px; height: 46px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 1rem; box-shadow: 0 4px 10px rgba(0,0,0,0.25);">'+initial+'</div>'
      +'<div><h3>'+escapeHtml(j.title)+'</h3><p class="job-card-company">'+escapeHtml(j.company)+loc+'</p></div></div>'
      +'<div class="match-badge" data-tier="'+tier+'"><span class="match-badge-val">'+Math.round(j.matchPct)+'%</span><span class="match-badge-lbl">match</span></div></div>'
      +'<div class="job-card-meta" style="margin-left: 3.8rem;"><span class="tag tag-domain">'+escapeHtml(j.domainLabel||'')+'</span><span class="tag tag-source">'+escapeHtml(j.source)+'</span><span class="tag tag-time"><i class="fa-regular fa-clock" style="font-size: 0.7rem;"></i> '+escapeHtml(j.postedLabel)+'</span>'+freshHtml+high+'</div>'
      +'<div style="margin-left: 3.8rem; margin-top: 0.75rem;">'+matched+missing+'</div>'+desc+'<div class="job-card-foot" style="margin-left: 3.8rem;"><div style="display: flex; gap: 0.5rem; width: 100%; justify-content: flex-end;">'+apply+'</div></div></article>';
  }).join('');
}

function refreshFeed() {
  statusEl.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Fetching…';
  const fd = new FormData();
  fd.append('action', 'refreshFeed');
  fd.append('ajax', '1');
  fetch(ctx + '/student', { method: 'POST', body: fd })
    .then(r => r.json())
    .then(d => {
      renderFeed(d.feed);
      statusEl.textContent = 'Updated ' + new Date().toLocaleTimeString();
      if (d.message) statusEl.title = d.message;
    })
    .catch(() => { statusEl.textContent = 'Refresh failed'; });
}

const btn = document.getElementById('btnRefresh');
if (btn) btn.addEventListener('click', refreshFeed);
</script>
<jsp:include page="/WEB-INF/jsp/floating-chat.jsp"/>
</body>
</html>

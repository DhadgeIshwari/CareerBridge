<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Job Postings | CareerAssist HR</title>
  <jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
  <style>
    /* ── Page Layout ───────────────────────────────── */
    .jobs-page-grid {
      display: grid;
      grid-template-columns: 480px 1fr;
      gap: 2rem;
      align-items: flex-start;
    }
    @media (max-width: 1050px) {
      .jobs-page-grid { grid-template-columns: 1fr; }
    }

    /* ── Form Card ─────────────────────────────────── */
    .form-card {
      background: rgba(15, 23, 42, 0.7);
      border: 1px solid rgba(6, 182, 212, 0.25);
      border-radius: 20px;
      padding: 2.25rem;
      backdrop-filter: blur(24px);
      box-shadow: 0 0 40px rgba(6, 182, 212, 0.05), 0 8px 40px rgba(0,0,0,0.35);
      position: sticky;
      top: 2rem;
    }
    .form-card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 2rem;
      padding-bottom: 1.25rem;
      border-bottom: 1px solid rgba(255,255,255,0.06);
    }
    .form-card-title {
      display: flex;
      align-items: center;
      gap: 0.75rem;
    }
    .form-card-icon {
      width: 44px;
      height: 44px;
      border-radius: 12px;
      background: linear-gradient(135deg, rgba(6,182,212,0.2), rgba(139,92,246,0.2));
      border: 1px solid rgba(6,182,212,0.3);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.1rem;
      color: var(--accent-cyan);
      box-shadow: 0 0 16px rgba(6,182,212,0.15);
    }
    .form-card-title h3 {
      font-family: 'Outfit', sans-serif;
      font-size: 1.15rem;
      font-weight: 700;
      margin: 0;
    }
    .form-card-title p {
      color: var(--text-muted);
      font-size: 0.78rem;
      margin: 0.2rem 0 0;
    }

    /* ── Form Fields ───────────────────────────────── */
    .form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1.1rem;
    }
    .form-group { display: flex; flex-direction: column; gap: 0.45rem; }
    .form-group.full { grid-column: 1 / -1; }

    .form-label {
      font-size: 0.78rem;
      font-weight: 600;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    .form-label .req { color: var(--accent-cyan); margin-left: 2px; }

    .form-control {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.1);
      border-radius: 10px;
      color: var(--text-primary);
      font-size: 0.92rem;
      padding: 0.7rem 1rem;
      transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
      font-family: 'Inter', sans-serif;
      width: 100%;
      box-sizing: border-box;
    }
    .form-control::placeholder { color: rgba(148,163,184,0.4); }
    .form-control:focus {
      outline: none;
      border-color: rgba(6,182,212,0.6);
      background: rgba(6,182,212,0.04);
      box-shadow: 0 0 0 3px rgba(6,182,212,0.1);
    }
    select.form-control { cursor: pointer; }
    select.form-control option { background: #0f172a; }
    textarea.form-control { resize: vertical; min-height: 90px; line-height: 1.5; }

    .skill-hint {
      font-size: 0.73rem;
      color: var(--text-muted);
      margin-top: 0.25rem;
    }

    /* ── Submit Button ─────────────────────────────── */
    .btn-post {
      width: 100%;
      padding: 0.9rem;
      font-size: 1rem;
      font-weight: 700;
      border-radius: 12px;
      background: linear-gradient(135deg, #06b6d4 0%, #8b5cf6 100%);
      color: #fff;
      border: none;
      cursor: pointer;
      margin-top: 1.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.6rem;
      transition: opacity 0.2s, transform 0.15s, box-shadow 0.2s;
      box-shadow: 0 4px 20px rgba(6,182,212,0.3);
      letter-spacing: 0.01em;
    }
    .btn-post:hover { opacity: 0.9; transform: translateY(-1px); box-shadow: 0 8px 30px rgba(6,182,212,0.4); }

    /* ── Domain Preview Badge ──────────────────────── */
    .domain-preview {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      background: rgba(139,92,246,0.08);
      border: 1px solid rgba(139,92,246,0.2);
      border-radius: 8px;
      padding: 0.6rem 0.85rem;
      margin-top: 0.5rem;
      font-size: 0.82rem;
      color: var(--accent-purple);
      font-weight: 600;
      min-height: 38px;
    }

    /* ── Right Panel ───────────────────────────────── */
    .postings-panel {}
    .postings-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 1.5rem;
    }
    .postings-header h2 {
      font-family: 'Outfit', sans-serif;
      font-size: 1.25rem;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 0.6rem;
    }
    .postings-count {
      background: rgba(6,182,212,0.1);
      border: 1px solid rgba(6,182,212,0.2);
      color: var(--accent-cyan);
      font-size: 0.78rem;
      font-weight: 700;
      padding: 0.25rem 0.75rem;
      border-radius: 999px;
    }

    /* ── Job Entry Card ────────────────────────────── */
    .job-entry {
      background: rgba(15, 23, 42, 0.6);
      border: 1px solid rgba(255,255,255,0.07);
      border-radius: 16px;
      padding: 1.5rem 1.75rem;
      margin-bottom: 1rem;
      transition: border-color 0.2s, transform 0.2s, box-shadow 0.2s;
      position: relative;
      overflow: hidden;
    }
    .job-entry:hover {
      border-color: rgba(6,182,212,0.25);
      transform: translateY(-2px);
      box-shadow: 0 8px 30px rgba(0,0,0,0.2), 0 0 20px rgba(6,182,212,0.05);
    }
    .job-entry-accent {
      position: absolute;
      left: 0; top: 0; bottom: 0;
      width: 4px;
      border-radius: 4px 0 0 4px;
    }
    .job-entry-top {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 1rem;
    }
    .job-entry-left { display: flex; align-items: flex-start; gap: 1rem; }
    .job-entry-avatar {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-weight: 800;
      font-size: 1rem;
      flex-shrink: 0;
      box-shadow: 0 4px 12px rgba(0,0,0,0.25);
    }
    .job-entry-info {}
    .job-entry-title {
      font-size: 1rem;
      font-weight: 700;
      color: var(--text-primary);
      font-family: 'Outfit', sans-serif;
      display: block;
      margin-bottom: 0.2rem;
    }
    .job-entry-meta {
      font-size: 0.8rem;
      color: var(--text-muted);
      display: flex;
      align-items: center;
      gap: 0.5rem;
      flex-wrap: wrap;
    }
    .job-entry-badges {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
      margin-top: 1rem;
    }
    .job-entry-actions {
      display: flex;
      gap: 0.5rem;
      margin-top: 1.25rem;
      padding-top: 1rem;
      border-top: 1px solid rgba(255,255,255,0.05);
    }
    .job-entry-actions a, .job-entry-actions button { flex: 1; text-align: center; justify-content: center; }

    .badge-active {
      background: rgba(16,185,129,0.12);
      border: 1px solid rgba(16,185,129,0.3);
      color: #34d399;
      font-size: 0.72rem;
      font-weight: 700;
      padding: 0.2rem 0.65rem;
      border-radius: 999px;
      letter-spacing: 0.05em;
    }
    .badge-closed {
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.1);
      color: var(--text-muted);
      font-size: 0.72rem;
      font-weight: 600;
      padding: 0.2rem 0.65rem;
      border-radius: 999px;
      letter-spacing: 0.05em;
    }

    .empty-state {
      text-align: center;
      padding: 4rem 2rem;
      background: rgba(15, 23, 42, 0.4);
      border: 1px dashed rgba(255,255,255,0.08);
      border-radius: 20px;
    }
    .empty-state i { font-size: 3rem; opacity: 0.15; display: block; margin-bottom: 1rem; }
    .empty-state p { color: var(--text-muted); font-size: 0.9rem; }
  </style>
</head>
<body>
<div class="wrap">
  <jsp:include page="/WEB-INF/jsp/hr-nav.jsp"><jsp:param name="action" value="jobs"/></jsp:include>

  <main class="main">
    <%
      List<Job> jobs = (List<Job>) request.getAttribute("jobs");
      Job editJob    = (Job) request.getAttribute("editJob");
      boolean isEdit = editJob != null;
    %>

    <!-- Page Header -->
    <div class="hr-topbar" style="margin-bottom: 2rem;">
      <div class="hr-topbar-left">
        <span class="hr-topbar-eyebrow">HR Portal</span>
        <h1 class="hr-page-title"><span class="header-accent-grad"><%= isEdit ? "Edit Job Posting" : "Job Postings" %></span></h1>
        <p class="hr-page-sub">Create and manage openings. Posted jobs automatically appear in the Student Job Feed.</p>
      </div>
    </div>

    <% if (session.getAttribute("error") != null) { %>
      <div class="alert err"><i class="fa-solid fa-triangle-exclamation"></i> <%=session.getAttribute("error")%><% session.removeAttribute("error"); %></div>
    <% } %>
    <% if (session.getAttribute("msg") != null) { %>
      <div class="alert ok"><i class="fa-solid fa-circle-check"></i> <%=session.getAttribute("msg")%><% session.removeAttribute("msg"); %></div>
    <% } %>

    <div class="jobs-page-grid">

      <!-- ══════════════ LEFT: FORM ══════════════ -->
      <div class="form-card">
        <div class="form-card-header">
          <div class="form-card-title">
            <div class="form-card-icon">
              <i class="fa-solid fa-<%= isEdit ? "pen-to-square" : "circle-plus" %>"></i>
            </div>
            <div>
              <h3><%= isEdit ? "Edit Job" : "Post New Job" %></h3>
              <p><%= isEdit ? "Update posting details below" : "Fill in the details to publish" %></p>
            </div>
          </div>
          <% if (isEdit) { %>
            <a href="${pageContext.request.contextPath}/hr?action=jobs" class="btn btn-sm btn-outline">
              <i class="fa-solid fa-xmark"></i> Cancel
            </a>
          <% } %>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/hr" id="jobForm">
          <input type="hidden" name="action" value="jobs">
          <% if (isEdit) { %>
            <input type="hidden" name="jobId" value="<%= editJob.getJobId() %>">
          <% } %>

          <div class="form-grid">

            <!-- Job Title -->
            <div class="form-group full">
              <label class="form-label" for="jobTitle">Job Title <span class="req">*</span></label>
              <input id="jobTitle" name="title" class="form-control" required
                     placeholder="e.g. Senior Java Developer"
                     value="<%= isEdit ? editJob.getTitle() : "" %>">
            </div>

            <!-- Company -->
            <div class="form-group">
              <label class="form-label" for="jobCompany">Company <span class="req">*</span></label>
              <input id="jobCompany" name="company" class="form-control" required
                     placeholder="e.g. TechCorp Pvt Ltd"
                     value="<%= isEdit ? editJob.getCompany() : "" %>">
            </div>

            <!-- Location -->
            <div class="form-group">
              <label class="form-label" for="jobLocation">Location</label>
              <input id="jobLocation" name="location" class="form-control"
                     placeholder="e.g. Bangalore / Remote"
                     value="<%= isEdit && editJob.getLocation() != null ? editJob.getLocation() : "" %>">
            </div>

            <!-- Job Type -->
            <div class="form-group">
              <label class="form-label" for="jobType">Job Type</label>
              <select id="jobType" name="jobType" class="form-control">
                <option value="Full-time" <%= isEdit && "Full-time".equals(editJob.getJobType()) ? "selected" : "" %>>Full-time</option>
                <option value="Part-time" <%= isEdit && "Part-time".equals(editJob.getJobType()) ? "selected" : "" %>>Part-time</option>
                <option value="Internship" <%= isEdit && "Internship".equals(editJob.getJobType()) ? "selected" : "" %>>Internship</option>
                <option value="Contract" <%= isEdit && "Contract".equals(editJob.getJobType()) ? "selected" : "" %>>Contract</option>
              </select>
            </div>

            <!-- Experience Level -->
            <div class="form-group">
              <label class="form-label" for="experienceLevel">Experience Level</label>
              <select id="experienceLevel" name="experienceLevel" class="form-control">
                <option value="Entry Level" <%= isEdit && "Entry Level".equals(editJob.getExperienceLevel()) ? "selected" : "" %>>Entry Level (0–2 yrs)</option>
                <option value="Mid Level" <%= isEdit && "Mid Level".equals(editJob.getExperienceLevel()) ? "selected" : "" %>>Mid Level (2–5 yrs)</option>
                <option value="Senior Level" <%= isEdit && "Senior Level".equals(editJob.getExperienceLevel()) ? "selected" : "" %>>Senior Level (5+ yrs)</option>
              </select>
            </div>

            <!-- Salary Range -->
            <div class="form-group">
              <label class="form-label" for="jobSalary">Salary Range</label>
              <input id="jobSalary" name="salary" class="form-control"
                     placeholder="e.g. 8–12 LPA"
                     value="<%= isEdit && editJob.getSalaryRange() != null ? editJob.getSalaryRange() : "" %>">
            </div>

            <!-- Application Deadline -->
            <div class="form-group">
              <label class="form-label" for="applicationDeadline">Application Deadline</label>
              <input type="date" id="applicationDeadline" name="applicationDeadline" class="form-control"
                     value="<%= isEdit && editJob.getApplicationDeadline() != null ? editJob.getApplicationDeadline() : "" %>">
            </div>

            <!-- Required Skills (full width) -->
            <div class="form-group full">
              <label class="form-label" for="jobSkills">Required Skills</label>
              <input id="jobSkills" name="skills" class="form-control"
                     placeholder="e.g. Java, Spring Boot, SQL, REST API"
                     value="<%= isEdit && editJob.getSkills() != null ? String.join(", ", editJob.getSkills()) : "" %>"
                     oninput="previewDomain(this.value)">
              <span class="skill-hint"><i class="fa-solid fa-circle-info" style="font-size:0.7rem;"></i> Separate with commas. Domain is auto-detected from these skills.</span>
              <!-- Domain Preview -->
              <div class="domain-preview" id="domainPreview">
                <i class="fa-solid fa-wand-magic-sparkles"></i>
                <span id="domainText">Domain will auto-detect from skills</span>
              </div>
            </div>

            <!-- Job Description -->
            <div class="form-group full">
              <label class="form-label" for="jobDescription">Job Description</label>
              <textarea id="jobDescription" name="description" class="form-control" rows="4"
                        placeholder="Describe the role, responsibilities, and what success looks like in this position…"><%= isEdit && editJob.getDescription() != null ? editJob.getDescription() : "" %></textarea>
            </div>

            <!-- Requirements -->
            <div class="form-group full">
              <label class="form-label" for="jobRequirements">Requirements</label>
              <textarea id="jobRequirements" name="requirements" class="form-control" rows="3"
                        placeholder="Education, certifications, specific qualifications…"><%= isEdit && editJob.getRequirements() != null ? editJob.getRequirements() : "" %></textarea>
            </div>

            <!-- Status -->
            <div class="form-group full">
              <label class="form-label" for="jobStatus">Posting Status</label>
              <select id="jobStatus" name="status" class="form-control">
                <option value="ACTIVE" <%= isEdit && "ACTIVE".equals(editJob.getStatus()) ? "selected" : "" %>>🟢 Active — visible to students</option>
                <option value="CLOSED" <%= isEdit && "CLOSED".equals(editJob.getStatus()) ? "selected" : "" %>>🔴 Closed — hidden from students</option>
              </select>
            </div>

          </div>

          <button class="btn-post" type="submit" id="jobSubmitBtn">
            <i class="fa-solid fa-<%= isEdit ? "floppy-disk" : "paper-plane" %>"></i>
            <%= isEdit ? "Update Job Posting" : "Post Job — Go Live" %>
          </button>
        </form>
      </div>

      <!-- ══════════════ RIGHT: LISTINGS ══════════════ -->
      <div class="postings-panel">
        <div class="postings-header">
          <h2>
            <i class="fa-solid fa-layer-group" style="color: var(--accent-cyan);"></i>
            Your Postings
          </h2>
          <span class="postings-count"><%= jobs != null ? jobs.size() : 0 %> job<%= (jobs != null && jobs.size() == 1) ? "" : "s" %></span>
        </div>

        <% if (jobs == null || jobs.isEmpty()) { %>
          <div class="empty-state">
            <i class="fa-solid fa-briefcase"></i>
            <p>No job postings yet.<br>Use the form to publish your first opening.</p>
          </div>
        <% } else { %>
          <% for (Job j : jobs) {
              boolean active = "ACTIVE".equals(j.getStatus());
              String initial = j.getCompany() != null ? j.getCompany().substring(0, Math.min(2, j.getCompany().length())).toUpperCase() : "CO";
              int colorHash = Math.abs(j.getCompany() != null ? j.getCompany().hashCode() : 0) % 4;
              String grad = colorHash == 1 ? "background: linear-gradient(135deg, #10b981, #06b6d4);" :
                            colorHash == 2 ? "background: linear-gradient(135deg, #ec4899, #f43f5e);" :
                            colorHash == 3 ? "background: linear-gradient(135deg, #f59e0b, #d946ef);" :
                                            "background: linear-gradient(135deg, #3b82f6, #8b5cf6);";
              String accentColor = active ? "#06b6d4" : "rgba(255,255,255,0.12)";
          %>
          <div class="job-entry">
            <div class="job-entry-accent" style="background: <%= accentColor %>; <%= active ? "box-shadow: 0 0 12px rgba(6,182,212,0.4);" : "" %>"></div>

            <div class="job-entry-top">
              <div class="job-entry-left">
                <div class="job-entry-avatar" style="<%= grad %>"><%= initial %></div>
                <div class="job-entry-info">
                  <span class="job-entry-title"><%= j.getTitle() %></span>
                  <div class="job-entry-meta">
                    <i class="fa-solid fa-building" style="font-size:0.7rem;"></i> <%= j.getCompany() %>
                    <% if (j.getLocation() != null && !j.getLocation().isEmpty()) { %>
                      <span style="color: rgba(255,255,255,0.15);">|</span>
                      <i class="fa-solid fa-location-dot" style="font-size:0.7rem;"></i> <%= j.getLocation() %>
                    <% } %>
                    <% if (j.getSalaryRange() != null && !j.getSalaryRange().isEmpty()) { %>
                      <span style="color: rgba(255,255,255,0.15);">|</span>
                      <i class="fa-solid fa-indian-rupee-sign" style="font-size:0.7rem;"></i> <%= j.getSalaryRange() %>
                    <% } %>
                  </div>
                </div>
              </div>
              <span class="<%= active ? "badge-active" : "badge-closed" %>">
                <%= active ? "ACTIVE" : "CLOSED" %>
              </span>
            </div>

            <div class="job-entry-badges">
              <% if (j.getDomain() != null && !j.getDomain().isEmpty()) { %>
                <span class="tag tag-domain" style="font-size:0.72rem;"><%= j.getDomain() %></span>
              <% } %>
              <% if (j.getJobType() != null) { %>
                <span class="tag" style="background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.1); font-size:0.72rem;"><i class="fa-solid fa-briefcase" style="font-size:0.65rem;"></i> <%= j.getJobType() %></span>
              <% } %>
              <% if (j.getExperienceLevel() != null) { %>
                <span class="tag" style="background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.1); font-size:0.72rem;"><i class="fa-solid fa-layer-group" style="font-size:0.65rem;"></i> <%= j.getExperienceLevel() %></span>
              <% } %>
              <% if (j.getApplicationDeadline() != null && !j.getApplicationDeadline().isEmpty()) { %>
                <span class="tag" style="background:rgba(251,191,36,0.08); border:1px solid rgba(251,191,36,0.25); color:#fbbf24; font-size:0.72rem;"><i class="fa-solid fa-calendar-xmark" style="font-size:0.65rem;"></i> Deadline: <%= j.getApplicationDeadline() %></span>
              <% } %>
            </div>

            <% if (j.getSkills() != null && !j.getSkills().isEmpty()) { %>
              <div style="margin-top: 0.85rem; display: flex; flex-wrap: wrap; gap: 0.35rem;">
                <% for (String sk : j.getSkills()) { %>
                  <span class="tag tag-match" style="font-size:0.72rem;"><%= sk %></span>
                <% } %>
              </div>
            <% } %>

            <div class="job-entry-actions">
              <a href="${pageContext.request.contextPath}/hr?action=jobs&edit=<%= j.getJobId() %>" class="btn btn-sm btn-outline">
                <i class="fa-solid fa-pen-to-square"></i> Edit
              </a>
              <form method="post" action="${pageContext.request.contextPath}/hr"
                    style="flex:1;"
                    onsubmit="return confirm('Delete this job posting?');">
                <input type="hidden" name="action" value="jobs">
                <input type="hidden" name="sub" value="delete">
                <input type="hidden" name="jobId" value="<%= j.getJobId() %>">
                <button class="btn btn-sm btn-r" type="submit" style="width:100%; justify-content:center;">
                  <i class="fa-solid fa-trash"></i> Delete
                </button>
              </form>
            </div>
          </div>
          <% } %>
        <% } %>
      </div>

    </div>
  </main>
</div>

<script>
// Auto domain detection preview
const domainMap = {
  'BACKEND':    { label: '⚙️  Backend Developer', color: '#3b82f6' },
  'FRONTEND':   { label: '🖥️  Frontend Developer', color: '#ec4899' },
  'FULL_STACK': { label: '🌐  Full Stack Developer', color: '#8b5cf6' },
  'NETWORKING': { label: '🌐  Network Engineer', color: '#06b6d4' },
  'DATA':       { label: '📊  Data Analyst / Scientist', color: '#f59e0b' },
  'DEVOPS':     { label: '🚀  DevOps Engineer', color: '#10b981' },
  'GENERAL':    { label: '💼  General / Other', color: '#94a3b8' },
};

function detectDomain(skills) {
  const s = skills.toLowerCase();
  if (s.includes('java') || s.includes('spring') || s.includes('node') || s.includes('backend')) return 'BACKEND';
  if (s.includes('react') || s.includes('javascript') || s.includes('frontend') || s.includes('html') || s.includes('css')) return 'FRONTEND';
  if ((s.includes('full') && s.includes('stack'))) return 'FULL_STACK';
  if (s.includes('ccna') || s.includes('network') || s.includes('cisco')) return 'NETWORKING';
  if (s.includes('python') || s.includes('sql') || s.includes('power bi') || s.includes('data')) return 'DATA';
  if (s.includes('aws') || s.includes('docker') || s.includes('devops') || s.includes('kubernetes')) return 'DEVOPS';
  return 'GENERAL';
}

function previewDomain(val) {
  const d = detectDomain(val);
  const info = domainMap[d];
  const el = document.getElementById('domainPreview');
  const txt = document.getElementById('domainText');
  txt.textContent = val.trim() ? 'Auto-detected: ' + info.label : 'Domain will auto-detect from skills';
  el.style.borderColor = 'rgba(' + hexToRgb(info.color) + ', 0.4)';
  el.style.background = 'rgba(' + hexToRgb(info.color) + ', 0.06)';
  el.style.color = info.color;
}

function hexToRgb(hex) {
  const r = parseInt(hex.slice(1,3),16);
  const g = parseInt(hex.slice(3,5),16);
  const b = parseInt(hex.slice(5,7),16);
  return r + ',' + g + ',' + b;
}

// Seed current value on edit
window.addEventListener('DOMContentLoaded', function() {
  const el = document.getElementById('jobSkills');
  if (el && el.value) previewDomain(el.value);
});
</script>
</body>
</html>

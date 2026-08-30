<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Candidate Discovery | CareerAssist HR</title>
  <jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
  <style>
    /* CSS additions for dynamic filters and Lovable UI design */
    .discovery-layout {
      display: grid;
      grid-template-columns: 280px 1fr;
      gap: 2rem;
      margin-top: 1.5rem;
    }

    @media (max-width: 992px) {
      .discovery-layout {
        grid-template-columns: 1fr;
      }
    }

    /* Glassmorphic Filter panel */
    .filter-panel {
      background: var(--bg-card);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border-radius: 16px;
      border: 1px solid var(--border-color);
      padding: 1.5rem;
      height: fit-content;
      position: sticky;
      top: 2rem;
    }

    .filter-section {
      margin-bottom: 1.5rem;
    }

    .filter-title {
      font-family: 'Outfit', sans-serif;
      font-size: 0.85rem;
      font-weight: 700;
      color: var(--text-primary);
      text-transform: uppercase;
      letter-spacing: 0.05em;
      margin-bottom: 0.75rem;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    /* Glow Cards for Candidates */
    .candidate-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(310px, 1fr));
      gap: 1.5rem;
    }

    .discovery-candidate-card {
      background: var(--bg-card);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border-radius: 16px;
      border: 1px solid var(--border-color);
      padding: 1.5rem;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      position: relative;
      overflow: hidden;
    }

    .discovery-candidate-card::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 2px;
      background: var(--grad-cyan-purple);
      opacity: 0.5;
    }

    .discovery-candidate-card:hover {
      transform: translateY(-3px);
      border-color: rgba(6, 182, 212, 0.4);
      box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.45), 0 0 20px rgba(6, 182, 212, 0.15);
    }

    .candidate-card-header {
      display: flex;
      align-items: flex-start;
      gap: 0.85rem;
      margin-bottom: 1rem;
    }

    .candidate-avatar {
      width: 46px;
      height: 46px;
      border-radius: 50%;
      background: var(--grad-cyan-purple);
      color: #fff;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 1.15rem;
      font-family: 'Outfit';
    }

    .candidate-meta-info {
      flex: 1;
      min-width: 0;
    }

    .candidate-name-title {
      font-family: 'Outfit', sans-serif;
      font-weight: 700;
      font-size: 1.1rem;
      color: var(--text-primary);
      margin-bottom: 0.15rem;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .candidate-role-predicted {
      font-size: 0.76rem;
      color: var(--accent-cyan);
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      display: block;
    }

    .candidate-upload-date {
      font-size: 0.68rem;
      color: var(--text-muted);
      margin-top: 0.15rem;
      display: block;
    }

    .score-badge-pills {
      display: flex;
      gap: 0.5rem;
      margin-bottom: 1.25rem;
      background: rgba(255, 255, 255, 0.02);
      border: 1px solid var(--border-color);
      border-radius: 10px;
      padding: 0.65rem;
    }

    .score-badge-pill {
      flex: 1;
      text-align: center;
      display: flex;
      flex-direction: column;
      border-right: 1px solid var(--border-color);
    }

    .score-badge-pill:last-child {
      border-right: none;
    }

    .score-badge-val {
      font-family: 'Outfit', sans-serif;
      font-size: 1.1rem;
      font-weight: 800;
      line-height: 1.2;
    }

    .score-badge-lbl {
      font-size: 0.58rem;
      color: var(--text-muted);
      text-transform: uppercase;
      font-weight: 700;
      margin-top: 0.15rem;
    }

    .skills-badges-wrap {
      display: flex;
      flex-wrap: wrap;
      gap: 0.4rem;
      margin-bottom: 1.25rem;
      min-height: 52px;
      align-content: flex-start;
    }

    .card-footer-actions {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 0.5rem;
      border-top: 1px solid var(--border-color);
      padding-top: 1rem;
    }

    .btn-action-discovery {
      background: rgba(255, 255, 255, 0.02);
      border: 1px solid var(--border-color);
      color: var(--text-secondary);
      border-radius: 8px;
      padding: 0.45rem;
      font-size: 0.72rem;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.35rem;
      transition: all 0.2s ease;
    }

    .btn-action-discovery:hover {
      border-color: var(--accent-cyan);
      color: var(--accent-cyan);
      background: rgba(6, 182, 212, 0.05);
    }

    .btn-action-discovery.shortlist:hover {
      border-color: var(--accent-green);
      color: var(--accent-green);
      background: rgba(16, 185, 129, 0.05);
    }
  </style>
</head>
<body>
<div class="wrap">
  <jsp:include page="/WEB-INF/jsp/hr-nav.jsp"><jsp:param name="action" value="talent-pool"/></jsp:include>

  <main class="main">
    <%
      String initialRole = request.getParameter("role");
      if (initialRole == null) initialRole = "";

      List<User> students = (List<User>) request.getAttribute("list");
      Map<Integer,Integer> atsMap = (Map<Integer,Integer>) request.getAttribute("atsMap");
      Map<Integer,List<String>> skillMap = (Map<Integer,List<String>>) request.getAttribute("skillMap");
      Map<Integer,Double> gapMap = (Map<Integer,Double>) request.getAttribute("gapMap");
      Map<Integer,String> roleMap = (Map<Integer,String>) request.getAttribute("roleMap");

      // Extract unique dynamic roles from candidate skills in database to populate filters
      Set<String> uniqueRoles = new LinkedHashSet<>();
      if (roleMap != null) {
        for (String r : roleMap.values()) {
          if (r != null && !r.equals("Uncategorized")) {
            uniqueRoles.add(r);
          }
        }
      }
    %>

    <div class="hr-topbar">
      <div class="hr-topbar-left">
        <a href="${pageContext.request.contextPath}/hr?action=talent-pool" style="display: inline-flex; align-items: center; gap: 0.35rem; font-size: 0.8rem; font-weight: 700; color: var(--accent-cyan); text-transform: uppercase; margin-bottom: 0.5rem;">
          <i class="fa-solid fa-arrow-left-long"></i> Back to Talent Pool
        </a>
        <h1 class="hr-page-title">Candidate <span class="header-accent-grad">Discovery</span></h1>
        <p class="hr-page-sub">Dynamic ranking and matchmaking system for database resumes.</p>
      </div>
    </div>

    <div class="discovery-layout">
      <!-- LEFT: FILTERS -->
      <aside class="filter-panel filter-panel-premium glass-panel-premium">
        <div class="filter-section">
          <span class="filter-title"><i class="fa-solid fa-magnifying-glass"></i> Search Candidates</span>
          <input type="text" id="discovery-search" placeholder="Name, skill, or role…" style="margin-bottom: 0;" autocomplete="off">
        </div>

        <div class="filter-section">
          <span class="filter-title"><i class="fa-solid fa-user-tag"></i> Filter by Role</span>
          <select id="discovery-role-filter">
            <option value="">All Roles</option>
            <% for (String r : uniqueRoles) { %>
              <option value="<%= r %>" <%= r.equalsIgnoreCase(initialRole) ? "selected" : "" %>><%= r %></option>
            <% } %>
          </select>
        </div>

        <div class="filter-section">
          <span class="filter-title"><i class="fa-solid fa-gauge-high"></i> Min ATS Score</span>
          <div style="display: flex; align-items: center; gap: 1rem;">
            <input type="range" id="discovery-ats-filter" class="premium-slider" min="0" max="100" value="0" style="flex: 1; margin: 0; cursor: pointer;">
            <span id="ats-val-lbl" style="font-family: 'Outfit'; font-weight: 700; font-size: 1rem; min-width: 28px; color: var(--accent-cyan);">0</span>
          </div>
        </div>

        <div class="filter-section">
          <span class="filter-title"><i class="fa-solid fa-sort"></i> Sort Ranking By</span>
          <select id="discovery-sort-by">
            <option value="ats">ATS Score (Highest)</option>
            <option value="name">Name (A-Z)</option>
          </select>
        </div>
      </aside>

      <!-- RIGHT: CANDIDATE CARDS -->
      <section>
        <div class="candidate-grid" id="candidate-cards-container">
          <%
            if (students == null || students.isEmpty()) {
          %>
            <div class="hr-full-empty" style="grid-column: 1 / -1; padding: 4rem 2rem;">
              <i class="fa-solid fa-user-slash" style="font-size: 2.5rem; color: var(--text-muted); margin-bottom: 1rem;"></i>
              <p style="color: var(--text-muted);">No candidates exist in the database.</p>
            </div>
          <%
            } else {
              com.careerassist.dao.CareerDAO dynamicDao = new com.careerassist.service.CareerService().getDao();
              for (User s : students) {
                List<String> skills = skillMap != null ? skillMap.get(s.getUserId()) : null;
                if (skills == null) skills = new ArrayList<>();
                Integer atsScore = atsMap != null ? atsMap.get(s.getUserId()) : null;
                int scoreVal = atsScore != null ? atsScore : 0;
                Double matchScore = gapMap != null ? gapMap.get(s.getUserId()) : null;
                double matchVal = matchScore != null ? matchScore : 0.0;
                
                // Fetch dynamic upload date
                String uploadDate = "No resume uploaded";
                try {
                  List<Resume> resList = dynamicDao.listResumes(s.getUserId());
                  if (resList != null && !resList.isEmpty()) {
                    for (Resume r : resList) {
                      if (r.isLatest()) {
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                        uploadDate = "Uploaded: " + sdf.format(r.getUploadedAt());
                        break;
                      }
                    }
                  }
                } catch(Exception e) {}

                // Predict dynamic role from skill gap target title
                String predictedRole = roleMap != null && roleMap.containsKey(s.getUserId()) ? roleMap.get(s.getUserId()) : "Uncategorized";
                String skillString = "";
                if (!skills.isEmpty()) {
                  skillString = String.join(", ", skills);
                }

                String initials = "";
                if (s.getFullName() != null && s.getFullName().length() > 0) {
                  String[] parts = s.getFullName().split(" ");
                  if (parts.length > 1) {
                    initials = parts[0].substring(0,1).toUpperCase() + parts[1].substring(0,1).toUpperCase();
                  } else {
                    initials = s.getFullName().substring(0, Math.min(2, s.getFullName().length())).toUpperCase();
                  }
                } else {
                  initials = "C";
                }
          %>
            <div class="discovery-candidate-card glass-panel-premium"
                 data-name="<%= s.getFullName().toLowerCase() %>"
                 data-role="<%= predictedRole %>"
                 data-ats="<%= scoreVal %>"
                 data-resume="<%= scoreVal %>"
                 data-skills="<%= skillString.toLowerCase() %>">
              
              <div>
                <div class="candidate-card-header">
                  <div class="candidate-avatar"><%= initials %></div>
                  <div class="candidate-meta-info">
                    <span class="candidate-name-title"><%= s.getFullName() %></span>
                    <span class="candidate-role-predicted"><%= predictedRole %></span>
                    <span class="candidate-upload-date"><i class="fa-solid fa-envelope"></i> <%= s.getEmail() %></span>
                    <span class="candidate-upload-date"><%= uploadDate %></span>
                  </div>
                </div>

                <div class="score-badge-pills">
                  <div class="score-badge-pill">
                    <span class="score-badge-val" style="color: var(--accent-cyan);"><%= scoreVal > 0 ? scoreVal : "—" %></span>
                    <span class="score-badge-lbl">ATS Score</span>
                  </div>
                </div>

                <div class="skills-badges-wrap">
                  <%
                    if (skills.isEmpty()) {
                  %>
                    <span style="color: var(--text-muted); font-size: 0.72rem;">No extracted skills</span>
                  <%
                    } else {
                      int shown = 0;
                      for (String sk : skills) {
                        if (shown >= 5) break;
                  %>
                    <span class="tag tag-skill"><%= sk %></span>
                  <%
                        shown++;
                      }
                      if (skills.size() > 5) {
                  %>
                    <span class="tag" style="opacity: 0.6;">+<%= skills.size() - 5 %></span>
                  <%
                      }
                    }
                  %>
                </div>
              </div>

              <div class="card-footer-actions">
                <button type="button" class="btn-action-discovery" onclick="window.open('${pageContext.request.contextPath}/hr/viewResume?userId=<%= s.getUserId() %>', '_blank')">
                  <i class="fa-solid fa-file-invoice"></i> View Resume
                </button>
                <button type="button" class="btn-action-discovery" onclick="window.location.href='mailto:<%= s.getEmail() %>'">
                  <i class="fa-solid fa-paper-plane"></i> Send Email
                </button>
                <button type="button" class="btn-action-discovery shortlist" style="grid-column: 1 / -1;" onclick="alert('<%= s.getFullName() %> has been shortlisted successfully!')">
                  <i class="fa-solid fa-square-check"></i> Shortlist Candidate
                </button>
              </div>

            </div>
          <%
              }
            }
          %>
        </div>

        <div class="hr-full-empty" id="no-candidates-matched" style="display: none; padding: 5rem 2rem; background: var(--bg-card); border-radius: 16px; border: 1px solid var(--border-color); text-align: center; margin-top: 1.5rem;">
          <i class="fa-solid fa-magnifying-glass" style="font-size: 3rem; color: var(--text-muted); margin-bottom: 1rem;"></i>
          <h3>No matching candidates found</h3>
          <p style="color: var(--text-muted); margin-top: 0.25rem;">Try adjusting your search criteria, filters, or minimum ATS score slider.</p>
        </div>
      </section>
    </div>

  </main>
</div>

<!-- CLIENT FILTERING & SORTING ENGINE (LOVABLE-STYLE INSTANT INTERACTION) -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('discovery-search');
    const roleFilter = document.getElementById('discovery-role-filter');
    const atsFilter = document.getElementById('discovery-ats-filter');
    const atsValLbl = document.getElementById('ats-val-lbl');
    const sortBy = document.getElementById('discovery-sort-by');
    const cardsContainer = document.getElementById('candidate-cards-container');
    const noCandidatesMatched = document.getElementById('no-candidates-matched');

    function filterAndSort() {
      const searchVal = searchInput.value.toLowerCase().trim();
      const roleVal = roleFilter.value;
      const minAts = parseInt(atsFilter.value);
      atsValLbl.textContent = minAts;

      const cards = Array.from(cardsContainer.getElementsByClassName('discovery-candidate-card'));
      let visibleCount = 0;

      cards.forEach(card => {
        const name = card.getAttribute('data-name');
        const role = card.getAttribute('data-role');
        const ats = parseInt(card.getAttribute('data-ats'));
        const skills = card.getAttribute('data-skills');

        // Check if matches Search Query
        const matchesSearch = name.includes(searchVal) || skills.includes(searchVal) || role.toLowerCase().includes(searchVal);
        // Check if matches Role Filter
        const matchesRole = !roleVal || role.toLowerCase() === roleVal.toLowerCase();
        // Check if matches ATS score
        const matchesAts = ats >= minAts;

        if (matchesSearch && matchesRole && matchesAts) {
          card.style.display = 'flex';
          visibleCount++;
        } else {
          card.style.display = 'none';
        }
      });

      // Handle empty state visibility
      if (visibleCount === 0 && cards.length > 0) {
        noCandidatesMatched.style.display = 'block';
      } else {
        noCandidatesMatched.style.display = 'none';
      }

      // Sort visible cards
      const criteria = sortBy.value;
      const sortedCards = cards.filter(c => c.style.display !== 'none').sort((a, b) => {
        if (criteria === 'ats' || criteria === 'resume') {
          const atsA = parseInt(a.getAttribute('data-ats'));
          const atsB = parseInt(b.getAttribute('data-ats'));
          return atsB - atsA; // Descending
        } else if (criteria === 'name') {
          const nameA = a.getAttribute('data-name');
          const nameB = b.getAttribute('data-name');
          return nameA.localeCompare(nameB); // Ascending
        }
        return 0;
      });

      // Re-append sorted cards to container
      sortedCards.forEach(card => cardsContainer.appendChild(card));
    }

    // Attach listeners
    searchInput.addEventListener('input', filterAndSort);
    roleFilter.addEventListener('change', filterAndSort);
    atsFilter.addEventListener('input', filterAndSort);
    sortBy.addEventListener('change', filterAndSort);

    // Initial load run
    filterAndSort();
  });
</script>
</body>
</html>

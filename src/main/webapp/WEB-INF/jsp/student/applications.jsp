<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<%
  List<Application> apps = (List<Application>) request.getAttribute("apps");
  String[] columns = {"APPLIED", "INTERVIEW", "REJECTED", "SELECTED"};
  Map<String, List<Application>> byStatus = new LinkedHashMap<>();
  for (String c : columns) byStatus.put(c, new ArrayList<>());
  if (apps != null) {
    for (Application a : apps) {
      String st = a.getStatus() != null ? a.getStatus().toUpperCase() : "APPLIED";
      if ("PENDING".equals(st)) st = "APPLIED";
      if ("ACCEPTED".equals(st) || "SELECTED".equals(st)) st = "SELECTED";
      if ("SHORTLISTED".equals(st)) st = "INTERVIEW";
      if (!byStatus.containsKey(st)) st = "APPLIED";
      byStatus.get(st).add(a);
    }
  }
%>
<!DOCTYPE html>
<html>
<head>
<title>Apply Tracker</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
</head>
<body>
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="applications"/></jsp:include>
<main class="main">
  <h1>Apply Tracker</h1>
  <p class="dashboard-sub">Kanban board — drag cards to update status (Applied → Interview → Selected / Rejected).</p>

  <% if (session.getAttribute("msg") != null) { %>
  <div class="alert ok"><%= session.getAttribute("msg") %><% session.removeAttribute("msg"); %></div>
  <% } %>

  <div class="kanban-board">
    <% for (String col : columns) {
         String colClass = col.toLowerCase();
         List<Application> colApps = byStatus.get(col); %>
    <div class="kanban-column" data-status="<%= col %>">
      <div class="kanban-col-head kanban-<%= colClass %>">
        <span><%= col %></span>
        <span class="kanban-count"><%= colApps.size() %></span>
      </div>
      <div class="kanban-cards" data-drop="<%= col %>">
        <% if (colApps.isEmpty()) { %>
        <p class="kanban-empty muted">Drop here</p>
        <% } else {
             for (Application a : colApps) { %>
        <div class="kanban-card" draggable="true" data-app-id="<%= a.getApplicationId() %>">
          <strong><%= a.getJobTitle() %></strong>
          <span class="kanban-company"><%= a.getCompany() %></span>
          <span class="tag"><%= a.getJobSource() %></span>
          <span class="kanban-date muted"><%= a.getAppliedAt() != null ? a.getAppliedAt().replace('T',' ').substring(0, Math.min(16, a.getAppliedAt().length())) : "" %></span>
        </div>
        <%   }
           } %>
      </div>
    </div>
    <% } %>
  </div>

  <p class="muted" style="margin-top:1rem;font-size:.85rem">
    Track where you applied from the <a href="${pageContext.request.contextPath}/student?action=jobfeed">Live Job Feed</a>.
    Indeed listings use a licensed demo feed (no scraping of indeed.com).
  </p>
</main>
</div>

<script>
const ctx = '${pageContext.request.contextPath}';
let draggedId = null;

document.querySelectorAll('.kanban-card').forEach(card => {
  card.addEventListener('dragstart', e => {
    draggedId = card.dataset.appId;
    e.dataTransfer.effectAllowed = 'move';
    card.classList.add('dragging');
  });
  card.addEventListener('dragend', () => card.classList.remove('dragging'));
});

document.querySelectorAll('.kanban-cards').forEach(zone => {
  zone.addEventListener('dragover', e => { e.preventDefault(); zone.classList.add('drag-over'); });
  zone.addEventListener('dragleave', () => zone.classList.remove('drag-over'));
  zone.addEventListener('drop', e => {
    e.preventDefault();
    zone.classList.remove('drag-over');
    const status = zone.dataset.drop;
    if (!draggedId || !status) return;
    const fd = new FormData();
    fd.append('action', 'updateApp');
    fd.append('appId', draggedId);
    fd.append('status', status);
    fd.append('ajax', '1');
    fetch(ctx + '/student', { method: 'POST', body: fd })
      .then(r => r.json())
      .then(d => { if (d.ok) location.reload(); else alert(d.error || 'Update failed'); })
      .catch(() => alert('Could not update status'));
  });
});
</script>
<jsp:include page="/WEB-INF/jsp/floating-chat.jsp"/>
</body>
</html>

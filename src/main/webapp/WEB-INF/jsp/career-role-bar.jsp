<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*,com.careerassist.service.CareerContextService" %>
<%
  CareerContext ctx = (CareerContext) request.getAttribute("careerContext");
  Map<String, String> roleOptions = (Map<String, String>) request.getAttribute("roleOptions");
  String selected = ctx != null ? CareerContextService.selectedOptionValue(ctx) : "";
  // Resolve display name for the selected role
  String roleName = null;
  if (ctx != null && roleOptions != null && !selected.isEmpty()) {
    roleName = roleOptions.get(selected);
  }
  if (roleName == null && ctx != null && ctx.getTargetTitle() != null) {
    roleName = ctx.getTargetTitle();
  }
%>
<div class="card career-role-bar">
  <!-- Hidden form still submits if role needs to be set programmatically -->
  <form id="roleForm" method="post" action="${pageContext.request.contextPath}/student" style="display:none;">
    <input type="hidden" name="action" value="setJobRole">
    <input type="hidden" name="roleOption" id="roleOption" value="<%= selected %>">
  </form>
  <div class="role-form-inner" style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
    <div>
      <label><strong>Target job role</strong></label>
      <% if (roleName != null && !roleName.isEmpty()) { %>
      <p style="font-size: 1.05rem; font-weight: 700; color: var(--text-primary); margin-top: 0.25rem;"><%= roleName %></p>
      <% } else { %>
      <p style="font-size: 0.88rem; color: var(--text-muted); margin-top: 0.25rem;">No role selected yet</p>
      <% } %>
    </div>
    <% if (ctx != null) { %>
    <div class="role-context-summary">
      <span class="tag tag-domain"><%= ctx.getRoleDomain() != null ? ctx.getRoleDomain().replace('_', ' ') : "Role" %></span>
      <span class="tag tag-match"><%= String.format("%.0f", ctx.getReadinessPct()) %>% ready</span>
    </div>
    <% } %>
  </div>
</div>

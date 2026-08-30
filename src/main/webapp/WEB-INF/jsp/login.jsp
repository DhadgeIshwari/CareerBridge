<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String role = (String) request.getAttribute("role");
  if (role == null) role = request.getParameter("role");
  if (role == null || (!"STUDENT".equals(role) && !"HR".equals(role))) role = "STUDENT";
  boolean isHr = "HR".equals(role);
  String ctx = request.getContextPath();

  String error = (String) request.getAttribute("error");
  if (error == null) error = (String) session.getAttribute("authError");
  if (error != null) session.removeAttribute("authError");

  String msg = (String) request.getAttribute("msg");
  if (msg == null) msg = (String) session.getAttribute("authMsg");
  if (msg != null) session.removeAttribute("authMsg");

  String emailVal = request.getAttribute("email") != null ? (String) request.getAttribute("email")
          : (request.getParameter("email") != null ? request.getParameter("email") : "");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= isHr ? "HR Login" : "Student Login" %> | NexusAI</title>
<jsp:include page="/WEB-INF/jsp/auth-head.jsp"/>

<style>
/* ===== GLOBAL BACKGROUND ===== */
body.auth-page {
  margin: 0;
  font-family: "Inter", sans-serif;
  background: radial-gradient(circle at top, #0b1220, #05070f 60%);
  color: white;
  overflow-x: hidden;
}

/* animated glow blobs */
.bg-glow {
  position: fixed;
  width: 600px;
  height: 600px;
  border-radius: 50%;
  filter: blur(120px);
  opacity: 0.25;
  animation: float 8s ease-in-out infinite;
}

.glow1 { background: #7c3aed; top: -200px; left: -200px; }
.glow2 { background: #06b6d4; bottom: -200px; right: -200px; }

@keyframes float {
  0%,100% { transform: translateY(0px); }
  50% { transform: translateY(40px); }
}

/* ===== LAYOUT ===== */
.auth-container {
  display: flex;
  min-height: 100vh;
}

/* LEFT PANEL */
.auth-left {
  flex: 1.2;
  padding: 3rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.brand-title {
  font-size: 2.4rem;
  font-weight: 800;
  background: linear-gradient(90deg,#06b6d4,#7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.subtitle {
  color: #a1a1aa;
  margin-top: 1rem;
  max-width: 420px;
}

/* floating cards */
.mock-card {
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.1);
  padding: 1rem;
  border-radius: 14px;
  backdrop-filter: blur(12px);
  margin-top: 1.5rem;
  width: 280px;
  transition: 0.3s;
}
.mock-card:hover { transform: translateY(-5px); }

/* RIGHT PANEL */
.auth-right {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* GLASS CARD */
.glass-card {
  width: 380px;
  padding: 2rem;
  border-radius: 18px;
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.12);
  backdrop-filter: blur(18px);
  box-shadow: 0 10px 40px rgba(0,0,0,0.4);
}

/* inputs */
input {
  width: 100%;
  padding: 0.75rem;
  margin-top: 0.4rem;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(0,0,0,0.3);
  color: white;
}

/* button */
.btn-primary {
  width: 100%;
  padding: 0.8rem;
  margin-top: 1rem;
  border: none;
  border-radius: 10px;
  background: linear-gradient(90deg,#06b6d4,#7c3aed);
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: 0.3s;
}
.btn-primary:hover {
  transform: translateY(-2px);
}

/* role switch */
.role-switch {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.role-switch a {
  flex: 1;
  text-align: center;
  padding: 0.5rem;
  border-radius: 8px;
  text-decoration: none;
  font-size: 0.85rem;
  color: #aaa;
  background: rgba(255,255,255,0.05);
}
.role-switch a.active {
  background: rgba(124,58,237,0.3);
  color: white;
}

/* responsive */
@media(max-width:900px){
  .auth-container { flex-direction: column; }
  .auth-left { display:none; }
}
</style>
</head>

<body class="auth-page">

<div class="bg-glow glow1"></div>
<div class="bg-glow glow2"></div>

<div class="auth-container">

<!-- LEFT SIDE (AI DASHBOARD PREVIEW) -->
<div class="auth-left">
  <div class="brand-title">NexusAI Career OS</div>
  <div class="subtitle">
    A futuristic AI-powered platform for skill matching, job intelligence, and career roadmaps.
  </div>

  <div class="mock-card">
    ⚡ AI Skill Engine<br>
    <small style="color:#aaa;">Real-time resume intelligence & parsing</small>
  </div>

  <div class="mock-card">
    📊 Job Match Analytics<br>
    <small style="color:#aaa;">AI-driven 92% match prediction system</small>
  </div>

  <div class="mock-card">
    🚀 Career Roadmap<br>
    <small style="color:#aaa;">Personalized learning path generator</small>
  </div>
</div>

<!-- RIGHT SIDE (LOGIN) -->
<div class="auth-right">

  <div class="glass-card">

    <!-- ROLE SWITCH -->
    <div class="role-switch">
      <a class="<%= !isHr ? "active" : "" %>" href="<%= ctx %>/auth?role=STUDENT">Student</a>
      <a class="<%= isHr ? "active" : "" %>" href="<%= ctx %>/auth?role=HR">HR</a>
    </div>

    <h2 style="margin-bottom:0.5rem;">
      <%= isHr ? "HR Portal Login" : "Student Portal Login" %>
    </h2>

    <p style="color:#aaa;font-size:0.8rem;margin-bottom:1rem;">
      Enter your credentials to continue
    </p>

    <% if (error != null) { %>
      <div style="color:#ff6b6b;font-size:0.8rem;margin-bottom:0.5rem;"><%= error %></div>
    <% } %>

    <% if (msg != null) { %>
      <div style="color:#22c55e;font-size:0.8rem;margin-bottom:0.5rem;"><%= msg %></div>
    <% } %>

    <form method="post" action="<%= ctx %>/auth">
      <input type="hidden" name="action" value="login">
      <input type="hidden" name="role" value="<%= role %>">

      <label>Email</label>
      <input type="email" name="email" value="<%= emailVal %>" required>

      <label>Password</label>
      <input type="password" name="password" required>

      <button class="btn-primary">Sign In</button>
    </form>

    <p style="text-align:center;margin-top:1rem;font-size:0.8rem;color:#aaa;">
      New user? <a href="<%= ctx %>/auth?action=signup&role=<%= role %>" style="color:#7c3aed;">Create account</a>
    </p>

  </div>

</div>

</div>

</body>
</html>
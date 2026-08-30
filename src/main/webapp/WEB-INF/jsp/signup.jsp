<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String role = (String) request.getAttribute("role");
  if (role == null) role = request.getParameter("role");
  if (role == null || (!"STUDENT".equals(role) && !"HR".equals(role))) role = "STUDENT";
  boolean isHr = "HR".equals(role);
  String ctx = request.getContextPath();

  String error = (String) request.getAttribute("error");
%>

<%
  String loginUrl = ctx + "/auth?role=" + role + "&action=login";
  String signupUrlStudent = ctx + "/auth?action=signup&role=STUDENT";
  String signupUrlHr = ctx + "/auth?action=signup&role=HR";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= isHr ? "HR Sign Up" : "Student Sign Up" %> | NexusAI</title>
<jsp:include page="/WEB-INF/jsp/auth-head.jsp"/>

<style>
body.auth-page {
  margin: 0;
  font-family: Inter, sans-serif;
  background: radial-gradient(circle at top, #0b1220, #05070f 70%);
  color: white;
}

/* glowing background */
.glow {
  position: fixed;
  width: 600px;
  height: 600px;
  border-radius: 50%;
  filter: blur(140px);
  opacity: 0.22;
}
.glow1 { background: #7c3aed; top: -200px; left: -200px; }
.glow2 { background: #06b6d4; bottom: -200px; right: -200px; }

.auth-container {
  display: flex;
  min-height: 100vh;
}

/* LEFT SIDE */
.auth-left {
  flex: 1.2;
  padding: 3rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.brand {
  font-size: 2.6rem;
  font-weight: 800;
  background: linear-gradient(90deg,#06b6d4,#7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.subtitle {
  color: #aaa;
  margin-top: 1rem;
  max-width: 450px;
}

.card-mini {
  margin-top: 1rem;
  padding: 1rem;
  width: 280px;
  border-radius: 14px;
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.1);
  backdrop-filter: blur(14px);
  transition: 0.3s;
}
.card-mini:hover {
  transform: translateY(-5px);
}

/* RIGHT SIDE */
.auth-right {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* GLASS FORM */
.glass {
  width: 420px;
  padding: 2rem;
  border-radius: 18px;
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.12);
  backdrop-filter: blur(20px);
  box-shadow: 0 20px 60px rgba(0,0,0,0.5);
}

input {
  width: 100%;
  padding: 0.75rem;
  margin-top: 0.4rem;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(0,0,0,0.25);
  color: white;
}

button {
  width: 100%;
  padding: 0.85rem;
  margin-top: 1rem;
  border: none;
  border-radius: 12px;
  background: linear-gradient(90deg,#06b6d4,#7c3aed);
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: 0.3s;
}

button:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(124,58,237,0.3);
}

/* ROLE SWITCH */
.switch {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.switch a {
  flex: 1;
  text-align: center;
  padding: 0.55rem;
  border-radius: 10px;
  text-decoration: none;
  font-size: 0.85rem;
  color: #aaa;
  background: rgba(255,255,255,0.04);
}

.switch a.active {
  background: rgba(124,58,237,0.35);
  color: white;
}

@media(max-width:900px){
  .auth-container { flex-direction: column; }
  .auth-left { display:none; }
}
</style>
</head>

<body class="auth-page">

<div class="glow glow1"></div>
<div class="glow glow2"></div>

<div class="auth-container">

<!-- LEFT PANEL -->
<div class="auth-left">

  <div class="brand">AI Career Engine</div>

  <div class="subtitle">
    Build your intelligent career profile. Get matched with companies using AI-driven skill analysis.
  </div>

  <div class="card-mini">⚡ Resume AI Parser</div>
  <div class="card-mini">📊 Skill Gap Analyzer</div>
  <div class="card-mini">🚀 Job Matching Engine</div>

</div>

<!-- RIGHT PANEL -->
<div class="auth-right">

  <div class="glass">

    <!-- ROLE SWITCH -->
    <div class="switch">
      <a class="<%= !isHr ? "active" : "" %>" href="<%= signupUrlStudent %>">Student</a>
      <a class="<%= isHr ? "active" : "" %>" href="<%= signupUrlHr %>">HR</a>
    </div>

    <h2>Create Account</h2>
    <p style="color:#aaa;font-size:0.8rem;">Join NexusAI ecosystem</p>

    <% if (error != null) { %>
      <p style="color:#ff6b6b;font-size:0.8rem;"><%= error %></p>
    <% } %>

    <form method="post" action="<%= ctx %>/auth" id="signupForm">

      <input type="hidden" name="action" value="signup">
      <input type="hidden" name="role" value="<%= role %>">

      <label>Full Name</label>
      <input type="text" name="fullName" required>

      <label>Email</label>
      <input type="email" name="email" id="email" required>
      <div id="emailError" style="color: #ff6b6b; font-size: 0.75rem; margin-top: 0.2rem; display: none;"></div>

      <label>Password</label>
      <input type="password" name="password" id="password" required>
      <div id="passwordError" style="color: #ff6b6b; font-size: 0.75rem; margin-top: 0.2rem; display: none;"></div>

      <label>Confirm Password</label>
      <input type="password" name="confirmPassword" id="confirmPassword" required>
      <div id="confirmError" style="color: #ff6b6b; font-size: 0.75rem; margin-top: 0.2rem; display: none;"></div>

      <button type="submit">Create Account</button>

    </form>

    <script>
      document.getElementById('signupForm').addEventListener('submit', function(e) {
        let valid = true;

        const email = document.getElementById('email').value;
        const emailRegex = /^[a-zA-Z0-9_+&*-]+(?:\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$/;
        const emailError = document.getElementById('emailError');
        if (!emailRegex.test(email)) {
          emailError.textContent = "Please enter a valid email address";
          emailError.style.display = 'block';
          valid = false;
        } else {
          emailError.style.display = 'none';
        }

        const password = document.getElementById('password').value;
        const passRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        const passwordError = document.getElementById('passwordError');
        if (!passRegex.test(password)) {
          passwordError.textContent = "Password must be at least 8 characters, with 1 uppercase, 1 lowercase, 1 number, and 1 special character.";
          passwordError.style.display = 'block';
          valid = false;
        } else {
          passwordError.style.display = 'none';
        }

        const confirmPassword = document.getElementById('confirmPassword').value;
        const confirmError = document.getElementById('confirmError');
        if (password !== confirmPassword) {
          confirmError.textContent = "Passwords do not match.";
          confirmError.style.display = 'block';
          valid = false;
        } else {
          confirmError.style.display = 'none';
        }

        if (!valid) {
          e.preventDefault();
        }
      });
      
      // Real-time validation
      document.getElementById('email').addEventListener('input', function() {
        const emailRegex = /^[a-zA-Z0-9_+&*-]+(?:\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$/;
        const emailError = document.getElementById('emailError');
        if (this.value && !emailRegex.test(this.value)) {
          emailError.textContent = "Please enter a valid email address";
          emailError.style.display = 'block';
        } else {
          emailError.style.display = 'none';
        }
      });

      document.getElementById('password').addEventListener('input', function() {
        const passRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        const passwordError = document.getElementById('passwordError');
        if (this.value && !passRegex.test(this.value)) {
          passwordError.textContent = "Password must be at least 8 characters, with 1 uppercase, 1 lowercase, 1 number, and 1 special character.";
          passwordError.style.display = 'block';
        } else {
          passwordError.style.display = 'none';
        }
      });
    </script>

    <p style="text-align:center;margin-top:1rem;font-size:0.8rem;color:#aaa;">
      Already have account?
      <a href="<%= loginUrl %>" style="color:#7c3aed;">Login</a>
    </p>

  </div>

</div>

</div>

</body>
</html>
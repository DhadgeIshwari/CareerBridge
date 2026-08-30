<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String error = (String) request.getAttribute("error");
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>OTP Verification | HR Portal</title>
<jsp:include page="/WEB-INF/jsp/auth-head.jsp"/>

<style>
body.auth-page {
  margin: 0;
  font-family: Inter, sans-serif;
  background: radial-gradient(circle at top, #0b1220, #05070f 70%);
  color: white;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
}

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

.glass {
  width: 380px;
  padding: 2.5rem;
  border-radius: 18px;
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.12);
  backdrop-filter: blur(20px);
  box-shadow: 0 20px 60px rgba(0,0,0,0.5);
  text-align: center;
  z-index: 10;
}

.otp-icon {
  font-size: 3rem;
  color: #06b6d4;
  margin-bottom: 1rem;
}

h2 {
  margin: 0 0 0.5rem 0;
  font-weight: 700;
}

p.subtext {
  color: #aaa;
  font-size: 0.85rem;
  margin-bottom: 1.5rem;
}

input {
  width: 100%;
  padding: 0.85rem;
  margin-top: 0.4rem;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(0,0,0,0.25);
  color: white;
  text-align: center;
  font-size: 1.5rem;
  letter-spacing: 0.5rem;
  font-weight: bold;
}

input:focus {
  outline: none;
  border-color: #06b6d4;
  box-shadow: 0 0 10px rgba(6, 182, 212, 0.2);
}

button {
  width: 100%;
  padding: 0.85rem;
  margin-top: 1.5rem;
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

.error-msg {
  color: #ff6b6b;
  font-size: 0.85rem;
  margin-bottom: 1rem;
  background: rgba(255, 107, 107, 0.1);
  padding: 0.5rem;
  border-radius: 6px;
  border: 1px solid rgba(255, 107, 107, 0.2);
}
</style>
</head>

<body class="auth-page">

<div class="glow glow1"></div>
<div class="glow glow2"></div>

<div class="glass">
  <div class="otp-icon"><i class="fa-solid fa-shield-halved"></i></div>
  <h2>Verify Your Email</h2>
  <p class="subtext">We've sent a 6-digit verification code to your email. Enter it below to complete registration.</p>

  <% if (error != null) { %>
    <div class="error-msg"><%= error %></div>
  <% } %>

  <form method="post" action="<%= ctx %>/auth">
    <input type="hidden" name="action" value="verifyOtp">
    <input type="text" name="otp" id="otp" maxlength="6" pattern="\d{6}" title="Please enter a 6-digit code" required autocomplete="off" placeholder="------">
    <button type="submit">Verify & Create Account</button>
  </form>
  
  <p style="margin-top: 1.5rem; font-size: 0.8rem; color: #aaa;">
    <a href="<%= ctx %>/auth?action=signup&role=HR" style="color: #7c3aed; text-decoration: none;">Cancel and go back</a>
  </p>
</div>

<script>
  // Simple validation to only allow numbers
  document.getElementById('otp').addEventListener('input', function (e) {
    this.value = this.value.replace(/[^0-9]/g, '');
  });
</script>

</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html>
<html>
<head>
<title>AI Career Advisor</title>
<jsp:include page="/WEB-INF/jsp/layout-head.jsp"/>
<style>
  /* Premium Dark Chat Theme */
  .chat-theme-dark {
    background: #0b0f19;
    color: #e2e8f0;
    min-height: 100vh;
  }
  .chat-container-premium {
    max-width: 900px;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    height: calc(100vh - 120px);
    background: rgba(15, 23, 42, 0.6);
    backdrop-filter: blur(16px);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  }
  .chat-box-premium {
    flex: 1;
    overflow-y: auto;
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
    background: radial-gradient(circle at top, rgba(30, 41, 59, 0.2), transparent);
    scroll-behavior: smooth;
  }
  
  /* Bubbles */
  .bubble-premium {
    max-width: 80%;
    padding: 1rem 1.25rem;
    border-radius: 16px;
    line-height: 1.5;
    font-size: 0.95rem;
    position: relative;
    animation: bubbleFadeIn 0.3s ease-out;
  }
  @keyframes bubbleFadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  
  /* User Bubble */
  .bubble-premium.u {
    background: linear-gradient(135deg, #3b82f6, #1d4ed8);
    color: #fff;
    align-self: flex-end;
    border-bottom-right-radius: 4px;
    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
  }
  
  /* Bot/Advisor Bubble */
  .bubble-premium.b {
    background: rgba(30, 41, 59, 0.7);
    border: 1px solid rgba(255, 255, 255, 0.06);
    color: #cbd5e1;
    align-self: flex-start;
    border-bottom-left-radius: 4px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }
  
  /* Form & Inputs */
  .chat-input-bar {
    padding: 1.25rem;
    background: rgba(15, 23, 42, 0.8);
    border-top: 1px solid rgba(255, 255, 255, 0.08);
  }
  .chat-form-premium {
    display: flex;
    gap: 0.75rem;
  }
  .chat-form-premium input[type="text"] {
    flex: 1;
    background: rgba(30, 41, 59, 0.5);
    border: 1px solid rgba(255, 255, 255, 0.12);
    color: #fff;
    padding: 0.75rem 1.25rem;
    border-radius: 999px;
    outline: none;
    margin-bottom: 0;
    transition: all 0.2s;
  }
  .chat-form-premium input[type="text"]:focus {
    border-color: #3b82f6;
    background: rgba(30, 41, 59, 0.7);
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.25);
  }
  .chat-form-premium button {
    background: linear-gradient(135deg, #3b82f6, #1d4ed8);
    border: none;
    color: white;
    padding: 0.75rem 1.5rem;
    border-radius: 999px;
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.2s;
  }
  .chat-form-premium button:active {
    transform: scale(0.96);
  }
  
  /* Chips styling */
  .chips-container {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    padding: 0.75rem 1.5rem;
    background: rgba(15, 23, 42, 0.4);
    border-top: 1px solid rgba(255, 255, 255, 0.04);
  }
  .chip-premium {
    background: rgba(30, 41, 59, 0.6);
    border: 1px solid rgba(255, 255, 255, 0.08);
    color: #94a3b8;
    padding: 0.4rem 0.85rem;
    border-radius: 999px;
    font-size: 0.82rem;
    cursor: pointer;
    transition: all 0.2s;
  }
  .chip-premium:hover {
    background: rgba(59, 130, 246, 0.15);
    border-color: #3b82f6;
    color: #3b82f6;
    transform: translateY(-1px);
  }

  /* Typing Animation */
  .typing-bubble {
    display: none;
    align-self: flex-start;
    background: rgba(30, 41, 59, 0.7);
    border: 1px solid rgba(255, 255, 255, 0.06);
    padding: 0.75rem 1.25rem;
    border-radius: 16px;
    border-bottom-left-radius: 4px;
  }
  .typing-loader {
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .typing-dot {
    width: 8px;
    height: 8px;
    background-color: #94a3b8;
    border-radius: 50%;
    animation: typingBounce 1.4s infinite ease-in-out both;
  }
  .typing-dot:nth-child(1) { animation-delay: -0.32s; }
  .typing-dot:nth-child(2) { animation-delay: -0.16s; }
  @keyframes typingBounce {
    0%, 80%, 100% { transform: scale(0); }
    40% { transform: scale(1); }
  }

  /* Premium Advisor Bubble Elements */
  .adv-type {
    font-size: 0.68rem;
    font-weight: 700;
    letter-spacing: 0.06em;
    color: #60a5fa;
    text-transform: uppercase;
    margin-bottom: 0.25rem;
  }
  .adv-title {
    display: block;
    font-size: 1.1rem;
    color: #fff;
    margin-bottom: 0.5rem;
    font-weight: 700;
  }
  .adv-summary {
    font-size: 0.95rem;
    color: #cbd5e1;
    margin-bottom: 0.75rem;
  }
  .adv-highlights {
    list-style: none;
    padding: 0;
    margin: 0.75rem 0;
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
  }
  .adv-highlights li {
    font-size: 0.9rem;
    color: #94a3b8;
    position: relative;
    padding-left: 1.2rem;
  }
  .adv-highlights li::before {
    content: "✦";
    position: absolute;
    left: 0;
    color: #3b82f6;
  }
  .adv-section {
    margin-top: 0.75rem;
    padding-top: 0.75rem;
    border-top: 1px dashed rgba(255, 255, 255, 0.1);
  }
  .adv-sec-head {
    font-weight: 600;
    font-size: 0.9rem;
    color: #60a5fa;
    margin-bottom: 0.35rem;
  }
  .adv-section p {
    font-size: 0.88rem;
    color: #cbd5e1;
    margin-bottom: 0.5rem;
  }
  .adv-section ul {
    list-style: square;
    margin-left: 1.25rem;
    font-size: 0.88rem;
    color: #cbd5e1;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }
</style>
</head>
<body class="chat-theme-dark">
<div class="wrap">
<jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="chat"/></jsp:include>
<main class="main">
  
  <header style="margin-bottom: 1.5rem;">
    <h1 style="color: #fff; font-size: 1.75rem; margin-bottom: 0.25rem;">AI Career Advisor</h1>
    <p style="color: #94a3b8; font-size: 0.95rem;">Ask your dynamic mentor about your skills gaps, custom learning paths, domain job feed, or recommended certifications.</p>
  </header>

  <jsp:include page="/WEB-INF/jsp/career-role-bar.jsp"/>

  <div class="chat-container-premium">
    <div class="chat-box-premium" id="chatBox">
      
      <!-- Welcome Message from Advisor -->
      <div class="bubble-premium b">
        <div class="adv-type">Mentor Overview</div>
        <strong class="adv-title">Welcome to CareerAssist AI</strong>
        <p class="adv-summary">I'm your dedicated career mentor, fully context-aware of your profile. Ask me any question, such as:</p>
        <ul class="adv-highlights">
          <li>What is missing in my resume?</li>
          <li>Suggest certifications for my domain</li>
          <li>How can I improve my networking skills?</li>
          <li>What jobs match my resume skills?</li>
        </ul>
      </div>

      <!-- Historical Chat Logs -->
      <% List<ChatMsg> chatList = (List<ChatMsg>) request.getAttribute("chat");
         if (chatList != null) {
           for (ChatMsg m : chatList) {
             boolean isUser = "USER".equals(m.getRole());
      %>
      <div class="bubble-premium <%= isUser ? "u" : "b" %>">
        <% if (isUser) { %>
          <%= m.getMessage() %>
        <% } else { 
             // We format structured lines nicely if they contain our markup labels
             String msg = m.getMessage();
             if (msg.contains(":\n") || msg.contains("•")) {
               // Render formatted
               String[] lines = msg.split("\n");
               for (String line : lines) {
                 if (line.endsWith(":")) {
                   out.print("<div class='adv-sec-head'>" + line + "</div>");
                 } else if (line.trim().startsWith("•")) {
                   out.print("<div style='margin-left:1rem; color:#cbd5e1; font-size:0.9rem; margin-bottom:0.25rem;'>✦ " + line.replace("•", "").trim() + "</div>");
                 } else {
                   out.print("<p style='font-size:0.92rem; color:#cbd5e1; margin-bottom:0.5rem;'>" + line + "</p>");
                 }
               }
             } else {
               out.print(msg.replace("\n", "<br>"));
             }
           }
        %>
      </div>
      <%   }
         } %>
         
      <!-- Animated Typing Loader -->
      <div class="typing-bubble" id="typingBubble">
        <div class="typing-loader">
          <div class="typing-dot"></div>
          <div class="typing-dot"></div>
          <div class="typing-dot"></div>
        </div>
      </div>
    </div>

    <!-- 6 Premium quick prompt chips -->
    <div class="chips-container">
      <button type="button" class="chip-premium" data-prompt="What jobs match my resume?">What jobs match my resume?</button>
      <button type="button" class="chip-premium" data-prompt="What is missing in my resume?">What is missing in my resume?</button>
      <button type="button" class="chip-premium" data-prompt="Suggest certifications">Suggest certifications</button>
      <button type="button" class="chip-premium" data-prompt="How can I improve networking skills?">How to improve networking?</button>
      <button type="button" class="chip-premium" data-prompt="What should I learn next?">What to learn next?</button>
      <button type="button" class="chip-premium" data-prompt="Why am I not getting shortlisted?">Why not shortlisted?</button>
    </div>

    <!-- Chat Form Input -->
    <div class="chat-input-bar">
      <form id="chatForm" onsubmit="return sendChat(event)" class="chat-form-premium">
        <input type="text" id="msg" placeholder="Ask about missing skills, jobs, roadmaps, or certs..." required autocomplete="off">
        <button type="submit">Send</button>
      </form>
    </div>
  </div>
</main>
</div>

<script>
const ctx = '${pageContext.request.contextPath}';

function escapeHtml(s) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// Render dynamic advisor layouts returned by CareerAIService
function renderAdvisorBubble(data) {
  const wrap = document.createElement('div');
  wrap.className = 'bubble-premium b';
  
  let html = '<div class="adv-type">' + escapeHtml(data.type || 'ADVICE') + '</div>';
  html += '<strong class="adv-title">' + escapeHtml(data.title || '') + '</strong>';
  if (data.summary) html += '<p class="adv-summary">' + escapeHtml(data.summary) + '</p>';
  
  if (data.highlights && data.highlights.length) {
    html += '<ul class="adv-highlights">';
    data.highlights.forEach(h => {
      html += '<li>' + escapeHtml(h) + '</li>';
    });
    html += '</ul>';
  }
  
  if (data.sections) {
    data.sections.forEach(sec => {
      html += '<div class="adv-section"><div class="adv-sec-head">' + escapeHtml(sec.heading || '') + '</div>';
      if (sec.body) html += '<p>' + escapeHtml(sec.body) + '</p>';
      if (sec.items && sec.items.length) {
        html += '<ul>';
        sec.items.forEach(it => {
          html += '<li>' + escapeHtml(it) + '</li>';
        });
        html += '</ul>';
      }
      html += '</div>';
    });
  }
  
  wrap.innerHTML = html;
  return wrap;
}

function sendChat(e) {
  e.preventDefault();
  const input = document.getElementById('msg');
  const m = input.value.trim();
  if (!m) return false;
  
  const box = document.getElementById('chatBox');
  const typing = document.getElementById('typingBubble');
  
  // Append User Bubble
  const u = document.createElement('div');
  u.className = 'bubble-premium u';
  u.textContent = m;
  box.insertBefore(u, typing);
  
  // Show typing loader
  typing.style.display = 'block';
  box.scrollTop = box.scrollHeight;

  const fd = new FormData();
  fd.append('action', 'chat');
  fd.append('message', m);
  fd.append('ajax', '1');

  fetch(ctx + '/student', { method: 'POST', body: fd })
    .then(r => r.json())
    .then(d => {
      // Hide typing loader
      typing.style.display = 'none';
      // Append bot bubble
      box.insertBefore(renderAdvisorBubble(d), typing);
      box.scrollTop = box.scrollHeight;
    })
    .catch(() => {
      typing.style.display = 'none';
      const err = document.createElement('div');
      err.className = 'bubble-premium b';
      err.textContent = 'I experienced a connection issue. Please try resending your message.';
      box.insertBefore(err, typing);
      box.scrollTop = box.scrollHeight;
    });

  input.value = '';
  return false;
}

// Auto-submit quick prompt chips
document.querySelectorAll('.chip-premium').forEach(btn => {
  btn.addEventListener('click', () => {
    document.getElementById('msg').value = btn.dataset.prompt;
    document.getElementById('chatForm').requestSubmit();
  });
});

// Scroll to bottom initially
window.addEventListener('DOMContentLoaded', () => {
  const box = document.getElementById('chatBox');
  box.scrollTop = box.scrollHeight;
});
</script>
</body>
</html>

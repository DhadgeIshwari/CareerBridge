<%-- floating-chat.jsp: Global floating AI assistant for all Student pages --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String _ctx = request.getContextPath();
%>

<!-- ===== FLOATING AI ASSISTANT WIDGET ===== -->
<style>
/* ---- FAB Button ---- */
#ai-fab {
  position: fixed;
  bottom: 28px;
  right: 28px;
  z-index: 9999;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: linear-gradient(135deg, #06b6d4, #7c3aed);
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
  color: #fff;
  box-shadow: 0 0 0 0 rgba(6,182,212,0.5);
  animation: fabPulse 2.4s infinite;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
  outline: none;
}
#ai-fab:hover {
  transform: scale(1.12);
  box-shadow: 0 0 28px rgba(6,182,212,0.55), 0 0 60px rgba(124,58,237,0.25);
  animation: none;
}
#ai-fab .fab-badge {
  position: absolute;
  top: -3px;
  right: -3px;
  width: 14px;
  height: 14px;
  background: #10b981;
  border-radius: 50%;
  border: 2px solid #0b0f19;
}
@keyframes fabPulse {
  0%   { box-shadow: 0 0 0 0 rgba(6,182,212,0.55); }
  70%  { box-shadow: 0 0 0 14px rgba(6,182,212,0); }
  100% { box-shadow: 0 0 0 0 rgba(6,182,212,0); }
}

/* ---- Chat Window ---- */
#ai-chat-window {
  position: fixed;
  bottom: 100px;
  right: 28px;
  z-index: 9998;
  width: 390px;
  max-height: 600px;
  display: flex;
  flex-direction: column;
  background: rgba(9, 14, 28, 0.97);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(6,182,212,0.2);
  border-radius: 20px;
  box-shadow: 0 24px 80px rgba(0,0,0,0.6), 0 0 40px rgba(6,182,212,0.08);
  overflow: hidden;
  transform: translateY(24px) scale(0.95);
  opacity: 0;
  pointer-events: none;
  transition: transform 0.3s cubic-bezier(.34,1.56,.64,1), opacity 0.25s ease;
}
#ai-chat-window.open {
  transform: translateY(0) scale(1);
  opacity: 1;
  pointer-events: all;
}

/* ---- Header ---- */
.ai-chat-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.1rem;
  background: linear-gradient(90deg, rgba(6,182,212,0.1), rgba(124,58,237,0.1));
  border-bottom: 1px solid rgba(255,255,255,0.07);
  flex-shrink: 0;
}
.ai-chat-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg,#06b6d4,#7c3aed);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1rem;
  color: #fff;
  flex-shrink: 0;
}
.ai-chat-title {
  flex: 1;
}
.ai-chat-title strong {
  display: block;
  font-size: 0.9rem;
  font-weight: 700;
  color: #f1f5f9;
  font-family: 'Outfit', sans-serif;
}
.ai-chat-title span {
  font-size: 0.72rem;
  color: #10b981;
  font-weight: 500;
}
.ai-chat-header-btns {
  display: flex;
  gap: 0.35rem;
}
.ai-hdr-btn {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  border: none;
  background: rgba(255,255,255,0.06);
  color: #94a3b8;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  transition: background 0.2s, color 0.2s;
}
.ai-hdr-btn:hover {
  background: rgba(255,255,255,0.12);
  color: #f1f5f9;
}

/* ---- Messages Area ---- */
#ai-messages {
  flex: 1;
  overflow-y: auto;
  padding: 1rem 1rem 0.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
  scroll-behavior: smooth;
  min-height: 0;
}
#ai-messages::-webkit-scrollbar { width: 4px; }
#ai-messages::-webkit-scrollbar-track { background: transparent; }
#ai-messages::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 2px; }

/* ---- Message Bubbles ---- */
.ai-bubble {
  max-width: 86%;
  padding: 0.75rem 1rem;
  border-radius: 16px;
  font-size: 0.875rem;
  line-height: 1.55;
  animation: bubbleIn 0.3s ease-out;
}
@keyframes bubbleIn {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}
.ai-bubble.user {
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
  color: #fff;
  align-self: flex-end;
  border-bottom-right-radius: 4px;
  box-shadow: 0 4px 14px rgba(37,99,235,0.3);
}
.ai-bubble.bot {
  background: rgba(30, 41, 59, 0.75);
  border: 1px solid rgba(255,255,255,0.07);
  color: #cbd5e1;
  align-self: flex-start;
  border-bottom-left-radius: 4px;
}
.ai-bubble.bot .bot-type {
  font-size: 0.65rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  color: #06b6d4;
  text-transform: uppercase;
  margin-bottom: 0.25rem;
}
.ai-bubble.bot .bot-title {
  font-size: 0.95rem;
  font-weight: 700;
  color: #f1f5f9;
  font-family: 'Outfit', sans-serif;
  margin-bottom: 0.3rem;
  display: block;
}
.ai-bubble.bot .bot-summary {
  font-size: 0.85rem;
  color: #94a3b8;
  margin-bottom: 0.4rem;
}
.ai-bubble.bot ul.bot-highlights {
  list-style: none;
  padding: 0;
  margin: 0.5rem 0 0;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}
.ai-bubble.bot ul.bot-highlights li {
  font-size: 0.82rem;
  color: #94a3b8;
  padding-left: 1rem;
  position: relative;
}
.ai-bubble.bot ul.bot-highlights li::before {
  content: "✦";
  position: absolute;
  left: 0;
  color: #06b6d4;
  font-size: 0.65rem;
  top: 2px;
}
.ai-bubble.bot .bot-section { margin-top: 0.6rem; border-top: 1px dashed rgba(255,255,255,0.07); padding-top: 0.6rem; }
.ai-bubble.bot .bot-sec-head { font-weight: 600; font-size: 0.8rem; color: #7c3aed; margin-bottom: 0.3rem; }

/* ---- Typing Indicator ---- */
#ai-typing {
  display: none;
  align-self: flex-start;
  background: rgba(30,41,59,0.75);
  border: 1px solid rgba(255,255,255,0.07);
  padding: 0.65rem 1rem;
  border-radius: 16px;
  border-bottom-left-radius: 4px;
  animation: bubbleIn 0.3s ease-out;
}
#ai-typing .dots {
  display: flex;
  gap: 5px;
  align-items: center;
}
#ai-typing .dot {
  width: 7px;
  height: 7px;
  background: #94a3b8;
  border-radius: 50%;
  animation: dotBounce 1.3s infinite ease-in-out both;
}
#ai-typing .dot:nth-child(1) { animation-delay: -0.32s; }
#ai-typing .dot:nth-child(2) { animation-delay: -0.16s; }
@keyframes dotBounce {
  0%, 80%, 100% { transform: scale(0.5); opacity: 0.4; }
  40%           { transform: scale(1);   opacity: 1; }
}

/* ---- Welcome Screen ---- */
#ai-welcome {
  padding: 1.25rem 1rem 0.5rem;
  text-align: center;
  animation: bubbleIn 0.4s ease-out;
}
#ai-welcome .w-emoji { font-size: 2rem; margin-bottom: 0.5rem; }
#ai-welcome .w-title {
  font-family: 'Outfit', sans-serif;
  font-size: 1.05rem;
  font-weight: 700;
  color: #f1f5f9;
  margin-bottom: 0.25rem;
}
#ai-welcome .w-sub {
  font-size: 0.78rem;
  color: #64748b;
  margin-bottom: 0.85rem;
}
#ai-welcome .w-caps {
  text-align: left;
  background: rgba(6,182,212,0.05);
  border: 1px solid rgba(6,182,212,0.12);
  border-radius: 12px;
  padding: 0.75rem;
  margin-bottom: 0.85rem;
}
#ai-welcome .w-caps .cap-item {
  font-size: 0.8rem;
  color: #94a3b8;
  padding: 0.2rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
#ai-welcome .w-caps .cap-item i { color: #06b6d4; width: 14px; }
#ai-welcome .w-qlabel {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: #475569;
  margin-bottom: 0.5rem;
  text-align: left;
}

/* ---- Quick Chips ---- */
.ai-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  padding: 0.5rem 1rem 0.75rem;
  border-top: 1px solid rgba(255,255,255,0.04);
  flex-shrink: 0;
}
.ai-chip {
  background: rgba(30,41,59,0.6);
  border: 1px solid rgba(255,255,255,0.08);
  color: #64748b;
  padding: 0.35rem 0.75rem;
  border-radius: 999px;
  font-size: 0.75rem;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
  font-family: 'Inter', sans-serif;
}
.ai-chip:hover {
  background: rgba(6,182,212,0.12);
  border-color: #06b6d4;
  color: #06b6d4;
  transform: translateY(-1px);
}

/* ---- Input Bar ---- */
.ai-input-bar {
  display: flex;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background: rgba(6,10,22,0.8);
  border-top: 1px solid rgba(255,255,255,0.06);
  flex-shrink: 0;
}
#ai-input {
  flex: 1;
  background: rgba(30,41,59,0.5);
  border: 1px solid rgba(255,255,255,0.1);
  color: #f1f5f9;
  padding: 0.6rem 1rem;
  border-radius: 999px;
  font-size: 0.875rem;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  font-family: 'Inter', sans-serif;
}
#ai-input::placeholder { color: #475569; }
#ai-input:focus {
  border-color: #06b6d4;
  box-shadow: 0 0 0 3px rgba(6,182,212,0.15);
}
#ai-send {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, #06b6d4, #7c3aed);
  color: #fff;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: transform 0.2s, box-shadow 0.2s;
}
#ai-send:hover  { transform: scale(1.08); box-shadow: 0 4px 14px rgba(6,182,212,0.4); }
#ai-send:active { transform: scale(0.95); }

@media (max-width: 480px) {
  #ai-chat-window { width: calc(100vw - 24px); right: 12px; bottom: 88px; }
  #ai-fab { right: 16px; bottom: 16px; }
}
</style>

<!-- FAB -->
<button id="ai-fab" aria-label="Open AI Career Assistant" title="Career AI Assistant">
  <i class="fa-solid fa-robot"></i>
  <span class="fab-badge"></span>
</button>

<!-- Chat Window -->
<div id="ai-chat-window" role="dialog" aria-label="Career AI Assistant">

  <!-- Header -->
  <div class="ai-chat-header">
    <div class="ai-chat-avatar"><i class="fa-solid fa-robot"></i></div>
    <div class="ai-chat-title">
      <strong>Career AI Assistant</strong>
      <span>&#9679; Online</span>
    </div>
    <div class="ai-chat-header-btns">
      <button class="ai-hdr-btn" id="ai-clear-btn" title="Clear chat"><i class="fa-solid fa-rotate-left"></i></button>
      <button class="ai-hdr-btn" id="ai-close-btn" title="Close"><i class="fa-solid fa-xmark"></i></button>
    </div>
  </div>

  <!-- Messages -->
  <div id="ai-messages">
    <!-- Welcome screen injected by JS when history is empty -->
  </div>

  <!-- Typing indicator (lives inside message flow) -->
  <div id="ai-typing">
    <div class="dots">
      <div class="dot"></div><div class="dot"></div><div class="dot"></div>
    </div>
  </div>

  <!-- Quick chips -->
  <div class="ai-chips" id="ai-chips">
    <button class="ai-chip" data-q="What jobs match my profile?">&#x1F4BC; Jobs for me</button>
    <button class="ai-chip" data-q="Why is my ATS score low?">&#x1F4CA; ATS Score</button>
    <button class="ai-chip" data-q="What should I learn next?">&#x1F9E0; Learn Next</button>
    <button class="ai-chip" data-q="What skills am I missing?">&#x26A1; Skill Gaps</button>
    <button class="ai-chip" data-q="Suggest certifications for my domain">&#x1F3C6; Certifications</button>
  </div>

  <!-- Input -->
  <div class="ai-input-bar">
    <input type="text" id="ai-input" placeholder="Ask about your career, skills, or jobs…" autocomplete="off" maxlength="300">
    <button id="ai-send" aria-label="Send"><i class="fa-solid fa-paper-plane"></i></button>
  </div>
</div>

<script>
(function () {
  const CTX   = '<%= _ctx %>';
  const STORE = 'ai_chat_history_v2';

  /* -------- State -------- */
  let history = [];
  try { history = JSON.parse(localStorage.getItem(STORE) || '[]'); } catch(e) {}

  /* -------- Elements -------- */
  const fab     = document.getElementById('ai-fab');
  const win     = document.getElementById('ai-chat-window');
  const msgs    = document.getElementById('ai-messages');
  const typing  = document.getElementById('ai-typing');
  const input   = document.getElementById('ai-input');
  const sendBtn = document.getElementById('ai-send');
  const closeBtn= document.getElementById('ai-close-btn');
  const clearBtn= document.getElementById('ai-clear-btn');
  let isOpen = false;

  /* -------- Toggle -------- */
  fab.addEventListener('click', () => {
    isOpen ? closeChat() : openChat();
  });
  closeBtn.addEventListener('click', closeChat);
  clearBtn.addEventListener('click', () => {
    history = [];
    localStorage.removeItem(STORE);
    msgs.innerHTML = '';
    typing.style.display = 'none';
    renderWelcome();
    // Move typing back into msgs
    msgs.appendChild(typing);
  });

  function openChat() {
    isOpen = true;
    win.classList.add('open');
    fab.innerHTML = '<i class="fa-solid fa-xmark"></i>';
    // Render persisted history or welcome
    if (history.length === 0) {
      renderWelcome();
    } else {
      msgs.innerHTML = '';
      history.forEach(h => appendBubble(h.role, h.data, false));
    }
    msgs.appendChild(typing);
    scrollDown();
    setTimeout(() => input.focus(), 300);
  }

  function closeChat() {
    isOpen = false;
    win.classList.remove('open');
    fab.innerHTML = '<i class="fa-solid fa-robot"></i><span class="fab-badge"></span>';
  }

  /* -------- Welcome Screen -------- */
  function renderWelcome() {
    const w = document.createElement('div');
    w.id = 'ai-welcome';
    w.innerHTML = `
      <div class="w-emoji">&#x1F44B;</div>
      <div class="w-title">Welcome to Career AI Assistant</div>
      <div class="w-sub">Your intelligent career mentor, available 24/7.</div>
      <div class="w-caps">
        <div class="cap-item"><i class="fa-solid fa-file-lines"></i> Resume Analysis</div>
        <div class="cap-item"><i class="fa-solid fa-chart-bar"></i> ATS Score Improvement</div>
        <div class="cap-item"><i class="fa-solid fa-briefcase"></i> Job Recommendations</div>
        <div class="cap-item"><i class="fa-solid fa-bolt"></i> Skill Gap Analysis</div>
        <div class="cap-item"><i class="fa-solid fa-brain"></i> Learning Paths</div>
      </div>
      <div class="w-qlabel">Suggested Questions</div>
    `;
    msgs.innerHTML = '';
    msgs.appendChild(w);
  }

  /* -------- Render a bubble -------- */
  function appendBubble(role, data, animate) {
    const el = document.createElement('div');
    el.className = 'ai-bubble ' + (role === 'user' ? 'user' : 'bot');
    if (!animate) el.style.animation = 'none';

    if (role === 'user') {
      el.textContent = typeof data === 'string' ? data : data.text;
    } else {
      // data is a ChatResponse-shaped object
      let html = '';
      if (data.type && data.type !== 'GREETING')
        html += `<div class="bot-type">\${esc(data.type.replace('_',' '))}</div>`;
      if (data.title)
        html += `<span class="bot-title">\${esc(data.title)}</span>`;
      if (data.summary)
        html += `<div class="bot-summary">\${esc(data.summary)}</div>`;
      if (data.highlights && data.highlights.length) {
        html += '<ul class="bot-highlights">';
        data.highlights.forEach(h => { html += `<li>\${esc(h)}</li>`; });
        html += '</ul>';
      }
      if (data.sections && data.sections.length) {
        data.sections.forEach(sec => {
          html += `<div class="bot-section"><div class="bot-sec-head">\${esc(sec.heading||'')}</div>`;
          if (sec.body) html += `<div style="font-size:0.82rem;color:#94a3b8">\${esc(sec.body)}</div>`;
          if (sec.items && sec.items.length) {
            html += '<ul class="bot-highlights">';
            sec.items.forEach(it => { html += `<li>\${esc(it)}</li>`; });
            html += '</ul>';
          }
          html += '</div>';
        });
      }
      // Fallback: plain reply text
      if (!data.title && !data.summary && data.reply) {
        html = data.reply.replace(/\n/g, '<br>');
      }
      el.innerHTML = html;
    }

    msgs.insertBefore(el, typing);
    scrollDown();
    return el;
  }

  function esc(s) {
    return String(s||'')
      .replace(/&/g,'&amp;')
      .replace(/</g,'&lt;')
      .replace(/>/g,'&gt;')
      .replace(/"/g,'&quot;');
  }

  function scrollDown() {
    requestAnimationFrame(() => { msgs.scrollTop = msgs.scrollHeight; });
  }

  /* -------- Send -------- */
  function sendMessage() {
    const text = input.value.trim();
    if (!text) return;
    input.value = '';

    // Remove welcome screen if present
    const welcome = document.getElementById('ai-welcome');
    if (welcome) welcome.remove();

    // User bubble
    appendBubble('user', { text }, true);
    history.push({ role: 'user', data: { text } });

    // Show typing
    typing.style.display = 'block';
    msgs.appendChild(typing);
    scrollDown();

    // Randomised delay 600–950ms for natural feel
    const delay = 600 + Math.random() * 350;

    const fd = new FormData();
    fd.append('action', 'chat');
    fd.append('message', text);
    fd.append('ajax', '1');

    const start = Date.now();
    fetch(CTX + '/student', { method: 'POST', body: fd })
      .then(r => r.json())
      .then(d => {
        const elapsed = Date.now() - start;
        const wait = Math.max(0, delay - elapsed);
        setTimeout(() => {
          typing.style.display = 'none';
          appendBubble('bot', d, true);
          history.push({ role: 'bot', data: d });
          if (history.length > 40) history = history.slice(-40);
          try { localStorage.setItem(STORE, JSON.stringify(history)); } catch(e) {}
        }, wait);
      })
      .catch(() => {
        typing.style.display = 'none';
        const errData = {
          type: 'ERROR',
          title: 'Connection Issue',
          summary: 'I couldn\'t reach the server. Please check your connection and try again.'
        };
        appendBubble('bot', errData, true);
      });
  }

  sendBtn.addEventListener('click', sendMessage);
  input.addEventListener('keydown', e => {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  });

  /* -------- Quick chips -------- */
  document.querySelectorAll('#ai-chips .ai-chip').forEach(btn => {
    btn.addEventListener('click', () => {
      input.value = btn.dataset.q;
      sendMessage();
    });
  });

  /* ---- Move typing node into msgs on init ---- */
  msgs.appendChild(typing);

})();
</script>

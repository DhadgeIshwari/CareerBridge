<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>CareerAssist — Land your dream job with AI guidance</title>
<meta name="description" content="CareerAssist uses AI to score your resume, match you to the right jobs, and close your skill gaps." />
<style>
  /* ---------- Reset & base ---------- */
  *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
  html{scroll-behavior:smooth}
  body{
    font-family:'Inter',system-ui,-apple-system,Segoe UI,Roboto,sans-serif;
    background:#06060c;
    color:#e7e9f3;
    line-height:1.6;
    overflow-x:hidden;
    -webkit-font-smoothing:antialiased;
  }
  a{color:inherit;text-decoration:none}
  img{max-width:100%;display:block}
  /* ---------- Background glow blobs ---------- */
  .bg-wrap{position:fixed;inset:0;z-index:-1;overflow:hidden;pointer-events:none}
  .blob{
    position:absolute;border-radius:50%;filter:blur(120px);opacity:.45;
    animation:float 14s ease-in-out infinite;
  }
  .blob.b1{width:520px;height:520px;background:#7c3aed;top:-160px;left:-120px}
  .blob.b2{width:480px;height:480px;background:#06b6d4;top:30%;right:-140px;animation-delay:-4s}
  .blob.b3{width:420px;height:420px;background:#3b82f6;bottom:-160px;left:30%;animation-delay:-8s}
  @keyframes float{
    0%,100%{transform:translate(0,0) scale(1)}
    50%{transform:translate(40px,-30px) scale(1.08)}
  }
  /* ---------- Layout ---------- */
  .container{width:min(1140px,92%);margin-inline:auto}
  /* ---------- Navbar ---------- */
  .nav{
    position:sticky;top:0;z-index:50;
    backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);
    background:rgba(10,10,18,.6);
    border-bottom:1px solid rgba(255,255,255,.06);
  }
  .nav-inner{display:flex;align-items:center;justify-content:space-between;padding:16px 0}
  .logo{
    font-weight:800;font-size:1.25rem;letter-spacing:-.02em;
    background:linear-gradient(90deg,#22d3ee,#8b5cf6);
    -webkit-background-clip:text;background-clip:text;color:transparent;
  }
  .nav-links{display:flex;gap:28px;align-items:center}
  .nav-links a.lnk{font-size:.92rem;color:#b9bccc;transition:color .2s}
  .nav-links a.lnk:hover{color:#fff}
  .nav-actions{display:flex;gap:10px;align-items:center}
  .btn{
    display:inline-flex;align-items:center;justify-content:center;gap:8px;
    padding:10px 18px;border-radius:10px;font-weight:600;font-size:.9rem;
    border:1px solid transparent;cursor:pointer;transition:all .25s ease;
    white-space:nowrap;
  }
  .btn-ghost{background:transparent;color:#e7e9f3;border-color:rgba(255,255,255,.12)}
  .btn-ghost:hover{border-color:rgba(255,255,255,.3);background:rgba(255,255,255,.04)}
  .btn-primary{
    color:#fff;
    background:linear-gradient(135deg,#06b6d4 0%,#6366f1 50%,#8b5cf6 100%);
    box-shadow:0 10px 30px -10px rgba(99,102,241,.55);
  }
  .btn-primary:hover{transform:translateY(-2px);box-shadow:0 18px 40px -12px rgba(139,92,246,.7)}
  .btn-lg{padding:14px 26px;font-size:1rem;border-radius:12px}
  /* ---------- Hero ---------- */
  .hero{padding:96px 0 80px;text-align:center;position:relative}
  .pill{
    display:inline-flex;align-items:center;gap:8px;
    padding:6px 14px;border-radius:999px;font-size:.8rem;color:#c7cbe0;
    background:rgba(255,255,255,.04);
    border:1px solid rgba(255,255,255,.08);
    margin-bottom:28px;
    animation:fadeUp .8s ease both;
  }
  .pill::before{content:"";width:8px;height:8px;border-radius:50%;background:#22d3ee;box-shadow:0 0 12px #22d3ee}
  .hero h1{
    font-size:clamp(2.4rem,6vw,4.5rem);
    line-height:1.05;letter-spacing:-.03em;font-weight:800;
    background:linear-gradient(180deg,#ffffff 0%,#b9bccc 100%);
    -webkit-background-clip:text;background-clip:text;color:transparent;
    max-width:900px;margin:0 auto;
    animation:fadeUp .9s .1s ease both;
  }
  .hero h1 .accent{
    background:linear-gradient(90deg,#22d3ee,#8b5cf6);
    -webkit-background-clip:text;background-clip:text;color:transparent;
  }
  .hero p{
    margin:24px auto 0;max-width:620px;color:#a3a8bd;font-size:1.1rem;
    animation:fadeUp 1s .25s ease both;
  }
  .hero-cta{
    margin-top:40px;display:flex;gap:14px;justify-content:center;flex-wrap:wrap;
    animation:fadeUp 1.1s .4s ease both;
  }
  /* ---------- Features ---------- */
  .features{padding:80px 0 60px}
  .section-head{text-align:center;margin-bottom:56px}
  .section-head .eyebrow{
    text-transform:uppercase;letter-spacing:.18em;font-size:.78rem;
    color:#22d3ee;font-weight:600;margin-bottom:14px;
  }
  .section-head h2{
    font-size:clamp(1.8rem,3.6vw,2.6rem);font-weight:700;letter-spacing:-.02em;
    color:#fff;
  }
  .grid{display:grid;grid-template-columns:repeat(3,1fr);gap:24px}
  .card{
    position:relative;padding:32px;border-radius:20px;
    background:linear-gradient(180deg,rgba(255,255,255,.04),rgba(255,255,255,.015));
    border:1px solid rgba(255,255,255,.08);
    backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);
    transition:transform .35s ease,border-color .35s ease,box-shadow .35s ease;
    overflow:hidden;
    opacity:0;transform:translateY(20px);
    animation:fadeUp .8s ease forwards;
  }
  .card:nth-child(1){animation-delay:.1s}
  .card:nth-child(2){animation-delay:.25s}
  .card:nth-child(3){animation-delay:.4s}
  .card::before{
    content:"";position:absolute;inset:0;border-radius:20px;padding:1px;
    background:linear-gradient(135deg,#22d3ee,#8b5cf6,#3b82f6);
    -webkit-mask:linear-gradient(#000 0 0) content-box,linear-gradient(#000 0 0);
    -webkit-mask-composite:xor;mask-composite:exclude;
    opacity:0;transition:opacity .35s ease;pointer-events:none;
  }
  .card:hover{
    transform:translateY(-8px);
    box-shadow:0 30px 60px -25px rgba(139,92,246,.45);
  }
  .card:hover::before{opacity:1}
  .icon-badge{
    width:56px;height:56px;border-radius:16px;
    display:flex;align-items:center;justify-content:center;
    background:linear-gradient(135deg,rgba(34,211,238,.18),rgba(139,92,246,.22));
    border:1px solid rgba(255,255,255,.08);
    font-size:1.6rem;margin-bottom:22px;
    box-shadow:inset 0 0 20px rgba(139,92,246,.15);
  }
  .card h3{font-size:1.2rem;font-weight:700;color:#fff;margin-bottom:10px;letter-spacing:-.01em}
  .card p{color:#a3a8bd;font-size:.95rem}
  /* ---------- How it works ---------- */
  .how{padding:80px 0 100px}
  .steps{display:grid;grid-template-columns:repeat(3,1fr);gap:24px;counter-reset:step}
  .step{
    padding:28px;border-radius:18px;
    background:rgba(255,255,255,.025);
    border:1px solid rgba(255,255,255,.06);
    position:relative;transition:border-color .3s;
  }
  .step:hover{border-color:rgba(139,92,246,.4)}
  .step::before{
    counter-increment:step;content:"0" counter(step);
    font-weight:800;font-size:1.1rem;
    background:linear-gradient(90deg,#22d3ee,#8b5cf6);
    -webkit-background-clip:text;background-clip:text;color:transparent;
    display:block;margin-bottom:14px;
  }
  .step h4{color:#fff;font-size:1.05rem;margin-bottom:6px}
  .step p{color:#a3a8bd;font-size:.92rem}
  /* ---------- Footer ---------- */
  footer{
    border-top:1px solid rgba(255,255,255,.06);
    padding:24px 0;text-align:center;color:#7a7f95;font-size:.85rem;
  }
  /* ---------- Animations ---------- */
  @keyframes fadeUp{
    from{opacity:0;transform:translateY(20px)}
    to{opacity:1;transform:translateY(0)}
  }
  /* ---------- Responsive ---------- */
  @media (max-width:860px){
    .nav-links a.lnk{display:none}
    .grid,.steps{grid-template-columns:1fr}
    .hero{padding:64px 0 56px}
  }
  @media (max-width:480px){
    .btn-ghost.hide-sm{display:none}
    .hero-cta .btn{width:100%}
  }
</style>
</head>
<body>
<div class="bg-wrap" aria-hidden="true">
  <div class="blob b1"></div>
  <div class="blob b2"></div>
  <div class="blob b3"></div>
</div>
<!-- Navbar -->
<header class="nav">
  <div class="container nav-inner">
    <a href="${pageContext.request.contextPath}/" class="logo">CareerAssist</a>
    <nav class="nav-links">
      <a href="#features" class="lnk">Features</a>
      <a href="#how" class="lnk">How it Works</a>
    </nav>
   <div class="nav-actions">

  <a href="${pageContext.request.contextPath}/auth?role=STUDENT"
     class="btn btn-ghost hide-sm">
    Login
  </a>

  <a href="${pageContext.request.contextPath}/auth?action=signup&role=STUDENT"
     class="btn btn-primary">
    Get Started
  </a>

</div>
  </div>
</header>
<!-- Hero -->
<section class="hero">
  <div class="container">
    <span class="pill">Stop applying blindly — let AI guide your caree</span>
    <h1>Land your dream job with <span class="accent">AI guidance</span></h1>
    <p>CareerAssist analyzes your resume, matches you to the right roles, and shows exactly what to learn next — so you spend less time applying and more time interviewing.</p>
    <div class="hero-cta">
      <a href="${pageContext.request.contextPath}/auth?action=signup&role=STUDENT" class="btn btn-primary btn-lg">Get Started Free →</a>
      <a href="#features" class="btn btn-ghost btn-lg">See How It Works</a>
    </div>
  </div>
</section>
<!-- Features -->
<section id="features" class="features">
  <div class="container">
    <div class="section-head">
      <div class="eyebrow">Features</div>
      <h2>Everything you need to get hired</h2>
    </div>
    <div class="grid">
      <article class="card">
        <div class="icon-badge">📄</div>
        <h3>AI Resume Scoring</h3>
        <p>Get an instant score and actionable feedback to make your resume stand out to recruiters and ATS systems.</p>
      </article>
      <article class="card">
        <div class="icon-badge">🎯</div>
        <h3>Smart Job Matching</h3>
        <p>Our AI pairs your skills and goals with roles that actually fit — no more endless scrolling.</p>
      </article>
      <article class="card">
        <div class="icon-badge">📈</div>
        <h3>Skill Gap Analysis</h3>
        <p>See the exact skills you’re missing for your target role and a clear learning path to close the gap.</p>
      </article>
    </div>
  </div>
</section>
<!-- How it Works -->
<section id="how" class="how">
  <div class="container">
    <div class="section-head">
      <div class="eyebrow">How it Works</div>
      <h2>Three steps to your next role</h2>
    </div>
    <div class="steps">
      <div class="step">
        <h4>Upload your resume</h4>
        <p>Drop in your CV and let our AI parse your experience in seconds.</p>
      </div>
      <div class="step">
        <h4>Get AI insights</h4>
        <p>Receive a resume score, job matches, and a personalized skill roadmap.</p>
      </div>
      <div class="step">
        <h4>Apply with confidence</h4>
        <p>Track applications and improve as you go with continuous AI feedback.</p>
      </div>
    </div>
  </div>
</section>
<footer>
  <div class="container">© <%= java.time.Year.now() %> CareerAssist. All rights reserved.</div>
</footer>
</body>
</html>

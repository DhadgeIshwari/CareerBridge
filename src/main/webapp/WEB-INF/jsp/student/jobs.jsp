<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,com.careerassist.model.*" %>
<!DOCTYPE html><html><head><title>Jobs</title><jsp:include page="/WEB-INF/jsp/layout-head.jsp"/></head>
<body><div class="wrap"><jsp:include page="/WEB-INF/jsp/student-nav.jsp"><jsp:param name="action" value="jobs"/></jsp:include>
<main class="main"><h1>Job Listings</h1>
<a href="?action=jobs&seed=1" class="btn btn-sm">Load Sample API/Scraped Jobs</a>
<h3 style="margin:1rem 0">Internal Jobs</h3><div class="grid">
<% List<Job> internal=(List<Job>)request.getAttribute("internal");
if(internal!=null) for(Job j:internal){%><div class="card"><h3><%=j.getTitle()%></h3><p><%=j.getCompany()%></p>
<p class="muted">Use <a href="?action=jobfeed">Job Feed</a> for filtered recommendations with external apply links.</p></div><%}%></div>
</main></div></body></html>

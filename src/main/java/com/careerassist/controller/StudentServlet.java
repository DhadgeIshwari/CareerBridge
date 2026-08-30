package com.careerassist.controller;



import java.io.IOException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;




import com.careerassist.model.ApplyPreview;

import com.careerassist.model.CareerContext;

import com.careerassist.model.CareerRefreshResult;

import com.careerassist.model.ChatResponse;

import com.careerassist.model.Job;

import com.careerassist.model.JobFeedItem;

import com.careerassist.model.ResumeScore;

import com.careerassist.model.LearningItem;

import com.careerassist.model.SkillLearningHub;

import com.careerassist.model.SkillGap;

import com.careerassist.model.Application;
import com.careerassist.model.User;

import com.careerassist.service.CareerService;

import com.careerassist.util.AppUtil;

import com.careerassist.util.AppUtil.SkillChartData;



import com.google.gson.Gson;



import jakarta.servlet.ServletException;

import jakarta.servlet.annotation.MultipartConfig;

import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;

import jakarta.servlet.http.HttpServletRequest;

import jakarta.servlet.http.HttpServletResponse;

import jakarta.servlet.http.Part;



@WebServlet("/student")

@MultipartConfig(maxFileSize = 5242880)

public class StudentServlet extends HttpServlet {

    private final CareerService service = new CareerService();

    private final Gson gson = new Gson();



    @Override

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        User u = AppUtil.getUser(req);

        if (u == null || !"STUDENT".equals(u.getRole())) {

            resp.sendRedirect(req.getContextPath() + "/auth?role=STUDENT");

            return;

        }

        String action = req.getParameter("action");

        if (action == null) action = "dashboard";

        try {

            attachCareerContext(req, u);

            switch (action) {

                case "dashboard" -> loadDashboard(req, u);

                case "skilldev" -> loadSkillDev(req, u);

                case "skillgap" -> loadSkillGap(req, u);

                case "learning" -> {
                    resp.sendRedirect(req.getContextPath() + "/student?action=skilldev");
                    return;
                }

                case "recommend" -> {

                    req.setAttribute("jobs", service.recommendJobs(u.getUserId(), req));

                    req.setAttribute("feed", service.getLiveJobFeed(u.getUserId(), req));

                }

                case "jobs", "jobfeed" -> loadJobFeed(req, u);

                case "chat" -> {

                    req.setAttribute("chat", service.getDao().listChat(u.getUserId()));

                    req.setAttribute("careerContext", service.getContextService().getContext(req, u.getUserId()));

                }

                case "applications" -> req.setAttribute("apps", service.getDao().listApplications(u.getUserId()));

                case "apply" -> {
                    if (!loadApplyPreview(req, u)) {
                        resp.sendRedirect(req.getContextPath() + "/student?action=jobfeed");
                        return;
                    }
                }
                case "job-details" -> {
                    int jobId = Integer.parseInt(req.getParameter("jobId"));
                    Job job = service.getDao().getJob(jobId);
                    req.setAttribute("job", job);
                    
                    List<String> studentSkills = service.getDao().getUserSkills(u.getUserId());
                    List<String> reqSkills = job.getSkills();
                    if (reqSkills == null || reqSkills.isEmpty() && job.getRequirements() != null) {
                        reqSkills = Arrays.stream(job.getRequirements().split(",")).map(String::trim).collect(Collectors.toList());
                    }
                    
                    int matchCount = 0;
                    for (String rSk : reqSkills) {
                        for (String uSk : studentSkills) {
                            if (uSk.equalsIgnoreCase(rSk)) { matchCount++; break; }
                        }
                    }
                    double matchPct = reqSkills.isEmpty() ? 0 : (matchCount * 100.0) / reqSkills.size();
                    
                    List<String> matched = com.careerassist.util.AppUtil.matched(studentSkills, reqSkills);
                    List<String> missing = com.careerassist.util.AppUtil.missing(studentSkills, reqSkills);
                    
                    req.setAttribute("matchPct", matchPct);
                    req.setAttribute("matchedSkills", matched);
                    req.setAttribute("missingSkills", missing);
                }
                case "apply-internal" -> {
                    int jobId = Integer.parseInt(req.getParameter("jobId"));
                    Application app = new Application();
                    app.setUserId(u.getUserId());
                    app.setJobId(jobId);
                    app.setJobSource("INTERNAL");
                    app.setStatus("APPLIED");
                    service.getDao().apply(app);
                    req.getSession().setAttribute("msg", "Successfully applied to internal job!");
                    resp.sendRedirect(req.getContextPath() + "/student?action=jobfeed");
                    return;
                }

                case "applicationSuccess" -> { /* msg via session */ }

                default -> loadDashboard(req, u);

            }

        } catch (Exception e) { req.setAttribute("error", e.getMessage()); }

        String jsp;
        if ("jobs".equals(action) || "jobfeed".equals(action)) {
            jsp = "jobfeed";
        } else if ("dashboard".equals(action) || "skilldev".equals(action) || "chat".equals(action) 
                   || "applications".equals(action) || "apply".equals(action) 
                   || "applicationSuccess".equals(action) || "recommend".equals(action)
                   || "skillgap".equals(action) || "job-details".equals(action)) {
            jsp = action;
        } else {
            jsp = "dashboard";
        }

        req.getRequestDispatcher("/WEB-INF/jsp/student/" + jsp + ".jsp").forward(req, resp);

    }



    @Override

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        User u = AppUtil.getUser(req);

        if (u == null) { resp.sendRedirect(req.getContextPath() + "/auth?role=STUDENT"); return; }

        String action = req.getParameter("action");

        try {

            switch (action) {

                case "deleteResume" -> {
                    String resumeIdStr = req.getParameter("resumeId");
                    if (resumeIdStr != null && !resumeIdStr.isBlank()) {
                        int resumeId = Integer.parseInt(resumeIdStr);
                        String err = service.deleteResume(resumeId, u.getUserId());
                        if (err == null) {
                            req.getSession().setAttribute("msg", "Resume deleted successfully.");
                        } else {
                            req.getSession().setAttribute("error", err);
                        }
                    }
                    resp.sendRedirect(req.getContextPath() + "/student?action=dashboard");
                    return;
                }

                case "resume" -> {

                    String err = service.uploadResume(u.getUserId(), req.getPart("file"), getServletContext().getRealPath("/"));

                    if (err == null) {

                        service.afterResumeUpload(req, u.getUserId());

                        req.getSession().setAttribute("msg", "Resume uploaded — career modules synced to your profile.");

                    } else {

                        req.getSession().setAttribute("msg", err);

                    }

                    resp.sendRedirect(req.getContextPath() + "/student?action=dashboard");

                    return;

                }

                case "setJobRole" -> {

                    String roleOption = req.getParameter("roleOption");

                    if ("1".equals(req.getParameter("ajax"))) {

                        resp.setContentType("application/json;charset=UTF-8");

                        try {

                            CareerRefreshResult result = service.setSelectedJobRole(req, u.getUserId(), roleOption);

                            Map<String, Object> payload = new HashMap<>();

                            payload.put("ok", true);

                            payload.put("message", result.getMessage());

                            payload.put("context", result.getContext());

                            payload.put("gap", result.getGap());

                            payload.put("feedCount", result.getFeed().size());

                            payload.put("learningCount", result.getLearningItemCount());

                            payload.put("redirect", req.getContextPath() + "/student?action=skilldev");

                            resp.getWriter().print(gson.toJson(payload));

                        } catch (Exception ex) {

                            Map<String, Object> err = new HashMap<>();

                            err.put("ok", false);

                            err.put("error", ex.getMessage());

                            resp.getWriter().print(gson.toJson(err));

                        }

                        return;

                    }

                    service.setSelectedJobRole(req, u.getUserId(), roleOption);

                    req.getSession().setAttribute("msg", "Target role updated — skill gap, jobs, and learning path refreshed.");

                    resp.sendRedirect(req.getContextPath() + "/student?action=skilldev");

                    return;

                }

                case "skilldev", "skillgap" -> {

                    String roleOption = req.getParameter("roleOption");

                    if (roleOption != null && !roleOption.isBlank()) {

                        service.setSelectedJobRole(req, u.getUserId(), roleOption);

                    } else {

                        String jid = req.getParameter("jobId");

                        if (jid != null && !jid.isBlank()) {

                            service.setSelectedJobRole(req, u.getUserId(), "job:" + jid);

                        }

                    }

                    resp.sendRedirect(req.getContextPath() + "/student?action=skilldev");

                    return;

                }

                case "learning" -> {

                    service.generateLearningPath(u.getUserId(), req);

                    resp.sendRedirect(req.getContextPath() + "/student?action=skilldev");

                    return;

                }

                case "applyConfirm" -> {

                    String[] resolved = CareerService.resolveApplyParams(

                            req.getParameter("feedType"), req.getParameter("refId"),

                            req.getParameter("source"), req.getParameter("jobId"),

                            req.getParameter("apiId"), req.getParameter("scrapedId"));

                    if (resolved == null) {

                        req.getSession().setAttribute("error", "Invalid job selection.");

                        resp.sendRedirect(req.getContextPath() + "/student?action=jobfeed");

                        return;

                    }

                    String jobTitle = service.submitInternalApplication(

                            u.getUserId(), resolved[0], Integer.parseInt(resolved[1]));

                    req.getSession().setAttribute("msg", "Application tracked: " + jobTitle);

                    resp.sendRedirect(req.getContextPath() + "/student?action=applicationSuccess&job="

                            + java.net.URLEncoder.encode(jobTitle, java.nio.charset.StandardCharsets.UTF_8));

                    return;

                }

                case "apply" -> {

                    String[] resolved = CareerService.resolveApplyParams(

                            req.getParameter("feedType"), req.getParameter("refId"),

                            req.getParameter("source"), req.getParameter("jobId"),

                            req.getParameter("apiId"), req.getParameter("scrapedId"));

                    if (resolved == null) {

                        req.getSession().setAttribute("error", "Could not open apply page.");

                        resp.sendRedirect(req.getContextPath() + "/student?action=jobfeed");

                        return;

                    }

                    resp.sendRedirect(req.getContextPath() + "/student?action=apply&feedType="

                            + resolved[0] + "&refId=" + resolved[1]);

                    return;

                }

                case "refreshFeed" -> {

                    if ("1".equals(req.getParameter("ajax"))) {

                        String message = service.refreshJobFeed(getServletContext(), u.getUserId(), req);

                        List<JobFeedItem> feed = service.getLiveJobFeed(u.getUserId(), req);

                        Map<String, Object> payload = new HashMap<>();

                        payload.put("message", message);

                        payload.put("feed", feed);

                        resp.setContentType("application/json;charset=UTF-8");

                        resp.getWriter().print(gson.toJson(payload));

                        return;

                    }

                }

                case "updateApp" -> {

                    if ("1".equals(req.getParameter("ajax"))) {

                        resp.setContentType("application/json;charset=UTF-8");

                        try {

                            service.updateApplicationStatus(u.getUserId(),

                                    Integer.parseInt(req.getParameter("appId")),

                                    req.getParameter("status"));

                            resp.getWriter().print("{\"ok\":true}");

                        } catch (Exception ex) {

                            resp.getWriter().print("{\"ok\":false,\"error\":\"" + ex.getMessage().replace("\"", "'") + "\"}");

                        }

                        return;

                    }

                }

                case "chat" -> {

                    ChatResponse chatResponse = service.chat(u.getUserId(), req.getParameter("message"), req);

                    if ("1".equals(req.getParameter("ajax"))) {

                        resp.setContentType("application/json;charset=UTF-8");

                        resp.getWriter().print(gson.toJson(chatResponse));

                        return;

                    }

                }

            }

        } catch (Exception e) { req.getSession().setAttribute("error", e.getMessage()); }

        resp.sendRedirect(req.getContextPath() + "/student?action=" + (action != null ? action : "dashboard"));

    }



    private void attachCareerContext(HttpServletRequest req, User u) throws Exception {

        CareerContext ctx = service.getContextService().getContext(req, u.getUserId());

        req.setAttribute("careerContext", ctx);

        req.setAttribute("roleOptions", service.getContextService().listRoleOptions(u.getUserId()));

        // Dynamically compute and attach the overallMatch readiness score so it is correct on all pages
        SkillGap gap = service.getContextSkillGap(u.getUserId(), req);
        double overallMatch = 87.0;
        if (gap != null) {
            overallMatch = Math.round((100.0 - gap.getGapPercentage()) * 10.0) / 10.0;
        }
        req.setAttribute("overallMatch", overallMatch);
        req.getSession().setAttribute("overallMatch", overallMatch);

    }



    private void loadSkillGap(HttpServletRequest req, User u) throws Exception {

        req.setAttribute("gap", service.getContextSkillGap(u.getUserId(), req));

        req.setAttribute("skills", service.getDao().getUserSkills(u.getUserId()));

    }



    private void loadLearning(HttpServletRequest req, User u) throws Exception {

        req.setAttribute("paths", service.getDao().listLearningPaths(u.getUserId()));

        req.setAttribute("hubs", service.getSkillLearningHubs(u.getUserId(), req));

        req.setAttribute("resumeSkills", service.getDao().getUserSkills(u.getUserId()));

    }

    private void loadSkillDev(HttpServletRequest req, User u) throws Exception {
        loadSkillGap(req, u);
        loadLearning(req, u);
    }



    private void loadDashboard(HttpServletRequest req, User u) throws Exception {

        int userId = u.getUserId();

        SkillGap gap = service.getContextSkillGap(userId, req);

        List<String> skills = service.getDao().getUserSkills(userId);

        SkillChartData chart = AppUtil.buildSkillChartData(skills, gap);



        List<Job> matchedJobs = service.recommendJobs(userId, req).stream()

                .filter(j -> j.getMatchPct() > 0)

                .limit(6)

                .toList();



        req.setAttribute("skills", skills);

        req.setAttribute("gap", gap);

        req.setAttribute("matchedJobs", matchedJobs);

        CareerContext ctx = service.getContextService().getContext(req, userId);

        req.setAttribute("userDomain", ctx.getRoleDomain() != null ? ctx.getRoleDomain() : "GENERAL");

        req.setAttribute("chartLabels", gson.toJson(chart.labels));

        req.setAttribute("chartUser", gson.toJson(chart.userScores));

        req.setAttribute("chartRequired", gson.toJson(chart.requiredScores));

        req.setAttribute("overallMatch", chart.overallMatchPct);

        req.setAttribute("hasChart", !chart.labels.isEmpty());



        ResumeScore resumeScore = service.getResumeScore(userId);

        if (resumeScore == null && !skills.isEmpty()) {

            resumeScore = service.calculateAndSaveResumeScore(userId);

        }

        req.setAttribute("resumeScore", resumeScore);

        req.setAttribute("matchDistribution", gson.toJson(service.getMatchDistribution(userId, req)));

        req.setAttribute("topMissing", service.getTopMissingSkills(userId, 6));

        req.setAttribute("recommendedFeed", service.getLiveJobFeed(userId, req).stream().limit(5).toList());

        req.setAttribute("resumes", service.getResumeHistory(userId));

    }



    private boolean loadApplyPreview(HttpServletRequest req, User u) throws Exception {

        String[] resolved = CareerService.resolveApplyParams(

                req.getParameter("feedType"), req.getParameter("refId"),

                req.getParameter("source"), req.getParameter("jobId"),

                req.getParameter("apiId"), req.getParameter("scrapedId"));

        if (resolved == null) return false;

        ApplyPreview preview = service.buildApplyPreview(u.getUserId(),

                resolved[0], Integer.parseInt(resolved[1]));

        if (preview == null) return false;

        req.setAttribute("preview", preview);

        return true;

    }



    private void loadJobFeed(HttpServletRequest req, User u) throws Exception {

        if ("1".equals(req.getParameter("seed"))) {

            service.seedSampleExternalJobs();

        }

        if ("1".equals(req.getParameter("refresh"))) {

            req.setAttribute("feedMessage", service.refreshJobFeed(getServletContext(), u.getUserId(), req));

        }

        req.setAttribute("feed", service.getLiveJobFeed(u.getUserId(), req));

        List<Job> allInternalJobs = service.getDao().listActiveJobs();
        List<String> studentSkills = service.getDao().getUserSkills(u.getUserId());

        // Use the authoritative domain engine — not inline keyword matching
        com.careerassist.model.JobDomain studentDomain =
                com.careerassist.util.AppUtil.detectUserDomain(studentSkills);

        List<Job> recommendedInternal = new ArrayList<>();
        List<Job> exploreInternal = new ArrayList<>();

        for (Job j : allInternalJobs) {
            List<String> reqSkills = j.getSkills();
            if (reqSkills == null || reqSkills.isEmpty() && j.getRequirements() != null) {
                reqSkills = Arrays.stream(j.getRequirements().split(","))
                        .map(String::trim).collect(Collectors.toList());
            }
            if (reqSkills == null || reqSkills.isEmpty()) continue;

            // Gate on JobRelevanceEngine — same filter used by external jobs and recommendations
            if (!com.careerassist.util.JobRelevanceEngine.passesFilter(
                    studentSkills, reqSkills, j.getTitle(), j.getDescription(), studentDomain)) {
                continue;  // Completely exclude — do NOT fall into explore
            }

            double matchPct = com.careerassist.util.AppUtil.matchPercent(studentSkills, reqSkills);
            j.setMatchPct(matchPct);

            if (matchPct >= 70.0) {
                recommendedInternal.add(j);
            } else {
                // Only domain-relevant jobs with some overlap go here
                exploreInternal.add(j);
            }
        }

        recommendedInternal.sort((a, b) -> Double.compare(b.getMatchPct(), a.getMatchPct()));
        exploreInternal.sort((a, b) -> Double.compare(b.getMatchPct(), a.getMatchPct()));

        req.setAttribute("recommendedInternal", recommendedInternal);
        req.setAttribute("exploreInternal", exploreInternal);
        req.setAttribute("skills", studentSkills);
        req.setAttribute("userDomain", studentDomain.name());
    }
}



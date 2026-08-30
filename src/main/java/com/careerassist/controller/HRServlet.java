package com.careerassist.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import com.careerassist.model.Job;
import com.careerassist.model.User;
import com.careerassist.service.CareerService;
import com.careerassist.util.AppUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/hr")
public class HRServlet extends HttpServlet {
    private final CareerService service = new CareerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = AppUtil.getUser(req);
        if (u == null || !"HR".equals(u.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/auth?role=HR");
            return;
        }
        String action = req.getParameter("action");
        if (action == null) action = "dashboard";

        try {
            switch (action) {
                case "dashboard" -> {
                    req.setAttribute("students",          service.getDao().countStudents());
                    req.setAttribute("activeJobs",        service.getDao().countActiveHrJobs(u.getUserId()));
                    req.setAttribute("apps",              service.getDao().countApplications());
                    req.setAttribute("averageAts",        service.getDao().getAverageAtsScore());
                    req.setAttribute("recentCandidates",  service.getDao().getRecentCandidates(5));
                    req.setAttribute("recentJobs",        service.getDao().getRecentJobs(5));
                }
                case "talent-pool" -> {
                    String sk = req.getParameter("skill");
                    java.util.List<User> students = (sk != null && !sk.isBlank())
                        ? service.getDao().searchStudents(sk)
                        : service.getDao().listStudents();
                    req.setAttribute("list", students);
                    // For each student, fetch their ATS score and skills for the talent pool cards
                    java.util.Map<Integer, Integer> atsMap = new java.util.LinkedHashMap<>();
                    java.util.Map<Integer, java.util.List<String>> skillMap = new java.util.LinkedHashMap<>();
                    java.util.Map<Integer, Double> gapMap = new java.util.LinkedHashMap<>();
                    java.util.Map<Integer, String> roleMap = new java.util.LinkedHashMap<>();
                    for (User s : students) {
                        Integer score = service.getDao().getStudentAtsScore(s.getUserId());
                        atsMap.put(s.getUserId(), score);
                        java.util.List<String> skills = service.getDao().getUserSkills(s.getUserId());
                        skillMap.put(s.getUserId(), skills);
                        com.careerassist.model.SkillGap gap = service.getDao().getLatestGap(s.getUserId());
                        gapMap.put(s.getUserId(), gap != null ? Math.max(0, 100.0 - gap.getGapPercentage()) : 0.0);
                        
                        String predictedRole = "Uncategorized";
                        if (skills != null && !skills.isEmpty()) {
                            String skStr = String.join(" ", skills).toLowerCase();
                            if (skStr.contains("java") || skStr.contains("spring")) predictedRole = "Java Developer";
                            else if (skStr.contains("react") || skStr.contains("javascript") || skStr.contains("js") || skStr.contains("frontend")) predictedRole = "Frontend Developer";
                            else if (skStr.contains("node") || skStr.contains("express") || skStr.contains("django") || skStr.contains("backend")) predictedRole = "Backend Developer";
                            else if (skStr.contains("full") && skStr.contains("stack")) predictedRole = "Full Stack Developer";
                            else if (skStr.contains("ccna") || skStr.contains("network")) predictedRole = "Network Engineer";
                            else if (skStr.contains("python") || skStr.contains("sql") || skStr.contains("data") || skStr.contains("analytics")) predictedRole = "Data Analyst";
                            else if (skStr.contains("aws") || skStr.contains("docker") || skStr.contains("devops")) predictedRole = "DevOps Engineer";
                        }
                        roleMap.put(s.getUserId(), predictedRole);
                    }
                    req.setAttribute("atsMap", atsMap);
                    req.setAttribute("skillMap", skillMap);
                    req.setAttribute("gapMap", gapMap);
                    req.setAttribute("roleMap", roleMap);
                }
                case "candidates" -> {
                    String sk = req.getParameter("skill");
                    req.setAttribute("list", sk != null && !sk.isBlank()
                        ? service.getDao().searchStudents(sk)
                        : service.getDao().listStudents());
                    String vid = req.getParameter("view");
                    if (vid != null) {
                        int id = Integer.parseInt(vid);
                        User viewUser = service.getDao().findUserById(id);
                        req.setAttribute("viewUser", viewUser);
                        req.setAttribute("viewSkills", service.getDao().getUserSkills(id));
                        Integer atsScore = service.getDao().getStudentAtsScore(id);
                        req.setAttribute("viewAts", atsScore);
                        // Latest skill gap
                        req.setAttribute("viewGap", service.getDao().getLatestGap(id));
                    }
                }
                case "jobs", "post-job" -> {
                    req.setAttribute("jobs", service.getDao().listHrJobs(u.getUserId()));
                    String eid = req.getParameter("edit");
                    if (eid != null) req.setAttribute("editJob", service.getDao().getJob(Integer.parseInt(eid)));
                }
                case "applications" -> {
                    String statusFilter = req.getParameter("status");
                    java.util.List<com.careerassist.model.Application> allApps =
                        service.getDao().listAllApplications();
                    if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equals(statusFilter)) {
                        final String sf = statusFilter;
                        allApps = allApps.stream()
                            .filter(a -> sf.equals(a.getStatus()))
                            .collect(Collectors.toList());
                    }
                    req.setAttribute("apps", allApps);
                    req.setAttribute("statusFilter", statusFilter != null ? statusFilter : "ALL");
                }
                case "messages" -> {
                    // Placeholder: future messaging system
                    req.setAttribute("msgInfo", "Messaging system coming soon.");
                }
                case "analytics" -> {
                    // Analytics data placeholders
                }
                case "candidate-discovery" -> {
                    java.util.List<User> students = service.getDao().listStudents();
                    req.setAttribute("list", students);
                    java.util.Map<Integer, Integer> atsMap = new java.util.LinkedHashMap<>();
                    java.util.Map<Integer, java.util.List<String>> skillMap = new java.util.LinkedHashMap<>();
                    java.util.Map<Integer, Double> gapMap = new java.util.LinkedHashMap<>();
                    java.util.Map<Integer, String> roleMap = new java.util.LinkedHashMap<>();
                    for (User s : students) {
                        Integer score = service.getDao().getStudentAtsScore(s.getUserId());
                        atsMap.put(s.getUserId(), score);
                        java.util.List<String> skills = service.getDao().getUserSkills(s.getUserId());
                        skillMap.put(s.getUserId(), skills);
                        com.careerassist.model.SkillGap gap = service.getDao().getLatestGap(s.getUserId());
                        gapMap.put(s.getUserId(), gap != null ? Math.max(0, 100.0 - gap.getGapPercentage()) : 0.0);
                        
                        String predictedRole = "Uncategorized";
                        if (skills != null && !skills.isEmpty()) {
                            String skStr = String.join(" ", skills).toLowerCase();
                            if (skStr.contains("java") || skStr.contains("spring")) predictedRole = "Java Developer";
                            else if (skStr.contains("react") || skStr.contains("javascript") || skStr.contains("js") || skStr.contains("frontend")) predictedRole = "Frontend Developer";
                            else if (skStr.contains("node") || skStr.contains("express") || skStr.contains("django") || skStr.contains("backend")) predictedRole = "Backend Developer";
                            else if (skStr.contains("full") && skStr.contains("stack")) predictedRole = "Full Stack Developer";
                            else if (skStr.contains("ccna") || skStr.contains("network")) predictedRole = "Network Engineer";
                            else if (skStr.contains("python") || skStr.contains("sql") || skStr.contains("data") || skStr.contains("analytics")) predictedRole = "Data Analyst";
                            else if (skStr.contains("aws") || skStr.contains("docker") || skStr.contains("devops")) predictedRole = "DevOps Engineer";
                        }
                        roleMap.put(s.getUserId(), predictedRole);
                    }
                    req.setAttribute("atsMap", atsMap);
                    req.setAttribute("skillMap", skillMap);
                    req.setAttribute("gapMap", gapMap);
                    req.setAttribute("roleMap", roleMap);
                }
                case "company-profile" -> {
                    req.setAttribute("hrUser", u);
                    req.setAttribute("jobCount", service.getDao().countJobs());
                }
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
        }

        String jsp = switch (action) {
            case "dashboard", "talent-pool", "candidates", "jobs",
                 "applications", "messages", "company-profile", "analytics", "candidate-discovery" -> action;
            case "post-job" -> "jobs";
            default -> "dashboard";
        };

        req.getRequestDispatcher("/WEB-INF/jsp/hr/" + jsp + ".jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = AppUtil.getUser(req);
        if (u == null) { resp.sendRedirect(req.getContextPath() + "/auth?role=HR"); return; }
        String action = req.getParameter("action");
        try {
            if ("jobs".equals(action)) {
                if ("delete".equals(req.getParameter("sub"))) {
                    service.getDao().deleteJob(Integer.parseInt(req.getParameter("jobId")), u.getUserId());
                } else {
                    Job j = new Job();
                    j.setHrId(u.getUserId());
                    j.setTitle(req.getParameter("title"));
                    j.setCompany(req.getParameter("company"));
                    j.setLocation(req.getParameter("location"));
                    j.setDescription(req.getParameter("description"));
                    j.setRequirements(req.getParameter("requirements"));
                    j.setSalaryRange(req.getParameter("salary"));
                    j.setStatus(req.getParameter("status") != null ? req.getParameter("status") : "ACTIVE");
                    
                    j.setJobType(req.getParameter("jobType"));
                    j.setExperienceLevel(req.getParameter("experienceLevel"));
                    j.setApplicationDeadline(req.getParameter("applicationDeadline"));
                    
                    String sk = req.getParameter("skills");
                    List<String> reqSkillsList = new ArrayList<>();
                    if (sk != null) {
                        reqSkillsList = Arrays.stream(sk.split(",")).map(String::trim).filter(s -> !s.isEmpty()).collect(Collectors.toList());
                        j.setSkills(reqSkillsList);
                    } else if (j.getRequirements() != null) {
                        reqSkillsList = Arrays.stream(j.getRequirements().split(",")).map(String::trim).filter(s -> !s.isEmpty()).collect(Collectors.toList());
                    }
                    
                    String dom = "GENERAL";
                    String skStr = String.join(" ", reqSkillsList).toLowerCase();
                    if (skStr.contains("java") || skStr.contains("spring") || skStr.contains("node") || skStr.contains("backend")) dom = "BACKEND";
                    else if (skStr.contains("react") || skStr.contains("javascript") || skStr.contains("frontend")) dom = "FRONTEND";
                    else if (skStr.contains("full") && skStr.contains("stack")) dom = "FULL_STACK";
                    else if (skStr.contains("ccna") || skStr.contains("network")) dom = "NETWORKING";
                    else if (skStr.contains("python") || skStr.contains("sql") || skStr.contains("data")) dom = "DATA";
                    else if (skStr.contains("aws") || skStr.contains("docker") || skStr.contains("devops")) dom = "DEVOPS";
                    j.setDomain(dom);

                    String jid = req.getParameter("jobId");
                    if (jid != null && !jid.isBlank()) {
                        j.setJobId(Integer.parseInt(jid));
                        service.getDao().updateJob(j);
                    } else {
                        service.getDao().insertJob(j);
                        
                        // Simulate Job Notification Emails
                        System.out.println("====== AUTOMATIC JOB NOTIFICATIONS ======");
                        System.out.println("New Internal Job: " + j.getTitle() + " | Domain: " + dom);
                        List<User> students = service.getDao().listStudents();
                        for (User s : students) {
                            List<String> sSkills = service.getDao().getUserSkills(s.getUserId());
                            String sSkStr = String.join(" ", sSkills).toLowerCase();
                            String sDom = "GENERAL";
                            if (sSkStr.contains("java") || sSkStr.contains("spring") || sSkStr.contains("node") || sSkStr.contains("backend")) sDom = "BACKEND";
                            else if (sSkStr.contains("react") || sSkStr.contains("javascript") || sSkStr.contains("frontend")) sDom = "FRONTEND";
                            else if (sSkStr.contains("full") && sSkStr.contains("stack")) sDom = "FULL_STACK";
                            else if (sSkStr.contains("ccna") || sSkStr.contains("network")) sDom = "NETWORKING";
                            else if (sSkStr.contains("python") || sSkStr.contains("sql") || sSkStr.contains("data")) sDom = "DATA";
                            else if (sSkStr.contains("aws") || sSkStr.contains("docker") || sSkStr.contains("devops")) sDom = "DEVOPS";
                            
                            if (reqSkillsList.size() > 0) {
                                int matchCount = 0;
                                for (String reqSk : reqSkillsList) {
                                    for (String userSk : sSkills) {
                                        if (userSk.equalsIgnoreCase(reqSk)) { matchCount++; break; }
                                    }
                                }
                                double matchPct = (matchCount * 100.0) / reqSkillsList.size();
                                if (matchPct >= 60.0 && sDom.equals(dom)) {
                                    System.out.println(" -> Sending Email to " + s.getEmail() + " | Match: " + String.format("%.0f%%", matchPct));
                                }
                            }
                        }
                        System.out.println("=======================================");
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/hr?action=jobs");
                return;
            }
            if ("applications".equals(action)) {
                service.getDao().updateAppStatus(
                    Integer.parseInt(req.getParameter("appId")),
                    req.getParameter("status")
                );
                resp.sendRedirect(req.getContextPath() + "/hr?action=applications");
                return;
            }
        } catch (Exception e) {
            req.getSession().setAttribute("error", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/hr?action=" + action);
        }
    }
}

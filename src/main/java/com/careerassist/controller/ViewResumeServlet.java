package com.careerassist.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

import com.careerassist.model.Resume;
import com.careerassist.model.User;
import com.careerassist.service.CareerService;
import com.careerassist.util.AppUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/hr/viewResume")
public class ViewResumeServlet extends HttpServlet {
    private final CareerService service = new CareerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = AppUtil.getUser(req);
        if (u == null || !"HR".equals(u.getRole())) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        String userIdParam = req.getParameter("userId");
        if (userIdParam == null || userIdParam.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing userId");
            return;
        }

        int targetUserId = Integer.parseInt(userIdParam);

        try {
            List<Resume> resList = service.getDao().listResumes(targetUserId);
            Resume latestResume = null;
            if (resList != null) {
                for (Resume r : resList) {
                    if (r.isLatest()) {
                        latestResume = r;
                        break;
                    }
                }
                if (latestResume == null && !resList.isEmpty()) {
                    latestResume = resList.get(0);
                }
            }

            if (latestResume == null || latestResume.getFilePath() == null) {
                resp.setContentType("text/plain");
                resp.getWriter().write("No resume uploaded");
                return;
            }

            File file = new File(latestResume.getFilePath());
            if (!file.exists()) {
                resp.setContentType("text/plain");
                resp.getWriter().write("Resume file not found");
                return;
            }

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "inline; filename=\"" + latestResume.getFileName() + "\"");

            try (FileInputStream in = new FileInputStream(file); OutputStream out = resp.getOutputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server Error");
        }
    }
}

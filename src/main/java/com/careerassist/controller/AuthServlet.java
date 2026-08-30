package com.careerassist.controller;

import java.io.IOException;
import java.util.Set;

import com.careerassist.model.User;
import com.careerassist.service.CareerService;
import com.careerassist.util.AppUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {
    private static final Set<String> VALID_ROLES = Set.of("STUDENT", "HR");

    private final CareerService service = new CareerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("logout".equals(req.getParameter("action"))) {
            AppUtil.logout(req);
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        if ("otp".equals(req.getParameter("action"))) {
            req.getRequestDispatcher("/WEB-INF/jsp/hr/otp.jsp").forward(req, resp);
            return;
        }

        String role = normalizeRole(req.getParameter("role"));

        if ("signup".equals(req.getParameter("action"))) {
            req.setAttribute("role", role);
            req.getRequestDispatcher("/WEB-INF/jsp/signup.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("role", role);
        req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String role = normalizeRole(req.getParameter("role"));

        if ("signup".equals(action)) {
            handleSignup(req, resp, role);
            return;
        }

        if ("verifyOtp".equals(action)) {
            handleVerifyOtp(req, resp);
            return;
        }

        handleLogin(req, resp, role);
    }

    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String expectedOtp = (String) session.getAttribute("pendingHrOtp");
        String enteredOtp = req.getParameter("otp");

        if (expectedOtp != null && expectedOtp.equals(enteredOtp)) {
            User u = (User) session.getAttribute("pendingHrUser");
            String password = (String) session.getAttribute("pendingHrPass");
            
            String err = service.register(u, password, password);
            if (err != null) {
                req.setAttribute("error", err);
                req.getRequestDispatcher("/WEB-INF/jsp/hr/otp.jsp").forward(req, resp);
                return;
            }

            session.removeAttribute("pendingHrUser");
            session.removeAttribute("pendingHrPass");
            session.removeAttribute("pendingHrOtp");

            session.setAttribute("authMsg", "Account created successfully! Please sign in.");
            resp.sendRedirect(req.getContextPath() + "/auth?role=HR");
        } else {
            req.setAttribute("error", "Invalid OTP. Please try again.");
            req.getRequestDispatcher("/WEB-INF/jsp/hr/otp.jsp").forward(req, resp);
        }
    }

    private void handleSignup(HttpServletRequest req, HttpServletResponse resp, String role)
            throws ServletException, IOException {
        User u = new User();
        u.setFullName(req.getParameter("fullName"));
        u.setEmail(req.getParameter("email"));
        u.setPhone(req.getParameter("phone"));
        u.setRole(role);

        String password = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");

        String err = service.validateRegistration(u, password, confirm);
        if (err != null) {
            req.setAttribute("error", err);
            req.setAttribute("role", role);
            req.getRequestDispatcher("/WEB-INF/jsp/signup.jsp").forward(req, resp);
            return;
        }

        if ("HR".equals(role)) {
            String otp = String.format("%06d", new java.util.Random().nextInt(999999));
            System.out.println("==================================================");
            System.out.println("OTP for HR Registration (" + u.getEmail() + "): " + otp);
            System.out.println("==================================================");

            HttpSession session = req.getSession(true);
            session.setAttribute("pendingHrUser", u);
            session.setAttribute("pendingHrPass", password);
            session.setAttribute("pendingHrOtp", otp);

            resp.sendRedirect(req.getContextPath() + "/auth?action=otp");
            return;
        }

        err = service.register(u, password, confirm);
        if (err != null) {
            req.setAttribute("error", err);
            req.setAttribute("role", role);
            req.getRequestDispatcher("/WEB-INF/jsp/signup.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("authMsg", "Account created! Please sign in.");
        resp.sendRedirect(req.getContextPath() + "/auth?role=" + role);
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp, String role)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        String err = service.loginWithMessage(email, password, role);
        if (err != null) {
            req.setAttribute("error", err);
            req.setAttribute("role", role);
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
            return;
        }

        User u = service.login(email, password, role);
        if (u == null) {
            req.setAttribute("error", "Invalid email or password.");
            req.setAttribute("role", role);
            req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
            return;
        }

        AppUtil.setUser(req, u);
        if ("HR".equals(u.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/hr?action=dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/student?action=dashboard");
        }
    }

    private static String normalizeRole(String role) {
        if (role == null) return "STUDENT";
        String r = role.trim().toUpperCase();
        return VALID_ROLES.contains(r) ? r : "STUDENT";
    }
}

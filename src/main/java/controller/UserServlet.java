package controller;

import dao.SettingDao;
import dao.UserDao;
import dto.UserDto;
import entity.enums.AuthProvider;
import entity.enums.UserStatus;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import service.UserService;
import util.SessionUtil;

@WebServlet(name = "UserServlet", urlPatterns = {"/users/*"})
public class UserServlet extends HttpServlet {
    private UserService userService;

    @Override
    public void init() throws ServletException {
        this.userService = new UserService(new UserDao(), new SettingDao());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "list";
        processAction(action, req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "save";
        processAction(action, req, resp);
    }

    private void processAction(String action, HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        switch (action) {
            case "list":
                showList(req, resp);
                break;
            case "detail":
                showDetail(req, resp);
                break;
            case "profile":
                showProfile(req, resp);
                break;
            case "save":
                saveUser(req, resp);
                break;
            case "update-profile":
                updateProfile(req, resp);
                break;
            case "change-status":
                changeStatus(req, resp);
                break;
            default:
                showList(req, resp);
                break;
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<UserDto> users = userService.getUsers();
        req.setAttribute("users", users);
        req.getRequestDispatcher("/WEB-INF/views/user/list.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr != null) {
            long userId = Long.parseLong(idStr);
            UserDto user = userService.getUser(userId);
            req.setAttribute("user", user);
        }
        req.getRequestDispatcher("/WEB-INF/views/user/detail.jsp").forward(req, resp);
    }

    private void showProfile(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser != null) {
            UserDto profile = userService.getUser(currentUser.getId());
            req.setAttribute("user", profile);
        }
        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private void saveUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto dto = bindUser(req);
        try {
            userService.saveUser(dto);
            resp.sendRedirect(req.getContextPath() + "/users/list?success=true");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/users/detail?error=" + e.getMessage());
        }
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        UserDto dto = new UserDto();
        dto.setId(currentUser.getId());
        dto.setFullName(req.getParameter("fullName"));
        try {
            userService.updateProfile(dto);
            currentUser.setFullName(dto.getFullName());
            SessionUtil.setCurrentUser(req, currentUser);
            resp.sendRedirect(req.getContextPath() + "/profile?success=true");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/profile?error=" + e.getMessage());
        }
    }

    private void changeStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        String statusStr = req.getParameter("status");
        if (idStr != null && statusStr != null) {
            long id = Long.parseLong(idStr);
            UserStatus status = UserStatus.fromDb(statusStr);
            userService.changeStatus(id, status);
        }
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private UserDto bindUser(HttpServletRequest req) {
        UserDto dto = new UserDto();
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            dto.setId(Long.parseLong(idStr.trim()));
        }
        dto.setUsername(req.getParameter("username"));
        dto.setEmail(req.getParameter("email"));
        dto.setFullName(req.getParameter("fullName"));
        String roleIdStr = req.getParameter("roleId");
        if (roleIdStr != null && !roleIdStr.trim().isEmpty()) {
            dto.setRoleId(Long.parseLong(roleIdStr.trim()));
        }
        String statusStr = req.getParameter("status");
        if (statusStr != null && !statusStr.trim().isEmpty()) {
            dto.setStatus(UserStatus.fromDb(statusStr));
        }
        dto.setAuthProvider(AuthProvider.LOCAL);
        return dto;
    }
}

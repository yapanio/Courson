package controller;

import dto.UserDto;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.time.LocalDate;
import service.ProfileService;
import util.SessionUtil;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/profile/*"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,        // 1MB
        maxFileSize = 15L * 1024L * 1024L,      // 15MB
        maxRequestSize = 20L * 1024L * 1024L    // 20MB
)
public class ProfileServlet extends HttpServlet {

    private ProfileService profileService;

    @Override
    public void init() throws ServletException {
        this.profileService = new ProfileService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        try {
            UserDto profile = profileService.getProfile(currentUser.getId());
            req.setAttribute("user", profile);
            req.getRequestDispatcher("/WEB-INF/views/profile/index.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Lỗi khi tải thông tin hồ sơ: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/profile/index.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            sendJsonResponse(resp, HttpServletResponse.SC_UNAUTHORIZED, false, null, "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.", null);
            return;
        }

        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : req.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "avatar":
                handleUpdateAvatar(req, resp, currentUser);
                break;
            case "update-field":
            case "":
                handleUpdateField(req, resp, currentUser);
                break;
            default:
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, false, null, "Thao tác không được hỗ trợ.", null);
                break;
        }
    }

    private void handleUpdateAvatar(HttpServletRequest req, HttpServletResponse resp, UserDto currentUser)
            throws IOException, ServletException {
        try {
            Part filePart = req.getPart("avatar");
            if (filePart == null || filePart.getSize() == 0) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, false, "avatar", "Vui lòng chọn một file ảnh hợp lệ.", null);
                return;
            }

            String newAvatarUrl = profileService.updateAvatar(currentUser.getId(), filePart);

            // Update session
            currentUser.setAvatarUrl(newAvatarUrl);
            SessionUtil.setCurrentUser(req, currentUser);

            String fullAvatarUrl = req.getContextPath() + newAvatarUrl;
            sendJsonResponse(resp, HttpServletResponse.SC_OK, true, "avatar", "Cập nhật ảnh đại diện thành công!", fullAvatarUrl);
        } catch (IllegalArgumentException | IllegalStateException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, false, "avatar", e.getMessage(), null);
        } catch (Exception e) {
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "avatar", "Lỗi hệ thống khi cập nhật ảnh: " + e.getMessage(), null);
        }
    }

    private void handleUpdateField(HttpServletRequest req, HttpServletResponse resp, UserDto currentUser)
            throws IOException {
        String field = req.getParameter("field");
        String value = req.getParameter("value");

        if (field == null || field.trim().isEmpty()) {
            sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, false, null, "Thiếu trường cần cập nhật.", null);
            return;
        }

        field = field.trim();

        // 1. Strict security check: Email is NEVER allowed to be edited
        if ("email".equalsIgnoreCase(field)) {
            sendJsonResponse(resp, HttpServletResponse.SC_FORBIDDEN, false, "email", "Email là định danh tài khoản cố định, không được phép thay đổi.", null);
            return;
        }

        try {
            switch (field) {
                case "fullName": {
                    String updated = profileService.updateFullName(currentUser.getId(), value);
                    currentUser.setFullName(updated);
                    SessionUtil.setCurrentUser(req, currentUser);
                    sendJsonResponse(resp, HttpServletResponse.SC_OK, true, "fullName", "Cập nhật họ và tên thành công!", updated);
                    break;
                }
                case "username": {
                    String updated = profileService.updateUsername(currentUser.getId(), value);
                    currentUser.setUsername(updated);
                    SessionUtil.setCurrentUser(req, currentUser);
                    sendJsonResponse(resp, HttpServletResponse.SC_OK, true, "username", "Cập nhật tên đăng nhập thành công!", updated);
                    break;
                }
                case "phone": {
                    String updated = profileService.updatePhone(currentUser.getId(), value);
                    currentUser.setPhone(updated);
                    SessionUtil.setCurrentUser(req, currentUser);
                    sendJsonResponse(resp, HttpServletResponse.SC_OK, true, "phone", "Cập nhật số điện thoại thành công!", updated != null ? updated : "");
                    break;
                }
                case "birthDate": {
                    LocalDate updated = profileService.updateBirthDate(currentUser.getId(), value);
                    currentUser.setBirthDate(updated);
                    SessionUtil.setCurrentUser(req, currentUser);
                    String dateStr = updated != null ? updated.toString() : "";
                    sendJsonResponse(resp, HttpServletResponse.SC_OK, true, "birthDate", "Cập nhật ngày sinh thành công!", dateStr);
                    break;
                }
                default:
                    sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, false, field, "Trường cập nhật không hợp lệ: " + field, null);
                    break;
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, false, field, e.getMessage(), null);
        } catch (Exception e) {
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, field, "Lỗi máy chủ khi cập nhật: " + e.getMessage(), null);
        }
    }

    private void sendJsonResponse(HttpServletResponse resp, int status, boolean success, String field, String message, String value) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":").append(success);
        if (field != null) {
            sb.append(",\"field\":\"").append(escapeJson(field)).append("\"");
        }
        if (message != null) {
            sb.append(",\"message\":\"").append(escapeJson(message)).append("\"");
        }
        if (value != null) {
            sb.append(",\"value\":\"").append(escapeJson(value)).append("\"");
        }
        sb.append("}");
        resp.getWriter().write(sb.toString());
    }

    private String escapeJson(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}

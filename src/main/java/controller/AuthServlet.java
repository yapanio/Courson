package controller;

import dao.SettingDao;
import dao.UserDao;
import dto.GoogleAuthResult;
import dto.LoginDto;
import dto.RegisterDto;
import dto.UserDto;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import service.AuthService;
import service.InactiveAccountException;
import util.GoogleOAuthUtil;
import util.SessionUtil;

@WebServlet(name = "AuthServlet", urlPatterns = { "/auth/*" })
public class AuthServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        UserDao userDao = new UserDao();
        SettingDao settingDao = new SettingDao();
        this.authService = new AuthService(userDao, settingDao);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "login";
        processAction(action, req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "login";
        processAction(action, req, resp);
    }

    private void processAction(String action, HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String method = req.getMethod();
        switch (action) {
            case "login":
                if ("POST".equalsIgnoreCase(method)) {
                    login(req, resp);
                } else {
                    showLogin(req, resp);
                }
                break;
            case "register":
                if ("POST".equalsIgnoreCase(method)) {
                    register(req, resp);
                } else {
                    showRegister(req, resp);
                }
                break;
            case "check-email":
                showCheckEmail(req, resp);
                break;
            case "logout":
                logout(req, resp);
                break;
            case "google":
                // Bước 1: Redirect người dùng tới Google để xác thực
                initiateGoogleLogin(req, resp);
                break;
            case "google-callback":
                // Bước 2: Google redirect về đây với ?code=... sau khi người dùng đồng ý
                googleCallback(req, resp);
                break;
            default:
                showLogin(req, resp);
                break;
        }
    }

    private void showLogin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            String flashToastType = (String) session.getAttribute("flashToastType");
            String flashToastMessage = (String) session.getAttribute("flashToastMessage");
            if (flashToastMessage != null) {
                req.setAttribute("toastType", flashToastType != null ? flashToastType : "info");
                req.setAttribute("toastMessage", flashToastMessage);
                session.removeAttribute("flashToastType");
                session.removeAttribute("flashToastMessage");
            }
        }

        // Whitelist check for status query param fallback
        String status = req.getParameter("status");
        if (req.getAttribute("toastMessage") == null && status != null) {
            if ("verified".equals(status)) {
                req.setAttribute("toastType", "success");
                req.setAttribute("toastMessage", "Xác thực tài khoản thành công! Hãy đăng nhập để bắt đầu học tập.");
            } else if ("already".equals(status)) {
                req.setAttribute("toastType", "info");
                req.setAttribute("toastMessage", "Tài khoản đã được xác thực trước đó, hãy đăng nhập.");
            } else if ("invalid".equals(status)) {
                req.setAttribute("toastType", "error");
                req.setAttribute("toastMessage",
                        "Liên kết xác thực không hợp lệ hoặc đã hết hạn. Bạn có thể yêu cầu gửi lại email xác nhận.");
            }
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    private void showRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    private void showCheckEmail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/check-email.jsp").forward(req, resp);
    }

    private void login(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String loginId = req.getParameter("loginId");
        String password = req.getParameter("password");
        boolean rememberMe = "on".equalsIgnoreCase(req.getParameter("rememberMe"));

        LoginDto dto = new LoginDto(loginId, password, rememberMe);
        try {
            UserDto user = authService.authenticate(dto);
            SessionUtil.setCurrentUser(req, user);
            redirectByRole(user, req, resp);
        } catch (InactiveAccountException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("inactiveEmail", e.getEmail());
            req.setAttribute("loginId", loginId);
            showLogin(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("loginId", loginId);
            showLogin(req, resp);
        }
    }

    private String getDynamicBaseUrl(HttpServletRequest req) {
        String scheme = req.getScheme();
        String serverName = req.getServerName();
        int serverPort = req.getServerPort();
        String contextPath = req.getContextPath();
        return scheme + "://" + serverName
                + ((serverPort == 80 || serverPort == 443) ? "" : (":" + serverPort)) + contextPath;
    }

    private void register(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String fullName = req.getParameter("fullName");
        boolean agreeTerms = "on".equalsIgnoreCase(req.getParameter("agreeTerms"));

        RegisterDto dto = new RegisterDto(username, email, password, confirmPassword, fullName, agreeTerms);
        try {
            String dynamicBaseUrl = getDynamicBaseUrl(req);

            authService.register(dto, dynamicBaseUrl);
            String encodedEmail = URLEncoder.encode(dto.getEmail().trim(), StandardCharsets.UTF_8);
            resp.sendRedirect(req.getContextPath() + "/auth/check-email?email=" + encodedEmail);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("registerDto", dto);
            showRegister(req, resp);
        }
    }

    private void logout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        authService.logout(req.getSession(false));
        resp.sendRedirect(req.getContextPath() + "/home");
    }

    /**
     * Bước 1 – Redirect trình duyệt người dùng tới Google OAuth consent screen.
     * Sinh CSRF state token, lưu vào session để xác thực ở callback.
     */
    private void initiateGoogleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!GoogleOAuthUtil.isConfigured()) {
            // Credentials chưa được điền → hiển thị trang login với thông báo lỗi
            HttpSession session = req.getSession(true);
            session.setAttribute("flashToastType", "error");
            session.setAttribute("flashToastMessage",
                "Chức năng đăng nhập Google chưa được cấu hình. Vui lòng liên hệ quản trị viên.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // Tạo CSRF state token để chống CSRF attack
        String state = java.util.UUID.randomUUID().toString();
        HttpSession session = req.getSession(true);
        session.setAttribute("oauth_state", state);

        try {
            String authUrl = GoogleOAuthUtil.buildAuthUrl(state);
            resp.sendRedirect(authUrl);
        } catch (IOException e) {
            session.setAttribute("flashToastType", "error");
            session.setAttribute("flashToastMessage", "Không thể kết nối tới Google. Vui lòng thử lại.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        }
    }

    /**
     * Bước 2 – Google redirect về đây sau khi người dùng đồng ý (hoặc từ chối).
     * Xử lý: xác thực state, đổi code lấy token, lấy user info, đăng nhập/tạo account.
     */
    private void googleCallback(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        String ctx = req.getContextPath();

        // ── Kiểm tra người dùng từ chối đăng nhập Google ──
        String error = req.getParameter("error");
        if (error != null) {
            if (session != null) {
                session.setAttribute("flashToastType", "info");
                session.setAttribute("flashToastMessage", "Bạn đã huỷ đăng nhập bằng Google.");
            }
            resp.sendRedirect(ctx + "/auth/login");
            return;
        }

        // ── Xác thực CSRF state ──
        String returnedState = req.getParameter("state");
        String savedState = (session != null) ? (String) session.getAttribute("oauth_state") : null;
        if (savedState == null || !savedState.equals(returnedState)) {
            if (session != null) {
                session.setAttribute("flashToastType", "error");
                session.setAttribute("flashToastMessage", "Phiên đăng nhập không hợp lệ. Vui lòng thử lại.");
            }
            resp.sendRedirect(ctx + "/auth/login");
            return;
        }
        // Xoá state đã dùng
        if (session != null) {
            session.removeAttribute("oauth_state");
        }

        // ── Lấy authorization code từ Google ──
        String code = req.getParameter("code");
        if (code == null || code.isBlank()) {
            if (session == null) session = req.getSession(true);
            session.setAttribute("flashToastType", "error");
            session.setAttribute("flashToastMessage", "Không nhận được mã xác thực từ Google.");
            resp.sendRedirect(ctx + "/auth/login");
            return;
        }

        try {
            // ── Bước 2a: Đổi code → access token ──
            String accessToken = GoogleOAuthUtil.exchangeCodeForToken(code);

            // ── Bước 2b: Lấy thông tin người dùng từ Google ──
            GoogleOAuthUtil.GoogleUserInfo googleUser = GoogleOAuthUtil.getUserInfo(accessToken);

            if (googleUser.getEmail() == null || googleUser.getEmail().isBlank()) {
                throw new IllegalArgumentException("Không lấy được email từ tài khoản Google.");
            }

            // ── Bước 2c: Đăng nhập hoặc tạo tài khoản ──
            String dynamicBaseUrl = getDynamicBaseUrl(req);
            GoogleAuthResult result = authService.authenticateGoogle(googleUser.getEmail(), googleUser.getName(), dynamicBaseUrl);
            UserDto user = result.getUser();
            SessionUtil.setCurrentUser(req, user);

            if (session == null) session = req.getSession(true);
            if (result.getStatus() == GoogleAuthResult.Status.NEW_USER_CREATED) {
                session.setAttribute("flashToastType", "success");
                session.setAttribute("flashToastMessage",
                    "Đăng nhập Google thành công! Thông tin tài khoản và mật khẩu đã được gửi về Gmail của bạn.");
            } else if (result.getStatus() == GoogleAuthResult.Status.UNVERIFIED_ACTIVATED) {
                session.setAttribute("flashToastType", "success");
                session.setAttribute("flashToastMessage",
                    "Đăng nhập Google thành công! Tài khoản của bạn đã được kích hoạt. Tên đăng nhập và mật khẩu được giữ nguyên như khi đăng ký.");
            } else {
                session.setAttribute("flashToastType", "success");
                session.setAttribute("flashToastMessage", "Đăng nhập bằng Google thành công! Chào mừng bạn quay trở lại.");
            }

            redirectByRole(user, req, resp);

        } catch (Exception e) {
            String msg = e.getMessage();
            if (msg == null || msg.isBlank()) msg = "Đăng nhập bằng Google thất bại. Vui lòng thử lại.";
            if (session == null) session = req.getSession(true);
            session.setAttribute("flashToastType", "error");
            session.setAttribute("flashToastMessage", msg);
            resp.sendRedirect(ctx + "/auth/login");
        }
    }

    private void redirectByRole(UserDto user, HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        if (user == null || user.getRoleName() == null) {
            resp.sendRedirect(ctx + "/home");
            return;
        }

        String role = user.getRoleName();
        if ("ADMIN".equalsIgnoreCase(role) || "ROLE_ADMIN".equalsIgnoreCase(role)) {
            resp.sendRedirect(ctx + "/admin/dashboard");
        } else if ("EXPERT".equalsIgnoreCase(role) || "ROLE_EXPERT".equalsIgnoreCase(role)) {
            resp.sendRedirect(ctx + "/expert/dashboard");
        } else if ("MANAGER".equalsIgnoreCase(role) || "ROLE_MANAGER".equalsIgnoreCase(role)) {
            resp.sendRedirect(ctx + "/manager/dashboard");
        } else if ("INSTRUCTOR".equalsIgnoreCase(role)) {
            resp.sendRedirect(ctx + "/admin/courses");
        } else {
            resp.sendRedirect(ctx + "/home");
        }
    }
}

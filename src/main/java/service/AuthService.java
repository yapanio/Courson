package service;

import dao.SettingDao;
import dao.UserDao;
import dto.GoogleAuthResult;
import dto.LoginDto;
import dto.RegisterDto;
import dto.UserDto;
import entity.Setting;
import entity.User;
import entity.enums.AuthProvider;
import entity.enums.SettingType;
import entity.enums.UserStatus;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import util.DbConnection;
import util.MailUtil;
import util.PasswordUtil;
import util.ValidationUtil;

public class AuthService {

    private final UserDao userDao;
    private final SettingDao settingDao;
    private final EmailVerificationService emailVerificationService;

    public AuthService(UserDao userDao, SettingDao settingDao) {
        this(userDao, settingDao, new EmailVerificationService(new dao.VerificationTokenDao(), userDao));
    }

    public AuthService(UserDao userDao, SettingDao settingDao, EmailVerificationService emailVerificationService) {
        this.userDao = userDao;
        this.settingDao = settingDao;
        this.emailVerificationService = emailVerificationService;
    }

    public UserDto authenticate(LoginDto dto) {
        validateLogin(dto);
        try (Connection con = DbConnection.getConnection()) {
            Optional<User> userOpt = userDao.findByUsernameOrEmail(con, dto.getLoginId().trim());
            if (!userOpt.isPresent()) {
                throw new IllegalArgumentException("Tài khoản hoặc mật khẩu không chính xác.");
            }
            User user = userOpt.get();
            if (user.getStatus() == UserStatus.BANNED) {
                throw new IllegalStateException("Tài khoản của bạn đã bị khóa.");
            }
            if (user.getStatus() == UserStatus.INACTIVE) {
                throw new InactiveAccountException("Tài khoản chưa được kích hoạt. Vui lòng xác thực email của bạn để tiếp tục.", user.getEmail());
            }
            if (!PasswordUtil.verify(dto.getPassword(), user.getPasswordHash())) {
                throw new IllegalArgumentException("Tài khoản hoặc mật khẩu không chính xác.");
            }
            return mapUser(user);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi xác thực hệ thống: " + e.getMessage(), e);
        }
    }

    public UserDto register(RegisterDto dto) {
        return register(dto, null);
    }

    public UserDto register(RegisterDto dto, String dynamicBaseUrl) {
        validateRegistration(dto);
        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                if (userDao.existsUsername(con, dto.getUsername().trim(), null)) {
                    throw new IllegalArgumentException("Tên đăng nhập đã được sử dụng.");
                }
                if (userDao.existsEmail(con, dto.getEmail().trim(), null)) {
                    throw new IllegalArgumentException("Email đã được sử dụng.");
                }

                Setting studentRole = resolveStudentRole();

                User user = new User();
                user.setUsername(dto.getUsername().trim());
                user.setEmail(dto.getEmail().trim());
                user.setPasswordHash(PasswordUtil.hash(dto.getPassword()));
                user.setFullName(dto.getFullName().trim());
                user.setRoleId(studentRole != null ? studentRole.getId() : null);
                user.setRoleType(SettingType.USER_ROLE);
                user.setAuthProvider(AuthProvider.LOCAL);
                user.setStatus(UserStatus.INACTIVE);

                long id = userDao.insert(con, user);
                user.setId(id);

                if (emailVerificationService != null) {
                    emailVerificationService.createAndSendToken(con, user, dynamicBaseUrl);
                }

                con.commit();
                return mapUser(user);
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi đăng ký tài khoản: " + e.getMessage(), e);
        }
    }

    public GoogleAuthResult authenticateGoogle(String email, String name, String dynamicBaseUrl) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email Google không hợp lệ.");
        }
        if (!ValidationUtil.isEmail(email)) {
            throw new IllegalArgumentException("Email Google không đúng định dạng.");
        }
        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // ── 1. Tìm theo email chính xác ──────────────────────────────
                Optional<User> userOpt = userDao.findByEmail(con, email.trim());
                User user;
                GoogleAuthResult.Status authStatus;
                String generatedPassword = null;

                if (userOpt.isPresent()) {
                    // ── 2a. Đã có tài khoản với email này ────────────────────
                    user = userOpt.get();

                    // Kiểm tra tài khoản bị khoá
                    if (user.getStatus() == UserStatus.BANNED) {
                        throw new IllegalStateException("Tài khoản của bạn đã bị khóa.");
                    }

                    // Nếu tài khoản LOCAL nhưng chưa verify (INACTIVE), Google đăng nhập
                    // sẽ tự động kích hoạt luôn (email đã xác thực qua Google)
                    if (user.getStatus() == UserStatus.INACTIVE) {
                        userDao.updateStatus(con, user.getId(), UserStatus.ACTIVE);
                        user.setStatus(UserStatus.ACTIVE);
                        // Vô hiệu hóa các token xác thực email chưa sử dụng trước đó nếu có
                        new dao.VerificationTokenDao().invalidateTokensByUserId(con, user.getId());
                        authStatus = GoogleAuthResult.Status.UNVERIFIED_ACTIVATED;
                    } else {
                        authStatus = GoogleAuthResult.Status.EXISTING_USER;
                    }

                    // Nếu trước đây đăng ký LOCAL, cập nhật auth_provider → GOOGLE
                    if (user.getAuthProvider() == AuthProvider.LOCAL) {
                        updateAuthProviderToGoogle(con, user.getId());
                        user.setAuthProvider(AuthProvider.GOOGLE);
                    }

                } else {
                    // ── 2b. Chưa có tài khoản → tạo mới ─────────────────────
                    Setting studentRole = resolveStudentRole();

                    // Tạo username từ phần trước @ của email (giữ nguyên logic chuẩn)
                    String baseUsername = sanitizeUsername(email.split("@")[0]);
                    String username = resolveUniqueUsername(con, baseUsername);

                    // Tạo mật khẩu ngẫu nhiên bằng SecureRandom thỏa mãn chuẩn validate đăng ký
                    generatedPassword = PasswordUtil.generateSecureRandomPassword();

                    user = new User();
                    user.setUsername(username);
                    user.setEmail(email.trim());
                    user.setPasswordHash(PasswordUtil.hash(generatedPassword));
                    user.setFullName(name != null && !name.trim().isEmpty()
                        ? name.trim()
                        : baseUsername);
                    user.setRoleId(studentRole != null ? studentRole.getId() : null);
                    user.setRoleType(SettingType.USER_ROLE);
                    user.setAuthProvider(AuthProvider.GOOGLE);
                    user.setStatus(UserStatus.ACTIVE); // Google đã verify email rồi
                    long id = userDao.insert(con, user);
                    user.setId(id);

                    authStatus = GoogleAuthResult.Status.NEW_USER_CREATED;
                }

                con.commit();

                // Gửi email thật chứa thông tin tài khoản và mật khẩu sau khi commit thành công
                if (authStatus == GoogleAuthResult.Status.NEW_USER_CREATED && generatedPassword != null) {
                    MailUtil.sendAccountCredentialsEmailAsync(
                        user.getEmail(),
                        user.getFullName(),
                        user.getUsername(),
                        generatedPassword,
                        dynamicBaseUrl
                    );
                }

                return new GoogleAuthResult(mapUser(user), authStatus);
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi đăng nhập Google: " + e.getMessage(), e);
        }
    }

    public UserDto authenticateGoogle(String email, String name) {
        return authenticateGoogle(email, name, null).getUser();
    }

    public void logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
    }

    private void validateLogin(LoginDto dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Thông tin đăng nhập không được để trống.");
        }
        ValidationUtil.requireText(dto.getLoginId(), "Tên đăng nhập hoặc Email");
        ValidationUtil.requireText(dto.getPassword(), "Mật khẩu");
    }

    private void validateRegistration(RegisterDto dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Thông tin đăng ký không được để trống.");
        }

        ValidationUtil.requireText(dto.getFullName(), "Họ và tên");
        if (!ValidationUtil.isValidFullName(dto.getFullName())) {
            throw new IllegalArgumentException("Họ và tên phải từ 3 đến 50 ký tự.");
        }

        ValidationUtil.requireText(dto.getUsername(), "Tên đăng nhập");
        if (!ValidationUtil.isValidUsername(dto.getUsername())) {
            throw new IllegalArgumentException(
                    "Tên đăng nhập phải từ 4–30 ký tự, chỉ gồm chữ cái, số hoặc dấu gạch dưới (_).");
        }

        ValidationUtil.requireText(dto.getEmail(), "Email");
        if (!ValidationUtil.isEmail(dto.getEmail())) {
            throw new IllegalArgumentException("Email không đúng định dạng.");
        }

        ValidationUtil.requireText(dto.getPassword(), "Mật khẩu");
        if (!ValidationUtil.isStrongPassword(dto.getPassword())) {
            throw new IllegalArgumentException(
                    "Mật khẩu phải từ 8–32 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ số và 1 ký tự đặc biệt.");
        }

        // Xác nhận mật khẩu
        if (!dto.getPassword().equals(dto.getConfirmPassword())) {
            throw new IllegalArgumentException("Xác nhận mật khẩu không khớp.");
        }

        if (!dto.isAgreeTerms()) {
            throw new IllegalArgumentException("Bạn phải đồng ý với điều khoản dịch vụ để tiếp tục.");
        }
    }

    private Setting resolveStudentRole() {
        try (Connection con = DbConnection.getConnection()) {
            List<Setting> roles = settingDao.findByType(con, SettingType.USER_ROLE);
            for (Setting r : roles) {
                if ("STUDENT".equalsIgnoreCase(r.getValue()) || "ROLE_STUDENT".equalsIgnoreCase(r.getName())) {
                    return r;
                }
            }
            return !roles.isEmpty() ? roles.get(0) : null;
        } catch (SQLException e) {
            return null;
        }
    }

    /**
     * Cập nhật cột auth_provider của user thành GOOGLE.
     * Dùng khi user đã đăng ký bằng LOCAL sau đó đăng nhập bằng Google cùng email.
     */
    private void updateAuthProviderToGoogle(Connection con, long userId) throws java.sql.SQLException {
        String sql = "UPDATE users SET auth_provider = 'GOOGLE', updated_at = ? WHERE id = ?";
        try (java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, java.time.OffsetDateTime.now());
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    /**
     * Làm sạch phần trước @ của email thành username hợp lệ:
     * chỉ giữ lại chữ cái, số, dấu gạch dưới; tối thiểu 4 ký tự.
     */
    private String sanitizeUsername(String emailPrefix) {
        if (emailPrefix == null) return "user";
        // Thay ký tự không hợp lệ bằng gạch dưới
        String cleaned = emailPrefix.replaceAll("[^a-zA-Z0-9_]", "_");
        // Xoá gạch dưới thừa ở đầu/cuối
        cleaned = cleaned.replaceAll("^_+|_+$", "");
        if (cleaned.isEmpty()) cleaned = "user";
        // Đảm bảo tối thiểu 4 ký tự
        if (cleaned.length() < 4) cleaned = cleaned + "user";
        // Giới hạn tối đa 20 ký tự (để còn chỗ thêm suffix số)
        if (cleaned.length() > 20) cleaned = cleaned.substring(0, 20);
        return cleaned.toLowerCase();
    }

    /**
     * Tìm username chưa bị trùng trong DB.
     * Nếu {@code base} đã tồn tại, thử: base2, base3, ... tới base99.
     */
    private String resolveUniqueUsername(Connection con, String base) throws java.sql.SQLException {
        if (!userDao.existsUsername(con, base, null)) {
            return base;
        }
        for (int i = 2; i <= 9999; i++) {
            String candidate = base + i;
            if (!userDao.existsUsername(con, candidate, null)) {
                return candidate;
            }
        }
        // Fallback cực kỳ hiếm: dùng timestamp
        return base + System.currentTimeMillis();
    }

    private UserDto mapUser(User user) {
        if (user == null) {
            return null;
        }
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setFullName(user.getFullName());
        dto.setRoleId(user.getRoleId());
        dto.setAuthProvider(user.getAuthProvider());
        dto.setStatus(user.getStatus());
        dto.setAvatarUrl(user.getAvatarUrl());
        dto.setPhone(user.getPhone());
        dto.setBirthDate(user.getBirthDate());

        if (user.getRoleId() != null) {
            try (Connection con = DbConnection.getConnection()) {
                settingDao.findById(con, user.getRoleId()).ifPresent(s -> dto.setRoleName(s.getValue()));
            } catch (SQLException ignored) {
            }
        }
        return dto;
    }
}

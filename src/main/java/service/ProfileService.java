package service;

import dao.ProfileDao;
import dao.UserDao;
import dto.UserDto;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;
import util.DbConnection;
import util.ProfileValidator;

public class ProfileService {

    private final ProfileDao profileDao;
    private final UserDao userDao;
    private final File avatarStorageDir;

    public ProfileService() {
        this(new ProfileDao(), new UserDao(), resolveDefaultAvatarDir());
    }

    public ProfileService(ProfileDao profileDao, UserDao userDao, File avatarStorageDir) {
        this.profileDao = profileDao;
        this.userDao = userDao;
        this.avatarStorageDir = avatarStorageDir;
        if (!this.avatarStorageDir.exists()) {
            this.avatarStorageDir.mkdirs();
        }
    }

    public static File resolveDefaultAvatarDir() {
        String envPath = System.getProperty("courson.upload.dir");
        if (envPath != null && !envPath.trim().isEmpty()) {
            return new File(envPath.trim(), "avatars");
        }
        return new File(System.getProperty("user.home"), "courson_uploads" + File.separator + "avatars");
    }

    public File getAvatarStorageDir() {
        return avatarStorageDir;
    }

    public UserDto getProfile(long userId) {
        try (Connection con = DbConnection.getConnection()) {
            Optional<UserDto> profileOpt = profileDao.findProfileById(con, userId);
            if (!profileOpt.isPresent()) {
                throw new IllegalArgumentException("Không tìm thấy thông tin người dùng.");
            }
            return profileOpt.get();
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi CSDL khi lấy thông tin hồ sơ: " + e.getMessage(), e);
        }
    }

    public String updateFullName(long userId, String fullName) {
        String error = ProfileValidator.validateFullName(fullName);
        if (error != null) {
            throw new IllegalArgumentException(error);
        }
        String cleanName = fullName.trim();
        try (Connection con = DbConnection.getConnection()) {
            boolean ok = profileDao.updateFullName(con, userId, cleanName);
            if (!ok) {
                throw new IllegalStateException("Không thể cập nhật họ và tên.");
            }
            return cleanName;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi CSDL khi cập nhật họ và tên: " + e.getMessage(), e);
        }
    }

    public String updateUsername(long userId, String username) {
        String error = ProfileValidator.validateUsername(username);
        if (error != null) {
            throw new IllegalArgumentException(error);
        }
        String cleanUsername = username.trim();
        try (Connection con = DbConnection.getConnection()) {
            if (userDao.existsUsername(con, cleanUsername, userId)) {
                throw new IllegalArgumentException("Tên đăng nhập đã được sử dụng.");
            }
            boolean ok = profileDao.updateUsername(con, userId, cleanUsername);
            if (!ok) {
                throw new IllegalStateException("Không thể cập nhật tên đăng nhập.");
            }
            return cleanUsername;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi CSDL khi cập nhật tên đăng nhập: " + e.getMessage(), e);
        }
    }

    public String updatePhone(long userId, String phone) {
        String error = ProfileValidator.validatePhone(phone);
        if (error != null) {
            throw new IllegalArgumentException(error);
        }
        String normalized = ProfileValidator.normalizePhone(phone);
        try (Connection con = DbConnection.getConnection()) {
            boolean ok = profileDao.updatePhone(con, userId, normalized);
            if (!ok) {
                throw new IllegalStateException("Không thể cập nhật số điện thoại.");
            }
            return normalized;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi CSDL khi cập nhật số điện thoại: " + e.getMessage(), e);
        }
    }

    public LocalDate updateBirthDate(long userId, String birthDateStr) {
        String error = ProfileValidator.validateBirthDate(birthDateStr);
        if (error != null) {
            throw new IllegalArgumentException(error);
        }
        LocalDate birthDate = (birthDateStr != null && !birthDateStr.trim().isEmpty())
                ? LocalDate.parse(birthDateStr.trim()) : null;
        try (Connection con = DbConnection.getConnection()) {
            boolean ok = profileDao.updateBirthDate(con, userId, birthDate);
            if (!ok) {
                throw new IllegalStateException("Không thể cập nhật ngày sinh.");
            }
            return birthDate;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi CSDL khi cập nhật ngày sinh: " + e.getMessage(), e);
        }
    }

    public String updateAvatar(long userId, Part filePart) {
        String error = ProfileValidator.validateAvatar(filePart);
        if (error != null) {
            throw new IllegalArgumentException(error);
        }

        String ext = ProfileValidator.getFileExtension(filePart.getSubmittedFileName());
        String newFileName = UUID.randomUUID().toString() + "." + ext;
        File destinationFile = new File(avatarStorageDir, newFileName);

        try (InputStream in = filePart.getInputStream()) {
            Files.copy(in, destinationFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new RuntimeException("Lỗi lưu file ảnh đại diện: " + e.getMessage(), e);
        }

        String relativeUrl = "/uploads/avatar/" + newFileName;

        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String oldAvatarUrl = profileDao.getAvatarUrl(con, userId);

                boolean ok = profileDao.updateAvatar(con, userId, relativeUrl);
                if (!ok) {
                    throw new IllegalStateException("Không thể cập nhật ảnh đại diện vào cơ sở dữ liệu.");
                }

                con.commit();

                // Delete old local file if present and different
                if (oldAvatarUrl != null && oldAvatarUrl.startsWith("/uploads/avatar/")) {
                    String oldFileName = oldAvatarUrl.substring("/uploads/avatar/".length());
                    File oldFile = new File(avatarStorageDir, oldFileName);
                    if (oldFile.exists() && oldFile.isFile()) {
                        oldFile.delete();
                    }
                }

                return relativeUrl;
            } catch (Exception ex) {
                con.rollback();
                // Clean up newly written file on error
                if (destinationFile.exists()) {
                    destinationFile.delete();
                }
                throw ex;
            }
        } catch (SQLException e) {
            if (destinationFile.exists()) {
                destinationFile.delete();
            }
            throw new RuntimeException("Lỗi CSDL khi lưu ảnh đại diện: " + e.getMessage(), e);
        }
    }
}

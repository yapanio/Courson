package dao;

import entity.User;
import entity.enums.AuthProvider;
import entity.enums.SettingType;
import entity.enums.UserStatus;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class UserDao {
    private static final String SQL_FIND_ALL = "SELECT id, username, email, password_hash, full_name, role_id, role_type, auth_provider, status, created_at, updated_at, avatar_url, phone, birth_date FROM users ORDER BY id DESC";
    private static final String SQL_FIND_BY_ID = "SELECT id, username, email, password_hash, full_name, role_id, role_type, auth_provider, status, created_at, updated_at, avatar_url, phone, birth_date FROM users WHERE id = ?";
    private static final String SQL_FIND_BY_EMAIL = "SELECT id, username, email, password_hash, full_name, role_id, role_type, auth_provider, status, created_at, updated_at, avatar_url, phone, birth_date FROM users WHERE LOWER(email) = LOWER(?)";
    private static final String SQL_FIND_BY_USERNAME_OR_EMAIL = "SELECT id, username, email, password_hash, full_name, role_id, role_type, auth_provider, status, created_at, updated_at, avatar_url, phone, birth_date FROM users WHERE username = ? OR LOWER(email) = LOWER(?)";
    private static final String SQL_EXISTS_USERNAME = "SELECT COUNT(1) FROM users WHERE username = ? AND (? IS NULL OR id != ?)";
    private static final String SQL_EXISTS_EMAIL = "SELECT COUNT(1) FROM users WHERE LOWER(email) = LOWER(?) AND (? IS NULL OR id != ?)";
    private static final String SQL_INSERT = "INSERT INTO users (username, email, password_hash, full_name, role_id, role_type, auth_provider, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id";
    private static final String SQL_UPDATE = "UPDATE users SET full_name = ?, role_id = ?, role_type = ?, status = ?, password_hash = COALESCE(?, password_hash), updated_at = ? WHERE id = ?";
    private static final String SQL_UPDATE_STATUS = "UPDATE users SET status = ?, updated_at = ? WHERE id = ?";

    public List<User> findAll(Connection con) throws SQLException {
        List<User> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_ALL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public Optional<User> findById(Connection con, long id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_ID)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    public List<User> findByRoleId(Connection con, long roleId) throws SQLException {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, username, email, password_hash, full_name, role_id, role_type, auth_provider, status, created_at, updated_at, avatar_url, phone, birth_date FROM users WHERE role_id = ? ORDER BY full_name ASC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public Optional<User> findByUsernameOrEmail(Connection con, String value) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_USERNAME_OR_EMAIL)) {
            ps.setString(1, value);
            ps.setString(2, value);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    /**
     * Tìm user theo email chính xác (case-insensitive).
     * Dùng cho Google OAuth — tránh nhầm với username trùng.
     */
    public Optional<User> findByEmail(Connection con, String email) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_EMAIL)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    /**
     * Tìm ID của Manager đang ACTIVE khả dụng nhất để phân công cho khóa học mới.
     * Thuật toán:
     * 1. Ưu tiên: Manager đang ACTIVE có ít khóa học được phân công nhất (cân bằng tải).
     * 2. Dự phòng 1: Admin đang ACTIVE nếu hệ thống chưa có Manager nào.
     * 3. Dự phòng 2: Bất kỳ người dùng nào đang ACTIVE đầu tiên trong hệ thống.
     */
    public Optional<Long> findDefaultManagerId(Connection con) throws SQLException {
        // 1. Tìm Manager đang ACTIVE có ít khóa học được gán nhất
        String sqlManager = "SELECT u.id FROM users u " +
                            "JOIN settings s ON u.role_id = s.id AND u.role_type = s.type " +
                            "LEFT JOIN courses c ON c.manager_id = u.id " +
                            "WHERE s.type = 'USER_ROLE' AND UPPER(s.value) = 'MANAGER' AND u.status = 'ACTIVE' " +
                            "GROUP BY u.id " +
                            "ORDER BY COUNT(c.id) ASC, u.id ASC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sqlManager);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return Optional.of(rs.getLong("id"));
            }
        }

        // 2. Dự phòng 1: Admin đang ACTIVE
        String sqlAdmin = "SELECT u.id FROM users u " +
                          "JOIN settings s ON u.role_id = s.id AND u.role_type = s.type " +
                          "WHERE s.type = 'USER_ROLE' AND UPPER(s.value) = 'ADMIN' AND u.status = 'ACTIVE' " +
                          "ORDER BY u.id ASC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sqlAdmin);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return Optional.of(rs.getLong("id"));
            }
        }

        // 3. Dự phòng 2: Bất kỳ User nào đang ACTIVE
        String sqlAny = "SELECT id FROM users WHERE status = 'ACTIVE' ORDER BY id ASC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sqlAny);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return Optional.of(rs.getLong("id"));
            }
        }

        return Optional.empty();
    }

    public boolean existsUsername(Connection con, String username, Long excludeId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_EXISTS_USERNAME)) {
            ps.setString(1, username);
            if (excludeId == null) {
                ps.setNull(2, java.sql.Types.BIGINT);
                ps.setNull(3, java.sql.Types.BIGINT);
            } else {
                ps.setLong(2, excludeId);
                ps.setLong(3, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public boolean existsEmail(Connection con, String email, Long excludeId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_EXISTS_EMAIL)) {
            ps.setString(1, email);
            if (excludeId == null) {
                ps.setNull(2, java.sql.Types.BIGINT);
                ps.setNull(3, java.sql.Types.BIGINT);
            } else {
                ps.setLong(2, excludeId);
                ps.setLong(3, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public long insert(Connection con, User entity) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_INSERT)) {
            ps.setString(1, entity.getUsername());
            ps.setString(2, entity.getEmail());
            ps.setString(3, entity.getPasswordHash());
            ps.setString(4, entity.getFullName());
            if (entity.getRoleId() != null) ps.setLong(5, entity.getRoleId());
            else ps.setNull(5, java.sql.Types.BIGINT);
            ps.setString(6, entity.getRoleType() != null ? entity.getRoleType().getDbValue() : SettingType.USER_ROLE.getDbValue());
            ps.setString(7, entity.getAuthProvider() != null ? entity.getAuthProvider().getDbValue() : AuthProvider.LOCAL.getDbValue());
            ps.setString(8, entity.getStatus() != null ? entity.getStatus().getDbValue() : UserStatus.ACTIVE.getDbValue());
            OffsetDateTime now = OffsetDateTime.now();
            ps.setObject(9, entity.getCreatedAt() != null ? entity.getCreatedAt() : now);
            ps.setObject(10, entity.getUpdatedAt() != null ? entity.getUpdatedAt() : now);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    entity.setId(id);
                    return id;
                }
            }
        }
        return 0L;
    }

    public boolean update(Connection con, User entity) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE)) {
            ps.setString(1, entity.getFullName());
            if (entity.getRoleId() != null) ps.setLong(2, entity.getRoleId());
            else ps.setNull(2, java.sql.Types.BIGINT);
            ps.setString(3, entity.getRoleType() != null ? entity.getRoleType().getDbValue() : SettingType.USER_ROLE.getDbValue());
            ps.setString(4, entity.getStatus() != null ? entity.getStatus().getDbValue() : UserStatus.ACTIVE.getDbValue());
            ps.setString(5, entity.getPasswordHash());
            ps.setObject(6, OffsetDateTime.now());
            ps.setLong(7, entity.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(Connection con, long id, UserStatus status) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_STATUS)) {
            ps.setString(1, status.getDbValue());
            ps.setObject(2, OffsetDateTime.now());
            ps.setLong(3, id);
            return ps.executeUpdate() > 0;
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getLong("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        long roleId = rs.getLong("role_id");
        u.setRoleId(rs.wasNull() ? null : roleId);
        u.setRoleType(SettingType.fromDb(rs.getString("role_type")));
        u.setAuthProvider(AuthProvider.fromDb(rs.getString("auth_provider")));
        u.setStatus(UserStatus.fromDb(rs.getString("status")));
        u.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
        u.setUpdatedAt(rs.getObject("updated_at", OffsetDateTime.class));
        u.setAvatarUrl(rs.getString("avatar_url"));
        u.setPhone(rs.getString("phone"));
        java.sql.Date bd = rs.getDate("birth_date");
        u.setBirthDate(bd != null ? bd.toLocalDate() : null);
        return u;
    }
}

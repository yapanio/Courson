package dao;

import dto.UserDto;
import entity.enums.AuthProvider;
import entity.enums.UserStatus;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Optional;

public class ProfileDao {

    private static final String SQL_FIND_PROFILE_BY_ID =
            "SELECT u.id, u.username, u.email, u.full_name, u.role_id, s.value as role_name, "
            + "u.auth_provider, u.status, u.avatar_url, u.phone, u.birth_date "
            + "FROM users u "
            + "LEFT JOIN settings s ON u.role_id = s.id AND u.role_type = s.type "
            + "WHERE u.id = ?";

    private static final String SQL_UPDATE_AVATAR =
            "UPDATE users SET avatar_url = ?, updated_at = NOW() WHERE id = ?";

    private static final String SQL_UPDATE_FULL_NAME =
            "UPDATE users SET full_name = ?, updated_at = NOW() WHERE id = ?";

    private static final String SQL_UPDATE_PHONE =
            "UPDATE users SET phone = ?, updated_at = NOW() WHERE id = ?";

    private static final String SQL_UPDATE_USERNAME =
            "UPDATE users SET username = ?, updated_at = NOW() WHERE id = ?";

    private static final String SQL_UPDATE_BIRTH_DATE =
            "UPDATE users SET birth_date = ?, updated_at = NOW() WHERE id = ?";

    private static final String SQL_GET_AVATAR_URL =
            "SELECT avatar_url FROM users WHERE id = ?";

    public Optional<UserDto> findProfileById(Connection con, long userId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_PROFILE_BY_ID)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    UserDto dto = new UserDto();
                    dto.setId(rs.getLong("id"));
                    dto.setUsername(rs.getString("username"));
                    dto.setEmail(rs.getString("email"));
                    dto.setFullName(rs.getString("full_name"));
                    dto.setRoleId(rs.getLong("role_id"));
                    dto.setRoleName(rs.getString("role_name"));
                    dto.setAuthProvider(AuthProvider.fromDb(rs.getString("auth_provider")));
                    dto.setStatus(UserStatus.fromDb(rs.getString("status")));
                    dto.setAvatarUrl(rs.getString("avatar_url"));
                    dto.setPhone(rs.getString("phone"));
                    Date bDate = rs.getDate("birth_date");
                    dto.setBirthDate(bDate != null ? bDate.toLocalDate() : null);
                    return Optional.of(dto);
                }
            }
        }
        return Optional.empty();
    }

    public boolean updateAvatar(Connection con, long userId, String avatarUrl) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_AVATAR)) {
            ps.setString(1, avatarUrl);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateFullName(Connection con, long userId, String fullName) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_FULL_NAME)) {
            ps.setString(1, fullName);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePhone(Connection con, long userId, String phone) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_PHONE)) {
            ps.setString(1, phone);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateUsername(Connection con, long userId, String username) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_USERNAME)) {
            ps.setString(1, username);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateBirthDate(Connection con, long userId, LocalDate birthDate) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_BIRTH_DATE)) {
            if (birthDate != null) {
                ps.setDate(1, Date.valueOf(birthDate));
            } else {
                ps.setNull(1, java.sql.Types.DATE);
            }
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public String getAvatarUrl(Connection con, long userId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_GET_AVATAR_URL)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("avatar_url");
                }
            }
        }
        return null;
    }
}

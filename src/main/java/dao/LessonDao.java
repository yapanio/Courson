package dao;

import entity.Lesson;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class LessonDao {
    private static final String SQL_FIND_BY_MODULE = "SELECT id, module_id, title, content, video_url, document_url, order_index, is_active, created_at, updated_at FROM lessons WHERE module_id = ? ORDER BY order_index ASC";
    private static final String SQL_FIND_BY_ID = "SELECT id, module_id, title, content, video_url, document_url, order_index, is_active, created_at, updated_at FROM lessons WHERE id = ?";
    private static final String SQL_INSERT = "INSERT INTO lessons (module_id, title, content, video_url, document_url, order_index, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id";
    private static final String SQL_UPDATE = "UPDATE lessons SET module_id = ?, title = ?, content = ?, video_url = ?, document_url = ?, order_index = ?, is_active = ?, updated_at = ? WHERE id = ?";
    private static final String SQL_UPDATE_ACTIVE = "UPDATE lessons SET is_active = ?, updated_at = now() WHERE id = ?";
    private static final String SQL_DELETE = "DELETE FROM lessons WHERE id = ?";

    public List<Lesson> findByModuleId(Connection con, long moduleId) throws SQLException {
        List<Lesson> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_MODULE)) {
            ps.setLong(1, moduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public Optional<Lesson> findById(Connection con, long id) throws SQLException {
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

    public boolean existsOrderIndex(Connection con, long moduleId, int order, Long excludeId) throws SQLException {
        String sql = (excludeId == null)
                ? "SELECT COUNT(1) FROM lessons WHERE module_id = ? AND order_index = ?"
                : "SELECT COUNT(1) FROM lessons WHERE module_id = ? AND order_index = ? AND id != ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, moduleId);
            ps.setInt(2, order);
            if (excludeId != null) {
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

    public long insert(Connection con, Lesson entity) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_INSERT)) {
            ps.setLong(1, entity.getModuleId());
            ps.setString(2, entity.getTitle());
            ps.setString(3, entity.getContent());
            ps.setString(4, entity.getVideoUrl());
            ps.setString(5, entity.getDocumentUrl());
            ps.setInt(6, entity.getOrderIndex());
            ps.setBoolean(7, entity.isActive());
            OffsetDateTime now = OffsetDateTime.now();
            ps.setObject(8, entity.getCreatedAt() != null ? entity.getCreatedAt() : now);
            ps.setObject(9, entity.getUpdatedAt() != null ? entity.getUpdatedAt() : now);

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

    public boolean update(Connection con, Lesson entity) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE)) {
            ps.setLong(1, entity.getModuleId());
            ps.setString(2, entity.getTitle());
            ps.setString(3, entity.getContent());
            ps.setString(4, entity.getVideoUrl());
            ps.setString(5, entity.getDocumentUrl());
            ps.setInt(6, entity.getOrderIndex());
            ps.setBoolean(7, entity.isActive());
            ps.setObject(8, OffsetDateTime.now());
            ps.setLong(9, entity.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateActiveStatus(Connection con, long id, boolean isActive) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_ACTIVE)) {
            ps.setBoolean(1, isActive);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(Connection con, long id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_DELETE)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Lesson mapRow(ResultSet rs) throws SQLException {
        Lesson l = new Lesson();
        l.setId(rs.getLong("id"));
        l.setModuleId(rs.getLong("module_id"));
        l.setTitle(rs.getString("title"));
        l.setContent(rs.getString("content"));
        l.setVideoUrl(rs.getString("video_url"));
        l.setDocumentUrl(rs.getString("document_url"));
        l.setOrderIndex(rs.getInt("order_index"));
        l.setActive(rs.getBoolean("is_active"));
        l.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
        l.setUpdatedAt(rs.getObject("updated_at", OffsetDateTime.class));
        return l;
    }
}

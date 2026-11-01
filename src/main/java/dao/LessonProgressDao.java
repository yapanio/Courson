package dao;

import entity.LessonProgress;
import entity.enums.LessonProgressStatus;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class LessonProgressDao {
    private static final String SQL_FIND_BY_REG = "SELECT id, registration_id, lesson_id, status, completed_at, user_note FROM lesson_progress WHERE registration_id = ?";
    private static final String SQL_FIND_BY_REG_AND_LESSON = "SELECT id, registration_id, lesson_id, status, completed_at, user_note FROM lesson_progress WHERE registration_id = ? AND lesson_id = ?";
    private static final String SQL_UPSERT = "INSERT INTO lesson_progress (registration_id, lesson_id, status, completed_at, user_note, updated_at) VALUES (?, ?, ?, ?, ?, NOW()) "
            + "ON CONFLICT (registration_id, lesson_id) DO UPDATE SET status = EXCLUDED.status, completed_at = EXCLUDED.completed_at, "
            + "user_note = COALESCE(EXCLUDED.user_note, lesson_progress.user_note), updated_at = NOW() RETURNING id";
    private static final String SQL_SAVE_USER_NOTE = "INSERT INTO lesson_progress (registration_id, lesson_id, status, user_note, updated_at) "
            + "VALUES (?, ?, 'IN_PROGRESS', ?, NOW()) "
            + "ON CONFLICT (registration_id, lesson_id) DO UPDATE SET user_note = EXCLUDED.user_note, updated_at = NOW()";
    private static final String SQL_TOUCH_LESSON = "INSERT INTO lesson_progress (registration_id, lesson_id, status, updated_at) "
            + "VALUES (?, ?, 'IN_PROGRESS', NOW()) "
            + "ON CONFLICT (registration_id, lesson_id) DO UPDATE SET updated_at = NOW()";
    private static final String SQL_CALCULATE_PROGRESS = "SELECT "
            + "  (SELECT COUNT(1) FROM lesson_progress lp JOIN lessons l ON lp.lesson_id = l.id WHERE lp.registration_id = r.id AND lp.status = 'COMPLETED' AND l.is_active = true) AS completed_count, "
            + "  (SELECT COUNT(1) FROM lessons l JOIN modules m ON l.module_id = m.id WHERE m.course_id = r.course_id AND l.is_active = true) AS total_count "
            + "FROM registrations r WHERE r.id = ?";

    public List<LessonProgress> findByRegistrationId(Connection con, long registrationId) throws SQLException {
        List<LessonProgress> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_REG)) {
            ps.setLong(1, registrationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public Optional<LessonProgress> findByRegistrationAndLesson(Connection con, long registrationId, long lessonId)
            throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_REG_AND_LESSON)) {
            ps.setLong(1, registrationId);
            ps.setLong(2, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    public long upsert(Connection con, LessonProgress entity) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_UPSERT)) {
            ps.setLong(1, entity.getRegistrationId());
            ps.setLong(2, entity.getLessonId());
            ps.setString(3, entity.getStatus().getDbValue());
            ps.setObject(4, entity.getCompletedAt());
            ps.setString(5, entity.getUserNote());
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

    public void saveUserNote(Connection con, long registrationId, long lessonId, String note) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_SAVE_USER_NOTE)) {
            ps.setLong(1, registrationId);
            ps.setLong(2, lessonId);
            ps.setString(3, note);
            ps.executeUpdate();
        }
    }

    public void touchLesson(Connection con, long registrationId, long lessonId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_TOUCH_LESSON)) {
            ps.setLong(1, registrationId);
            ps.setLong(2, lessonId);
            ps.executeUpdate();
        }
    }

    public BigDecimal calculateProgress(Connection con, long registrationId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_CALCULATE_PROGRESS)) {
            ps.setLong(1, registrationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    long completed = rs.getLong("completed_count");
                    long total = rs.getLong("total_count");
                    if (total > 0) {
                        return BigDecimal.valueOf(completed * 100.0 / total).setScale(2, RoundingMode.HALF_UP);
                    }
                }
            }
        }
        return BigDecimal.ZERO;
    }

    
    public boolean hasProgress(Connection con, long lessonId) throws SQLException {
        String sql = "SELECT 1 FROM lesson_progress WHERE lesson_id = ? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private LessonProgress mapRow(ResultSet rs) throws SQLException {
        LessonProgress lp = new LessonProgress();
        lp.setId(rs.getLong("id"));
        lp.setRegistrationId(rs.getLong("registration_id"));
        lp.setLessonId(rs.getLong("lesson_id"));
        lp.setStatus(LessonProgressStatus.fromDb(rs.getString("status")));
        lp.setCompletedAt(rs.getObject("completed_at", OffsetDateTime.class));
        lp.setUserNote(rs.getString("user_note"));
        return lp;
    }
}

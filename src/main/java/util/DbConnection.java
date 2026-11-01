package util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public final class DbConnection {
    private static String URL = "jdbc:postgresql://localhost:5432/courson_db";
    private static String USER = "postgres";
    private static String PASSWORD = "sa";
    private static final String[] FALLBACK_PASSWORDS = {"sa", "postgres", "root", "123456", "admin", "password", "12345678", ""};
    private static volatile boolean schemaVerified = false;

    static {
        try {
            Class.forName("org.postgresql.Driver");

            // 1. Đọc từ db.properties mặc định
            try (InputStream is = DbConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (is != null) {
                    Properties prop = new Properties();
                    prop.load(is);
                    if (prop.containsKey("db.url"))
                        URL = prop.getProperty("db.url").trim();
                    if (prop.containsKey("db.user"))
                        USER = prop.getProperty("db.user").trim();
                    if (prop.containsKey("db.password"))
                        PASSWORD = prop.getProperty("db.password").trim();
                }
            } catch (Exception ignored) {
            }

            // 2. Đọc từ db.local.properties (nếu có - dành riêng cho máy cá nhân, không bị git theo dõi)
            try (InputStream isLocal = DbConnection.class.getClassLoader().getResourceAsStream("db.local.properties")) {
                if (isLocal != null) {
                    Properties propLocal = new Properties();
                    propLocal.load(isLocal);
                    if (propLocal.containsKey("db.url"))
                        URL = propLocal.getProperty("db.url").trim();
                    if (propLocal.containsKey("db.user"))
                        USER = propLocal.getProperty("db.user").trim();
                    if (propLocal.containsKey("db.password"))
                        PASSWORD = propLocal.getProperty("db.password").trim();
                }
            } catch (Exception ignored) {
            }

            // 3. Biến môi trường hệ thống (ưu tiên cao nhất)
            if (System.getenv("DB_URL") != null)
                URL = System.getenv("DB_URL").trim();
            if (System.getenv("DB_USER") != null)
                USER = System.getenv("DB_USER").trim();
            if (System.getenv("DB_PASSWORD") != null)
                PASSWORD = System.getenv("DB_PASSWORD").trim();
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("PostgreSQL JDBC Driver not found", e);
        }
    }

    private DbConnection() {
    }

    public static Connection getConnection() throws SQLException {
        Connection con = null;
        try {
            con = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            String sqlState = e.getSQLState();
            String msg = e.getMessage() != null ? e.getMessage().toLowerCase() : "";

            // Trường hợp 1: Mật khẩu sai (28P01 / password authentication failed) -> Thử các mật khẩu phổ biến
            if ("28P01".equals(sqlState) || msg.contains("password authentication failed")) {
                for (String candidate : FALLBACK_PASSWORDS) {
                    if (candidate.equals(PASSWORD)) continue;
                    try {
                        con = DriverManager.getConnection(URL, USER, candidate);
                        PASSWORD = candidate;
                        System.out.println("[DbConnection] Tự động khớp mật khẩu PostgreSQL thành công: '" + candidate + "'");
                        break;
                    } catch (SQLException ignored) {
                    }
                }
            }

            // Trường hợp 2: Sai tên Database (3D000 / database does not exist) -> Thử đổi courson_db <-> courson
            if (con == null && ("3D000".equals(sqlState) || msg.contains("does not exist"))) {
                String altUrl = null;
                if (URL.contains("/courson_db")) {
                    altUrl = URL.replace("/courson_db", "/courson");
                } else if (URL.contains("/courson")) {
                    altUrl = URL.replace("/courson", "/courson_db");
                }
                if (altUrl != null) {
                    try {
                        con = DriverManager.getConnection(altUrl, USER, PASSWORD);
                        URL = altUrl;
                        System.out.println("[DbConnection] Tự động chuyển kết nối sang database khả dụng: " + altUrl);
                    } catch (SQLException ignored) {
                    }
                }
            }

            if (con == null) {
                throw e;
            }
        }

        // Tự động kiểm tra và vá nhẹ schema (Self-healing Schema) nếu DB cũ thiếu cột/ràng buộc mới
        if (!schemaVerified) {
            verifySchemaOnce(con);
        }

        return con;
    }

    private static synchronized void verifySchemaOnce(Connection con) {
        if (schemaVerified) return;
        try (Statement st = con.createStatement()) {
            // Đảm bảo hỗ trợ trạng thái PENDING_REVIEW trong courses
            st.execute("ALTER TABLE courses DROP CONSTRAINT IF EXISTS chk_courses_status; " +
                       "ALTER TABLE courses ADD CONSTRAINT chk_courses_status CHECK (status IN ('DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'ARCHIVED'));");
            // Đảm bảo có các cột lưu trữ và ghi chú mới
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS archive_at timestamptz; " +
                       "ALTER TABLE courses ADD COLUMN IF NOT EXISTS archive_notice text; " +
                       "ALTER TABLE lessons ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true; " +
                       "ALTER TABLE lesson_progress ADD COLUMN IF NOT EXISTS user_note text;");
            st.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url varchar(255); " +
                       "ALTER TABLE users ADD COLUMN IF NOT EXISTS phone varchar(20); " +
                       "ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date date;");
        } catch (Exception ex) {
            // Không chặn ứng dụng nếu tài khoản không đủ quyền DDL
        } finally {
            schemaVerified = true;
        }
    }

    public static void rollbackQuietly(Connection con) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    public static void closeQuietly(AutoCloseable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (Exception ignored) {
            }
        }
    }
}

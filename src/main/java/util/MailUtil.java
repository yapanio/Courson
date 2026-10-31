package util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class MailUtil {

    private static final Logger LOGGER = Logger.getLogger(MailUtil.class.getName());
    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(4, r -> {
        Thread t = new Thread(r, "CoursonMailWorker");
        t.setDaemon(true);
        return t;
    });

    private static String SMTP_HOST = "smtp.gmail.com";
    private static String SMTP_PORT = "587";
    private static String SMTP_USERNAME = "";
    private static String SMTP_PASSWORD = "";
    private static String FROM_NAME = "Courson LMS";
    private static String APP_BASE_URL = "http://localhost:8080/Courson";

    static {
        loadConfig();
    }

    private MailUtil() {
    }

    private static void loadConfig() {
        try (InputStream is = MailUtil.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (is != null) {
                Properties prop = new Properties();
                prop.load(is);
                if (prop.containsKey("mail.smtp.host")) SMTP_HOST = prop.getProperty("mail.smtp.host").trim();
                if (prop.containsKey("mail.smtp.port")) SMTP_PORT = prop.getProperty("mail.smtp.port").trim();
                if (prop.containsKey("mail.smtp.username")) SMTP_USERNAME = prop.getProperty("mail.smtp.username").trim();
                if (prop.containsKey("mail.smtp.password")) SMTP_PASSWORD = prop.getProperty("mail.smtp.password").trim();
                if (prop.containsKey("mail.from.name")) FROM_NAME = prop.getProperty("mail.from.name").trim();
                if (prop.containsKey("app.base.url")) APP_BASE_URL = prop.getProperty("app.base.url").trim();
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Không thể đọc mail.properties, sử dụng cấu hình mặc định", e);
        }

        // Environment variable overrides
        if (System.getenv("MAIL_SMTP_HOST") != null) SMTP_HOST = System.getenv("MAIL_SMTP_HOST").trim();
        if (System.getenv("MAIL_SMTP_PORT") != null) SMTP_PORT = System.getenv("MAIL_SMTP_PORT").trim();
        if (System.getenv("MAIL_SMTP_USERNAME") != null) SMTP_USERNAME = System.getenv("MAIL_SMTP_USERNAME").trim();
        if (System.getenv("MAIL_SMTP_PASSWORD") != null) SMTP_PASSWORD = System.getenv("MAIL_SMTP_PASSWORD").trim();
        if (System.getenv("MAIL_FROM_NAME") != null) FROM_NAME = System.getenv("MAIL_FROM_NAME").trim();
        if (System.getenv("APP_BASE_URL") != null) APP_BASE_URL = System.getenv("APP_BASE_URL").trim();

        // Remove any spaces if provided as 4-word Google App password
        if (SMTP_PASSWORD != null) {
            SMTP_PASSWORD = SMTP_PASSWORD.replace(" ", "");
        }
    }

    public static String getAppBaseUrl() {
        return APP_BASE_URL;
    }

    /**
     * Sends verification email asynchronously.
     */
    public static void sendVerificationEmailAsync(String toEmail, String fullName, String rawToken, String dynamicBaseUrl) {
        EXECUTOR.submit(() -> {
            try {
                sendVerificationEmailSync(toEmail, fullName, rawToken, dynamicBaseUrl);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Lỗi khi gửi email xác thực bất đồng bộ tới: " + toEmail, e);
            }
        });
    }

    /**
     * Synchronous mail sending logic for verification.
     */
    public static void sendVerificationEmailSync(String toEmail, String fullName, String rawToken, String dynamicBaseUrl)
            throws MessagingException {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            LOGGER.warning("Địa chỉ email nhận không hợp lệ, bỏ qua gửi mail.");
            return;
        }

        if (SMTP_USERNAME == null || SMTP_USERNAME.isEmpty() || SMTP_PASSWORD == null || SMTP_PASSWORD.isEmpty()) {
            LOGGER.severe("Chưa cấu hình tài khoản SMTP (username hoặc password rỗng). Vui lòng kiểm tra mail.properties.");
            return;
        }

        String baseUrl = (dynamicBaseUrl != null && !dynamicBaseUrl.trim().isEmpty()) ? dynamicBaseUrl : APP_BASE_URL;
        if (baseUrl.endsWith("/")) {
            baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
        }
        String verificationUrl = baseUrl + "/verify?token=" + rawToken;

        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");

        if ("465".equals(SMTP_PORT)) {
            props.put("mail.smtp.ssl.enable", "true");
        } else {
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        }

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        try {
            message.setFrom(new InternetAddress(SMTP_USERNAME, FROM_NAME, StandardCharsets.UTF_8.name()));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail.trim()));
            message.setSubject("Xác thực tài khoản Courson LMS", StandardCharsets.UTF_8.name());

            String htmlBody = buildVerificationEmailHtml(fullName != null ? fullName : "Học viên", verificationUrl);
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            LOGGER.info("Đã gửi email xác thực thành công tới: " + toEmail);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Gửi email xác thực thất bại tới: " + toEmail, e);
            throw new MessagingException("Gửi email thất bại: " + e.getMessage(), e);
        }
    }

    /**
     * Sends account credentials (username & generated password) asynchronously.
     */
    public static void sendAccountCredentialsEmailAsync(String toEmail, String fullName, String username, String rawPassword, String dynamicBaseUrl) {
        EXECUTOR.submit(() -> {
            try {
                sendAccountCredentialsEmailSync(toEmail, fullName, username, rawPassword, dynamicBaseUrl);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Lỗi khi gửi email thông tin tài khoản bất đồng bộ tới: " + toEmail, e);
            }
        });
    }

    /**
     * Synchronous mail sending logic for account credentials.
     */
    public static void sendAccountCredentialsEmailSync(String toEmail, String fullName, String username, String rawPassword, String dynamicBaseUrl)
            throws MessagingException {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            LOGGER.warning("Địa chỉ email nhận không hợp lệ, bỏ qua gửi mail.");
            return;
        }

        if (SMTP_USERNAME == null || SMTP_USERNAME.isEmpty() || SMTP_PASSWORD == null || SMTP_PASSWORD.isEmpty()) {
            LOGGER.severe("Chưa cấu hình tài khoản SMTP (username hoặc password rỗng). Vui lòng kiểm tra mail.properties.");
            return;
        }

        String baseUrl = (dynamicBaseUrl != null && !dynamicBaseUrl.trim().isEmpty()) ? dynamicBaseUrl : APP_BASE_URL;
        if (baseUrl.endsWith("/")) {
            baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
        }
        String loginUrl = baseUrl + "/auth/login";

        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");

        if ("465".equals(SMTP_PORT)) {
            props.put("mail.smtp.ssl.enable", "true");
        } else {
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        }

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        try {
            message.setFrom(new InternetAddress(SMTP_USERNAME, FROM_NAME, StandardCharsets.UTF_8.name()));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail.trim()));
            message.setSubject("Thông tin tài khoản đăng nhập Courson LMS", StandardCharsets.UTF_8.name());

            String displayName = fullName != null && !fullName.trim().isEmpty() ? fullName.trim() : username;
            String htmlBody = buildAccountCredentialsEmailHtml(displayName, username, rawPassword, loginUrl);
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            LOGGER.info("Đã gửi email thông tin tài khoản thành công tới: " + toEmail);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Gửi email thông tin tài khoản thất bại tới: " + toEmail, e);
            throw new MessagingException("Gửi email thất bại: " + e.getMessage(), e);
        }
    }

    private static String buildVerificationEmailHtml(String displayName, String verificationUrl) {
        return "<!DOCTYPE html>"
                + "<html lang=\"vi\">"
                + "<head>"
                + "<meta charset=\"UTF-8\">"
                + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
                + "<title>Xác thực tài khoản Courson LMS</title>"
                + "</head>"
                + "<body style=\"margin:0;padding:0;background-color:#F5EFEB;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#1F1F20;\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"table-layout:fixed;background-color:#F5EFEB;padding:40px 10px;\">"
                + "  <tr>"
                + "    <td align=\"center\">"
                + "      <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width:580px;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,0.06);border:1px solid #E5DFD7;\">"
                + "        <!-- Header / Logo -->"
                + "        <tr>"
                + "          <td style=\"background:#1F1F20;padding:32px 40px;text-align:center;\">"
                + "            <div style=\"display:inline-flex;align-items:center;gap:10px;\">"
                + "              <span style=\"display:inline-block;width:38px;height:38px;background:linear-gradient(135deg,#F38020,#FF9D42);border-radius:10px;text-align:center;line-height:38px;font-size:22px;\">☁️</span>"
                + "              <span style=\"font-size:22px;font-weight:800;letter-spacing:0.5px;color:#ffffff;\">COURSON<span style=\"color:#F38020;\">.LMS</span></span>"
                + "            </div>"
                + "          </td>"
                + "        </tr>"
                + "        <!-- Body -->"
                + "        <tr>"
                + "          <td style=\"padding:40px 40px 32px 40px;\">"
                + "            <h2 style=\"margin:0 0 16px 0;font-size:22px;font-weight:700;color:#1F1F20;\">Kích hoạt tài khoản của bạn</h2>"
                + "            <p style=\"margin:0 0 16px 0;font-size:15px;line-height:1.6;color:#555555;\">"
                + "              Xin chào <strong>" + escapeHtml(displayName) + "</strong>,"
                + "            </p>"
                + "            <p style=\"margin:0 0 24px 0;font-size:15px;line-height:1.6;color:#555555;\">"
                + "              Cảm ơn bạn đã đăng ký tài khoản tại <strong>Courson LMS</strong>. Vui lòng bấm vào nút bên dưới để hoàn tất xác thực email và bắt đầu hành trình học tập:"
                + "            </p>"
                + "            <!-- CTA Button -->"
                + "            <div style=\"text-align:center;margin:32px 0;\">"
                + "              <a href=\"" + verificationUrl + "\" target=\"_blank\" style=\"display:inline-block;background:linear-gradient(135deg,#F38020,#E56B00);color:#ffffff;text-decoration:none;font-size:16px;font-weight:700;padding:14px 36px;border-radius:10px;box-shadow:0 6px 18px rgba(243,128,32,0.35);letter-spacing:0.3px;\">"
                + "                Xác thực tài khoản"
                + "              </a>"
                + "            </div>"
                + "            <!-- Expiration & Security notes -->"
                + "            <div style=\"background:#FFF8F0;border-left:4px solid #F38020;padding:12px 16px;border-radius:6px;margin:24px 0;\">"
                + "              <p style=\"margin:0;font-size:13.5px;color:#A24E00;line-height:1.5;\">"
                + "                ⏰ <strong>Lưu ý:</strong> Link xác thực này có hiệu lực trong vòng <strong>24 giờ</strong> và chỉ sử dụng được 1 lần."
                + "              </p>"
                + "            </div>"
                + "            <p style=\"margin:0;font-size:13px;color:#999999;line-height:1.5;font-style:italic;\">"
                + "              Nếu bạn không đăng ký tài khoản này, vui lòng bỏ qua email. Tài khoản sẽ tự động hết hạn."
                + "            </p>"
                + "          </td>"
                + "        </tr>"
                + "        <!-- Footer -->"
                + "        <tr>"
                + "          <td style=\"background:#FAF8F5;border-top:1px solid #ECE7E1;padding:20px 40px;text-align:center;\">"
                + "            <p style=\"margin:0;font-size:12px;color:#999999;\">"
                + "              © " + java.time.Year.now().getValue() + " Courson LMS. Mọi quyền được bảo lưu."
                + "            </p>"
                + "          </td>"
                + "        </tr>"
                + "      </table>"
                + "    </td>"
                + "  </tr>"
                + "</table>"
                + "</body>"
                + "</html>";
    }

    private static String buildAccountCredentialsEmailHtml(String displayName, String username, String rawPassword, String loginUrl) {
        return "<!DOCTYPE html>"
                + "<html lang=\"vi\">"
                + "<head>"
                + "<meta charset=\"UTF-8\">"
                + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
                + "<title>Thông tin tài khoản Courson LMS</title>"
                + "</head>"
                + "<body style=\"margin:0;padding:0;background-color:#F5EFEB;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#1F1F20;\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"table-layout:fixed;background-color:#F5EFEB;padding:40px 10px;\">"
                + "  <tr>"
                + "    <td align=\"center\">"
                + "      <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width:580px;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,0.06);border:1px solid #E5DFD7;\">"
                + "        <!-- Header / Logo -->"
                + "        <tr>"
                + "          <td style=\"background:#1F1F20;padding:32px 40px;text-align:center;\">"
                + "            <div style=\"display:inline-flex;align-items:center;gap:10px;\">"
                + "              <span style=\"display:inline-block;width:38px;height:38px;background:linear-gradient(135deg,#F38020,#FF9D42);border-radius:10px;text-align:center;line-height:38px;font-size:22px;\">☁️</span>"
                + "              <span style=\"font-size:22px;font-weight:800;letter-spacing:0.5px;color:#ffffff;\">COURSON<span style=\"color:#F38020;\">.LMS</span></span>"
                + "            </div>"
                + "          </td>"
                + "        </tr>"
                + "        <!-- Body -->"
                + "        <tr>"
                + "          <td style=\"padding:40px 40px 32px 40px;\">"
                + "            <h2 style=\"margin:0 0 16px 0;font-size:22px;font-weight:700;color:#1F1F20;\">Thông tin tài khoản của bạn</h2>"
                + "            <p style=\"margin:0 0 16px 0;font-size:15px;line-height:1.6;color:#555555;\">"
                + "              Xin chào <strong>" + escapeHtml(displayName) + "</strong>,"
                + "            </p>"
                + "            <p style=\"margin:0 0 24px 0;font-size:15px;line-height:1.6;color:#555555;\">"
                + "              Bạn vừa đăng nhập vào hệ thống <strong>Courson LMS</strong> bằng tài khoản Google. Dưới đây là thông tin tài khoản và mật khẩu khởi tạo của bạn:"
                + "            </p>"
                + "            <!-- Credentials Box -->"
                + "            <div style=\"background:#FAF8F5;border:1px solid #EAE3DA;border-radius:10px;padding:20px 24px;margin:24px 0;\">"
                + "              <div style=\"margin-bottom:12px;font-size:14px;color:#444444;\">"
                + "                <span style=\"display:inline-block;width:130px;color:#777777;\">Tên đăng nhập:</span>"
                + "                <strong style=\"font-family:monospace;font-size:15px;color:#1F1F20;\">" + escapeHtml(username) + "</strong>"
                + "              </div>"
                + "              <div style=\"margin-bottom:0;font-size:14px;color:#444444;\">"
                + "                <span style=\"display:inline-block;width:130px;color:#777777;\">Mật khẩu:</span>"
                + "                <strong style=\"font-family:monospace;font-size:15px;color:#F38020;background:#FFF0E2;padding:2px 8px;border-radius:4px;\">" + escapeHtml(rawPassword) + "</strong>"
                + "              </div>"
                + "            </div>"
                + "            <!-- CTA Button -->"
                + "            <div style=\"text-align:center;margin:32px 0;\">"
                + "              <a href=\"" + loginUrl + "\" target=\"_blank\" style=\"display:inline-block;background:linear-gradient(135deg,#F38020,#E56B00);color:#ffffff;text-decoration:none;font-size:16px;font-weight:700;padding:14px 36px;border-radius:10px;box-shadow:0 6px 18px rgba(243,128,32,0.35);letter-spacing:0.3px;\">"
                + "                Đăng nhập Courson LMS"
                + "              </a>"
                + "            </div>"
                + "            <!-- Note -->"
                + "            <div style=\"background:#FFF8F0;border-left:4px solid #F38020;padding:12px 16px;border-radius:6px;margin:24px 0;\">"
                + "              <p style=\"margin:0;font-size:13.5px;color:#A24E00;line-height:1.5;\">"
                + "                💡 <strong>Gợi ý:</strong> Bạn có thể sử dụng Tên đăng nhập và Mật khẩu trên để đăng nhập trực tiếp tại trang Đăng nhập hoặc tiếp tục đăng nhập nhanh bằng Google bất cứ lúc nào."
                + "              </p>"
                + "            </div>"
                + "          </td>"
                + "        </tr>"
                + "        <!-- Footer -->"
                + "        <tr>"
                + "          <td style=\"background:#FAF8F5;border-top:1px solid #ECE7E1;padding:20px 40px;text-align:center;\">"
                + "            <p style=\"margin:0;font-size:12px;color:#999999;\">"
                + "              © " + java.time.Year.now().getValue() + " Courson LMS. Mọi quyền được bảo lưu."
                + "            </p>"
                + "          </td>"
                + "        </tr>"
                + "      </table>"
                + "    </td>"
                + "  </tr>"
                + "</table>"
                + "</body>"
                + "</html>";
    }

    private static String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;");
    }
}

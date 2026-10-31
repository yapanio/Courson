package util;

import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Pattern;

public final class ProfileValidator {

    public static final long MAX_AVATAR_SIZE = 15L * 1024L * 1024L; // 15MB

    private static final Set<String> ALLOWED_EXTENSIONS = new HashSet<>(
            Arrays.asList("jpg", "jpeg", "png", "webp")
    );

    private static final Set<String> ALLOWED_MIME_TYPES = new HashSet<>(
            Arrays.asList("image/jpeg", "image/png", "image/webp")
    );

    // Vietnamese phone number regex: accepts 0 or +84, followed by 9 digits with valid network prefixes
    private static final Pattern VN_PHONE_PATTERN = Pattern.compile(
            "^(0|\\+84)(3[2-9]|5[25689]|7[06-9]|8[1-9]|9[0-9])[0-9]{7}$"
    );

    private ProfileValidator() {
    }

    public static String validateFullName(String fullName) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        if (!ValidationUtil.isValidFullName(fullName)) {
            return "Họ và tên phải từ 3 đến 50 ký tự.";
        }
        return null;
    }

    public static String validateUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return "Tên đăng nhập không được để trống.";
        }
        if (!ValidationUtil.isValidUsername(username)) {
            return "Tên đăng nhập phải từ 4-30 ký tự, chỉ gồm chữ cái, số hoặc dấu gạch dưới (_).";
        }
        return null;
    }

    public static String validatePhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return null; // Phone is optional
        }
        String cleaned = phone.trim().replaceAll("\\s+", "");
        if (!VN_PHONE_PATTERN.matcher(cleaned).matches()) {
            return "Số điện thoại không hợp lệ (phải gồm 10 số thuộc các nhà mạng Việt Nam hợp lệ, bắt đầu bằng 0 hoặc +84).";
        }
        return null;
    }

    public static String normalizePhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return null;
        }
        String cleaned = phone.trim().replaceAll("\\s+", "");
        if (cleaned.startsWith("+84")) {
            return "0" + cleaned.substring(3);
        }
        return cleaned;
    }

    public static String validateBirthDate(String birthDateStr) {
        if (birthDateStr == null || birthDateStr.trim().isEmpty()) {
            return null; // Birth date is optional
        }
        try {
            LocalDate birthDate = LocalDate.parse(birthDateStr.trim());
            LocalDate today = LocalDate.now();
            if (birthDate.isAfter(today)) {
                return "Ngày sinh không được ở tương lai.";
            }
            int age = Period.between(birthDate, today).getYears();
            if (age < 10) {
                return "Độ tuổi tối thiểu là 10 tuổi.";
            }
            if (age > 120) {
                return "Độ tuổi không hợp lệ (tối đa 120 tuổi).";
            }
            return null;
        } catch (DateTimeParseException e) {
            return "Ngày sinh không đúng định dạng (YYYY-MM-DD).";
        }
    }

    public static String validateAvatar(Part part) {
        if (part == null || part.getSize() == 0) {
            return "Vui lòng chọn một file ảnh.";
        }

        if (part.getSize() > MAX_AVATAR_SIZE) {
            return "Dung lượng ảnh vượt quá giới hạn 15MB.";
        }

        String submittedFileName = part.getSubmittedFileName();
        if (submittedFileName == null || !submittedFileName.contains(".")) {
            return "Tên file ảnh không hợp lệ.";
        }

        String ext = submittedFileName.substring(submittedFileName.lastIndexOf(".") + 1).toLowerCase();
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            return "Định dạng file không được hỗ trợ. Chỉ chấp nhận JPG, JPEG, PNG, WEBP.";
        }

        String contentType = part.getContentType();
        if (contentType != null && !ALLOWED_MIME_TYPES.contains(contentType.toLowerCase())) {
            return "Loại MIME không hợp lệ: " + contentType;
        }

        // Validate Magic Bytes
        try (InputStream in = part.getInputStream()) {
            byte[] header = new byte[12];
            int bytesRead = in.read(header);
            if (bytesRead < 4) {
                return "File ảnh bị lỗi hoặc không thể đọc được.";
            }

            if (!isImageMagicBytes(header, bytesRead)) {
                return "Nội dung file không phải là ảnh hợp lệ (chữ ký nhị phân không khớp).";
            }
        } catch (IOException e) {
            return "Lỗi khi đọc file ảnh: " + e.getMessage();
        }

        return null;
    }

    public static boolean isImageMagicBytes(byte[] header, int length) {
        if (length >= 3 && (header[0] & 0xFF) == 0xFF && (header[1] & 0xFF) == 0xD8 && (header[2] & 0xFF) == 0xFF) {
            // JPEG: FF D8 FF
            return true;
        }
        if (length >= 8 && (header[0] & 0xFF) == 0x89
                && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47
                && header[4] == 0x0D && header[5] == 0x0A && header[6] == 0x1A && header[7] == 0x0A) {
            // PNG: 89 50 4E 47 0D 0A 1A 0A
            return true;
        }
        if (length >= 12 && header[0] == 'R' && header[1] == 'I' && header[2] == 'F' && header[3] == 'F'
                && header[8] == 'W' && header[9] == 'E' && header[10] == 'B' && header[11] == 'P') {
            // WEBP: RIFF....WEBP
            return true;
        }
        return false;
    }

    public static String getFileExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return "jpg";
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
    }
}

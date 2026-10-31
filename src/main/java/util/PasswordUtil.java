package util;

import java.security.SecureRandom;
import org.mindrot.jbcrypt.BCrypt;

public final class PasswordUtil {
    private static final int WORK_FACTOR = 12;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private static final String UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    private static final String LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
    private static final String DIGITS = "0123456789";
    private static final String SPECIAL = "!@#$%^&*()-_=+";
    private static final String ALL_CHARS = UPPERCASE + LOWERCASE + DIGITS + SPECIAL;

    private PasswordUtil() {
    }

    public static String hash(String rawPassword) {
        if (rawPassword == null) {
            throw new IllegalArgumentException("Password cannot be null");
        }
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt(WORK_FACTOR));
    }

    public static boolean verify(String rawPassword, String passwordHash) {
        if (rawPassword == null || passwordHash == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(rawPassword, passwordHash);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Generates a cryptographically strong random password using SecureRandom.
     * Guaranteed to satisfy registration password validation requirements:
     * - Length between 8 and 32 characters (default 12)
     * - At least 1 uppercase letter
     * - At least 1 lowercase letter
     * - At least 1 numerical digit
     * - At least 1 special character
     */
    public static String generateSecureRandomPassword() {
        int length = 12;
        while (true) {
            StringBuilder sb = new StringBuilder(length);
            // Ensure at least one character from each mandatory class
            sb.append(UPPERCASE.charAt(SECURE_RANDOM.nextInt(UPPERCASE.length())));
            sb.append(LOWERCASE.charAt(SECURE_RANDOM.nextInt(LOWERCASE.length())));
            sb.append(DIGITS.charAt(SECURE_RANDOM.nextInt(DIGITS.length())));
            sb.append(SPECIAL.charAt(SECURE_RANDOM.nextInt(SPECIAL.length())));

            // Fill the remaining length with characters randomly selected from all classes
            for (int i = 4; i < length; i++) {
                sb.append(ALL_CHARS.charAt(SECURE_RANDOM.nextInt(ALL_CHARS.length())));
            }

            // Shuffle characters using Fisher-Yates shuffle with SecureRandom
            char[] chars = sb.toString().toCharArray();
            for (int i = chars.length - 1; i > 0; i--) {
                int j = SECURE_RANDOM.nextInt(i + 1);
                char temp = chars[i];
                chars[i] = chars[j];
                chars[j] = temp;
            }

            String candidate = new String(chars);
            if (ValidationUtil.isStrongPassword(candidate)) {
                return candidate;
            }
        }
    }
}

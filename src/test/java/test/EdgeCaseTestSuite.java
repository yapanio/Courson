package test;

import dao.*;
import dto.CourseDto;
import dto.LessonDto;
import dto.ModuleDto;
import dto.UserDto;
import entity.Course;
import entity.Lesson;
import entity.Module;
import entity.enums.CourseStatus;
import service.CourseService;
import util.DbConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EdgeCaseTestSuite {

    private static final CourseDao courseDao = new CourseDao();
    private static final ModuleDao moduleDao = new ModuleDao();
    private static final LessonDao lessonDao = new LessonDao();
    private static final LessonProgressDao lessonProgressDao = new LessonProgressDao();
    private static final RegistrationDao registrationDao = new RegistrationDao();
    private static final CourseService courseService = new CourseService(
            courseDao, moduleDao, lessonDao, lessonProgressDao, registrationDao);

    private static int totalPassed = 0;
    private static int totalFailed = 0;
    private static final List<String> failures = new ArrayList<>();

    public static void main(String[] args) {
        System.out.println("======================================================================");
        System.out.println("       COURSON LMS - TOÀN DIỆN KIỂM THỬ TÍNH NĂNG VÀ EDGE CASES       ");
        System.out.println("======================================================================\n");

        UserDto expertUser = new UserDto();
        expertUser.setId(3L);
        expertUser.setEmail("expert@courson.edu.vn");
        expertUser.setRoleName("Expert");
        expertUser.setRoleId(4L);

        UserDto otherExpert = new UserDto();
        otherExpert.setId(999L);
        otherExpert.setEmail("other@courson.edu.vn");
        otherExpert.setRoleName("Expert");
        otherExpert.setRoleId(4L);

        long testCourseId = 0;
        try {
            // Setup a clean test course
            testCourseId = createTestCourse(expertUser.getId(), "Khóa học Kiểm thử Edge Cases");
            System.out.println("[SETUP] Khởi tạo Khóa học Test ID: " + testCourseId + "\n");

            // CATEGORY 1: "ĐỔ CHƯƠNG" (DIRECTIONAL CHAPTER MOVING)
            testDirectionalMoveEarlierToTarget(testCourseId, expertUser);
            testDirectionalMoveLaterToTarget(testCourseId, expertUser);
            testMoveToEmptyModule(testCourseId, expertUser);
            testMoveWithGapsInExistingOrders(testCourseId, expertUser);
            testRapidConsecutiveMoves(testCourseId, expertUser);

            // CATEGORY 2: DRAG & DROP REORDERING
            testReverseReorderLessons(testCourseId, expertUser);
            testCrossModuleDragAndDrop(testCourseId, expertUser);

            // CATEGORY 3: MODULE & LESSON DELETIONS (HARD VS SOFT)
            testDeleteModuleContainingLessonsBlocked(testCourseId, expertUser);
            testDeleteEmptyModuleSucceeds(testCourseId, expertUser);
            testDeleteLessonDraftCourseHardDelete(testCourseId, expertUser);
            testDeleteLessonPublishedCourseSoftDelete(expertUser);

            // CATEGORY 4: SECURITY & IDOR DEFENSE
            testCrossCourseMoveLessonBlocked(testCourseId, expertUser);
            testIDORCourseOwnershipCheck(testCourseId, otherExpert);

            // CATEGORY 5: LIFECYCLE & STATE MACHINE LOCKS
            testPublishEmptyCourseBlocked(expertUser);
            testLockEditingDuringPendingReview(testCourseId, expertUser);

        } catch (Exception e) {
            System.err.println("[FATAL TEST ERROR] " + e.getMessage());
            e.printStackTrace();
        } finally {
            // Clean up test course
            if (testCourseId > 0) {
                cleanUpTestCourse(testCourseId);
                System.out.println("\n[CLEANUP] Đã dọn dẹp Khóa học Test ID: " + testCourseId);
            }
        }

        System.out.println("\n======================================================================");
        System.out.printf(" KẾT QUẢ KIỂM THỬ: %d THÀNH CÔNG, %d THẤT BẠI\n", totalPassed, totalFailed);
        System.out.println("======================================================================");
        if (!failures.isEmpty()) {
            System.out.println("\nDANH SÁCH TEST THẤT BẠI:");
            for (String f : failures) {
                System.out.println(" - " + f);
            }
            System.exit(1);
        } else {
            System.out.println(" TẤT CẢ EDGE CASES ĐỀU ĐẠT CHUẨN HOÀN TOÀN!");
            System.exit(0);
        }
    }

    private static void assertTrue(String testName, boolean condition, String message) {
        if (condition) {
            System.out.println(" [PASS] " + testName);
            totalPassed++;
        } else {
            System.err.println(" [FAIL] " + testName + " -> " + message);
            totalFailed++;
            failures.add(testName + ": " + message);
        }
    }

    // -------------------------------------------------------------------------
    // TEST IMPLEMENTATIONS
    // -------------------------------------------------------------------------

    private static void testDirectionalMoveEarlierToTarget(long courseId, UserDto user) throws SQLException {
        // Module 1 (order 1) with L1
        long mod1 = createModule(courseId, "Chương 1 (Trước)", 1);
        long l1 = createLesson(mod1, "Bài mở đầu 1", 1);

        // Module 2 (order 2) with M2_A(1), M2_B(2), M2_C(3)
        long mod2 = createModule(courseId, "Chương 2 (Đích)", 2);
        long m2_a = createLesson(mod2, "Bài 2A", 1);
        long m2_b = createLesson(mod2, "Bài 2B", 2);
        long m2_c = createLesson(mod2, "Bài 2C", 3);

        // Move L1 from Mod 1 -> Mod 2 (Earlier -> Later: Push to TOP)
        LessonDto dto = new LessonDto();
        dto.setId(l1);
        dto.setCourseId(courseId);
        dto.setModuleId(mod2);
        dto.setTitle("Bài mở đầu 1 (Đã đổi sang Ch.2)");
        courseService.saveLesson(dto);

        // Verify L1 is now order 1, and m2_a, m2_b, m2_c shifted to 2, 3, 4
        int orderL1 = getLessonOrder(l1);
        int orderM2A = getLessonOrder(m2_a);
        int orderM2B = getLessonOrder(m2_b);
        int orderM2C = getLessonOrder(m2_c);

        assertTrue("EdgeCase 1.1: Chuyển từ chương trước sang chương sau -> ĐẨY LÊN ĐẦU (order=1)",
                orderL1 == 1, "Kỳ vọng order=1 nhưng nhận " + orderL1);
        assertTrue("EdgeCase 1.1: Các bài cũ trong chương đích tự động lùi thứ tự 2, 3, 4",
                orderM2A == 2 && orderM2B == 3 && orderM2C == 4,
                String.format("Kỳ vọng (2,3,4) nhưng nhận (%d, %d, %d)", orderM2A, orderM2B, orderM2C));
    }

    private static void testDirectionalMoveLaterToTarget(long courseId, UserDto user) throws SQLException {
        // Module 3 (order 3) with L3
        long mod3 = createModule(courseId, "Chương 3 (Sau)", 3);
        long l3 = createLesson(mod3, "Bài nâng cao 3", 1);

        // Target Module 2 has 4 lessons right now (orders 1, 2, 3, 4)
        List<Module> mods = getModules(courseId);
        long mod2 = mods.stream().filter(m -> m.getOrderIndex() == 2).findFirst().get().getId();

        // Move L3 from Mod 3 -> Mod 2 (Later -> Earlier: Push to BOTTOM)
        LessonDto dto = new LessonDto();
        dto.setId(l3);
        dto.setCourseId(courseId);
        dto.setModuleId(mod2);
        dto.setTitle("Bài nâng cao 3 (Đã đổi về Ch.2)");
        courseService.saveLesson(dto);

        int orderL3 = getLessonOrder(l3);
        assertTrue("EdgeCase 1.2: Chuyển từ chương sau về chương trước -> ĐẨY XUỐNG CUỐI (order=max+1=5)",
                orderL3 == 5, "Kỳ vọng order=5 nhưng nhận " + orderL3);
    }

    private static void testMoveToEmptyModule(long courseId, UserDto user) throws SQLException {
        // Module 4 has 0 lessons
        long mod4 = createModule(courseId, "Chương 4 (Trống)", 4);

        // Create lesson in Mod 1
        List<Module> mods = getModules(courseId);
        long mod1 = mods.stream().filter(m -> m.getOrderIndex() == 1).findFirst().get().getId();
        long lNew = createLesson(mod1, "Bài chuyển vào chương rỗng", 1);

        // Move into empty Module 4
        LessonDto dto = new LessonDto();
        dto.setId(lNew);
        dto.setCourseId(courseId);
        dto.setModuleId(mod4);
        dto.setTitle("Bài chuyển vào chương rỗng");
        courseService.saveLesson(dto);

        int order = getLessonOrder(lNew);
        assertTrue("EdgeCase 1.3: Chuyển bài học vào một chương đang trống hoàn toàn -> order=1",
                order == 1, "Kỳ vọng order=1 nhưng nhận " + order);
    }

    private static void testMoveWithGapsInExistingOrders(long courseId, UserDto user) throws SQLException {
        // Module with irregular gaps: order 2, 9, 20
        long modGap = createModule(courseId, "Chương Có Gap Thứ Tự", 5);
        long lG1 = createLesson(modGap, "Bài Gap 1", 2);
        long lG2 = createLesson(modGap, "Bài Gap 2", 9);
        long lG3 = createLesson(modGap, "Bài Gap 3", 20);

        // Move a lesson from Mod 1 (order 1 < 5) -> must push to top without unique constraint failure
        List<Module> mods = getModules(courseId);
        long mod1 = mods.stream().filter(m -> m.getOrderIndex() == 1).findFirst().get().getId();
        long lFrom1 = createLesson(mod1, "Bài từ ch1 sang chGap", 1);

        LessonDto dto = new LessonDto();
        dto.setId(lFrom1);
        dto.setCourseId(courseId);
        dto.setModuleId(modGap);
        dto.setTitle("Bài từ ch1 sang chGap");
        courseService.saveLesson(dto);

        int orderNew = getLessonOrder(lFrom1);
        int o1 = getLessonOrder(lG1);
        int o2 = getLessonOrder(lG2);
        int o3 = getLessonOrder(lG3);

        assertTrue("EdgeCase 1.4: Đổ chương vào module có khoảng trống thứ tự (Gap 2,9,20) không bị lỗi unique constraint",
                orderNew == 1 && o1 == 2 && o2 == 3 && o3 == 4,
                String.format("Kỳ vọng (1, 2, 3, 4) nhưng nhận (%d, %d, %d, %d)", orderNew, o1, o2, o3));
    }

    private static void testRapidConsecutiveMoves(long courseId, UserDto user) throws SQLException {
        long modTarget = createModule(courseId, "Chương Rapid Target", 6);
        long modSource = createModule(courseId, "Chương Rapid Source", 7);

        List<Long> sourceLessons = new ArrayList<>();
        for (int i = 1; i <= 4; i++) {
            sourceLessons.add(createLesson(modSource, "Rapid Lesson " + i, i));
        }

        // Rapidly move all 4 lessons one by one from Mod 7 -> Mod 6 (Later -> Earlier: push to bottom)
        for (Long lid : sourceLessons) {
            LessonDto dto = new LessonDto();
            dto.setId(lid);
            dto.setCourseId(courseId);
            dto.setModuleId(modTarget);
            dto.setTitle("Rapid Lesson " + lid);
            courseService.saveLesson(dto);
        }

        List<Lesson> targetLessons = lessonDao.findByModuleId(DbConnection.getConnection(), modTarget);
        boolean sequential = true;
        for (int i = 0; i < targetLessons.size(); i++) {
            if (targetLessons.get(i).getOrderIndex() != i + 1) {
                sequential = false;
                break;
            }
        }
        assertTrue("EdgeCase 1.5: Di chuyển liên tiếp 4 bài học không bị xung đột khóa, thứ tự liên tục 1..4",
                targetLessons.size() == 4 && sequential,
                "Kỳ vọng 4 bài liên tục 1..4 nhưng size=" + targetLessons.size());
    }

    private static void testReverseReorderLessons(long courseId, UserDto user) throws SQLException {
        long mod = createModule(courseId, "Chương Test Reorder", 8);
        List<Long> ids = new ArrayList<>();
        for (int i = 1; i <= 5; i++) {
            ids.add(createLesson(mod, "Item " + i, i));
        }

        // Reverse: [5, 4, 3, 2, 1]
        List<Long> reversed = new ArrayList<>();
        for (int i = ids.size() - 1; i >= 0; i--) {
            reversed.add(ids.get(i));
        }

        courseService.reorderLessons(mod, reversed);

        // Check in DB
        boolean match = true;
        for (int i = 0; i < reversed.size(); i++) {
            int order = getLessonOrder(reversed.get(i));
            if (order != (i + 1)) {
                match = false;
                break;
            }
        }
        assertTrue("EdgeCase 2.1: Reorder đảo ngược toàn bộ 5 bài học [5,4,3,2,1] qua 2-phase update thành công 100%",
                match, "Thứ tự đảo ngược không khớp 1..5");
    }

    private static void testCrossModuleDragAndDrop(long courseId, UserDto user) throws SQLException {
        long modA = createModule(courseId, "Drag Mod A", 9);
        long modB = createModule(courseId, "Drag Mod B", 10);

        long lA1 = createLesson(modA, "A1", 1);
        long lA2 = createLesson(modA, "A2", 2);
        long lB1 = createLesson(modB, "B1", 1);

        // Drag lA1 into Mod B: new order in Mod B is [lB1, lA1]
        List<Long> newBList = List.of(lB1, lA1);
        courseService.reorderLessons(modB, newBList);

        int orderB1 = getLessonOrder(lB1);
        int orderA1 = getLessonOrder(lA1);
        long modOfA1 = getLessonModuleId(lA1);

        assertTrue("EdgeCase 2.2: Kéo thả bài học xuyên module cập nhật đúng module_id và thứ tự mới",
                modOfA1 == modB && orderB1 == 1 && orderA1 == 2,
                String.format("Kỳ vọng mod=%d order=(1,2) nhưng nhận mod=%d order=(%d,%d)", modB, modOfA1, orderB1, orderA1));
    }

    private static void testDeleteModuleContainingLessonsBlocked(long courseId, UserDto user) throws SQLException {
        long mod = createModule(courseId, "Module Có Bài", 11);
        createLesson(mod, "Bài 1", 1);

        boolean blocked = false;
        try {
            courseService.deleteModule(mod);
        } catch (IllegalArgumentException e) {
            blocked = e.getMessage().contains("vẫn còn");
        }
        assertTrue("EdgeCase 3.1: Chặn xóa Chương học khi vẫn còn bài học bên trong để bảo vệ dữ liệu",
                blocked, "Hệ thống không chặn hoặc không thông báo đúng.");
    }

    private static void testDeleteEmptyModuleSucceeds(long courseId, UserDto user) throws SQLException {
        long mod = createModule(courseId, "Module Rỗng Cần Xóa", 12);
        boolean deleted = false;
        try {
            courseService.deleteModule(mod);
            deleted = moduleDao.findById(DbConnection.getConnection(), mod).isEmpty();
        } catch (Exception e) {
            deleted = false;
        }
        assertTrue("EdgeCase 3.2: Xóa thành công Chương học rỗng (0 bài học, 0 quiz)",
                deleted, "Không xóa được chương rỗng");
    }

    private static void testDeleteLessonDraftCourseHardDelete(long courseId, UserDto user) throws SQLException {
        long mod = createModule(courseId, "Module Xóa Thử", 13);
        long lId = createLesson(mod, "Bài cần xóa vĩnh viễn", 1);

        courseService.deleteLesson(lId);
        boolean exists = lessonDao.findById(DbConnection.getConnection(), lId).isPresent();
        assertTrue("EdgeCase 3.3: Khóa học Draft chưa có học sinh -> Xóa vĩnh viễn (Hard Delete) khỏi DB",
                !exists, "Bài học vẫn còn tồn tại trong DB sau khi xóa.");
    }

    private static void testDeleteLessonPublishedCourseSoftDelete(UserDto user) throws SQLException {
        long pubCourseId = createTestCourse(user.getId(), "Khóa Học Đã Xuất Bản");
        try {
            // Set published
            try (Connection con = DbConnection.getConnection()) {
                try (PreparedStatement ps = con.prepareStatement("UPDATE courses SET status = 'PUBLISHED' WHERE id = ?")) {
                    ps.setLong(1, pubCourseId);
                    ps.executeUpdate();
                }
            }
            long mod = createModule(pubCourseId, "Chương 1", 1);
            long lId = createLesson(mod, "Bài học đã public", 1);

            boolean softDeleted = false;
            try {
                courseService.deleteLesson(lId);
            } catch (IllegalStateException e) {
                // Throws notification that it was safely switched to hidden
                Lesson l = lessonDao.findById(DbConnection.getConnection(), lId).orElse(null);
                softDeleted = (l != null && !l.isActive());
            }
            assertTrue("EdgeCase 3.4: Khóa học đã Xuất bản -> Tự động chuyển sang Tạm ẩn (Soft Delete), không mất bài",
                    softDeleted, "Bài học không được chuyển sang trạng thái Ẩn");
        } finally {
            cleanUpTestCourse(pubCourseId);
        }
    }

    private static void testCrossCourseMoveLessonBlocked(long courseIdA, UserDto user) throws SQLException {
        long courseIdB = createTestCourse(user.getId(), "Khóa Học B Khác Biệt");
        try {
            long modA = createModule(courseIdA, "Mod A", 14);
            long modB = createModule(courseIdB, "Mod B", 1);
            long lA = createLesson(modA, "Bài A", 1);

            boolean blocked = false;
            try {
                LessonDto dto = new LessonDto();
                dto.setId(lA);
                dto.setCourseId(courseIdA);
                dto.setModuleId(modB); // Target is module in Course B!
                dto.setTitle("Bài A chuyển lậu sang Khóa B");
                courseService.saveLesson(dto);
            } catch (IllegalArgumentException e) {
                blocked = e.getMessage().contains("khác") || e.getMessage().contains("không thuộc về khóa học");
            }
            assertTrue("EdgeCase 4.1: Chặn triệt để hành vi di chuyển bài học sang chương thuộc Khóa học khác",
                    blocked, "Không chặn chuyển bài xuyên khóa học");
        } finally {
            cleanUpTestCourse(courseIdB);
        }
    }

    private static void testIDORCourseOwnershipCheck(long courseId, UserDto otherExpert) {
        boolean blocked = false;
        try {
            courseService.checkCourseOwnership(courseId, otherExpert);
        } catch (SecurityException e) {
            blocked = true;
        }
        assertTrue("EdgeCase 4.2: IDOR Defense - Chặn người dùng khác can thiệp khóa học không thuộc quyền quản lý",
                blocked, "Hệ thống không chặn IDOR!");
    }

    private static void testPublishEmptyCourseBlocked(UserDto user) throws SQLException {
        long emptyCourseId = createTestCourse(user.getId(), "Khóa Học Rỗng Không Bài");
        try {
            boolean blocked = false;
            try {
                courseService.updateCourseStatus(emptyCourseId, CourseStatus.PUBLISHED);
            } catch (IllegalStateException e) {
                blocked = e.getMessage().contains("chưa có bài");
            }
            assertTrue("EdgeCase 5.1: Chặn xuất bản (PUBLISHED) khóa học khi chưa có bài học nào",
                    blocked, "Cho phép xuất bản khóa học rỗng!");

            boolean blockedReview = false;
            try {
                courseService.updateCourseStatus(emptyCourseId, CourseStatus.PENDING_REVIEW);
            } catch (IllegalStateException e) {
                blockedReview = e.getMessage().contains("chưa có bài");
            }
            assertTrue("EdgeCase 5.2: Chặn gửi duyệt (PENDING_REVIEW) khóa học khi chưa có bài học nào",
                    blockedReview, "Cho phép gửi duyệt khóa học rỗng!");
        } finally {
            cleanUpTestCourse(emptyCourseId);
        }
    }

    private static void testLockEditingDuringPendingReview(long courseId, UserDto user) throws SQLException {
        long mod = createModule(courseId, "Mod Pending", 15);
        long lid = createLesson(mod, "Bài Pending", 1);

        // Put course in PENDING_REVIEW
        try (Connection con = DbConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement("UPDATE courses SET status = 'PENDING_REVIEW' WHERE id = ?")) {
                ps.setLong(1, courseId);
                ps.executeUpdate();
            }
        }

        boolean blocked = false;
        try {
            courseService.checkCourseEditable(courseId);
        } catch (IllegalStateException e) {
            blocked = e.getMessage().contains("Chờ duyệt");
        }

        // Revert to DRAFT for subsequent cleanup
        try (Connection con = DbConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement("UPDATE courses SET status = 'DRAFT' WHERE id = ?")) {
                ps.setLong(1, courseId);
                ps.executeUpdate();
            }
        }

        assertTrue("EdgeCase 5.3: Khóa học ở trạng thái PENDING_REVIEW bị khóa chỉnh sửa nội dung hoàn toàn",
                blocked, "Khóa học Chờ duyệt không bị khóa chỉnh sửa");
    }

    // -------------------------------------------------------------------------
    // DB HELPERS
    // -------------------------------------------------------------------------

    private static long createTestCourse(long expertId, String title) throws SQLException {
        try (Connection con = DbConnection.getConnection()) {
            Course c = new Course();
            c.setExpertId(expertId);
            c.setManagerId(2L);
            c.setCategoryId(6L);
            c.setTitle(title);
            c.setDescription("Mô tả test tự động");
            c.setPrice(BigDecimal.ZERO);
            c.setStatus(CourseStatus.DRAFT);
            return courseDao.insert(con, c);
        }
    }

    private static long createModule(long courseId, String title, int order) throws SQLException {
        try (Connection con = DbConnection.getConnection()) {
            Module m = new Module();
            m.setCourseId(courseId);
            m.setTitle(title);
            m.setOrderIndex(order);
            return moduleDao.insert(con, m);
        }
    }

    private static long createLesson(long moduleId, String title, int order) throws SQLException {
        try (Connection con = DbConnection.getConnection()) {
            Lesson l = new Lesson();
            l.setModuleId(moduleId);
            l.setTitle(title);
            l.setContent("Nội dung bài học test");
            l.setOrderIndex(order);
            l.setActive(true);
            return lessonDao.insert(con, l);
        }
    }

    private static int getLessonOrder(long lessonId) throws SQLException {
        try (Connection con = DbConnection.getConnection()) {
            return lessonDao.findById(con, lessonId).map(Lesson::getOrderIndex).orElse(-1);
        }
    }

    private static long getLessonModuleId(long lessonId) throws SQLException {
        try (Connection con = DbConnection.getConnection()) {
            return lessonDao.findById(con, lessonId).map(Lesson::getModuleId).orElse(-1L);
        }
    }

    private static List<Module> getModules(long courseId) throws SQLException {
        try (Connection con = DbConnection.getConnection()) {
            return moduleDao.findByCourseId(con, courseId);
        }
    }

    private static void cleanUpTestCourse(long courseId) {
        try (Connection con = DbConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM lessons WHERE module_id IN (SELECT id FROM modules WHERE course_id = ?)")) {
                ps.setLong(1, courseId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM modules WHERE course_id = ?")) {
                ps.setLong(1, courseId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM courses WHERE id = ?")) {
                ps.setLong(1, courseId);
                ps.executeUpdate();
            }
        } catch (SQLException ignored) {
        }
    }
}

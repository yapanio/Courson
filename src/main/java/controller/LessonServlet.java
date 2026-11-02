package controller;

import dao.CourseDao;
import dao.LessonDao;
import dao.LessonProgressDao;
import dao.ModuleDao;
import dao.RegistrationDao;
import dto.CourseDto;
import dto.LessonDto;
import dto.ModuleDto;
import dto.UserDto;
import entity.enums.CourseStatus;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import service.CourseService;
import util.SessionUtil;

import java.time.LocalDateTime;

import java.time.OffsetDateTime;

import java.time.ZoneId;

import java.time.format.DateTimeFormatter;

/**
 * Controller phụ trách các màn hình Lesson Management (BF-04) của Toàn:
 * - Expert Dashboard (II.4.3)
 * - Lesson List (II.4.1)
 * - Lesson Detail / Editor (II.4.1)
 */
@WebServlet(name = "LessonServlet", urlPatterns = {"/expert/*"})
public class LessonServlet extends HttpServlet {
    // Quản lý bộ nhớ đệm bản nháp đa thiết bị theo tài khoản Expert (User ID)
    private static final java.util.concurrent.ConcurrentHashMap<String, java.util.Map<String, String>> USER_DRAFTS = new java.util.concurrent.ConcurrentHashMap<>();

    private static String buildUserDraftKey(long userId, String courseId, String lessonId) {
        String cId = (courseId != null && !courseId.trim().isEmpty()) ? courseId.trim() : "0";
        String lId = (lessonId != null && !lessonId.trim().isEmpty()) ? lessonId.trim() : "new";
        return "u" + userId + "_c" + cId + "_l" + lId;
    }
    private CourseService courseService;

    // =========================================================================
    // 1. VÒNG ĐỜI & ĐIỀU HƯỚNG REQUEST (LIFECYCLE & ROUTING)
    // =========================================================================

    /**
     * Khởi tạo Servlet: Tạo đối tượng CourseService và nạp các DAO truy vấn CSDL.
     * Hàm này chỉ chạy 1 lần duy nhất khi Tomcat nạp Servlet vào bộ nhớ.
     */
    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService(
                new CourseDao(), new ModuleDao(), new LessonDao(),
                new LessonProgressDao(), new RegistrationDao()
        );
    }

    /**
     * Tiếp nhận tất cả các HTTP GET request (truy cập xem trang từ trình duyệt).
     * Bóc tách action từ URL (ví dụ: /expert/lessons -> action = "lessons").
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "dashboard";
        processAction(action, req, resp);
    }

    /**
     * Tiếp nhận tất cả các HTTP POST request (khi người dùng nộp form lưu/xóa dữ liệu).
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "dashboard";
        processAction(action, req, resp);
    }

    /**
     * Bộ phân loại hành động (Router Switchboard):
     * Điều hướng request đến hàm xử lý tương ứng dựa vào tên action.
     */
    private void processAction(String action, HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // [Xử lý Flash Messages]: Lấy thông báo lỗi/thành công từ Session (nếu có) và nạp vào Request, tự động xóa khỏi Session
        String flashError = SessionUtil.popFlashError(req);
        if (flashError != null) {
            req.setAttribute("errorMessage", flashError);
        }
        String flashSuccess = SessionUtil.popFlashSuccess(req);
        if (flashSuccess != null) {
            req.setAttribute("successMessage", flashSuccess);
        }

        // [Security - Mutating Endpoint Guard]: Chặn triệt để phương thức GET tại các endpoint thay đổi dữ liệu
        java.util.Set<String> mutatingActions = java.util.Set.of(
            "save-lesson", "hide-lesson", "delete-lesson", "toggle-lesson-status",
            "save-module", "delete-module", "save-course", "batch-save-lessons",
            "delete-course", "save-lesson-draft", "delete-lesson-draft",
            "generate-ai-description", "request-publish", "cancel-request-publish",
            "archive-course", "unarchive-course", "cancel-archive", "reorder-lessons"
        );
        if (mutatingActions.contains(action) && !"POST".equalsIgnoreCase(req.getMethod())) {
            SessionUtil.setFlashError(req, "Phương thức " + req.getMethod() + " không được hỗ trợ cho thao tác này. Vui lòng gửi yêu cầu qua POST.");
            String courseId = req.getParameter("courseId");
            if (courseId != null && !courseId.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseId.trim());
            } else {
                resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
            }
            return;
        }

        switch (action) {
            case "dashboard":
                showExpertDashboard(req, resp);
                break;
            case "lessons":
                showLessonList(req, resp);
                break;
            case "lesson-detail":
                showLessonDetail(req, resp);
                break;
            case "save-lesson":
                saveLesson(req, resp);
                break;
            case "hide-lesson":
                hideLesson(req, resp);
                break;
            case "delete-lesson":
                deleteLesson(req, resp);
                break;
            case "reorder-lessons":
                reorderLessons(req, resp);
                break;
            case "toggle-lesson-status":
                toggleLessonStatus(req, resp);
                break;
            case "save-module":
                saveModule(req, resp);
                break;
            case "delete-module":
                deleteModule(req, resp);
                break;
            case "save-course":
                saveCourse(req, resp);
                break;
            case "batch-save-lessons":
                batchSaveLessons(req, resp);
                break;
            case "delete-course":
                deleteCourse(req, resp);
                break;
            case "get-course":
                getCourseJson(req, resp);
                break;
            case "save-lesson-draft":
                saveLessonDraft(req, resp);
                break;
            case "get-lesson-draft":
                getLessonDraft(req, resp);
                break;
            case "delete-lesson-draft":
                deleteLessonDraft(req, resp);
                break;
            case "suggest-module-title":
                suggestModuleTitle(req, resp);
                break;
            case "preview-batch-videos":
                previewBatchVideos(req, resp);
                break;
            case "generate-ai-description":
                generateAiDescription(req, resp);
                break;
            case "request-publish":
                requestPublish(req, resp);
                break;
            case "cancel-request-publish":
                cancelRequestPublish(req, resp);
                break;
            case "archive-course":
                archiveCourse(req, resp);
                break;
            case "unarchive-course":
                unarchiveCourse(req, resp);
                break;
            case "cancel-archive":
                cancelArchive(req, resp);
                break;
            case "get-video-title":
                getVideoTitle(req, resp);
                break;
            default:
                showExpertDashboard(req, resp);
                break;
        }
    }

    // =========================================================================
    // 2. NHÓM QUẢN LÝ EXPERT DASHBOARD & KHÓA HỌC (COURSE MANAGEMENT)
    // =========================================================================

    /**
     * [Màn hình II.4.3] Hiển thị trang Expert Dashboard:
     * - Kiểm tra phiên đăng nhập (Session).
     * - Lấy danh sách khóa học thuộc quyền phụ trách của Expert hiện tại.
     * - Lấy danh mục thể loại khóa học để phục vụ form tạo khóa học mới.
     * - Chuyển tiếp (forward) dữ liệu sang views/expert/dashboard.jsp.
     */
    private void showExpertDashboard(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        List<CourseDto> courses = courseService.getManagedCourses(currentUser.getId());
        List<dto.SettingDto> categories = courseService.getCategories();
        req.setAttribute("courses", courses);
        req.setAttribute("categories", categories);
        req.getRequestDispatcher("/WEB-INF/views/expert/dashboard.jsp").forward(req, resp);
    }

    /**
     * [Tối ưu hiệu năng & Indexed Query]:
     * Lấy trực tiếp thông tin 1 khóa học bằng index (ID) duy nhất trong CSDL
     * trả về JSON để hiển thị lên Modal sửa khóa học thay vì phải tải toàn bộ thông tin
     * tất cả các khóa học vào DOM.
     */
    private void getCourseJson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Vui lòng đăng nhập để tiếp tục.\"}");
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Thiếu ID khóa học cần lấy thông tin.\"}");
            return;
        }

        try {
            long courseId = Long.parseLong(idStr.trim());
            // [IDOR Defense]: Kiểm tra quyền hạn của Expert đối với khóa học
            courseService.checkCourseOwnership(courseId, currentUser);

            // Truy vấn trực tiếp bản ghi bằng index khóa chính trong CSDL O(1)
            CourseDto course = courseService.getCourseById(courseId);

            resp.setContentType("application/json;charset=UTF-8");
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"id\":").append(course.getId()).append(",");
            json.append("\"title\":\"").append(escapeJson(course.getTitle())).append("\",");
            json.append("\"categoryId\":").append(course.getCategoryId() != null ? course.getCategoryId() : "null").append(",");
            json.append("\"categoryName\":\"").append(escapeJson(course.getCategoryName())).append("\",");
            json.append("\"price\":").append(course.getPrice() != null ? course.getPrice() : "0").append(",");
            json.append("\"status\":\"").append(course.getStatus() != null ? course.getStatus().name() : "DRAFT").append("\",");
            json.append("\"description\":\"").append(escapeJson(course.getDescription())).append("\"");
            json.append("}");

            resp.getWriter().write(json.toString());
        } catch (SecurityException se) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"" + escapeJson(se.getMessage()) + "\"}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    /**
     * API trả về tiêu đề của Video (YouTube) dưới dạng JSON:
     * GET /expert/get-video-title?url=...
     */
    private void getVideoTitle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String url = req.getParameter("url");
        if (url == null || url.trim().isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"URL không hợp lệ\"}");
            return;
        }

        String title = CourseService.fetchYoutubeVideoTitle(url);
        if (title != null && !title.trim().isEmpty()) {
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,");
            json.append("\"title\":\"").append(escapeJson(title)).append("\"");
            json.append("}");
            resp.getWriter().write(json.toString());
        } else {
            resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy tiêu đề video\"}");
        }
    }

    /**
     * [Tự động lưu nháp liên tục (Real-time Auto-save) - Backup Session]:
     * Nhận yêu cầu tự động lưu bản nháp từ màn hình soạn thảo bài học,
     * lưu trữ tạm thời trong Session để bảo toàn dữ liệu tránh mất mát bài khi chưa kịp ấn lưu.
     */
    private void saveLessonDraft(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        String courseId = req.getParameter("courseId");
        String lessonId = req.getParameter("lessonId");
        String title = req.getParameter("title");
        String moduleId = req.getParameter("moduleId");
        String orderIndex = req.getParameter("orderIndex");
        String videoUrl = req.getParameter("videoUrl");
        String documentUrl = req.getParameter("documentUrl");
        String content = req.getParameter("content");

        String draftKey = "draft_lesson_" + (courseId != null ? courseId : "0") + "_" + (lessonId != null && !lessonId.trim().isEmpty() ? lessonId.trim() : "new");
        java.util.Map<String, String> draft = new java.util.HashMap<>();
        draft.put("courseId", courseId != null ? courseId : "");
        draft.put("lessonId", lessonId != null ? lessonId : "");
        draft.put("title", title != null ? title : "");
        draft.put("moduleId", moduleId != null ? moduleId : "");
        draft.put("orderIndex", orderIndex != null ? orderIndex : "1");
        draft.put("videoUrl", videoUrl != null ? videoUrl : "");
        draft.put("documentUrl", documentUrl != null ? documentUrl : "");
        draft.put("content", content != null ? content : "");
        draft.put("savedAt", java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy")));

        // 1. Lưu bản nháp theo User ID -> Hỗ trợ làm việc xuyên thiết bị (đổi sang máy khác vẫn nhận được)
        String userDraftKey = buildUserDraftKey(currentUser.getId(), courseId, lessonId);
        USER_DRAFTS.put(userDraftKey, draft);

        // 2. Dự phòng trong Session của trình duyệt hiện tại
        req.getSession().setAttribute(draftKey, draft);

        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"success\":true,\"savedAt\":\"" + draft.get("savedAt") + "\"}");
    }

    /**
     * [Khôi phục bản nháp đa thiết bị theo tài khoản Expert]:
     */
    private void getLessonDraft(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        String courseId = req.getParameter("courseId");
        String lessonId = req.getParameter("lessonId");
        String draftKey = "draft_lesson_" + (courseId != null ? courseId : "0") + "_" + (lessonId != null && !lessonId.trim().isEmpty() ? lessonId.trim() : "new");

        java.util.Map<String, String> draft = null;
        if (currentUser != null) {
            String userDraftKey = buildUserDraftKey(currentUser.getId(), courseId, lessonId);
            draft = USER_DRAFTS.get(userDraftKey);
        }
        if (draft == null) {
            @SuppressWarnings("unchecked")
            java.util.Map<String, String> sessionDraft = (java.util.Map<String, String>) req.getSession().getAttribute(draftKey);
            draft = sessionDraft;
        }

        resp.setContentType("application/json;charset=UTF-8");
        if (draft == null) {
            resp.getWriter().write("{\"exists\":false}");
            return;
        }
        StringBuilder json = new StringBuilder("{\"exists\":true");
        for (java.util.Map.Entry<String, String> entry : draft.entrySet()) {
            json.append(",\"").append(entry.getKey()).append("\":\"").append(escapeJson(entry.getValue())).append("\"");
        }
        json.append("}");
        resp.getWriter().write(json.toString());
    }

    /**
     * [Xóa bản nháp khi người dùng chọn Bỏ qua hoặc bài học đã lưu thành công]:
     */
    private void deleteLessonDraft(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        String courseId = req.getParameter("courseId");
        String lessonId = req.getParameter("lessonId");
        String draftKey = "draft_lesson_" + (courseId != null ? courseId : "0") + "_" + (lessonId != null && !lessonId.trim().isEmpty() ? lessonId.trim() : "new");

        if (currentUser != null) {
            String userDraftKey = buildUserDraftKey(currentUser.getId(), courseId, lessonId);
            USER_DRAFTS.remove(userDraftKey);
        }
        req.getSession().removeAttribute(draftKey);

        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"success\":true}");
    }

    /**
     * [AJAX API]: Xem trước danh sách bài học bóc tách từ nhiều URL hoặc Playlist YouTube.
     * Tag tìm kiếm: #YOUTUBE_PLAYLIST_IMPORT #PREVIEW_BATCH
     */
    private void previewBatchVideos(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String batchText = req.getParameter("batchText");
        CourseService.BatchParseResult result = CourseService.parseBatchVideoResult(batchText);

        resp.setContentType("application/json;charset=UTF-8");
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"playlistTitle\":");
        if (result.getPlaylistTitle() != null && !result.getPlaylistTitle().isEmpty()) {
            sb.append("\"").append(escapeJson(result.getPlaylistTitle())).append("\"");
        } else {
            sb.append("null");
        }
        sb.append(",\"suggestedCategoryId\":").append(result.getSuggestedCategoryId() != null ? result.getSuggestedCategoryId() : "null");
        sb.append(",\"suggestedCategoryName\":");
        if (result.getSuggestedCategoryName() != null && !result.getSuggestedCategoryName().isEmpty()) {
            sb.append("\"").append(escapeJson(result.getSuggestedCategoryName())).append("\"");
        } else {
            sb.append("null");
        }
        sb.append(",\"suggestedDescription\":");
        if (result.getSuggestedDescription() != null && !result.getSuggestedDescription().isEmpty()) {
            sb.append("\"").append(escapeJson(result.getSuggestedDescription())).append("\"");
        } else {
            sb.append("null");
        }
        sb.append(",\"videos\":[");
        List<LessonDto> lessons = result.getLessons();
        for (int i = 0; i < lessons.size(); i++) {
            LessonDto l = lessons.get(i);
            if (i > 0) sb.append(",");
            String vidId = "";
            if (l.getVideoUrl() != null && l.getVideoUrl().contains("/embed/")) {
                vidId = l.getVideoUrl().substring(l.getVideoUrl().lastIndexOf("/embed/") + 7);
            }
            sb.append("{")
              .append("\"orderIndex\":").append(l.getOrderIndex()).append(",")
              .append("\"title\":\"").append(escapeJson(l.getTitle())).append("\",")
              .append("\"videoUrl\":\"").append(escapeJson(l.getVideoUrl())).append("\",")
              .append("\"videoId\":\"").append(escapeJson(vidId)).append("\"")
              .append("}");
        }
        sb.append("]}");
        resp.getWriter().write(sb.toString());
    }

    /**
     * Tự động sinh mô tả khóa học bằng Google Gemini AI:
     * - Nhận tham số title và categoryName.
     * - Trả về JSON: {"description": "..."}
     */
    private void generateAiDescription(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String title = req.getParameter("title");
        String categoryName = req.getParameter("categoryName");
        String desc = courseService.generateCourseDescription(title, categoryName);

        resp.setContentType("application/json;charset=UTF-8");
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"description\":");
        if (desc != null && !desc.trim().isEmpty()) {
            sb.append("\"").append(escapeJson(desc)).append("\"");
        } else {
            sb.append("null");
        }
        sb.append("}");
        resp.getWriter().write(sb.toString());
    }

    /**
     * Tạo mới hoặc Cập nhật thông tin Khóa học:
     * - [IDOR Defense]: Nếu chỉnh sửa khóa học cũ (id != null), kiểm tra quyền sở hữu của user.
     * - Đọc các tham số: tiêu đề, mô tả, danh mục, giá học phí.
     * - Khóa học do Expert tạo mới luôn có trạng thái DRAFT chờ Manager duyệt.
     * - Nếu có kèm danh sách link video (batchVideoText) thì tự động bóc tách tạo bài học ngay.
     * - [Flash Message]: Dùng session flash attributes thay vì truyền error qua URL.
     */
    private void saveCourse(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        CourseDto dto = new CourseDto();
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            long courseId = Long.parseLong(idStr.trim());
            try {
                // [IDOR Defense]: Kiểm tra quyền sở hữu khóa học trước khi sửa
                courseService.checkCourseOwnership(courseId, currentUser);
                courseService.checkCourseEditable(courseId);
                dto.setId(courseId);
                CourseDto existing = courseService.getCourseDetail(dto.getId());
                dto.setStatus(existing.getStatus());
                dto.setManagerId(existing.getManagerId());
            } catch (SecurityException se) {
                SessionUtil.setFlashError(req, se.getMessage());
                resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
                return;
            } catch (Exception ignored) {
                dto.setStatus(entity.enums.CourseStatus.DRAFT);
            }
        } else {
            // Khóa học mới tạo bởi Expert luôn ở trạng thái DRAFT để chờ Quản lý duyệt
            dto.setStatus(entity.enums.CourseStatus.DRAFT);
            Long defaultManagerId = courseService.getDefaultManagerId();
            if (defaultManagerId != null) {
                dto.setManagerId(defaultManagerId);
            }
        }

        String title = req.getParameter("title");
        String batchText = req.getParameter("batchVideoText");
        String batchModuleTitle = req.getParameter("batchModuleTitle");
        CourseService.BatchParseResult batchResult = null;
        if (batchText != null && !batchText.trim().isEmpty()) {
            batchResult = CourseService.parseBatchVideoResult(batchText);
        }

        // Tự động gán tên Playlist YouTube làm tên khóa học nếu người dùng chưa nhập tiêu đề
        if ((title == null || title.trim().isEmpty()) && batchResult != null && batchResult.getPlaylistTitle() != null && !batchResult.getPlaylistTitle().trim().isEmpty()) {
            title = batchResult.getPlaylistTitle().trim();
        }

        dto.setTitle(title);
        dto.setDescription(req.getParameter("description"));
        String catIdStr = req.getParameter("categoryId");
        String customCategory = req.getParameter("customCategory");
        if (customCategory != null && !customCategory.trim().isEmpty()) {
            dto.setCategoryId(courseService.getOrCreateCategory(customCategory));
        } else if (catIdStr != null && !catIdStr.trim().isEmpty() && !"__NEW__".equalsIgnoreCase(catIdStr.trim())) {
            dto.setCategoryId(Long.parseLong(catIdStr.trim()));
        } else if (batchResult != null && batchResult.getSuggestedCategoryId() != null) {
            dto.setCategoryId(batchResult.getSuggestedCategoryId());
        } else {
            dto.setCategoryId(6L);
        }
        String priceStr = req.getParameter("price");
        dto.setPrice(priceStr != null && !priceStr.trim().isEmpty() ? new java.math.BigDecimal(priceStr.trim()) : java.math.BigDecimal.ZERO);
        dto.setExpertId(currentUser.getId());

        try {
            long savedId = courseService.saveCourse(dto);

            // Kiểm tra nếu có nhập danh sách link video hàng loạt kèm theo
            if (batchResult != null && !batchResult.getLessons().isEmpty()) {
                courseService.saveBatchLessons(savedId, null, batchModuleTitle, batchResult.getLessons());
                SessionUtil.setFlashSuccess(req, "Khởi tạo khóa học thành công! Các bài giảng đã được tự động phân chia vào các Chương học (Modules) tương ứng.");
            } else {
                SessionUtil.setFlashSuccess(req, "Khởi tạo khóa học thành công! Hãy bắt đầu thêm các chương và bài học bên dưới.");
            }
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + savedId);
        } catch (Exception e) {
            SessionUtil.setFlashError(req, e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
        }
    }

    /**
     * Nhập hàng loạt bài giảng (Batch Import) từ Playlist / nhiều link YouTube:
     * - [IDOR Defense]: Kiểm tra quyền sở hữu khóa học và chương học.
     * - Bóc tách danh sách URL YouTube từ chuỗi text.
     * - Tự động tạo bài giảng và gán vào Module chỉ định (hoặc tạo Module mới với tên do người dùng đặt).
     */
    private void batchSaveLessons(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        String moduleIdStr = req.getParameter("moduleId");
        String newModuleTitle = req.getParameter("newModuleTitle");
        String batchText = req.getParameter("batchText");

        if (courseIdStr == null || courseIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
            return;
        }

        long courseId = Long.parseLong(courseIdStr.trim());
        Long moduleId = (moduleIdStr != null && !moduleIdStr.trim().isEmpty() && !"__NEW__".equals(moduleIdStr.trim()))
                ? Long.parseLong(moduleIdStr.trim()) : null;

        try {
            // [IDOR Defense]: Kiểm tra quyền sở hữu
            courseService.checkCourseOwnership(courseId, currentUser);
            courseService.checkCourseEditable(courseId);
            if (moduleId != null) {
                courseService.checkModuleOwnership(moduleId, currentUser);
            }

            List<LessonDto> lessons = CourseService.parseBatchVideoText(batchText);
            int count = courseService.saveBatchLessons(courseId, moduleId, newModuleTitle, lessons);
            SessionUtil.setFlashSuccess(req, "Đã nhập và khởi tạo thành công " + count + " bài học từ danh sách video YouTube!");
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseId);
        } catch (SecurityException se) {
            SessionUtil.setFlashError(req, se.getMessage());
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
        } catch (Exception e) {
            SessionUtil.setFlashError(req, e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseId);
        }
    }

    /**
     * Xóa Khóa học:
     * - [Quy tắc bảo mật]: Chuyên gia CHỈ có thể xóa hoàn toàn khóa học nếu đang ở trạng thái Nháp (DRAFT).
     * - Nếu khóa học đã xuất bản hoặc có học viên thì chỉ có Admin mới có quyền xóa.
     */
    private void deleteCourse(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));
        if (currentUser == null) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để thực hiện.\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String idStr = req.getParameter("id");
        if (idStr != null) {
            try {
                long courseId = Long.parseLong(idStr.trim());
                courseService.deleteCourse(courseId, currentUser);
                if (isAjax) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Đã xóa vĩnh viễn khóa học nháp thành công!\"}");
                    return;
                }
                SessionUtil.setFlashSuccess(req, "Đã xóa vĩnh viễn khóa học nháp thành công!");
            } catch (Exception e) {
                if (isAjax) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":false,\"message\":\"" + (e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Lỗi khi xóa khóa học.") + "\"}");
                    return;
                }
                SessionUtil.setFlashError(req, e.getMessage());
            }
        }
        resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
    }

    /**
     * Lưu trữ / Lên lịch lưu trữ khóa học (Archive):
     * - Áp dụng cho khóa học đã xuất bản (PUBLISHED).
     * - Hỗ trợ các chế độ thời gian tùy ý:
     *   1. IMMEDIATE: Ẩn ngay lập tức.
     *   2. DURATION: Tùy ý nhập số lượng bất kỳ kèm đơn vị (Giờ / Ngày / Tuần / Tháng).
     *   3. SPECIFIC_DATE: Chọn mốc ngày giờ chính xác trên lịch (datetime-local).
     *   4. Backward compatibility: Tham số noticeDays truyền thống.
     */
    private void archiveCourse(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String idStr = req.getParameter("courseId");
        if (idStr == null || idStr.trim().isEmpty()) {
            idStr = req.getParameter("id");
        }
        if (idStr != null) {
            try {
                long courseId = Long.parseLong(idStr.trim());
                String archiveMode = req.getParameter("archiveMode");
                String customNotice = req.getParameter("archiveNotice");

                OffsetDateTime targetArchiveTime;

                if ("IMMEDIATE".equalsIgnoreCase(archiveMode)) {
                    targetArchiveTime = OffsetDateTime.now();
                } else if ("SPECIFIC_DATE".equalsIgnoreCase(archiveMode)) {
                    String dateStr = req.getParameter("specificArchiveDate");
                    if (dateStr != null && !dateStr.trim().isEmpty()) {
                        LocalDateTime localDt = LocalDateTime.parse(dateStr.trim());
                        targetArchiveTime = localDt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
                    } else {
                        targetArchiveTime = OffsetDateTime.now();
                    }
                } else if ("DURATION".equalsIgnoreCase(archiveMode)) {
                    String durationValStr = req.getParameter("durationValue");
                    String durationUnit = req.getParameter("durationUnit");
                    long durationVal = (durationValStr != null && !durationValStr.trim().isEmpty())
                            ? Long.parseLong(durationValStr.trim())
                            : 3L;

                    if (durationVal <= 0) {
                        targetArchiveTime = OffsetDateTime.now();
                    } else {
                        OffsetDateTime now = OffsetDateTime.now();
                        if ("HOURS".equalsIgnoreCase(durationUnit)) {
                            targetArchiveTime = now.plusHours(durationVal);
                        } else if ("WEEKS".equalsIgnoreCase(durationUnit)) {
                            targetArchiveTime = now.plusWeeks(durationVal);
                        } else if ("MONTHS".equalsIgnoreCase(durationUnit)) {
                            targetArchiveTime = now.plusMonths(durationVal);
                        } else {
                            targetArchiveTime = now.plusDays(durationVal);
                        }
                    }
                } else {
                    int noticeDays = 3;
                    String noticeDaysStr = req.getParameter("noticeDays");
                    if (noticeDaysStr != null && !noticeDaysStr.trim().isEmpty()) {
                        noticeDays = Integer.parseInt(noticeDaysStr.trim());
                    }
                    targetArchiveTime = (noticeDays <= 0) ? OffsetDateTime.now() : OffsetDateTime.now().plusDays(noticeDays);
                }

                courseService.scheduleArchiveCourse(courseId, targetArchiveTime, customNotice, currentUser);

                if (targetArchiveTime != null && targetArchiveTime.isAfter(OffsetDateTime.now())) {
                    String formattedTime = targetArchiveTime.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
                    SessionUtil.setFlashSuccess(req, "Đã lên lịch lưu trữ khóa học thành công! Khóa học sẽ tự động chuyển sang chế độ Lưu trữ vào lúc " + formattedTime + ".");
                } else {
                    SessionUtil.setFlashSuccess(req, "Đã chuyển khóa học sang chế độ Lưu trữ! Khóa học đã được ẩn khỏi danh mục chung.");
                }
            } catch (Exception e) {
                SessionUtil.setFlashError(req, "Lỗi lưu trữ khóa học: " + e.getMessage());
            }
        }
        resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
    }

    /**
     * Mở lại khóa học (Unarchive) đưa về PUBLISHED.
     */
    private void unarchiveCourse(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                long courseId = Long.parseLong(idStr.trim());
                courseService.unarchiveCourse(courseId, currentUser);
                SessionUtil.setFlashSuccess(req, "Đã khôi phục khóa học thành công! Khóa học đã hiển thị trở lại cho học viên mới.");
            } catch (Exception e) {
                SessionUtil.setFlashError(req, e.getMessage());
            }
        }
        resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
    }

    /**
     * Hủy lịch lưu trữ khóa học đang hẹn giờ.
     */
    private void cancelArchive(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                long courseId = Long.parseLong(idStr.trim());
                courseService.cancelArchiveSchedule(courseId, currentUser);
                SessionUtil.setFlashSuccess(req, "Đã hủy lịch lưu trữ khóa học thành công!");
            } catch (Exception e) {
                SessionUtil.setFlashError(req, e.getMessage());
            }
        }
        resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
    }

    /**
     * Gửi yêu cầu duyệt xuất bản khóa học:
     * - Chỉ Expert phụ trách khóa học mới có quyền gửi yêu cầu.
     * - Điều kiện tiên quyết: Khóa học phải có ít nhất 1 chương học và 1 bài học.
     * - Chuyển trạng thái từ DRAFT sang PENDING_REVIEW để Ban Quản Trị xem xét.
     */
    private void requestPublish(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr == null || courseIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
            return;
        }

        try {
            long courseId = Long.parseLong(courseIdStr.trim());
            courseService.checkCourseOwnership(courseId, currentUser);

            CourseDto course = courseService.getCourseDetail(courseId);
            if (course == null) {
                throw new IllegalArgumentException("Không tìm thấy khóa học.");
            }

            if (course.getStatus() == CourseStatus.PUBLISHED) {
                SessionUtil.setFlashError(req, "Khóa học này đã được công khai trên hệ thống.");
            } else if (course.getTotalLessons() <= 0) {
                SessionUtil.setFlashError(req, "Khóa học chưa có bài giảng nào! Vui lòng thêm ít nhất một bài học trước khi gửi yêu cầu duyệt xuất bản.");
            } else {
                courseService.updateCourseStatus(courseId, CourseStatus.PENDING_REVIEW);
                SessionUtil.setFlashSuccess(req, "Đã gửi yêu cầu xét duyệt xuất bản khóa học \"" + course.getTitle() + "\" đến Ban Quản Trị thành công!");
            }
        } catch (Exception e) {
            SessionUtil.setFlashError(req, e.getMessage());
        }

        String from = req.getParameter("from");
        if ("lessons".equalsIgnoreCase(from)) {
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseIdStr);
        } else {
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
        }
    }

    /**
     * Thu hồi yêu cầu xuất bản khóa học:
     * - Cho phép Expert rút lại yêu cầu duyệt để tiếp tục bổ sung/chỉnh sửa nội dung.
     * - Chuyển trạng thái từ PENDING_REVIEW trở lại DRAFT.
     */
    private void cancelRequestPublish(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr == null || courseIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
            return;
        }

        try {
            long courseId = Long.parseLong(courseIdStr.trim());
            courseService.checkCourseOwnership(courseId, currentUser);

            CourseDto course = courseService.getCourseDetail(courseId);
            if (course == null) {
                throw new IllegalArgumentException("Không tìm thấy khóa học.");
            }

            if (course.getStatus() != CourseStatus.PENDING_REVIEW) {
                SessionUtil.setFlashError(req, "Khóa học hiện không ở trạng thái chờ duyệt.");
            } else {
                courseService.updateCourseStatus(courseId, CourseStatus.DRAFT);
                SessionUtil.setFlashSuccess(req, "Đã thu hồi yêu cầu xuất bản. Khóa học đã trở về Bản nháp để bạn tiếp tục chỉnh sửa.");
            }
        } catch (Exception e) {
            SessionUtil.setFlashError(req, e.getMessage());
        }

        String from = req.getParameter("from");
        if ("lessons".equalsIgnoreCase(from)) {
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseIdStr);
        } else {
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
        }
    }

    // =========================================================================
    // 3. NHÓM QUẢN LÝ BÀI HỌC & CHƯƠNG MỤC (LESSON & MODULE MANAGEMENT)
    // =========================================================================

    /**
     * [Màn hình II.4.1] Hiển thị Danh sách Bài học (Lesson List):
     * - [IDOR Defense]: Xác thực user có quyền quản lý khóa học này không.
     * - Lấy toàn bộ chi tiết khóa học (bao gồm cấu trúc cây Modules -> Lessons).
     * - Chuyển tiếp sang views/expert/lesson_list.jsp.
     */
    private void showLessonList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
            try {
                long courseId = Long.parseLong(courseIdStr.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu
                courseService.checkCourseOwnership(courseId, currentUser);

                CourseDto course = courseService.getCourseDetail(courseId);
                req.setAttribute("course", course);
                req.getRequestDispatcher("/WEB-INF/views/expert/lesson_list.jsp").forward(req, resp);
                return;
            } catch (SecurityException se) {
                SessionUtil.setFlashError(req, se.getMessage());
                resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
                return;
            } catch (Exception e) {
                SessionUtil.setFlashError(req, "Không tìm thấy khóa học: " + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
                return;
            }
        }
        resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
    }

    /**
     * [Màn hình II.4.1] Hiển thị Trình soạn thảo Bài học (Lesson Detail / Editor):
     * - [IDOR Defense]: Kiểm tra quyền sở hữu đối với Course, Module và Lesson.
     * - [Tối ưu hiệu năng]: Thay vì tải toàn bộ cây dữ liệu khóa học rồi duyệt vòng lặp,
     *   chỉ lấy danh sách Modules tóm tắt và gọi trực tiếp getLessonById (O(1)).
     * - Chuyển tiếp sang views/expert/lesson_detail.jsp.
     */
    private void showLessonDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        String moduleIdStr = req.getParameter("moduleId");
        String lessonIdStr = req.getParameter("lessonId");

        if (courseIdStr == null || courseIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
            return;
        }

        try {
            long courseId = Long.parseLong(courseIdStr.trim());
            // [IDOR Defense]: Kiểm tra quyền sở hữu khóa học
            courseService.checkCourseOwnership(courseId, currentUser);

            // Lấy thông tin khóa học đầy đủ kèm danh sách bài học để tính chính xác totalLessons cho thứ tự bài mới
            CourseDto course = courseService.getCourseDetail(courseId);
            if (course != null && course.getStatus() == CourseStatus.PENDING_REVIEW) {
                SessionUtil.setFlashError(req, "Khóa học đang ở trạng thái Chờ duyệt nên tạm khóa chỉnh sửa. Vui lòng thu hồi yêu cầu duyệt về Bản nháp nếu muốn tiếp tục sửa bài.");
                resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseId);
                return;
            }
            req.setAttribute("course", course);

            // Kiểm tra xem là chế độ Chỉnh sửa hay Tạo mới
            if (lessonIdStr != null && !lessonIdStr.trim().isEmpty()) {
                long lessonId = Long.parseLong(lessonIdStr.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu bài học
                courseService.checkLessonOwnership(lessonId, currentUser);

                // [Tối ưu hiệu năng]: Lấy trực tiếp Lesson theo ID trong O(1) từ DAO
                LessonDto lesson = courseService.getLessonById(lessonId);
                req.setAttribute("lesson", lesson);
                req.setAttribute("selectedModuleId", lesson.getModuleId());
            } else if (moduleIdStr != null && !moduleIdStr.trim().isEmpty()) {
                long moduleId = Long.parseLong(moduleIdStr.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu chương học
                courseService.checkModuleOwnership(moduleId, currentUser);
                req.setAttribute("selectedModuleId", moduleId);
            }

            req.getRequestDispatcher("/WEB-INF/views/expert/lesson_detail.jsp").forward(req, resp);
        } catch (SecurityException se) {
            SessionUtil.setFlashError(req, se.getMessage());
            resp.sendRedirect(req.getContextPath() + "/expert/dashboard");
        } catch (Exception e) {
            SessionUtil.setFlashError(req, "Lỗi nạp bài học: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseIdStr);
        }
    }

    /**
     * Lưu thông tin Bài học (Thêm mới hoặc Cập nhật):
     * - [IDOR Defense]: Kiểm tra quyền sở hữu chương và bài học.
     * - [Validation]: Kiểm tra đầy đủ qua tầng Service.
     * - [Flash Message]: Lưu thông báo an toàn qua Session, không đính kèm lỗi thô lên URL.
     */
    private void saveLesson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        try {
            LessonDto dto = new LessonDto();
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                long lessonId = Long.parseLong(idStr.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu bài học trước khi sửa
                courseService.checkLessonOwnership(lessonId, currentUser);
                dto.setId(lessonId);
            }

            Long courseId = (courseIdStr != null && !courseIdStr.trim().isEmpty()) ? Long.parseLong(courseIdStr.trim()) : null;
            if (courseId != null) {
                courseService.checkCourseOwnership(courseId, currentUser);
                courseService.checkCourseEditable(courseId);
                dto.setCourseId(courseId);
            }

            String moduleId = req.getParameter("moduleId");
            String newModuleTitle = req.getParameter("newModuleTitle");
            if (courseId != null && ("__NEW__".equals(moduleId) || (newModuleTitle != null && !newModuleTitle.trim().isEmpty()))) {
                long newModId = courseService.createModuleForCourse(courseId, newModuleTitle);
                dto.setModuleId(newModId);
            } else if (moduleId != null && !moduleId.trim().isEmpty() && !"__NONE__".equals(moduleId.trim()) && !"__NEW__".equals(moduleId.trim())) {
                long modId = Long.parseLong(moduleId.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu chương học trước khi lưu
                courseService.checkModuleOwnership(modId, currentUser);
                dto.setModuleId(modId);
            } else if (courseId != null) {
                // Tự động gán vào module mặc định của khóa học nếu người dùng không chọn chương
                dto.setModuleId(courseService.getOrCreateDefaultModuleId(courseId));
            }

            String title = req.getParameter("title");
            String videoUrl = req.getParameter("videoUrl");
            if ((title == null || title.trim().isEmpty() || "Bài mới".equalsIgnoreCase(title.trim()))
                    && videoUrl != null && !videoUrl.trim().isEmpty()) {
                String fetchedTitle = CourseService.fetchYoutubeVideoTitle(videoUrl);
                if (fetchedTitle != null && !fetchedTitle.trim().isEmpty()) {
                    title = fetchedTitle;
                }
            }
            dto.setTitle(title);
            dto.setContent(req.getParameter("content"));
            dto.setVideoUrl(videoUrl);
            dto.setDocumentUrl(req.getParameter("documentUrl"));
            String orderStr = req.getParameter("orderIndex");
            dto.setOrderIndex(orderStr != null && !orderStr.trim().isEmpty() ? Integer.parseInt(orderStr.trim()) : 1);

            String activeStr = req.getParameter("isActive");
            if (activeStr != null && !activeStr.trim().isEmpty()) {
                dto.setActive(Boolean.parseBoolean(activeStr.trim()));
            } else if (dto.getId() != null && dto.getId() > 0) {
                try {
                    LessonDto existing = courseService.getLessonById(dto.getId());
                    if (existing != null) {
                        dto.setActive(existing.isActive());
                    }
                } catch (Exception ignored) {
                }
            }

            courseService.saveLesson(dto);

            // [Xóa bản nháp]: Khi người dùng đã lưu thành công bài học, xóa bỏ draft trên cả User Draft Map và Session
            String draftKey = "draft_lesson_" + (courseIdStr != null ? courseIdStr : "0") + "_" + (dto.getId() != null ? dto.getId() : "new");
            req.getSession().removeAttribute(draftKey);
            if (currentUser != null) {
                USER_DRAFTS.remove(buildUserDraftKey(currentUser.getId(), courseIdStr, dto.getId() != null ? String.valueOf(dto.getId()) : "new"));
                USER_DRAFTS.remove(buildUserDraftKey(currentUser.getId(), courseIdStr, "new"));
            }

            // [Flash Attribute chống XSS]: Lưu thông báo an toàn qua session
            SessionUtil.setFlashSuccess(req, "Đã lưu thông tin bài học thành công!");
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseIdStr);
        } catch (Exception e) {
            // [Flash Attribute chống XSS]: Không truyền error string thô qua URL
            SessionUtil.setFlashError(req, e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + (courseIdStr != null ? courseIdStr : ""));
        }
    }

    /**
     * Tạm ẩn Bài học (Soft-Hide):
     * - [IDOR Defense]: Kiểm tra quyền sở hữu bài học trước khi ẩn.
     */
    private void hideLesson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String lessonIdStr = req.getParameter("lessonId");
        String courseIdStr = req.getParameter("courseId");
        try {
            if (lessonIdStr != null) {
                long lessonId = Long.parseLong(lessonIdStr.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu bài học trước khi cập nhật
                courseService.checkLessonOwnership(lessonId, currentUser);
                courseService.checkLessonEditable(lessonId);
                courseService.hideLesson(lessonId);
                SessionUtil.setFlashSuccess(req, "Đã tạm ẩn bài học thành công!");
            }
        } catch (Exception e) {
            SessionUtil.setFlashError(req, e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + (courseIdStr != null ? courseIdStr : ""));
    }

    /**
     * Xóa Bài học (Lesson):
     * - Khóa học Draft / chưa có học viên: Xóa vĩnh viễn (Hard delete).
     * - Khóa học đã xuất bản / đã có học viên học: Tự động chuyển sang Tạm ẩn (Soft delete).
     * - Hỗ trợ cả AJAX call từ giao diện đếm ngược 5s lẫn form POST truyền thống.
     */
    private void deleteLesson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để thực hiện.\"}");
            return;
        }
        String lessonIdStr = req.getParameter("lessonId");
        String courseIdStr = req.getParameter("courseId");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));
        try {
            if (lessonIdStr != null && !lessonIdStr.trim().isEmpty()) {
                long lessonId = Long.parseLong(lessonIdStr.trim());
                courseService.checkLessonOwnership(lessonId, currentUser);
                courseService.checkLessonEditable(lessonId);
                courseService.deleteLesson(lessonId);

                if (isAjax) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Đã xóa vĩnh viễn bài học khỏi hệ thống thành công!\"}");
                    return;
                }
                SessionUtil.setFlashSuccess(req, "Đã xóa bài học thành công!");
            }
        } catch (Exception e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
                return;
            }
            SessionUtil.setFlashError(req, e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + (courseIdStr != null ? courseIdStr : ""));
    }

    /**
     * Sắp xếp lại thứ tự bài học (Kéo thả Drag & Drop):
     * - Cập nhật danh sách ID bài học theo thứ tự mới trong Module.
     */
    private void reorderLessons(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để thực hiện.\"}");
            return;
        }
        String courseIdStr = req.getParameter("courseId");
        String moduleIdStr = req.getParameter("moduleId");
        String[] lessonIdStrs = req.getParameterValues("lessonIds[]");
        if (lessonIdStrs == null || lessonIdStrs.length == 0) {
            String singleParam = req.getParameter("lessonIds");
            if (singleParam != null && !singleParam.trim().isEmpty()) {
                lessonIdStrs = singleParam.split(",");
            }
        }
        try {
            long courseId = Long.parseLong(courseIdStr.trim());
            long moduleId = Long.parseLong(moduleIdStr.trim());
            courseService.checkCourseOwnership(courseId, currentUser);
            courseService.checkCourseEditable(courseId);
            courseService.checkModuleOwnership(moduleId, currentUser);

            if (lessonIdStrs != null && lessonIdStrs.length > 0) {
                List<Long> orderedIds = new ArrayList<>();
                for (String s : lessonIdStrs) {
                    if (s != null) {
                        String cleaned = s.replace("[", "").replace("]", "").replace("'", "").replace("\"", "").trim();
                        if (!cleaned.isEmpty()) {
                            for (String part : cleaned.split(",")) {
                                if (!part.trim().isEmpty()) {
                                    orderedIds.add(Long.parseLong(part.trim()));
                                }
                            }
                        }
                    }
                }
                courseService.reorderLessons(moduleId, orderedIds);
            }
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\":true,\"message\":\"Đã cập nhật vị trí bài học thành công!\"}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Bật / Tắt trạng thái hiển thị của bài học (Ẩn / Mở lại):
     * - [IDOR Defense]: Kiểm tra quyền sở hữu bài học trước khi thay đổi trạng thái.
     */
    private void toggleLessonStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String lessonIdStr = req.getParameter("lessonId");
        String courseIdStr = req.getParameter("courseId");
        String activeStr = req.getParameter("active");
        try {
            if (lessonIdStr != null) {
                long lessonId = Long.parseLong(lessonIdStr.trim());
                courseService.checkLessonOwnership(lessonId, currentUser);
                courseService.checkLessonEditable(lessonId);

                boolean targetActive;
                if (activeStr != null && !activeStr.trim().isEmpty()) {
                    targetActive = Boolean.parseBoolean(activeStr.trim());
                } else {
                    LessonDto current = courseService.getLessonById(lessonId);
                    targetActive = !current.isActive();
                }

                courseService.toggleLessonActive(lessonId, targetActive);
                if (targetActive) {
                    SessionUtil.setFlashSuccess(req, "Đã mở hiển thị bài học thành công!");
                } else {
                    SessionUtil.setFlashSuccess(req, "Đã tạm ẩn bài học thành công!");
                }
            }
        } catch (Exception e) {
            SessionUtil.setFlashError(req, e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + (courseIdStr != null ? courseIdStr : ""));
    }

    /**
     * Tạo mới hoặc Cập nhật Chương học (Module):
     * - [IDOR Defense]: Kiểm tra quyền sở hữu khóa học và chương học.
     */
    private void saveModule(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String courseId = req.getParameter("courseId");
        try {
            ModuleDto dto = new ModuleDto();
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                long modId = Long.parseLong(idStr.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu chương học
                courseService.checkModuleOwnership(modId, currentUser);
                dto.setId(modId);
            }
            if (courseId != null && !courseId.trim().isEmpty()) {
                long cId = Long.parseLong(courseId.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu khóa học
                courseService.checkCourseOwnership(cId, currentUser);
                courseService.checkCourseEditable(cId);
                dto.setCourseId(cId);
            }
            dto.setTitle(req.getParameter("title"));
            String orderStr = req.getParameter("orderIndex");
            dto.setOrderIndex(orderStr != null && !orderStr.trim().isEmpty() ? Integer.parseInt(orderStr.trim()) : 1);

            courseService.saveModule(dto);
            SessionUtil.setFlashSuccess(req, "Đã lưu chương học thành công!");
        } catch (Exception e) {
            SessionUtil.setFlashError(req, e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + (courseId != null ? courseId : ""));
    }

    /**
     * Xóa Chương học (Module):
     * - [IDOR Defense]: Kiểm tra quyền sở hữu chương học trước khi xóa.
     */
    private void deleteModule(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDto currentUser = SessionUtil.getCurrentUser(req);
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));
        if (currentUser == null) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để thực hiện.\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        String moduleIdStr = req.getParameter("moduleId");
        String courseIdStr = req.getParameter("courseId");
        try {
            if (moduleIdStr != null) {
                long modId = Long.parseLong(moduleIdStr.trim());
                // [IDOR Defense]: Kiểm tra quyền sở hữu chương học
                courseService.checkModuleOwnership(modId, currentUser);
                courseService.checkModuleEditable(modId);
                courseService.deleteModule(modId);
                if (isAjax) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Đã xóa chương học thành công!\"}");
                    return;
                }
                SessionUtil.setFlashSuccess(req, "Đã xóa chương học thành công!");
            }
        } catch (Exception e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"" + (e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Lỗi khi xóa chương học.") + "\"}");
                return;
            }
            SessionUtil.setFlashError(req, e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + (courseIdStr != null ? courseIdStr : ""));
    }

    /**
     * [AJAX API]: AI gợi ý tên Chương học phù hợp dựa theo bài giảng.
     */
    private void suggestModuleTitle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String courseIdStr = req.getParameter("courseId");
        String lessonTitle = req.getParameter("lessonTitle");
        String courseTitle = "";
        if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
            try {
                CourseDto c = courseService.getCourseById(Long.parseLong(courseIdStr.trim()));
                if (c != null) courseTitle = c.getTitle();
            } catch (Exception ignored) {}
        }
        String suggested = courseService.suggestModuleTitle(courseTitle, lessonTitle);
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"moduleTitle\":\"" + (suggested != null ? escapeJson(suggested) : "") + "\"}");
    }
}

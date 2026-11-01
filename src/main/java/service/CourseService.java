package service;

import dao.CourseDao;
import dao.LessonDao;
import dao.LessonProgressDao;
import dao.ModuleDao;
import dao.QuizDao;
import dao.RegistrationDao;
import dao.SettingDao;
import dao.UserDao;
import dto.CourseDto;
import dto.LessonDto;
import dto.ModuleDto;
import dto.QuizDto;
import entity.Course;
import entity.Lesson;
import entity.LessonProgress;
import entity.Module;
import entity.Quiz;
import entity.Registration;
import entity.User;
import dto.SettingDto;
import dto.UserDto;
import entity.enums.CourseStatus;
import entity.enums.LessonProgressStatus;
import entity.enums.RegistrationStatus;
import entity.enums.SettingStatus;
import entity.enums.SettingType;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import util.DbConnection;
import util.GeminiAiUtil;
import util.ValidationUtil;

public class CourseService {
    private final CourseDao courseDao;
    private final ModuleDao moduleDao;
    private final LessonDao lessonDao;
    private final LessonProgressDao lessonProgressDao;
    private final RegistrationDao registrationDao;
    private final QuizDao quizDao = new QuizDao();

    public CourseService(CourseDao courseDao, ModuleDao moduleDao, LessonDao lessonDao,
            LessonProgressDao lessonProgressDao, RegistrationDao registrationDao) {
        this.courseDao = courseDao;
        this.moduleDao = moduleDao;
        this.lessonDao = lessonDao;
        this.lessonProgressDao = lessonProgressDao;
        this.registrationDao = registrationDao;
    }

    public List<CourseDto> searchPublished(String keyword, Long categoryId) {
        try (Connection con = DbConnection.getConnection()) {
            List<Course> list = courseDao.searchPublished(con, keyword, categoryId);
            List<CourseDto> dtos = new ArrayList<>();
            for (Course c : list) {
                dtos.add(buildCourseTree(c));
            }
            return dtos;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tìm kiếm khóa học: " + e.getMessage(), e);
        }
    }

    /**
     * Lấy danh sách các danh mục khóa học đang ACTIVE từ bảng settings trong CSDL.
     */
    public List<SettingDto> getActiveCategories() {
        return fetchActiveCategories();
    }

    public static List<SettingDto> fetchActiveCategories() {
        try (Connection con = DbConnection.getConnection()) {
            SettingDao settingDao = new SettingDao();
            List<entity.Setting> list = settingDao.findByType(con, SettingType.COURSE_CATEGORY);
            List<SettingDto> result = new ArrayList<>();
            for (entity.Setting s : list) {
                if (s.getStatus() == SettingStatus.ACTIVE) {
                    SettingDto dto = new SettingDto();
                    dto.setId(s.getId());
                    dto.setType(s.getType());
                    dto.setName(s.getName());
                    dto.setValue(s.getValue());
                    dto.setPriority(s.getPriority());
                    dto.setStatus(s.getStatus());
                    dto.setDescription(s.getDescription());
                    result.add(dto);
                }
            }
            return result;
        } catch (SQLException e) {
            return new ArrayList<>();
        }
    }

    public List<CourseDto> searchAdminCourses(String keyword, Long categoryId, Long managerId, String status) {
        try (Connection con = DbConnection.getConnection()) {
            List<Course> list = courseDao.searchAdmin(con, keyword, categoryId, managerId, status);
            List<CourseDto> dtos = new ArrayList<>();
            for (Course c : list) {
                dtos.add(buildCourseTree(c));
            }
            return dtos;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tìm kiếm khóa học (Admin): " + e.getMessage(), e);
        }
    }

    public CourseDto getCourseDetail(long courseId) {
        try (Connection con = DbConnection.getConnection()) {
            Course course = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học ID: " + courseId));
            return buildCourseTree(course);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi xem chi tiết khóa học: " + e.getMessage(), e);
        }
    }

    /**
     * [Tối ưu hiệu năng]: Lấy trực tiếp thông tin 1 khóa học theo courseId (chỉ mục ID trong CSDL),
     * phục vụ form sửa thông tin khóa học mà không cần tải toàn bộ cây modules, bài học hay bài kiểm tra.
     */
    public CourseDto getCourseById(long courseId) {
        try (Connection con = DbConnection.getConnection()) {
            Course course = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học ID: " + courseId));
            CourseDto dto = new CourseDto();
            dto.setId(course.getId());
            dto.setTitle(course.getTitle());
            dto.setCategoryId(course.getCategoryId());
            dto.setDescription(course.getDescription());
            dto.setPrice(course.getPrice());
            dto.setStatus(course.getStatus());
            dto.setManagerId(course.getManagerId());
            dto.setExpertId(course.getExpertId());
            dto.setArchiveAt(course.getArchiveAt());
            dto.setArchiveNotice(course.getArchiveNotice());
            if (course.getCategoryId() != null) {
                SettingDao sDao = new SettingDao();
                sDao.findById(con, course.getCategoryId()).ifPresent(s -> dto.setCategoryName(s.getName()));
            }
            return dto;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi xem thông tin khóa học: " + e.getMessage(), e);
        }
    }

    /**
     * [Tối ưu hiệu năng]: Lấy trực tiếp thông tin 1 bài học theo lessonId (O(1)),
     * không cần tải toàn bộ cây khóa học.
     */
    public LessonDto getLessonById(long lessonId) {
        try (Connection con = DbConnection.getConnection()) {
            Lesson l = lessonDao.findById(con, lessonId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài học ID: " + lessonId));
            LessonDto dto = new LessonDto(
                    l.getId(), l.getModuleId(), l.getTitle(), l.getContent(),
                    l.getVideoUrl(), l.getDocumentUrl(), l.getOrderIndex(),
                    LessonProgressStatus.NOT_STARTED);
            dto.setActive(l.isActive());
            return dto;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy thông tin bài học: " + e.getMessage(), e);
        }
    }

    /**
     * [Tối ưu hiệu năng]: Chỉ lấy thông tin khóa học và danh sách Modules nhẹ nhàng
     * để đổ vào dropdown và breadcrumb, bỏ qua việc query nặng nề toàn bộ lessons &
     * quizzes.
     */
    public CourseDto getCourseSummaryWithModules(long courseId) {
        try (Connection con = DbConnection.getConnection()) {
            Course course = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học ID: " + courseId));
            CourseDto dto = new CourseDto();
            dto.setId(course.getId());
            dto.setTitle(course.getTitle());
            dto.setCategoryId(course.getCategoryId());
            dto.setDescription(course.getDescription());
            dto.setPrice(course.getPrice());
            dto.setStatus(course.getStatus());
            dto.setManagerId(course.getManagerId());
            dto.setExpertId(course.getExpertId());
            dto.setArchiveAt(course.getArchiveAt());
            dto.setArchiveNotice(course.getArchiveNotice());

            List<Module> modules = moduleDao.findByCourseId(con, course.getId());
            for (Module m : modules) {
                ModuleDto mDto = new ModuleDto();
                mDto.setId(m.getId());
                mDto.setCourseId(m.getCourseId());
                mDto.setTitle(m.getTitle());
                mDto.setOrderIndex(m.getOrderIndex());
                dto.getModules().add(mDto);
            }
            return dto;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy danh sách chương của khóa học: " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // KIỂM TRA PHÂN QUYỀN CẤP DỮ LIỆU (IDOR DEFENSE)
    // =========================================================================

    public boolean canManageCourse(long courseId, UserDto user) {
        if (user == null) {
            return false;
        }
        String role = user.getRoleName();
        if ("ADMIN".equalsIgnoreCase(role) || "ROLE_ADMIN".equalsIgnoreCase(role)) {
            return true;
        }
        try (Connection con = DbConnection.getConnection()) {
            return courseDao.findById(con, courseId)
                    .map(c -> (c.getExpertId() != null && c.getExpertId().equals(user.getId()))
                            || (c.getManagerId() != null && c.getManagerId().equals(user.getId())))
                    .orElse(false);
        } catch (SQLException e) {
            return false;
        }
    }

    public void checkCourseOwnership(long courseId, UserDto user) {
        if (!canManageCourse(courseId, user)) {
            throw new SecurityException("Từ chối truy cập: Bạn không có quyền quản lý khóa học #" + courseId);
        }
    }

    public void checkModuleOwnership(long moduleId, UserDto user) {
        if (user == null)
            throw new SecurityException("Vui lòng đăng nhập.");
        String role = user.getRoleName();
        if ("ADMIN".equalsIgnoreCase(role) || "ROLE_ADMIN".equalsIgnoreCase(role)) {
            return;
        }
        try (Connection con = DbConnection.getConnection()) {
            Module m = moduleDao.findById(con, moduleId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chương học ID: " + moduleId));
            checkCourseOwnership(m.getCourseId(), user);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra quyền chương học: " + e.getMessage(), e);
        }
    }

    public void checkLessonOwnership(long lessonId, UserDto user) {
        if (user == null)
            throw new SecurityException("Vui lòng đăng nhập.");
        String role = user.getRoleName();
        if ("ADMIN".equalsIgnoreCase(role) || "ROLE_ADMIN".equalsIgnoreCase(role)) {
            return;
        }
        try (Connection con = DbConnection.getConnection()) {
            Lesson l = lessonDao.findById(con, lessonId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài học ID: " + lessonId));
            checkModuleOwnership(l.getModuleId(), user);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra quyền bài học: " + e.getMessage(), e);
        }
    }

    /**
     * Kiểm tra trạng thái khóa học có cho phép chỉnh sửa hay không:
     * - Khi ở trạng thái PENDING_REVIEW (Chờ duyệt), nội dung bị khóa tạm thời.
     * - Người dùng phải thu hồi yêu cầu xuất bản về DRAFT (Bản nháp) mới được sửa tiếp.
     */
    public void checkCourseEditable(long courseId) {
        try (Connection con = DbConnection.getConnection()) {
            Course c = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học ID: " + courseId));
            if (c.getStatus() == CourseStatus.PENDING_REVIEW) {
                throw new IllegalStateException("Khóa học đang ở trạng thái Chờ duyệt nên không thể chỉnh sửa. Vui lòng thu hồi yêu cầu xuất bản về Bản nháp để tiếp tục chỉnh sửa.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra trạng thái khóa học: " + e.getMessage(), e);
        }
    }

    public void checkModuleEditable(long moduleId) {
        try (Connection con = DbConnection.getConnection()) {
            Module m = moduleDao.findById(con, moduleId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chương học ID: " + moduleId));
            checkCourseEditable(m.getCourseId());
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra trạng thái chương học: " + e.getMessage(), e);
        }
    }

    public void checkLessonEditable(long lessonId) {
        try (Connection con = DbConnection.getConnection()) {
            Lesson l = lessonDao.findById(con, lessonId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài học ID: " + lessonId));
            checkModuleEditable(l.getModuleId());
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra trạng thái bài học: " + e.getMessage(), e);
        }
    }

    public List<CourseDto> getManagedCourses(long userId) {
        try (Connection con = DbConnection.getConnection()) {
            List<Course> list = courseDao.findByManagerOrExpert(con, userId);
            List<CourseDto> dtos = new ArrayList<>();
            for (Course c : list) {
                dtos.add(buildCourseTree(c));
            }
            return dtos;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy danh sách khóa học quản lý: " + e.getMessage(), e);
        }
    }

    public List<CourseDto> getAllCourses() {
        try (Connection con = DbConnection.getConnection()) {
            List<Course> list = courseDao.findAll(con);
            List<CourseDto> dtos = new ArrayList<>();
            for (Course c : list) {
                dtos.add(buildCourseTree(c));
            }
            return dtos;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy toàn bộ danh sách khóa học: " + e.getMessage(), e);
        }
    }

    public List<UserDto> getExperts() {
        try (Connection con = DbConnection.getConnection()) {
            UserDao uDao = new UserDao();
            List<User> list = uDao.findByRoleId(con, 4L); // Role 4 = EXPERT
            List<UserDto> dtos = new ArrayList<>();
            for (User u : list) {
                UserDto dto = new UserDto();
                dto.setId(u.getId());
                dto.setUsername(u.getUsername());
                dto.setEmail(u.getEmail());
                dto.setFullName(u.getFullName());
                dto.setRoleId(u.getRoleId());
                dto.setRoleName("EXPERT");
                dto.setAuthProvider(u.getAuthProvider());
                dto.setStatus(u.getStatus());
                dtos.add(dto);
            }
            return dtos;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy danh sách chuyên gia: " + e.getMessage(), e);
        }
    }

    public long saveCourse(CourseDto dto) {
        validateCourse(dto);
        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                long id;
                if (dto.getId() != null && dto.getId() > 0) {
                    Course course = courseDao.findById(con, dto.getId())
                            .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học cần sửa."));
                    course.setTitle(dto.getTitle().trim());
                    if (dto.getCategoryId() != null)
                        course.setCategoryId(dto.getCategoryId());
                    course.setDescription(dto.getDescription());
                    course.setPrice(dto.getPrice());
                    course.setStatus(dto.getStatus() != null ? dto.getStatus() : CourseStatus.DRAFT);
                    if (dto.getManagerId() != null)
                        course.setManagerId(dto.getManagerId());
                    if (dto.getExpertId() != null)
                        course.setExpertId(dto.getExpertId());
                    if (dto.getArchiveAt() != null)
                        course.setArchiveAt(dto.getArchiveAt());
                    if (dto.getArchiveNotice() != null)
                        course.setArchiveNotice(dto.getArchiveNotice());
                    courseDao.update(con, course);
                    id = course.getId();
                } else {
                    Course course = new Course();
                    course.setTitle(dto.getTitle().trim());
                    course.setCategoryId(dto.getCategoryId());
                    course.setCategoryType(SettingType.COURSE_CATEGORY);
                    course.setDescription(dto.getDescription());
                    course.setPrice(dto.getPrice());
                    course.setStatus(dto.getStatus() != null ? dto.getStatus() : CourseStatus.DRAFT);
                    
                    Long managerId = dto.getManagerId();
                    if (managerId == null || managerId <= 0) {
                        UserDao userDao = new UserDao();
                        managerId = userDao.findDefaultManagerId(con).orElse(null);
                        if (managerId == null) {
                            throw new IllegalStateException("Không tìm thấy Quản lý (Manager) hoặc Quản trị viên (Admin) khả dụng trong hệ thống.");
                        }
                    }
                    course.setManagerId(managerId);
                    course.setExpertId(dto.getExpertId());
                    course.setArchiveAt(dto.getArchiveAt());
                    course.setArchiveNotice(dto.getArchiveNotice());
                    id = courseDao.insert(con, course);
                }
                con.commit();
                return id;
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lưu khóa học: " + e.getMessage(), e);
        }
    }

    public List<dto.SettingDto> getCategories() {
        try (Connection con = DbConnection.getConnection()) {
            SettingDao sDao = new SettingDao();
            List<entity.Setting> list = sDao.findByType(con, SettingType.COURSE_CATEGORY);
            List<dto.SettingDto> dtos = new ArrayList<>();
            for (entity.Setting s : list) {
                dto.SettingDto dto = new dto.SettingDto();
                dto.setId(s.getId());
                dto.setType(s.getType());
                dto.setName(s.getName());
                dto.setValue(s.getValue());
                dto.setPriority(s.getPriority());
                dto.setStatus(s.getStatus());
                dto.setDescription(s.getDescription());
                dtos.add(dto);
            }
            return dtos;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy danh mục khóa học: " + e.getMessage(), e);
        }
    }

    public Long getOrCreateCategory(String name) {
        if (name == null || name.trim().isEmpty()) {
            return 6L;
        }
        String trimmedName = name.trim();
        try (Connection con = DbConnection.getConnection()) {
            SettingDao sDao = new SettingDao();
            List<entity.Setting> list = sDao.findByType(con, SettingType.COURSE_CATEGORY);
            for (entity.Setting s : list) {
                if (s.getName().equalsIgnoreCase(trimmedName)) {
                    return s.getId();
                }
            }
            entity.Setting s = new entity.Setting();
            s.setType(SettingType.COURSE_CATEGORY);
            s.setName(trimmedName);
            String val = java.text.Normalizer.normalize(trimmedName, java.text.Normalizer.Form.NFD)
                    .replaceAll("\\p{M}", "")
                    .toUpperCase()
                    .replaceAll("[^A-Z0-9]+", "_")
                    .replaceAll("^_+|_+$", "");
            if (val.isEmpty()) {
                val = "CAT_" + System.currentTimeMillis();
            }
            s.setValue(val);
            s.setPriority(list.size() + 1);
            s.setStatus(entity.enums.SettingStatus.ACTIVE);
            s.setDescription("Danh mục tạo tự động khi tạo khóa học");
            return sDao.insert(con, s);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tạo danh mục mới: " + e.getMessage(), e);
        }
    }

    public String generateCourseDescription(String title, String categoryName) {
        return GeminiAiUtil.generateDescription(title, categoryName);
    }

    public String suggestModuleTitle(String courseTitle, String lessonTitle) {
        return GeminiAiUtil.suggestModuleTitle(courseTitle, lessonTitle);
    }

    public long createModuleForCourse(long courseId, String title) {
        try (Connection con = DbConnection.getConnection()) {
            List<Module> existing = moduleDao.findByCourseId(con, courseId);
            Module m = new Module();
            m.setCourseId(courseId);
            m.setTitle(title != null && !title.trim().isEmpty() ? title.trim() : ("Chương " + (existing.size() + 1)));
            m.setOrderIndex(existing.size() + 1);
            return moduleDao.insert(con, m);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tạo chương học mới: " + e.getMessage(), e);
        }
    }

    /**
     * Kiểm tra tính hợp lệ của việc chuyển đổi trạng thái khóa học.
     * Ma trận chuyển dịch:
     * - DRAFT -> PENDING_REVIEW, PUBLISHED
     * - PENDING_REVIEW -> DRAFT, PUBLISHED
     * - PUBLISHED -> ARCHIVED, DRAFT
     * - ARCHIVED -> PUBLISHED
     */
    public boolean isValidTransition(CourseStatus current, CourseStatus target) {
        if (current == null || target == null) return false;
        if (current == target) return true;
        switch (current) {
            case DRAFT:
                return target == CourseStatus.PENDING_REVIEW || target == CourseStatus.PUBLISHED;
            case PENDING_REVIEW:
                return target == CourseStatus.DRAFT || target == CourseStatus.PUBLISHED;
            case PUBLISHED:
                return target == CourseStatus.ARCHIVED || target == CourseStatus.DRAFT;
            case ARCHIVED:
                return target == CourseStatus.PUBLISHED;
            default:
                return false;
        }
    }

    public void updateCourseStatus(long courseId, CourseStatus targetStatus) {
        try (Connection con = DbConnection.getConnection()) {
            Course course = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học."));

            CourseStatus current = course.getStatus();
            if (current != targetStatus) {
                if (!isValidTransition(current, targetStatus)) {
                    throw new IllegalStateException("Không được phép chuyển trạng thái khóa học từ " + current + " sang " + targetStatus + ".");
                }
            }

            // Khi chuyển sang PUBLISHED: Kiểm tra khóa học phải có ít nhất 1 bài học
            if (targetStatus == CourseStatus.PUBLISHED) {
                List<Module> modules = moduleDao.findByCourseId(con, courseId);
                int count = 0;
                for (Module m : modules) {
                    count += lessonDao.findByModuleId(con, m.getId()).size();
                }
                if (count <= 0) {
                    throw new IllegalStateException("Khóa học chưa có bài giảng nào. Không thể xuất bản khóa học rỗng.");
                }
                // Nếu unarchive hoặc phát hành lại, xóa lịch lưu trữ quá khứ
                if (course.getArchiveAt() != null && !course.getArchiveAt().isAfter(OffsetDateTime.now())) {
                    course.setArchiveAt(null);
                    course.setArchiveNotice(null);
                }
            }

            // Khi chuyển sang PENDING_REVIEW: Kiểm tra khóa học phải có ít nhất 1 bài học
            if (targetStatus == CourseStatus.PENDING_REVIEW) {
                List<Module> modules = moduleDao.findByCourseId(con, courseId);
                int count = 0;
                for (Module m : modules) {
                    count += lessonDao.findByModuleId(con, m.getId()).size();
                }
                if (count <= 0) {
                    throw new IllegalStateException("Khóa học chưa có bài học nào. Vui lòng thêm bài học trước khi gửi yêu cầu duyệt.");
                }
            }

            course.setStatus(targetStatus);
            courseDao.update(con, course);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi cập nhật trạng thái khóa học: " + e.getMessage(), e);
        }
    }

    /**
     * Worker quét và thực thi tự động lịch lưu trữ các khóa học đã tới hạn.
     */
    public int processScheduledArchives() {
        try (Connection con = DbConnection.getConnection()) {
            return courseDao.archiveExpiredCourses(con);
        } catch (SQLException e) {
            System.err.println("[CourseArchiveWorker] Lỗi thực thi lưu trữ tự động: " + e.getMessage());
            return 0;
        }
    }

    /**
     * Lên lịch hoặc thực hiện lưu trữ khóa học (Archive) theo mốc thời gian cụ thể (OffsetDateTime).
     */
    public void scheduleArchiveCourse(long courseId, OffsetDateTime targetArchiveTime, String customNotice, UserDto currentUser) {
        if (currentUser == null) {
            throw new SecurityException("Vui lòng đăng nhập để thực hiện thao tác này.");
        }
        checkCourseOwnership(courseId, currentUser);

        try (Connection con = DbConnection.getConnection()) {
            Course course = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học ID: " + courseId));

            if (course.getStatus() != CourseStatus.PUBLISHED) {
                throw new IllegalStateException("Chỉ khóa học đang công khai (PUBLISHED) mới có thể thiết lập lịch lưu trữ.");
            }

            OffsetDateTime now = OffsetDateTime.now();
            CourseStatus targetStatus;
            OffsetDateTime finalArchiveTime;

            if (targetArchiveTime == null || !targetArchiveTime.isAfter(now)) {
                targetStatus = CourseStatus.ARCHIVED;
                finalArchiveTime = now;
            } else {
                targetStatus = CourseStatus.PUBLISHED;
                finalArchiveTime = targetArchiveTime;
            }

            String notice = (customNotice != null && !customNotice.trim().isEmpty())
                    ? customNotice.trim()
                    : (targetStatus == CourseStatus.ARCHIVED
                        ? "Khóa học này đã được chuyển sang chế độ Lưu trữ (ngừng tuyển sinh mới)."
                        : ("Khóa học này sẽ chính thức ngừng tuyển sinh mới và chuyển sang chế độ Lưu trữ vào ngày "
                            + finalArchiveTime.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) + "."));

            courseDao.updateArchiveStatus(con, courseId, targetStatus, finalArchiveTime, notice);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lưu trữ khóa học: " + e.getMessage(), e);
        }
    }

    /**
     * Lên lịch hoặc thực hiện lưu trữ khóa học (Archive) theo số ngày (Backward compatibility).
     */
    public void scheduleArchiveCourse(long courseId, int noticeDays, String customNotice, UserDto currentUser) {
        OffsetDateTime targetTime = (noticeDays <= 0) 
                ? OffsetDateTime.now() 
                : OffsetDateTime.now().plusDays(noticeDays);
        scheduleArchiveCourse(courseId, targetTime, customNotice, currentUser);
    }


    /**
     * Khôi phục / Hủy lưu trữ (Unarchive) khóa học: Đưa trở lại trạng thái PUBLISHED và xóa thông báo lưu trữ.
     */
    public void unarchiveCourse(long courseId, UserDto currentUser) {
        if (currentUser == null) {
            throw new SecurityException("Vui lòng đăng nhập.");
        }
        checkCourseOwnership(courseId, currentUser);

        try (Connection con = DbConnection.getConnection()) {
            Course course = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học."));

            if (course.getStatus() != CourseStatus.ARCHIVED) {
                throw new IllegalStateException("Khóa học không ở trạng thái lưu trữ (ARCHIVED).");
            }

            courseDao.updateArchiveStatus(con, courseId, CourseStatus.PUBLISHED, null, null);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi khôi phục khóa học: " + e.getMessage(), e);
        }
    }

    /**
     * Hủy lịch lưu trữ khóa học (khi đang trong thời gian thông báo trước vài ngày).
     */
    public void cancelArchiveSchedule(long courseId, UserDto currentUser) {
        if (currentUser == null) {
            throw new SecurityException("Vui lòng đăng nhập.");
        }
        checkCourseOwnership(courseId, currentUser);

        try (Connection con = DbConnection.getConnection()) {
            Course course = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học."));

            if (course.getStatus() != CourseStatus.PUBLISHED || course.getArchiveAt() == null) {
                throw new IllegalStateException("Khóa học không có lịch hẹn lưu trữ nào cần hủy.");
            }

            courseDao.updateArchiveStatus(con, courseId, CourseStatus.PUBLISHED, null, null);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi hủy lịch lưu trữ khóa học: " + e.getMessage(), e);
        }
    }

    public void deleteCourse(long courseId) {
        deleteCourse(courseId, null);
    }

    /**
     * Xóa vĩnh viễn khóa học:
     * - Expert: CHỈ có thể xóa hoàn toàn nếu khóa học ở trạng thái DRAFT và chưa có học viên nào đăng ký.
     * - Khóa học đã xuất bản (PUBLISHED) hoặc đã lưu trữ (ARCHIVED) hoặc đã có học viên: CHỈ Admin mới có quyền xóa hoàn toàn khỏi CSDL.
     */
    public void deleteCourse(long courseId, UserDto currentUser) {
        try (Connection con = DbConnection.getConnection()) {
            Course course = courseDao.findById(con, courseId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học cần xóa ID: " + courseId));

            if (currentUser != null) {
                String role = currentUser.getRoleName();
                boolean isAdmin = "ADMIN".equalsIgnoreCase(role) || (currentUser.getRoleId() != null && currentUser.getRoleId() == 5L);

                if (!isAdmin) {
                    // Kiểm tra quyền sở hữu của Expert / Manager
                    checkCourseOwnership(courseId, currentUser);

                    // Quy tắc: Nếu đã public hoặc có sinh viên học, Expert chỉ được archive, không được xóa vĩnh viễn
                    if (course.getStatus() != CourseStatus.DRAFT) {
                        throw new IllegalStateException("Chuyên gia chỉ có thể xóa hoàn toàn khóa học khi ở trạng thái Nháp (Draft). Khóa học đã xuất bản hoặc đã có sinh viên chỉ có thể Lưu trữ (Archive) hoặc do Quản trị viên (Admin) xóa khỏi hệ thống.");
                    }

                    List<Registration> regs = registrationDao.findByCourseId(con, courseId);
                    if (regs != null && !regs.isEmpty()) {
                        throw new IllegalStateException("Khóa học đã có học viên đăng ký, chỉ Quản trị viên (Admin) mới có quyền xóa hoàn toàn khỏi cơ sở dữ liệu.");
                    }
                }
            }

            con.setAutoCommit(false);
            try {
                // Xóa đăng ký học phụ thuộc nếu có (Admin thực hiện)
                try (java.sql.PreparedStatement ps = con.prepareStatement("DELETE FROM registrations WHERE course_id = ?")) {
                    ps.setLong(1, courseId);
                    ps.executeUpdate();
                }
                boolean deleted = courseDao.delete(con, courseId);
                if (!deleted) {
                    throw new IllegalArgumentException("Không tìm thấy khóa học cần xóa.");
                }
                con.commit();
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi xóa khóa học: " + e.getMessage(), e);
        }
    }

    public long saveModule(ModuleDto dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Dữ liệu chương học không hợp lệ.");
        }
        if (dto.getId() != null && dto.getId() > 0) {
            checkModuleEditable(dto.getId());
        } else if (dto.getCourseId() != null && dto.getCourseId() > 0) {
            checkCourseEditable(dto.getCourseId());
        }
        ValidationUtil.requireText(dto.getTitle(), "Tiêu đề chương");
        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                long id;
                if (dto.getId() != null && dto.getId() > 0) {
                    Module m = moduleDao.findById(con, dto.getId())
                            .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chương cần sửa."));
                    m.setTitle(dto.getTitle().trim());
                    if (dto.getOrderIndex() > 0 && !moduleDao.existsOrderIndex(con, m.getCourseId(), dto.getOrderIndex(), m.getId())) {
                        m.setOrderIndex(dto.getOrderIndex());
                    }
                    moduleDao.update(con, m);
                    id = m.getId();
                } else {
                    if (dto.getCourseId() == null) {
                        throw new IllegalArgumentException("Khóa học không hợp lệ.");
                    }
                    Module m = new Module();
                    m.setCourseId(dto.getCourseId());
                    m.setTitle(dto.getTitle().trim());
                    int order = dto.getOrderIndex();
                    if (order <= 0 || moduleDao.existsOrderIndex(con, dto.getCourseId(), order, null)) {
                        List<Module> currentModules = moduleDao.findByCourseId(con, dto.getCourseId());
                        order = currentModules.stream().mapToInt(Module::getOrderIndex).max().orElse(0) + 1;
                    }
                    m.setOrderIndex(order);
                    id = moduleDao.insert(con, m);
                }
                con.commit();
                return id;
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lưu chương học: " + e.getMessage(), e);
        }
    }

    public void deleteModule(long moduleId) {
        checkModuleEditable(moduleId);
        try (Connection con = DbConnection.getConnection()) {
            List<Lesson> lessons = lessonDao.findByModuleId(con, moduleId);
            if (lessons != null && !lessons.isEmpty()) {
                throw new IllegalArgumentException("Không thể xóa chương học này vì vẫn còn " + lessons.size() + " bài học bên trong. Vui lòng di chuyển hoặc xóa các bài học trước khi xóa chương.");
            }
            List<Quiz> quizzes = quizDao.findByModuleId(con, moduleId);
            if (quizzes != null && !quizzes.isEmpty()) {
                throw new IllegalArgumentException("Không thể xóa chương học này vì vẫn còn " + quizzes.size() + " bài kiểm tra (Quiz) bên trong. Vui lòng di chuyển hoặc xóa bài kiểm tra trước khi xóa chương.");
            }
            boolean deleted = moduleDao.delete(con, moduleId);
            if (!deleted) {
                throw new IllegalArgumentException("Không tìm thấy chương cần xóa.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi xóa chương học: " + e.getMessage(), e);
        }
    }

    public long getOrCreateDefaultModuleId(long courseId) {
        try (Connection con = DbConnection.getConnection()) {
            List<Module> existing = moduleDao.findByCourseId(con, courseId);
            for (Module m : existing) {
                if ("Danh sách bài học".equalsIgnoreCase(m.getTitle()) || "Bài học chung".equalsIgnoreCase(m.getTitle())) {
                    return m.getId();
                }
            }
            if (existing.isEmpty()) {
                Module m = new Module();
                m.setCourseId(courseId);
                m.setTitle("Danh sách bài học");
                m.setOrderIndex(1);
                return moduleDao.insert(con, m);
            }
            // Nếu đã có các chương riêng biệt, tạo một mục "Bài học chung"
            Module m = new Module();
            m.setCourseId(courseId);
            m.setTitle("Bài học chung");
            m.setOrderIndex(existing.size() + 1);
            return moduleDao.insert(con, m);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tìm hoặc tạo chương học mặc định: " + e.getMessage(), e);
        }
    }

    public long saveLesson(LessonDto dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Dữ liệu bài học không hợp lệ.");
        }
        if (dto.getId() != null && dto.getId() > 0) {
            checkLessonEditable(dto.getId());
        } else if (dto.getModuleId() != null && dto.getModuleId() > 0) {
            checkModuleEditable(dto.getModuleId());
        } else if (dto.getCourseId() != null && dto.getCourseId() > 0) {
            checkCourseEditable(dto.getCourseId());
        }
        if (dto.getModuleId() == null || dto.getModuleId() <= 0) {
            if (dto.getCourseId() != null && dto.getCourseId() > 0) {
                dto.setModuleId(getOrCreateDefaultModuleId(dto.getCourseId()));
            } else {
                throw new IllegalArgumentException("Vui lòng chọn khóa học hoặc chương học hợp lệ.");
            }
        }
        if ((dto.getTitle() == null || dto.getTitle().trim().isEmpty() || "Bài mới".equalsIgnoreCase(dto.getTitle().trim()))
                && dto.getVideoUrl() != null && !dto.getVideoUrl().trim().isEmpty()) {
            String fetchedTitle = fetchYoutubeVideoTitle(dto.getVideoUrl());
            if (fetchedTitle != null && !fetchedTitle.trim().isEmpty()) {
                dto.setTitle(fetchedTitle);
            }
        }
        ValidationUtil.requireText(dto.getTitle(), "Tiêu đề bài học");
        ValidationUtil.requireMaxLength(dto.getTitle(), 255, "Tiêu đề bài học");

        int order = dto.getOrderIndex() > 0 ? dto.getOrderIndex() : 1;
        dto.setOrderIndex(order);

        if (dto.getVideoUrl() != null && !dto.getVideoUrl().trim().isEmpty()) {
            String vUrl = dto.getVideoUrl().trim();
            ValidationUtil.requireMaxLength(vUrl, 500, "URL Video");
            if (!ValidationUtil.isValidVideoUrl(vUrl)) {
                throw new IllegalArgumentException(
                        "Định dạng URL Video không hợp lệ (hỗ trợ liên kết YouTube, Google Drive, Vimeo hoặc file MP4).");
            }
            dto.setVideoUrl(vUrl);
        } else {
            dto.setVideoUrl(null);
        }

        if (dto.getDocumentUrl() != null && !dto.getDocumentUrl().trim().isEmpty()) {
            String dUrl = dto.getDocumentUrl().trim();
            ValidationUtil.requireMaxLength(dUrl, 500, "URL Tài liệu");
            if (!ValidationUtil.isValidHttpUrl(dUrl)) {
                throw new IllegalArgumentException("URL Tài liệu đính kèm phải bắt đầu bằng http:// hoặc https://");
            }
            dto.setDocumentUrl(dUrl);
        } else {
            dto.setDocumentUrl(null);
        }

        if (dto.getContent() != null) {
            ValidationUtil.requireMaxLength(dto.getContent(), 65535, "Nội dung bài học");
        }

        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // 1. Kiểm tra chương học có tồn tại và thuộc đúng khóa học hay không
                Module targetModule = moduleDao.findById(con, dto.getModuleId())
                        .orElseThrow(() -> new IllegalArgumentException(
                                "Chương học ID " + dto.getModuleId() + " không tồn tại."));

                if (dto.getCourseId() != null && dto.getCourseId() > 0) {
                    if (!Objects.equals(targetModule.getCourseId(), dto.getCourseId())) {
                        throw new IllegalArgumentException("Chương học ID " + dto.getModuleId() + " không thuộc về khóa học ID " + dto.getCourseId());
                    }
                }

                // 2. Nếu là sửa bài học, kiểm tra bài học cũ có hợp lệ không
                if (dto.getId() != null && dto.getId() > 0) {
                    Lesson existing = lessonDao.findById(con, dto.getId())
                            .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài học cần sửa."));
                    if (!Objects.equals(existing.getModuleId(), dto.getModuleId())) {
                        Module oldMod = moduleDao.findById(con, existing.getModuleId()).orElse(null);
                        if (oldMod != null && !Objects.equals(oldMod.getCourseId(), targetModule.getCourseId())) {
                            throw new IllegalArgumentException("Không thể di chuyển bài học sang chương thuộc khóa học khác.");
                        }

                        // Quy tắc đổi chương:
                        // - Nếu bài học chuyển từ chương ở TRƯỚC (oldMod.orderIndex < targetModule.orderIndex): Đẩy lên ĐẦU chương đích (order_index = 1)
                        // - Nếu bài học chuyển từ chương ở SAU (oldMod.orderIndex >= targetModule.orderIndex): Đẩy xuống CUỐI chương đích (order_index = max + 1)
                        List<Lesson> targetLessons = lessonDao.findByModuleId(con, dto.getModuleId());
                        List<Lesson> otherLessons = new ArrayList<>();
                        for (Lesson tl : targetLessons) {
                            if (!Objects.equals(tl.getId(), dto.getId())) {
                                otherLessons.add(tl);
                            }
                        }

                        if (oldMod != null && oldMod.getOrderIndex() < targetModule.getOrderIndex()) {
                            // Đẩy lên đầu: bài học mới nhận orderIndex = 1, các bài hiện tại dời thành 2, 3, 4...
                            // Dùng 2-phase update với thứ tự âm tạm thời để triệt tiêu hoàn toàn vi phạm unique constraint
                            String tempSql = "UPDATE lessons SET order_index = - ? WHERE id = ?";
                            try (PreparedStatement ps = con.prepareStatement(tempSql)) {
                                for (int i = 0; i < otherLessons.size(); i++) {
                                    ps.setInt(1, (i + 1) * 1000);
                                    ps.setLong(2, otherLessons.get(i).getId());
                                    ps.addBatch();
                                }
                                ps.executeBatch();
                            }
                            String shiftSql = "UPDATE lessons SET order_index = ? WHERE id = ?";
                            try (PreparedStatement ps = con.prepareStatement(shiftSql)) {
                                for (int i = 0; i < otherLessons.size(); i++) {
                                    ps.setInt(1, i + 2); // 2, 3, 4, ...
                                    ps.setLong(2, otherLessons.get(i).getId());
                                    ps.addBatch();
                                }
                                ps.executeBatch();
                            }
                            dto.setOrderIndex(1);
                        } else {
                            // Đẩy xuống cuối chương đích
                            int nextOrder = otherLessons.isEmpty() ? 1 :
                                    (otherLessons.stream().mapToInt(Lesson::getOrderIndex).max().orElse(0) + 1);
                            dto.setOrderIndex(nextOrder);
                        }
                    }
                } else {
                    int maxOrder = lessonDao.findByModuleId(con, dto.getModuleId())
                            .stream().mapToInt(Lesson::getOrderIndex).max().orElse(0);
                    dto.setOrderIndex(maxOrder + 1);
                }

                // 3. Kiểm tra chống trùng thứ tự bài học (order_index) trong cùng một Module (Safety Fallback)
                Long excludeLessonId = (dto.getId() != null && dto.getId() > 0) ? dto.getId() : null;
                if (lessonDao.existsOrderIndex(con, dto.getModuleId(), dto.getOrderIndex(), excludeLessonId)) {
                    int maxOrder = lessonDao.findByModuleId(con, dto.getModuleId())
                            .stream().filter(l -> !Objects.equals(l.getId(), excludeLessonId))
                            .mapToInt(Lesson::getOrderIndex).max().orElse(0);
                    dto.setOrderIndex(maxOrder + 1);
                }

                long id;
                if (dto.getId() != null && dto.getId() > 0) {
                    Lesson l = lessonDao.findById(con, dto.getId())
                            .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài học cần sửa."));
                    l.setModuleId(dto.getModuleId());
                    l.setTitle(dto.getTitle().trim());
                    l.setContent(dto.getContent() != null ? dto.getContent() : "");
                    l.setVideoUrl(dto.getVideoUrl());
                    l.setDocumentUrl(dto.getDocumentUrl());
                    l.setOrderIndex(dto.getOrderIndex());
                    l.setActive(dto.isActive());
                    lessonDao.update(con, l);
                    id = l.getId();
                } else {
                    Lesson l = new Lesson();
                    l.setModuleId(dto.getModuleId());
                    l.setTitle(dto.getTitle().trim());
                    l.setContent(dto.getContent() != null ? dto.getContent() : "");
                    l.setVideoUrl(dto.getVideoUrl());
                    l.setDocumentUrl(dto.getDocumentUrl());
                    l.setOrderIndex(dto.getOrderIndex());
                    l.setActive(dto.isActive());
                    id = lessonDao.insert(con, l);
                }
                con.commit();
                return id;
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lưu bài học: " + e.getMessage(), e);
        }
    }

    /**
     * Sắp xếp lại thứ tự bài học (Kéo thả Drag & Drop):
     * - Hỗ trợ kéo thả trong cùng một chương hoặc kéo thả xuyên chương.
     * - Cập nhật nguyên tử trong một Transaction dùng số âm tạm thời để triệt tiêu vi phạm unique constraint.
     */
    public void reorderLessons(long targetModuleId, List<Long> orderedLessonIds) {
        if (orderedLessonIds == null || orderedLessonIds.isEmpty()) return;
        checkModuleEditable(targetModuleId);
        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // 1. Gán thứ tự tạm thời âm để tránh đụng độ unique constraint (uq_lessons_module_order)
                String tempSql = "UPDATE lessons SET order_index = - ? WHERE id = ?";
                try (PreparedStatement ps = con.prepareStatement(tempSql)) {
                    for (int i = 0; i < orderedLessonIds.size(); i++) {
                        ps.setInt(1, (i + 1) * 1000);
                        ps.setLong(2, orderedLessonIds.get(i));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }

                // 2. Cập nhật module_id đích và thứ tự chính thức từ 1 đến N
                String finalSql = "UPDATE lessons SET module_id = ?, order_index = ?, updated_at = now() WHERE id = ?";
                try (PreparedStatement ps = con.prepareStatement(finalSql)) {
                    for (int i = 0; i < orderedLessonIds.size(); i++) {
                        ps.setLong(1, targetModuleId);
                        ps.setInt(2, i + 1);
                        ps.setLong(3, orderedLessonIds.get(i));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }

                con.commit();
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi cập nhật vị trí bài học: " + e.getMessage(), e);
        }
    }

    /**
     * Lấy ID của Manager khả dụng để phân công cho khóa học mới.
     */
    public Long getDefaultManagerId() {
        try (Connection con = DbConnection.getConnection()) {
            UserDao userDao = new UserDao();
            return userDao.findDefaultManagerId(con).orElse(null);
        } catch (SQLException e) {
            return null;
        }
    }

    /**
     * Tạm ẩn bài học (Soft-Hide thay thế xóa cứng):
     * Bảo toàn toàn vẹn dữ liệu tiến độ và ghi chú của học viên.
     */
    public void hideLesson(long lessonId) {
        toggleLessonActive(lessonId, false);
    }

    @Deprecated
    public void deleteLesson(long lessonId) {
        checkLessonEditable(lessonId);
        try (Connection con = DbConnection.getConnection()) {
            Lesson l = lessonDao.findById(con, lessonId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài học cần xóa."));
            Module m = moduleDao.findById(con, l.getModuleId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chương học của bài này."));
            Course c = courseDao.findById(con, m.getCourseId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học."));

            boolean hasProgress = lessonProgressDao.hasProgress(con, lessonId);
            if (hasProgress || c.getStatus() == CourseStatus.PUBLISHED) {
                toggleLessonActive(lessonId, false);
                throw new IllegalStateException("Bài học này thuộc khóa học đã xuất bản hoặc đã có tiến độ học tập của học viên. Hệ thống đã tự động chuyển bài học sang trạng thái [Đã ẩn] để bảo toàn dữ liệu thay vì xóa vĩnh viễn.");
            }

            boolean deleted = lessonDao.delete(con, lessonId);
            if (!deleted) {
                throw new IllegalArgumentException("Không thể xóa bài học.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi xóa bài học: " + e.getMessage(), e);
        }
    }

    public void toggleLessonActive(long lessonId, boolean isActive) {
        checkLessonEditable(lessonId);
        try (Connection con = DbConnection.getConnection()) {
            boolean updated = lessonDao.updateActiveStatus(con, lessonId, isActive);
            if (!updated) {
                throw new IllegalArgumentException("Không tìm thấy bài học để cập nhật trạng thái.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi cập nhật trạng thái hiển thị bài học: " + e.getMessage(), e);
        }
    }

    public int saveBatchLessons(long courseId, Long moduleId, List<LessonDto> lessons) {
        return saveBatchLessons(courseId, moduleId, null, lessons);
    }

    public int saveBatchLessons(long courseId, Long moduleId, String newModuleTitle, List<LessonDto> lessons) {
        checkCourseEditable(courseId);
        if (lessons == null || lessons.isEmpty()) {
            return 0;
        }
        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                if (moduleId != null && moduleId > 0) {
                    long targetModuleId = moduleId;
                    List<Lesson> currentLessons = lessonDao.findByModuleId(con, targetModuleId);
                    int startOrder = currentLessons.size() + 1;
                    int count = 0;
                    for (LessonDto dto : lessons) {
                        Lesson l = new Lesson();
                        l.setModuleId(targetModuleId);
                        l.setTitle(dto.getTitle() != null && !dto.getTitle().trim().isEmpty() ? dto.getTitle().trim()
                                : ("Bài " + (startOrder + count) + ": Bài giảng"));
                        l.setContent(dto.getContent() != null ? dto.getContent() : "");
                        l.setVideoUrl(dto.getVideoUrl());
                        l.setDocumentUrl(dto.getDocumentUrl());
                        l.setOrderIndex(startOrder + count);
                        lessonDao.insert(con, l);
                        count++;
                    }
                    con.commit();
                    return count;
                } else if (newModuleTitle != null && !newModuleTitle.trim().isEmpty()) {
                    List<Module> existingModules = moduleDao.findByCourseId(con, courseId);
                    Module newModule = new Module();
                    newModule.setCourseId(courseId);
                    newModule.setTitle(newModuleTitle.trim());
                    newModule.setOrderIndex(existingModules.size() + 1);
                    long targetModuleId = moduleDao.insert(con, newModule);

                    int count = 0;
                    for (LessonDto dto : lessons) {
                        Lesson l = new Lesson();
                        l.setModuleId(targetModuleId);
                        l.setTitle(dto.getTitle() != null && !dto.getTitle().trim().isEmpty() ? dto.getTitle().trim()
                                : ("Bài " + (count + 1) + ": Bài giảng"));
                        l.setContent(dto.getContent() != null ? dto.getContent() : "");
                        l.setVideoUrl(dto.getVideoUrl());
                        l.setDocumentUrl(dto.getDocumentUrl());
                        l.setOrderIndex(count + 1);
                        lessonDao.insert(con, l);
                        count++;
                    }
                    con.commit();
                    return count;
                } else {
                    // [GEMINI AI & HEURISTIC MODULE GROUPING]:
                    // Tự động phân tích danh sách tiêu đề bài học và chia thành các Chương học (Modules) hợp lý
                    List<Module> existingModules = moduleDao.findByCourseId(con, courseId);
                    Course c = courseDao.findById(con, courseId).orElse(null);
                    String courseTitle = c != null ? c.getTitle() : "Khóa học";

                    List<String> lessonTitles = new ArrayList<>();
                    for (LessonDto dto : lessons) {
                        lessonTitles.add(dto.getTitle() != null ? dto.getTitle() : "");
                    }

                    List<GeminiAiUtil.ModuleGroup> groups = GeminiAiUtil.groupLessonsIntoModules(courseTitle, lessonTitles);
                    int currentModuleOrder = existingModules.size();
                    int count = 0;

                    for (GeminiAiUtil.ModuleGroup group : groups) {
                        Module mod = new Module();
                        mod.setCourseId(courseId);
                        mod.setTitle(group.getModuleTitle());
                        mod.setOrderIndex(++currentModuleOrder);
                        long targetModuleId = moduleDao.insert(con, mod);

                        int lessonInModuleOrder = 1;
                        for (int idx : group.getLessonIndices()) {
                            if (idx >= 1 && idx <= lessons.size()) {
                                LessonDto dto = lessons.get(idx - 1);
                                Lesson l = new Lesson();
                                l.setModuleId(targetModuleId);
                                l.setTitle(dto.getTitle() != null && !dto.getTitle().trim().isEmpty() ? dto.getTitle().trim()
                                        : ("Bài " + (count + 1) + ": Bài giảng"));
                                l.setContent(dto.getContent() != null ? dto.getContent() : "");
                                l.setVideoUrl(dto.getVideoUrl());
                                l.setDocumentUrl(dto.getDocumentUrl());
                                l.setOrderIndex(lessonInModuleOrder++);
                                lessonDao.insert(con, l);
                                count++;
                            }
                        }
                    }

                    con.commit();
                    return count;
                }
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lưu danh sách bài học hàng loạt: " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // [TÍNH NĂNG]: CÀO YOUTUBE PLAYLIST & NHẬP BÀI HỌC HÀNG LOẠT (BATCH IMPORT)
    // Tag tìm kiếm: #YOUTUBE_PLAYLIST_IMPORT #BATCH_LESSON_PARSER
    // =========================================================================

    /**
     * Bóc tách danh sách bài học từ chuỗi văn bản (hỗ trợ cả nhiều link YouTube đơn lẻ lẫn YouTube Playlist):
     * - Tự động phát hiện tham số danh sách phát (Playlist) dạng 'list=PL...' hoặc 'playlist?list=PL...' hoặc mã ID 'PL...'.
     * - Nếu là Playlist: Tự động gửi request HTTP ngầm lên YouTube để cào toàn bộ video và tiêu đề gốc.
     * - Nếu là Video đơn lẻ: Bóc tách Video ID và lọc tiêu đề tiếng Việt tương ứng trên mỗi dòng.
     * - Cơ chế chống trùng lặp: 'seenVideoIds' loại bỏ các video bị trùng nếu người dùng dán nhiều lần.
     */
    public static class BatchParseResult {
        private String playlistTitle;
        private List<LessonDto> lessons = new ArrayList<>();
        private Long suggestedCategoryId;
        private String suggestedCategoryName;
        private String suggestedDescription;

        public BatchParseResult() {}

        public BatchParseResult(String playlistTitle, List<LessonDto> lessons) {
            this.playlistTitle = playlistTitle;
            this.lessons = lessons != null ? lessons : new ArrayList<>();
        }

        public String getPlaylistTitle() { return playlistTitle; }
        public void setPlaylistTitle(String playlistTitle) { this.playlistTitle = playlistTitle; }
        public List<LessonDto> getLessons() { return lessons; }
        public void setLessons(List<LessonDto> lessons) { this.lessons = lessons; }
        public Long getSuggestedCategoryId() { return suggestedCategoryId; }
        public void setSuggestedCategoryId(Long suggestedCategoryId) { this.suggestedCategoryId = suggestedCategoryId; }
        public String getSuggestedCategoryName() { return suggestedCategoryName; }
        public void setSuggestedCategoryName(String suggestedCategoryName) { this.suggestedCategoryName = suggestedCategoryName; }
        public String getSuggestedDescription() { return suggestedDescription; }
        public void setSuggestedDescription(String suggestedDescription) { this.suggestedDescription = suggestedDescription; }
    }

    public static class YoutubePlaylistData {
        private String title;
        private List<LessonDto> lessons = new ArrayList<>();

        public YoutubePlaylistData() {}

        public YoutubePlaylistData(String title, List<LessonDto> lessons) {
            this.title = title;
            this.lessons = lessons != null ? lessons : new ArrayList<>();
        }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public List<LessonDto> getLessons() { return lessons; }
        public void setLessons(List<LessonDto> lessons) { this.lessons = lessons; }
    }

    private static String unescapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&amp;", "&")
                   .replace("&quot;", "\"")
                   .replace("&#39;", "'")
                   .replace("&lt;", "<")
                   .replace("&gt;", ">")
                   .replace("&apos;", "'");
    }

    public static BatchParseResult parseBatchVideoResult(String text) {
        BatchParseResult result = new BatchParseResult();
        List<LessonDto> list = new ArrayList<>();
        if (text == null || text.trim().isEmpty()) {
            result.setLessons(list);
            return result;
        }

        String[] lines = text.split("\\r?\\n");
        int seq = 1;
        java.util.regex.Pattern playlistPattern = java.util.regex.Pattern.compile(
                "(?:[?&]list=|playlist\\?list=)([a-zA-Z0-9_-]+)|(^PL[a-zA-Z0-9_-]{16,})");
        java.util.regex.Pattern ytIdPattern = java.util.regex.Pattern.compile(
                "(?:youtu\\.be\\/|v\\/|u\\/\\w\\/|embed\\/|watch\\?v=|\\&v=)([a-zA-Z0-9_-]{11})|^([a-zA-Z0-9_-]{11})$");

        java.util.Set<String> processedPlaylistIds = new java.util.HashSet<>();
        java.util.Set<String> seenVideoIds = new java.util.HashSet<>();

        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty())
                continue;

            // 1. Kiểm tra xem dòng có chứa Playlist ID hay không
            String playlistId = null;
            java.util.regex.Matcher plMatcher = playlistPattern.matcher(line);
            if (plMatcher.find()) {
                playlistId = plMatcher.group(1) != null ? plMatcher.group(1) : plMatcher.group(2);
            }

            if (playlistId != null && !processedPlaylistIds.contains(playlistId)) {
                processedPlaylistIds.add(playlistId);
                YoutubePlaylistData playlistData = fetchYoutubePlaylistData(playlistId);
                if (result.getPlaylistTitle() == null && playlistData.getTitle() != null && !playlistData.getTitle().isEmpty()) {
                    result.setPlaylistTitle(playlistData.getTitle());
                }
                List<LessonDto> playlistVideos = playlistData.getLessons();
                if (playlistVideos != null && !playlistVideos.isEmpty()) {
                    for (LessonDto plDto : playlistVideos) {
                        String vidId = extractVideoIdFromUrl(plDto.getVideoUrl());
                        if (vidId != null && seenVideoIds.add(vidId)) {
                            plDto.setOrderIndex(seq++);
                            list.add(plDto);
                        }
                    }
                    continue; // Đã xử lý trọn vẹn toàn bộ Playlist
                }
            }

            // 2. Nếu không phải Playlist (hoặc tải Playlist thất bại), bóc tách video đơn lẻ
            String videoId = null;
            String[] tokens = line.split("\\s+");
            for (String token : tokens) {
                java.util.regex.Matcher m = ytIdPattern.matcher(token);
                if (m.find()) {
                    videoId = m.group(1) != null ? m.group(1) : m.group(2);
                    break;
                }
            }

            if (videoId != null && seenVideoIds.add(videoId)) {
                String cleanLine = line.replaceAll("https?://[^\\s]+", "")
                        .replaceAll("^[0-9]+[\\.\\:\\-]\\s*", "")
                        .replaceAll("^[\\-\\–\\—\\|\\:\\.]+\\s*", "")
                        .replaceAll("\\s*[\\-\\–\\—\\|\\:]+$", "")
                        .trim();
                String title;
                if (!cleanLine.isEmpty() && cleanLine.length() > 2) {
                    title = cleanLine;
                } else {
                    String fetched = fetchYoutubeVideoTitle(videoId);
                    if (fetched != null && !fetched.trim().isEmpty()) {
                        title = fetched;
                    } else {
                        title = "Bài " + seq + ": Video bài giảng";
                    }
                }

                LessonDto dto = new LessonDto();
                dto.setTitle(title);
                dto.setVideoUrl("https://www.youtube.com/embed/" + videoId);
                dto.setOrderIndex(seq++);
                list.add(dto);
            }
        }
        result.setLessons(list);
        autoDetectCategory(result, text);
        return result;
    }

    /**
     * Tự động nhận diện danh mục phù hợp dựa trên tiêu đề Playlist và danh sách tiêu đề bài học.
     */
    public static void autoDetectCategory(BatchParseResult result) {
        autoDetectCategory(result, null);
    }

    public static void autoDetectCategory(BatchParseResult result, String rawInputText) {
        if (result == null) return;

        // Chỉ phân loại khi ĐÃ nhận diện được Playlist hoặc có ít nhất 1 bài học thực tế!
        boolean hasActualContent = (result.getPlaylistTitle() != null && !result.getPlaylistTitle().isEmpty())
                || (result.getLessons() != null && !result.getLessons().isEmpty());
        if (!hasActualContent) {
            return;
        }

        List<SettingDto> activeCategories = fetchActiveCategories();
        String title = result.getPlaylistTitle();
        if (title == null || title.isEmpty()) {
            if (result.getLessons() != null && !result.getLessons().isEmpty()) {
                title = result.getLessons().get(0).getTitle();
            } else if (rawInputText != null && !rawInputText.trim().isEmpty()) {
                title = rawInputText.split("\\r?\\n")[0];
            }
        }

        // 1. [AI CLASSIFICATION]: Thử nhận diện ngữ nghĩa thông minh qua Google Gemini 2.5 Flash Lite
        if (GeminiAiUtil.isAvailable()) {

            StringBuilder ctxBuilder = new StringBuilder();
            if (result.getLessons() != null) {
                int count = 0;
                for (LessonDto l : result.getLessons()) {
                    if (l.getTitle() != null) {
                        ctxBuilder.append(l.getTitle()).append("; ");
                        if (++count >= 10) break; // Lấy tối đa 10 bài đầu để tối ưu token
                    }
                }
            }
            if (rawInputText != null && !rawInputText.trim().isEmpty()) {
                ctxBuilder.append(rawInputText);
            }

            GeminiAiUtil.CategoryResult aiResult = GeminiAiUtil.classifyCourse(title, ctxBuilder.toString(), activeCategories);
            if (aiResult != null && aiResult.getCategoryId() != null) {
                result.setSuggestedCategoryId(aiResult.getCategoryId());
                result.setSuggestedCategoryName(aiResult.getCategoryName());
                result.setSuggestedDescription(aiResult.getSuggestedDescription());
                return; // Phân loại AI thành công!
            }
        }

        // 2. [FALLBACK DYNAMIC]: Nếu AI không phản hồi, đối chiếu trực tiếp với tên các danh mục thực tế từ CSDL
        if (activeCategories != null && !activeCategories.isEmpty()) {
            String searchCorpus = ((title != null ? title : "") + " " + (rawInputText != null ? rawInputText : "")).toLowerCase();
            String normCorpus = removeDiacritics(searchCorpus);
            for (SettingDto cat : activeCategories) {
                if (cat.getName() != null && !cat.getName().trim().isEmpty()) {
                    String normCat = removeDiacritics(cat.getName().toLowerCase());
                    if (normCorpus.contains(normCat)) {
                        result.setSuggestedCategoryId(cat.getId());
                        result.setSuggestedCategoryName(cat.getName());
                        return;
                    }
                }
            }
        }
    }

    private static String removeDiacritics(String str) {
        if (str == null) return "";
        return java.text.Normalizer.normalize(str, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace("đ", "d").replace("Đ", "D")
                .toLowerCase();
    }

    public static List<LessonDto> parseBatchVideoText(String text) {
        return parseBatchVideoResult(text).getLessons();
    }

    /**
     * Tự động kết nối YouTube và cào toàn bộ danh sách video (ID + Tiêu đề) và tên Playlist từ Playlist công khai.
     */
    public static YoutubePlaylistData fetchYoutubePlaylistData(String playlistId) {
        YoutubePlaylistData data = new YoutubePlaylistData();
        if (playlistId == null || playlistId.trim().isEmpty()) {
            return data;
        }
        playlistId = playlistId.trim();

        try {
            java.net.http.HttpClient client = java.net.http.HttpClient.newBuilder()
                    .connectTimeout(java.time.Duration.ofSeconds(10))
                    .followRedirects(java.net.http.HttpClient.Redirect.ALWAYS)
                    .build();

            String url = "https://www.youtube.com/playlist?list=" + playlistId;
            java.net.http.HttpRequest request = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create(url))
                    .timeout(java.time.Duration.ofSeconds(15))
                    .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
                    .header("Accept-Language", "vi,en-US;q=0.9,en;q=0.8")
                    .build();

            java.net.http.HttpResponse<String> response = client.send(request, java.net.http.HttpResponse.BodyHandlers.ofString(java.nio.charset.StandardCharsets.UTF_8));
            if (response.statusCode() != 200) {
                return data;
            }

            String html = response.body();

            // 1. Bóc tách tiêu đề của Playlist
            String plTitle = null;
            java.util.regex.Matcher mOg = java.util.regex.Pattern.compile("<meta property=\"og:title\" content=\"([^\"]+)\"").matcher(html);
            if (mOg.find()) {
                plTitle = unescapeHtml(unescapeUnicode(mOg.group(1)));
            }
            if (plTitle == null || plTitle.isEmpty()) {
                java.util.regex.Matcher mMeta = java.util.regex.Pattern.compile("\"playlistMetadataRenderer\":\\{\"title\":\"([^\"]+)\"").matcher(html);
                if (mMeta.find()) {
                    plTitle = unescapeUnicode(mMeta.group(1));
                }
            }
            if (plTitle == null || plTitle.isEmpty()) {
                java.util.regex.Matcher mTitle = java.util.regex.Pattern.compile("<title>([^<]+?)(?:\\s*-\\s*YouTube)?</title>").matcher(html);
                if (mTitle.find()) {
                    plTitle = unescapeHtml(unescapeUnicode(mTitle.group(1).trim()));
                }
            }
            data.setTitle(plTitle);

            List<LessonDto> list = new ArrayList<>();
            java.util.Set<String> seenIds = new java.util.HashSet<>();
            int seq = 1;

            // Pattern 1: Modern lockupViewModel with title content
            java.util.regex.Pattern p1 = java.util.regex.Pattern.compile(
                    "\"videoId\":\"([a-zA-Z0-9_-]{11})\".{1,1500}?\"title\":\\{\"content\":\"([^\"]+)\"\\}",
                    java.util.regex.Pattern.DOTALL);
            java.util.regex.Matcher m1 = p1.matcher(html);
            while (m1.find()) {
                String vid = m1.group(1);
                String rawTitle = unescapeUnicode(m1.group(2));
                if (seenIds.add(vid)) {
                    LessonDto dto = new LessonDto();
                    dto.setTitle(rawTitle);
                    dto.setVideoUrl("https://www.youtube.com/embed/" + vid);
                    dto.setOrderIndex(seq++);
                    list.add(dto);
                }
            }

            // Pattern 2: Legacy runs/text title
            if (list.isEmpty()) {
                java.util.regex.Pattern p2 = java.util.regex.Pattern.compile(
                        "\"videoId\":\"([a-zA-Z0-9_-]{11})\".{1,1500}?\"title\":\\{\"runs\":\\[\\{\"text\":\"([^\"]+)\"\\}",
                        java.util.regex.Pattern.DOTALL);
                java.util.regex.Matcher m2 = p2.matcher(html);
                while (m2.find()) {
                    String vid = m2.group(1);
                    String rawTitle = unescapeUnicode(m2.group(2));
                    if (seenIds.add(vid)) {
                        LessonDto dto = new LessonDto();
                        dto.setTitle(rawTitle);
                        dto.setVideoUrl("https://www.youtube.com/embed/" + vid);
                        dto.setOrderIndex(seq++);
                        list.add(dto);
                    }
                }
            }

            // Pattern 3: Fallback any videoId
            if (list.isEmpty()) {
                java.util.regex.Pattern p3 = java.util.regex.Pattern.compile(
                        "\"videoId\":\"([a-zA-Z0-9_-]{11})\"",
                        java.util.regex.Pattern.DOTALL);
                java.util.regex.Matcher m3 = p3.matcher(html);
                while (m3.find()) {
                    String vid = m3.group(1);
                    if (seenIds.add(vid)) {
                        LessonDto dto = new LessonDto();
                        dto.setTitle("Bài " + seq + ": Video bài giảng");
                        dto.setVideoUrl("https://www.youtube.com/embed/" + vid);
                        dto.setOrderIndex(seq++);
                        list.add(dto);
                    }
                }
            }
            data.setLessons(list);
        } catch (Exception e) {
            System.err.println("Lỗi khi tải YouTube playlist " + playlistId + ": " + e.getMessage());
        }
        return data;
    }

    public static List<LessonDto> fetchYoutubePlaylistVideos(String playlistId) {
        return fetchYoutubePlaylistData(playlistId).getLessons();
    }

    public static String extractVideoIdFromUrl(String url) {
        if (url == null) return null;
        url = url.trim();
        java.util.regex.Pattern ytIdPattern = java.util.regex.Pattern.compile(
                "(?:youtu\\.be\\/|v\\/|u\\/\\w\\/|embed\\/|shorts\\/|watch\\?v=|\\&v=)([a-zA-Z0-9_-]{11})|^([a-zA-Z0-9_-]{11})$");
        java.util.regex.Matcher m = ytIdPattern.matcher(url);
        if (m.find()) {
            return m.group(1) != null ? m.group(1) : m.group(2);
        }
        return null;
    }

    /**
     * Tự động lấy tiêu đề của video YouTube thông qua oEmbed API hoặc cào trang watch.
     * Hỗ trợ định dạng link watch, shorts, embed, youtu.be hoặc ID 11 ký tự.
     */
    public static String fetchYoutubeVideoTitle(String videoUrlOrId) {
        if (videoUrlOrId == null || videoUrlOrId.trim().isEmpty()) {
            return null;
        }
        String videoId = extractVideoIdFromUrl(videoUrlOrId);
        if (videoId == null) {
            return null;
        }
        try {
            java.net.http.HttpClient client = java.net.http.HttpClient.newBuilder()
                    .connectTimeout(java.time.Duration.ofSeconds(6))
                    .followRedirects(java.net.http.HttpClient.Redirect.ALWAYS)
                    .build();

            // 1. YouTube oEmbed API (nhanh, nhẹ và chuẩn xác)
            String oembedUrl = "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=" + videoId + "&format=json";
            java.net.http.HttpRequest req = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create(oembedUrl))
                    .timeout(java.time.Duration.ofSeconds(6))
                    .header("User-Agent", "Mozilla/5.0")
                    .build();

            java.net.http.HttpResponse<String> resp = client.send(req, java.net.http.HttpResponse.BodyHandlers.ofString(java.nio.charset.StandardCharsets.UTF_8));
            if (resp.statusCode() == 200) {
                String json = resp.body();
                java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"title\"\\s*:\\s*\"([^\"]+)\"").matcher(json);
                if (m.find()) {
                    String title = unescapeUnicode(m.group(1));
                    return unescapeHtml(title);
                }
            }

            // 2. Fallback sang cào trang watch trực tiếp
            String watchUrl = "https://www.youtube.com/watch?v=" + videoId;
            java.net.http.HttpRequest watchReq = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create(watchUrl))
                    .timeout(java.time.Duration.ofSeconds(8))
                    .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
                    .header("Accept-Language", "vi,en-US;q=0.9,en;q=0.8")
                    .build();
            java.net.http.HttpResponse<String> watchResp = client.send(watchReq, java.net.http.HttpResponse.BodyHandlers.ofString(java.nio.charset.StandardCharsets.UTF_8));
            if (watchResp.statusCode() == 200) {
                String html = watchResp.body();
                java.util.regex.Matcher mOg = java.util.regex.Pattern.compile("<meta property=\"og:title\" content=\"([^\"]+)\"").matcher(html);
                if (mOg.find()) {
                    return unescapeHtml(unescapeUnicode(mOg.group(1)));
                }
                java.util.regex.Matcher mTitle = java.util.regex.Pattern.compile("<title>([^<]+?)(?:\\s*-\\s*YouTube)?</title>").matcher(html);
                if (mTitle.find()) {
                    return unescapeHtml(unescapeUnicode(mTitle.group(1).trim()));
                }
            }
        } catch (Exception e) {
            System.err.println("Không thể lấy tiêu đề video YouTube " + videoId + ": " + e.getMessage());
        }
        return null;
    }

    private static String unescapeUnicode(String input) {
        if (input == null) return "";
        java.util.regex.Pattern p = java.util.regex.Pattern.compile("\\\\u([0-9a-fA-F]{4})");
        java.util.regex.Matcher m = p.matcher(input);
        StringBuilder sb = new StringBuilder();
        while (m.find()) {
            char ch = (char) Integer.parseInt(m.group(1), 16);
            m.appendReplacement(sb, java.util.regex.Matcher.quoteReplacement(Character.toString(ch)));
        }
        m.appendTail(sb);
        return sb.toString().replace("\\\"", "\"").replace("\\\\", "\\").trim();
    }

    public CourseDto getLearningContent(long registrationId, long userId) {
        try (Connection con = DbConnection.getConnection()) {
            Registration reg = registrationDao.findById(con, registrationId)
                    .orElseThrow(
                            () -> new IllegalArgumentException("Không tìm thấy đơn đăng ký ID: " + registrationId));
            if (!Long.valueOf(userId).equals(reg.getUserId())) {
                throw new SecurityException("Bạn không có quyền truy cập khóa học này.");
            }
            if (reg.getStatus() != RegistrationStatus.ACTIVE && reg.getStatus() != RegistrationStatus.COMPLETED) {
                throw new IllegalStateException("Đơn đăng ký chưa được kích hoạt hoặc đã bị hủy.");
            }
            Course course = courseDao.findById(con, reg.getCourseId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khóa học tương ứng."));

            // Không cho phép học viên thường truy cập bài học nếu khóa học đang ở trạng thái DRAFT hoặc PENDING_REVIEW
            if (course.getStatus() == CourseStatus.DRAFT || course.getStatus() == CourseStatus.PENDING_REVIEW) {
                boolean isPrivileged = (course.getExpertId() != null && course.getExpertId().equals(userId))
                        || (course.getManagerId() != null && course.getManagerId().equals(userId));
                if (!isPrivileged) {
                    throw new IllegalStateException("Khóa học này đang ở trạng thái Nháp (tạm thời chưa mở học hoặc đang cập nhật nội dung). Vui lòng quay lại sau.");
                }
            }

            CourseDto courseDto = buildCourseTree(course);

            // Populate progress for each lesson
            List<LessonProgress> progresses = lessonProgressDao.findByRegistrationId(con, registrationId);
            for (ModuleDto m : courseDto.getModules()) {
                for (LessonDto l : m.getLessons()) {
                    l.setProgressStatus(LessonProgressStatus.NOT_STARTED);
                    for (LessonProgress lp : progresses) {
                        if (lp.getLessonId().equals(l.getId())) {
                            l.setProgressStatus(lp.getStatus());
                            l.setUserNote(lp.getUserNote());
                            break;
                        }
                    }
                }
            }
            return courseDto;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tải nội dung học tập: " + e.getMessage(), e);
        }
    }

    public void touchLessonProgress(long registrationId, long userId, long lessonId) {
        try (Connection con = DbConnection.getConnection()) {
            Registration reg = registrationDao.findById(con, registrationId).orElse(null);
            if (reg == null || !Long.valueOf(userId).equals(reg.getUserId())) {
                return;
            }
            if (reg.getStatus() != RegistrationStatus.ACTIVE && reg.getStatus() != RegistrationStatus.COMPLETED) {
                return;
            }
            Course course = courseDao.findById(con, reg.getCourseId()).orElse(null);
            if (course == null || course.getStatus() == CourseStatus.DRAFT) {
                return;
            }
            lessonProgressDao.touchLesson(con, registrationId, lessonId);
        } catch (Exception ignored) {
        }
    }

    public void saveLessonNote(long registrationId, long userId, long lessonId, String note) {
        try (Connection con = DbConnection.getConnection()) {
            Registration registration = registrationDao.findById(con, registrationId)
                    .orElseThrow(
                            () -> new IllegalArgumentException("Không tìm thấy đơn đăng ký ID: " + registrationId));
            if (!Long.valueOf(userId).equals(registration.getUserId())) {
                throw new SecurityException("Bạn không có quyền cập nhật ghi chú của đơn đăng ký này.");
            }
            if (registration.getStatus() != RegistrationStatus.ACTIVE
                    && registration.getStatus() != RegistrationStatus.COMPLETED) {
                throw new IllegalStateException("Đơn đăng ký chưa được kích hoạt hoặc đã bị hủy.");
            }
            Lesson lesson = lessonDao.findById(con, lessonId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài học ID: " + lessonId));
            Module module = moduleDao.findById(con, lesson.getModuleId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chương học của bài học."));
            if (!registration.getCourseId().equals(module.getCourseId())) {
                throw new SecurityException("Bài học không thuộc khóa học đã đăng ký.");
            }
            lessonProgressDao.saveUserNote(con, registrationId, lessonId, note);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lưu ghi chú bài học: " + e.getMessage(), e);
        }
    }

    public void updateLessonProgress(long registrationId, long userId, long lessonId, LessonProgressStatus status) {
        try (Connection con = DbConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                Registration registration = registrationDao.findById(con, registrationId)
                        .orElseThrow(
                                () -> new IllegalArgumentException("Không tìm thấy đơn đăng ký ID: " + registrationId));
                if (!Long.valueOf(userId).equals(registration.getUserId())) {
                    throw new SecurityException("Bạn không có quyền cập nhật tiến độ của đơn đăng ký này.");
                }
                if (registration.getStatus() != RegistrationStatus.ACTIVE
                        && registration.getStatus() != RegistrationStatus.COMPLETED) {
                    throw new IllegalStateException("Đơn đăng ký chưa được kích hoạt hoặc đã bị hủy.");
                }
                Lesson lesson = lessonDao.findById(con, lessonId)
                        .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài học ID: " + lessonId));
                Module module = moduleDao.findById(con, lesson.getModuleId())
                        .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chương học của bài học."));
                if (!registration.getCourseId().equals(module.getCourseId())) {
                    throw new SecurityException("Bài học không thuộc khóa học đã đăng ký.");
                }
                LessonProgress lp = new LessonProgress();
                lp.setRegistrationId(registrationId);
                lp.setLessonId(lessonId);
                lp.setStatus(status);
                if (status == LessonProgressStatus.COMPLETED) {
                    lp.setCompletedAt(OffsetDateTime.now());
                }
                lessonProgressDao.upsert(con, lp);

                refreshRegistrationProgress(registrationId);
                con.commit();
            } catch (Exception ex) {
                DbConnection.rollbackQuietly(con);
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi cập nhật tiến trình bài học: " + e.getMessage(), e);
        }
    }

    private void validateCourse(CourseDto dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Dữ liệu khóa học trống.");
        }
        ValidationUtil.requireText(dto.getTitle(), "Tên khóa học");
        ValidationUtil.requirePositive(dto.getPrice(), "Học phí");
    }

    private CourseDto buildCourseTree(Course course) {
        if (course == null)
            return null;
        CourseDto dto = new CourseDto();
        dto.setId(course.getId());
        dto.setTitle(course.getTitle());
        dto.setCategoryId(course.getCategoryId());
        dto.setDescription(course.getDescription());
        dto.setPrice(course.getPrice());
        dto.setStatus(course.getStatus());
        dto.setManagerId(course.getManagerId());
        dto.setExpertId(course.getExpertId());
        dto.setArchiveAt(course.getArchiveAt());
        dto.setArchiveNotice(course.getArchiveNotice());

        try (Connection con = DbConnection.getConnection()) {
            if (course.getCategoryId() != null) {
                SettingDao sDao = new SettingDao();
                sDao.findById(con, course.getCategoryId()).ifPresent(s -> dto.setCategoryName(s.getName()));
            }
            UserDao uDao = new UserDao();
            if (course.getManagerId() != null) {
                uDao.findById(con, course.getManagerId()).ifPresent(u -> dto.setManagerName(u.getFullName()));
            }
            if (course.getExpertId() != null) {
                uDao.findById(con, course.getExpertId()).ifPresent(u -> dto.setExpertName(u.getFullName()));
            }

            // Build modules & lessons
            List<Module> modules = moduleDao.findByCourseId(con, course.getId());
            QuizDao quizDao = new QuizDao();
            for (Module m : modules) {
                ModuleDto mDto = new ModuleDto();
                mDto.setId(m.getId());
                mDto.setCourseId(m.getCourseId());
                mDto.setTitle(m.getTitle());
                mDto.setOrderIndex(m.getOrderIndex());

                List<Lesson> lessons = lessonDao.findByModuleId(con, m.getId());
                for (Lesson l : lessons) {
                    LessonDto lDto = new LessonDto(
                            l.getId(), l.getModuleId(), l.getTitle(), l.getContent(),
                            l.getVideoUrl(), l.getDocumentUrl(), l.getOrderIndex(), LessonProgressStatus.NOT_STARTED);
                    lDto.setActive(l.isActive());
                    mDto.getLessons().add(lDto);
                }

                List<Quiz> quizzes = quizDao.findByModuleId(con, m.getId());
                for (Quiz q : quizzes) {
                    QuizDto qDto = new QuizDto(
                            q.getId(), q.getModuleId(), q.getTitle(), q.getPassScore(),
                            q.getTimeLimitMinutes(), q.getOrderIndex(), new ArrayList<>());
                    mDto.getQuizzes().add(qDto);
                }

                dto.getModules().add(mDto);
            }
        } catch (SQLException ignored) {
        }
        return dto;
    }

    private void refreshRegistrationProgress(long registrationId) {
        try (Connection con = DbConnection.getConnection()) {
            BigDecimal percent = lessonProgressDao.calculateProgress(con, registrationId);
            registrationDao.updateProgress(con, registrationId, percent);
            if (percent.compareTo(BigDecimal.valueOf(100.0)) >= 0) {
                registrationDao.updateStatus(con, registrationId, RegistrationStatus.COMPLETED);
            }
        } catch (SQLException ignored) {
        }
    }
}

-- =====================================================================
-- Courson LMS - PostgreSQL Master Consolidated Schema (14 bảng)
--
-- 14 bảng quan hệ chuẩn hóa:
--   1. settings                  - Vai trò hệ thống & Danh mục khóa học
--   2. users                     - Người dùng & Thông tin hồ sơ cá nhân
--   3. email_verification_tokens - Token xác thực tài khoản qua email
--   4. courses                   - Khóa học, trạng thái & lịch lưu trữ
--   5. modules                   - Chương học / Học phần
--   6. lessons                   - Bài giảng & cờ ẩn/hiện bài học
--   7. quizzes                   - Bài kiểm tra trắc nghiệm
--   8. questions                 - Ngân hàng câu hỏi
--   9. answer_options            - Các phương án trả lời cho câu hỏi
--  10. quiz_questions            - Gán câu hỏi vào đề thi kèm điểm số
--  11. registrations             - Đăng ký khóa học & Thanh toán (Sepay, VNPay)
--  12. lesson_progress           - Tiến độ học bài & Ghi chú cá nhân học viên
--  13. quiz_attempts             - Lịch sử làm bài thi của học viên
--  14. quiz_answers              - Chi tiết lựa chọn và điểm từng câu hỏi
--
-- Tích hợp đầy đủ các bản cập nhật / Migrations:
--   + 01_add_pending_review_to_courses: Trạng thái PENDING_REVIEW cho courses
--   + 02_add_archive_and_notes_columns: archive_at, archive_notice cho courses,
--                                       is_active cho lessons, user_note cho lesson_progress
--   + 03_add_user_profile_columns: avatar_url, phone, birth_date cho users
--   + Đồng bộ tracking: updated_at và created_at cho lesson_progress
-- =====================================================================

-- Xóa các bảng cũ theo thứ tự phụ thuộc (nếu đã tồn tại) để reset sạch sẽ CSDL
DROP TABLE IF EXISTS quiz_answers CASCADE;
DROP TABLE IF EXISTS quiz_attempts CASCADE;
DROP TABLE IF EXISTS lesson_progress CASCADE;
DROP TABLE IF EXISTS registrations CASCADE;
DROP TABLE IF EXISTS quiz_questions CASCADE;
DROP TABLE IF EXISTS answer_options CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS quizzes CASCADE;
DROP TABLE IF EXISTS lessons CASCADE;
DROP TABLE IF EXISTS modules CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS email_verification_tokens CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS settings CASCADE;

BEGIN;

-- ---------------------------------------------------------------------
-- 1. settings  (Role và Category)
-- ---------------------------------------------------------------------
CREATE TABLE settings (
    id          bigserial PRIMARY KEY,
    type        varchar(30)  NOT NULL,
    name        varchar(100) NOT NULL,
    value       varchar(255),
    priority    integer      NOT NULL DEFAULT 0,
    status      varchar(20)  NOT NULL DEFAULT 'ACTIVE',
    description varchar(255),
    created_at  timestamptz  NOT NULL DEFAULT now(),
    updated_at  timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_settings_type_name UNIQUE (type, name),
    CONSTRAINT uq_settings_id_type   UNIQUE (id, type),
    CONSTRAINT chk_settings_type   CHECK (type IN ('USER_ROLE','COURSE_CATEGORY')),
    CONSTRAINT chk_settings_status CHECK (status IN ('ACTIVE','INACTIVE'))
);
CREATE INDEX idx_settings_type_status ON settings (type, status);

-- ---------------------------------------------------------------------
-- 2. users (Bao gồm thông tin hồ sơ Profile: avatar_url, phone, birth_date)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id             bigserial PRIMARY KEY,
    username       varchar(50)  NOT NULL,
    email          varchar(100) NOT NULL,
    password_hash  varchar(255),
    full_name      varchar(100) NOT NULL,
    role_id        bigint       NOT NULL,
    role_type      varchar(30)  NOT NULL DEFAULT 'USER_ROLE',
    auth_provider  varchar(20)  NOT NULL,
    status         varchar(20)  NOT NULL DEFAULT 'ACTIVE',
    avatar_url     varchar(255),
    phone          varchar(20),
    birth_date     date,
    created_at     timestamptz  NOT NULL DEFAULT now(),
    updated_at     timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email    UNIQUE (email),
    CONSTRAINT chk_users_role_type CHECK (role_type = 'USER_ROLE'),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id, role_type) REFERENCES settings (id, type),
    CONSTRAINT chk_users_auth_provider CHECK (auth_provider IN ('LOCAL','GOOGLE')),
    CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE','INACTIVE','BANNED')),
    CONSTRAINT chk_users_password CHECK (
        (auth_provider = 'LOCAL' AND password_hash IS NOT NULL) OR (auth_provider = 'GOOGLE')
    )
);
CREATE INDEX idx_users_role_id ON users (role_id);

-- ---------------------------------------------------------------------
-- 2b. email_verification_tokens (Phục vụ xác thực tài khoản qua email)
-- ---------------------------------------------------------------------
CREATE TABLE email_verification_tokens (
    id           bigserial    PRIMARY KEY,
    user_id      bigint       NOT NULL,
    token_hash   varchar(64)  NOT NULL,
    expires_at   timestamptz  NOT NULL,
    used         boolean      NOT NULL DEFAULT false,
    created_at   timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT fk_evt_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX uq_evt_token_hash ON email_verification_tokens (token_hash);
CREATE INDEX idx_evt_user_id ON email_verification_tokens (user_id);

-- ---------------------------------------------------------------------
-- 3. courses (Hỗ trợ 4 trạng thái, đóng khóa học archive_at, archive_notice)
-- ---------------------------------------------------------------------
CREATE TABLE courses (
    id             bigserial PRIMARY KEY,
    title          varchar(200) NOT NULL,
    category_id    bigint,
    category_type  varchar(30)  NOT NULL DEFAULT 'COURSE_CATEGORY',
    description    text,
    price          numeric(12,2) NOT NULL DEFAULT 0,
    status         varchar(20)   NOT NULL DEFAULT 'DRAFT',
    manager_id     bigint        NOT NULL,
    expert_id      bigint,
    created_at     timestamptz   NOT NULL DEFAULT now(),
    updated_at     timestamptz   NOT NULL DEFAULT now(),
    archive_at     timestamptz,
    archive_notice text,
    CONSTRAINT chk_courses_category_type CHECK (category_type = 'COURSE_CATEGORY'),
    CONSTRAINT fk_courses_category FOREIGN KEY (category_id, category_type) REFERENCES settings (id, type),
    CONSTRAINT fk_courses_manager  FOREIGN KEY (manager_id) REFERENCES users (id),
    CONSTRAINT fk_courses_expert   FOREIGN KEY (expert_id)  REFERENCES users (id),
    CONSTRAINT chk_courses_status CHECK (status IN ('DRAFT','PENDING_REVIEW','PUBLISHED','ARCHIVED')),
    CONSTRAINT chk_courses_price  CHECK (price >= 0)
);
CREATE INDEX idx_courses_manager_id  ON courses (manager_id);
CREATE INDEX idx_courses_expert_id   ON courses (expert_id);
CREATE INDEX idx_courses_category_id ON courses (category_id);

-- ---------------------------------------------------------------------
-- 4. modules
-- ---------------------------------------------------------------------
CREATE TABLE modules (
    id          bigserial PRIMARY KEY,
    course_id   bigint       NOT NULL,
    title       varchar(200) NOT NULL,
    order_index integer      NOT NULL,
    created_at  timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT fk_modules_course FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE,
    CONSTRAINT uq_modules_course_order UNIQUE (course_id, order_index)
);
CREATE INDEX idx_modules_course_id ON modules (course_id);

-- ---------------------------------------------------------------------
-- 5. lessons (Hỗ trợ cờ is_active để ẩn mềm thay vì xóa bài giảng)
-- ---------------------------------------------------------------------
CREATE TABLE lessons (
    id           bigserial PRIMARY KEY,
    module_id    bigint       NOT NULL,
    title        varchar(200) NOT NULL,
    content      text,
    video_url    varchar(500),
    document_url varchar(500),
    order_index  integer      NOT NULL,
    is_active    boolean      NOT NULL DEFAULT true,
    created_at   timestamptz  NOT NULL DEFAULT now(),
    updated_at   timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT fk_lessons_module FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE,
    CONSTRAINT uq_lessons_module_order UNIQUE (module_id, order_index)
);
CREATE INDEX idx_lessons_module_id ON lessons (module_id);

-- ---------------------------------------------------------------------
-- 6. quizzes
-- ---------------------------------------------------------------------
CREATE TABLE quizzes (
    id                 bigserial PRIMARY KEY,
    module_id          bigint       NOT NULL,
    title              varchar(200) NOT NULL,
    pass_score         numeric(5,2) NOT NULL,
    time_limit_minutes integer,
    order_index        integer      NOT NULL,
    created_at         timestamptz  NOT NULL DEFAULT now(),
    updated_at         timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT fk_quizzes_module FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE,
    CONSTRAINT uq_quizzes_module_order UNIQUE (module_id, order_index),
    CONSTRAINT uq_quizzes_id_module UNIQUE (id, module_id),
    CONSTRAINT chk_quizzes_pass_score CHECK (pass_score >= 0 AND pass_score <= 100)
);
CREATE INDEX idx_quizzes_module_id ON quizzes (module_id);

-- ---------------------------------------------------------------------
-- 7. questions (Ngân hàng câu hỏi)
-- ---------------------------------------------------------------------
CREATE TABLE questions (
    id             bigserial PRIMARY KEY,
    module_id      bigint       NOT NULL,
    question_text  text         NOT NULL,
    question_type  varchar(20)  NOT NULL,
    default_points numeric(5,2) NOT NULL DEFAULT 1,
    created_at     timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT fk_questions_module FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE,
    CONSTRAINT uq_questions_id_module UNIQUE (id, module_id),
    CONSTRAINT chk_questions_type CHECK (question_type IN ('SINGLE_CHOICE','MULTI_CHOICE','TRUE_FALSE')),
    CONSTRAINT chk_questions_points CHECK (default_points > 0)
);
CREATE INDEX idx_questions_module_id ON questions (module_id);

-- ---------------------------------------------------------------------
-- 8. answer_options
-- ---------------------------------------------------------------------
CREATE TABLE answer_options (
    id          bigserial PRIMARY KEY,
    question_id bigint       NOT NULL,
    option_text varchar(500) NOT NULL,
    is_correct  boolean      NOT NULL DEFAULT false,
    order_index integer      NOT NULL DEFAULT 0,
    CONSTRAINT fk_answer_options_question FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
);
CREATE INDEX idx_answer_options_question_id ON answer_options (question_id);

-- ---------------------------------------------------------------------
-- 9. quiz_questions
-- ---------------------------------------------------------------------
CREATE TABLE quiz_questions (
    id          bigserial PRIMARY KEY,
    quiz_id     bigint       NOT NULL,
    question_id bigint       NOT NULL,
    module_id   bigint       NOT NULL,
    order_index integer      NOT NULL,
    points      numeric(5,2) NOT NULL,
    CONSTRAINT fk_quiz_questions_quiz     FOREIGN KEY (quiz_id, module_id)     REFERENCES quizzes (id, module_id)   ON DELETE CASCADE,
    CONSTRAINT fk_quiz_questions_question FOREIGN KEY (question_id, module_id) REFERENCES questions (id, module_id) ON DELETE CASCADE,
    CONSTRAINT uq_quiz_questions_quiz_question UNIQUE (quiz_id, question_id),
    CONSTRAINT uq_quiz_questions_quiz_order    UNIQUE (quiz_id, order_index),
    CONSTRAINT chk_quiz_questions_points CHECK (points > 0)
);
CREATE INDEX idx_quiz_questions_quiz_id     ON quiz_questions (quiz_id);
CREATE INDEX idx_quiz_questions_question_id ON quiz_questions (question_id);

-- ---------------------------------------------------------------------
-- 10. registrations
-- ---------------------------------------------------------------------
CREATE TABLE registrations (
    id                  bigserial PRIMARY KEY,
    user_id             bigint       NOT NULL,
    course_id           bigint       NOT NULL,
    registration_date   timestamptz  NOT NULL DEFAULT now(),
    progress_percentage numeric(5,2) NOT NULL DEFAULT 0,
    status              varchar(20)  NOT NULL DEFAULT 'PENDING',
    payment_method      varchar(20),
    payment_code        varchar(100),
    payment_amount      numeric(12,2) NOT NULL DEFAULT 0,
    payment_status      varchar(20)  NOT NULL DEFAULT 'PENDING',
    paid_at             timestamptz,
    CONSTRAINT fk_registrations_user   FOREIGN KEY (user_id)   REFERENCES users (id),
    CONSTRAINT fk_registrations_course FOREIGN KEY (course_id) REFERENCES courses (id),
    CONSTRAINT uq_registrations_user_course UNIQUE (user_id, course_id),
    CONSTRAINT chk_registrations_status CHECK (status IN ('PENDING','ACTIVE','COMPLETED','CANCELLED')),
    CONSTRAINT chk_registrations_progress CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    CONSTRAINT chk_registrations_payment_method CHECK (payment_method IS NULL OR payment_method IN ('SEPAY','VNPAY')),
    CONSTRAINT chk_registrations_payment_status CHECK (payment_status IN ('FREE','PENDING','SUCCESS','FAILED')),
    CONSTRAINT chk_registrations_payment_amount CHECK (payment_amount >= 0),
    CONSTRAINT chk_registrations_paid_fields CHECK (
        payment_status <> 'SUCCESS' OR (payment_code IS NOT NULL AND paid_at IS NOT NULL)
    ),
    CONSTRAINT chk_registrations_access CHECK (
        status NOT IN ('ACTIVE','COMPLETED') OR payment_status IN ('SUCCESS','FREE')
    )
);
CREATE INDEX idx_registrations_user_id   ON registrations (user_id);
CREATE INDEX idx_registrations_course_id ON registrations (course_id);
CREATE UNIQUE INDEX uq_registrations_payment_code
    ON registrations (payment_code)
    WHERE payment_code IS NOT NULL;

-- ---------------------------------------------------------------------
-- 11. lesson_progress (Bao gồm user_note, created_at, updated_at)
-- ---------------------------------------------------------------------
CREATE TABLE lesson_progress (
    id              bigserial PRIMARY KEY,
    registration_id bigint      NOT NULL,
    lesson_id       bigint      NOT NULL,
    status          varchar(20) NOT NULL DEFAULT 'NOT_STARTED',
    completed_at    timestamptz,
    user_note       text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT fk_lesson_progress_registration FOREIGN KEY (registration_id) REFERENCES registrations (id) ON DELETE CASCADE,
    CONSTRAINT fk_lesson_progress_lesson       FOREIGN KEY (lesson_id)       REFERENCES lessons (id) ON DELETE CASCADE,
    CONSTRAINT uq_lesson_progress_registration_lesson UNIQUE (registration_id, lesson_id),
    CONSTRAINT chk_lesson_progress_status CHECK (status IN ('NOT_STARTED','IN_PROGRESS','COMPLETED'))
);
CREATE INDEX idx_lesson_progress_registration_id ON lesson_progress (registration_id);
CREATE INDEX idx_lesson_progress_lesson_id       ON lesson_progress (lesson_id);

-- ---------------------------------------------------------------------
-- 12. quiz_attempts
-- ---------------------------------------------------------------------
CREATE TABLE quiz_attempts (
    id              bigserial PRIMARY KEY,
    registration_id bigint       NOT NULL,
    quiz_id         bigint       NOT NULL,
    submitted_at    timestamptz  NOT NULL DEFAULT now(),
    total_score     numeric(6,2) NOT NULL,
    pass_status     boolean      NOT NULL,
    CONSTRAINT fk_quiz_attempts_registration FOREIGN KEY (registration_id) REFERENCES registrations (id) ON DELETE CASCADE,
    CONSTRAINT fk_quiz_attempts_quiz         FOREIGN KEY (quiz_id)         REFERENCES quizzes (id) ON DELETE CASCADE,
    CONSTRAINT uq_quiz_attempts_registration_quiz UNIQUE (registration_id, quiz_id),
    CONSTRAINT chk_quiz_attempts_score CHECK (total_score >= 0)
);
CREATE INDEX idx_quiz_attempts_registration_id ON quiz_attempts (registration_id);
CREATE INDEX idx_quiz_attempts_quiz_id         ON quiz_attempts (quiz_id);

-- ---------------------------------------------------------------------
-- 13. quiz_answers
-- ---------------------------------------------------------------------
CREATE TABLE quiz_answers (
    id                 bigserial PRIMARY KEY,
    quiz_attempt_id    bigint       NOT NULL,
    question_id        bigint       NOT NULL,
    selected_option_id bigint,
    is_correct         boolean      NOT NULL DEFAULT false,
    score              numeric(5,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_quiz_answers_attempt  FOREIGN KEY (quiz_attempt_id)     REFERENCES quiz_attempts (id) ON DELETE CASCADE,
    CONSTRAINT fk_quiz_answers_question FOREIGN KEY (question_id)        REFERENCES questions (id) ON DELETE CASCADE,
    CONSTRAINT fk_quiz_answers_option   FOREIGN KEY (selected_option_id) REFERENCES answer_options (id) ON DELETE SET NULL,
    CONSTRAINT uq_quiz_answers_attempt_question UNIQUE (quiz_attempt_id, question_id)
);
CREATE INDEX idx_quiz_answers_attempt_id  ON quiz_answers (quiz_attempt_id);
CREATE INDEX idx_quiz_answers_question_id ON quiz_answers (question_id);

-- =====================================================================
-- SEED DATA CƠ BẢN KHỞI TẠO HỆ THỐNG
-- =====================================================================

-- 1. Roles (SettingType = USER_ROLE)
INSERT INTO settings (id, type, name, value, priority, status, description) VALUES
    (1, 'USER_ROLE', 'Guest',   'GUEST',   1, 'ACTIVE', 'Khách truy cập, chưa đăng nhập'),
    (2, 'USER_ROLE', 'Student', 'STUDENT', 2, 'ACTIVE', 'Học viên'),
    (3, 'USER_ROLE', 'Manager', 'MANAGER', 3, 'ACTIVE', 'Quản lý khoá học'),
    (4, 'USER_ROLE', 'Expert',  'EXPERT',  4, 'ACTIVE', 'Chuyên gia tạo nội dung'),
    (5, 'USER_ROLE', 'Admin',   'ADMIN',   5, 'ACTIVE', 'Quản trị hệ thống')
ON CONFLICT (type, name) DO NOTHING;

-- 2. Course Categories (SettingType = COURSE_CATEGORY - Đầy đủ 12 danh mục chuẩn)
INSERT INTO settings (id, type, name, value, priority, status, description) VALUES
    (6,  'COURSE_CATEGORY', 'Lập trình',               'PROGRAMMING',  1,  'ACTIVE', 'Khoá học lập trình, thuật toán, phát triển phần mềm'),
    (7,  'COURSE_CATEGORY', 'Khoa học Dữ liệu & AI',   'DATA_AI',      2,  'ACTIVE', 'Trí tuệ nhân tạo, phân tích dữ liệu, Machine Learning'),
    (8,  'COURSE_CATEGORY', 'Thiết kế',                'DESIGN',       3,  'ACTIVE', 'Thiết kế đồ họa, UI/UX, mỹ thuật số'),
    (9,  'COURSE_CATEGORY', 'Kinh doanh',              'BUSINESS',     4,  'ACTIVE', 'Quản trị kinh doanh, khởi nghiệp, lãnh đạo doanh nghiệp'),
    (10, 'COURSE_CATEGORY', 'Marketing',              'MARKETING',    5,  'ACTIVE', 'Marketing số, truyền thông, tiếp thị và thương hiệu'),
    (11, 'COURSE_CATEGORY', 'Ngoại ngữ',              'LANGUAGES',    6,  'ACTIVE', 'Tiếng Anh giao tiếp, TOEIC, IELTS, Tiếng Nhật, Hàn, Hoa'),
    (12, 'COURSE_CATEGORY', 'Kỹ năng mềm',            'SOFT_SKILLS',  7,  'ACTIVE', 'Kỹ năng giao tiếp, làm việc nhóm, tư duy phản biện'),
    (13, 'COURSE_CATEGORY', 'Tài chính',              'FINANCE',      8,  'ACTIVE', 'Quản lý tài chính cá nhân, đầu tư'),
    (14, 'COURSE_CATEGORY', 'Nghệ thuật & Sáng tạo',   'ART_CREATIVE', 9,  'ACTIVE', 'Nhiếp ảnh, quay dựng video, âm nhạc, hội họa'),
    (15, 'COURSE_CATEGORY', 'Nhân tướng học',         'PHYSIOGNOMY',  10, 'ACTIVE', 'Kiến thức nhân tướng học, diện mạo và nhân trắc học ứng dụng'),
    (16, 'COURSE_CATEGORY', 'Tử Vi & Phong Thủy',     'TU_VI',        11, 'ACTIVE', 'Nghiên cứu lá số Tử Vi, âm dương ngũ hành và giải đoán vận hạn'),
    (17, 'COURSE_CATEGORY', 'Chiêm tinh học',         'ASTROLOGY',    12, 'ACTIVE', 'Khám phá bí mật 12 cung hoàng đạo và chiêm tinh học ứng dụng')
ON CONFLICT (type, name) DO NOTHING;

-- Cập nhật sequence của bảng settings lên giá trị tiếp theo
SELECT setval('settings_id_seq', (SELECT MAX(id) FROM settings));

-- 3. Initial Users (Mật khẩu mặc định: admin123 băm bằng BCrypt $2a$12)
INSERT INTO users (id, username, email, password_hash, full_name, role_id, role_type, auth_provider, status, avatar_url, phone, birth_date) VALUES
    (1, 'admin', 'admin@courson.edu.vn', '$2a$12$Jl9I6uWRXBnYCHQmmh8o8eFWKFwQacRW3EWaTTLREbC6m8cWo2GTS', 'Quản trị viên Hệ thống', 5, 'USER_ROLE', 'LOCAL', 'ACTIVE', NULL, '0901234567', '1990-01-01'),
    (2, 'manager1', 'manager@courson.edu.vn', '$2a$12$Jl9I6uWRXBnYCHQmmh8o8eFWKFwQacRW3EWaTTLREbC6m8cWo2GTS', 'Quản lý Khóa học', 3, 'USER_ROLE', 'LOCAL', 'ACTIVE', NULL, '0912345678', '1992-05-15'),
    (3, 'expert1', 'expert@courson.edu.vn', '$2a$12$Jl9I6uWRXBnYCHQmmh8o8eFWKFwQacRW3EWaTTLREbC6m8cWo2GTS', 'Chuyên gia Nội dung', 4, 'USER_ROLE', 'LOCAL', 'ACTIVE', NULL, '0923456789', '1988-10-20'),
    (4, 'student1', 'student@courson.edu.vn', '$2a$12$Jl9I6uWRXBnYCHQmmh8o8eFWKFwQacRW3EWaTTLREbC6m8cWo2GTS', 'Học viên Nguyễn Văn A', 2, 'USER_ROLE', 'LOCAL', 'ACTIVE', NULL, '0934567890', '2002-12-12')
ON CONFLICT (username) DO NOTHING;

-- Cập nhật sequence của bảng users lên giá trị tiếp theo
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

COMMIT;

# 📋 BÁO CÁO KIỂM TOÁN AN TOÀN & DANH MỤC KIỂM THỬ HỒI QUY
## Project: Courson LMS (SWP391 - SE2051-NET Group 5)

---

## 📌 1. Tổng quan Kiểm toán Hệ thống (Executive Summary)

Báo cáo này tổng hợp kết quả kiểm toán kỹ thuật (Technical Audit), phân tích các lỗ hổng tiềm ẩn về an toàn dữ liệu, tính toàn vẹn tham chiếu cơ sở dữ liệu và trải nghiệm người dùng, đồng thời cung cấp Danh mục Kiểm thử Hồi quy (Regression Test Checklist) nhằm đảm bảo hệ thống vận hành ổn định, không phát sinh lỗi (Zero Regressions).

---

## 🔍 2. Chi tiết Kết quả Kiểm toán & Giải pháp Khắc phục

| Mã lỗi / Rủi ro | Vấn đề phát hiện | Rủi ro kỹ thuật & nghiệp vụ | Giải pháp kiến trúc đã triển khai | Trạng thái |
| :--- | :--- | :--- | :--- | :---: |
| **AUDIT-01** | Hardcode `manager_id = 2L` khi Expert tạo khóa học nháp mới | **Nghiêm trọng (High):** Vi phạm khóa ngoại `fk_courses_manager` nếu database không có user ID=2; gây thắt cổ chai khi dồn 100% khóa học cho 1 manager. | Thêm thuật toán `findDefaultManagerId` trong `UserDao`: Ưu tiên Manager đang ACTIVE có ít khóa học nhất (cân bằng tải); dự phòng Admin ACTIVE; bảo vệ 2 lớp tại Controller và Service. | **ĐÃ KHẮC PHỤC** |
| **AUDIT-02** | Ràng buộc CHECK trong `courses` thiếu `PENDING_REVIEW` | **Nghiêm trọng (High):** Lỗi `PSQLException: new row violates check constraint "chk_courses_status"` khi Expert gửi duyệt xuất bản. | Cập nhật `database/schema.sql` và tạo script di chuyển dữ liệu `database/migrations/01_add_pending_review_to_courses.sql`. | **ĐÃ KHẮC PHỤC** |
| **AUDIT-03** | Endpoints thay đổi dữ liệu chấp nhận phương thức GET | **Trung bình (Medium):** Nguy cơ tấn công CSRF qua liên kết ảnh/bot crawler vô tình kích hoạt ẩn bài học hoặc gửi duyệt khóa học. | Chặn 100% GET tại các mutating actions trong `LessonServlet`. Nâng cấp `showConfirmModal` trong `footer.jsp` để tự động tạo form ẩn gửi bằng phương thức `POST`. | **ĐÃ KHẮC PHỤC** |
| **AUDIT-04** | Trạng thái khóa học chuyển dịch tự do không kiểm soát | **Trung bình (Medium):** Khóa học nháp chưa có bài học có thể bị xuất bản nhầm; khóa học DRAFT có thể bị lưu trữ sai luồng. | Thiết lập Ma trận Chuyển dịch Trạng thái (`isValidTransition`); siết điều kiện: chỉ xuất bản khi có ít nhất 1 bài học, chỉ lưu trữ khóa học `PUBLISHED`, unarchive chỉ áp dụng cho `ARCHIVED`. | **ĐÃ KHẮC PHỤC** |
| **AUDIT-05** | Thiếu xác thực Module - Course & Trùng thứ tự bài học | **Trung bình (Medium):** Lỗi `uq_lessons_module_order` khi nhập trùng `order_index`; nguy cơ gán nhầm module của khóa học khác. | Xác thực `module.getCourseId() == dto.getCourseId()`; gọi `lessonDao.existsOrderIndex` kiểm tra trùng thứ tự trước khi thực thi lệnh ghi và đưa ra thông báo thân thiện. | **ĐÃ KHẮC PHỤC** |
| **AUDIT-06** | Mất dữ liệu soạn thảo bản nháp khi submit bị lỗi | **Thấp - Trải nghiệm (Low/UX):** Khi người dùng nhấn "Lưu bài học", `localStorage` bị xóa ngay lập tức trước khi server phản hồi; nếu validate thất bại sẽ mất trắng bài soạn. | Giữ nguyên bản nháp local khi submit form; chỉ xóa bản nháp sau khi server xác nhận lưu thành công (qua cờ `savedSuccess=true` hoặc flash success). | **ĐÃ KHẮC PHỤC** |
| **AUDIT-07** | Lịch hẹn lưu trữ khóa học không tự động kích hoạt | **Trung bình (Medium):** Khi tới hạn `archive_at`, nếu không có người truy cập thì trạng thái khóa học vẫn giữ `PUBLISHED`. | Cài đặt `CourseArchiveSchedulerListener` (Worker nền chạy định kỳ mỗi 60 giây) tự động quét và kích hoạt `archiveExpiredCourses` khi Tomcat chạy. | **ĐÃ KHẮC PHỤC** |
| **AUDIT-08** | Trang User Profile dùng chung & Bảo mật dữ liệu người dùng | **Nghiêm trọng (High):** Nguy cơ đổi trái phép email tài khoản (dẫn đến chiếm quyền sở hữu); upload file giả mạo đuôi ảnh độc hại (RCE); mất đồng bộ session khi đổi username; lỗi thiếu cột CSDL `avatar_url`, `phone`, `birth_date`. | Thiết kế kiến trúc Profile an toàn: Chặn 100% việc đổi email (403 Forbidden); thẩm định magic bytes nhị phân cho ảnh PNG/JPEG/WEBP; lưu ảnh ngoài thư mục deploy Tomcat và tự động xóa ảnh cũ; chuẩn hóa SĐT Việt Nam (+84 sang 0); đồng bộ ngay `CURRENT_USER` trong session khi đổi username; áp dụng thống nhất cho 4 role (Student, Expert, Manager, Admin). | **ĐÃ KHẮC PHỤC** |

---

## 🧪 3. Danh mục Kiểm thử Hồi quy (Regression Test Checklist)

### Bảng Kịch Bản Kiểm Thử (18 Test Cases Toàn Diện)

| Mã TC | Phân quyền | Kịch bản kiểm thử | Các bước thực hiện | Kết quả mong đợi | Kết quả kiểm thử | Đánh giá |
| :---: | :---: | :--- | :--- | :--- | :--- | :---: |
| **TC-01** | `EXPERT` | Tạo khóa học nháp mới (Kiểm tra cấp phát Manager ID) | 1. Đăng nhập bằng `expert1`.<br>2. Nhấn "Thêm khóa học mới".<br>3. Nhập tiêu đề, giá, mô tả và bấm "Lưu". | Khóa học tạo thành công ở trạng thái `DRAFT`. `manager_id` được gán tự động cho Manager có ít việc nhất, không bị lỗi vi phạm khóa ngoại. | Khóa học tạo thành công với managerId hợp lệ. | **PASS** |
| **TC-02** | `EXPERT` | Kiểm tra chặn GET tại endpoint thay đổi dữ liệu | 1. Đăng nhập bằng `expert1`.<br>2. Gõ trực tiếp trên thanh địa chỉ URL trình duyệt: `/expert/request-publish?courseId=1`. | Hệ thống từ chối thực thi GET, hiển thị thông báo lỗi Flash yêu cầu dùng POST và chuyển hướng về màn hình an toàn. Không thay đổi dữ liệu. | Server chặn GET và chuyển hướng kèm thông báo lỗi. | **PASS** |
| **TC-03** | `EXPERT` | Gửi yêu cầu xuất bản qua Modal xác nhận | 1. Vào trang quản lý đề cương bài học của khóa học DRAFT có bài.<br>2. Bấm nút "Gửi duyệt xuất bản".<br>3. Bấm xác nhận trên Modal. | Modal tạo form ẩn và gửi yêu cầu bằng phương thức `POST`. Trạng thái khóa học chuyển sang `PENDING_REVIEW`. | Khóa học chuyển sang PENDING_REVIEW an toàn qua POST. | **PASS** |
| **TC-04** | `EXPERT` | Kiểm tra Khóa Soạn thảo khi Chờ duyệt (Review Lock) | 1. Khi khóa học ở trạng thái `PENDING_REVIEW`, thử bấm sửa/thêm bài học hoặc chương học. | Toàn bộ giao diện chỉnh sửa bị khóa. Thao tác nộp form bị chặn với lỗi "Khóa học đang chờ duyệt, không thể chỉnh sửa". | Quyền chỉnh sửa bị khóa chặt chẽ. | **PASS** |
| **TC-05** | `EXPERT` | Thu hồi yêu cầu duyệt (Cancel Request Publish) | 1. Bấm nút "Thu hồi yêu cầu duyệt".<br>2. Xác nhận trên Modal (gửi POST). | Khóa học chuyển trạng thái từ `PENDING_REVIEW` về lại `DRAFT`. Giảng viên được mở lại quyền chỉnh sửa bài học. | Khóa học trở về DRAFT, mở lại quyền soạn thảo. | **PASS** |
| **TC-06** | `EXPERT` | Kiểm tra chống trùng thứ tự bài học (`order_index`) | 1. Mở bài học mới trong Module 1 (đã có bài số 1).<br>2. Đặt `orderIndex = 1`.<br>3. Nhấn "Lưu bài học". | Hệ thống bắt lỗi logic và hiển thị thông báo: "Thứ tự bài học (1) đã tồn tại trong chương này...". Không bị crash lỗi CSDL 500. | Hiển thị thông báo thân thiện, không ném lỗi 500. | **PASS** |
| **TC-07** | `EXPERT` | Bảo toàn bản nháp Local khi lưu thất bại | 1. Soạn bài học dài trong trình soạn thảo Quill.<br>2. Cố tình nhập lỗi (ví dụ trùng thứ tự bài hoặc URL sai).<br>3. Nhấn "Lưu bài học". | Server báo lỗi và quay lại trang soạn thảo. Toàn bộ nội dung văn bản trong Quill và các trường nhập liệu vẫn được giữ nguyên từ `localStorage`. | Bản nháp local được bảo toàn 100%. | **PASS** |
| **TC-08** | `EXPERT` | Xóa bản nháp Local sau khi lưu thành công | 1. Nhập thông tin bài học hợp lệ.<br>2. Nhấn "Lưu bài học". | Server lưu thành công và chuyển hướng với `savedSuccess=true`. Bản nháp trong `localStorage` được dọn dẹp sạch sẽ. | Bản nháp dọn dẹp sạch sau khi lưu thành công. | **PASS** |
| **TC-09** | `EXPERT` | Ẩn mềm bài học (Soft-Hide) & Khôi phục | 1. Bấm nút Tạm ẩn bài học trong đề cương.<br>2. Xác nhận qua Modal POST.<br>3. Bấm Mở lại bài học. | Cờ `is_active` chuyển thành `false` (bài học không bị xóa khỏi DB, dữ liệu tiến độ học viên giữ nguyên). Khi mở lại, `is_active` thành `true`. | Bài học ẩn/hiện chính xác, không mất dữ liệu liên quan. | **PASS** |
| **TC-10** | `SYSTEM` | Kiểm tra Worker tự động lưu trữ khóa học tới hạn | 1. Thiết lập khóa học PUBLISHED có `archive_at = NOW() - 1 phút`.<br>2. Chờ Worker nền kích hoạt (chu kỳ 60s). | Worker `CourseArchiveSchedulerListener` tự động quét CSDL và cập nhật trạng thái khóa học sang `ARCHIVED`. | Khóa học chuyển sang ARCHIVED tự động. | **PASS** |
| **TC-11** | `GUEST` | Kiểm tra phân quyền truy cập trang `/profile` | 1. Chưa đăng nhập.<br>2. Truy cập trực tiếp URL `/Courson/profile`. | `AuthenticationFilter` chặn truy cập, chuyển hướng 302 về trang đăng nhập `/Courson/auth/login`. | Chuyển hướng 302 về login chính xác. | **PASS** |
| **TC-12** | `ALL_ROLES` | Tải lên ảnh đại diện & Thẩm định Magic Bytes | 1. Tải file giả mạo đuôi .png (nội dung text).<br>2. Tải file ảnh .png thật.<br>3. Tải tiếp ảnh khác để kiểm tra dọn ảnh cũ. | File giả bị từ chối với lỗi magic bytes. File ảnh thật được lưu tên UUID ngoài thư mục WAR, URL trả về dạng `/uploads/avatar/...`, ảnh cũ bị xóa khỏi đĩa. | Bảo mật upload tuyệt đối, dọn dẹp đĩa sạch sẽ. | **PASS** |
| **TC-13** | `ALL_ROLES` | Cập nhật Họ và tên qua AJAX | 1. Nhập họ tên < 3 ký tự hoặc để trống.<br>2. Nhập họ tên hợp lệ (3-50 ký tự). | Server trả JSON báo lỗi validation chính xác. Khi hợp lệ, DB cập nhật và sidebar cập nhật tên mới không reload trang. | Validation khớp 100% luồng đăng ký. | **PASS** |
| **TC-14** | `ALL_ROLES` | Cập nhật Số điện thoại chuẩn Việt Nam | 1. Nhập SĐT đầu số sai (0123...).<br>2. Nhập SĐT hợp lệ dạng `+84912345678`.<br>3. Để trống SĐT. | Đầu số sai bị từ chối. SĐT `+84` tự động chuẩn hóa về `0912345678`. Cho phép để trống (tùy chọn). | Chuẩn hóa SĐT VN hoạt động chuẩn xác. | **PASS** |
| **TC-15** | `ALL_ROLES` | Đổi Tên đăng nhập & Đồng bộ Session | 1. Nhập username trùng (`admin`).<br>2. Nhập username sai định dạng.<br>3. Nhập username mới hợp lệ. | Bắt trùng và báo lỗi validation. Khi đổi thành công, session `CURRENT_USER` được cập nhật tức thì, không gây lỗi các trang khác. | Đổi username an toàn, đồng bộ session mượt mà. | **PASS** |
| **TC-16** | `ALL_ROLES` | Chống can thiệp sửa Email tài khoản | 1. Kiểm tra UI: input email có thuộc tính `readonly disabled`.<br>2. Gửi request POST giả mạo `field=email&value=hacker@evil.com`. | Server chặn đứng với mã HTTP 403 Forbidden và thông báo "Email là định danh cố định, không được phép thay đổi". | Miễn nhiễm 100% với việc can thiệp sửa email. | **PASS** |
| **TC-17** | `ALL_ROLES` | Cập nhật Ngày sinh & Thẩm định độ tuổi | 1. Chọn ngày sinh ở tương lai.<br>2. Chọn ngày sinh có tuổi < 10.<br>3. Chọn ngày sinh hợp lệ (ví dụ năm 2000). | Ngày tương lai và tuổi < 10 bị từ chối với lỗi rõ ràng. Ngày hợp lệ lưu thành công vào CSDL kiểu `date`. | Validation ngày sinh chặt chẽ. | **PASS** |
| **TC-18** | `ALL_ROLES` | Hiển thị Badge vai trò & Avatar trên Navbar | 1. Đăng nhập lần lượt với 4 vai trò: `STUDENT`, `ADMIN`, `EXPERT`, `MANAGER`.<br>2. Quan sát badge tại sidebar và avatar tại navbar. | Hiển thị đúng nhãn/badge vai trò của từng user (`STUDENT`, `ADMIN`, `EXPERT`, `MANAGER`). Navbar hiển thị ảnh avatar đã upload (hoặc chữ cái đầu nếu chưa có ảnh). | Giao diện nhất quán, phân quyền trực quan. | **PASS** |

---

## 🛡️ 4. Hướng dẫn Kiểm tra Lại Môi trường (Verification Commands)

### 1. Kiểm tra cấu trúc CSDL và Migration:
```bash
# Thực thi các migration lần lượt trên PostgreSQL:
psql -U postgres -d courson_db -f database/migrations/01_add_pending_review_to_courses.sql
psql -U postgres -d courson_db -f database/migrations/02_add_archive_and_notes_columns.sql
psql -U postgres -d courson_db -f database/migrations/03_add_user_profile_columns.sql
```

### 2. Biên dịch và Đóng gói:
```bash
mvn package -DskipTests
```

### 3. Khởi động Tomcat & Giám sát Worker nền:
Trong log của Tomcat (`catalina.out` hoặc console), quan sát thông báo khởi động worker:
```text
[CourseArchiveSchedulerListener] Worker quét lưu trữ khóa học đã được khởi tạo thành công (chu kỳ 60s).
```

---
*Báo cáo được hoàn thành và cập nhật tự động vào hệ thống ngày 31/10/2026.*

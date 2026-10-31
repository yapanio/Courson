# 🎓 Courson LMS - Nền Tảng Quản Lý Học Tập & Đánh Giá Trực Tuyến

<div align="center">

[![Java Version](https://img.shields.io/badge/Java-17%20%7C%2021%20LTS-orange.svg?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10%20(Servlet%206.0%20%7C%20JSP%203.1)-red.svg)](https://jakarta.ee/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-blue.svg?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-10.1%2B-yellow.svg?logo=apachetomcat&logoColor=white)](https://tomcat.apache.org/)
[![Google Gemini AI](https://img.shields.io/badge/Google%20Gemini-AI%201.5%20%7C%202.0%20Flash-4285F4.svg?logo=google&logoColor=white)](https://ai.google.dev/)
[![OAuth 2.0](https://img.shields.io/badge/Auth-Google%20OAuth%202.0-34A853.svg?logo=google&logoColor=white)](https://developers.google.com/identity)
[![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3.3%20SaaS-purple.svg?logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
[![Course](https://img.shields.io/badge/Course-SWP391%20%7C%20SE2051--NET%20G5-green.svg)](#)

**Dự án Thực hành Phát triển Phần mềm (SWP391) • Lớp SE2051-NET • Nhóm 5 • Đại Học FPT Hà Nội**

[🚀 Chạy Trực Tiếp (GitHub Pages / Local)](#-cách-1-chạy-trực-tiếp-trên-trình-duyệt-khuyên-dùng-khi-chấm-thử) • [Nghiệp Vụ Chi Tiết 4 Phân Quyền](#-2-tính-năng--quy-trình-nghiệp-vụ-chi-tiết) • [Kiến Trúc & Bảo Mật](#-3-kiến-trúc-hệ-thống--an-toàn-bảo-mật) • [Cơ Sở Dữ Liệu (14 Bảng)](#-4-cơ-sở-dữ-liệu-postgresql-14-bảng) • [Bảng Endpoint Servlet](#-5-bảng-danh-mục-endpoint--điều-hướng-servlet) • [Tài Khoản Test](#-6-tài-khoản-thử-nghiệm-mặc-định)

</div>

---

## ⚡ 1. Giới thiệu tổng quan & Điểm nổi bật

**Courson LMS** là giải pháp nền tảng học tập trực tuyến (Learning Management System) toàn diện, ứng dụng kiến trúc chuẩn doanh nghiệp **Layered Architecture (MVC + Service Layer + DAO Pattern + Security Filters)** trên nền tảng **Jakarta EE 10 (Servlet 6.0, JSP 3.1, JSTL 3.0)** và hệ quản trị cơ sở dữ liệu quan hệ **PostgreSQL 14+**.

Hệ thống cung cấp chu trình đào tạo hoàn chỉnh theo mô hình **RBAC (Role-Based Access Control)** với 4 vai trò độc lập: **Student (Học viên)**, **Expert (Giảng viên/Chuyên gia)**, **Manager (Quản lý nội dung & vận hành)** và **Admin (Quản trị viên hệ thống)**.

### 🌟 Điểm nổi bật & Cải tiến nghiệp vụ then chốt:

1. **Chu trình Duyệt & Khóa Khóa học (Course Review & Editing Lock):**
   * Quy trình chuyển dịch trạng thái nghiêm ngặt: `DRAFT` ➔ `PENDING_REVIEW` ➔ `PUBLISHED` / `ARCHIVED`.
   * **Khóa chỉnh sửa khi chờ duyệt (Pending Review Lock):** Khi Giảng viên gửi yêu cầu xuất bản (`/expert/request-publish`), khóa học chuyển sang `PENDING_REVIEW` và **bị khóa toàn bộ quyền sửa/thêm/xóa Module và Bài học** nhằm đảm bảo tính toàn vẹn dữ liệu thẩm định.
   * **Thu hồi yêu cầu duyệt (Draft Revocation):** Nếu cần sửa đổi nội dung, Giảng viên phải chủ động thực hiện "Thu hồi yêu cầu duyệt" (`/expert/cancel-request-publish`) để đưa khóa học về lại `DRAFT`.
2. **Cơ chế Ẩn mềm Bài giảng & Bảo vệ Phiên học viên (Soft-Hide & Student Session Protection):**
   * **Loại bỏ nút Xóa vĩnh viễn (No Hard Deletes):** Bài học không bị xóa (`DELETE CASCADE`) khỏi database để bảo vệ an toàn 100% dữ liệu lịch sử học tập (`lesson_progress`) và ghi chú của học viên. Thay vào đó, Giảng viên sử dụng chức năng **Ẩn/Hiện mềm** (`is_active = false/true`).
   * **Bảo vệ phiên học viên (Active Session Grace):** Nếu Giảng viên ẩn bài học khi học viên đang trực tiếp học bài đó, học viên vẫn được phép hoàn tất việc xem video và lưu ghi chú trong phiên làm việc hiện tại. Chỉ khi học viên chuyển sang bài khác hoặc rời khỏi phiên, bài ẩn mới chính thức biến mất; các yêu cầu truy cập trực tiếp bài ẩn sau đó sẽ tự động được hệ thống chuyển hướng an toàn về bài học khả dụng đầu tiên của khóa.
3. **Trợ lý Sáng tạo Nội dung Google Gemini AI (Tổng quan Khóa học):**
   * Tích hợp Google Gemini AI (1.5 Flash / 2.0 Flash) qua REST API.
   * Tự động tạo mô tả và đề cương khóa học bằng AI (`generate-ai-description`).
   * Tự động quét lấy tiêu đề & thời lượng video YouTube (`get-video-title`).
   * Nhập hàng loạt bài giảng từ danh sách phát YouTube (`preview-batch-videos` & `batch-save-lessons`).
4. **Tự động Lưu Bản nháp & Khôi phục Sự cố (Real-time Auto-save Drafts):**
   * Tích hợp trình soạn thảo WYSIWYG **Quill.js** hiện đại.
   * Cơ chế debounced 2.5 giây tự động lưu nháp nội dung bài học vào server/session.
   * Tự động cảnh báo và cho phép Giảng viên khôi phục bản nháp khi gặp sự cố ngắt kết nối mạng hoặc tắt trình duyệt đột ngột.
5. **Cơ chế Lưu trữ & Hẹn giờ Đóng Khóa học (Scheduled Archiving & Lifetime Access):**
   * Cho phép hẹn giờ đóng đăng ký khóa học (`archive_at`) kèm thông báo công khai (`archive_notice`) và đồng hồ đếm ngược trực quan.
   * **Quyền truy cập trọn đời (Lifetime Access):** Khi khóa học chuyển sang trạng thái `ARCHIVED`, chỉ dừng tiếp nhận học viên mới; tất cả học viên đã đăng ký trước đó vẫn tiếp tục vào học, xem bài giảng và làm bài trắc nghiệm bình thường.
6. **Bảng điều khiển Học viên & Tiếp tục Học Thông minh (Smart Resume Banner):**
   * Dashboard học viên (`/registrations/my`) thống kê trực quan KPIs: Khóa đang học, Khóa hoàn thành, Điểm số, Tiến độ trung bình.
   * Banner "Tiếp tục bài học" tự động nhận diện bài giảng đang học dở gần nhất để học viên bấm vào học tiếp chỉ với 1 cú click chuột.
   * Ghi chú cá nhân theo thời gian thực (`user_note`) lưu trực tiếp theo từng bài giảng.
7. **Xác thực Đa kênh An toàn (Multi-Channel Auth & Google OAuth 2.0):**
   * Đăng nhập truyền thống với mật khẩu băm **BCrypt** (salt round 12), tài khoản kích hoạt qua Email Token (Jakarta Mail).
   * Đăng nhập 1-click tiện lợi thông qua **Google OAuth 2.0**.
   * Hệ thống phòng thủ bảo mật đa lớp chống **IDOR, XSS, CSRF**.

---

## 🌐 Trải nghiệm Trực tiếp: 2 Cách chạy dự án

Dự án hỗ trợ **2 phương thức khởi chạy** linh hoạt:

### 🌟 Cách 1: Chạy trực tiếp trên Trình duyệt (Khuyên dùng khi chấm thử)

> [!TIP]
> **Không yêu cầu cài đặt Apache Tomcat, Maven hay PostgreSQL!** Toàn bộ giao diện người dùng SaaS, dữ liệu 3 khóa học thực tế, 118 bài giảng YouTube chuẩn HD, 12 bộ đề thi trắc nghiệm có hẹn giờ và chức năng đổi vai trò (Student / Expert / Manager / Admin) đã được đóng gói thành **1 file duy nhất [`index.html`](file:///d:/LMHT/SWP/SE2051-NET_SWP391_G5/index.html)** tương thích 100% với **GitHub Pages**.

#### 1. Mở trực tiếp trên máy tính cá nhân (Offline / Local):
* Nhấp đúp chuột vào file [`index.html`](file:///d:/LMHT/SWP/SE2051-NET_SWP391_G5/index.html) bằng bất kỳ trình duyệt web hiện đại nào (Google Chrome, Microsoft Edge, Mozilla Firefox).
* Mọi tính năng phát video YouTube, tính điểm trắc nghiệm đếm ngược, chuyển đổi 4 vai trò người dùng hoạt động trơn tru ngay lập tức.

#### 2. Chạy trên GitHub Pages (Live trên Internet):
1. Vào tab **Settings** của repository trên GitHub ➔ Chọn menu **Pages** (cột bên trái).
2. Tại mục **Build and deployment** ➔ **Source**: Chọn **Deploy from a branch**.
3. Chọn Branch: **`main`**, thư mục: **`/ (root)`** ➔ Nhấn **Save**.
4. Trang web sẽ trực tiếp khả dụng tại:
   ```text
   https://<username>.github.io/SE2051-NET_SWP391_G5/
   ```

---

### ☕ Cách 2: Triển khai đầy đủ trên Tomcat 10 + PostgreSQL

Dành cho việc kiểm thử toàn diện mã nguồn Backend Servlets, Database Persistence, Security Filters và cơ chế lưu trữ dữ liệu thực tế:

#### Yêu cầu môi trường:
* **Java Development Kit (JDK):** Phiên bản **17 LTS** hoặc **21 LTS** (Khuyến nghị Eclipse Temurin hoặc OpenJDK 17).
* **Apache Maven:** Phiên bản **3.8+**.
* **Apache Tomcat:** Phiên bản **10.1+** (hỗ trợ đặc tả Jakarta EE 10 / Servlet 6.0).
* **PostgreSQL:** Phiên bản **14+** (cổng mặc định `5432`).

#### Các bước triển khai chi tiết:

##### Bước 1: Khởi tạo Cơ sở dữ liệu PostgreSQL
Mở terminal hoặc pgAdmin và thực thi tuần tự 2 file SQL:
```bash
# 1. Tạo database
createdb -U postgres courson_db

# 2. Nạp cấu trúc 14 bảng quan hệ chuẩn hóa
psql -U postgres -d courson_db -f database/schema.sql

# 3. Nạp dữ liệu hạt giống (3 khóa học thực tế, 118 bài giảng, 12 đề thi, 4 tài khoản chuẩn)
psql -U postgres -d courson_db -f database/seed.sql
```

##### Bước 2: Cấu hình thông số kết nối
Kiểm tra và cập nhật file cấu hình [`src/main/resources/db.properties`](file:///d:/LMHT/SWP/SE2051-NET_SWP391_G5/src/main/resources/db.properties):
```properties
db.url=jdbc:postgresql://localhost:5432/courson_db
db.user=postgres
db.password=sa
```

*(Tùy chọn cấu hình SMTP gửi email kích hoạt trong [`src/main/resources/mail.properties`](file:///d:/LMHT/SWP/SE2051-NET_SWP391_G5/src/main/resources/mail.properties) và API Key Gemini trong biến môi trường hoặc cấu hình hệ thống).*

##### Bước 3: Biên dịch & Đóng gói file WAR
```bash
mvn clean package -DskipTests
```
*File `Courson.war` được tạo tại thư mục `target/Courson.war`.*

##### Bước 4: Deploy lên Tomcat 10
1. Copy file `target/Courson.war` vào thư mục `webapps/` của máy chủ Apache Tomcat 10.1+.
2. Khởi động Tomcat:
   ```bash
   # Trên Windows
   catalina.bat run
   # Trên Linux / macOS
   ./catalina.sh run
   ```
3. Truy cập hệ thống tại: **[http://localhost:8080/Courson/](http://localhost:8080/Courson/)**
   *(Giao diện demo tương tác nội bộ tại: [http://localhost:8080/Courson/demo.html](http://localhost:8080/Courson/demo.html)).*

---

## 🌟 2. Tính năng & Quy trình Nghiệp vụ Chi Tiết

```mermaid
flowchart TD
    subgraph RBAC["Mô hình 4 Phân quyền Người dùng"]
        G["Khách (Guest)"] -->|Đăng ký / Đăng nhập| S["Học viên (Student)"]
        S
        E["Giảng viên (Expert)"]
        M["Quản lý (Manager)"]
        A["Quản trị viên (Admin)"]
    end

    subgraph CourseWorkflow["Vòng đời Khóa học & Kiểm duyệt Nghiêm ngặt"]
        E -->|Soạn bài & Đề thi| DRAFT["DRAFT (Bản nháp)"]
        DRAFT -->|Nộp duyệt (request-publish)| PENDING["PENDING_REVIEW (Chờ duyệt)<br>🔒 KHÓA TOÀN BỘ CHỈNH SỬA"]
        PENDING -->|Thu hồi sửa tiếp (cancel-request)| DRAFT
        PENDING -->|Quản lý từ chối| DRAFT
        PENDING -->|Quản lý phê duyệt| PUBLISHED["PUBLISHED (Đã xuất bản)"]
        PUBLISHED -->|Hết hạn / Lên lịch| ARCHIVED["ARCHIVED (Lưu trữ / Đóng)<br>🛡️ Học viên cũ giữ quyền trọn đời"]
    end
```

---

### 👨‍🎓 2.1. Dành cho Học viên (Student - `student1`)

* **Khám phá Danh mục Khóa học (Course Catalog - `/courses/catalog`):**
  * Tìm kiếm tức thời theo từ khóa, lọc theo danh mục chuẩn hóa (`COURSE_CATEGORY`).
  * Xem thông tin chi tiết khóa học (`/courses/detail`): đề cương chương mục (Syllabus), số lượng bài giảng, thông tin giảng viên, học phí và thông báo lịch lưu trữ khóa học (nếu có).
* **Đăng ký Khóa học & Thanh toán (Enrollment & Checkout):**
  * Quy trình thanh toán chuyển khoản minh bạch với mã giao dịch thanh toán duy nhất (`payment_code`).
  * Tự động kích hoạt quyền học tập ngay khi đơn hàng được ghi nhận.
* **Bảng điều khiển Học viên (Student Dashboard - `/registrations/my`):**
  * **Banner "Tiếp tục bài học" (Smart Resume Banner):** Hệ thống tự động xác định bài giảng học viên đang học dở gần nhất, hiển thị nút "Tiếp tục bài học" kèm tên bài giảng và chương học để học viên vào học ngay lập tức.
  * **Chỉ số Tiến độ Cá nhân (KPIs Metric Cards):** Thống kê số khóa đang học (`IN_PROGRESS`), số khóa đã hoàn thành (`COMPLETED`), số khóa chờ xác nhận thanh toán (`PENDING`) và % tiến độ học tập bình quân.
  * **Bộ lọc Trạng thái Thông minh:** Tabs lọc danh sách khóa học: *Tất cả*, *Đang học*, *Chờ thanh toán*, *Đã hoàn thành*.
* **Không gian Học tập Tập trung (Learning Workspace - `/courses/learn`):**
  * Tự động phát video bài giảng chất lượng cao chuẩn YouTube Embed, hỗ trợ auto-thumbnail sắc nét.
  * Đề cương bên hông (Syllabus Sidebar) nhóm theo từng Module, tích hợp thanh tìm kiếm bài học nhanh.
  * **Đánh dấu Hoàn thành (`/courses/update-progress`):** Bấm nút ghi nhận hoàn thành bài học, hệ thống cập nhật bản ghi `lesson_progress` và tính toán lại thanh tiến độ tổng thể của khóa học theo thời gian thực.
  * **Ghi chú Cá nhân Thời gian thực (Real-time Personal Notes - `/courses/save-lesson-note`):** Học viên có thể ghi chú bài giảng ngay bên dưới video; nội dung ghi chú được lưu an toàn vào trường `user_note` của bảng `lesson_progress`.
  * **Bảo vệ Phiên Học viên khi Bài bị Ẩn (Active Session Grace):** Nếu Giảng viên ẩn bài học (`is_active = false`) khi học viên đang mở bài đó, học viên vẫn có thể học tiếp và lưu ghi chú bình thường trong phiên hiện tại. Sau khi chuyển sang bài khác, bài ẩn sẽ biến mất khỏi đề cương và nếu cố truy cập bằng URL trực tiếp, hệ thống sẽ tự động điều hướng mượt mà đến bài học khả dụng đầu tiên.
  * **Quyền Truy cập Trọn đời (Lifetime Access):** Với các khóa học đã đóng đăng ký (`ARCHIVED`), học viên đã ghi danh vẫn được bảo lưu toàn bộ quyền học tập, xem lại video và làm quiz ôn tập vĩnh viễn.
* **Động cơ Kiểm tra & Đánh giá (Live Quiz Engine - `/quizzes/attempt`):**
  * Đồng hồ đếm ngược thời gian thực (ví dụ 15 phút), chuyển màu vàng/đỏ cảnh báo khi còn dưới 2 phút.
  * Lưới điều hướng câu hỏi (Question Grid Navigator) trực quan với trạng thái đã trả lời / chưa trả lời.
  * Tự động nộp bài khi hết thời gian quy định; tính điểm tức thời theo trọng số câu hỏi.
  * Đánh giá kết quả Đạt / Không đạt (Pass/Fail) dựa theo điểm chuẩn sàn (`pass_score`).
  * Trang xem lại bài làm chi tiết (`/quizzes/result`): Tô màu đáp án đúng (xanh lá), đáp án sai (đỏ) kèm lời giải thích chuyên môn cặn kẽ.

---

### 👨‍🏫 2.2. Dành cho Giảng viên / Chuyên gia (Expert - `expert1`)

* **Bảng điều khiển Giảng viên (Expert Dashboard - `/expert/dashboard`):**
  * Thống kê toàn cảnh các khóa học được phân công: Tổng số khóa học, Khóa nháp (`DRAFT`), Khóa đang chờ duyệt (`PENDING_REVIEW`), Khóa đã phát hành (`PUBLISHED`), Khóa lưu trữ (`ARCHIVED`).
  * Tabs lọc danh sách khóa học nhanh theo từng trạng thái.
* **Quản lý Đề cương Scoped theo Module & Soạn thảo Bài giảng:**
  * **Tạo Module linh hoạt:** Thêm mới và quản lý các chương học theo thứ tự hiển thị `order_index`.
  * **Thêm Bài học chuẩn mực trong Module:** Tạo bài giảng trực tiếp trong phạm vi từng Module cụ thể, loại bỏ thao tác di chuyển phức tạp, đảm bảo cấu trúc đề cương luôn chặt chẽ.
  * **Trình soạn thảo WYSIWYG Quill.js:** Soạn thảo nội dung bài học phong phú với đầy đủ định dạng văn bản, danh sách, khối trích dẫn và liên kết.
  * **Tự động lưu Bản nháp & Phục hồi Sự cố (Auto-Save Drafts):**
    * Cơ chế debounced 2.5 giây tự động lưu nháp nội dung (`/expert/save-lesson-draft`).
    * Khi mở lại trang soạn thảo sau sự cố tắt trình duyệt, hệ thống tự động kiểm tra bản nháp lưu tạm (`/expert/get-lesson-draft`) và hiển thị thông báo cho phép phục hồi nội dung chỉ với 1 thao tác.
  * **Ẩn / Hiện mềm Bài giảng (Soft-Hide / Unhide - `/expert/toggle-lesson-status`):**
    * Loại bỏ hoàn toàn nút xóa cứng (`DELETE`), thay thế bằng nút chuyển đổi trạng thái Hoạt động / Tạm ẩn (`is_active = true/false`).
    * Giữ nguyên 100% dữ liệu tiến độ và bài nộp của học viên, tránh lỗi hổng toàn vẹn khóa ngoại.
* **Trợ lý Sáng tạo Nội dung Google Gemini AI (Tổng quan Khóa học):**
  * **Tạo Mô tả Khóa học bằng AI (`/expert/generate-ai-description`):** AI phân tích tên khóa học và tạo ra bản mô tả cuốn hút kèm mục tiêu bài học chuẩn SEO ngay trên form tạo tổng quan khóa học.
  * **Tự động Lấy Tiêu đề & Thời lượng YouTube (`/expert/get-video-title`):** Giảng viên chỉ cần dán link YouTube, hệ thống tự động trích xuất tiêu đề chính xác và thời lượng của video.
  * **Nhập Hàng loạt Bài giảng từ Playlist YouTube (`/expert/preview-batch-videos` & `/expert/batch-save-lessons`):** Quét toàn bộ playlist video và nhập hàng loạt vào module chỉ trong vài giây.
* **Quy trình Kiểm duyệt & Khóa Soạn thảo Nghiêm ngặt (Review Lock):**
  * **Gửi Yêu cầu Xuất bản (`/expert/request-publish`):** Chuyển khóa học từ `DRAFT` sang `PENDING_REVIEW`.
  * **Khóa Chỉnh sửa Tuyệt đối:** Khi ở trạng thái `PENDING_REVIEW`, mọi thao tác lưu bài học, sửa module, xóa chương đều bị chặn (`checkCourseEditable` bảo vệ ở Service và Controller Layer).
  * **Thu hồi Yêu cầu Duyệt (`/expert/cancel-request-publish`):** Nếu cần bổ sung hoặc chỉnh sửa thêm nội dung, Giảng viên có thể chủ động bấm "Thu hồi yêu cầu duyệt" để đưa khóa học trở lại `DRAFT`.
* **Quản lý Lưu trữ & Hẹn giờ Đóng Khóa học (Course Archiving):**
  * Hẹn giờ đóng khóa học theo thời điểm cụ thể (`archive_at`) kèm thông báo tùy biến (`archive_notice`) hiển thị đồng hồ đếm ngược trên trang chi tiết khóa học.
  * Lưu trữ ngay lập tức (`/expert/archive-course`), Khôi phục phát hành lại (`/expert/unarchive-course`) hoặc Hủy lịch hẹn giờ lưu trữ (`/expert/cancel-archive`).
* **Ngân hàng Câu hỏi & Quản lý Đề thi (Question Bank & Quizzes):**
  * **Ngân hàng Câu hỏi (`/quizzes/question-bank`):** Quản lý tập trung các câu hỏi trắc nghiệm theo từng Module; hỗ trợ 4 lựa chọn trả lời kèm lời giải thích chi tiết.
  * **Thiết lập Đề thi (`/quizzes/detail`):** Cấu hình thời gian làm bài (`time_limit_minutes`), điểm sàn đạt (`pass_score`).
  * **Gán câu hỏi vào Đề thi (`/quizzes/assign-question`):** Chọn câu hỏi từ ngân hàng câu hỏi, gán điểm số cụ thể (`points`), kiểm soát chống trùng lặp câu hỏi trong một đề thi.

---

### 👔 2.3. Dành cho Quản lý Khóa học (Manager - `manager1`)

* **Bảng điều khiển Quản lý (Manager Dashboard - `/manager/dashboard`):**
  * Báo cáo tổng thể vận hành: Tổng số học viên, doanh thu thực tế, số lượt nộp bài thi, tỷ lệ hoàn thành khóa học.
  * Card cảnh báo số lượng khóa học đang chờ duyệt (`pendingCount`).
* **Hàng đợi Kiểm duyệt Khóa học (Course Review Queue):**
  * Tiếp nhận các khóa học ở trạng thái `PENDING_REVIEW`.
  * Xem trước toàn bộ đề cương, video bài giảng và câu hỏi trắc nghiệm trước khi ra quyết định.
  * **Phê duyệt xuất bản (`PUBLISHED`):** Khóa học ngay lập tức xuất hiện trên Catalog công khai để học viên đăng ký.
  * **Từ chối duyệt:** Trả khóa học về trạng thái `DRAFT` kèm phản hồi để giảng viên hoàn thiện thêm.
* **Phân công Giảng viên (Assign Expert):**
  * Gán giảng viên chuyên môn phụ trách cho từng khóa học.
* **Quản lý Đăng ký Học viên & Doanh thu:**
  * Theo dõi danh sách đăng ký học tập, xác nhận trạng thái thanh toán và kiểm soát quyền truy cập khóa học.

---

### 👑 2.4. Dành cho Quản trị viên Hệ thống (System Admin - `admin`)

* **Quản lý Tài khoản Người dùng (User Management - `/users/list`):**
  * Tra cứu danh sách toàn bộ tài khoản, hỗ trợ tìm kiếm theo tên, email, lọc theo vai trò (`STUDENT`, `EXPERT`, `MANAGER`, `ADMIN`).
  * Khóa hoặc kích hoạt lại tài khoản người dùng (`ACTIVE` / `BANNED`).
  * Chỉnh sửa thông tin hồ sơ và vai trò của tài khoản.
* **Cài đặt Hệ thống Động (Settings Management - `/settings/list`):**
  * Quản lý linh hoạt danh mục khóa học (`COURSE_CATEGORY`) và nhóm vai trò người dùng (`USER_ROLE`).
  * Cấu hình thứ tự ưu tiên hiển thị (`priority`), giá trị hiển thị và bật/tắt trạng thái danh mục.

---

## 🏗️ 3. Kiến trúc Hệ thống & An toàn Bảo mật

### Mô hình Phân Tầng Chuẩn Doanh Nghiệp (Layered Architecture):

```
+-----------------------------------------------------------------------------------+
|                            Trình Duyệt (Web Browser / Client)                     |
+-----------------------------------------+-----------------------------------------+
                                          | HTTP / HTTPS Requests
                                          v
+-----------------------------------------------------------------------------------+
|                         Security & Filter Layer (Jakarta EE)                      |
|  - EncodingFilter: Ép chuẩn mã hóa ký tự UTF-8 cho toàn bộ Request & Response     |
|  - AuthenticationFilter: Kiểm soát truy cập các Endpoint công khai và nội bộ      |
|  - AuthorizationFilter: Thực thi phân quyền theo vai trò (RBAC 4 Roles)           |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                          Controller Layer (Jakarta Servlets 6.0)                  |
|  - AuthServlet, CourseServlet, LessonServlet, QuizServlet, RegistrationServlet    |
|  - AdminCourseServlet, ManagerDashboardServlet, UserServlet, SettingServlet       |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                             Service Layer (Business Logic)                        |
|  - AuthService, CourseService, QuizService, RegistrationService, UserService      |
|  - GeminiAiUtil (AI Assistant), GoogleOAuthUtil, MailUtil                         |
|  - Kiểm tra điều kiện nghiệp vụ: checkCourseEditable, checkCourseOwnership...     |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                     Data Access Object Layer (DAO Pattern - JDBC)                 |
|  - CourseDao, LessonDao, ModuleDao, QuizDao, RegistrationDao, UserDao, SettingDao |
|  - 100% PreparedStatements (Triệt tiêu hoàn toàn nguy cơ SQL Injection)           |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                            PostgreSQL 14+ Relational Database                     |
+-----------------------------------------------------------------------------------+
```

### Cơ chế An Toàn & Bảo Mật Thực Tiễn:
1. **Mã hóa Mật khẩu Chuẩn Doanh nghiệp:** Ứng dụng thuật toán **BCrypt** độ dài salt rounds 12 thông qua thư viện `org.mindrot.jbcrypt`, chống lại các kỹ thuật tấn công Rainbow Table và Brute Force.
2. **Xác thực Đăng ký qua Email Token:** Tạo chuỗi token ngẫu nhiên có thời hạn lưu trong bảng `email_verification_tokens`, gửi thư kích hoạt qua giao thức SMTP bằng Jakarta Mail (Angus Mail).
3. **Đăng nhập Google OAuth 2.0:** Xác thực token an toàn từ Google Identity Platform, tự động ánh xạ tài khoản email Google vào hệ thống.
4. **Phòng chống Lỗ hổng Cấp Dữ liệu (IDOR Prevention):**
   * Controller kiểm tra nghiêm ngặt quyền sở hữu: Học viên chỉ được xem bài học hoặc làm bài thi của các khóa học mà chính họ đã đăng ký hợp lệ (`registration.getUserId() == session.getUserId()`).
   * Giảng viên chỉ được xem và sửa các khóa học được phân công (`checkCourseOwnership`).
5. **Khóa Chỉnh sửa Bảo vệ Thẩm định (Course Edit Lock):** Phương thức `checkCourseEditable` chủ động ngăn chặn mọi yêu cầu sửa đổi khi khóa học đang ở trạng thái thẩm định `PENDING_REVIEW`.
6. **Bảo toàn Toàn vẹn Dữ liệu (Soft-Hide vs Hard-Delete):** Dùng cờ `is_active` để ẩn bài giảng thay vì xóa cứng `DELETE FROM lessons`, bảo toàn 100% lịch sử học tập của học viên.
7. **Phòng chống XSS (Cross-Site Scripting):** Sử dụng hàm JSTL `<c:out>` và cơ chế mã hóa tự động để làm sạch dữ liệu hiển thị.

---

## 🗄️ 4. Cơ Sở Dữ Liệu PostgreSQL (14 Bảng)

Hệ thống được chuẩn hóa với **14 bảng quan hệ**, đảm bảo toàn vẹn tham chiếu và hiệu năng truy vấn:

| STT | Tên bảng | Các trường dữ liệu cốt lõi | Chức năng nghiệp vụ chính |
| :---: | :--- | :--- | :--- |
| **1** | `settings` | `id`, `type`, `value`, `order_index`, `is_active` | Quản lý danh mục khóa học (`COURSE_CATEGORY`) và vai trò người dùng (`USER_ROLE`). |
| **2** | `users` | `id`, `full_name`, `email`, `password_hash`, `role_id`, `status` | Quản lý tài khoản người dùng, email duy nhất, mật khẩu BCrypt, trạng thái `ACTIVE`/`BANNED`. |
| **3** | `email_verification_tokens` | `id`, `user_id`, `token`, `expires_at` | Lưu trữ mã token kích hoạt tài khoản gửi qua email khi học viên đăng ký mới. |
| **4** | `courses` | `id`, `title`, `price`, `status`, `manager_id`, `expert_id`, `archive_at`, `archive_notice` | Khóa học với chu trình trạng thái (`DRAFT`, `PENDING_REVIEW`, `PUBLISHED`, `ARCHIVED`), lịch hẹn đóng và thông báo. |
| **5** | `modules` | `id`, `course_id`, `title`, `order_index` | Các chương học trong một khóa học, sắp xếp tuần tự theo `order_index`. |
| **6** | `lessons` | `id`, `module_id`, `title`, `content`, `video_url`, `order_index`, `is_active` | Bài giảng thuộc từng module; hỗ trợ nhúng video YouTube, nội dung HTML và cờ ẩn mềm `is_active`. |
| **7** | `quizzes` | `id`, `module_id`, `title`, `pass_score`, `time_limit_minutes`, `order_index` | Đề thi trắc nghiệm theo chương, thiết lập thời gian làm bài (phút) và điểm sàn qua môn (`pass_score`). |
| **8** | `questions` | `id`, `module_id`, `content`, `explanation` | Ngân hàng câu hỏi trắc nghiệm của từng module kèm lời giải thích chi tiết. |
| **9** | `answer_options` | `id`, `question_id`, `content`, `is_correct` | Các lựa chọn trả lời (4 phương án/câu) kèm cờ đánh dấu đáp án chính xác (`is_correct`). |
| **10** | `quiz_questions` | `quiz_id`, `question_id`, `points` | Bảng liên kết gán câu hỏi vào đề thi kèm thang điểm số cụ thể cho từng câu. |
| **11** | `registrations` | `id`, `user_id`, `course_id`, `status`, `payment_status`, `payment_code`, `enrolled_at` | Đơn đăng ký khóa học của học viên, mã thanh toán giao dịch và trạng thái truy cập. |
| **12** | `lesson_progress` | `id`, `registration_id`, `lesson_id`, `status`, `user_note`, `completed_at` | Tiến độ học bài học (`COMPLETED`/`IN_PROGRESS`), thời gian hoàn thành và ghi chú cá nhân học viên (`user_note`). |
| **13** | `quiz_attempts` | `id`, `registration_id`, `quiz_id`, `score`, `is_passed`, `attempted_at` | Lưu trữ lịch sử lần thi của học viên (tổng điểm đạt được, thời điểm nộp bài, kết quả Pass/Fail). |
| **14** | `quiz_answers` | `id`, `attempt_id`, `question_id`, `selected_option_id` | Chi tiết từng câu trả lời do học viên lựa chọn trong mỗi lượt thi. |

---

## 🚦 5. Bảng Danh Mục Endpoint & Điều Hướng Servlet

| Nhóm chức năng | Endpoint URL Pattern | Phương thức | Phân quyền (RBAC) | Mô tả chi tiết nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **Trang chủ** | `/home` | `GET` | Public | Hiển thị khóa học chọn lọc, banner giới thiệu và thanh tìm kiếm nhanh |
| **Khóa học** | `/courses/catalog` | `GET` | Public | Danh mục khóa học, tìm kiếm theo từ khóa và lọc theo chuyên mục |
| | `/courses/detail` | `GET` | Public | Xem thông tin chi tiết khóa học, đề cương, thông báo hẹn đóng khóa học |
| | `/courses/learn` | `GET` | STUDENT | Không gian học tập video HD, đề cương bài học, ghi chú cá nhân |
| | `/courses/update-progress` | `POST` | STUDENT | Đánh dấu hoàn thành bài học, cập nhật % tiến độ khóa học tức thời |
| | `/courses/save-lesson-note`| `POST` | STUDENT | Lưu ghi chú cá nhân của học viên cho bài giảng đang học |
| **Bảng điều khiển Học viên** | `/registrations/my` | `GET` | STUDENT | Dashboard học viên: Banner tiếp tục bài học, KPI metrics, lọc khóa học |
| | `/registrations/checkout` | `GET, POST` | STUDENT | Trang thanh toán khóa học, hiển thị thông tin chuyển khoản & mã thanh toán |
| **Đề thi & Trắc nghiệm** | `/quizzes/attempt` | `GET` | STUDENT | Vào phòng thi trắc nghiệm kèm đồng hồ đếm lùi thời gian thực |
| | `/quizzes/submit` | `POST` | STUDENT | Nộp bài thi, tự động chấm điểm và đánh giá Đạt / Không đạt (Pass/Fail) |
| | `/quizzes/result` | `GET` | STUDENT | Xem chi tiết bài làm, đáp án đúng/sai kèm lời giải thích chuyên môn |
| | `/quizzes/list` | `GET` | EXPERT, ADMIN | Quản lý danh sách các đề thi trắc nghiệm theo khóa học |
| | `/quizzes/detail` | `GET, POST` | EXPERT, ADMIN | Cấu hình đề thi: thời gian, điểm sàn và gán câu hỏi từ ngân hàng |
| | `/quizzes/question-bank` | `GET, POST` | EXPERT, ADMIN | Quản lý ngân hàng câu hỏi trắc nghiệm của từng module |
| | `/quizzes/assign-question`| `POST` | EXPERT, ADMIN | Gán câu hỏi vào đề thi kèm thang điểm, kiểm tra chống trùng lặp |
| **Giảng viên (Expert)** | `/expert/dashboard` | `GET` | EXPERT, ADMIN | Bảng điều khiển Giảng viên, thống kê khóa học theo trạng thái |
| | `/expert/lessons` | `GET` | EXPERT, ADMIN | Quản lý đề cương chương mục (Modules) và danh sách bài giảng |
| | `/expert/lesson-detail` | `GET` | EXPERT, ADMIN | Mở giao diện soạn thảo bài học kèm trình soạn thảo Quill WYSIWYG |
| | `/expert/save-lesson` | `POST` | EXPERT, ADMIN | Thêm mới hoặc cập nhật bài giảng trong module (yêu cầu khóa không PENDING) |
| | `/expert/toggle-lesson-status` | `POST` | EXPERT, ADMIN | Ẩn / Hiện mềm bài giảng (`is_active`), bảo vệ lịch sử học viên |
| | `/expert/save-module` | `POST` | EXPERT, ADMIN | Thêm mới hoặc cập nhật thông tin chương học (Module) |
| | `/expert/delete-module` | `POST` | EXPERT, ADMIN | Xóa module rỗng trong khóa học |
| | `/expert/save-lesson-draft` | `POST` | EXPERT, ADMIN | Tự động lưu nháp nội dung bài giảng định kỳ 2.5 giây |
| | `/expert/get-lesson-draft` | `GET` | EXPERT, ADMIN | Lấy nội dung bản nháp bài giảng đã lưu để phục hồi sự cố |
| | `/expert/request-publish` | `POST` | EXPERT, ADMIN | Gửi yêu cầu xuất bản khóa học (`DRAFT` ➔ `PENDING_REVIEW`, khóa chỉnh sửa) |
| | `/expert/cancel-request-publish` | `POST` | EXPERT, ADMIN | Thu hồi yêu cầu duyệt (`PENDING_REVIEW` ➔ `DRAFT`) để tiếp tục chỉnh sửa |
| | `/expert/archive-course` | `POST` | EXPERT, ADMIN | Lưu trữ khóa học ngay hoặc lên lịch hẹn giờ đóng đăng ký |
| | `/expert/unarchive-course` | `POST` | EXPERT, ADMIN | Khôi phục khóa học lưu trữ trở lại hoạt động |
| | `/expert/cancel-archive` | `POST` | EXPERT, ADMIN | Hủy bỏ lịch hẹn lưu trữ khóa học đã thiết lập |
| | `/expert/get-video-title` | `GET` | EXPERT, ADMIN | Tự động quét lấy tiêu đề & thời lượng video YouTube |
| | `/expert/generate-ai-description` | `POST` | EXPERT, ADMIN | Dùng Gemini AI tạo mô tả và đề cương khóa học tự động |
| | `/expert/batch-save-lessons` | `POST` | EXPERT, ADMIN | Nhập hàng loạt bài giảng vào module từ danh sách video YouTube |
| **Quản lý (Manager)** | `/manager/dashboard` | `GET` | MANAGER, ADMIN | Dashboard vận hành: thống kê doanh thu, khóa chờ duyệt (`pendingCount`) |
| | `/admin/courses` | `GET, POST` | MANAGER, ADMIN | Quản lý danh sách khóa học, duyệt khóa học chờ (`PENDING_REVIEW`) |
| | `/admin/course-detail` | `GET` | MANAGER, ADMIN | Xem chi tiết nội dung khóa học phục vụ công tác thẩm định |
| **Quản trị (Admin)** | `/users/list` | `GET, POST` | ADMIN | Danh sách người dùng, tìm kiếm, kích hoạt hoặc khóa tài khoản (`BANNED`) |
| | `/settings/list` | `GET, POST` | ADMIN | Quản lý danh mục khóa học và phân quyền vai trò người dùng |
| **Xác thực (Auth)** | `/auth/login` | `GET, POST` | Public | Đăng nhập tài khoản (hỗ trợ email không phân biệt hoa thường) |
| | `/auth/register` | `GET, POST` | Public | Đăng ký tài khoản học viên mới và gửi email kích hoạt |
| | `/auth/google` | `GET` | Public | Điều hướng đăng nhập nhanh qua Google OAuth 2.0 |
| | `/auth/google-callback` | `GET` | Public | Tiếp nhận mã ủy quyền từ Google và hoàn tất xác thực đăng nhập |
| | `/verify` | `GET` | Public | Kích hoạt tài khoản người dùng qua token gửi về email |
| | `/auth/logout` | `GET` | Đã đăng nhập | Đăng xuất người dùng và hủy toàn bộ HTTP Session |

---

## 🔑 6. Tài Khoản Thử Nghiệm Mặc Định

Tất cả các tài khoản thử nghiệm dưới đây được nạp sẵn từ file `database/schema.sql` và đều sử dụng chung một mật khẩu mặc định:

```text
admin123
```

| Vai trò | Tên đăng nhập | Email | Quyền hạn & Kịch bản thử nghiệm |
| :--- | :--- | :--- | :--- |
| 👑 **Admin** | `admin` | `admin@courson.edu.vn` | **Toàn quyền hệ thống:** Quản lý danh sách người dùng, khóa/mở tài khoản, quản lý danh mục và cấu hình tham số hệ thống. |
| 👔 **Manager** | `manager1` | `manager@courson.edu.vn` | **Quản lý Vận hành:** Bảng điều khiển quản lý, duyệt khóa học trong hàng đợi `PENDING_REVIEW`, phân công giảng viên, quản lý đơn đăng ký. |
| 👨‍🏫 **Expert** | `expert1` | `expert@courson.edu.vn` | **Giảng viên / Chuyên gia:** Soạn thảo bài giảng WYSIWYG, tự động lưu nháp, ẩn/hiển thị bài học, gửi duyệt & thu hồi yêu cầu duyệt, dùng trợ lý Gemini AI, cấu hình ngân hàng câu hỏi & đề thi. |
| 👨‍🎓 **Student** | `student1` | `student@courson.edu.vn` | **Học viên:** Bảng điều khiển cá nhân, xem video HD, lưu ghi chú thời gian thực, làm bài thi trắc nghiệm tính giờ và xem lại đáp án chi tiết. |

---

## 🛠️ 7. Cấu Trúc Mã Nguồn Dự Án

```text
SE2051-NET_SWP391_G5/
├── database/
│   ├── schema.sql                 # Cấu trúc 14 bảng quan hệ PostgreSQL chuẩn hóa
│   └── seed.sql                   # Dữ liệu hạt giống hoàn chỉnh (3 khóa học, 118 bài giảng, 12 đề thi)
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── controller/        # Jakarta Servlets (12 Servlets điều hướng URL)
│   │   │   ├── dao/               # Data Access Objects (100% PreparedStatement an toàn)
│   │   │   ├── entity/            # Thực thể dữ liệu ánh xạ database & enums nghiệp vụ
│   │   │   ├── filter/            # EncodingFilter, AuthenticationFilter, AuthorizationFilter
│   │   │   ├── service/           # Business Logic Layer (Kiểm tra nghiệp vụ, bảo vệ IDOR)
│   │   │   └── util/              # GeminiAiUtil, GoogleOAuthUtil, MailUtil, PasswordUtil
│   │   ├── resources/
│   │   │   ├── db.properties      # Cấu hình chuỗi kết nối PostgreSQL
│   │   │   └── mail.properties    # Cấu hình giao thức gửi mail SMTP
│   │   └── webapp/
│   │       ├── WEB-INF/views/     # Các trang JSP theo từng phân quyền (Admin, Manager, Expert, Student, Quiz)
│   │       └── index.html         # Trang demo tương tác độc lập (GitHub Pages & Local ready)
├── pom.xml                        # Maven Project Object Model (Dependencies & Build config)
└── README.md                      # Tài liệu hướng dẫn kỹ thuật & mô tả nghiệp vụ toàn diện
```

---

## 👥 8. Thông Tin Đội Ngũ Phát Triển

* **Học phần:** SWP391 - Software Development Project (Thực hành Phát triển Phần mềm)
* **Lớp:** SE2051-NET
* **Nhóm:** Group 5
* **Cơ sở đào tạo:** Trường Đại Học FPT Hà Nội
* **Giảng viên hướng dẫn:** Thầy KienNT

---

<div align="center">
  <i>© 2026 Courson LMS. Dự án được xây dựng với tâm huyết vì mục đích giáo dục và nâng cao trải nghiệm học tập số.</i>
</div>

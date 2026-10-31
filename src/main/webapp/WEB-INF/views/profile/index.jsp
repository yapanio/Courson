<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Hồ sơ người dùng - Courson LMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<style>
    .profile-sidebar-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }
    .profile-avatar-wrapper {
        position: relative;
        width: 120px;
        height: 120px;
        margin: 0 auto 16px auto;
    }
    .profile-avatar-img, .profile-avatar-initial {
        width: 120px;
        height: 120px;
        border-radius: 50%;
        object-fit: cover;
        box-shadow: 0 4px 12px rgba(243, 128, 32, 0.2);
        border: 3px solid #FFF5EB;
    }
    .profile-avatar-initial {
        display: flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #FAAD3F 0%, #F38020 100%);
        color: #ffffff;
        font-size: 42px;
        font-weight: 700;
    }
    .profile-avatar-btn {
        position: absolute;
        bottom: 0;
        right: 0;
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background-color: #F38020;
        color: #ffffff;
        border: 2px solid #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
    }
    .profile-avatar-btn:hover {
        background-color: #E56B00;
        transform: scale(1.08);
    }
    .profile-nav-item {
        display: flex;
        align-items: center;
        padding: 12px 16px;
        margin-bottom: 6px;
        border-radius: 10px;
        color: #475569;
        text-decoration: none;
        font-weight: 500;
        font-size: 0.95rem;
        transition: all 0.2s ease;
        cursor: pointer;
    }
    .profile-nav-item i {
        font-size: 1.15rem;
        margin-right: 12px;
        color: #94a3b8;
        transition: color 0.2s;
    }
    .profile-nav-item:hover {
        background-color: #FFF5EB;
        color: #F38020;
    }
    .profile-nav-item:hover i {
        color: #F38020;
    }
    .profile-nav-item.active {
        background: linear-gradient(135deg, #FFF5EB 0%, #FEEBD6 100%);
        color: #F38020;
        font-weight: 600;
        border-left: 4px solid #F38020;
    }
    .profile-nav-item.active i {
        color: #F38020;
    }
    .profile-content-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 32px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }
    .profile-section-title {
        font-weight: 700;
        font-size: 1.25rem;
        color: #1e293b;
        margin-bottom: 6px;
    }
    .profile-section-desc {
        color: #64748b;
        font-size: 0.9rem;
        margin-bottom: 24px;
    }
    .profile-field-card {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
    }
    .btn-cf-save {
        background-color: #F38020;
        border-color: #F38020;
        color: #ffffff;
        font-weight: 600;
        padding: 8px 20px;
        border-radius: 8px;
        transition: all 0.2s;
    }
    .btn-cf-save:hover, .btn-cf-save:focus {
        background-color: #E56B00;
        border-color: #E56B00;
        color: #ffffff;
    }
    .field-error-msg {
        font-size: 0.85rem;
        color: #dc3545;
        margin-top: 6px;
        display: none;
    }
    .password-toggle-btn {
        cursor: pointer;
        background: transparent;
        border: none;
        color: #94a3b8;
    }
    .password-toggle-btn:hover {
        color: #475569;
    }
</style>

<main class="main-content py-5">
    <div class="container">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none text-muted">Trang chủ</a></li>
                <li class="breadcrumb-item active text-dark fw-semibold" aria-current="page">Hồ sơ người dùng</li>
            </ol>
        </nav>

        <c:set var="displayName" value="${not empty user.fullName ? user.fullName : user.username}" />
        <c:set var="userInitial" value="${fn:toUpperCase(fn:substring(displayName, 0, 1))}" />

        <div class="row g-4">
            <!-- Left Sidebar -->
            <div class="col-lg-4 col-md-5">
                <div class="profile-sidebar-card text-center">
                    <!-- Avatar Area -->
                    <div class="profile-avatar-wrapper">
                        <c:choose>
                            <c:when test="${not empty user.avatarUrl}">
                                <img src="${pageContext.request.contextPath}${user.avatarUrl}" id="sidebarAvatarImg" class="profile-avatar-img" alt="Avatar" />
                                <div id="sidebarAvatarInitial" class="profile-avatar-initial" style="display: none;">${userInitial}</div>
                            </c:when>
                            <c:otherwise>
                                <img src="" id="sidebarAvatarImg" class="profile-avatar-img" style="display: none;" alt="Avatar" />
                                <div id="sidebarAvatarInitial" class="profile-avatar-initial">${userInitial}</div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Change Avatar Button -->
                        <button type="button" class="profile-avatar-btn" id="btnTriggerAvatar" title="Thay đổi ảnh đại diện">
                            <i class="bi bi-camera-fill"></i>
                        </button>
                        <!-- Hidden file input -->
                        <input type="file" id="avatarFileInput" accept="image/jpeg,image/png,image/webp" style="display: none;" />
                    </div>

                    <!-- User Information in Sidebar -->
                    <h5 class="fw-bold text-dark mb-1" id="sidebarFullNameDisplay">${displayName}</h5>
                    <p class="text-muted small mb-2" id="sidebarUsernameDisplay">@${user.username}</p>

                    <!-- Role Badge -->
                    <div class="mb-4">
                        <c:choose>
                            <c:when test="${user.roleName == 'STUDENT'}">
                                <span class="cf-role-badge cf-role-student py-1 px-3 fs-6">
                                    <i class="bi bi-mortarboard me-1"></i>Học viên
                                </span>
                            </c:when>
                            <c:when test="${user.roleName == 'EXPERT'}">
                                <span class="cf-role-badge cf-role-expert py-1 px-3 fs-6">
                                    <i class="bi bi-person-badge me-1"></i>Chuyên gia
                                </span>
                            </c:when>
                            <c:when test="${user.roleName == 'ADMIN'}">
                                <span class="cf-role-badge cf-role-admin py-1 px-3 fs-6">
                                    <i class="bi bi-shield-lock me-1"></i>Quản trị viên
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="cf-role-badge cf-role-manager py-1 px-3 fs-6">
                                    <i class="bi bi-briefcase me-1"></i>Quản lý
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div id="avatarUploadFeedback" class="small text-danger mb-3" style="display: none;"></div>

                    <!-- Sidebar Navigation Tabs -->
                    <div class="text-start mt-2">
                        <a class="profile-nav-item active" data-tab="tab-general">
                            <i class="bi bi-person-badge"></i>Hồ sơ cá nhân
                        </a>
                        <a class="profile-nav-item" data-tab="tab-username">
                            <i class="bi bi-at"></i>Tên người dùng
                        </a>
                        <a class="profile-nav-item" data-tab="tab-password">
                            <i class="bi bi-key"></i>Mật khẩu
                        </a>
                        <a class="profile-nav-item" data-tab="tab-email">
                            <i class="bi bi-envelope"></i>Email
                        </a>
                        <a class="profile-nav-item" data-tab="tab-birthdate">
                            <i class="bi bi-calendar-event"></i>Ngày sinh
                        </a>
                    </div>
                </div>
            </div>

            <!-- Right Main Panel -->
            <div class="col-lg-8 col-md-7">
                <!-- Global Alerts Container -->
                <div id="globalAlertContainer" class="mb-3"></div>

                <!-- TAB 1: General Profile (Full Name & Phone) -->
                <div class="profile-content-card tab-content-panel" id="tab-general">
                    <h4 class="profile-section-title">Hồ sơ cá nhân</h4>
                    <p class="profile-section-desc">Cập nhật họ và tên và số điện thoại liên lạc của tài khoản.</p>

                    <!-- Form 1: Họ và tên -->
                    <div class="profile-field-card">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label fw-bold text-dark mb-0">Họ và tên</label>
                            <span class="badge bg-light text-muted border">Bắt buộc</span>
                        </div>
                        <p class="text-muted small mb-3">Tên hiển thị trên chứng chỉ và toàn bộ hệ thống Courson LMS.</p>
                        <div class="row g-2 align-items-start">
                            <div class="col-sm-8">
                                <input type="text" class="form-control" id="inputFullName" value="<c:out value='${user.fullName}' />" placeholder="Nhập họ và tên..." maxlength="50" />
                                <div class="field-error-msg" id="errorFullName"></div>
                            </div>
                            <div class="col-sm-4">
                                <button type="button" class="btn btn-cf-save w-100" id="btnSaveFullName">
                                    <i class="bi bi-check-lg me-1"></i>Lưu họ tên
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Form 2: Số điện thoại -->
                    <div class="profile-field-card">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label fw-bold text-dark mb-0">Số điện thoại</label>
                            <span class="badge bg-light text-muted border">Tùy chọn</span>
                        </div>
                        <p class="text-muted small mb-3">Số điện thoại 10 chữ số tại Việt Nam (hỗ trợ đầu số 0 hoặc +84).</p>
                        <div class="row g-2 align-items-start">
                            <div class="col-sm-8">
                                <input type="text" class="form-control" id="inputPhone" value="<c:out value='${user.phone}' />" placeholder="Ví dụ: 0912345678 hoặc +84912345678" maxlength="15" />
                                <div class="field-error-msg" id="errorPhone"></div>
                            </div>
                            <div class="col-sm-4">
                                <button type="button" class="btn btn-cf-save w-100" id="btnSavePhone">
                                    <i class="bi bi-check-lg me-1"></i>Lưu SĐT
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 2: Username -->
                <div class="profile-content-card tab-content-panel" id="tab-username" style="display: none;">
                    <h4 class="profile-section-title">Tên người dùng</h4>
                    <p class="profile-section-desc">Tên đăng nhập duy nhất được dùng để truy cập vào hệ thống Courson LMS.</p>

                    <div class="profile-field-card">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label fw-bold text-dark mb-0">Tên đăng nhập (Username)</label>
                            <span class="badge bg-light text-muted border">Bắt buộc</span>
                        </div>
                        <p class="text-muted small mb-3">Độ dài 4-30 ký tự, chỉ gồm chữ cái, chữ số hoặc dấu gạch dưới (_).</p>
                        <div class="row g-2 align-items-start">
                            <div class="col-sm-8">
                                <div class="input-group">
                                    <span class="input-group-text bg-white text-muted">@</span>
                                    <input type="text" class="form-control" id="inputUsername" value="<c:out value='${user.username}' />" placeholder="Tên đăng nhập..." maxlength="30" />
                                </div>
                                <div class="field-error-msg" id="errorUsername"></div>
                            </div>
                            <div class="col-sm-4">
                                <button type="button" class="btn btn-cf-save w-100" id="btnSaveUsername">
                                    <i class="bi bi-check-lg me-1"></i>Lưu tên đăng nhập
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 3: Password (UI & Client-side validation) -->
                <div class="profile-content-card tab-content-panel" id="tab-password" style="display: none;">
                    <h4 class="profile-section-title">Đổi mật khẩu</h4>
                    <p class="profile-section-desc">Quản lý và cập nhật mật khẩu để bảo mật tài khoản.</p>

                    <div class="profile-field-card">
                        <div class="mb-3">
                            <label class="form-label fw-bold text-dark mb-1">Mật khẩu mới</label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="inputNewPassword" placeholder="Tối thiểu 6 ký tự" />
                                <button class="btn btn-outline-secondary password-toggle-btn" type="button" data-target="inputNewPassword">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold text-dark mb-1">Nhập lại mật khẩu mới</label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="inputConfirmPassword" placeholder="Nhập lại mật khẩu mới" />
                                <button class="btn btn-outline-secondary password-toggle-btn" type="button" data-target="inputConfirmPassword">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                            <div class="field-error-msg" id="errorPassword"></div>
                        </div>

                        <div class="text-end">
                            <button type="button" class="btn btn-cf-save" id="btnSavePassword">
                                <i class="bi bi-shield-check me-1"></i>Đổi mật khẩu
                            </button>
                        </div>
                    </div>
                </div>

                <!-- TAB 4: Email (Readonly) -->
                <div class="profile-content-card tab-content-panel" id="tab-email" style="display: none;">
                    <h4 class="profile-section-title">Địa chỉ Email</h4>
                    <p class="profile-section-desc">Email dùng để đăng nhập, xác thực và nhận thông báo quan trọng.</p>

                    <div class="profile-field-card">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label fw-bold text-dark mb-0">Email tài khoản</label>
                            <span class="badge bg-success-subtle text-success border border-success-subtle">
                                <i class="bi bi-patch-check-fill me-1"></i>Đã xác thực
                            </span>
                        </div>
                        <p class="text-muted small mb-3">Email là định danh tài khoản cố định và không thể thay đổi vì lý do bảo mật.</p>
                        <div class="input-group mb-2">
                            <span class="input-group-text bg-light text-muted"><i class="bi bi-envelope-fill"></i></span>
                            <input type="email" class="form-control bg-light text-muted" value="<c:out value='${user.email}' />" readonly disabled />
                        </div>
                        <div class="alert alert-secondary py-2 px-3 small mt-3 mb-0" role="alert">
                            <i class="bi bi-info-circle-fill me-1 text-primary"></i>Nếu cần thay đổi email liên lạc, vui lòng liên hệ Ban quản trị qua trang Hỗ trợ.
                        </div>
                    </div>
                </div>

                <!-- TAB 5: Birth Date -->
                <div class="profile-content-card tab-content-panel" id="tab-birthdate" style="display: none;">
                    <h4 class="profile-section-title">Ngày sinh</h4>
                    <p class="profile-section-desc">Ngày tháng năm sinh phục vụ cấp chứng chỉ và cá nhân hóa khóa học.</p>

                    <div class="profile-field-card">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label fw-bold text-dark mb-0">Ngày sinh</label>
                            <span class="badge bg-light text-muted border">Tùy chọn</span>
                        </div>
                        <p class="text-muted small mb-3">Độ tuổi học viên hợp lệ từ 10 đến 120 tuổi.</p>
                        <div class="row g-2 align-items-start">
                            <div class="col-sm-8">
                                <input type="date" class="form-control" id="inputBirthDate" value="${user.birthDate}" />
                                <div class="field-error-msg" id="errorBirthDate"></div>
                            </div>
                            <div class="col-sm-4">
                                <button type="button" class="btn btn-cf-save w-100" id="btnSaveBirthDate">
                                    <i class="bi bi-check-lg me-1"></i>Lưu ngày sinh
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />

<!-- Profile Interactions Script -->
<script>
    (function () {
        const contextPath = '${pageContext.request.contextPath}';

        // 1. Tab Switching
        const navItems = document.querySelectorAll('.profile-nav-item');
        const panels = document.querySelectorAll('.tab-content-panel');

        navItems.forEach(item => {
            item.addEventListener('click', function () {
                navItems.forEach(n => n.classList.remove('active'));
                this.classList.add('active');

                const targetTab = this.getAttribute('data-tab');
                panels.forEach(p => {
                    p.style.display = (p.id === targetTab) ? 'block' : 'none';
                });
            });
        });

        // 2. Alert Toast Utility
        const alertContainer = document.getElementById('globalAlertContainer');
        function showAlert(message, type = 'success') {
            const icon = type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill';
            const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
            alertContainer.innerHTML = `
                <div class="alert \${alertClass} alert-dismissible fade show py-2.5 px-3 small d-flex align-items-center" role="alert">
                    <i class="bi \${icon} me-2 fs-6"></i>
                    <div>\${message}</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="padding: 0.85rem;"></button>
                </div>
            `;
            // Auto dismiss after 5s
            setTimeout(() => {
                const el = alertContainer.querySelector('.alert');
                if (el) {
                    el.classList.remove('show');
                    setTimeout(() => el.remove(), 200);
                }
            }, 5000);
        }

        // 3. Reusable AJAX Field Saver
        function saveField(field, value, btn, errorEl, onSuccessCallback) {
            // Clear previous error
            errorEl.style.display = 'none';
            errorEl.textContent = '';

            // Loading state
            const originalHtml = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>Đang lưu...';

            const params = new URLSearchParams();
            params.append('field', field);
            params.append('value', value != null ? value : '');

            fetch(contextPath + '/profile/update-field', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                },
                body: params.toString()
            })
            .then(res => res.json())
            .then(data => {
                btn.disabled = false;
                btn.innerHTML = originalHtml;

                if (data.success) {
                    showAlert(data.message, 'success');
                    if (onSuccessCallback) {
                        onSuccessCallback(data.value);
                    }
                } else {
                    errorEl.textContent = data.message || 'Đã có lỗi xảy ra.';
                    errorEl.style.display = 'block';
                }
            })
            .catch(err => {
                btn.disabled = false;
                btn.innerHTML = originalHtml;
                errorEl.textContent = 'Lỗi kết nối máy chủ: ' + err.message;
                errorEl.style.display = 'block';
            });
        }

        // 4. Save Full Name
        const btnSaveFullName = document.getElementById('btnSaveFullName');
        const inputFullName = document.getElementById('inputFullName');
        const errorFullName = document.getElementById('errorFullName');

        btnSaveFullName.addEventListener('click', function () {
            saveField('fullName', inputFullName.value, btnSaveFullName, errorFullName, function (val) {
                document.getElementById('sidebarFullNameDisplay').textContent = val;
            });
        });

        // 5. Save Phone
        const btnSavePhone = document.getElementById('btnSavePhone');
        const inputPhone = document.getElementById('inputPhone');
        const errorPhone = document.getElementById('errorPhone');

        btnSavePhone.addEventListener('click', function () {
            saveField('phone', inputPhone.value, btnSavePhone, errorPhone, function (normalizedVal) {
                inputPhone.value = normalizedVal || '';
            });
        });

        // 6. Save Username
        const btnSaveUsername = document.getElementById('btnSaveUsername');
        const inputUsername = document.getElementById('inputUsername');
        const errorUsername = document.getElementById('errorUsername');

        btnSaveUsername.addEventListener('click', function () {
            saveField('username', inputUsername.value, btnSaveUsername, errorUsername, function (val) {
                document.getElementById('sidebarUsernameDisplay').textContent = '@' + val;
            });
        });

        // 7. Save Birth Date
        const btnSaveBirthDate = document.getElementById('btnSaveBirthDate');
        const inputBirthDate = document.getElementById('inputBirthDate');
        const errorBirthDate = document.getElementById('errorBirthDate');

        btnSaveBirthDate.addEventListener('click', function () {
            saveField('birthDate', inputBirthDate.value, btnSaveBirthDate, errorBirthDate);
        });

        // 8. Password Toggle & Validation
        document.querySelectorAll('.password-toggle-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                const targetId = this.getAttribute('data-target');
                const targetInput = document.getElementById(targetId);
                const icon = this.querySelector('i');
                if (targetInput.type === 'password') {
                    targetInput.type = 'text';
                    icon.classList.remove('bi-eye');
                    icon.classList.add('bi-eye-slash');
                } else {
                    targetInput.type = 'password';
                    icon.classList.remove('bi-eye-slash');
                    icon.classList.add('bi-eye');
                }
            });
        });

        const btnSavePassword = document.getElementById('btnSavePassword');
        const inputNewPassword = document.getElementById('inputNewPassword');
        const inputConfirmPassword = document.getElementById('inputConfirmPassword');
        const errorPassword = document.getElementById('errorPassword');

        btnSavePassword.addEventListener('click', function () {
            errorPassword.style.display = 'none';
            errorPassword.textContent = '';

            const p1 = inputNewPassword.value;
            const p2 = inputConfirmPassword.value;

            if (!p1 || p1.length < 6) {
                errorPassword.textContent = 'Mật khẩu mới phải có tối thiểu 6 ký tự.';
                errorPassword.style.display = 'block';
                return;
            }
            if (p1 !== p2) {
                errorPassword.textContent = 'Mật khẩu xác nhận không khớp.';
                errorPassword.style.display = 'block';
                return;
            }

            // TODO: Kết nối API đổi mật khẩu thực tế khi triển khai tính năng đổi mật khẩu
            showAlert('Chức năng đổi mật khẩu hiện đang được nâng cấp và sẽ sớm ra mắt!', 'success');
            inputNewPassword.value = '';
            inputConfirmPassword.value = '';
        });

        // 9. Avatar Upload Handler
        const btnTriggerAvatar = document.getElementById('btnTriggerAvatar');
        const avatarFileInput = document.getElementById('avatarFileInput');
        const avatarFeedback = document.getElementById('avatarUploadFeedback');
        const sidebarAvatarImg = document.getElementById('sidebarAvatarImg');
        const sidebarAvatarInitial = document.getElementById('sidebarAvatarInitial');

        btnTriggerAvatar.addEventListener('click', function () {
            avatarFileInput.click();
        });

        avatarFileInput.addEventListener('change', function () {
            avatarFeedback.style.display = 'none';
            avatarFeedback.textContent = '';

            const file = this.files[0];
            if (!file) return;

            // Client-side size validation (< 15MB)
            if (file.size > 15 * 1024 * 1024) {
                avatarFeedback.textContent = 'Dung lượng ảnh vượt quá 15MB.';
                avatarFeedback.style.display = 'block';
                this.value = '';
                return;
            }

            // Client-side extension validation
            const ext = file.name.split('.').pop().toLowerCase();
            if (!['jpg', 'jpeg', 'png', 'webp'].includes(ext)) {
                avatarFeedback.textContent = 'Chỉ chấp nhận file ảnh JPG, JPEG, PNG, WEBP.';
                avatarFeedback.style.display = 'block';
                this.value = '';
                return;
            }

            // Send via AJAX FormData
            btnTriggerAvatar.disabled = true;
            btnTriggerAvatar.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span>';

            const formData = new FormData();
            formData.append('avatar', file);

            fetch(contextPath + '/profile/avatar', {
                method: 'POST',
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                btnTriggerAvatar.disabled = false;
                btnTriggerAvatar.innerHTML = '<i class="bi bi-camera-fill"></i>';

                if (data.success) {
                    showAlert(data.message, 'success');

                    // Update sidebar avatar
                    sidebarAvatarImg.src = data.value;
                    sidebarAvatarImg.style.display = 'block';
                    if (sidebarAvatarInitial) {
                        sidebarAvatarInitial.style.display = 'none';
                    }

                    // Update navbar avatar (both desktop and mobile)
                    document.querySelectorAll('.navbar-avatar-img').forEach(img => {
                        img.src = data.value;
                        img.style.display = 'inline-block';
                    });
                    document.querySelectorAll('.navbar-avatar-text').forEach(txt => {
                        txt.style.display = 'none';
                    });
                } else {
                    avatarFeedback.textContent = data.message || 'Lỗi khi upload ảnh.';
                    avatarFeedback.style.display = 'block';
                }
            })
            .catch(err => {
                btnTriggerAvatar.disabled = false;
                btnTriggerAvatar.innerHTML = '<i class="bi bi-camera-fill"></i>';
                avatarFeedback.textContent = 'Lỗi kết nối máy chủ: ' + err.message;
                avatarFeedback.style.display = 'block';
            });
        });

    })();
</script>

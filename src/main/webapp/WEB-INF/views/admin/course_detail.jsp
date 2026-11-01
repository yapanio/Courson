<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Quản trị khóa học - Courson LMS" />
<c:set var="rolePath" value="${sessionScope.CURRENT_USER.roleName == 'MANAGER' ? '/manager' : '/admin'}" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<style>
/* ==========================================================================
   MODERN SAAS DESIGN SYSTEM (Admin Course Detail)
   ========================================================================== */
:root {
    --saas-bg: #f8fafc;
    --saas-card-bg: #ffffff;
    --saas-border: #e2e8f0;
    --saas-border-subtle: #f1f5f9;
    --saas-text-heading: #0f172a;
    --saas-text-body: #334155;
    --saas-text-muted: #64748b;
    --saas-primary: #0f172a;
    --saas-accent: #2563eb;
    --saas-radius-md: 10px;
    --saas-radius-lg: 14px;
    --saas-shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.06), 0 1px 2px -1px rgba(0, 0, 0, 0.04);
}

body {
    background-color: var(--saas-bg);
    color: var(--saas-text-body);
}


.saas-card {
    background: var(--saas-card-bg);
    border: 1px solid var(--saas-border);
    border-radius: var(--saas-radius-lg);
    box-shadow: var(--saas-shadow-sm);
    padding: 24px;
}

.saas-label {
    font-size: 0.8125rem;
    font-weight: 600;
    color: var(--saas-text-heading);
    margin-bottom: 6px;
    display: block;
}

.saas-input, .saas-select {
    border-radius: 8px;
    border: 1px solid var(--saas-border);
    padding: 9px 14px;
    font-size: 0.875rem;
    color: var(--saas-text-heading);
    transition: all 0.15s ease;
    background-color: #ffffff;
}
.saas-input:focus, .saas-select:focus {
    border-color: var(--saas-accent);
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
    outline: none;
}

/* Badges */
.saas-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 10px;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 600;
    letter-spacing: 0.02em;
    white-space: nowrap;
}
.badge-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
}
.saas-badge-published {
    background: #ecfdf5;
    color: #065f46;
}
.saas-badge-published .badge-dot { background: #10b981; }

.saas-badge-pending {
    background: #fffbeb;
    color: #92400e;
}
.saas-badge-pending .badge-dot { background: #f59e0b; }

.saas-badge-draft {
    background: #f1f5f9;
    color: #475569;
}
.saas-badge-draft .badge-dot { background: #94a3b8; }

.saas-badge-archived {
    background: #fef2f2;
    color: #991b1b;
}
.saas-badge-archived .badge-dot { background: #ef4444; }

.btn-saas-outline {
    background: #ffffff;
    border: 1px solid var(--saas-border);
    color: #475569;
    font-size: 0.875rem;
    font-weight: 600;
    padding: 9px 18px;
    border-radius: var(--saas-radius-md);
    transition: all 0.15s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}
.btn-saas-outline:hover {
    background: #f8fafc;
    border-color: #cbd5e1;
    color: #0f172a;
}
</style>

<main class="main-content py-4">
    <div class="container">
        <!-- Breadcrumb & Title -->
        <nav class="mb-4">
            <ol class="breadcrumb small mb-0">
                <c:choose>
                    <c:when test="${sessionScope.CURRENT_USER.roleName == 'MANAGER'}">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/manager/dashboard" class="text-decoration-none text-muted">Manager Dashboard</a></li>
                    </c:when>
                    <c:otherwise>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="text-decoration-none text-muted">Admin Dashboard</a></li>
                    </c:otherwise>
                </c:choose>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}${rolePath}/courses" class="text-decoration-none text-muted">Khóa học</a></li>
                <li class="breadcrumb-item active text-dark fw-semibold">Chi tiết khóa học #${course.id}</li>
            </ol>
        </nav>

        <c:if test="${param.success != null}">
            <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-xs mb-4 py-2 px-3 small" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>Đã cập nhật thông tin và phân công chuyên gia thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-xs mb-4 py-2 px-3 small" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="row g-4">
            <!-- Left col: Course edit & Expert assignment form -->
            <div class="col-lg-7">
                <div class="saas-card">
                    <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                        <h2 class="h5 fw-bold mb-0 text-dark">
                            <i class="bi bi-info-square me-2 text-primary"></i>Thông số khóa học (Course Specifications)
                        </h2>
                        <c:choose>
                            <c:when test="${course.status == 'PUBLISHED'}">
                                <span class="saas-badge saas-badge-published"><span class="badge-dot"></span> Đã duyệt</span>
                            </c:when>
                            <c:when test="${course.status == 'PENDING_REVIEW'}">
                                <span class="saas-badge saas-badge-pending"><span class="badge-dot"></span> Chờ duyệt</span>
                            </c:when>
                            <c:when test="${course.status == 'ARCHIVED'}">
                                <span class="saas-badge saas-badge-archived"><span class="badge-dot"></span> Đã đóng</span>
                            </c:when>
                            <c:otherwise>
                                <span class="saas-badge saas-badge-draft"><span class="badge-dot"></span> Nháp</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <form action="${pageContext.request.contextPath}${rolePath}/save-course" method="POST">
                        <input type="hidden" name="id" value="${course.id}">
                        
                        <div class="mb-3">
                            <label class="saas-label">Tên khóa học (Course Title) <span class="text-danger">*</span></label>
                            <input type="text" name="title" class="form-control saas-input fw-bold" value="${course.title}" required>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="saas-label">Học phí (Price, 0 là Miễn phí)</label>
                                <input type="number" name="price" step="1000" min="0" value="${course.price}" class="form-control saas-input text-success fw-semibold" required>
                            </div>
                            <div class="col-md-6">
                                <label class="saas-label">Danh mục (Category) <span class="text-danger">*</span></label>
                                <select name="categoryId" class="form-select saas-select" onchange="toggleAdminCustomCat(this)">
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.id}" ${course.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                                    </c:forEach>
                                    <option value="__NEW__" class="fw-bold text-primary">+ Nhập danh mục mới...</option>
                                </select>
                                <div id="adminCustomCatDiv" class="mt-2" style="display: none;">
                                    <input type="text" name="customCategory" class="form-control saas-input form-control-sm border-primary" placeholder="✨ Nhập tên danh mục mới...">
                                </div>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="saas-label">Người quản lý (Assigned Manager)</label>
                                <select name="managerId" class="form-select saas-select">
                                    <option value="">-- Chọn Manager --</option>
                                    <c:forEach var="mgr" items="${managers}">
                                        <option value="${mgr.id}" ${course.managerId == mgr.id ? 'selected' : ''}>${mgr.fullName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="saas-label">Chuyên gia phụ trách (Assigned Expert) <span class="text-danger">*</span></label>
                                <select name="expertId" class="form-select saas-select border-primary" required>
                                    <option value="">-- Chọn Chuyên gia --</option>
                                    <c:forEach var="exp" items="${experts}">
                                        <option value="${exp.id}" ${course.expertId == exp.id ? 'selected' : ''}>${exp.fullName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="saas-label">Mô tả chi tiết (Description)</label>
                            <textarea name="description" rows="4" class="form-control saas-input" placeholder="Mục tiêu khóa học và tóm tắt kiến thức...">${course.description}</textarea>
                        </div>

                        <!-- Administrative Override -->
                        <div class="pt-4 border-top">
                            <h3 class="h6 fw-bold mb-3 text-danger">
                                <i class="bi bi-shield-exclamation me-2"></i>Quyền kiểm duyệt &amp; Trạng thái (Status Override)
                            </h3>
                            <div class="mb-3">
                                <label class="saas-label">Trạng thái khóa học (Course Status) <span class="text-danger">*</span></label>
                                <select name="status" class="form-select saas-select border-danger">
                                    <option value="DRAFT" ${course.status == 'DRAFT' ? 'selected' : ''}>Draft (Bản nháp)</option>
                                    <option value="PENDING_REVIEW" ${course.status == 'PENDING_REVIEW' ? 'selected' : ''}>Pending Review (Chờ duyệt xuất bản)</option>
                                    <option value="PUBLISHED" ${course.status == 'PUBLISHED' ? 'selected' : ''}>Published (Phát hành công khai)</option>
                                    <option value="ARCHIVED" ${course.status == 'ARCHIVED' ? 'selected' : ''}>Archived (Đình chỉ / Lưu trữ)</option>
                                </select>
                            </div>

                            <div class="mb-4">
                                <label class="saas-label">Ghi chú kiểm duyệt (Moderation Note)</label>
                                <textarea name="moderationNote" rows="2" class="form-control saas-input" maxlength="255" placeholder="Ghi chú lý do thay đổi trạng thái (tối đa 255 ký tự)..."></textarea>
                            </div>

                            <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                                <a href="${pageContext.request.contextPath}${rolePath}/courses" class="btn-saas-outline">
                                    <i class="bi bi-arrow-left"></i> Quay lại
                                </a>
                                <button type="submit" class="btn btn-danger fw-semibold px-4 py-2" style="border-radius: var(--saas-radius-md);">
                                    <i class="bi bi-shield-check me-1"></i> Lưu thay đổi
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Right col: Curriculum preview & Meta info -->
            <div class="col-lg-5">
                <!-- Meta Info Card -->
                <div class="saas-card mb-4">
                    <h3 class="h6 fw-bold text-dark mb-3">
                        <i class="bi bi-info-circle me-1 text-primary"></i> Thông tin tổng quan
                    </h3>
                    <ul class="list-unstyled small mb-0">
                        <li class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Mã khóa học:</span>
                            <span class="fw-bold">#${course.id}</span>
                        </li>
                        <li class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Người quản lý (Manager):</span>
                            <span class="fw-semibold">${course.managerName != null ? course.managerName : 'Hệ thống'}</span>
                        </li>
                        <li class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Chuyên gia phụ trách:</span>
                            <span class="fw-semibold text-primary">${course.expertName != null ? course.expertName : 'Chưa phân công'}</span>
                        </li>
                        <li class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Tổng số chương:</span>
                            <span class="badge bg-light text-secondary border">${course.modules != null ? course.modules.size() : 0} Chương</span>
                        </li>
                        <li class="d-flex justify-content-between py-2">
                            <span class="text-muted">Học phí niêm yết:</span>
                            <span class="fw-bold text-success">
                                <c:choose>
                                    <c:when test="${course.price > 0}">
                                        <fmt:formatNumber value="${course.price}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                    </c:when>
                                    <c:otherwise>Miễn phí</c:otherwise>
                                </c:choose>
                            </span>
                        </li>
                    </ul>
                </div>

                <!-- Curriculum Preview -->
                <div class="saas-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="h6 fw-bold mb-0 text-dark">
                            <i class="bi bi-list-task me-1 text-primary"></i> Khung chương trình học
                        </h3>
                        <span class="small text-muted">Biên soạn bởi Expert</span>
                    </div>

                    <c:choose>
                        <c:when test="${empty course.modules}">
                            <div class="text-center py-5 text-muted">
                                <i class="bi bi-hourglass-split fs-2 d-block mb-2 opacity-50"></i>
                                <p class="small mb-0">Chuyên gia phụ trách chưa tạo chương trình học cho khóa này.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="accordion" id="curriculumAccordion">
                                <c:forEach var="m" items="${course.modules}" varStatus="status">
                                    <div class="accordion-item border mb-2 rounded-2 overflow-hidden">
                                        <h2 class="accordion-header">
                                            <button class="accordion-button py-2 ${status.first ? '' : 'collapsed'}" type="button" data-bs-toggle="collapse" data-bs-target="#mod${m.id}">
                                                <small class="fw-bold">${m.displayTitle}</small>
                                            </button>
                                        </h2>
                                        <div id="mod${m.id}" class="accordion-collapse collapse ${status.first ? 'show' : ''}">
                                            <div class="accordion-body p-2">
                                                <ul class="list-group list-group-flush small">
                                                    <c:forEach var="l" items="${m.lessons}">
                                                        <li class="list-group-item d-flex justify-content-between align-items-center py-2">
                                                            <span><i class="bi bi-play-circle text-primary me-2"></i>Bài ${l.orderIndex}: ${l.title}</span>
                                                            <span class="badge bg-light text-muted border">Bài học</span>
                                                        </li>
                                                    </c:forEach>
                                                    <c:forEach var="q" items="${m.quizzes}">
                                                        <li class="list-group-item d-flex justify-content-between align-items-center py-2 bg-light-subtle">
                                                            <span><i class="bi bi-question-circle text-warning me-2"></i>${q.title}</span>
                                                            <span class="badge bg-warning bg-opacity-10 text-warning border border-warning border-opacity-25">Bài thi</span>
                                                        </li>
                                                    </c:forEach>
                                                    <c:if test="${empty m.lessons && empty m.quizzes}">
                                                        <li class="list-group-item text-muted text-center py-2 fst-italic">
                                                            Chưa có bài học hoặc bài thi trong chương này
                                                        </li>
                                                    </c:if>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
function toggleAdminCustomCat(selectEl) {
    var div = document.getElementById('adminCustomCatDiv');
    if (!div) return;
    if (selectEl.value === '__NEW__') {
        div.style.display = 'block';
        var inp = div.querySelector('input');
        if (inp) {
            inp.focus();
            inp.required = true;
        }
    } else {
        div.style.display = 'none';
        var inp = div.querySelector('input');
        if (inp) {
            inp.required = false;
            inp.value = '';
        }
    }
}
</script>

<jsp:include page="../common/footer.jsp" />

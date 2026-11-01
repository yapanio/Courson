<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Quản lý bài học - Courson LMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<style>
/* ==========================================================================
   MODERN SAAS DESIGN SYSTEM (Cohesive with Expert Dashboard)
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
    --saas-primary-hover: #1e293b;
    --saas-accent: #2563eb;
    --saas-accent-hover: #1d4ed8;
    --saas-radius-sm: 6px;
    --saas-radius-md: 10px;
    --saas-radius-lg: 14px;
    --saas-radius-xl: 18px;
    --saas-shadow-xs: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
    --saas-shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.06), 0 1px 2px -1px rgba(0, 0, 0, 0.04);
    --saas-shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.06), 0 2px 4px -2px rgba(0, 0, 0, 0.04);
}

body {
    background-color: var(--saas-bg);
    color: var(--saas-text-body);
}


/* Breadcrumbs */
.saas-breadcrumb {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.8125rem;
    color: var(--saas-text-muted);
    margin-bottom: 16px;
}
.saas-breadcrumb a {
    color: var(--saas-text-muted);
    text-decoration: none;
    transition: color 0.15s ease;
}
.saas-breadcrumb a:hover {
    color: var(--saas-text-heading);
}
.saas-breadcrumb .separator {
    color: #cbd5e1;
    font-size: 0.75rem;
}
.saas-breadcrumb .current {
    color: var(--saas-text-heading);
    font-weight: 500;
}

/* Page Header */
.saas-header {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    margin-bottom: 24px;
}
.saas-title {
    font-size: 1.5rem;
    font-weight: 700;
    letter-spacing: -0.025em;
    color: var(--saas-text-heading);
    margin: 0;
    display: flex;
    align-items: center;
    gap: 10px;
}
.saas-subtitle {
    font-size: 0.875rem;
    color: var(--saas-text-muted);
    margin-top: 4px;
    margin-bottom: 0;
}

/* Status Badges */
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
    border: 1px solid #a7f3d0;
}
.saas-badge-published .badge-dot { background: #10b981; }

.saas-badge-pending {
    background: #fffbeb;
    color: #92400e;
    border: 1px solid #fde68a;
}
.saas-badge-pending .badge-dot { background: #f59e0b; }

.saas-badge-draft {
    background: #f1f5f9;
    color: #334155;
    border: 1px solid #cbd5e1;
}
.saas-badge-draft .badge-dot { background: #64748b; }

/* Buttons */
.btn-saas-primary {
    background: #0f172a;
    color: #ffffff;
    border: 1px solid #0f172a;
    font-weight: 600;
    font-size: 0.8125rem;
    padding: 7px 14px;
    border-radius: 8px;
    transition: all 0.15s ease;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    text-decoration: none;
    box-shadow: var(--saas-shadow-xs);
}
.btn-saas-primary:hover {
    background: #1e293b;
    color: #ffffff;
    border-color: #1e293b;
}

.btn-saas-outline {
    background: #ffffff;
    color: #334155;
    border: 1px solid var(--saas-border);
    font-weight: 500;
    font-size: 0.8125rem;
    padding: 7px 14px;
    border-radius: 8px;
    transition: all 0.15s ease;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    text-decoration: none;
    box-shadow: var(--saas-shadow-xs);
}
.btn-saas-outline:hover {
    background: #f8fafc;
    color: #0f172a;
    border-color: #cbd5e1;
}

.btn-saas-outline-emerald {
    background: #ffffff;
    color: #059669;
    border: 1px solid #a7f3d0;
    font-weight: 600;
    font-size: 0.8125rem;
    padding: 7px 14px;
    border-radius: 8px;
    transition: all 0.15s ease;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    text-decoration: none;
}
.btn-saas-outline-emerald:hover {
    background: #ecfdf5;
    color: #047857;
    border-color: #6ee7b7;
}

.btn-saas-outline-amber {
    background: #ffffff;
    color: #d97706;
    border: 1px solid #fde68a;
    font-weight: 600;
    font-size: 0.8125rem;
    padding: 7px 14px;
    border-radius: 8px;
    transition: all 0.15s ease;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    text-decoration: none;
}
.btn-saas-outline-amber:hover {
    background: #fffbeb;
    color: #b45309;
    border-color: #fcd34d;
}

.btn-icon-action {
    width: 34px;
    height: 34px;
    border-radius: 8px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border: 1px solid var(--saas-border);
    background: #ffffff;
    color: #64748b;
    transition: all 0.15s ease;
    cursor: pointer;
    font-size: 0.9rem;
    text-decoration: none;
}
.btn-icon-action:hover {
    background: #f1f5f9;
    color: #0f172a;
    border-color: #cbd5e1;
}

/* Module Cards */
.saas-module-card {
    background: var(--saas-card-bg);
    border: 1px solid var(--saas-border);
    border-radius: var(--saas-radius-lg);
    box-shadow: var(--saas-shadow-sm);
    overflow: hidden;
    margin-bottom: 20px;
    transition: border-color 0.15s ease;
}
.saas-module-card:hover {
    border-color: #cbd5e1;
}
.saas-module-header {
    background: #ffffff;
    padding: 16px 20px;
    border-bottom: 1px solid var(--saas-border);
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    cursor: pointer;
    user-select: none;
    transition: background-color 0.15s ease, border-color 0.15s ease;
}
.saas-module-header:hover {
    background-color: #f8fafc;
}
.saas-module-header.collapsed {
    border-bottom-color: transparent;
}
.module-chevron {
    transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    font-size: 0.95rem;
    color: #64748b;
    display: inline-block;
}
.saas-module-header.collapsed .module-chevron {
    transform: rotate(-90deg);
}
.saas-module-title {
    font-size: 1rem;
    font-weight: 700;
    color: var(--saas-text-heading);
    margin: 0;
    display: flex;
    align-items: center;
    gap: 8px;
}

/* Lesson Items */
.saas-lesson-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid var(--saas-border-subtle);
    background: #ffffff;
    transition: background-color 0.15s ease;
    gap: 16px;
}
.saas-lesson-item:last-child {
    border-bottom: none;
}
.saas-lesson-item:hover {
    background-color: #f8fafc;
}
.lesson-drag-handle {
    cursor: grab;
    color: #94a3b8;
    padding: 2px 4px;
    border-radius: 4px;
    transition: all 0.15s ease;
    display: flex;
    align-items: center;
    user-select: none;
}
.lesson-drag-handle:hover {
    color: #1e293b;
    background: #f1f5f9;
}
.saas-lesson-item.dragging {
    opacity: 0.45;
    background: #eff6ff !important;
    border: 2px dashed #3b82f6 !important;
}
.saas-lesson-item.drag-over {
    border-top: 2px solid #2563eb !important;
}
.lesson-thumb-box {
    width: 84px;
    height: 52px;
    border-radius: 8px;
    overflow: hidden;
    flex-shrink: 0;
    background: #0f172a;
    border: 1px solid var(--saas-border);
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}
.lesson-thumb-box img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

/* Pills & Tags */
.pill-neutral {
    background: #f1f5f9;
    color: #334155;
    border: 1px solid #e2e8f0;
    font-size: 0.75rem;
    font-weight: 500;
    padding: 3px 8px;
    border-radius: 6px;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}
.pill-video {
    background: #fef2f2;
    color: #b91c1c;
    border: 1px solid #fecaca;
    font-size: 0.75rem;
    font-weight: 500;
    padding: 2px 7px;
    border-radius: 6px;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}
.pill-doc {
    background: #f0fdfa;
    color: #0f766e;
    border: 1px solid #ccfbf1;
    font-size: 0.75rem;
    font-weight: 500;
    padding: 2px 7px;
    border-radius: 6px;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

/* Modals (shadcn inspired) */
.modal-content.saas-modal {
    border-radius: 16px;
    border: 1px solid var(--saas-border);
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
    overflow: hidden;
}
.modal-header.saas-modal-header {
    background: #ffffff;
    border-bottom: 1px solid var(--saas-border);
    padding: 20px 24px;
}
.modal-footer.saas-modal-footer {
    background: #f8fafc;
    border-top: 1px solid var(--saas-border);
    padding: 16px 24px;
}
.saas-form-label {
    font-size: 0.8125rem;
    font-weight: 600;
    color: #334155;
    margin-bottom: 6px;
}
.saas-form-control {
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    font-size: 0.875rem;
    padding: 9px 12px;
    transition: all 0.15s ease;
}
.saas-form-control:focus {
    border-color: var(--saas-accent);
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
}

/* Alerts */
.saas-alert {
    border-radius: var(--saas-radius-md);
    padding: 14px 18px;
    font-size: 0.875rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
    box-shadow: var(--saas-shadow-xs);
}
.saas-alert-success {
    background: #f0fdf4;
    border: 1px solid #bbf7d0;
    color: #166534;
}
.saas-alert-danger {
    background: #fef2f2;
    border: 1px solid #fecaca;
    color: #991b1b;
}

/* Pagination styling */
.pagination .page-link {
    color: var(--saas-text-secondary);
    border: 1px solid var(--saas-border);
    padding: 0.35rem 0.65rem;
    font-size: 0.8125rem;
    font-weight: 500;
    border-radius: 6px;
    background: #ffffff;
    transition: all 0.15s ease;
}
.pagination .page-link:hover {
    color: var(--saas-accent);
    background-color: #eff6ff;
    border-color: #bfdbfe;
}
.pagination .page-item.active .page-link {
    background-color: var(--saas-accent);
    border-color: var(--saas-accent);
    color: #ffffff;
    font-weight: 600;
}
.pagination .page-item.disabled .page-link {
    color: var(--saas-text-muted);
    background-color: transparent;
    border-color: var(--saas-border-subtle);
    opacity: 0.6;
}
</style>

<main class="main-content py-4">
    <div class="container">
        <!-- Modern Breadcrumb -->
        <nav class="saas-breadcrumb" aria-label="breadcrumb">
            <a href="${pageContext.request.contextPath}/expert/dashboard">
                <i class="bi bi-mortarboard-fill me-1 text-primary"></i>Expert Studio
            </a>
            <span class="separator">/</span>
            <span class="current">${course.title}</span>
            <span class="separator">/</span>
            <span>Danh sách bài học</span>
        </nav>

        <!-- Flash alerts -->
        <c:set var="displaySuccess" value="${not empty successMessage ? successMessage : param.success}" />
        <c:if test="${not empty displaySuccess}">
            <div class="saas-alert saas-alert-success alert-dismissible fade show" role="alert">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-check-circle-fill fs-5"></i>
                    <span>
                        <c:choose>
                            <c:when test="${displaySuccess == 'batch_saved'}">
                                Đã nhập thành công <strong><c:out value="${not empty param.count ? param.count : 'toàn bộ'}" /> bài học</strong> từ YouTube!
                            </c:when>
                            <c:when test="${displaySuccess == 'created'}">
                                Tạo khóa học thành công!
                            </c:when>
                            <c:when test="${displaySuccess == 'true'}">
                                Đã lưu thông tin bài học thành công!
                            </c:when>
                            <c:otherwise>
                                <c:out value="${displaySuccess}" escapeXml="true" />
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
            </div>
        </c:if>

        <c:set var="displayError" value="${not empty errorMessage ? errorMessage : param.error}" />
        <c:if test="${not empty displayError}">
            <div class="saas-alert saas-alert-danger alert-dismissible fade show" role="alert">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                    <span><c:out value="${displayError}" escapeXml="true" /></span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
            </div>
        </c:if>

        <c:if test="${course.status == 'PENDING_REVIEW'}">
            <div class="alert alert-warning border border-warning shadow-sm rounded-3 py-3 px-4 mb-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-warning bg-opacity-25 p-2 text-warning fs-4 d-flex align-items-center justify-content-center" style="width: 44px; height: 44px;">
                        <i class="bi bi-clock-history"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-1 text-dark">Khóa học đang ở trạng thái Chờ duyệt (Khóa chỉnh sửa)</h6>
                        <p class="mb-0 text-muted small">
                            Nội dung khóa học đã được gửi tới Ban Quản Trị và tạm khóa chỉnh sửa. Nếu bạn muốn tiếp tục sửa đổi hoặc bổ sung bài giảng, vui lòng chuyển khóa học về Bản nháp.
                        </p>
                    </div>
                </div>
                <button type="button" class="btn btn-warning fw-semibold btn-sm text-dark px-3 shadow-sm"
                        onclick="confirmCancelPublishCourse('${fn:escapeXml(course.title)}', '${pageContext.request.contextPath}/expert/cancel-request-publish?courseId=${course.id}&from=lessons')">
                    <i class="bi bi-arrow-counterclockwise me-1"></i>Thu hồi về Bản nháp để sửa
                </button>
            </div>
        </c:if>

        <!-- Top Header & Primary Actions -->
        <div class="saas-header">
            <div>
                <div class="d-flex align-items-center gap-2 mb-1">
                    <h1 class="saas-title">
                        <i class="bi bi-journal-bookmark text-primary"></i>${course.title}
                    </h1>
                    <c:choose>
                        <c:when test="${course.status == 'PUBLISHED'}">
                            <span class="saas-badge saas-badge-published">
                                <span class="badge-dot"></span>Đã công khai
                            </span>
                        </c:when>
                        <c:when test="${course.status == 'PENDING_REVIEW'}">
                            <span class="saas-badge saas-badge-pending">
                                <span class="badge-dot"></span>Chờ duyệt
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="saas-badge saas-badge-draft">
                                <span class="badge-dot"></span>Bản nháp
                            </span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <p class="saas-subtitle">Quản lý danh sách các bài giảng trong khóa học này</p>
            </div>

            <!-- Action Toolbar -->
            <div class="d-flex flex-wrap align-items-center gap-2">
                <c:choose>
                    <c:when test="${course.status == 'DRAFT'}">
                        <button type="button"
                           class="btn btn-saas-outline-emerald"
                           onclick="confirmPublishCourse('${fn:escapeXml(course.title)}', '${pageContext.request.contextPath}/expert/request-publish?courseId=${course.id}&from=lessons')"
                           title="Gửi duyệt khóa học">
                            <i class="bi bi-send-check"></i>Gửi duyệt
                        </button>
                    </c:when>
                    <c:when test="${course.status == 'PENDING_REVIEW'}">
                        <button type="button"
                           class="btn btn-warning text-dark fw-semibold"
                           onclick="confirmCancelPublishCourse('${fn:escapeXml(course.title)}', '${pageContext.request.contextPath}/expert/cancel-request-publish?courseId=${course.id}&from=lessons')"
                           title="Thu hồi yêu cầu xuất bản về Bản nháp">
                            <i class="bi bi-arrow-counterclockwise me-1"></i>Thu hồi về Bản nháp để sửa
                        </button>
                    </c:when>
                </c:choose>
                <a href="${pageContext.request.contextPath}/quizzes/list?courseId=${course.id}" class="btn btn-saas-outline" title="Quản lý Quiz cho khóa học">
                    <i class="bi bi-patch-question text-warning me-1"></i>Quản lý Quiz
                </a>
                <c:if test="${course.status != 'PENDING_REVIEW'}">
                    <button type="button" class="btn btn-saas-primary" data-bs-toggle="modal" data-bs-target="#addModuleModal">
                        <i class="bi bi-folder-plus me-1"></i>Thêm Chương mới
                    </button>
                </c:if>
            </div>
        </div>

        <!-- Modules & Lessons List (Grouped by Module) -->
        <c:choose>
            <c:when test="${empty course.modules}">
                <div class="saas-module-card p-5 text-center">
                    <div class="saas-stat-icon saas-icon-blue mx-auto mb-3" style="width: 52px; height: 52px; font-size: 1.5rem; border-radius: 12px; background: #eff6ff; color: #2563eb; display: inline-flex; align-items: center; justify-content: center;">
                        <i class="bi bi-collection-play"></i>
                    </div>
                    <h5 class="fw-bold text-dark mb-2">Khóa học này chưa có chương học nào</h5>
                    <p class="text-muted small mb-4" style="max-width: 500px; margin-left: auto; margin-right: auto;">
                        Bắt đầu xây dựng cấu trúc khóa học bằng cách thêm Chương học (Module) đầu tiên. Mỗi bài giảng sẽ được thêm vào bên trong chương học tương ứng.
                    </p>
                    <c:if test="${course.status != 'PENDING_REVIEW'}">
                        <div class="d-flex justify-content-center gap-2">
                            <button type="button" class="btn btn-saas-primary" data-bs-toggle="modal" data-bs-target="#addModuleModal">
                                <i class="bi bi-folder-plus me-1"></i>Thêm Chương đầu tiên
                            </button>
                        </div>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="m" items="${course.modules}">
                    <div class="saas-module-card mb-3" id="moduleCard-${m.id}">
                        <!-- Module Header -->
                        <div class="saas-module-header">
                            <div class="d-flex align-items-center gap-2 flex-grow-1" data-bs-toggle="collapse" data-bs-target="#moduleCollapse-${m.id}" aria-expanded="true">
                                <i class="bi bi-chevron-down module-chevron me-1"></i>
                                <div class="saas-module-title">
                                    <i class="bi bi-folder2-open text-primary"></i>
                                    <span>${m.displayTitle}</span>
                                </div>
                                <span class="pill-neutral ms-1">${fn:length(m.lessons)} bài học</span>
                            </div>
                            <div class="d-flex align-items-center gap-2 flex-shrink-0" onclick="event.stopPropagation();">
                                <c:choose>
                                    <c:when test="${course.status == 'PENDING_REVIEW'}">
                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle py-1.5 px-2" style="font-size: 11px;">
                                            <i class="bi bi-lock-fill me-1"></i>Chờ duyệt (Đã khóa)
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/expert/lesson-detail?courseId=${course.id}&moduleId=${m.id}" class="btn btn-sm btn-saas-primary" title="Thêm bài học vào chương này">
                                            <i class="bi bi-plus-lg me-1"></i>Thêm bài học
                                        </a>
                                        <button type="button" class="btn-icon-action" onclick="openEditModuleModal('${m.id}', '${fn:escapeXml(m.title)}', '${m.orderIndex}')" title="Đổi tên chương">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <button type="button" class="btn-icon-action text-danger" onclick="confirmDeleteModule('${fn:escapeXml(m.title)}', '${pageContext.request.contextPath}/expert/delete-module?courseId=${course.id}&moduleId=${m.id}', ${fn:length(m.lessons)})" title="Xóa chương này">
                                            <i class="bi bi-trash3"></i>
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Module Lessons (Collapsible) -->
                        <div class="collapse show module-lesson-list" id="moduleCollapse-${m.id}" data-module-id="${m.id}">
                            <c:choose>
                                <c:when test="${empty m.lessons}">
                                    <div class="p-4 text-center text-muted small bg-light">
                                        <i class="bi bi-inbox me-1"></i>Chương này chưa có bài học nào.
                                        <c:choose>
                                            <c:when test="${course.status == 'PENDING_REVIEW'}">
                                                <span class="ms-1 text-muted">(Khóa học đang chờ duyệt, vui lòng thu hồi về Bản nháp để thêm bài học)</span>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/expert/lesson-detail?courseId=${course.id}&moduleId=${m.id}" class="ms-1 fw-semibold text-primary text-decoration-none">
                                                    + Bấm vào đây để thêm bài học vào chương này
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="l" items="${m.lessons}" varStatus="lStatus">
                                        <div class="saas-lesson-item ${!l.active ? 'opacity-75 bg-light-subtle' : ''}" id="lessonRow-${l.id}"
                                                 data-lesson-id="${l.id}" data-module-id="${m.id}"
                                                 draggable="${course.status != 'PENDING_REVIEW'}"
                                                 style="transition: all 0.25s ease;">
                                            <div class="d-flex align-items-center gap-3 min-w-0">
                                                <c:if test="${course.status != 'PENDING_REVIEW'}">
                                                    <div class="lesson-drag-handle me-1" style="cursor: grab;" title="Kéo thả để sắp xếp vị trí bài học">
                                                        <i class="bi bi-grip-vertical fs-5"></i>
                                                    </div>
                                                </c:if>
                                                <div class="lesson-thumb-box">
                                                    <img src="${l.thumbnailUrl}" alt="${l.title}"
                                                         onerror="this.src='https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300'">
                                                </div>
                                                <div class="min-w-0">
                                                    <div class="d-flex align-items-center gap-2 mb-1 flex-wrap">
                                                        <span class="pill-neutral lesson-order-badge" style="font-size: 11px;">Bài ${lStatus.count}</span>
                                                        <c:if test="${not empty l.videoUrl}">
                                                            <span class="pill-video"><i class="bi bi-youtube"></i>Video</span>
                                                        </c:if>
                                                        <c:if test="${not empty l.documentUrl}">
                                                            <span class="pill-doc"><i class="bi bi-file-earmark-text"></i>Tài liệu</span>
                                                        </c:if>
                                                        <c:choose>
                                                            <c:when test="${l.active}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle" style="font-size: 11px;">
                                                                    <i class="bi bi-check-circle me-1"></i>Hiển thị
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle" style="font-size: 11px;">
                                                                    <i class="bi bi-eye-slash-fill me-1"></i>Đã ẩn
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="fw-semibold text-dark text-truncate ${!l.active ? 'text-muted' : ''}" style="font-size: 0.95rem;" title="${l.title}">
                                                        ${l.title}
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="d-flex align-items-center gap-2 flex-shrink-0">
                                                <c:choose>
                                                    <c:when test="${course.status == 'PENDING_REVIEW'}">
                                                        <span class="badge bg-light text-muted border py-1.5 px-2" style="font-size: 11px;" title="Khóa học đang chờ duyệt, chuyển về Bản nháp để chỉnh sửa">
                                                            <i class="bi bi-lock me-1"></i>Đã khóa
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/expert/lesson-detail?courseId=${course.id}&moduleId=${m.id}&lessonId=${l.id}" class="btn-icon-action" title="Chỉnh sửa bài học" aria-label="Sửa bài">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>
                                                        <c:choose>
                                                            <c:when test="${l.active}">
                                                                <button type="button" class="btn-icon-action text-warning border-0 bg-transparent ms-1"
                                                                        onclick="confirmToggleVisibility('${l.id}', '${fn:escapeXml(l.title)}', false)"
                                                                        title="Tạm ẩn bài học (Học viên không nhìn thấy)" aria-label="Ẩn bài học">
                                                                    <i class="bi bi-eye-slash"></i>
                                                                </button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button type="button" class="btn-icon-action text-success border-0 bg-transparent ms-1"
                                                                        onclick="confirmToggleVisibility('${l.id}', '${fn:escapeXml(l.title)}', true)"
                                                                        title="Mở hiển thị lại cho học viên" aria-label="Hiện bài học">
                                                                    <i class="bi bi-eye"></i>
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <button type="button" class="btn-icon-action text-danger border-0 bg-transparent ms-1"
                                                                onclick="startDeleteCountdown('${l.id}', '${fn:escapeXml(l.title)}', '${m.id}')"
                                                                title="Xóa bài học (Có 5s để Hoàn tác / Rollback bằng Ctrl+Z)" aria-label="Xóa bài">
                                                            <i class="bi bi-trash3"></i>
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<!-- Floating Undo Delete Countdown Toast (5s Rollback / Ctrl+Z) -->
<div id="undoToastContainer" class="position-fixed bottom-0 start-50 translate-middle-x pb-4" style="z-index: 1080; display: none;">
    <div class="shadow-lg rounded-4 p-3 border border-secondary text-white" style="background: #1e293b; min-width: 380px; max-width: 520px; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.4), 0 8px 10px -6px rgba(0, 0, 0, 0.3);">
        <div class="d-flex align-items-center justify-content-between gap-3 mb-2">
            <div class="d-flex align-items-center gap-2 text-truncate">
                <div class="rounded-circle bg-danger-subtle text-danger d-inline-flex align-items-center justify-content-center flex-shrink-0" style="width: 36px; height: 36px; font-size: 1.1rem;">
                    <i class="bi bi-trash3-fill"></i>
                </div>
                <div class="min-w-0">
                    <div class="text-white-50 small" style="font-size: 11px;">Đang chuẩn bị xóa bài học...</div>
                    <div class="fw-bold text-white text-truncate small" id="undoLessonTitle" style="max-width: 200px;"></div>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2 flex-shrink-0">
                <button type="button" class="btn btn-warning btn-sm fw-bold px-3 py-1.5 rounded-pill shadow-sm d-inline-flex align-items-center gap-1.5" onclick="rollbackDelete()" style="font-size: 12px;">
                    <i class="bi bi-arrow-counterclockwise fs-6"></i>
                    <span>Hoàn tác (<strong id="undoCountdownSeconds">5</strong>s)</span>
                </button>
                <button type="button" class="btn btn-outline-secondary btn-sm text-white-50 border-0 p-1" onclick="commitDeleteNow()" title="Xóa ngay lập tức">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>
        </div>
        <div class="d-flex align-items-center justify-content-between text-muted mt-1 px-1" style="font-size: 11px;">
            <span><i class="bi bi-keyboard me-1 text-light"></i>Bấm <kbd class="bg-dark text-white border border-secondary px-1.5 py-0.5 rounded">Ctrl</kbd> + <kbd class="bg-dark text-white border border-secondary px-1.5 py-0.5 rounded">Z</kbd> để hoàn tác</span>
            <span id="undoStatusText" class="text-warning-emphasis">Hủy sau 5s...</span>
        </div>
        <!-- Countdown Progress Bar -->
        <div class="progress mt-2" style="height: 3px; background-color: rgba(255,255,255,0.15); border-radius: 2px; overflow: hidden;">
            <div id="undoProgressBar" class="progress-bar bg-warning" role="progressbar" style="width: 100%; transition: width 0.05s linear;"></div>
        </div>
    </div>
</div>

<!-- Add Module Modal -->
<div class="modal fade" id="addModuleModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content saas-modal">
            <form action="${pageContext.request.contextPath}/expert/save-module" method="POST">
                <input type="hidden" name="courseId" value="${course.id}">
                <div class="modal-header saas-modal-header">
                    <h5 class="modal-title fw-bold text-dark fs-6">
                        <i class="bi bi-folder-plus text-primary me-2"></i>Thêm Chương học mới
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label saas-form-label">Tên chương học <span class="text-danger">*</span></label>
                        <input type="text" name="title" class="form-control saas-form-control" required placeholder="Ví dụ: Chương 1: Cài đặt và cấu hình">
                    </div>
                </div>
                <div class="modal-footer saas-modal-footer">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-saas-primary btn-sm">Tạo chương</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Module Modal -->
<div class="modal fade" id="editModuleModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content saas-modal">
            <form action="${pageContext.request.contextPath}/expert/save-module" method="POST">
                <input type="hidden" name="courseId" value="${course.id}">
                <input type="hidden" name="id" id="editModuleId">
                <input type="hidden" name="orderIndex" id="editModuleOrder">
                <div class="modal-header saas-modal-header">
                    <h5 class="modal-title fw-bold text-dark fs-6">
                        <i class="bi bi-pencil-square text-primary me-2"></i>Chỉnh sửa Chương học
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label saas-form-label">Tên chương học <span class="text-danger">*</span></label>
                        <input type="text" name="title" id="editModuleTitle" class="form-control saas-form-control" required>
                    </div>
                </div>
                <div class="modal-footer saas-modal-footer">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-saas-primary btn-sm">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function openEditModuleModal(id, title, order) {
        document.getElementById('editModuleId').value = id || '';
        document.getElementById('editModuleTitle').value = title || '';
        document.getElementById('editModuleOrder').value = order || '1';
        new bootstrap.Modal(document.getElementById('editModuleModal')).show();
    }

    function confirmDeleteModule(title, url, lessonCount) {
        if (lessonCount && lessonCount > 0) {
            showConfirmModal({
                title: 'Không thể xóa Chương học',
                html: 'Chương "<strong>' + (title || '') + '</strong>" hiện đang có <strong>' + lessonCount + ' bài học</strong> bên trong.<br><span class="text-danger small mt-2 d-inline-block"><i class="bi bi-exclamation-octagon-fill me-1"></i>Hệ thống không cho phép xóa chương đang chứa bài học. Vui lòng di chuyển hoặc xóa các bài học trước khi xóa chương.</span>',
                type: 'warning',
                icon: 'bi bi-shield-exclamation',
                confirmText: 'Đã hiểu',
                confirmIcon: 'bi bi-check2 me-1',
                confirmBtnClass: 'btn-secondary',
                confirmUrl: null
            });
            return;
        }
        showConfirmModal({
            title: 'Xác nhận xóa Chương học',
            method: 'POST',
            html: 'Bạn có chắc chắn muốn xóa chương "<strong>' + (title || '') + '</strong>"?<br><span class="text-danger small mt-2 d-inline-block"><i class="bi bi-trash3 me-1"></i>Chương học này đang trống và sẽ được xóa vĩnh viễn khỏi khóa học.</span>',
            type: 'danger',
            icon: 'bi bi-trash3-fill',
            confirmText: 'Xóa chương',
            confirmIcon: 'bi bi-trash3 me-1',
            confirmBtnClass: 'btn-danger',
            confirmUrl: url
        });
    }

    // ==========================================
    // 1. TẠM ẨN / MỞ HIỂN THỊ (ẨN LÀ ẨN)
    // ==========================================
    function confirmToggleVisibility(lessonId, lessonTitle, willActive) {
        if (willActive) {
            showConfirmModal({
                title: 'Mở hiển thị bài học',
                method: 'POST',
                html: 'Bạn có chắc chắn muốn mở hiển thị bài học "<strong>' + (lessonTitle || '') + '</strong>" cho học viên?',
                type: 'success',
                icon: 'bi bi-eye-fill',
                confirmText: 'Mở hiển thị',
                confirmIcon: 'bi bi-eye me-1',
                confirmBtnClass: 'btn-success',
                confirmUrl: '${pageContext.request.contextPath}/expert/toggle-lesson-status?courseId=${course.id}&lessonId=' + lessonId + '&active=true'
            });
        } else {
            showConfirmModal({
                title: 'Tạm ẩn bài học',
                method: 'POST',
                html: 'Bạn có chắc chắn muốn tạm ẩn bài học "<strong>' + (lessonTitle || '') + '</strong>" với học viên?<br><span class="text-muted small mt-2 d-inline-block"><i class="bi bi-info-circle me-1"></i>Học viên sẽ không thấy bài học này trong danh sách. Dữ liệu bài học vẫn được giữ nguyên an toàn 100%.</span>',
                type: 'warning',
                icon: 'bi bi-eye-slash-fill',
                confirmText: 'Tạm ẩn',
                confirmIcon: 'bi bi-eye-slash me-1',
                confirmBtnClass: 'btn-warning text-dark',
                confirmUrl: '${pageContext.request.contextPath}/expert/toggle-lesson-status?courseId=${course.id}&lessonId=' + lessonId + '&active=false'
            });
        }
    }

    // ==========================================
    // 2. XÓA BÀI HỌC VỚI COUNTDOWN 5s & ROLLBACK (Ctrl+Z)
    // ==========================================
    let pendingDeleteState = null;
    let deleteTimer = null;
    let progressTimer = null;

    function startDeleteCountdown(lessonId, lessonTitle, moduleId) {
        // Nếu có bài học khác đang chờ xóa dở, commit bài đó ngay
        if (pendingDeleteState) {
            commitDeleteNow();
        }

        const row = document.getElementById('lessonRow-' + lessonId);
        if (!row) return;

        pendingDeleteState = {
            lessonId: lessonId,
            lessonTitle: lessonTitle,
            moduleId: moduleId,
            startTime: Date.now(),
            totalDuration: 5000,
            rowElement: row
        };

        // Làm mờ và khóa tương tác hàng bài học tạm thời
        row.style.opacity = '0.25';
        row.style.pointerEvents = 'none';
        row.style.filter = 'grayscale(100%)';

        // Hiển thị thanh đếm ngược Toast
        const container = document.getElementById('undoToastContainer');
        const titleEl = document.getElementById('undoLessonTitle');
        const secEl = document.getElementById('undoCountdownSeconds');
        const pBar = document.getElementById('undoProgressBar');
        const statusText = document.getElementById('undoStatusText');

        titleEl.textContent = lessonTitle;
        secEl.textContent = '5';
        pBar.style.width = '100%';
        pBar.className = 'progress-bar bg-warning';
        statusText.textContent = 'Xóa vĩnh viễn sau 5s...';
        container.style.display = 'block';

        let elapsed = 0;
        const interval = 50;
        progressTimer = setInterval(() => {
            elapsed += interval;
            const remaining = Math.max(0, 5000 - elapsed);
            const remainingSec = Math.ceil(remaining / 1000);
            const percent = (remaining / 5000) * 100;

            secEl.textContent = remainingSec;
            pBar.style.width = percent + '%';
            if (remainingSec <= 2) {
                pBar.className = 'progress-bar bg-danger';
            }

            if (elapsed >= 5000) {
                clearInterval(progressTimer);
                progressTimer = null;
            }
        }, interval);

        deleteTimer = setTimeout(() => {
            commitDeleteNow();
        }, 5000);
    }

        // ==========================================
    // 3. KÉO THẢ SẮP XẾP BÀI HỌC (DRAG & DROP REORDERING)
    // ==========================================
    let draggedLesson = null;
    let sourceModuleContainer = null;

    function initLessonDragAndDrop() {
        const lessonItems = document.querySelectorAll('.saas-lesson-item[draggable="true"]');
        const moduleLists = document.querySelectorAll('.module-lesson-list');

        lessonItems.forEach(item => {
            item.addEventListener('dragstart', handleDragStart);
            item.addEventListener('dragend', handleDragEnd);
            item.addEventListener('dragover', handleDragOverItem);
            item.addEventListener('dragleave', handleDragLeaveItem);
            item.addEventListener('drop', handleDropOnItem);
        });

        moduleLists.forEach(list => {
            list.addEventListener('dragover', handleDragOverList);
            list.addEventListener('drop', handleDropOnList);
        });
    }

    function handleDragStart(e) {
        draggedLesson = this;
        sourceModuleContainer = this.closest('.module-lesson-list');
        this.classList.add('dragging');
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', this.dataset.lessonId);
    }

    function handleDragEnd(e) {
        this.classList.remove('dragging');
        document.querySelectorAll('.saas-lesson-item.drag-over').forEach(el => el.classList.remove('drag-over'));
        draggedLesson = null;
        sourceModuleContainer = null;
    }

    function handleDragOverItem(e) {
        if (!draggedLesson || draggedLesson === this) return;
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        this.classList.add('drag-over');
    }

    function handleDragLeaveItem(e) {
        this.classList.remove('drag-over');
    }

    function handleDropOnItem(e) {
        if (!draggedLesson || draggedLesson === this) return;
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('drag-over');

        const targetList = this.closest('.module-lesson-list');
        if (!targetList) return;

        // Determine if drop is above or below middle of target
        const rect = this.getBoundingClientRect();
        const dropMiddle = rect.top + rect.height / 2;
        if (e.clientY < dropMiddle) {
            targetList.insertBefore(draggedLesson, this);
        } else {
            targetList.insertBefore(draggedLesson, this.nextSibling);
        }

        finalizeReorder(targetList);
    }

    function handleDragOverList(e) {
        if (!draggedLesson) return;
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
    }

    function handleDropOnList(e) {
        if (!draggedLesson) return;
        e.preventDefault();
        const targetList = this;
        if (!targetList.contains(draggedLesson)) {
            targetList.appendChild(draggedLesson);
        }
        finalizeReorder(targetList);
    }

    function finalizeReorder(targetList) {
        const targetModuleId = targetList.dataset.moduleId;
        if (!targetModuleId) return;

        // Re-number badges in target module
        updateModuleBadges(targetList);

        // If moved across modules, also re-number source module
        if (sourceModuleContainer && sourceModuleContainer !== targetList) {
            updateModuleBadges(sourceModuleContainer);
            updateModuleLessonCount(sourceModuleContainer);
        }
        updateModuleLessonCount(targetList);

        // Collect new ordered lesson IDs
        const items = targetList.querySelectorAll('.saas-lesson-item');
        const lessonIds = [];
        items.forEach(it => {
            if (it.dataset.lessonId) {
                lessonIds.push(it.dataset.lessonId);
                it.dataset.moduleId = targetModuleId;
            }
        });

        if (lessonIds.length === 0) return;

        // Send AJAX request to reorder endpoint
        const formData = new URLSearchParams();
        formData.append('courseId', '${course.id}');
        formData.append('moduleId', targetModuleId);
        lessonIds.forEach(id => formData.append('lessonIds[]', id));

        fetch('${pageContext.request.contextPath}/expert/reorder-lessons', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: formData.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                showFloatingToast(data.message || 'Đã cập nhật vị trí bài học thành công!', 'success');
            } else {
                showFloatingToast(data.message || 'Lỗi cập nhật vị trí bài học.', 'danger');
            }
        })
        .catch(err => {
            console.error('Lỗi lưu thứ tự bài học:', err);
            showFloatingToast('Không thể kết nối máy chủ để lưu thứ tự bài học.', 'danger');
        });
    }

    function updateModuleBadges(listContainer) {
        if (!listContainer) return;
        const badges = listContainer.querySelectorAll('.lesson-order-badge');
        badges.forEach((b, idx) => {
            b.textContent = 'Bài ' + (idx + 1);
        });
    }

    function updateModuleLessonCount(listContainer) {
        if (!listContainer) return;
        const card = listContainer.closest('.saas-module-card');
        if (!card) return;
        const countBadge = card.querySelector('.saas-module-header .pill-neutral');
        const items = listContainer.querySelectorAll('.saas-lesson-item');
        if (countBadge) {
            countBadge.textContent = items.length + ' bài học';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        initLessonDragAndDrop();
    });

// Rollback (Hoàn tác xóa) - Khi bấm nút Hoàn tác hoặc nhấn phím Ctrl + Z
    function rollbackDelete() {
        if (!pendingDeleteState) return;

        if (deleteTimer) { clearTimeout(deleteTimer); deleteTimer = null; }
        if (progressTimer) { clearInterval(progressTimer); progressTimer = null; }

        const row = pendingDeleteState.rowElement;
        const title = pendingDeleteState.lessonTitle;
        pendingDeleteState = null;

        document.getElementById('undoToastContainer').style.display = 'none';

        if (row) {
            row.style.opacity = '1';
            row.style.pointerEvents = '';
            row.style.filter = '';
            row.style.boxShadow = '0 0 0 2px #22c55e';
            setTimeout(() => { row.style.boxShadow = ''; }, 1200);
        }

        showFloatingToast('Đã hoàn tác (Rollback)! Bài học "' + title + '" được giữ nguyên.', 'success');
    }

    // Thực sự xóa vĩnh viễn khỏi CSDL khi hết 5s hoặc bấm Xóa ngay
    function commitDeleteNow() {
        if (!pendingDeleteState) return;

        if (deleteTimer) { clearTimeout(deleteTimer); deleteTimer = null; }
        if (progressTimer) { clearInterval(progressTimer); progressTimer = null; }

        const state = pendingDeleteState;
        pendingDeleteState = null;
        document.getElementById('undoToastContainer').style.display = 'none';

        const row = state.rowElement;
        const lessonId = state.lessonId;
        const courseId = '${course.id}';

        fetch('${pageContext.request.contextPath}/expert/delete-lesson', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: 'courseId=' + encodeURIComponent(courseId) + '&lessonId=' + encodeURIComponent(lessonId) + '&ajax=true'
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                if (row) {
                    row.style.transition = 'all 0.3s ease';
                    row.style.maxHeight = '0px';
                    row.style.padding = '0px';
                    row.style.margin = '0px';
                    row.style.overflow = 'hidden';
                    setTimeout(() => { row.remove(); }, 350);
                }
                showFloatingToast(data.message || 'Đã xóa bài học thành công!', 'success');
            } else {
                if (row) {
                    row.style.opacity = '1';
                    row.style.pointerEvents = '';
                    row.style.filter = '';
                }
                alert(data.message || 'Lỗi khi xóa bài học.');
            }
        })
        .catch(err => {
            console.error('Lỗi kết nối khi xóa bài học:', err);
            // Nếu mất mạng hoặc lỗi máy chủ, tự động khôi phục giao diện và thông báo an toàn
            if (row) {
                row.style.opacity = '1';
                row.style.pointerEvents = '';
                row.style.filter = '';
                row.style.boxShadow = '0 0 0 2px #ef4444';
                setTimeout(() => { row.style.boxShadow = ''; }, 1500);
            }
            showFloatingToast('Mất kết nối mạng! Không thể gửi lệnh xóa tới máy chủ. Bài học đã được tự động giữ nguyên.', 'danger');
        });
    }

    // Lắng nghe phím tắt Ctrl + Z (hoặc Cmd + Z trên macOS)
    window.addEventListener('keydown', function(e) {
        if ((e.ctrlKey || e.metaKey) && (e.key === 'z' || e.key === 'Z')) {
            if (pendingDeleteState) {
                e.preventDefault();
                rollbackDelete();
            }
        }
    });

    // Nếu người dùng tải lại trang (F5) hoặc đóng tab khi đang trong 5s chờ đếm ngược:
    // Theo nguyên tắc Fail-safe: Lệnh xóa bị hủy bỏ (Abort) và CSDL hoàn toàn không bị đụng tới.
    window.addEventListener('beforeunload', function() {
        if (pendingDeleteState) {
            if (deleteTimer) clearTimeout(deleteTimer);
            if (progressTimer) clearInterval(progressTimer);
            pendingDeleteState = null;
        }
    });

    function showFloatingToast(message, type) {
        let toastContainer = document.getElementById('floatingNotificationToast');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.id = 'floatingNotificationToast';
            toastContainer.className = 'toast-container position-fixed top-0 end-0 p-3';
            toastContainer.style.zIndex = '1090';
            toastContainer.innerHTML = '<div id="floatingToastInner" class="toast align-items-center text-white border-0 shadow rounded-3" role="alert" aria-live="assertive" aria-atomic="true"><div class="d-flex"><div class="toast-body small fw-semibold" id="floatingToastMsg"></div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div></div>';
            document.body.appendChild(toastContainer);
        }
        const inner = document.getElementById('floatingToastInner');
        inner.className = 'toast align-items-center text-white border-0 shadow rounded-3 ' + (type === 'success' ? 'bg-success' : 'bg-danger');
        document.getElementById('floatingToastMsg').textContent = message;
        const bsToast = new bootstrap.Toast(inner, { delay: 3500 });
        bsToast.show();
    }

    function confirmPublishCourse(title, url) {
        showConfirmModal({
            title: 'Gửi yêu cầu xuất bản',
            method: 'POST',
            html: 'Bạn có chắc chắn muốn gửi yêu cầu duyệt khóa học "<strong>' + (title || '') + '</strong>" để Quản lý kiểm tra và công khai khóa học?',
            type: 'success',
            icon: 'bi bi-send-check-fill',
            confirmText: 'Gửi duyệt ngay',
            confirmIcon: 'bi bi-send-check me-1',
            confirmBtnClass: 'btn-success',
            confirmUrl: url
        });
    }

    function confirmCancelPublishCourse(title, url) {
        showConfirmModal({
            title: 'Thu hồi yêu cầu xuất bản (Chuyển về Bản nháp)',
            method: 'POST',
            html: 'Bạn có chắc chắn muốn thu hồi yêu cầu duyệt để tiếp tục chỉnh sửa khóa học "<strong>' + (title || '') + '</strong>"?<br><span class="text-muted small mt-2 d-inline-block"><i class="bi bi-info-circle me-1"></i>Khóa học sẽ trở về trạng thái <strong>Bản nháp</strong> để bạn có thể thêm, sửa bài giảng và chương học.</span>',
            type: 'warning',
            icon: 'bi bi-arrow-counterclockwise',
            confirmText: 'Chuyển về Bản nháp',
            confirmIcon: 'bi bi-arrow-counterclockwise me-1',
            confirmBtnClass: 'btn-warning text-dark',
            confirmUrl: url
        });
    }
</script>

<jsp:include page="../common/footer.jsp" />

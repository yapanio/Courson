<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

                <c:set var="pageTitle"
                    value="Quản lý Quiz & Ngân hàng câu hỏi - ${not empty course ? course.title : 'Courson LMS'}" />
                <jsp:include page="../common/header.jsp" />
                <jsp:include page="../common/navbar.jsp" />

                <style>
/* ==========================================================================
   MODERN SAAS DESIGN SYSTEM (Synchronized with Expert Studio & Lesson List)
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

/* Stat Cards */
.saas-stat-card {
    background: var(--saas-card-bg);
    border: 1px solid var(--saas-border);
    border-radius: var(--saas-radius-lg);
    padding: 20px;
    box-shadow: var(--saas-shadow-sm);
    transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.saas-stat-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--saas-shadow-md);
    border-color: #cbd5e1;
}
.saas-stat-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
}
.saas-stat-label {
    font-size: 0.8125rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--saas-text-muted);
}
.saas-stat-icon {
    width: 36px;
    height: 36px;
    border-radius: var(--saas-radius-md);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 1.125rem;
}
.saas-icon-blue { background: #eff6ff; color: #2563eb; }
.saas-icon-emerald { background: #ecfdf5; color: #059669; }
.saas-icon-amber { background: #fffbeb; color: #d97706; }
.saas-icon-slate { background: #f1f5f9; color: #475569; }

.saas-stat-value {
    font-size: 2rem;
    font-weight: 700;
    letter-spacing: -0.03em;
    color: var(--saas-text-heading);
    line-height: 1;
}
.saas-stat-desc {
    font-size: 0.8125rem;
    color: var(--saas-text-muted);
    margin-top: 8px;
    display: flex;
    align-items: center;
    gap: 4px;
}

/* Tabs */
.saas-tabs {
    border-bottom: 1px solid var(--saas-border);
    gap: 8px;
}
.saas-tabs .nav-link {
    color: var(--saas-text-muted);
    font-weight: 600;
    font-size: 0.875rem;
    border: none;
    border-bottom: 2px solid transparent;
    padding: 10px 18px;
    background: transparent;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    border-radius: 0;
    transition: all 0.15s ease;
}
.saas-tabs .nav-link:hover {
    color: var(--saas-accent);
}
.saas-tabs .nav-link.active {
    color: var(--saas-accent);
    border-bottom: 2px solid var(--saas-accent);
    background: transparent;
}
.tab-count-badge {
    font-size: 0.75rem;
    font-weight: 600;
    padding: 2px 8px;
    border-radius: 9999px;
    background: #f1f5f9;
    color: #475569;
    border: 1px solid #e2e8f0;
}
.saas-tabs .nav-link.active .tab-count-badge {
    background: #eff6ff;
    color: #2563eb;
    border-color: #bfdbfe;
}

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
    cursor: pointer;
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
    cursor: pointer;
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
    cursor: pointer;
}
.btn-saas-outline-emerald:hover {
    background: #ecfdf5;
    color: #047857;
    border-color: #6ee7b7;
}

.btn-icon-action {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border: 1px solid var(--saas-border);
    background: #ffffff;
    color: #64748b;
    transition: all 0.15s ease;
    cursor: pointer;
    font-size: 0.875rem;
    text-decoration: none;
}
.btn-icon-action:hover {
    background: #f1f5f9;
    color: #0f172a;
    border-color: #cbd5e1;
}
.btn-icon-action.text-danger:hover {
    background: #fef2f2;
    color: #dc2626 !important;
    border-color: #fecaca;
}

/* Card & Filter Toolbar */
.saas-card {
    background: var(--saas-card-bg);
    border: 1px solid var(--saas-border);
    border-radius: var(--saas-radius-lg);
    box-shadow: var(--saas-shadow-sm);
    overflow: hidden;
}
.saas-toolbar {
    background: #ffffff;
    padding: 14px 18px;
    border: 1px solid var(--saas-border);
    border-radius: var(--saas-radius-md);
    box-shadow: var(--saas-shadow-xs);
    margin-bottom: 16px;
}

/* Module Accordion Section Cards */
.udemy-curriculum-container {
    display: flex;
    flex-direction: column;
    gap: 16px;
}
.udemy-section-item {
    background: var(--saas-card-bg);
    border: 1px solid var(--saas-border);
    border-radius: var(--saas-radius-lg);
    box-shadow: var(--saas-shadow-sm);
    overflow: hidden;
    transition: border-color 0.15s ease;
}
.udemy-section-item:hover {
    border-color: #cbd5e1;
}
.udemy-section-header {
    background: #ffffff;
    padding: 14px 18px;
    border-bottom: 1px solid var(--saas-border);
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    cursor: pointer;
    user-select: none;
    transition: background-color 0.15s ease;
}
.udemy-section-header:hover {
    background-color: #f8fafc;
}
.udemy-section-header.collapsed {
    border-bottom-color: transparent;
}
.udemy-header-toggle {
    cursor: pointer;
    user-select: none;
    text-decoration: none;
}
.udemy-chevron {
    transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    font-size: 0.85rem;
    color: #64748b;
    display: inline-block;
}
.udemy-section-header.collapsed .udemy-chevron,
.udemy-header-toggle.collapsed .udemy-chevron {
    transform: rotate(-90deg);
}
.udemy-section-body {
    background-color: #ffffff;
}

/* Tables */
.clean-table {
    margin-bottom: 0;
}
.clean-table th {
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--saas-text-muted);
    background-color: #f8fafc;
    border-bottom: 1px solid var(--saas-border);
    padding: 10px 16px;
}
.clean-table td {
    padding: 12px 16px;
    vertical-align: middle;
    border-bottom: 1px solid var(--saas-border-subtle);
    font-size: 0.875rem;
}
.clean-table tbody tr:hover {
    background-color: #f8fafc;
}
.clean-table tbody tr:last-child td {
    border-bottom: none;
}

/* Pure text toggle */
.btn-text-toggle {
    background: none !important;
    border: none !important;
    padding: 0 !important;
    font-size: 0.8125rem;
    font-weight: 600;
    color: var(--saas-text-muted);
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    transition: color 0.15s ease;
}
.btn-text-toggle:hover {
    color: var(--saas-accent);
}
.curriculum-meta-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
    padding: 0 4px;
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

.saas-badge-blue {
    background: #eff6ff;
    color: #1d4ed8;
    border: 1px solid #bfdbfe;
}
.saas-badge-blue .badge-dot { background: #2563eb; }

/* Filter Buttons */
.module-filter-btn {
    font-size: 0.8125rem;
    font-weight: 500;
    padding: 6px 12px;
    border-radius: 6px;
    border: 1px solid var(--saas-border);
    background: #ffffff;
    color: var(--saas-text-body);
    transition: all 0.15s ease;
}
.module-filter-btn:hover {
    background: #f8fafc;
    color: var(--saas-text-heading);
}
.module-filter-btn.active {
    background: #0f172a !important;
    border-color: #0f172a !important;
    color: #ffffff !important;
    font-weight: 600;
}

/* Modals */
.modal-content.saas-modal {
    border-radius: 16px;
    border: 1px solid var(--saas-border);
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
    overflow: hidden;
}
.modal-header.saas-modal-header {
    background: #ffffff;
    border-bottom: 1px solid var(--saas-border);
    padding: 18px 24px;
}
.modal-footer.saas-modal-footer {
    background: #f8fafc;
    border-top: 1px solid var(--saas-border);
    padding: 14px 24px;
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
    padding: 8px 12px;
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

.correct-answer-snippet {
    font-size: 0.775rem;
    color: #059669;
    background: #ecfdf5;
    border: 1px solid #d1fae5;
    border-radius: 6px;
    padding: 0.2rem 0.5rem;
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    max-width: 100%;
}
.btn-xs {
    font-size: 0.75rem;
    padding: 0.2rem 0.5rem;
    border-radius: 0.375rem;
}
                </style>

                <main class="main-content py-4">
                    <div class="container">

                        <!-- Modern SaaS Breadcrumb Navigation -->
                        <nav class="saas-breadcrumb" aria-label="breadcrumb">
                            <a href="${pageContext.request.contextPath}/expert/dashboard">
                                <i class="bi bi-speedometer2 me-1"></i>Expert Dashboard
                            </a>
                            <span class="separator">/</span>
                            <c:if test="${not empty course}">
                                <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${course.id}">
                                    ${course.title}
                                </a>
                                <span class="separator">/</span>
                            </c:if>
                            <span class="current">Quản lý Quiz &amp; Ngân hàng câu hỏi</span>
                        </nav>

                        <!-- System Alerts -->
                        <c:if test="${not empty param.success}">
                            <div class="saas-alert saas-alert-success alert-dismissible fade show" role="alert">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-check-circle-fill fs-5"></i>
                                    <div>
                                        <c:choose>
                                            <c:when test="${param.success == 'deleted'}">Đã xóa bài kiểm tra thành công.</c:when>
                                            <c:when test="${param.success == 'saved'}">Đã lưu thông tin cấu hình bài kiểm tra thành công.</c:when>
                                            <c:when test="${param.success == 'question_saved'}">Đã lưu câu hỏi vào ngân hàng thành công!</c:when>
                                            <c:when test="${param.success == 'question_deleted'}">Đã xóa câu hỏi khỏi ngân hàng thành công!</c:when>
                                            <c:otherwise>Thao tác đã được hoàn tất thành công.</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>

                        <c:if test="${not empty param.error}">
                            <div class="saas-alert saas-alert-danger alert-dismissible fade show" role="alert">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                                    <div><c:out value="${param.error}" /></div>
                                </div>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>

                        <!-- Header Top Bar -->
                        <div class="saas-header">
                            <div>
                                <h1 class="saas-title">
                                    <span class="saas-stat-icon saas-icon-blue" style="width: 36px; height: 36px; border-radius: 10px;">
                                        <i class="bi bi-patch-question-fill"></i>
                                    </span>
                                    <span>Quản lý Quiz: ${course.title}</span>
                                </h1>
                                <p class="saas-subtitle">
                                    Quản lý bài kiểm tra theo từng chương và kho ngân hàng câu hỏi tập trung của khóa học
                                </p>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <c:if test="${not empty course}">
                                    <button type="button"
                                        class="btn-saas-outline-emerald"
                                        data-bs-toggle="modal" data-bs-target="#questionModal"
                                        onclick="openCreateQuestionModal('')">
                                        <i class="bi bi-database-add me-1"></i>Thêm câu hỏi
                                    </button>
                                    <button type="button"
                                        class="btn-saas-primary"
                                        data-bs-toggle="modal" data-bs-target="#quizModal"
                                        onclick="openCreateQuizModal('')">
                                        <i class="bi bi-plus-lg me-1"></i>Tạo bài Quiz mới
                                    </button>
                                </c:if>
                            </div>
                        </div>

                        <!-- 3 Stat Cards (Cohesive with Expert Studio) -->
                        <c:if test="${not empty course}">
                            <div class="row g-3 mb-4">
                                <div class="col-md-4 col-sm-6 col-12">
                                    <div class="saas-stat-card">
                                        <div class="saas-stat-header">
                                            <span class="saas-stat-label">Tổng số bài Quiz</span>
                                            <div class="saas-stat-icon saas-icon-blue">
                                                <i class="bi bi-patch-question-fill"></i>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="saas-stat-value">${course.totalQuizzes}</div>
                                            <div class="saas-stat-desc">
                                                <i class="bi bi-collection text-primary"></i> Bài kiểm tra trắc nghiệm
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-4 col-sm-6 col-12">
                                    <div class="saas-stat-card">
                                        <div class="saas-stat-header">
                                            <span class="saas-stat-label">Ngân hàng câu hỏi</span>
                                            <div class="saas-stat-icon saas-icon-emerald">
                                                <i class="bi bi-database-fill-check"></i>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="saas-stat-value">${totalQuestions}</div>
                                            <div class="saas-stat-desc">
                                                <i class="bi bi-check-circle-fill text-success"></i> Câu hỏi trong kho lưu trữ
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-4 col-sm-12 col-12">
                                    <div class="saas-stat-card">
                                        <div class="saas-stat-header">
                                            <span class="saas-stat-label">Số chương học</span>
                                            <div class="saas-stat-icon saas-icon-slate">
                                                <i class="bi bi-folder2-open"></i>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="saas-stat-value">${course.totalModules}</div>
                                            <div class="saas-stat-desc">
                                                <i class="bi bi-layers-half text-secondary"></i> Chương trong khóa học
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- Main Tabs Navigation -->
                        <ul class="nav nav-tabs saas-tabs mb-4" id="assessmentTabs" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active" id="pills-quizzes-tab" data-bs-toggle="tab"
                                    data-bs-target="#pills-quizzes" type="button" role="tab">
                                    <i class="bi bi-collection"></i>Danh sách Quiz
                                    <c:if test="${not empty course}">
                                        <span class="tab-count-badge">${course.totalQuizzes}</span>
                                    </c:if>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="pills-questions-tab" data-bs-toggle="tab"
                                    data-bs-target="#pills-questions" type="button" role="tab">
                                    <i class="bi bi-database"></i>Ngân hàng câu hỏi
                                    <span class="tab-count-badge" id="totalQuestionsBadge">${totalQuestions}</span>
                                </button>
                            </li>
                        </ul>

                        <!-- Tab Content -->
                        <div class="tab-content" id="assessmentTabsContent">

                            <!-- ======================================================= -->
                            <!-- TAB 1: DANH SÁCH BÀI QUIZ THEO TỪNG CHƯƠNG              -->
                            <!-- ======================================================= -->
                            <div class="tab-pane fade show active" id="pills-quizzes" role="tabpanel">
                                <c:choose>
                                    <c:when test="${empty course or empty course.modules}">
                                        <div class="saas-card p-5 text-center mb-4">
                                            <div class="bg-light text-muted rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-3"
                                                style="width: 64px; height: 64px;">
                                                <i class="bi bi-folder-x fs-2"></i>
                                            </div>
                                            <h5 class="fw-bold text-dark mb-1">Khóa học này chưa có chương học nào!</h5>
                                            <p class="text-muted small mb-3">Bạn cần tạo ít nhất một chương học để có
                                                thể thiết lập các bài kiểm tra trắc nghiệm.</p>
                                            <div>
                                                <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${course.id}"
                                                    class="btn-saas-primary">
                                                    <i class="bi bi-plus-circle me-1"></i>Tạo chương học ngay
                                                </a>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Thanh công cụ tìm kiếm & lọc Tab 1 -->
                                        <div class="saas-toolbar">
                                            <div class="row g-2 align-items-center justify-content-between">
                                                <div class="col-md-7 col-12">
                                                    <div class="input-group input-group-sm">
                                                        <span class="input-group-text bg-light border-end-0 text-muted">
                                                            <i class="bi bi-search"></i>
                                                        </span>
                                                        <input type="text" id="quizSearchInput"
                                                            class="form-control border-start-0 bg-light"
                                                            placeholder="Tìm kiếm bài thi theo tên hoặc chương...">
                                                        <button
                                                            class="btn btn-outline-secondary border-start-0 bg-light text-muted d-none"
                                                            type="button" id="clearQuizSearchBtn">
                                                            <i class="bi bi-x-circle"></i>
                                                        </button>
                                                    </div>
                                                </div>
                                                <div class="col-md-5 col-12 d-flex justify-content-md-end align-items-center gap-2">
                                                    <div class="btn-group btn-group-sm w-100 w-md-auto" role="group"
                                                        aria-label="Filter modules">
                                                        <button type="button"
                                                            class="module-filter-btn active"
                                                            data-filter="all">
                                                            Tất cả (${course.totalModules})
                                                        </button>
                                                        <button type="button"
                                                            class="module-filter-btn"
                                                            data-filter="has-quiz">
                                                            Có Quiz (${course.modulesWithQuizCount})
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Meta bar: Thông tin số lượng & nút text Thu gọn / Mở rộng tất cả -->
                                        <!-- Meta bar: Thông tin số lượng & nút text Thu gọn / Mở rộng tất cả -->
                                        <div class="curriculum-meta-bar">
                                            <span class="small text-muted fw-semibold">
                                                <i class="bi bi-layers-half text-secondary me-1"></i>${course.totalModules}
                                                chương &bull; ${course.totalQuizzes} bài thi
                                            </span>
                                            <button type="button" class="btn-text-toggle" id="toggleAllQuizBtn"
                                                onclick="toggleAllQuizSections()">
                                                <i class="bi bi-arrows-expand me-1"></i><span>Mở rộng tất cả</span>
                                            </button>
                                        </div>

                                        <!-- Thông báo khi filter không tìm thấy quiz nào -->
                                        <div id="quizTabNoResult"
                                            class="saas-card p-5 text-center d-none mb-3">
                                            <div class="text-muted mb-2"><i class="bi bi-search fs-2"></i></div>
                                            <h6 class="fw-bold text-dark mb-1">Không tìm thấy bài Quiz nào phù hợp</h6>
                                            <p class="small text-muted mb-0">Thử tìm kiếm với từ khóa khác hoặc chọn
                                                "Tất cả".</p>
                                        </div>

                                        <!-- Danh sách Modules & Quizzes dạng SaaS Module Cards -->
                                        <div class="udemy-curriculum-container mb-4" id="quizCurriculumContainer">
                                            <c:forEach var="m" items="${course.modules}">
                                                <c:set var="mHasQuizzes" value="${m.hasQuizzes}" />
                                                <div class="udemy-section-item" id="module-${m.id}"
                                                    data-has-quizzes="${mHasQuizzes ? 'true' : 'false'}"
                                                    data-module-title="${fn:toLowerCase(m.title)}">

                                                    <!-- Header: Click khu vực tiêu đề để toggle collapse, nút Tạo Quiz nằm riêng biệt -->
                                                    <div class="udemy-section-header collapsed" id="quiz-header-${m.id}">
                                                        <div class="udemy-header-toggle d-flex align-items-center gap-2 flex-grow-1 overflow-hidden collapsed"
                                                            data-bs-toggle="collapse"
                                                            data-bs-target="#quiz-collapse-${m.id}"
                                                            aria-expanded="false"
                                                            role="button">
                                                            <i class="bi bi-chevron-down udemy-chevron"></i>
                                                            <span class="badge bg-light text-dark border fw-semibold flex-shrink-0">
                                                                Chương ${m.orderIndex}
                                                            </span>
                                                            <span class="fw-bold text-dark text-truncate">${m.title}</span>
                                                            <c:choose>
                                                                <c:when test="${mHasQuizzes}">
                                                                    <span class="saas-badge saas-badge-blue flex-shrink-0 ms-1">
                                                                        <span class="badge-dot"></span>${m.quizCount} bài quiz
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="saas-badge saas-badge-draft flex-shrink-0 ms-1">
                                                                        <span class="badge-dot"></span>0 bài quiz
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>

                                                        <!-- Nút tạo quiz: Hoàn toàn tách biệt khỏi collapse trigger -->
                                                        <div class="flex-shrink-0" onclick="event.stopPropagation();">
                                                            <button type="button"
                                                                class="btn-saas-outline"
                                                                onclick="event.stopPropagation(); openCreateQuizModal('${m.id}', '${m.quizCount + 1}')"
                                                                data-bs-toggle="modal" data-bs-target="#quizModal">
                                                                <i class="bi bi-plus-lg me-1"></i>Tạo Quiz
                                                            </button>
                                                        </div>
                                                    </div>

                                                    <!-- Body: Collapsible (Closed by default) -->
                                                    <div class="collapse udemy-section-body"
                                                        id="quiz-collapse-${m.id}">
                                                        <c:choose>
                                                            <c:when test="${not mHasQuizzes}">
                                                                <div class="py-3 px-4 bg-light d-flex align-items-center justify-content-between text-muted small">
                                                                    <span class="d-flex align-items-center gap-1.5 text-secondary">
                                                                        <i class="bi bi-info-circle text-muted"></i>
                                                                        Chưa có bài kiểm tra nào trong chương này
                                                                    </span>
                                                                    <button type="button"
                                                                        class="btn btn-sm btn-link text-primary text-decoration-none fw-semibold p-0"
                                                                        onclick="openCreateQuizModal('${m.id}', 1)">
                                                                        + Tạo bài Quiz ngay
                                                                    </button>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="table-responsive bg-white">
                                                                    <table class="table clean-table mb-0 align-middle">
                                                                        <thead>
                                                                            <tr>
                                                                                <th style="width: 70px;"
                                                                                    class="text-center">TT</th>
                                                                                <th>Tên bài thi (Quiz)</th>
                                                                                <th style="width: 140px;"
                                                                                    class="text-center">Điểm đạt</th>
                                                                                <th style="width: 140px;"
                                                                                    class="text-center">Thời lượng</th>
                                                                                <th style="width: 130px;"
                                                                                    class="text-end pe-3">Hành động</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <c:forEach var="q" items="${m.quizzes}">
                                                                                <tr class="quiz-row"
                                                                                    data-quiz-title="${fn:toLowerCase(q.title)}">
                                                                                    <td class="text-center">
                                                                                        <span class="badge bg-light text-muted border">#${q.orderIndex}</span>
                                                                                    </td>
                                                                                    <td>
                                                                                        <div>
                                                                                            <a href="${pageContext.request.contextPath}/quizzes/detail?id=${q.id}&courseId=${course.id}"
                                                                                                class="fw-semibold text-dark text-decoration-none"
                                                                                                style="transition: color 0.15s ease;"
                                                                                                onmouseover="this.style.color='var(--saas-accent)'"
                                                                                                onmouseout="this.style.color='var(--saas-text-heading)'">
                                                                                                ${q.title}
                                                                                            </a>
                                                                                            <span class="small text-muted d-block" style="font-size: 0.75rem;">
                                                                                                Mã đề: #${q.id}
                                                                                                <c:if test="${q.attemptCount > 0}">
                                                                                                    • <span class="text-primary fw-semibold" title="Đã có ${q.attemptCount} lượt học viên làm bài"><i class="bi bi-people-fill me-1"></i>${q.attemptCount} lượt thi</span>
                                                                                                </c:if>
                                                                                            </span>
                                                                                        </div>
                                                                                    </td>
                                                                                    <td class="text-center">
                                                                                        <span class="saas-badge saas-badge-published">
                                                                                            <span class="badge-dot"></span>${q.passScore}%
                                                                                        </span>
                                                                                    </td>
                                                                                    <td class="text-center">
                                                                                        <c:choose>
                                                                                            <c:when test="${q.timeLimitMinutes != null and q.timeLimitMinutes > 0}">
                                                                                                <span class="badge bg-light text-dark border px-2 py-1">
                                                                                                    <i class="bi bi-stopwatch text-primary me-1"></i>${q.timeLimitMinutes} phút
                                                                                                </span>
                                                                                            </c:when>
                                                                                            <c:otherwise>
                                                                                                <span class="badge bg-light text-muted border px-2 py-1">Tự do</span>
                                                                                            </c:otherwise>
                                                                                        </c:choose>
                                                                                    </td>
                                                                                    <td class="text-end pe-3">
                                                                                        <div class="d-inline-flex align-items-center gap-1">
                                                                                            <button type="button"
                                                                                                class="btn-icon-action"
                                                                                                onclick="openEditQuizModal('${q.id}', '${m.id}', '${fn:escapeXml(q.title)}', '${q.passScore}', '${q.timeLimitMinutes}', '${q.orderIndex}')"
                                                                                                data-bs-toggle="modal"
                                                                                                data-bs-target="#quizModal"
                                                                                                title="Sửa thông tin">
                                                                                                <i class="bi bi-gear"></i>
                                                                                            </button>
                                                                                            <c:choose>
                                                                                                <c:when test="${q.attemptCount > 0}">
                                                                                                    <button type="button"
                                                                                                        class="btn-icon-action text-muted"
                                                                                                        onclick="alert('Không thể xóa bài kiểm tra vì đã có ${q.attemptCount} lượt làm bài của học viên. Hệ thống cần bảo toàn dữ liệu điểm số và tiến độ học tập!');"
                                                                                                        title="Đã có ${q.attemptCount} lượt thi (không thể xóa để bảo toàn dữ liệu)">
                                                                                                        <i class="bi bi-lock-fill text-warning"></i>
                                                                                                    </button>
                                                                                                </c:when>
                                                                                                <c:otherwise>
                                                                                                    <button type="button"
                                                                                                        class="btn-icon-action text-danger"
                                                                                                        onclick="openDeleteQuizModal('${q.id}', '${fn:escapeXml(q.title)}', '${course.id}', '${m.id}')"
                                                                                                        data-bs-toggle="modal"
                                                                                                        data-bs-target="#deleteQuizModal"
                                                                                                        title="Xóa bài Quiz">
                                                                                                        <i class="bi bi-trash3"></i>
                                                                                                    </button>
                                                                                                </c:otherwise>
                                                                                            </c:choose>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- ======================================================= -->
                            <!-- TAB 2: NGÂN HÀNG CÂU HỎI (HIỂN THỊ THEO CHƯƠNG)          -->
                            <!-- ======================================================= -->
                            <div class="tab-pane fade" id="pills-questions" role="tabpanel">
                                <c:choose>
                                    <c:when test="${empty course or empty course.modules}">
                                        <div class="saas-card p-5 text-center mb-4">
                                            <div class="bg-light text-muted rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-3"
                                                style="width: 64px; height: 64px;">
                                                <i class="bi bi-folder-x fs-2"></i>
                                            </div>
                                            <h5 class="fw-bold text-dark mb-1">Khóa học này chưa có chương học nào!</h5>
                                            <p class="text-muted small mb-0">Bạn cần tạo ít nhất một chương học để quản
                                                lý ngân hàng câu hỏi.</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Toolbar lọc & tìm kiếm câu hỏi Tab 2 -->
                                        <div class="saas-toolbar">
                                            <div class="row g-2 align-items-center justify-content-between">
                                                <div class="col-md-5 col-12">
                                                    <div class="input-group input-group-sm">
                                                        <span class="input-group-text bg-light border-end-0 text-muted">
                                                            <i class="bi bi-search"></i>
                                                        </span>
                                                        <input type="text" id="questionSearchInput"
                                                            class="form-control border-start-0 bg-light"
                                                            placeholder="Tìm kiếm nội dung câu hỏi...">
                                                        <button
                                                            class="btn btn-outline-secondary border-start-0 bg-light text-muted d-none"
                                                            type="button" id="clearQuestionSearchBtn">
                                                            <i class="bi bi-x-circle"></i>
                                                        </button>
                                                    </div>
                                                </div>

                                                <div class="col-md-3 col-sm-6 col-12">
                                                    <select id="questionModuleFilter"
                                                        class="form-select form-select-sm bg-light">
                                                        <option value="all">Tất cả chương học</option>
                                                        <c:forEach var="moduleItem" items="${course.modules}">
                                                            <option value="${moduleItem.id}">Chương
                                                                ${moduleItem.orderIndex}: ${moduleItem.title}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>

                                                <div class="col-md-2 col-sm-6 col-12">
                                                    <select id="questionTypeFilter"
                                                        class="form-select form-select-sm bg-light">
                                                        <option value="all">Tất cả loại câu</option>
                                                        <option value="SINGLE_CHOICE">Trắc nghiệm</option>
                                                        <option value="TRUE_FALSE">Đúng / Sai</option>
                                                    </select>
                                                </div>

                                                <div class="col-md-2 col-12 text-md-end d-flex justify-content-md-end">
                                                    <button type="button"
                                                        class="btn-saas-outline-emerald w-100 w-md-auto"
                                                        onclick="openCreateQuestionModal('')" data-bs-toggle="modal"
                                                        data-bs-target="#questionModal">
                                                        <i class="bi bi-plus-lg me-1"></i>Thêm câu hỏi
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Meta bar Tab 2 -->
                                        <div class="curriculum-meta-bar">
                                            <span class="small text-muted fw-semibold">
                                                <i class="bi bi-layers-half text-secondary me-1"></i>${course.totalModules}
                                                chương &bull; Hiển thị <strong id="questionVisibleCount"
                                                    class="text-dark">${totalQuestions}</strong> / ${totalQuestions} câu hỏi
                                            </span>
                                            <button type="button" class="btn-text-toggle" id="toggleAllQuestionBtn"
                                                onclick="toggleAllQuestionSections()">
                                                <i class="bi bi-arrows-expand me-1"></i><span>Mở rộng tất cả</span>
                                            </button>
                                        </div>

                                        <!-- Thông báo khi filter không tìm thấy câu hỏi nào -->
                                        <div id="questionEmptyFilter"
                                            class="saas-card p-5 text-center d-none mb-3">
                                            <div class="text-muted mb-2"><i class="bi bi-funnel fs-2"></i></div>
                                            <h6 class="fw-bold text-dark mb-1">Không tìm thấy câu hỏi nào phù hợp</h6>
                                            <p class="small text-muted mb-0">Thử thay đổi từ khóa tìm kiếm hoặc chọn lại
                                                các bộ lọc.</p>
                                        </div>

                                        <!-- Danh sách câu hỏi theo từng chương dạng SaaS Module Cards -->
                                        <div class="udemy-curriculum-container mb-4" id="questionCurriculumContainer">
                                            <c:forEach var="m" items="${course.modules}">
                                                <c:set var="mHasQuestions" value="${m.hasQuestions}" />
                                                <div class="udemy-section-item question-module-section"
                                                    id="q-module-${m.id}" data-module-id="${m.id}"
                                                    data-has-questions="${mHasQuestions ? 'true' : 'false'}"
                                                    data-module-title="${fn:toLowerCase(m.title)}">

                                                    <!-- Header Chương: Click khu vực tiêu đề để đóng/mở, nút Thêm câu hỏi nằm riêng biệt -->
                                                    <div class="udemy-section-header collapsed" id="q-header-${m.id}">
                                                        <div class="udemy-header-toggle d-flex align-items-center gap-2 flex-grow-1 overflow-hidden collapsed"
                                                            data-bs-toggle="collapse"
                                                            data-bs-target="#q-collapse-${m.id}"
                                                            aria-expanded="false"
                                                            role="button">
                                                            <i class="bi bi-chevron-down udemy-chevron"></i>
                                                            <span class="badge bg-light text-dark border fw-semibold flex-shrink-0">
                                                                Chương ${m.orderIndex}
                                                            </span>
                                                            <span class="fw-bold text-dark text-truncate">${m.title}</span>
                                                            <c:choose>
                                                                <c:when test="${mHasQuestions}">
                                                                    <span class="saas-badge saas-badge-published flex-shrink-0 ms-1">
                                                                        <span class="badge-dot"></span>${m.questionCount} câu hỏi
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="saas-badge saas-badge-draft flex-shrink-0 ms-1">
                                                                        <span class="badge-dot"></span>0 câu hỏi
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>

                                                        <!-- Nút thêm câu hỏi: Hoàn toàn tách biệt khỏi collapse trigger -->
                                                        <div class="flex-shrink-0" onclick="event.stopPropagation();">
                                                            <button type="button"
                                                                class="btn-saas-outline-emerald py-1 px-2.5 small"
                                                                onclick="event.stopPropagation(); openCreateQuestionModal('${m.id}')"
                                                                data-bs-toggle="modal" data-bs-target="#questionModal">
                                                                <i class="bi bi-plus-lg me-1"></i>Thêm câu hỏi
                                                            </button>
                                                        </div>
                                                    </div>

                                                    <!-- Body Chương: Danh sách câu hỏi (Closed by default) -->
                                                    <div class="collapse udemy-section-body"
                                                        id="q-collapse-${m.id}">
                                                        <c:choose>
                                                            <c:when test="${not mHasQuestions}">
                                                                <div class="py-3 px-4 bg-light d-flex align-items-center justify-content-between text-muted small">
                                                                    <span class="d-flex align-items-center gap-1.5 text-secondary">
                                                                        <i class="bi bi-info-circle text-muted"></i>
                                                                        Chưa có câu hỏi nào trong chương này
                                                                    </span>
                                                                    <button type="button"
                                                                        class="btn btn-sm btn-link text-success text-decoration-none fw-semibold p-0"
                                                                        onclick="openCreateQuestionModal('${m.id}')">
                                                                        + Thêm câu hỏi ngay
                                                                    </button>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="table-responsive bg-white">
                                                                    <table class="table clean-table mb-0 align-middle">
                                                                        <thead>
                                                                            <tr>
                                                                                <th style="width: 65px;"
                                                                                    class="text-center">ID</th>
                                                                                <th>Nội dung câu hỏi &amp; Đáp án đúng</th>
                                                                                <th style="width: 140px;"
                                                                                    class="text-center">Dạng câu</th>
                                                                                <th style="width: 90px;"
                                                                                    class="text-center">Điểm</th>
                                                                                <th style="width: 110px;"
                                                                                    class="text-end pe-3">Hành động</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <c:forEach var="q" items="${m.questions}">
                                                                                <tr class="question-row"
                                                                                    data-module-id="${q.moduleId}"
                                                                                    data-type="${q.questionType}"
                                                                                    data-text="${fn:toLowerCase(fn:escapeXml(q.questionText))}"
                                                                                    data-q-id="${q.id}"
                                                                                    data-q-points="${q.defaultPoints}"
                                                                                    data-q-text="${fn:escapeXml(q.questionText)}">
                                                                                    <td class="text-center text-muted small fw-semibold">
                                                                                        #${q.id}
                                                                                        <!-- Hidden Options Data for Edit Modal -->
                                                                                        <div class="d-none question-options-data">
                                                                                            <c:forEach var="opt" items="${q.options}">
                                                                                                <span class="q-opt-item"
                                                                                                      data-text="<c:out value='${opt.optionText}' />"
                                                                                                      data-correct="${opt.correct}"></span>
                                                                                            </c:forEach>
                                                                                        </div>
                                                                                    </td>
                                                                                    <td>
                                                                                        <div class="fw-medium text-dark mb-1">
                                                                                            <c:out value="${q.questionText}" />
                                                                                        </div>

                                                                                        <!-- Hiển thị đáp án đúng & toggle xem chi tiết options -->
                                                                                        <div class="d-flex flex-wrap align-items-center gap-2 mt-1">
                                                                                            <c:set var="correctOptText" value="" />
                                                                                            <c:forEach var="opt" items="${q.options}">
                                                                                                <c:if test="${opt.correct}">
                                                                                                    <c:set var="correctOptText" value="${opt.optionText}" />
                                                                                                </c:if>
                                                                                            </c:forEach>

                                                                                            <c:if test="${not empty correctOptText}">
                                                                                                <span class="correct-answer-snippet">
                                                                                                    <i class="bi bi-check-circle-fill"></i>
                                                                                                    <span>Đáp án đúng: <strong><c:out value="${correctOptText}" /></strong></span>
                                                                                                </span>
                                                                                            </c:if>

                                                                                            <c:if test="${q.answerCount > 0}">
                                                                                                <span class="badge bg-secondary-subtle text-secondary border px-2 py-0.5" style="font-size: 0.72rem;" title="Đã có ${q.answerCount} bài làm của học viên liên quan">
                                                                                                    <i class="bi bi-lock-fill me-1"></i>Đã thi (${q.answerCount})
                                                                                                </span>
                                                                                            </c:if>
                                                                                            <c:if test="${q.assignmentCount > 0}">
                                                                                                <span class="badge bg-primary-subtle text-primary border px-2 py-0.5" style="font-size: 0.72rem;" title="Đang được sử dụng trong bài kiểm tra">
                                                                                                    <i class="bi bi-link-45deg me-1"></i>Đang dùng
                                                                                                </span>
                                                                                            </c:if>

                                                                                            <c:if test="${not empty q.options}">
                                                                                                <button type="button"
                                                                                                    class="btn btn-xs btn-outline-secondary py-0 px-2 rounded-pill"
                                                                                                    data-bs-toggle="collapse"
                                                                                                    data-bs-target="#options-collapse-${q.id}"
                                                                                                    title="Xem danh sách tất cả các phương án">
                                                                                                    <i class="bi bi-list-ul me-1"></i>Xem ${fn:length(q.options)} lựa chọn
                                                                                                </button>
                                                                                            </c:if>
                                                                                        </div>

                                                                                        <!-- Danh sách các lựa chọn có thể mở ra khi bấm -->
                                                                                        <c:if test="${not empty q.options}">
                                                                                            <div class="collapse mt-2" id="options-collapse-${q.id}">
                                                                                                <div class="p-2.5 rounded-3 bg-light border row g-2 small">
                                                                                                    <c:forEach var="opt" items="${q.options}" varStatus="optStatus">
                                                                                                        <div class="col-md-6 col-12">
                                                                                                            <div class="d-flex align-items-start gap-2 p-1.5 rounded-2 ${opt.correct ? 'bg-success-subtle text-success fw-semibold border border-success-subtle' : 'bg-white border text-secondary'}">
                                                                                                                <span class="badge ${opt.correct ? 'bg-success text-white' : 'bg-secondary-subtle text-secondary'} rounded-circle px-1.5 py-1"
                                                                                                                    style="font-size: 0.7rem; width: 20px; height: 20px; display: inline-flex; align-items: center; justify-content: center;">
                                                                                                                    ${optStatus.index == 0 ? 'A' : (optStatus.index == 1 ? 'B' : (optStatus.index == 2 ? 'C' : 'D'))}
                                                                                                                </span>
                                                                                                                <span class="text-break"><c:out value="${opt.optionText}" /></span>
                                                                                                                <c:if test="${opt.correct}">
                                                                                                                    <i class="bi bi-check2 text-success ms-auto flex-shrink-0"></i>
                                                                                                                </c:if>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                    </c:forEach>
                                                                                                </div>
                                                                                            </div>
                                                                                        </c:if>
                                                                                    </td>
                                                                                    <td class="text-center">
                                                                                        <span class="saas-badge saas-badge-draft">
                                                                                            <c:choose>
                                                                                                <c:when test="${q.questionType == 'TRUE_FALSE'}">Đúng / Sai</c:when>
                                                                                                <c:otherwise>Trắc nghiệm</c:otherwise>
                                                                                            </c:choose>
                                                                                        </span>
                                                                                    </td>
                                                                                    <td class="text-center fw-semibold text-secondary">
                                                                                        ${q.defaultPoints} đ
                                                                                    </td>
                                                                                    <td class="text-end pe-3 text-nowrap">
                                                                                        <div class="d-inline-flex align-items-center gap-1">
                                                                                            <button type="button"
                                                                                                class="btn-icon-action"
                                                                                                title="Sửa câu hỏi"
                                                                                                onclick="openEditQuestionModal(this)">
                                                                                                <i class="bi bi-pencil-square"></i>
                                                                                            </button>
                                                                                            <c:choose>
                                                                                                <c:when test="${q.answerCount > 0}">
                                                                                                    <button type="button"
                                                                                                        class="btn-icon-action text-muted"
                                                                                                        title="Đã có ${q.answerCount} bài làm của học viên liên quan (không thể xóa)"
                                                                                                        onclick="alert('Không thể xóa câu hỏi này vì đã có ${q.answerCount} bài làm của học viên liên kết với câu hỏi trong lịch sử thi!');">
                                                                                                        <i class="bi bi-lock-fill text-warning"></i>
                                                                                                    </button>
                                                                                                </c:when>
                                                                                                <c:when test="${q.assignmentCount > 0}">
                                                                                                    <button type="button"
                                                                                                        class="btn-icon-action text-muted"
                                                                                                        title="Câu hỏi đang được gán trong bài kiểm tra (vui lòng gỡ khỏi bài thi trước khi xóa)"
                                                                                                        onclick="alert('Không thể xóa câu hỏi vì đang được sử dụng trong bài kiểm tra. Vui lòng gỡ câu hỏi khỏi bài kiểm tra trước!');">
                                                                                                        <i class="bi bi-link-45deg text-primary"></i>
                                                                                                    </button>
                                                                                                </c:when>
                                                                                                <c:otherwise>
                                                                                                    <a href="${pageContext.request.contextPath}/quizzes/delete-question?id=${q.id}&courseId=${course.id}"
                                                                                                        class="btn-icon-action text-danger"
                                                                                                        onclick="return confirm('Bạn có chắc chắn muốn xóa câu hỏi này khỏi ngân hàng câu hỏi?');"
                                                                                                        title="Xóa câu hỏi">
                                                                                                        <i class="bi bi-trash3"></i>
                                                                                                    </a>
                                                                                                </c:otherwise>
                                                                                            </c:choose>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                        </div>
                    </div>
                </main>

                <!-- ======================================================= -->
                <!-- MODAL: TẠO MỚI & CHỈNH SỬA QUIZ                        -->
                <!-- ======================================================= -->
                <div class="modal fade" id="quizModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content saas-modal">
                            <form id="quizForm" action="${pageContext.request.contextPath}/quizzes/save" method="POST">
                                <input type="hidden" name="id" id="modalQuizId" value="">
                                <c:if test="${not empty course}">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                </c:if>

                                <div class="modal-header saas-modal-header">
                                    <h5 class="modal-title fw-bold text-dark d-flex align-items-center gap-2"
                                        id="quizModalLabel">
                                        <span class="text-primary"><i class="bi bi-patch-question"></i></span>
                                        Tạo bài kiểm tra mới (Quiz)
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>

                                <div class="modal-body p-4">
                                    <div class="mb-3">
                                        <label class="saas-form-label">Thuộc chương học
                                            <span class="text-danger">*</span></label>
                                        <select name="moduleId" id="modalModuleSelect" class="form-select saas-form-control"
                                            required>
                                            <c:forEach var="m" items="${course.modules}">
                                                <option value="${m.id}">${m.displayTitle}</option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label class="saas-form-label">Tên bài kiểm tra
                                            <span class="text-danger">*</span></label>
                                        <input type="text" name="title" id="modalQuizTitle"
                                            class="form-control saas-form-control" placeholder="Ví dụ: Quiz 1 - Tổng quan..."
                                            required>
                                    </div>

                                    <div class="row g-3 mb-3">
                                        <div class="col-6">
                                            <label class="saas-form-label">Điểm đạt tối
                                                thiểu (%) <span class="text-danger">*</span></label>
                                            <div class="input-group">
                                                <input type="number" name="passScore" id="modalQuizPassScore"
                                                    class="form-control saas-form-control rounded-start-3" value="50" min="0" max="100"
                                                    required>
                                                <span class="input-group-text bg-light text-muted fw-bold">%</span>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <label class="saas-form-label">Thời lượng
                                                (Phút)</label>
                                            <div class="input-group">
                                                <input type="number" name="timeLimitMinutes" id="modalQuizTimeLimit"
                                                    class="form-control saas-form-control rounded-start-3" value="15" min="1"
                                                    placeholder="Để trống nếu tự do">
                                                <span class="input-group-text bg-light text-muted">phút</span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mb-2">
                                        <label class="saas-form-label">Thứ tự hiển thị <span
                                                class="text-danger">*</span></label>
                                        <input type="number" name="orderIndex" id="modalQuizOrderIndex"
                                            class="form-control saas-form-control" value="1" min="1" required>
                                        <div id="modalQuizOrderHint" class="form-text small text-muted">
                                            Số thứ tự phải không trùng với bài Quiz khác trong cùng chương.
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-footer saas-modal-footer">
                                    <button type="button" class="btn-saas-outline"
                                        data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit"
                                        class="btn-saas-primary"
                                        id="submitQuizBtn">
                                        <i class="bi bi-save me-1"></i>Lưu bài thi
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- MODAL: XÁC NHẬN XÓA QUIZ                                -->
                <!-- ======================================================= -->
                <div class="modal fade" id="deleteQuizModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered modal-sm">
                        <div class="modal-content saas-modal">
                            <div class="modal-body text-center p-4">
                                <div class="bg-danger-subtle text-danger rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                                    style="width: 52px; height: 52px; font-size: 1.35rem;">
                                    <i class="bi bi-trash3-fill"></i>
                                </div>
                                <h5 class="fw-bold text-dark mb-1">Xác nhận xóa bài thi?</h5>
                                <p class="small text-muted mb-4" id="deleteQuizTitle">
                                    Thao tác này sẽ xóa bài kiểm tra khỏi khóa học. Các câu hỏi trong ngân hàng vẫn được
                                    giữ nguyên.
                                </p>
                                <div class="d-flex justify-content-center gap-2">
                                    <button type="button" class="btn-saas-outline"
                                        data-bs-dismiss="modal">Hủy</button>
                                    <a href="#" id="confirmDeleteLink"
                                        class="btn btn-danger btn-sm fw-semibold rounded-3 px-3">
                                        <i class="bi bi-trash3 me-1"></i>Xóa bài thi
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- MODAL: THÊM CÂU HỎI MỚI VÀO NGÂN HÀNG CỦA KHÓA HỌC       -->
                <!-- ======================================================= -->
                <div class="modal fade" id="questionModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered modal-lg">
                        <div class="modal-content saas-modal">
                            <form action="${pageContext.request.contextPath}/quizzes/save-question" method="POST"
                                id="bankQuestionForm">
                                <input type="hidden" name="id" id="modalQId" value="">
                                <c:if test="${not empty course}">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                </c:if>

                                <div class="modal-header saas-modal-header">
                                    <h5 class="modal-title fw-bold text-dark d-flex align-items-center gap-2" id="questionModalLabel">
                                        <span id="questionModalIcon" class="text-success"><i class="bi bi-database-add"></i></span>
                                        <span id="questionModalTitle">Tạo câu hỏi mới vào Ngân hàng</span>
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>

                                <div class="modal-body p-4">
                                    <div class="mb-3">
                                        <label class="saas-form-label">Thuộc chương học
                                            <span class="text-danger">*</span></label>
                                        <select name="moduleId" id="modalQModuleSelect" class="form-select saas-form-control"
                                            required>
                                            <c:forEach var="m" items="${course.modules}">
                                                <option value="${m.id}">${m.displayTitle}</option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label class="saas-form-label">Nội dung câu hỏi
                                            <span class="text-danger">*</span></label>
                                        <textarea name="questionText" id="modalQText" rows="3"
                                            class="form-control saas-form-control" required
                                            placeholder="Nhập nội dung câu hỏi trắc nghiệm ở đây..."></textarea>
                                    </div>

                                    <div class="row g-3 mb-3">
                                        <div class="col-md-6">
                                            <label class="saas-form-label">Loại câu hỏi</label>
                                            <select name="questionType" id="modalQType" class="form-select saas-form-control"
                                                onchange="handleModalQTypeChange(this.value)">
                                                <option value="SINGLE_CHOICE" selected>Trắc nghiệm 1 đáp án</option>
                                                <option value="TRUE_FALSE">Đúng / Sai</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="saas-form-label">Điểm mặc định
                                                <span class="text-danger">*</span></label>
                                            <div class="input-group">
                                                <input type="number" step="0.5" min="0.5" name="defaultPoints"
                                                    id="modalQPoints" value="1.0" class="form-control saas-form-control rounded-start-3"
                                                    required>
                                                <span class="input-group-text bg-light text-muted">điểm</span>
                                            </div>
                                        </div>
                                    </div>

                                    <label class="saas-form-label text-primary mb-2 d-flex align-items-center gap-1">
                                        <i class="bi bi-ui-radios"></i>
                                        <span>Các phương án trả lời (Tích chọn radio vào đáp án đúng):</span>
                                    </label>

                                    <div id="modalQOptionsContainer">
                                        <div class="mb-2 input-group shadow-sm rounded-3 overflow-hidden"
                                            id="modalQOptGroupA">
                                            <div class="input-group-text bg-white border-end-0">
                                                <input class="form-check-input mt-0" type="radio" name="correctOption"
                                                    value="0" checked title="Chọn làm đáp án đúng">
                                            </div>
                                            <span
                                                class="input-group-text bg-light fw-bold text-secondary border-start-0 border-end-0"
                                                style="min-width: 40px; justify-content: center;">A</span>
                                            <input type="text" name="optionText" id="modalQOptA"
                                                class="form-control border-start-0" placeholder="Đáp án A..." required>
                                        </div>

                                        <div class="mb-2 input-group shadow-sm rounded-3 overflow-hidden"
                                            id="modalQOptGroupB">
                                            <div class="input-group-text bg-white border-end-0">
                                                <input class="form-check-input mt-0" type="radio" name="correctOption"
                                                    value="1" title="Chọn làm đáp án đúng">
                                            </div>
                                            <span
                                                class="input-group-text bg-light fw-bold text-secondary border-start-0 border-end-0"
                                                style="min-width: 40px; justify-content: center;">B</span>
                                            <input type="text" name="optionText" id="modalQOptB"
                                                class="form-control border-start-0" placeholder="Đáp án B..." required>
                                        </div>

                                        <div class="mb-2 input-group shadow-sm rounded-3 overflow-hidden"
                                            id="modalQOptGroupC">
                                            <div class="input-group-text bg-white border-end-0">
                                                <input class="form-check-input mt-0" type="radio" name="correctOption"
                                                    value="2" title="Chọn làm đáp án đúng">
                                            </div>
                                            <span
                                                class="input-group-text bg-light fw-bold text-secondary border-start-0 border-end-0"
                                                style="min-width: 40px; justify-content: center;">C</span>
                                            <input type="text" name="optionText" id="modalQOptC"
                                                class="form-control border-start-0"
                                                placeholder="Đáp án C (tùy chọn)...">
                                        </div>

                                        <div class="mb-3 input-group shadow-sm rounded-3 overflow-hidden"
                                            id="modalQOptGroupD">
                                            <div class="input-group-text bg-white border-end-0">
                                                <input class="form-check-input mt-0" type="radio" name="correctOption"
                                                    value="3" title="Chọn làm đáp án đúng">
                                            </div>
                                            <span
                                                class="input-group-text bg-light fw-bold text-secondary border-start-0 border-end-0"
                                                style="min-width: 40px; justify-content: center;">D</span>
                                            <input type="text" name="optionText" id="modalQOptD"
                                                class="form-control border-start-0"
                                                placeholder="Đáp án D (tùy chọn)...">
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-footer saas-modal-footer">
                                    <button type="button" class="btn-saas-outline"
                                        data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" id="questionModalSubmitBtn"
                                        class="btn-saas-outline-emerald">
                                        <i class="bi bi-save me-1"></i><span id="questionModalSubmitText">Lưu vào ngân hàng</span>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <script>
                    // 1. Toggling functions cho Accordion ở cả 2 Tab (Dạng text thuần túy, không viền, không box)
                    function toggleAllQuizSections() {
                        const container = document.getElementById('quizCurriculumContainer');
                        if (!container) return;
                        const collapses = container.querySelectorAll('.collapse');
                        const btn = document.getElementById('toggleAllQuizBtn');
                        let anyOpen = false;
                        collapses.forEach(c => {
                            if (c.classList.contains('show')) anyOpen = true;
                        });

                        collapses.forEach(c => {
                            const bsCollapse = bootstrap.Collapse.getOrCreateInstance(c, { toggle: false });
                            if (anyOpen) {
                                bsCollapse.hide();
                            } else {
                                bsCollapse.show();
                            }
                        });

                        if (btn) {
                            if (anyOpen) {
                                btn.innerHTML = '<i class="bi bi-arrows-expand me-1"></i><span>Mở rộng tất cả</span>';
                            } else {
                                btn.innerHTML = '<i class="bi bi-arrows-collapse me-1"></i><span>Thu gọn tất cả</span>';
                            }
                        }
                    }

                    function toggleAllQuestionSections() {
                        const container = document.getElementById('questionCurriculumContainer');
                        if (!container) return;
                        const collapses = container.querySelectorAll('.collapse');
                        const btn = document.getElementById('toggleAllQuestionBtn');
                        let anyOpen = false;
                        collapses.forEach(c => {
                            if (c.classList.contains('show')) anyOpen = true;
                        });

                        collapses.forEach(c => {
                            const bsCollapse = bootstrap.Collapse.getOrCreateInstance(c, { toggle: false });
                            if (anyOpen) {
                                bsCollapse.hide();
                            } else {
                                bsCollapse.show();
                            }
                        });

                        if (btn) {
                            if (anyOpen) {
                                btn.innerHTML = '<i class="bi bi-arrows-expand me-1"></i><span>Mở rộng tất cả</span>';
                            } else {
                                btn.innerHTML = '<i class="bi bi-arrows-collapse me-1"></i><span>Thu gọn tất cả</span>';
                            }
                        }
                    }

                    document.addEventListener('DOMContentLoaded', function () {
                        // Kích hoạt tab nếu có query param ?tab=questions
                        const urlParams = new URLSearchParams(window.location.search);
                        if (urlParams.get('tab') === 'questions') {
                            const questionsTabBtn = document.getElementById('pills-questions-tab');
                            if (questionsTabBtn) {
                                bootstrap.Tab.getOrCreateInstance(questionsTabBtn).show();
                            }
                        }

                        // Tự động đồng bộ trạng thái text nút Toggle và header khi mở/đóng từng chương
                        const quizContainer = document.getElementById('quizCurriculumContainer');
                        if (quizContainer) {
                            quizContainer.addEventListener('show.bs.collapse', function (e) {
                                const item = e.target.closest('.udemy-section-item');
                                if (item) {
                                    const header = item.querySelector('.udemy-section-header');
                                    if (header) header.classList.remove('collapsed');
                                    const toggle = item.querySelector('.udemy-header-toggle');
                                    if (toggle) toggle.classList.remove('collapsed');
                                }
                            });
                            quizContainer.addEventListener('hide.bs.collapse', function (e) {
                                const item = e.target.closest('.udemy-section-item');
                                if (item) {
                                    const header = item.querySelector('.udemy-section-header');
                                    if (header) header.classList.add('collapsed');
                                    const toggle = item.querySelector('.udemy-header-toggle');
                                    if (toggle) toggle.classList.add('collapsed');
                                }
                            });
                            quizContainer.addEventListener('shown.bs.collapse', syncQuizToggleBtn);
                            quizContainer.addEventListener('hidden.bs.collapse', syncQuizToggleBtn);
                        }
                        function syncQuizToggleBtn() {
                            const btn = document.getElementById('toggleAllQuizBtn');
                            if (!btn || !quizContainer) return;
                            const anyOpen = Array.from(quizContainer.querySelectorAll('.collapse')).some(c => c.classList.contains('show'));
                            btn.innerHTML = anyOpen
                                ? '<i class="bi bi-arrows-collapse me-1"></i><span>Thu gọn tất cả</span>'
                                : '<i class="bi bi-arrows-expand me-1"></i><span>Mở rộng tất cả</span>';
                        }

                        const qContainer = document.getElementById('questionCurriculumContainer');
                        if (qContainer) {
                            qContainer.addEventListener('show.bs.collapse', function (e) {
                                const item = e.target.closest('.udemy-section-item');
                                if (item) {
                                    const header = item.querySelector('.udemy-section-header');
                                    if (header) header.classList.remove('collapsed');
                                    const toggle = item.querySelector('.udemy-header-toggle');
                                    if (toggle) toggle.classList.remove('collapsed');
                                }
                            });
                            qContainer.addEventListener('hide.bs.collapse', function (e) {
                                const item = e.target.closest('.udemy-section-item');
                                if (item) {
                                    const header = item.querySelector('.udemy-section-header');
                                    if (header) header.classList.add('collapsed');
                                    const toggle = item.querySelector('.udemy-header-toggle');
                                    if (toggle) toggle.classList.add('collapsed');
                                }
                            });
                            qContainer.addEventListener('shown.bs.collapse', syncQuestionToggleBtn);
                            qContainer.addEventListener('hidden.bs.collapse', syncQuestionToggleBtn);
                        }
                        function syncQuestionToggleBtn() {
                            const btn = document.getElementById('toggleAllQuestionBtn');
                            if (!btn || !qContainer) return;
                            const anyOpen = Array.from(qContainer.querySelectorAll('.collapse')).some(c => c.classList.contains('show'));
                            btn.innerHTML = anyOpen
                                ? '<i class="bi bi-arrows-collapse me-1"></i><span>Thu gọn tất cả</span>'
                                : '<i class="bi bi-arrows-expand me-1"></i><span>Mở rộng tất cả</span>';
                        }

                        // 2. Tab 1: Live search & Module filter (All vs Has-Quiz)
                        const quizSearch = document.getElementById('quizSearchInput');
                        const clearQuizBtn = document.getElementById('clearQuizSearchBtn');
                        const moduleFilterBtns = document.querySelectorAll('.module-filter-btn');
                        let currentModuleFilter = 'all';

                        function applyQuizTabFilter() {
                            const kw = quizSearch ? quizSearch.value.trim().toLowerCase() : '';
                            if (clearQuizBtn) {
                                clearQuizBtn.classList.toggle('d-none', kw === '');
                            }
                            const moduleSections = document.querySelectorAll('#quizCurriculumContainer .udemy-section-item');
                            let anyVisible = false;

                            moduleSections.forEach(function (sec) {
                                const hasQuizzes = sec.getAttribute('data-has-quizzes') === 'true';
                                const moduleTitle = sec.getAttribute('data-module-title') || '';

                                if (currentModuleFilter === 'has-quiz' && !hasQuizzes) {
                                    sec.classList.add('d-none');
                                    return;
                                }

                                if (kw === '') {
                                    sec.classList.remove('d-none');
                                    sec.querySelectorAll('.quiz-row').forEach(r => r.classList.remove('d-none'));
                                    anyVisible = true;
                                } else {
                                    let matchInQuizzes = false;
                                    const rows = sec.querySelectorAll('.quiz-row');
                                    rows.forEach(function (row) {
                                        const title = row.getAttribute('data-quiz-title') || '';
                                        if (title.includes(kw)) {
                                            row.classList.remove('d-none');
                                            matchInQuizzes = true;
                                        } else {
                                            row.classList.add('d-none');
                                        }
                                    });

                                    if (matchInQuizzes || moduleTitle.includes(kw)) {
                                        sec.classList.remove('d-none');
                                        if (moduleTitle.includes(kw)) {
                                            rows.forEach(r => r.classList.remove('d-none'));
                                        }
                                        // Tự động mở rộng section khi có kết quả tìm kiếm
                                        const collapseEl = sec.querySelector('.collapse');
                                        if (collapseEl && !collapseEl.classList.contains('show')) {
                                            bootstrap.Collapse.getOrCreateInstance(collapseEl, { toggle: false }).show();
                                        }
                                        anyVisible = true;
                                    } else {
                                        sec.classList.add('d-none');
                                    }
                                }
                            });

                            const noResultEl = document.getElementById('quizTabNoResult');
                            if (noResultEl) {
                                noResultEl.classList.toggle('d-none', anyVisible);
                            }
                        }

                        if (quizSearch) {
                            quizSearch.addEventListener('input', applyQuizTabFilter);
                        }
                        if (clearQuizBtn) {
                            clearQuizBtn.addEventListener('click', function () {
                                quizSearch.value = '';
                                applyQuizTabFilter();
                                quizSearch.focus();
                            });
                        }
                        moduleFilterBtns.forEach(function (btn) {
                            btn.addEventListener('click', function () {
                                moduleFilterBtns.forEach(b => b.classList.remove('active'));
                                this.classList.add('active');
                                currentModuleFilter = this.getAttribute('data-filter');
                                applyQuizTabFilter();
                            });
                        });

                        // 3. Tab 2: Live search, Module filter & Question Type filter
                        const qSearch = document.getElementById('questionSearchInput');
                        const clearQSearchBtn = document.getElementById('clearQuestionSearchBtn');
                        const qModFilter = document.getElementById('questionModuleFilter');
                        const qTypeFilter = document.getElementById('questionTypeFilter');
                        const qVisibleCountEl = document.getElementById('questionVisibleCount');
                        const qEmptyFilterEl = document.getElementById('questionEmptyFilter');

                        function filterQuestions() {
                            const kw = qSearch ? qSearch.value.trim().toLowerCase() : '';
                            if (clearQSearchBtn) {
                                clearQSearchBtn.classList.toggle('d-none', kw === '');
                            }
                            const modId = qModFilter ? qModFilter.value : 'all';
                            const type = qTypeFilter ? qTypeFilter.value : 'all';

                            const moduleSections = document.querySelectorAll('#questionCurriculumContainer .question-module-section');
                            let totalVisibleQuestions = 0;
                            let anySectionVisible = false;

                            moduleSections.forEach(function (sec) {
                                const secModId = sec.getAttribute('data-module-id') || '';
                                const secTitle = sec.getAttribute('data-module-title') || '';

                                // Lọc theo chương nếu chọn trong dropdown
                                if (modId !== 'all' && modId !== secModId) {
                                    sec.classList.add('d-none');
                                    return;
                                }

                                const rows = sec.querySelectorAll('.question-row');
                                let secVisibleQuestions = 0;

                                rows.forEach(function (row) {
                                    const rowText = row.getAttribute('data-text') || '';
                                    const rowType = row.getAttribute('data-type') || '';

                                    const matchKw = (kw === '' || rowText.includes(kw) || secTitle.includes(kw));
                                    const matchType = (type === 'all' || type === rowType);
                                    const visible = matchKw && matchType;

                                    row.classList.toggle('d-none', !visible);
                                    if (visible) {
                                        secVisibleQuestions++;
                                        totalVisibleQuestions++;
                                    }
                                });

                                if (kw === '' && type === 'all') {
                                    sec.classList.remove('d-none');
                                    anySectionVisible = true;
                                } else {
                                    if (secVisibleQuestions > 0) {
                                        sec.classList.remove('d-none');
                                        anySectionVisible = true;
                                        const collapseEl = sec.querySelector('.collapse');
                                        if (collapseEl && !collapseEl.classList.contains('show')) {
                                            bootstrap.Collapse.getOrCreateInstance(collapseEl, { toggle: false }).show();
                                        }
                                    } else {
                                        sec.classList.add('d-none');
                                    }
                                }
                            });

                            if (qVisibleCountEl) qVisibleCountEl.textContent = totalVisibleQuestions;
                            if (qEmptyFilterEl && qContainer) {
                                if (!anySectionVisible) {
                                    qEmptyFilterEl.classList.remove('d-none');
                                    qContainer.classList.add('d-none');
                                } else {
                                    qEmptyFilterEl.classList.add('d-none');
                                    qContainer.classList.remove('d-none');
                                }
                            }
                        }

                        if (qSearch) qSearch.addEventListener('input', filterQuestions);
                        if (clearQSearchBtn) {
                            clearQSearchBtn.addEventListener('click', function () {
                                qSearch.value = '';
                                filterQuestions();
                                qSearch.focus();
                            });
                        }
                        if (qModFilter) qModFilter.addEventListener('change', filterQuestions);
                        if (qTypeFilter) qTypeFilter.addEventListener('change', filterQuestions);
                    });

                    // 4. Xử lý đổi dạng câu hỏi modal tạo câu hỏi
                    function handleModalQTypeChange(type) {
                        const optC = document.getElementById('modalQOptGroupC');
                        const optD = document.getElementById('modalQOptGroupD');
                        const textA = document.getElementById('modalQOptA');
                        const textB = document.getElementById('modalQOptB');

                        if (type === 'TRUE_FALSE') {
                            if (optC) optC.style.display = 'none';
                            if (optD) optD.style.display = 'none';
                            if (textA) textA.value = 'Đúng (True)';
                            if (textB) textB.value = 'Sai (False)';
                        } else {
                            if (optC) optC.style.display = 'flex';
                            if (optD) optD.style.display = 'flex';
                            if (textA && textA.value === 'Đúng (True)') textA.value = '';
                            if (textB && textB.value === 'Sai (False)') textB.value = '';
                        }
                    }

                    // 5. Modal Quản lý Quiz
                    function openCreateQuizModal(moduleId, suggestedOrder) {
                        const idInput = document.getElementById('modalQuizId');
                        if (idInput) idInput.value = '';
                        const titleLabel = document.getElementById('quizModalLabel');
                        if (titleLabel) titleLabel.innerHTML = '<span class="text-orange"><i class="bi bi-patch-question"></i></span> Tạo bài kiểm tra mới (Quiz)';
                        const titleInput = document.getElementById('modalQuizTitle');
                        if (titleInput) titleInput.value = '';
                        const passScoreInput = document.getElementById('modalQuizPassScore');
                        if (passScoreInput) passScoreInput.value = '50';
                        const timeLimitInput = document.getElementById('modalQuizTimeLimit');
                        if (timeLimitInput) timeLimitInput.value = '15';
                        const orderInput = document.getElementById('modalQuizOrderIndex');
                        if (orderInput) orderInput.value = (suggestedOrder && suggestedOrder > 0) ? suggestedOrder : '1';
                        // Cập nhật hint text STT
                        const orderHint = document.getElementById('modalQuizOrderHint');
                        if (orderHint && suggestedOrder && suggestedOrder > 0) {
                            orderHint.textContent = 'Gợi ý: STT ' + suggestedOrder + ' chưa được dùng trong chương này.';
                            orderHint.className = 'form-text small text-success';
                        } else if (orderHint) {
                            orderHint.textContent = 'Số thứ tự phải không trùng với bài Quiz khác trong cùng chương.';
                            orderHint.className = 'form-text small text-muted';
                        }
                        if (moduleId) {
                            const modSelect = document.getElementById('modalModuleSelect');
                            if (modSelect) modSelect.value = moduleId;
                        }
                        const modalEl = document.getElementById('quizModal');
                        if (modalEl) {
                            bootstrap.Modal.getOrCreateInstance(modalEl).show();
                        }
                    }

                    function openEditQuizModal(id, moduleId, title, passScore, timeLimit, orderIndex) {
                        const idInput = document.getElementById('modalQuizId');
                        if (idInput) idInput.value = id;
                        const titleLabel = document.getElementById('quizModalLabel');
                        if (titleLabel) titleLabel.innerHTML = '<span class="text-orange"><i class="bi bi-gear-fill"></i></span> Cập nhật bài kiểm tra #' + id;
                        const titleInput = document.getElementById('modalQuizTitle');
                        if (titleInput) titleInput.value = title || '';
                        const passScoreInput = document.getElementById('modalQuizPassScore');
                        if (passScoreInput) passScoreInput.value = passScore || '50';
                        const timeLimitInput = document.getElementById('modalQuizTimeLimit');
                        if (timeLimitInput) timeLimitInput.value = timeLimit || '';
                        const orderInput = document.getElementById('modalQuizOrderIndex');
                        if (orderInput) orderInput.value = orderIndex || '1';
                        // Reset hint STT về mặc định khi edit
                        const orderHint = document.getElementById('modalQuizOrderHint');
                        if (orderHint) {
                            orderHint.textContent = 'Thứ tự hiện tại: ' + (orderIndex || 1) + '. Chỉ thay đổi nếu cần sắp xếp lại, tránh trùng với bài Quiz khác.';
                            orderHint.className = 'form-text small text-muted';
                        }
                        if (moduleId) {
                            const modSelect = document.getElementById('modalModuleSelect');
                            if (modSelect) modSelect.value = moduleId;
                        }
                        const modalEl = document.getElementById('quizModal');
                        if (modalEl) {
                            bootstrap.Modal.getOrCreateInstance(modalEl).show();
                        }
                    }

                    function openDeleteQuizModal(id, title, courseId, moduleId) {
                        const titleEl = document.getElementById('deleteQuizTitle');
                        if (titleEl) titleEl.textContent = 'Bạn có chắc chắn muốn xóa bài thi "' + title + '"?';
                        let deleteUrl = '${pageContext.request.contextPath}/quizzes/delete?id=' + id;
                        if (courseId) deleteUrl += '&courseId=' + courseId;
                        if (moduleId) deleteUrl += '&moduleId=' + moduleId;
                        const link = document.getElementById('confirmDeleteLink');
                        if (link) link.href = deleteUrl;
                        const modalEl = document.getElementById('deleteQuizModal');
                        if (modalEl) {
                            bootstrap.Modal.getOrCreateInstance(modalEl).show();
                        }
                    }

                    function openCreateQuestionModal(moduleId) {
                        // Reset về chế độ tạo mới
                        const qId = document.getElementById('modalQId');
                        if (qId) qId.value = '';
                        const qText = document.getElementById('modalQText');
                        if (qText) qText.value = '';
                        const qPoints = document.getElementById('modalQPoints');
                        if (qPoints) qPoints.value = '1.0';
                        if (moduleId) {
                            const modSelect = document.getElementById('modalQModuleSelect');
                            if (modSelect) modSelect.value = moduleId;
                        }
                        // Reset options về trống
                        ['modalQOptA','modalQOptB','modalQOptC','modalQOptD'].forEach(id => {
                            const el = document.getElementById(id);
                            if (el) el.value = '';
                        });
                        // Reset radio về đáp án A
                        const firstRadio = document.querySelector('#bankQuestionForm input[name="correctOption"][value="0"]');
                        if (firstRadio) firstRadio.checked = true;
                        // Reset header & button
                        const icon = document.getElementById('questionModalIcon');
                        if (icon) icon.innerHTML = '<i class="bi bi-database-add"></i>';
                        if (icon) icon.className = 'text-success';
                        const title = document.getElementById('questionModalTitle');
                        if (title) title.textContent = 'Tạo câu hỏi mới vào Ngân hàng';
                        const submitBtn = document.getElementById('questionModalSubmitBtn');
                        if (submitBtn) submitBtn.className = 'btn btn-success btn-sm fw-semibold rounded-3 px-3 shadow-sm';
                        const submitText = document.getElementById('questionModalSubmitText');
                        if (submitText) submitText.textContent = 'Lưu vào ngân hàng';
                        // Reset type
                        const qType = document.getElementById('modalQType');
                        if (qType) qType.value = 'SINGLE_CHOICE';
                        handleModalQTypeChange('SINGLE_CHOICE');
                        const modalEl = document.getElementById('questionModal');
                        if (modalEl) {
                            bootstrap.Modal.getOrCreateInstance(modalEl).show();
                        }
                    }

                    function openEditQuestionModal(btn) {
                        const tr = btn.closest('tr.question-row');
                        if (!tr) return;

                        const qId      = tr.getAttribute('data-q-id');
                        const qText    = tr.getAttribute('data-q-text');
                        const qPoints  = tr.getAttribute('data-q-points');
                        const qType    = tr.getAttribute('data-type');
                        const moduleId = tr.getAttribute('data-module-id');

                        // Điền id, text, points, type, module
                        document.getElementById('modalQId').value = qId;
                        document.getElementById('modalQText').value = qText;
                        document.getElementById('modalQPoints').value = qPoints;
                        const typeEl = document.getElementById('modalQType');
                        if (typeEl) typeEl.value = qType;
                        const modSel = document.getElementById('modalQModuleSelect');
                        if (modSel && moduleId) modSel.value = moduleId;

                        // Điền options A/B/C/D from DOM
                        const optItems = tr.querySelectorAll('.q-opt-item');
                        const optIds   = ['modalQOptA', 'modalQOptB', 'modalQOptC', 'modalQOptD'];
                        const radios   = document.querySelectorAll('#bankQuestionForm input[name="correctOption"]');
                        optIds.forEach((id, i) => {
                            const el = document.getElementById(id);
                            if (!el) return;
                            const optItem = optItems[i];
                            el.value = optItem ? (optItem.getAttribute('data-text') || '') : '';
                            const isCorrect = optItem ? (optItem.getAttribute('data-correct') === 'true') : (i === 0);
                            if (radios[i]) radios[i].checked = isCorrect;
                        });

                        // Áp dụng hiển thị theo loại câu hỏi
                        handleModalQTypeChange(qType);

                        // Đổi header & nút submit sang Edit mode
                        const icon = document.getElementById('questionModalIcon');
                        if (icon) { icon.innerHTML = '<i class="bi bi-pencil-square"></i>'; icon.className = 'text-primary'; }
                        const titleEl = document.getElementById('questionModalTitle');
                        if (titleEl) titleEl.textContent = 'Chỉnh sửa câu hỏi #' + qId;
                        const submitBtn = document.getElementById('questionModalSubmitBtn');
                        if (submitBtn) submitBtn.className = 'btn btn-primary btn-sm fw-semibold rounded-3 px-3 shadow-sm';
                        const submitText = document.getElementById('questionModalSubmitText');
                        if (submitText) submitText.textContent = 'Lưu thay đổi';

                        // Hiện modal
                        const modalEl = document.getElementById('questionModal');
                        if (modalEl) bootstrap.Modal.getOrCreateInstance(modalEl).show();
                    }
                </script>

                <jsp:include page="../common/footer.jsp" />

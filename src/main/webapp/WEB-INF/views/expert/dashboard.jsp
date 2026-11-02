<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Expert Studio - Courson LMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<style>
/* ==========================================================================
   MODERN SAAS DESIGN SYSTEM (Linear / Vercel / shadcn inspired)
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
    gap: 8px;
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

/* Course Main Card & Toolbar */
.saas-card {
    background: var(--saas-card-bg);
    border: 1px solid var(--saas-border);
    border-radius: var(--saas-radius-lg);
    box-shadow: var(--saas-shadow-sm);
    overflow: hidden;
}
.saas-toolbar {
    padding: 16px 20px;
    border-bottom: 1px solid var(--saas-border);
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    background: #ffffff;
}

/* Segmented Filter Tabs */
.saas-tabs {
    display: inline-flex;
    align-items: center;
    background: #f1f5f9;
    padding: 3px;
    border-radius: 8px;
    gap: 2px;
}
.saas-tab-btn {
    border: none;
    background: transparent;
    padding: 6px 14px;
    font-size: 0.8125rem;
    font-weight: 500;
    color: var(--saas-text-muted);
    border-radius: 6px;
    transition: all 0.15s ease;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}
.saas-tab-btn:hover {
    color: var(--saas-text-heading);
}
.saas-tab-btn.active {
    background: #ffffff;
    color: var(--saas-text-heading);
    font-weight: 600;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
}
.saas-tab-badge {
    background: #e2e8f0;
    color: #475569;
    font-size: 11px;
    font-weight: 600;
    padding: 1px 6px;
    border-radius: 9999px;
}
.saas-tab-btn.active .saas-tab-badge {
    background: #f1f5f9;
    color: #0f172a;
}

/* Search Box */
.saas-search-box {
    position: relative;
    min-width: 260px;
}
.saas-search-icon {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
    pointer-events: none;
    font-size: 0.875rem;
}
.saas-search-input {
    width: 100%;
    padding: 7px 12px 7px 34px;
    font-size: 0.875rem;
    border-radius: 8px;
    border: 1px solid var(--saas-border);
    background: #f8fafc;
    color: var(--saas-text-heading);
    transition: all 0.15s ease;
}
.saas-search-input:focus {
    outline: none;
    background: #ffffff;
    border-color: var(--saas-accent);
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
}

/* SaaS Table */
.saas-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
}
.saas-table th {
    background: #f8fafc;
    padding: 12px 16px;
    font-size: 0.775rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #64748b;
    border-bottom: 1px solid var(--saas-border);
    white-space: nowrap;
}
.saas-table td {
    padding: 16px 16px;
    border-bottom: 1px solid var(--saas-border-subtle);
    vertical-align: middle;
    background: #ffffff;
    transition: background-color 0.15s ease;
}
.saas-table tr:hover td {
    background-color: #f8fafc;
}
.saas-table tr:last-child td {
    border-bottom: none;
}

@media (min-width: 992px) {
    .table-responsive {
        overflow-x: visible !important;
    }
}

/* Course Identity Column */
.course-info-wrap {
    display: flex;
    align-items: center;
    gap: 16px;
    min-width: 0;
}
.course-thumb-box {
    width: 96px;
    height: 60px;
    border-radius: 8px;
    overflow: hidden;
    flex-shrink: 0;
    background: #0f172a;
    border: 1px solid #e2e8f0;
    position: relative;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
}
.course-thumb-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.2s ease;
}
.course-info-wrap:hover .course-thumb-img {
    transform: scale(1.05);
}
.course-title-text {
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--saas-text-heading);
    text-decoration: none;
    line-height: 1.4;
    display: block;
    word-break: break-word;
    transition: color 0.15s ease;
}
.course-title-text:hover {
    color: var(--saas-accent);
}
.course-meta-sub {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 4px;
    font-size: 0.8125rem;
    color: var(--saas-text-muted);
}

/* Modern Status Badges (shadcn inspired) */
.saas-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 5px 12px;
    border-radius: 9999px;
    font-size: 0.8rem;
    font-weight: 600;
    letter-spacing: 0.02em;
    white-space: nowrap;
}
.badge-dot {
    width: 7px;
    height: 7px;
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

.saas-badge-archived {
    background: #f8fafc;
    color: #64748b;
    border: 1px solid #e2e8f0;
}
.saas-badge-archived .badge-dot { background: #94a3b8; }

/* Category & Info Pills */
.pill-neutral {
    background: #f1f5f9;
    color: #334155;
    border: 1px solid #e2e8f0;
    font-size: 0.8rem;
    font-weight: 500;
    padding: 3px 9px;
    border-radius: 6px;
    display: inline-block;
}
.pill-quiz {
    background: #fefce8;
    color: #854d0e;
    border: 1px solid #fef08a;
    font-size: 0.75rem;
    font-weight: 500;
    padding: 2px 7px;
    border-radius: 6px;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}
.pill-quiz.empty {
    background: #f8fafc;
    color: #94a3b8;
    border: 1px solid #e2e8f0;
}

/* Action Dropdown & Buttons */
.btn-saas-primary {
    background: #0f172a;
    color: #ffffff;
    border: 1px solid #0f172a;
    font-weight: 600;
    font-size: 0.8125rem;
    padding: 6px 14px;
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

.btn-saas-outline-emerald {
    background: #ffffff;
    color: #059669;
    border: 1px solid #a7f3d0;
    font-weight: 600;
    font-size: 0.8125rem;
    padding: 6px 12px;
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
    padding: 6px 12px;
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
    width: 36px;
    height: 36px;
    border-radius: 8px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border: 1px solid var(--saas-border);
    background: #ffffff;
    color: #64748b;
    transition: all 0.15s ease;
    cursor: pointer;
    font-size: 0.95rem;
}
.btn-icon-action:hover {
    background: #f1f5f9;
    color: #0f172a;
    border-color: #cbd5e1;
}

@media (max-width: 768px) {
    .saas-toolbar {
        flex-direction: column;
        align-items: stretch;
    }
    .saas-tabs {
        width: 100%;
        overflow-x: auto;
        white-space: nowrap;
        justify-content: flex-start;
    }
    .saas-search-box {
        width: 100%;
        min-width: unset;
    }
}

/* Dropdown Menu (shadcn style) */
.saas-dropdown-menu {
    border: 1px solid var(--saas-border);
    border-radius: 10px;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.08), 0 4px 6px -4px rgba(0, 0, 0, 0.04);
    padding: 6px;
    min-width: 190px;
    border: 1px solid #e2e8f0;
}
.saas-dropdown-item {
    font-size: 0.8125rem;
    font-weight: 500;
    color: #334155;
    padding: 8px 12px;
    border-radius: 6px;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.12s ease;
    text-decoration: none;
}
.saas-dropdown-item:hover {
    background: #f1f5f9;
    color: #0f172a;
}
.saas-dropdown-item.text-danger {
    color: #dc2626 !important;
}
.saas-dropdown-item.text-danger:hover {
    background: #fef2f2 !important;
    color: #b91c1c !important;
}

/* Modals */
.modal-content.saas-modal {
    border-radius: 16px;
    border: 1px solid var(--saas-border);
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
    overflow: visible !important;
}
.modal-header.saas-modal-header {
    background: #ffffff;
    border-bottom: 1px solid var(--saas-border);
    padding: 20px 24px;
    border-top-left-radius: 16px;
    border-top-right-radius: 16px;
}
.modal-footer.saas-modal-footer {
    background: #f8fafc;
    border-top: 1px solid var(--saas-border);
    padding: 16px 24px;
    border-bottom-left-radius: 16px;
    border-bottom-right-radius: 16px;
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

/* Modern SaaS Searchable Select (Combobox) */
.saas-combobox {
    position: relative;
    width: 100%;
}
.saas-combobox-trigger {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #ffffff;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    padding: 9px 12px;
    font-size: 0.875rem;
    color: var(--saas-text-heading);
    cursor: pointer;
    transition: all 0.15s ease;
    text-align: left;
    user-select: none;
}
.saas-combobox-trigger:hover {
    background: #f8fafc;
    border-color: #94a3b8;
}
.saas-combobox.open .saas-combobox-trigger,
.saas-combobox-trigger:focus {
    outline: none;
    background: #ffffff;
    border-color: var(--saas-accent);
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
}
.saas-combobox-label {
    display: flex;
    align-items: center;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    padding-right: 8px;
    font-weight: 500;
}
.saas-combobox-arrow {
    font-size: 0.75rem;
    color: #64748b;
    transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    flex-shrink: 0;
}
.saas-combobox.open .saas-combobox-arrow {
    transform: rotate(180deg);
    color: var(--saas-accent);
}
.saas-combobox-dropdown {
    position: absolute;
    top: calc(100% + 6px);
    left: 0;
    right: 0;
    background: #ffffff;
    border: 1px solid var(--saas-border);
    border-radius: 12px;
    box-shadow: 0 14px 34px -4px rgba(15, 23, 42, 0.16), 0 6px 12px -2px rgba(15, 23, 42, 0.08);
    z-index: 1065;
    display: none;
    overflow: hidden;
}
.saas-combobox.open .saas-combobox-dropdown {
    display: block;
    animation: saasComboboxFade 0.15s cubic-bezier(0.16, 1, 0.3, 1);
}
@keyframes saasComboboxFade {
    from {
        opacity: 0;
        transform: translateY(-6px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}
.saas-combobox-search-wrap {
    position: relative;
    padding: 10px;
    background: #f8fafc;
    border-bottom: 1px solid var(--saas-border-subtle);
}
.saas-combobox-search {
    width: 100%;
    border: 1px solid #e2e8f0;
    border-radius: 6px;
    padding: 7px 30px 7px 32px;
    font-size: 0.8125rem;
    background: #ffffff;
    outline: none;
    color: var(--saas-text-heading);
    transition: all 0.15s ease;
}
.saas-combobox-search:focus {
    border-color: var(--saas-accent);
    box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
}
.saas-combobox-search-icon {
    position: absolute;
    left: 20px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 0.8rem;
    color: #94a3b8;
    pointer-events: none;
}
.saas-combobox-search-clear {
    position: absolute;
    right: 18px;
    top: 50%;
    transform: translateY(-50%);
    border: none;
    background: transparent;
    color: #94a3b8;
    cursor: pointer;
    padding: 0;
    font-size: 0.85rem;
    display: flex;
    align-items: center;
}
.saas-combobox-search-clear:hover {
    color: #475569;
}
.saas-combobox-list {
    max-height: 220px;
    overflow-y: auto;
    padding: 6px;
}
.saas-combobox-list::-webkit-scrollbar {
    width: 5px;
}
.saas-combobox-list::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 10px;
}
.saas-combobox-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 12px;
    border-radius: 6px;
    font-size: 0.84rem;
    color: #334155;
    cursor: pointer;
    transition: all 0.12s ease;
    user-select: none;
    margin-bottom: 1px;
}
.saas-combobox-item:hover {
    background: #f1f5f9;
    color: #0f172a;
}
.saas-combobox-item.selected {
    background: #eff6ff;
    color: #1d4ed8;
    font-weight: 600;
}
.saas-combobox-item .item-check {
    color: #2563eb;
    font-size: 1rem;
    display: none;
}
.saas-combobox-item.selected .item-check {
    display: inline-block;
}
.saas-combobox-empty {
    padding: 16px 12px;
    text-align: center;
    font-size: 0.8125rem;
    color: #94a3b8;
}
.saas-combobox-footer {
    border-top: 1px solid var(--saas-border-subtle);
    padding: 6px;
    background: #fafbfc;
}
.saas-combobox-footer .add-new-btn {
    width: 100%;
    display: flex;
    align-items: center;
    padding: 8px 12px;
    border-radius: 6px;
    font-size: 0.84rem;
    font-weight: 600;
    color: #2563eb;
    background: transparent;
    border: none;
    cursor: pointer;
    transition: all 0.12s ease;
    text-align: left;
}
.saas-combobox-footer .add-new-btn:hover {
    background: #eff6ff;
    color: #1d4ed8;
}

.saas-youtube-card {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    padding: 16px;
}

/* Alert notifications */
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
</style>

<main class="main-content py-4">
    <div class="container">
        <!-- Top bar -->
        <div class="saas-header">
            <div>
                <h1 class="saas-title">
                    <i class="bi bi-mortarboard-fill text-primary"></i>Expert Studio
                </h1>
                <p class="saas-subtitle">Quản lý và soạn nội dung các khóa học của bạn</p>
            </div>
            <div>
                <button type="button" class="btn btn-saas-primary px-3 py-2" data-bs-toggle="modal" data-bs-target="#newCourseModal">
                    <i class="bi bi-plus-lg"></i>Tạo Khóa học mới
                </button>
            </div>
        </div>

        <!-- Flash alerts -->
        <c:set var="displaySuccess" value="${not empty successMessage ? successMessage : param.success}" />
        <c:if test="${not empty displaySuccess}">
            <div class="saas-alert saas-alert-success alert-dismissible fade show" role="alert">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-check-circle-fill fs-5"></i>
                    <span>
                        <c:choose>
                            <c:when test="${displaySuccess == 'created'}">Tạo khóa học thành công! Hãy bắt đầu soạn bài học cho khóa học này.</c:when>
                            <c:when test="${displaySuccess == 'deleted'}">Đã xóa khóa học thành công!</c:when>
                            <c:otherwise><c:out value="${displaySuccess}" escapeXml="true" /></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:set var="displayError" value="${not empty errorMessage ? errorMessage : param.error}" />
        <c:if test="${not empty displayError}">
            <div class="saas-alert saas-alert-danger alert-dismissible fade show" role="alert">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                    <span><c:out value="${displayError}" escapeXml="true" /></span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Metric summary (Counts calculation) -->
        <c:set var="publishedCount" value="0" />
        <c:set var="pendingCount" value="0" />
        <c:set var="draftCount" value="0" />
        <c:set var="archivedCount" value="0" />
        <c:set var="totalAllQuizzes" value="0" />
        <c:forEach var="c" items="${courses}">
            <c:choose>
                <c:when test="${c.status == 'PUBLISHED'}">
                    <c:set var="publishedCount" value="${publishedCount + 1}" />
                </c:when>
                <c:when test="${c.status == 'PENDING_REVIEW'}">
                    <c:set var="pendingCount" value="${pendingCount + 1}" />
                </c:when>
                <c:when test="${c.status == 'ARCHIVED'}">
                    <c:set var="archivedCount" value="${archivedCount + 1}" />
                </c:when>
                <c:otherwise>
                    <c:set var="draftCount" value="${draftCount + 1}" />
                </c:otherwise>
            </c:choose>
            <c:set var="totalAllQuizzes" value="${totalAllQuizzes + c.totalQuizzes}" />
        </c:forEach>

        <!-- Modern SaaS Stat Cards (Neutral white cards, clean typography, soft icons) -->
        <div class="row g-3 mb-4">
            <div class="col-12 col-sm-6 col-lg-3">
                <div class="saas-stat-card">
                    <div class="saas-stat-header">
                        <span class="saas-stat-label">Tổng khóa học</span>
                        <div class="saas-stat-icon saas-icon-blue">
                            <i class="bi bi-collection-play"></i>
                        </div>
                    </div>
                    <div>
                        <div class="saas-stat-value">${courses.size()}</div>
                        <div class="saas-stat-desc">
                            <span>Tất cả khóa học của bạn</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <div class="saas-stat-card">
                    <div class="saas-stat-header">
                        <span class="saas-stat-label">Đã công khai</span>
                        <div class="saas-stat-icon saas-icon-emerald">
                            <i class="bi bi-check2-circle"></i>
                        </div>
                    </div>
                    <div>
                        <div class="saas-stat-value">${publishedCount}</div>
                        <div class="saas-stat-desc text-success">
                            <i class="bi bi-broadcast me-1"></i>Học viên đang theo học
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <div class="saas-stat-card">
                    <div class="saas-stat-header">
                        <span class="saas-stat-label">Chờ duyệt</span>
                        <div class="saas-stat-icon saas-icon-amber">
                            <i class="bi bi-hourglass-split"></i>
                        </div>
                    </div>
                    <div>
                        <div class="saas-stat-value">${pendingCount}</div>
                        <div class="saas-stat-desc text-warning">
                            <i class="bi bi-clock-history me-1"></i>Đang chờ Quản lý duyệt
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <div class="saas-stat-card">
                    <div class="saas-stat-header">
                        <span class="saas-stat-label">Bản nháp</span>
                        <div class="saas-stat-icon saas-icon-slate">
                            <i class="bi bi-file-earmark-text"></i>
                        </div>
                    </div>
                    <div>
                        <div class="saas-stat-value">${draftCount}</div>
                        <div class="saas-stat-desc text-muted">
                            <i class="bi bi-lock me-1"></i>Chưa công khai (chỉ bạn thấy)
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Course assigned list Card -->
        <div class="saas-card">
            <!-- Modern Toolbar: Segmented Tabs & Live Search -->
            <div class="saas-toolbar">
                <div class="saas-tabs" id="statusFilterTabs">
                    <button type="button" class="saas-tab-btn active" data-filter="all" onclick="filterCourses('all', this)">
                        Tất cả <span class="saas-tab-badge">${courses.size()}</span>
                    </button>
                    <button type="button" class="saas-tab-btn" data-filter="PUBLISHED" onclick="filterCourses('PUBLISHED', this)">
                        Đã công khai <span class="saas-tab-badge">${publishedCount}</span>
                    </button>
                    <button type="button" class="saas-tab-btn" data-filter="PENDING_REVIEW" onclick="filterCourses('PENDING_REVIEW', this)">
                        Chờ duyệt <span class="saas-tab-badge">${pendingCount}</span>
                    </button>
                    <button type="button" class="saas-tab-btn" data-filter="DRAFT" onclick="filterCourses('DRAFT', this)">
                        Bản nháp <span class="saas-tab-badge">${draftCount}</span>
                    </button>
                    <button type="button" class="saas-tab-btn" data-filter="ARCHIVED" onclick="filterCourses('ARCHIVED', this)">
                        Lưu trữ <span class="saas-tab-badge">${archivedCount}</span>
                    </button>
                </div>

                <div class="saas-search-box">
                    <i class="bi bi-search saas-search-icon"></i>
                    <input type="text" id="courseSearchInput" class="saas-search-input" placeholder="Tìm theo tên khóa học..." oninput="handleCourseSearch()">
                </div>
            </div>

            <!-- Modern SaaS Table -->
            <div class="table-responsive">
                <table class="saas-table align-middle" id="coursesTable">
                    <thead>
                        <tr>
                            <th style="width: 38%;">Khóa học</th>
                            <th style="width: 17%;">Danh mục &amp; Học phí</th>
                            <th style="width: 16%;">Nội dung</th>
                            <th style="width: 14%;">Trạng thái</th>
                            <th style="width: 15%; text-align: right;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty courses}">
                                <tr id="emptyCourseRow">
                                    <td colspan="5" class="text-center py-5">
                                        <div class="py-4">
                                            <div class="saas-stat-icon saas-icon-slate mx-auto mb-3" style="width: 48px; height: 48px; font-size: 1.5rem;">
                                                <i class="bi bi-journal-plus"></i>
                                            </div>
                                            <h6 class="fw-bold text-dark mb-1">Bạn chưa có khóa học nào</h6>
                                            <p class="text-muted small mb-3">Tạo khóa học đầu tiên để bắt đầu xây dựng nội dung.</p>
                                            <button type="button" class="btn btn-saas-primary btn-sm" data-bs-toggle="modal" data-bs-target="#newCourseModal">
                                                <i class="bi bi-plus-lg me-1"></i>Tạo Khóa học mới
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="c" items="${courses}">
                                    <tr class="course-row" id="courseRow-${c.id}" 
                                        data-status="${c.status}" 
                                        data-title="${fn:escapeXml(c.title)}" 
                                        data-category="${fn:escapeXml(c.categoryName != null ? c.categoryName : '')}">
                                        <td>
                                            <div class="course-info-wrap">
                                                <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${c.id}" class="course-thumb-box">
                                                    <img src="${c.thumbnailUrl}" class="course-thumb-img" alt="${c.title}"
                                                         onerror="this.src='https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300'">
                                                </a>
                                                <div class="flex-grow-1 min-w-0">
                                                    <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${c.id}" class="course-title-text" title="${c.title}">
                                                        ${c.title}
                                                    </a>
                                                    <div class="course-meta-sub">
                                                        <span>#${c.id}</span>
                                                        <span>&bull;</span>
                                                        <span>${c.totalLessons} bài học</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div>
                                                <span class="pill-neutral mb-1 d-inline-block">
                                                    ${c.categoryName != null ? c.categoryName : 'Khóa học'}
                                                </span>
                                                <div class="text-dark fw-semibold" style="font-size: 0.85rem;">
                                                    <c:choose>
                                                        <c:when test="${c.price <= 0}"><span class="text-success fw-semibold">Miễn phí</span></c:when>
                                                        <c:otherwise>${c.price} VNĐ</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-dark" style="font-size: 0.875rem;">
                                                <i class="bi bi-play-circle text-primary me-1"></i>${c.totalLessons} bài học
                                            </div>
                                            <div class="text-muted" style="font-size: 0.8rem; margin-top: 2px;">
                                                ${c.modules.size()} chương &bull; ${c.totalQuizzes} quiz
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${c.status == 'PUBLISHED'}">
                                                    <c:choose>
                                                        <c:when test="${c.archiveScheduled}">
                                                            <span class="saas-badge bg-warning bg-opacity-10 text-dark border border-warning" title="Sẽ lưu trữ vào ${c.formattedArchiveAt}">
                                                                <i class="bi bi-clock-history text-warning me-1"></i>Sắp lưu trữ (${c.timeRemainingUntilArchive})
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="saas-badge saas-badge-published">
                                                                <span class="badge-dot"></span>Đã công khai
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:when test="${c.status == 'PENDING_REVIEW'}">
                                                    <span class="saas-badge saas-badge-pending" title="Đang chờ Quản lý duyệt xuất bản">
                                                        <span class="badge-dot"></span>Chờ duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${c.status == 'ARCHIVED'}">
                                                    <span class="saas-badge saas-badge-archived" title="Đã ngừng nhận học viên mới">
                                                        <span class="badge-dot"></span>Đã lưu trữ
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="saas-badge saas-badge-draft" title="Bản nháp riêng tư">
                                                        <span class="badge-dot"></span>Bản nháp
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end text-nowrap">
                                            <div class="d-inline-flex align-items-center justify-content-end gap-2">
                                                <c:choose>
                                                    <c:when test="${c.status == 'PENDING_REVIEW'}">
                                                        <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${c.id}"
                                                           class="btn btn-saas-outline-amber btn-sm text-nowrap"
                                                           title="Khóa học đang chờ duyệt (nhấp để xem nội dung)">
                                                            <i class="bi bi-clock-history me-1"></i>Xem (Chờ duyệt)
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${c.id}"
                                                           class="btn btn-saas-primary btn-sm text-nowrap"
                                                           title="Quản lý chương và bài học">
                                                            <i class="bi bi-pencil-square me-1"></i>Soạn bài
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>

                                                <!-- Secondary Actions Menu (Sleek Dropdown) -->
                                                <div class="dropdown">
                                                    <button type="button" class="btn-icon-action" data-bs-toggle="dropdown" aria-expanded="false" title="Tùy chọn khác" aria-label="Tùy chọn khác">
                                                        <i class="bi bi-three-dots"></i>
                                                    </button>
                                                    <ul class="dropdown-menu dropdown-menu-end saas-dropdown-menu">
                                                        <c:choose>
                                                            <c:when test="${c.status == 'DRAFT'}">
                                                                <li>
                                                                    <a class="saas-dropdown-item text-success fw-semibold"
                                                                       href="javascript:void(0)"
                                                                       onclick="confirmPublishCourse('${fn:escapeXml(c.title)}', '${pageContext.request.contextPath}/expert/request-publish?courseId=${c.id}')">
                                                                        <i class="bi bi-send-check text-success"></i>Gửi duyệt xuất bản
                                                                    </a>
                                                                </li>
                                                                <li><hr class="dropdown-divider my-1"></li>
                                                            </c:when>
                                                            <c:when test="${c.status == 'PENDING_REVIEW'}">
                                                                <li>
                                                                    <a class="saas-dropdown-item text-warning fw-semibold"
                                                                       href="javascript:void(0)"
                                                                       onclick="confirmCancelPublishCourse('${fn:escapeXml(c.title)}', '${pageContext.request.contextPath}/expert/cancel-request-publish?courseId=${c.id}')">
                                                                        <i class="bi bi-arrow-counterclockwise text-warning"></i>Thu hồi yêu cầu duyệt
                                                                    </a>
                                                                </li>
                                                                <li><hr class="dropdown-divider my-1"></li>
                                                            </c:when>
                                                            <c:when test="${c.status == 'PUBLISHED'}">
                                                                <c:choose>
                                                                    <c:when test="${c.archiveScheduled}">
                                                                        <li>
                                                                            <a class="saas-dropdown-item text-danger fw-semibold"
                                                                               href="javascript:void(0)"
                                                                               onclick="confirmCancelArchive('${fn:escapeXml(c.title)}', '${pageContext.request.contextPath}/expert/cancel-archive?id=${c.id}')">
                                                                                <i class="bi bi-x-circle text-danger"></i>Hủy lịch lưu trữ
                                                                            </a>
                                                                        </li>
                                                                        <li>
                                                                            <button type="button" class="saas-dropdown-item w-100 border-0 bg-transparent text-start text-warning fw-semibold"
                                                                                    onclick="openArchiveModal('${c.id}', '${fn:escapeXml(c.title)}')">
                                                                                <i class="bi bi-calendar-event text-warning"></i>Đổi lịch lưu trữ
                                                                            </button>
                                                                        </li>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <li>
                                                                            <button type="button" class="saas-dropdown-item w-100 border-0 bg-transparent text-start text-warning fw-semibold"
                                                                                    onclick="openArchiveModal('${c.id}', '${fn:escapeXml(c.title)}')">
                                                                                <i class="bi bi-archive text-warning"></i>Lưu trữ / Ẩn khóa học
                                                                            </button>
                                                                        </li>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <li><hr class="dropdown-divider my-1"></li>
                                                            </c:when>
                                                            <c:when test="${c.status == 'ARCHIVED'}">
                                                                <li>
                                                                    <a class="saas-dropdown-item text-success fw-semibold"
                                                                       href="javascript:void(0)"
                                                                       onclick="confirmUnarchiveCourse('${fn:escapeXml(c.title)}', '${pageContext.request.contextPath}/expert/unarchive-course?id=${c.id}')">
                                                                        <i class="bi bi-arrow-counterclockwise text-success"></i>Mở lại khóa học (Unarchive)
                                                                    </a>
                                                                </li>
                                                                <li><hr class="dropdown-divider my-1"></li>
                                                            </c:when>
                                                        </c:choose>
                                                        <li>
                                                            <a class="saas-dropdown-item" href="${pageContext.request.contextPath}/quizzes/list?courseId=${c.id}">
                                                                <i class="bi bi-patch-question text-warning"></i>Quản lý Quiz (${c.totalQuizzes})
                                                            </a>
                                                        </li>
                                                        <li>
                                                            <button type="button" class="saas-dropdown-item w-100 border-0 bg-transparent text-start" onclick="openEditCourseModal('${c.id}')">
                                                                <i class="bi bi-gear text-secondary"></i>Chỉnh sửa thông tin
                                                            </button>
                                                        </li>
                                                        <li>
                                                            <a class="saas-dropdown-item" href="${pageContext.request.contextPath}/courses/detail?id=${c.id}" target="_blank">
                                                                <i class="bi bi-box-arrow-up-right text-info"></i>Xem trước khóa học
                                                            </a>
                                                        </li>
                                                        <c:choose>
                                                            <c:when test="${c.status == 'DRAFT'}">
                                                                <li><hr class="dropdown-divider my-1"></li>
                                                                <li>
                                                                    <a class="saas-dropdown-item text-danger" href="javascript:void(0)"
                                                                       onclick="startDeleteCourseCountdown('${c.id}', '${fn:escapeXml(c.title)}')">
                                                                        <i class="bi bi-trash3 text-danger"></i>Xóa vĩnh viễn (Nháp)
                                                                    </a>
                                                                </li>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <li><hr class="dropdown-divider my-1"></li>
                                                                <li>
                                                                    <span class="dropdown-item-text text-muted py-1" style="font-size: 0.75rem;">
                                                                        <i class="bi bi-shield-lock me-1"></i>Chỉ Admin có quyền xóa hoàn toàn
                                                                    </span>
                                                                </li>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </ul>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        <!-- No Match Filter Row -->
                        <tr id="noMatchRow" style="display: none;">
                            <td colspan="5" class="text-center py-5 text-muted">
                                <i class="bi bi-search fs-2 d-block mb-2 text-muted"></i>
                                Không tìm thấy khóa học nào phù hợp với bộ lọc.<br>
                                <button type="button" class="btn btn-link btn-sm text-decoration-none mt-2" onclick="resetFilters()">
                                    Xóa bộ lọc tìm kiếm
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>


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

<!-- New Course Modal (Redesigned Minimalist SaaS Modal) -->
<div class="modal fade" id="newCourseModal" tabindex="-1" aria-labelledby="newCourseModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content saas-modal">
            <form action="${pageContext.request.contextPath}/expert/save-course" method="POST">
                <div class="modal-header saas-modal-header">
                    <div>
                        <h5 class="modal-title fw-bold text-dark mb-1" id="newCourseModalLabel">
                            <i class="bi bi-plus-circle text-primary me-2"></i>Tạo Khóa học mới
                        </h5>
                        <p class="text-muted small mb-0">Nhập thông tin khóa học hoặc dán link YouTube để tự động tạo bài học</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="saas-form-label">Tên khóa học <span class="text-danger">*</span></label>
                        <input type="text" name="title" id="newCourseTitle" class="form-control saas-form-control"
                            placeholder="Ví dụ: Khóa học Lập trình Web Fullstack..." required oninput="this.dataset.autofilled = 'false'">
                        <div class="form-text small text-muted">Nếu dán link Playlist YouTube bên dưới, tên khóa học sẽ tự động được điền theo tên playlist.</div>
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-7">
                            <label class="saas-form-label">Danh mục</label>
                            <div class="saas-combobox" id="newCourseCategoryCombobox">
                                <input type="hidden" name="categoryId" id="newCourseCategoryId" value="${not empty categories ? categories[0].id : ''}">
                                <button type="button" class="saas-combobox-trigger" aria-haspopup="listbox" aria-expanded="false">
                                    <span class="saas-combobox-label">
                                        <i class="bi bi-tag text-muted me-2"></i>
                                        <span class="selected-text">${not empty categories ? categories[0].name : 'Chọn danh mục...'}</span>
                                    </span>
                                    <i class="bi bi-chevron-down saas-combobox-arrow"></i>
                                </button>
                                <div class="saas-combobox-dropdown" role="listbox">
                                    <div class="saas-combobox-search-wrap">
                                        <i class="bi bi-search saas-combobox-search-icon"></i>
                                        <input type="text" class="saas-combobox-search" placeholder="Tìm kiếm danh mục..." autocomplete="off">
                                        <button type="button" class="saas-combobox-search-clear d-none" aria-label="Xóa tìm kiếm">
                                            <i class="bi bi-x-circle-fill"></i>
                                        </button>
                                    </div>
                                    <div class="saas-combobox-list">
                                        <c:forEach var="cat" items="${categories}" varStatus="status">
                                            <div class="saas-combobox-item ${status.first ? 'selected' : ''}"
                                                 data-value="${cat.id}"
                                                 data-label="${fn:escapeXml(cat.name)}"
                                                 role="option">
                                                <span class="item-text"><c:out value="${cat.name}"/></span>
                                                <i class="bi bi-check2 item-check"></i>
                                            </div>
                                        </c:forEach>
                                        <div class="saas-combobox-empty d-none">
                                            <i class="bi bi-search text-muted mb-1 d-block fs-6"></i>
                                            Không tìm thấy danh mục phù hợp
                                        </div>
                                    </div>
                                    <div class="saas-combobox-footer">
                                        <button type="button" class="add-new-btn">
                                            <i class="bi bi-plus-circle text-primary me-2"></i>+ Thêm danh mục mới...
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div id="newCourseCustomCatDiv" class="mt-2" style="display: none;">
                                <div class="position-relative">
                                    <input type="text" name="customCategory"
                                        class="form-control form-control-sm saas-form-control border-primary pe-4"
                                        placeholder="✨ Nhập tên danh mục mới...">
                                    <button type="button" class="btn btn-link btn-sm text-muted position-absolute end-0 top-50 translate-middle-y text-decoration-none p-1 me-1"
                                        onclick="cancelCustomCategory('newCourseCategoryCombobox', 'newCourseCustomCatDiv')" title="Hủy nhập danh mục mới">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-5">
                            <label class="saas-form-label">Học phí (VNĐ)</label>
                            <input type="number" name="price" class="form-control saas-form-control" value="0" min="0"
                                placeholder="0 = Miễn phí">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="saas-form-label">Mô tả tóm tắt</label>
                        <textarea name="description" id="newCourseDescription" rows="4" class="form-control saas-form-control"
                            style="min-height: 105px; resize: vertical; line-height: 1.6;"
                            placeholder="Mô tả ngắn gọn về khóa học..." oninput="this.dataset.autofilled = 'false'; autoResizeTextarea(this);"></textarea>
                    </div>

                    <!-- YouTube Import Card -->
                    <div class="saas-youtube-card mb-2">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="saas-form-label mb-0 text-dark">
                                <i class="bi bi-youtube text-danger me-1"></i>Nhập Playlist hoặc danh sách link YouTube
                            </span>
                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle" style="font-size: 11px;">Tùy chọn</span>
                        </div>
                        <textarea name="batchVideoText" id="newCourseBatchText" rows="3"
                            class="form-control font-monospace small bg-white saas-form-control"
                            placeholder="Dán link playlist (https://www.youtube.com/playlist?list=...) hoặc danh sách link video (mỗi dòng 1 link)..."
                            oninput="previewCourseBatchVideos()"></textarea>
                        
                        <div id="newCourseBatchFeedback" class="mt-2 small d-none"></div>
                    </div>
                </div>
                <div class="modal-footer saas-modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-saas-primary">
                        <i class="bi bi-check-lg me-1"></i>Tạo khóa học
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Single Reusable Edit Course Modal (Redesigned) -->
<div class="modal fade" id="editCourseModal" tabindex="-1" aria-labelledby="editCourseModalTitle" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content saas-modal">
            <form action="${pageContext.request.contextPath}/expert/save-course" method="POST">
                <input type="hidden" name="id" id="editCourseId">
                <div class="modal-header saas-modal-header">
                    <div>
                        <h5 class="modal-title fw-bold text-dark mb-1" id="editCourseModalTitle">
                            <i class="bi bi-gear-fill text-primary me-2"></i>Chỉnh sửa Khóa học
                        </h5>
                        <p class="text-muted small mb-0">Cập nhật thông tin tiêu đề, danh mục và học phí</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <!-- Loading state -->
                    <div id="editCourseLoading" class="text-center py-4">
                        <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
                        <span class="small text-muted">Đang tải thông tin khóa học...</span>
                    </div>

                    <!-- Course Form Fields -->
                    <div id="editCourseFormFields" style="display: none;">
                        <div class="mb-3">
                            <label class="saas-form-label">Tên khóa học <span class="text-danger">*</span></label>
                            <input type="text" name="title" id="editCourseTitle" class="form-control saas-form-control" required>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-md-7">
                                <label class="saas-form-label">Danh mục</label>
                            <div class="saas-combobox" id="editCourseCategoryCombobox">
                                <input type="hidden" name="categoryId" id="editCourseCategory" value="">
                                <button type="button" class="saas-combobox-trigger" aria-haspopup="listbox" aria-expanded="false">
                                    <span class="saas-combobox-label">
                                        <i class="bi bi-tag text-muted me-2"></i>
                                        <span class="selected-text">Chọn danh mục...</span>
                                    </span>
                                    <i class="bi bi-chevron-down saas-combobox-arrow"></i>
                                </button>
                                <div class="saas-combobox-dropdown" role="listbox">
                                    <div class="saas-combobox-search-wrap">
                                        <i class="bi bi-search saas-combobox-search-icon"></i>
                                        <input type="text" class="saas-combobox-search" placeholder="Tìm kiếm danh mục..." autocomplete="off">
                                        <button type="button" class="saas-combobox-search-clear d-none" aria-label="Xóa tìm kiếm">
                                            <i class="bi bi-x-circle-fill"></i>
                                        </button>
                                    </div>
                                    <div class="saas-combobox-list">
                                        <c:forEach var="cat" items="${categories}">
                                            <div class="saas-combobox-item"
                                                 data-value="${cat.id}"
                                                 data-label="${fn:escapeXml(cat.name)}"
                                                 role="option">
                                                <span class="item-text"><c:out value="${cat.name}"/></span>
                                                <i class="bi bi-check2 item-check"></i>
                                            </div>
                                        </c:forEach>
                                        <div class="saas-combobox-empty d-none">
                                            <i class="bi bi-search text-muted mb-1 d-block fs-6"></i>
                                            Không tìm thấy danh mục phù hợp
                                        </div>
                                    </div>
                                    <div class="saas-combobox-footer">
                                        <button type="button" class="add-new-btn">
                                            <i class="bi bi-plus-circle text-primary me-2"></i>+ Nhập danh mục mới...
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div id="editCourseCustomCatDiv" class="mt-2" style="display: none;">
                                <div class="position-relative">
                                    <input type="text" name="customCategory" class="form-control form-control-sm saas-form-control border-primary pe-4"
                                        placeholder="✨ Nhập tên danh mục đào tạo mới...">
                                    <button type="button" class="btn btn-link btn-sm text-muted position-absolute end-0 top-50 translate-middle-y text-decoration-none p-1 me-1"
                                        onclick="cancelCustomCategory('editCourseCategoryCombobox', 'editCourseCustomCatDiv')" title="Hủy nhập danh mục mới">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>
                            </div>
                            </div>
                            <div class="col-md-5">
                                <label class="saas-form-label">Học phí (VNĐ)</label>
                                <input type="number" name="price" id="editCoursePrice" class="form-control saas-form-control" min="0" step="1000">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="saas-form-label">Mô tả tóm tắt</label>
                            <textarea name="description" id="editCourseDescription" rows="4" class="form-control saas-form-control"
                                style="min-height: 105px; resize: vertical; line-height: 1.6;" oninput="autoResizeTextarea(this);"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer saas-modal-footer d-flex justify-content-between align-items-center">
                    <button type="button" class="btn btn-outline-danger btn-sm" id="editCourseDeleteBtn" onclick="deleteEditingCourse()">
                        <i class="bi bi-trash3 me-1"></i>Xóa khóa học này
                    </button>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-saas-primary" id="editCourseSubmitBtn" disabled>
                            <i class="bi bi-check-lg me-1"></i>Lưu thay đổi
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Archive Course Modal -->
<div class="modal fade" id="archiveCourseModal" tabindex="-1" aria-labelledby="archiveCourseModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content saas-modal shadow-lg border-0">
            <form action="${pageContext.request.contextPath}/expert/archive-course" method="POST" id="archiveCourseForm" onsubmit="return validateArchiveSubmit()">
                <input type="hidden" name="courseId" id="archiveCourseId">
                <input type="hidden" name="archiveMode" id="archiveModeInput" value="DURATION">
                <input type="hidden" name="noticeDays" id="archiveNoticeDaysHidden" value="3">

                <div class="modal-header saas-modal-header bg-warning bg-opacity-10 border-bottom border-warning border-opacity-25 px-4 py-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="rounded-circle bg-warning bg-opacity-25 p-2 text-warning d-flex align-items-center justify-content-center" style="width: 44px; height: 44px;">
                            <i class="bi bi-archive-fill fs-5"></i>
                        </div>
                        <div>
                            <h5 class="modal-title fw-bold text-dark mb-0" id="archiveCourseModalTitle">
                                Lưu trữ / Lên lịch ẩn khóa học
                            </h5>
                            <p class="text-muted small mb-0">Thiết lập thời gian ngừng nhận học viên mới và tự động lưu trữ khóa học</p>
                        </div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>

                <div class="modal-body p-4">
                    <!-- Bảo lưu quyền lợi -->
                    <div class="alert alert-info py-2.5 px-3 small mb-3 border-0 bg-info bg-opacity-10 text-dark d-flex align-items-start gap-2 rounded-3">
                        <i class="bi bi-shield-check text-info fs-5 mt-n1 flex-shrink-0"></i>
                        <div>
                            <strong>Bảo lưu quyền lợi:</strong> Học viên đã mua khóa học vẫn tiếp tục được học tập trọn đời bình thường. Khóa học chỉ bị ẩn khỏi danh mục chung và ngừng bán cho học viên mới sau thời hạn được thiết lập.
                        </div>
                    </div>

                    <!-- Khóa học thực hiện -->
                    <div class="mb-3">
                        <label class="saas-form-label fw-bold text-dark small text-uppercase">Khóa học áp dụng:</label>
                        <div class="p-2.5 px-3 bg-light rounded-3 border text-truncate fw-semibold text-dark fs-6" id="archiveCourseTitleDisplay">...</div>
                    </div>

                    <!-- Timing Mode Selector Cards -->
                    <div class="mb-3">
                        <label class="saas-form-label fw-bold text-dark small text-uppercase mb-2">
                            Thời gian chuyển sang chế độ Lưu trữ:
                        </label>
                        
                        <div class="row g-2 mb-3">
                            <!-- Mode 1: Duration -->
                            <div class="col-md-5">
                                <label class="archive-mode-card h-100 p-3 rounded-3 border border-warning bg-warning bg-opacity-10 shadow-sm d-flex flex-column position-relative transition-all" id="cardModeDuration" for="radioModeDuration" style="cursor: pointer;">
                                    <div class="d-flex align-items-center gap-2 mb-1">
                                        <input type="radio" name="archiveTimingRadio" id="radioModeDuration" value="DURATION" checked onchange="switchArchiveMode('DURATION')" class="form-check-input mt-0 flex-shrink-0">
                                        <strong class="text-dark small">Hẹn thời gian bất kỳ</strong>
                                    </div>
                                    <span class="text-muted small ms-4">Nhập số giờ, ngày, tuần, tháng tùy ý</span>
                                </label>
                            </div>
                            
                            <!-- Mode 2: Specific Date -->
                            <div class="col-md-4">
                                <label class="archive-mode-card h-100 p-3 rounded-3 border d-flex flex-column position-relative transition-all" id="cardModeDate" for="radioModeDate" style="cursor: pointer;">
                                    <div class="d-flex align-items-center gap-2 mb-1">
                                        <input type="radio" name="archiveTimingRadio" id="radioModeDate" value="SPECIFIC_DATE" onchange="switchArchiveMode('SPECIFIC_DATE')" class="form-check-input mt-0 flex-shrink-0">
                                        <strong class="text-dark small">Chọn ngày giờ cụ thể</strong>
                                    </div>
                                    <span class="text-muted small ms-4">Chọn mốc thời gian trên lịch</span>
                                </label>
                            </div>

                            <!-- Mode 3: Immediate -->
                            <div class="col-md-3">
                                <label class="archive-mode-card h-100 p-3 rounded-3 border d-flex flex-column position-relative transition-all" id="cardModeImmediate" for="radioModeImmediate" style="cursor: pointer;">
                                    <div class="d-flex align-items-center gap-2 mb-1">
                                        <input type="radio" name="archiveTimingRadio" id="radioModeImmediate" value="IMMEDIATE" onchange="switchArchiveMode('IMMEDIATE')" class="form-check-input mt-0 flex-shrink-0">
                                        <strong class="text-dark small">Ẩn ngay</strong>
                                    </div>
                                    <span class="text-muted small ms-4">Lưu trữ lập tức</span>
                                </label>
                            </div>
                        </div>

                        <!-- SECTION: DURATION INPUT -->
                        <div id="sectionDuration" class="p-3 bg-light rounded-3 border mb-3">
                            <label class="form-label small fw-semibold text-secondary mb-2">Nhập thời lượng bạn muốn thông báo trước khi ẩn:</label>
                            <div class="input-group mb-2">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-hourglass-split"></i></span>
                                <input type="number" name="durationValue" id="archiveDurationValue" class="form-control text-center fw-bold fs-5" min="1" max="9999" value="3" oninput="calculateArchivePreview()">
                                <select name="durationUnit" id="archiveDurationUnit" class="form-select fw-semibold" style="max-width: 130px;" onchange="calculateArchivePreview()">
                                    <option value="DAYS" selected>Ngày</option>
                                    <option value="HOURS">Giờ</option>
                                    <option value="WEEKS">Tuần</option>
                                    <option value="MONTHS">Tháng</option>
                                </select>
                            </div>
                            
                            <!-- Quick presets pills -->
                            <div class="d-flex flex-wrap align-items-center gap-1 pt-1" id="durationPillsContainer">
                                <span class="small text-muted me-1">Chọn nhanh:</span>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill font-monospace" onclick="setQuickDuration(1, 'DAYS')">1 ngày</button>
                                <button type="button" class="btn btn-sm btn-outline-primary py-0 px-2 rounded-pill font-monospace active" onclick="setQuickDuration(3, 'DAYS')">3 ngày</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill font-monospace" onclick="setQuickDuration(7, 'DAYS')">7 ngày</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill font-monospace" onclick="setQuickDuration(14, 'DAYS')">14 ngày</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill font-monospace" onclick="setQuickDuration(30, 'DAYS')">30 ngày (1 tháng)</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill font-monospace" onclick="setQuickDuration(60, 'DAYS')">60 ngày</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill font-monospace" onclick="setQuickDuration(90, 'DAYS')">90 ngày (3 tháng)</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill font-monospace" onclick="setQuickDuration(180, 'DAYS')">6 tháng</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill font-monospace" onclick="setQuickDuration(365, 'DAYS')">1 năm</button>
                            </div>
                        </div>

                        <!-- SECTION: SPECIFIC DATE INPUT -->
                        <div id="sectionSpecificDate" class="p-3 bg-light rounded-3 border mb-3 d-none">
                            <label class="form-label small fw-semibold text-secondary mb-2">Chọn thời điểm chính xác muốn khóa học tự động chuyển sang Lưu trữ:</label>
                            <div class="input-group mb-2">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-calendar3"></i></span>
                                <input type="datetime-local" name="specificArchiveDate" id="archiveSpecificDate" class="form-control fw-semibold" onchange="calculateArchivePreview()">
                            </div>
                            <div class="d-flex flex-wrap align-items-center gap-1 pt-1">
                                <span class="small text-muted me-1">Gợi ý mốc:</span>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill" onclick="setSpecificPreset('TODAY_END')">Cuối ngày hôm nay (23:59)</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill" onclick="setSpecificPreset('WEEK_END')">Chủ nhật tuần này (23:59)</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2 rounded-pill" onclick="setSpecificPreset('MONTH_END')">Ngày cuối tháng này (23:59)</button>
                            </div>
                        </div>

                        <!-- SECTION: IMMEDIATE NOTICE -->
                        <div id="sectionImmediate" class="p-3 bg-warning bg-opacity-10 border border-warning border-opacity-50 rounded-3 mb-3 d-none">
                            <div class="d-flex align-items-center gap-2 text-warning-emphasis fw-semibold">
                                <i class="bi bi-lightning-charge-fill fs-5 text-warning"></i>
                                <span>Khóa học sẽ lập tức chuyển sang trạng thái ARCHIVED và ẩn khỏi trang tìm kiếm/danh mục chung.</span>
                            </div>
                        </div>

                        <!-- LIVE PREVIEW BOX -->
                        <div class="p-3 rounded-3 border border-primary border-opacity-25 bg-primary bg-opacity-10 d-flex align-items-start gap-2.5" id="archiveLivePreviewBox">
                            <i class="bi bi-clock-history text-primary fs-5 mt-n0.5 flex-shrink-0"></i>
                            <div class="small w-100">
                                <div class="text-secondary fw-medium">Dự kiến thời điểm lưu trữ:</div>
                                <div class="fw-bold text-dark fs-6" id="archiveCalculatedTimeDisplay">...</div>
                                <div class="text-muted mt-0.5" id="archivePreviewHelperText">Banner cảnh báo sẽ hiển thị để nhắc nhở học sinh mới trước khi chính thức ẩn khóa học.</div>
                            </div>
                        </div>
                    </div>

                    <!-- ARCHIVE NOTICE TEXTAREA -->
                    <div class="mb-2">
                        <div class="d-flex align-items-center justify-content-between mb-1.5 flex-wrap gap-1">
                            <label class="saas-form-label fw-bold text-dark small text-uppercase mb-0">Nội dung thông báo hiển thị cho học viên:</label>
                            <button type="button" class="btn btn-link btn-sm text-decoration-none p-0 fw-semibold text-primary" onclick="generateAutoNoticeMessage()">
                                <i class="bi bi-magic me-1"></i>Tự động điền theo thời gian đã chọn
                            </button>
                        </div>
                        <textarea name="archiveNotice" id="archiveNoticeText" rows="3" class="form-control saas-form-control"
                            placeholder="Nhập lời nhắn gửi đến học viên..."></textarea>
                    </div>
                </div>

                <div class="modal-footer saas-modal-footer px-4 py-3 bg-light border-top">
                    <button type="button" class="btn btn-outline-secondary px-3" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-warning text-dark fw-bold px-4 shadow-sm" id="btnSubmitArchive">
                        <i class="bi bi-archive-fill me-1"></i>Xác nhận lưu trữ
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function autoResizeTextarea(el) {
        if (!el) return;
        el.style.height = 'auto';
        el.style.height = Math.max(105, el.scrollHeight + 4) + 'px';
    }

    // =========================================================================
    // CLIENT-SIDE FILTER & INSTANT SEARCH
    // =========================================================================
    let currentFilter = 'all';

    function filterCourses(status, btnEl) {
        currentFilter = status;
        const tabBtns = document.querySelectorAll('#statusFilterTabs .saas-tab-btn');
        tabBtns.forEach(btn => btn.classList.remove('active'));
        if (btnEl) btnEl.classList.add('active');

        applyFilters();
    }

    function handleCourseSearch() {
        applyFilters();
    }

    function applyFilters() {
        const query = (document.getElementById('courseSearchInput').value || '').trim().toLowerCase();
        const rows = document.querySelectorAll('.course-row');
        let visibleCount = 0;

        rows.forEach(row => {
            const status = row.getAttribute('data-status') || '';
            const title = (row.getAttribute('data-title') || '').toLowerCase();
            const category = (row.getAttribute('data-category') || '').toLowerCase();

            const matchesStatus = (currentFilter === 'all') || (status === currentFilter);
            const matchesQuery = !query || title.includes(query) || category.includes(query);

            if (matchesStatus && matchesQuery) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        const noMatchRow = document.getElementById('noMatchRow');
        if (noMatchRow) {
            noMatchRow.style.display = (visibleCount === 0 && rows.length > 0) ? '' : 'none';
        }
    }

    function resetFilters() {
        document.getElementById('courseSearchInput').value = '';
        const allTab = document.querySelector('#statusFilterTabs .saas-tab-btn[data-filter="all"]');
        filterCourses('all', allTab);
    }

    // =========================================================================
    // EDIT COURSE MODAL LOGIC (Preserved O(1) Fetch)
    // =========================================================================
    function openEditCourseModal(courseId) {
        const modalEl = document.getElementById('editCourseModal');
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);

        document.getElementById('editCourseModalTitle').innerHTML = '<i class="bi bi-gear-fill text-primary me-2"></i>Chỉnh sửa Khóa học #' + courseId;
        document.getElementById('editCourseId').value = courseId;
        document.getElementById('editCourseLoading').style.display = 'block';
        document.getElementById('editCourseFormFields').style.display = 'none';
        document.getElementById('editCourseSubmitBtn').disabled = true;

        const customDiv = document.getElementById('editCourseCustomCatDiv');
        if (customDiv) customDiv.style.display = 'none';

        modal.show();

        fetch('${pageContext.request.contextPath}/expert/get-course?id=' + encodeURIComponent(courseId))
            .then(res => {
                if (!res.ok) throw new Error('Không thể tải khóa học #' + courseId);
                return res.json();
            })
            .then(data => {
                if (data.error) {
                    alert(data.error);
                    modal.hide();
                    return;
                }
                document.getElementById('editCourseId').value = data.id;
                document.getElementById('editCourseTitle').value = data.title || '';
                if (data.categoryId) {
                    setComboboxValue('editCourseCategoryCombobox', data.categoryId, data.categoryName);
                } else if (data.categoryName) {
                    setComboboxValue('editCourseCategoryCombobox', '__NEW__', data.categoryName);
                    const customDiv = document.getElementById('editCourseCustomCatDiv');
                    if (customDiv) {
                        customDiv.style.display = 'block';
                        const inp = customDiv.querySelector('input');
                        if (inp) inp.value = data.categoryName;
                    }
                }
                document.getElementById('editCoursePrice').value = data.price != null ? data.price : 0;
                const editDescEl = document.getElementById('editCourseDescription');
                editDescEl.value = data.description || '';
                autoResizeTextarea(editDescEl);

                document.getElementById('editCourseLoading').style.display = 'none';
                document.getElementById('editCourseFormFields').style.display = 'block';
                document.getElementById('editCourseSubmitBtn').disabled = false;

                // Quy tắc: Chỉ khóa học ở trạng thái DRAFT mới cho phép Expert xóa
                const delBtn = document.getElementById('editCourseDeleteBtn');
                if (delBtn) {
                    if (data.status === 'DRAFT') {
                        delBtn.style.display = 'inline-block';
                    } else {
                        delBtn.style.display = 'none';
                    }
                }
            })
            .catch(err => {
                alert('Lỗi khi truy vấn khóa học từ CSDL: ' + err.message);
                modal.hide();
            });
    }

        // =========================================================================
    // ARCHIVE COURSE MODAL CONTROLLER (FLEXIBLE TIMING)
    // =========================================================================
    let currentArchiveMode = 'DURATION';

    function openArchiveModal(courseId, courseTitle) {
        document.getElementById('archiveCourseId').value = courseId;
        document.getElementById('archiveCourseTitleDisplay').textContent = courseTitle;

        // Cài đặt ngày tối thiểu cho datetime-local là thời điểm hiện tại
        const now = new Date();
        const pad = n => n < 10 ? '0' + n : n;
        const minVal = now.getFullYear() + '-' + pad(now.getMonth() + 1) + '-' + pad(now.getDate()) + 'T' + pad(now.getHours()) + ':' + pad(now.getMinutes());
        
        const dateInput = document.getElementById('archiveSpecificDate');
        if (dateInput) {
            dateInput.min = minVal;
            const defaultDate = new Date();
            defaultDate.setDate(defaultDate.getDate() + 3);
            defaultDate.setHours(23, 59, 0, 0);
            dateInput.value = defaultDate.getFullYear() + '-' + pad(defaultDate.getMonth() + 1) + '-' + pad(defaultDate.getDate()) + 'T' + pad(defaultDate.getHours()) + ':' + pad(defaultDate.getMinutes());
        }

        // Mặc định về chế độ hẹn thời gian bất kỳ (3 ngày)
        switchArchiveMode('DURATION');
        setQuickDuration(3, 'DAYS');
        generateAutoNoticeMessage();

        const modalEl = document.getElementById('archiveCourseModal');
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    }

    function switchArchiveMode(mode) {
        currentArchiveMode = mode;
        document.getElementById('archiveModeInput').value = mode;

        ['cardModeDuration', 'cardModeDate', 'cardModeImmediate'].forEach(id => {
            const el = document.getElementById(id);
            if (el) {
                el.classList.remove('border-warning', 'bg-warning', 'bg-opacity-10', 'shadow-sm');
                el.classList.add('border');
            }
        });

        const activeCardId = mode === 'DURATION' ? 'cardModeDuration' : (mode === 'SPECIFIC_DATE' ? 'cardModeDate' : 'cardModeImmediate');
        const activeEl = document.getElementById(activeCardId);
        if (activeEl) {
            activeEl.classList.remove('border');
            activeEl.classList.add('border-warning', 'bg-warning', 'bg-opacity-10', 'shadow-sm');
        }

        const secDur = document.getElementById('sectionDuration');
        const secDate = document.getElementById('sectionSpecificDate');
        const secImm = document.getElementById('sectionImmediate');
        const previewBox = document.getElementById('archiveLivePreviewBox');

        if (secDur) secDur.classList.toggle('d-none', mode !== 'DURATION');
        if (secDate) secDate.classList.toggle('d-none', mode !== 'SPECIFIC_DATE');
        if (secImm) secImm.classList.toggle('d-none', mode !== 'IMMEDIATE');
        if (previewBox) previewBox.classList.toggle('d-none', mode === 'IMMEDIATE');

        calculateArchivePreview();
    }

    function setQuickDuration(value, unit) {
        const valInput = document.getElementById('archiveDurationValue');
        const unitSelect = document.getElementById('archiveDurationUnit');
        if (valInput) valInput.value = value;
        if (unitSelect) unitSelect.value = unit;
        
        const container = document.getElementById('durationPillsContainer');
        if (container) {
            container.querySelectorAll('button').forEach(btn => {
                btn.classList.remove('btn-outline-primary', 'active');
                btn.classList.add('btn-outline-secondary');
            });
            if (window.event && window.event.target && window.event.target.tagName === 'BUTTON') {
                window.event.target.classList.remove('btn-outline-secondary');
                window.event.target.classList.add('btn-outline-primary', 'active');
            }
        }

        calculateArchivePreview();
    }

    function setSpecificPreset(type) {
        const now = new Date();
        let target = new Date();

        if (type === 'TODAY_END') {
            target.setHours(23, 59, 0, 0);
        } else if (type === 'WEEK_END') {
            const day = now.getDay();
            const diff = (7 - day) % 7;
            target.setDate(now.getDate() + diff);
            target.setHours(23, 59, 0, 0);
        } else if (type === 'MONTH_END') {
            target = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 0);
        }

        const pad = n => n < 10 ? '0' + n : n;
        const val = target.getFullYear() + '-' + pad(target.getMonth() + 1) + '-' + pad(target.getDate()) + 'T' + pad(target.getHours()) + ':' + pad(target.getMinutes());
        const dateInput = document.getElementById('archiveSpecificDate');
        if (dateInput) dateInput.value = val;

        calculateArchivePreview();
    }

    function calculateArchivePreview() {
        const timeDisplay = document.getElementById('archiveCalculatedTimeDisplay');
        const helperText = document.getElementById('archivePreviewHelperText');
        const hiddenNoticeDays = document.getElementById('archiveNoticeDaysHidden');
        if (!timeDisplay) return;

        const now = new Date();
        let targetTime = new Date();

        if (currentArchiveMode === 'IMMEDIATE') {
            if (hiddenNoticeDays) hiddenNoticeDays.value = 0;
            return;
        }

        if (currentArchiveMode === 'DURATION') {
            const val = parseInt(document.getElementById('archiveDurationValue').value) || 1;
            const unit = document.getElementById('archiveDurationUnit').value;

            if (unit === 'HOURS') {
                targetTime.setTime(now.getTime() + val * 60 * 60 * 1000);
                if (hiddenNoticeDays) hiddenNoticeDays.value = Math.max(1, Math.round(val / 24));
            } else if (unit === 'DAYS') {
                targetTime.setDate(now.getDate() + val);
                if (hiddenNoticeDays) hiddenNoticeDays.value = val;
            } else if (unit === 'WEEKS') {
                targetTime.setDate(now.getDate() + (val * 7));
                if (hiddenNoticeDays) hiddenNoticeDays.value = val * 7;
            } else if (unit === 'MONTHS') {
                targetTime.setMonth(now.getMonth() + val);
                if (hiddenNoticeDays) hiddenNoticeDays.value = val * 30;
            }
        } else if (currentArchiveMode === 'SPECIFIC_DATE') {
            const dateInput = document.getElementById('archiveSpecificDate').value;
            if (dateInput) {
                targetTime = new Date(dateInput);
                const diffMs = targetTime.getTime() - now.getTime();
                if (hiddenNoticeDays) hiddenNoticeDays.value = Math.max(1, Math.ceil(diffMs / (1000 * 60 * 60 * 24)));
            } else {
                timeDisplay.textContent = 'Vui lòng chọn ngày giờ...';
                return;
            }
        }

        const pad = n => n < 10 ? '0' + n : n;
        const formattedDate = pad(targetTime.getDate()) + '/' + pad(targetTime.getMonth() + 1) + '/' + targetTime.getFullYear() + ' ' + pad(targetTime.getHours()) + ':' + pad(targetTime.getMinutes());
        
        const diffMs = targetTime.getTime() - now.getTime();
        if (diffMs <= 0) {
            timeDisplay.innerHTML = '<span class="text-danger">' + formattedDate + ' (Thời gian đã qua hoặc không hợp lệ!)</span>';
            if (helperText) helperText.textContent = 'Vui lòng chọn thời điểm trong tương lai.';
            return;
        }

        const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
        const diffDays = Math.floor(diffHours / 24);
        const remHours = diffHours % 24;

        let remainingStr = '';
        if (diffDays > 0) {
            remainingStr = diffDays + ' ngày' + (remHours > 0 ? ' ' + remHours + ' giờ' : '');
        } else if (diffHours > 0) {
            const remMins = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
            remainingStr = diffHours + ' giờ' + (remMins > 0 ? ' ' + remMins + ' phút' : '');
        } else {
            const remMins = Math.floor(diffMs / (1000 * 60));
            remainingStr = Math.max(1, remMins) + ' phút';
        }

        timeDisplay.innerHTML = '<span class="text-primary">' + formattedDate + '</span> <span class="badge bg-primary bg-opacity-10 text-primary ms-1">còn ' + remainingStr + '</span>';
        if (helperText) {
            helperText.textContent = 'Banner đếm ngược sẽ hiển thị công khai trên trang khóa học cho đến thời điểm trên.';
        }
    }

    function generateAutoNoticeMessage() {
        const noticeText = document.getElementById('archiveNoticeText');
        if (!noticeText) return;

        if (currentArchiveMode === 'IMMEDIATE') {
            noticeText.value = 'Khóa học này đã chính thức ngừng nhận học viên mới và chuyển sang chế độ Lưu trữ. Học viên đã đăng ký vẫn được học tập trọn đời bình thường.';
            return;
        }

        const timeDisplayEl = document.getElementById('archiveCalculatedTimeDisplay');
        const dateSpan = timeDisplayEl ? timeDisplayEl.querySelector('.text-primary') : null;
        const formattedDate = dateSpan ? dateSpan.textContent : '';

        if (formattedDate) {
            noticeText.value = 'Khóa học này sẽ chính thức ngừng nhận học viên mới và chuyển sang chế độ Lưu trữ vào lúc ' + formattedDate + '. Học viên quan tâm vui lòng đăng ký trước thời hạn này. Học viên đã đăng ký vẫn được học tập trọn đời bình thường.';
        } else {
            noticeText.value = 'Khóa học này sẽ chính thức ngừng nhận học viên mới và chuyển sang chế độ Lưu trữ. Học viên đã đăng ký vẫn được học tập trọn đời bình thường.';
        }
    }

    function validateArchiveSubmit() {
        if (currentArchiveMode === 'DURATION') {
            const val = parseInt(document.getElementById('archiveDurationValue').value);
            if (isNaN(val) || val <= 0) {
                alert('Vui lòng nhập thời lượng lưu trữ lớn hơn 0.');
                document.getElementById('archiveDurationValue').focus();
                return false;
            }
        } else if (currentArchiveMode === 'SPECIFIC_DATE') {
            const dateVal = document.getElementById('archiveSpecificDate').value;
            if (!dateVal) {
                alert('Vui lòng chọn ngày giờ muốn khóa học chuyển sang Lưu trữ.');
                document.getElementById('archiveSpecificDate').focus();
                return false;
            }
            const targetTime = new Date(dateVal);
            if (targetTime.getTime() <= Date.now()) {
                alert('Thời điểm lưu trữ phải ở trong tương lai. Vui lòng chọn lại.');
                document.getElementById('archiveSpecificDate').focus();
                return false;
            }
        }
        return true;
    }

    // =========================================================================
    // SAAS SEARCHABLE SELECT (COMBOBOX) CONTROLLER
    // =========================================================================
    function removeVietnameseDiacritics(str) {
        if (!str) return '';
        return str.normalize("NFD")
                  .replace(/[\u0300-\u036f]/g, "")
                  .replace(/đ/g, "d").replace(/Đ/g, "D")
                  .toLowerCase()
                  .trim();
    }

    function initSearchableSelect(comboboxId, customDivId) {
        const box = document.getElementById(comboboxId);
        if (!box) return;

        const trigger = box.querySelector('.saas-combobox-trigger');
        const labelSpan = box.querySelector('.selected-text');
        const hiddenInput = box.querySelector('input[type="hidden"]');
        const searchInput = box.querySelector('.saas-combobox-search');
        const searchClear = box.querySelector('.saas-combobox-search-clear');
        const items = box.querySelectorAll('.saas-combobox-list .saas-combobox-item');
        const emptyBox = box.querySelector('.saas-combobox-empty');
        const addNewBtn = box.querySelector('.add-new-btn');
        const customDiv = document.getElementById(customDivId);
        const customInput = customDiv ? customDiv.querySelector('input') : null;

        function openDropdown() {
            document.querySelectorAll('.saas-combobox.open').forEach(cb => {
                if (cb !== box) cb.classList.remove('open');
            });
            box.classList.add('open');
            trigger.setAttribute('aria-expanded', 'true');
            if (searchInput) {
                searchInput.value = '';
                filterItems('');
                setTimeout(() => searchInput.focus(), 50);
            }
        }

        function closeDropdown() {
            box.classList.remove('open');
            trigger.setAttribute('aria-expanded', 'false');
        }

        function toggleDropdown() {
            if (box.classList.contains('open')) {
                closeDropdown();
            } else {
                openDropdown();
            }
        }

        trigger.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            toggleDropdown();
        });

        document.addEventListener('click', function(e) {
            if (!box.contains(e.target)) {
                closeDropdown();
            }
        });

        box.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeDropdown();
                trigger.focus();
            }
        });

        function filterItems(query) {
            const cleanQuery = removeVietnameseDiacritics(query);
            let matchCount = 0;

            if (searchClear) {
                if (query.trim()) {
                    searchClear.classList.remove('d-none');
                } else {
                    searchClear.classList.add('d-none');
                }
            }

            items.forEach(it => {
                const label = it.getAttribute('data-label') || it.textContent;
                const cleanLabel = removeVietnameseDiacritics(label);
                if (!cleanQuery || cleanLabel.includes(cleanQuery)) {
                    it.classList.remove('d-none');
                    matchCount++;
                } else {
                    it.classList.add('d-none');
                }
            });

            if (emptyBox) {
                if (matchCount === 0) {
                    emptyBox.classList.remove('d-none');
                } else {
                    emptyBox.classList.add('d-none');
                }
            }

            if (addNewBtn) {
                if (query.trim()) {
                    addNewBtn.innerHTML = '<i class="bi bi-plus-circle text-primary me-2"></i>+ Thêm danh mục "' + escapeHtml(query.trim()) + '"...';
                    addNewBtn.dataset.customText = query.trim();
                } else {
                    addNewBtn.innerHTML = '<i class="bi bi-plus-circle text-primary me-2"></i>+ Thêm danh mục mới...';
                    delete addNewBtn.dataset.customText;
                }
            }
        }

        if (searchInput) {
            searchInput.addEventListener('input', function() {
                filterItems(this.value);
            });
            searchInput.addEventListener('click', function(e) {
                e.stopPropagation();
            });
        }

        if (searchClear) {
            searchClear.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                searchInput.value = '';
                filterItems('');
                searchInput.focus();
            });
        }

        items.forEach(it => {
            it.addEventListener('click', function(e) {
                e.stopPropagation();
                const val = this.getAttribute('data-value');
                const label = this.getAttribute('data-label') || this.querySelector('.item-text').textContent;

                items.forEach(i => i.classList.remove('selected'));
                this.classList.add('selected');

                hiddenInput.value = val;
                labelSpan.textContent = label;

                if (customDiv) {
                    customDiv.style.display = 'none';
                    if (customInput) {
                        customInput.required = false;
                        customInput.value = '';
                    }
                }

                closeDropdown();
                trigger.focus();
            });
        });

        if (addNewBtn) {
            addNewBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                hiddenInput.value = '__NEW__';
                const customVal = addNewBtn.dataset.customText || '';
                labelSpan.textContent = customVal ? ('Mới: ' + customVal) : '+ Danh mục mới';

                items.forEach(i => i.classList.remove('selected'));

                if (customDiv) {
                    customDiv.style.display = 'block';
                    if (customInput) {
                        customInput.required = true;
                        if (customVal) customInput.value = customVal;
                        setTimeout(() => customInput.focus(), 50);
                    }
                }

                closeDropdown();
            });
        }

        if (customInput) {
            customInput.addEventListener('input', function() {
                if (this.value.trim()) {
                    labelSpan.textContent = 'Mới: ' + this.value.trim();
                } else {
                    labelSpan.textContent = '+ Danh mục mới';
                }
            });
        }
    }

    function setComboboxValue(comboboxId, value, fallbackName) {
        const box = document.getElementById(comboboxId);
        if (!box) return;

        const hiddenInput = box.querySelector('input[type="hidden"]');
        const labelSpan = box.querySelector('.selected-text');
        const items = box.querySelectorAll('.saas-combobox-list .saas-combobox-item');

        let matched = false;
        items.forEach(it => {
            if (it.getAttribute('data-value') == value) {
                it.classList.add('selected');
                labelSpan.textContent = it.getAttribute('data-label') || it.textContent.trim();
                hiddenInput.value = value;
                matched = true;
            } else {
                it.classList.remove('selected');
            }
        });

        if (!matched && fallbackName) {
            hiddenInput.value = value || '__NEW__';
            labelSpan.textContent = fallbackName;
        }
    }

    function cancelCustomCategory(comboboxId, customDivId) {
        const box = document.getElementById(comboboxId);
        const customDiv = document.getElementById(customDivId);
        if (customDiv) {
            customDiv.style.display = 'none';
            const inp = customDiv.querySelector('input');
            if (inp) {
                inp.required = false;
                inp.value = '';
            }
        }
        if (box) {
            const firstItem = box.querySelector('.saas-combobox-list .saas-combobox-item');
            if (firstItem) {
                const val = firstItem.getAttribute('data-value');
                const label = firstItem.getAttribute('data-label') || firstItem.textContent.trim();
                setComboboxValue(comboboxId, val, label);
            }
        }
    }

    function escapeHtml(text) {
        if (!text) return '';
        return text.replace(/&/g, "&amp;")
                   .replace(/</g, "&lt;")
                   .replace(/>/g, "&gt;")
                   .replace(/"/g, "&quot;")
                   .replace(/'/g, "&#039;");
    }

    document.addEventListener('DOMContentLoaded', function() {
        initSearchableSelect('newCourseCategoryCombobox', 'newCourseCustomCatDiv');
        initSearchableSelect('editCourseCategoryCombobox', 'editCourseCustomCatDiv');
    });

    // =========================================================================
    // YOUTUBE PLAYLIST BATCH AUTO-DETECT & PREVIEW
    // =========================================================================
    let courseBatchTimer = null;
    let courseBatchAbortController = null;

    function hasYoutubeVideoOrPlaylist(text) {
        if (!text || !text.trim()) return false;
        const playlistRegex = /(?:[?&]list=|playlist\?list=)[a-zA-Z0-9_-]+|^PL[a-zA-Z0-9_-]{16,}/i;
        const videoRegex = /(?:youtu\.be\/|youtube\.com\/(?:watch\?.*v=|embed\/|v\/|shorts\/)|youtube\.com\/live\/)[a-zA-Z0-9_-]{11}/i;
        return playlistRegex.test(text) || videoRegex.test(text);
    }

    function previewCourseBatchVideos() {
        const text = document.getElementById('newCourseBatchText').value;
        const feedback = document.getElementById('newCourseBatchFeedback');

        // 1. Hủy ngay request cũ đang bay dở dang nếu có
        if (courseBatchAbortController) {
            courseBatchAbortController.abort();
            courseBatchAbortController = null;
        }

        // 2. Xóa bộ đếm chờ trước đó
        clearTimeout(courseBatchTimer);

        // 3. Nếu rỗng -> ẩn feedback và dừng lại
        if (!text || !text.trim()) {
            feedback.className = 'mt-2 small d-none';
            feedback.innerHTML = '';
            return;
        }

        // 4. KIỂM TRA ĐỊNH DẠNG: Chỉ gọi API nếu thực sự có link Playlist hoặc video YouTube!
        if (!hasYoutubeVideoOrPlaylist(text)) {
            feedback.className = 'mt-2 small text-muted';
            feedback.innerHTML = '<i class="bi bi-info-circle me-1"></i>Hệ thống nhận diện link Playlist (có ?list=...) hoặc link video YouTube (watch?v=, youtu.be, shorts).';
            return;
        }

        feedback.className = 'mt-2 small text-muted';
        feedback.innerHTML = '<span class="spinner-border spinner-border-sm text-danger me-1"></span>Đang phân tích video / playlist YouTube...';

        // 5. Chờ 300ms sau khi người dùng dừng nhập/dán thì mới gửi request mới
        courseBatchTimer = setTimeout(() => {
            courseBatchAbortController = new AbortController();
            const signal = courseBatchAbortController.signal;

            const params = new URLSearchParams();
            params.append('batchText', text);
            fetch('${pageContext.request.contextPath}/expert/preview-batch-videos', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString(),
                signal: signal
            })
            .then(r => r.json())
            .then(data => {
                const list = Array.isArray(data) ? data : (data.videos || []);
                if (list && list.length > 0) {
                    const plTitle = data.playlistTitle;
                    let infoText = 'Đã nhận diện: <strong>' + list.length + ' bài giảng</strong>';
                    if (plTitle) {
                        infoText += ' từ Playlist: "<strong>' + plTitle + '</strong>"';
                        const titleInp = document.getElementById('newCourseTitle');
                        if (titleInp && (!titleInp.value.trim() || titleInp.dataset.autofilled === 'true')) {
                            titleInp.value = plTitle;
                            titleInp.dataset.autofilled = 'true';
                        }
                    }

                    // Tự động gán danh mục nếu phát hiện (chọn ngầm định)
                    if (data.suggestedCategoryId && data.suggestedCategoryName) {
                        setComboboxValue('newCourseCategoryCombobox', data.suggestedCategoryId, data.suggestedCategoryName);
                    }

                    // Tự động điền mô tả tóm tắt nếu AI sinh thành công
                    if (data.suggestedDescription) {
                        const descInp = document.getElementById('newCourseDescription');
                        if (descInp && (!descInp.value.trim() || descInp.dataset.autofilled === 'true')) {
                            let cleanDesc = data.suggestedDescription.replace(/\\"/g, '"').replace(/^"+|"+$/g, '').trim();
                            descInp.value = cleanDesc;
                            descInp.dataset.autofilled = 'true';
                            autoResizeTextarea(descInp);
                        }
                    }

                    feedback.className = 'mt-2 small alert alert-success py-1 px-2 mb-0 d-flex align-items-center justify-content-between';
                    feedback.innerHTML = '<span><i class="bi bi-check-circle-fill text-success me-1"></i>' + infoText + '</span>';
                } else {
                    feedback.className = 'mt-2 small text-muted';
                    feedback.innerHTML = '<i class="bi bi-info-circle me-1"></i>Chưa nhận diện được video YouTube hợp lệ.';
                }
            })
            .catch(err => {
                // Nếu bị abort do người dùng đổi link khác -> im lặng bỏ qua, không nhận dữ liệu cũ
                if (err.name === 'AbortError') return;
                feedback.className = 'mt-2 small d-none';
            });
        }, 300);
    }

    function generateAiDescription(titleInputId, descInputId, categoryComboboxId, btnEl) {
        const titleInp = document.getElementById(titleInputId);
        const descInp = document.getElementById(descInputId);
        if (!titleInp || !titleInp.value.trim()) {
            alert('Vui lòng nhập tên khóa học trước khi yêu cầu AI viết mô tả!');
            titleInp.focus();
            return;
        }

        let catName = '';
        if (categoryComboboxId) {
            const box = document.getElementById(categoryComboboxId);
            if (box) {
                const label = box.querySelector('.selected-text');
                if (label) catName = label.textContent.trim();
            }
        }

        const originalBtnHtml = btnEl ? btnEl.innerHTML : '';
        if (btnEl) {
            btnEl.disabled = true;
            btnEl.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>Đang viết...';
        }

        const params = new URLSearchParams();
        params.append('title', titleInp.value.trim());
        if (catName && catName !== 'Chọn danh mục...') {
            params.append('categoryName', catName);
        }

        fetch('${pageContext.request.contextPath}/expert/generate-ai-description', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(r => r.json())
        .then(data => {
            if (data && data.description) {
                descInp.value = data.description;
                descInp.dataset.autofilled = 'false';
                descInp.style.transition = 'all 0.3s ease';
                descInp.style.backgroundColor = 'rgba(37, 99, 235, 0.08)';
                setTimeout(() => {
                    descInp.style.backgroundColor = '';
                }, 800);
            } else {
                alert('Không thể tạo mô tả lúc này. Vui lòng kiểm tra lại tên khóa học hoặc thử lại sau!');
            }
        })
        .catch(err => {
            alert('Lỗi kết nối khi gọi AI: ' + err.message);
        })
        .finally(() => {
            if (btnEl) {
                btnEl.disabled = false;
                btnEl.innerHTML = originalBtnHtml;
            }
        });
    }

    function deleteEditingCourse() {
        const id = document.getElementById('editCourseId').value;
        const title = document.getElementById('editCourseTitle').value;
        const modalEl = document.getElementById('editCourseModal');
        const modalInstance = bootstrap.Modal.getInstance(modalEl);
        if (modalInstance) modalInstance.hide();
        startDeleteCourseCountdown(id, title);
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

    function confirmCancelArchive(title, url) {
        showConfirmModal({
            title: 'Hủy lịch lưu trữ',
            method: 'POST',
            html: 'Bạn có chắc chắn muốn hủy lịch lưu trữ và tiếp tục giữ khóa học "<strong>' + (title || '') + '</strong>" công khai bình thường?',
            type: 'primary',
            icon: 'bi bi-calendar-x-fill',
            confirmText: 'Hủy lịch lưu trữ',
            confirmIcon: 'bi bi-calendar-x me-1',
            confirmBtnClass: 'btn-primary',
            confirmUrl: url
        });
    }

    function confirmUnarchiveCourse(title, url) {
        showConfirmModal({
            title: 'Mở lại khóa học (Unarchive)',
            method: 'POST',
            html: 'Khóa học "<strong>' + (title || '') + '</strong>" sẽ được công khai trở lại trên danh mục và cho phép học viên mới tiếp tục đăng ký.',
            type: 'success',
            icon: 'bi bi-arrow-counterclockwise',
            confirmText: 'Công khai trở lại',
            confirmIcon: 'bi bi-check-circle me-1',
            confirmBtnClass: 'btn-success',
            confirmUrl: url
        });
    }

    // ==========================================
    // KHÓA HỌC: ROLLBACK QUA COURSONROLLBACK
    // ==========================================
    function startDeleteCourseCountdown(courseId, courseTitle) {
        CoursonRollback.start({
            element: 'courseRow-' + courseId,
            type: 'Khóa học',
            title: courseTitle,
            endpoint: '${pageContext.request.contextPath}/expert/delete-course',
            body: 'id=' + encodeURIComponent(courseId) + '&ajax=true'
        });
    }

    function confirmDeleteCourse(title, url) {
        const match = url.match(/[?&]id=([^&]+)/);
        if (match) {
            startDeleteCourseCountdown(decodeURIComponent(match[1]), title);
            return;
        }
        showConfirmModal({
            title: 'Xác nhận xóa khóa học nháp',
            method: 'POST',
            html: 'Bạn có chắc chắn muốn xóa vĩnh viễn khóa học nháp "<strong>' + (title || '') + '</strong>"?<br><span class="text-danger small mt-2 d-inline-block"><i class="bi bi-exclamation-triangle me-1"></i>Toàn bộ nội dung bài học bên trong sẽ bị xóa vĩnh viễn.</span>',
            type: 'danger',
            icon: 'bi bi-trash3-fill',
            confirmText: 'Xóa vĩnh viễn',
            confirmIcon: 'bi bi-trash3 me-1',
            confirmBtnClass: 'btn-danger',
            confirmUrl: url
        });
    }
</script>

<jsp:include page="../common/footer.jsp" />
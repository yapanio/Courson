<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

            <!-- Request URI for Active State Highlighting -->
            <c:set var="reqUri" value="${pageContext.request.requestURI}" />
            <c:set var="isHome" value="${fn:endsWith(reqUri, '/home') || fn:endsWith(reqUri, '/')}" />
            <c:set var="isCourses"
                value="${fn:contains(reqUri, '/courses') && !fn:contains(reqUri, '/admin/courses')}" />
            <c:set var="isQuizzes" value="${fn:contains(reqUri, '/quizzes')}" />
            <c:set var="isMyRegistrations" value="${fn:contains(reqUri, '/registrations')}" />
            <c:set var="isExpert" value="${fn:contains(reqUri, '/expert')}" />
            <c:set var="isAdmin"
                value="${fn:contains(reqUri, '/admin') || fn:contains(reqUri, '/users') || fn:contains(reqUri, '/settings')}" />

            <style>
                /* ===================================================
CLOUDFLARE MODERN STREAMLINED NAVBAR
=================================================== */
                :root {
                    --cf-orange: #F38020;
                    --cf-orange-hover: #E56B00;
                    --cf-orange-light: #FFF5EB;
                    --cf-orange-border: #FCD5B5;
                    --cf-text-main: #1F2937;
                    --cf-text-muted: #6B7280;
                    --cf-border: #EAEDF1;
                    --cf-bg-hover: #F9FAFB;
                    --cf-shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.04);
                    --cf-shadow-dropdown: 0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.04);
                }

                /* Main Navbar Container */
                .cf-navbar {
                    background-color: rgba(255, 255, 255, 0.98);
                    backdrop-filter: blur(12px);
                    -webkit-backdrop-filter: blur(12px);
                    border-bottom: 1px solid var(--cf-border);
                    box-shadow: var(--cf-shadow-sm);
                    height: 64px;
                    position: sticky;
                    top: 0;
                    z-index: 1040;
                    padding: 0;
                }

                /* Brand Logo & Wordmark */
                .cf-brand {
                    display: inline-flex;
                    align-items: center;
                    gap: 10px;
                    text-decoration: none;
                    outline: none;
                }

                .cf-brand-name {
                    font-weight: 800;
                    font-size: 1.25rem;
                    letter-spacing: -0.5px;
                    color: #111827;
                    line-height: 1;
                }

                .cf-brand-name span {
                    color: var(--cf-orange);
                }

                .cf-brand-tag {
                    font-size: 10px;
                    font-weight: 700;
                    background: var(--cf-orange-light);
                    color: var(--cf-orange);
                    border: 1px solid var(--cf-orange-border);
                    padding: 1px 6px;
                    border-radius: 4px;
                    letter-spacing: 0.5px;
                    margin-left: 3px;
                    vertical-align: middle;
                }

                /* Navigation Links */
                .cf-nav-item {
                    position: relative;
                }

                .cf-nav-link {
                    font-size: 14px;
                    font-weight: 500;
                    color: var(--cf-text-main) !important;
                    padding: 21px 12px !important;
                    display: inline-flex;
                    align-items: center;
                    gap: 6px;
                    text-decoration: none;
                    border-bottom: 2px solid transparent;
                    transition: color 0.15s ease, border-color 0.15s ease;
                }

                .cf-nav-link:hover,
                .cf-nav-link.active,
                .cf-nav-item.show>.cf-nav-link {
                    color: var(--cf-orange) !important;
                    border-bottom-color: var(--cf-orange);
                }

                .cf-nav-link.active {
                    font-weight: 600;
                }

                .cf-nav-link .cf-chevron {
                    font-size: 11px;
                    color: #9CA3AF;
                    transition: transform 0.2s ease, color 0.15s ease;
                }

                .cf-nav-link:hover .cf-chevron,
                .cf-nav-item.show .cf-chevron {
                    transform: rotate(180deg);
                    color: var(--cf-orange);
                }

                /* Hover dropdown on Desktop */
                @media (min-width: 992px) {
                    .cf-hover-dropdown:hover>.cf-dropdown-menu {
                        display: block;
                    }

                    .cf-hover-dropdown>.cf-dropdown-menu::before {
                        content: '';
                        position: absolute;
                        top: -10px;
                        left: 0;
                        right: 0;
                        height: 10px;
                        background: transparent;
                    }

                    .cf-hover-dropdown:hover>.cf-nav-link {
                        color: var(--cf-orange) !important;
                        border-bottom-color: var(--cf-orange);
                    }

                    .cf-hover-dropdown:hover .cf-chevron {
                        transform: rotate(180deg);
                        color: var(--cf-orange);
                    }

                }

                /* Dropdown Menus */
                .cf-dropdown-menu {
                    border: 1px solid var(--cf-border);
                    border-radius: 10px;
                    box-shadow: var(--cf-shadow-dropdown);
                    padding: 8px;
                    margin-top: 2px;
                    background: #FFFFFF;
                    animation: cfFadeIn 0.15s ease;
                }

                @keyframes cfFadeIn {
                    from {
                        opacity: 0;
                        transform: translateY(4px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                .cf-dropdown-item {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    padding: 8px 12px;
                    font-size: 13.5px;
                    font-weight: 500;
                    color: #374151;
                    text-decoration: none;
                    border-radius: 6px;
                    transition: all 0.12s ease;
                }

                .cf-dropdown-item:hover {
                    background-color: var(--cf-bg-hover);
                    color: var(--cf-orange);
                }

                .cf-dropdown-item.text-danger:hover {
                    background-color: #FEF2F2;
                    color: #DC2626 !important;
                }

                /* Search Box with Ctrl+K */
                .cf-search-box {
                    position: relative;
                    width: 250px;
                }

                @media (min-width: 1200px) {
                    .cf-search-box {
                        width: 280px;
                    }
                }

                .cf-search-input {
                    width: 100%;
                    background-color: #F3F4F6;
                    border: 1px solid transparent;
                    border-radius: 6px;
                    padding: 6px 54px 6px 30px;
                    font-size: 13px;
                    color: #111827;
                    outline: none;
                    transition: all 0.15s ease;
                }

                .cf-search-input:focus {
                    background-color: #FFFFFF;
                    border-color: var(--cf-orange);
                    box-shadow: 0 0 0 3px rgba(243, 128, 32, 0.15);
                }

                .cf-search-input::placeholder {
                    color: #9CA3AF;
                    font-size: 12.5px;
                }

                .cf-search-icon {
                    position: absolute;
                    left: 9px;
                    top: 50%;
                    transform: translateY(-50%);
                    color: #9CA3AF;
                    font-size: 12px;
                    pointer-events: none;
                }

                .cf-kbd {
                    position: absolute;
                    right: 7px;
                    top: 50%;
                    transform: translateY(-50%);
                    background: #E5E7EB;
                    color: #6B7280;
                    font-size: 10px;
                    font-weight: 600;
                    padding: 2px 4px;
                    border-radius: 4px;
                    border: 1px solid #D1D5DB;
                    pointer-events: none;
                    font-family: inherit;
                }

                /* Cloudflare Buttons */
                .btn-cf-ghost {
                    color: #374151;
                    font-size: 13.5px;
                    font-weight: 600;
                    padding: 6px 14px;
                    border-radius: 6px;
                    text-decoration: none;
                    transition: all 0.15s ease;
                    display: inline-flex;
                    align-items: center;
                    gap: 6px;
                }

                .btn-cf-ghost:hover {
                    background-color: #F3F4F6;
                    color: #111827;
                }

                .btn-cf-primary {
                    background: var(--cf-orange);
                    color: #FFFFFF !important;
                    font-size: 13.5px;
                    font-weight: 600;
                    padding: 6px 16px;
                    border-radius: 6px;
                    border: 1px solid var(--cf-orange);
                    text-decoration: none;
                    box-shadow: 0 1px 2px rgba(243, 128, 32, 0.2);
                    transition: all 0.18s ease;
                    display: inline-flex;
                    align-items: center;
                    gap: 6px;
                }

                .btn-cf-primary:hover {
                    background: var(--cf-orange-hover);
                    border-color: var(--cf-orange-hover);
                    color: #FFFFFF !important;
                    transform: translateY(-1px);
                    box-shadow: 0 4px 8px rgba(243, 128, 32, 0.25);
                }

                .btn-cf-primary:active {
                    transform: translateY(0);
                }

                /* User Account Avatar & Pure Hover Dropdown */
                .cf-user-dropdown {
                    position: relative;
                    display: inline-flex;
                    align-items: center;
                }

                .cf-user-trigger {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    padding: 2px;
                    border-radius: 50%;
                    border: 2px solid transparent;
                    background: transparent;
                    cursor: pointer;
                    user-select: none;
                    transition: all 0.2s ease;
                }

                .cf-user-dropdown:hover .cf-user-trigger {
                    border-color: var(--cf-orange);
                    box-shadow: 0 0 0 3px rgba(243, 128, 32, 0.18);
                }

                .cf-avatar {
                    width: 34px;
                    height: 34px;
                    border-radius: 50%;
                    background: linear-gradient(135deg, var(--cf-orange), #FAAD3F);
                    color: #FFFFFF;
                    font-weight: 700;
                    font-size: 13.5px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    user-select: none;
                    transition: transform 0.15s ease;
                }

                .cf-user-dropdown:hover .cf-avatar {
                    transform: scale(1.04);
                }

                .cf-user-name {
                    font-size: 13px;
                    font-weight: 600;
                    color: #111827;
                    max-width: 120px;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                }

                /* Role Pill Badges */
                .cf-role-badge {
                    font-size: 10.5px;
                    font-weight: 600;
                    padding: 2px 7px;
                    border-radius: 12px;
                    letter-spacing: 0.2px;
                    text-transform: uppercase;
                }

                .cf-role-student {
                    background: #EFF6FF;
                    color: #2563EB;
                    border: 1px solid #BFDBFE;
                }

                .cf-role-expert {
                    background: #F5F3FF;
                    color: #7C3AED;
                    border: 1px solid #DDD6FE;
                }

                .cf-role-admin {
                    background: #FFF5EB;
                    color: #EA580C;
                    border: 1px solid #FED7AA;
                }

                .cf-role-manager {
                    background: #ECFDF5;
                    color: #059669;
                    border: 1px solid #A7F3D0;
                }

                /* Account Menu Header */
                .cf-account-menu {
                    position: absolute;
                    top: 100%;
                    right: 0 !important;
                    left: auto !important;
                    width: 250px;
                    border-radius: 10px;
                    padding: 6px;
                    margin-top: 6px;
                    display: none;
                    z-index: 1050;
                }

                .cf-user-dropdown:hover .cf-account-menu {
                    display: block;
                }

                .cf-account-menu::before {
                    content: '';
                    position: absolute;
                    top: -10px;
                    left: 0;
                    right: 0;
                    height: 10px;
                    background: transparent;
                }

                .cf-account-header {
                    padding: 10px 12px;
                    background: #F9FAFB;
                    border-radius: 6px;
                    margin-bottom: 6px;
                }

                /* Mobile Toggle */
                .cf-mobile-toggle {
                    border: 1px solid var(--cf-border);
                    background: #FFFFFF;
                    color: #374151;
                    padding: 5px 9px;
                    border-radius: 6px;
                    font-size: 1.2rem;
                }
            </style>

            <!-- MAIN CLOUDFLARE NAVBAR -->
            <nav class="cf-navbar navbar navbar-expand-lg">
                <div class="container">
                    <!-- 1. Brand Logo (Cloudflare Cloud Icon + Courson LMS) -->
                    <a class="cf-brand" href="${pageContext.request.contextPath}/home">
                        <svg width="34" height="23" viewBox="0 0 38 26" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path
                                d="M31.2 10.9C30.4 5.5 25.8 1.4 20.2 1.4C15.6 1.4 11.5 4.3 9.9 8.5C9.2 8.2 8.4 8.0 7.6 8.0C3.4 8.0 0 11.4 0 15.6C0 19.8 3.4 23.2 7.6 23.2H30.9C34.8 23.2 38 20.0 38 16.1C38 12.5 35.1 9.5 31.2 10.9Z"
                                fill="url(#cfNavGrad)" />
                            <path
                                d="M22.5 1.5C21.7 1.4 21.0 1.4 20.2 1.4C15.6 1.4 11.5 4.3 9.9 8.5C10.7 8.5 11.5 8.7 12.3 9.0C13.5 5.8 16.6 3.5 20.2 3.5C23.2 3.5 25.8 4.9 27.5 7.1C26.1 4.5 24.5 2.6 22.5 1.5Z"
                                fill="#FAAD3F" />
                            <defs>
                                <linearGradient id="cfNavGrad" x1="0" y1="0" x2="38" y2="24"
                                    gradientUnits="userSpaceOnUse">
                                    <stop stop-color="#FAAD3F" />
                                    <stop offset="0.45" stop-color="#F38020" />
                                    <stop offset="1" stop-color="#E56B00" />
                                </linearGradient>
                            </defs>
                        </svg>
                        <div class="d-flex align-items-center">
                            <span class="cf-brand-name">COURSON<span>.</span></span>
                            <span class="cf-brand-tag">LMS</span>
                        </div>
                    </a>

                    <!-- Mobile Drawer Toggle Button -->
                    <button class="cf-mobile-toggle d-lg-none" type="button" data-bs-toggle="offcanvas"
                        data-bs-target="#cfMobileDrawer" aria-controls="cfMobileDrawer">
                        <i class="bi bi-list"></i>
                    </button>

                    <!-- Desktop Navigation Items -->
                    <div class="collapse navbar-collapse d-none d-lg-flex" id="navbarNav">
                        <ul class="navbar-nav me-auto mb-2 mb-lg-0 align-items-center ms-lg-3">
                            <!-- 1. Trang chủ -->
                            <li class="nav-item cf-nav-item">
                                <a class="cf-nav-link ${isHome ? 'active' : ''}"
                                    href="${pageContext.request.contextPath}/home">
                                    <i class="bi bi-house-door"></i>
                                    <span>Trang chủ</span>
                                </a>
                            </li>

                            <!-- 2. Danh mục Khóa học -->
                            <li class="nav-item cf-nav-item">
                                <a class="cf-nav-link ${isCourses ? 'active' : ''}"
                                    href="${pageContext.request.contextPath}/courses/catalog">
                                    <i class="bi bi-collection"></i>
                                    <span>Khóa học</span>
                                </a>
                            </li>


                            <!-- ==============================================
         PHÂN QUYỀN RÕ RÀNG THEO TỪNG VAI TRÒ
         ============================================== -->
                            <c:if test="${sessionScope.CURRENT_USER != null}">
                                <!-- A. HỌC VIÊN (STUDENT) -->
                                <c:if test="${sessionScope.CURRENT_USER.roleName == 'STUDENT'}">
                                    <li class="nav-item cf-nav-item">
                                        <a class="cf-nav-link ${isMyRegistrations ? 'active' : ''}"
                                            href="${pageContext.request.contextPath}/registrations/my">
                                            <i class="bi bi-journal-bookmark text-primary"></i>
                                            <span>Khóa học của tôi</span>
                                        </a>
                                    </li>
                                </c:if>

                                <!-- B. CHUYÊN GIA (EXPERT) -->
                                <c:if test="${sessionScope.CURRENT_USER.roleName == 'EXPERT'}">
                                    <li class="nav-item cf-nav-item">
                                        <a class="cf-nav-link ${isExpert ? 'active' : ''}"
                                            href="${pageContext.request.contextPath}/expert/dashboard">
                                            <i class="bi bi-mortarboard" style="color: #7C3AED;"></i>
                                            <span>Expert Studio</span>
                                        </a>
                                    </li>
                                </c:if>

                                <!-- C. QUẢN TRỊ VIÊN & QUẢN LÝ (ADMIN / MANAGER) -->
                                <c:if
                                    test="${sessionScope.CURRENT_USER.roleName == 'ADMIN' || sessionScope.CURRENT_USER.roleName == 'MANAGER'}">
                                    <li class="nav-item cf-nav-item cf-hover-dropdown dropdown">
                                        <c:set var="dashboardPath"
                                            value="${sessionScope.CURRENT_USER.roleName == 'MANAGER' ? '/manager/dashboard' : '/admin/dashboard'}" />
                                        <c:set var="coursesPath"
                                            value="${sessionScope.CURRENT_USER.roleName == 'MANAGER' ? '/manager/courses' : '/admin/courses'}" />
                                        <a class="cf-nav-link dropdown-toggle ${isAdmin ? 'active' : ''}"
                                            href="${pageContext.request.contextPath}${dashboardPath}" role="button"
                                            data-bs-toggle="dropdown" aria-expanded="false">
                                            <i class="bi bi-shield-lock" style="color: #DC2626;"></i>
                                            <span>Quản trị hệ thống</span>
                                            <i class="bi bi-chevron-down cf-chevron"></i>
                                        </a>
                                        <ul class="dropdown-menu cf-dropdown-menu" style="min-width: 220px;">
                                            <li>
                                                <a class="cf-dropdown-item"
                                                    href="${pageContext.request.contextPath}${dashboardPath}">
                                                    <i class="bi bi-speedometer2 text-danger"></i> Dashboard Quản trị
                                                </a>
                                            </li>
                                            <li>
                                                <a class="cf-dropdown-item"
                                                    href="${pageContext.request.contextPath}${coursesPath}">
                                                    <i class="bi bi-collection text-primary"></i> Quản lý Khóa học
                                                </a>
                                            </li>
                                            <c:if test="${sessionScope.CURRENT_USER.roleName == 'ADMIN'}">
                                                <li>
                                                    <hr class="dropdown-divider my-1">
                                                </li>
                                                <li>
                                                    <a class="cf-dropdown-item"
                                                        href="${pageContext.request.contextPath}/users/list">
                                                        <i class="bi bi-people text-info"></i> Quản lý Người dùng
                                                    </a>
                                                </li>
                                                <li>
                                                    <a class="cf-dropdown-item"
                                                        href="${pageContext.request.contextPath}/settings/list">
                                                        <i class="bi bi-gear text-secondary"></i> Cấu hình hệ thống
                                                    </a>
                                                </li>
                                            </c:if>
                                        </ul>
                                    </li>
                                </c:if>
                            </c:if>
                        </ul>

                        <!-- Right Controls: Clean Search Box & Auth / Account -->
                        <div class="d-flex align-items-center gap-2">

                            <!-- Search Box -->
                            <form action="${pageContext.request.contextPath}/courses/catalog" method="GET"
                                class="cf-search-box me-1" role="search">
                                <i class="bi bi-search cf-search-icon"></i>
                                <input type="text" name="keyword" id="cfNavSearchInput" class="cf-search-input"
                                    placeholder="Tìm khóa học..." autocomplete="off">
                                <kbd class="cf-kbd">Ctrl K</kbd>
                            </form>

                            <!-- Auth Controls -->
                            <c:choose>
                                <c:when test="${sessionScope.CURRENT_USER != null}">
                                    <!-- Logged-in User Account Dropdown -->
                                    <c:set var="displayName"
                                        value="${not empty sessionScope.CURRENT_USER.fullName ? sessionScope.CURRENT_USER.fullName : sessionScope.CURRENT_USER.username}" />
                                    <c:set var="userInitial"
                                        value="${fn:toUpperCase(fn:substring(displayName, 0, 1))}" />

                                    <div class="cf-user-dropdown">
                                        <div class="cf-user-trigger">
                                            <c:choose>
                                                <c:when test="${not empty sessionScope.CURRENT_USER.avatarUrl}">
                                                    <img src="${pageContext.request.contextPath}${sessionScope.CURRENT_USER.avatarUrl}" class="cf-avatar navbar-avatar-img" style="object-fit: cover;" alt="Avatar" />
                                                    <div class="cf-avatar navbar-avatar-text" style="display: none;">${userInitial}</div>
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="" class="cf-avatar navbar-avatar-img" style="object-fit: cover; display: none;" alt="Avatar" />
                                                    <div class="cf-avatar navbar-avatar-text">${userInitial}</div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="cf-dropdown-menu cf-account-menu">
                                            <!-- User Summary -->
                                            <div class="cf-account-header">
                                                <div class="d-flex align-items-center gap-2 mb-1">
                                                    <c:choose>
                                                        <c:when test="${not empty sessionScope.CURRENT_USER.avatarUrl}">
                                                            <img src="${pageContext.request.contextPath}${sessionScope.CURRENT_USER.avatarUrl}"
                                                                class="cf-avatar navbar-avatar-img"
                                                                style="width: 34px; height: 34px; object-fit: cover;" alt="Avatar" />
                                                            <div class="cf-avatar navbar-avatar-text"
                                                                style="width: 34px; height: 34px; font-size: 14px; display: none;">
                                                                ${userInitial}
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src=""
                                                                class="cf-avatar navbar-avatar-img"
                                                                style="width: 34px; height: 34px; object-fit: cover; display: none;" alt="Avatar" />
                                                            <div class="cf-avatar navbar-avatar-text"
                                                                style="width: 34px; height: 34px; font-size: 14px;">
                                                                ${userInitial}
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div class="overflow-hidden">
                                                        <div class="fw-bold text-dark text-truncate">${displayName}
                                                        </div>
                                                        <div class="text-muted small text-truncate"
                                                            style="font-size: 11px;">
                                                            ${sessionScope.CURRENT_USER.email != null ?
                                                            sessionScope.CURRENT_USER.email :
                                                            sessionScope.CURRENT_USER.username}
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="mt-2">
                                                    <c:choose>
                                                        <c:when
                                                            test="${sessionScope.CURRENT_USER.roleName == 'STUDENT'}">
                                                            <span class="cf-role-badge cf-role-student"><i
                                                                    class="bi bi-mortarboard me-1"></i>Học viên</span>
                                                        </c:when>
                                                        <c:when
                                                            test="${sessionScope.CURRENT_USER.roleName == 'EXPERT'}">
                                                            <span class="cf-role-badge cf-role-expert"><i
                                                                    class="bi bi-person-badge me-1"></i>Chuyên
                                                                gia</span>
                                                        </c:when>
                                                        <c:when test="${sessionScope.CURRENT_USER.roleName == 'ADMIN'}">
                                                            <span class="cf-role-badge cf-role-admin"><i
                                                                    class="bi bi-shield-lock me-1"></i>Admin</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="cf-role-badge cf-role-manager"><i
                                                                    class="bi bi-briefcase me-1"></i>${sessionScope.CURRENT_USER.roleName}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- User Links -->
                                            <a class="cf-dropdown-item"
                                                href="${pageContext.request.contextPath}/profile">
                                                <i class="bi bi-person-circle text-primary"></i> Hồ sơ cá nhân
                                            </a>

                                            <c:if test="${sessionScope.CURRENT_USER.roleName == 'STUDENT'}">
                                                <a class="cf-dropdown-item"
                                                    href="${pageContext.request.contextPath}/registrations/my">
                                                    <i class="bi bi-journal-bookmark text-success"></i> Khóa học của tôi
                                                </a>
                                            </c:if>

                                            <c:if test="${sessionScope.CURRENT_USER.roleName == 'EXPERT'}">
                                                <a class="cf-dropdown-item"
                                                    href="${pageContext.request.contextPath}/expert/dashboard">
                                                    <i class="bi bi-speedometer2 text-purple"></i> Expert Dashboard
                                                </a>
                                            </c:if>

                                            <c:if test="${sessionScope.CURRENT_USER.roleName == 'ADMIN'}">
                                                <a class="cf-dropdown-item"
                                                    href="${pageContext.request.contextPath}/admin/dashboard">
                                                    <i class="bi bi-speedometer2 text-danger"></i> Admin Dashboard
                                                </a>
                                            </c:if>

                                            <c:if test="${sessionScope.CURRENT_USER.roleName == 'MANAGER'}">
                                                <a class="cf-dropdown-item"
                                                    href="${pageContext.request.contextPath}/manager/dashboard">
                                                    <i class="bi bi-speedometer2 text-primary"></i> Manager Dashboard
                                                </a>
                                            </c:if>

                                            <div class="dropdown-divider my-1"></div>

                                            <a class="cf-dropdown-item text-danger"
                                                href="${pageContext.request.contextPath}/auth/logout">
                                                <i class="bi bi-box-arrow-right"></i> Đăng xuất
                                            </a>
                                        </div>
                                    </div>
                                </c:when>

                                <c:otherwise>
                                    <!-- Guest State -->
                                    <a class="btn-cf-ghost" href="${pageContext.request.contextPath}/auth/login">
                                        Đăng nhập
                                    </a>
                                    <a class="btn-cf-primary" href="${pageContext.request.contextPath}/auth/register">
                                        Bắt đầu ngay <i class="bi bi-arrow-right"></i>
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </nav>

            <!-- MOBILE OFFCANVAS DRAWER -->
            <div class="offcanvas offcanvas-start" tabindex="-1" id="cfMobileDrawer"
                aria-labelledby="cfMobileDrawerLabel" style="width: 290px;">
                <div class="offcanvas-header border-bottom py-3">
                    <a class="cf-brand" href="${pageContext.request.contextPath}/home">
                        <svg width="28" height="20" viewBox="0 0 38 26" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path
                                d="M31.2 10.9C30.4 5.5 25.8 1.4 20.2 1.4C15.6 1.4 11.5 4.3 9.9 8.5C9.2 8.2 8.4 8.0 7.6 8.0C3.4 8.0 0 11.4 0 15.6C0 19.8 3.4 23.2 7.6 23.2H30.9C34.8 23.2 38 20.0 38 16.1C38 12.5 35.1 9.5 31.2 10.9Z"
                                fill="url(#cfNavGradMob)" />
                            <defs>
                                <linearGradient id="cfNavGradMob" x1="0" y1="0" x2="38" y2="24"
                                    gradientUnits="userSpaceOnUse">
                                    <stop stop-color="#FAAD3F" />
                                    <stop offset="0.45" stop-color="#F38020" />
                                    <stop offset="1" stop-color="#E56B00" />
                                </linearGradient>
                            </defs>
                        </svg>
                        <div class="d-flex align-items-center">
                            <span class="cf-brand-name fs-6">COURSON<span>.</span></span>
                            <span class="cf-brand-tag">LMS</span>
                        </div>
                    </a>
                    <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Đóng"></button>
                </div>

                <div class="offcanvas-body d-flex flex-column justify-content-between p-3">
                    <div>
                        <!-- Search -->
                        <form action="${pageContext.request.contextPath}/courses/catalog" method="GET" class="mb-3">
                            <div class="position-relative">
                                <i class="bi bi-search position-absolute top-50 start-0 translate-middle-y ms-3 text-muted"
                                    style="font-size: 12px;"></i>
                                <input type="text" name="keyword"
                                    class="form-control form-control-sm rounded-2 ps-5 py-2"
                                    placeholder="Tìm khóa học...">
                            </div>
                        </form>

                        <!-- Links -->
                        <div class="list-group list-group-flush">
                            <a href="${pageContext.request.contextPath}/home"
                                class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2 px-2 border-0 rounded-2 ${isHome ? 'fw-bold text-warning' : ''}">
                                <i class="bi bi-house-door text-muted"></i> Trang chủ
                            </a>
                            <a href="${pageContext.request.contextPath}/courses/catalog"
                                class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2 px-2 border-0 rounded-2 ${isCourses ? 'fw-bold text-warning' : ''}">
                                <i class="bi bi-collection text-primary"></i> Khóa học
                            </a>

                            <!-- Role Section on Mobile -->
                            <c:if test="${sessionScope.CURRENT_USER != null}">
                                <div class="text-uppercase text-muted fw-bold px-2 mt-3 mb-1" style="font-size: 11px;">
                                    Khu vực chức năng</div>

                                <c:if test="${sessionScope.CURRENT_USER.roleName == 'STUDENT'}">
                                    <a href="${pageContext.request.contextPath}/registrations/my"
                                        class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2 px-2 border-0 rounded-2 ${isMyRegistrations ? 'fw-bold text-warning' : ''}">
                                        <i class="bi bi-journal-bookmark text-success"></i> Khóa học của tôi
                                    </a>
                                </c:if>

                                <c:if test="${sessionScope.CURRENT_USER.roleName == 'EXPERT'}">
                                    <a href="${pageContext.request.contextPath}/expert/dashboard"
                                        class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2 px-2 border-0 rounded-2 ${isExpert ? 'fw-bold text-warning' : ''}">
                                        <i class="bi bi-mortarboard text-primary"></i> Expert Studio
                                    </a>
                                </c:if>

                                <c:if
                                    test="${sessionScope.CURRENT_USER.roleName == 'ADMIN' || sessionScope.CURRENT_USER.roleName == 'MANAGER'}">
                                    <a href="${pageContext.request.contextPath}/admin/dashboard"
                                        class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2 px-2 border-0 rounded-2 ${isAdmin ? 'fw-bold text-warning' : ''}">
                                        <i class="bi bi-speedometer2 text-danger"></i> Dashboard Quản trị
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/courses"
                                        class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2 px-2 border-0 rounded-2">
                                        <i class="bi bi-collection text-primary"></i> Quản lý Khóa học
                                    </a>
                                    <c:if test="${sessionScope.CURRENT_USER.roleName == 'ADMIN'}">
                                        <a href="${pageContext.request.contextPath}/users/list"
                                            class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2 px-2 border-0 rounded-2">
                                            <i class="bi bi-people text-info"></i> Quản lý Người dùng
                                        </a>
                                        <a href="${pageContext.request.contextPath}/settings/list"
                                            class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2 px-2 border-0 rounded-2">
                                            <i class="bi bi-gear text-secondary"></i> Cấu hình hệ thống
                                        </a>
                                    </c:if>
                                </c:if>
                            </c:if>
                        </div>
                    </div>

                    <!-- Mobile Bottom Auth / User Section -->
                    <div class="border-top pt-3">
                        <c:choose>
                            <c:when test="${sessionScope.CURRENT_USER != null}">
                                <div class="d-flex align-items-center gap-2 mb-3">
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.CURRENT_USER.avatarUrl}">
                                            <img src="${pageContext.request.contextPath}${sessionScope.CURRENT_USER.avatarUrl}" class="cf-avatar navbar-avatar-img" style="object-fit: cover;" alt="Avatar" />
                                            <div class="cf-avatar navbar-avatar-text" style="display: none;">${userInitial}</div>
                                        </c:when>
                                        <c:otherwise>
                                            <img src="" class="cf-avatar navbar-avatar-img" style="object-fit: cover; display: none;" alt="Avatar" />
                                            <div class="cf-avatar navbar-avatar-text">${userInitial}</div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="overflow-hidden">
                                        <div class="fw-bold text-dark text-truncate small">${displayName}</div>
                                        <span class="cf-role-badge cf-role-student py-0 px-2"
                                            style="font-size: 10px;">${sessionScope.CURRENT_USER.roleName}</span>
                                    </div>
                                </div>
                                <div class="d-grid gap-2">
                                    <a href="${pageContext.request.contextPath}/profile"
                                        class="btn btn-outline-secondary btn-sm">
                                        <i class="bi bi-person me-1"></i>Hồ sơ cá nhân
                                    </a>
                                    <a href="${pageContext.request.contextPath}/auth/logout"
                                        class="btn btn-outline-danger btn-sm">
                                        <i class="bi bi-box-arrow-right me-1"></i>Đăng xuất
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="d-grid gap-2">
                                    <a href="${pageContext.request.contextPath}/auth/login"
                                        class="btn btn-outline-secondary btn-sm">
                                        Đăng nhập
                                    </a>
                                    <a href="${pageContext.request.contextPath}/auth/register"
                                        class="btn btn-cf-primary btn-sm justify-content-center">
                                        Bắt đầu ngay <i class="bi bi-arrow-right"></i>
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- KEYBOARD SHORTCUT SCRIPT (Ctrl+K) -->
            <script>
                (function () {
                    document.addEventListener('keydown', function (e) {
                        if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
                            e.preventDefault();
                            var searchInput = document.getElementById('cfNavSearchInput');
                            if (searchInput) {
                                searchInput.focus();
                                searchInput.select();
                            }
                        }
                    });
                })();
            </script>
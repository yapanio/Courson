<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Courson LMS - Nền tảng học trực tuyến thông minh" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<style>
    :root {
        --brand-orange: #F38020;
        --brand-orange-hover: #E56B00;
        --brand-orange-soft: #FFF7ED;
        --brand-orange-border: #FFEDD5;
        --text-heading: #111827;
        --text-body: #4B5563;
        --text-muted: #6B7280;
        --border-color: #E5E7EB;
        --bg-card: #FFFFFF;
    }

    body {
        background-color: #FFFFFF !important;
    }

    .cf-navbar {
        position: sticky !important;
        top: 0 !important;
        z-index: 1040 !important;
        background-color: rgba(255, 255, 255, 0.96) !important;
        backdrop-filter: blur(12px) !important;
        -webkit-backdrop-filter: blur(12px) !important;
    }

    .eyebrow-tag {
        font-size: 0.78rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        color: var(--brand-orange);
        margin-bottom: 8px;
        display: inline-block;
    }

    .hero-section {
        padding: 56px 0 64px;
        background-color: #FFFFFF;
    }
    .hero-headline {
        font-size: 2.85rem;
        font-weight: 800;
        line-height: 1.15;
        color: var(--text-heading);
        letter-spacing: -0.6px;
        margin-bottom: 18px;
    }
    .hero-headline span.text-brand {
        color: var(--brand-orange);
    }
    .hero-sub {
        font-size: 1.05rem;
        color: var(--text-body);
        line-height: 1.65;
        margin-bottom: 32px;
        max-width: 520px;
    }
    .hero-actions {
        display: flex;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
    }
    .btn-pill-primary {
        background-color: var(--brand-orange);
        color: #fff !important;
        border: none;
        border-radius: 9999px;
        padding: 12px 26px;
        font-weight: 700;
        font-size: 0.92rem;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        transition: all 0.2s ease;
        box-shadow: 0 4px 12px rgba(243, 128, 32, 0.25);
    }
    .btn-pill-primary:hover {
        background-color: var(--brand-orange-hover);
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(243, 128, 32, 0.35);
    }
    .btn-pill-ghost {
        color: var(--text-heading) !important;
        font-weight: 600;
        font-size: 0.92rem;
        text-decoration: none;
        padding: 12px 16px;
        border-radius: 9999px;
        transition: color 0.15s ease;
    }
    .btn-pill-ghost:hover {
        color: var(--brand-orange) !important;
    }

    .hero-card-container {
        background-color: #FFF7ED;
        border: 1px solid #FFEDD5;
        border-radius: 28px;
        padding: 32px;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 330px;
        position: relative;
    }
    .hero-terminal-card {
        background-color: #141416;
        border: 1px solid #262626;
        border-radius: 18px;
        padding: 24px;
        width: 100%;
        max-width: 380px;
        color: #fff;
        box-shadow: 0 20px 35px -10px rgba(0, 0, 0, 0.25);
    }
    .terminal-dots {
        display: flex;
        gap: 6px;
        margin-bottom: 20px;
    }
    .terminal-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background-color: #404040;
    }
    .terminal-dot.active {
        background-color: var(--brand-orange);
    }
    .terminal-icon-box {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        background-color: rgba(243, 128, 32, 0.15);
        color: var(--brand-orange);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.35rem;
        margin-bottom: 16px;
    }
    .terminal-title {
        font-size: 1.1rem;
        font-weight: 700;
        margin-bottom: 6px;
        color: #fff;
    }
    .terminal-desc {
        font-size: 0.84rem;
        color: #A3A3A3;
        line-height: 1.5;
        margin-bottom: 20px;
    }
    .terminal-bars {
        display: flex;
        gap: 6px;
    }
    .terminal-bar {
        height: 4px;
        flex: 1;
        border-radius: 9999px;
        background-color: #262626;
    }
    .terminal-bar.filled {
        background-color: var(--brand-orange);
    }

    .topics-section {
        padding: 44px 0 54px;
        background-color: #FAFAFA;
        border-top: 1px solid #F3F4F6;
        border-bottom: 1px solid #F3F4F6;
    }
    .section-header-row {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-bottom: 24px;
    }
    .section-title {
        font-size: 1.85rem;
        font-weight: 800;
        color: var(--text-heading);
        letter-spacing: -0.4px;
        margin: 0;
    }
    .section-link {
        font-size: 0.88rem;
        font-weight: 700;
        color: var(--brand-orange) !important;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: gap 0.2s;
    }
    .section-link:hover {
        color: var(--brand-orange-hover) !important;
        gap: 9px;
    }
    .topic-pills-row {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
    }
    .topic-pill {
        background-color: #FFFFFF;
        border: 1px solid var(--border-color);
        border-radius: 10px;
        padding: 10px 20px;
        font-size: 0.88rem;
        font-weight: 600;
        color: var(--text-heading);
        text-decoration: none;
        transition: all 0.18s ease;
    }
    .topic-pill:hover {
        border-color: var(--brand-orange);
        background-color: #FFFBF7;
        color: var(--brand-orange);
        transform: translateY(-1px);
    }

    .featured-section {
        padding: 64px 0 74px;
        background-color: #FFFFFF;
    }
    .course-card-custom {
        background-color: var(--bg-card);
        border: 1px solid var(--border-color);
        border-radius: 16px;
        overflow: hidden;
        display: flex;
        flex-direction: column;
        height: 100%;
        text-decoration: none;
        transition: all 0.22s ease-in-out;
    }
    .course-card-custom:hover {
        transform: translateY(-4px);
        border-color: #FCD5B5;
        box-shadow: 0 14px 28px -8px rgba(0, 0, 0, 0.08);
    }
    .course-thumb-box {
        width: 100%;
        height: 185px;
        overflow: hidden;
        background-color: #F3F4F6;
        position: relative;
    }
    .course-thumb-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s ease;
    }
    .course-card-custom:hover .course-thumb-img {
        transform: scale(1.03);
    }
    .course-body-custom {
        padding: 20px;
        display: flex;
        flex-direction: column;
        flex: 1;
    }
    .course-category-tag {
        font-size: 0.72rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        color: var(--brand-orange);
        margin-bottom: 8px;
    }
    .course-title-custom {
        font-size: 1.05rem;
        font-weight: 700;
        color: var(--text-heading);
        line-height: 1.35;
        margin-bottom: 8px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        min-height: 44px;
    }
    .course-expert-name {
        font-size: 0.82rem;
        color: var(--text-muted);
        margin-bottom: 6px;
    }
    .course-meta-text {
        font-size: 0.8rem;
        color: var(--text-muted);
        margin-bottom: 16px;
    }
    .course-footer-custom {
        margin-top: auto;
        padding-top: 14px;
        border-top: 1px solid #F3F4F6;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .course-price-custom {
        font-size: 1.05rem;
        font-weight: 800;
        color: var(--text-heading);
    }
    .course-view-link {
        font-size: 0.85rem;
        font-weight: 700;
        color: var(--brand-orange);
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    .values-section {
        padding: 64px 0 64px;
        background-color: #FAFAFA;
        border-top: 1px solid #F3F4F6;
    }
    .value-card-custom {
        background-color: #FFFFFF;
        border: 1px solid var(--border-color);
        border-radius: 16px;
        padding: 28px;
        height: 100%;
        transition: all 0.2s ease;
    }
    .value-card-custom:hover {
        border-color: #FCD5B5;
        box-shadow: 0 8px 20px -6px rgba(243, 128, 32, 0.12);
        transform: translateY(-2px);
    }
    .value-icon-box {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        background-color: var(--brand-orange-soft);
        border: 1px solid var(--brand-orange-border);
        color: var(--brand-orange);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.35rem;
        margin-bottom: 18px;
    }
    .value-title {
        font-size: 1.15rem;
        font-weight: 700;
        color: var(--text-heading);
        margin-bottom: 8px;
    }
    .value-desc {
        font-size: 0.88rem;
        color: var(--text-body);
        line-height: 1.55;
        margin: 0;
    }

    .cta-banner-wrapper {
        padding: 0 0 74px;
        background-color: #FAFAFA;
    }
    .cta-banner-dark {
        background-color: #111827;
        border-radius: 20px;
        padding: 38px 48px;
        color: #FFFFFF;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 24px;
        box-shadow: 0 16px 32px -8px rgba(0, 0, 0, 0.2);
    }
    .cta-banner-title {
        font-size: 1.65rem;
        font-weight: 800;
        margin-bottom: 6px;
        color: #fff;
    }
    .cta-banner-sub {
        font-size: 0.95rem;
        color: #9CA3AF;
        margin: 0;
    }
</style>

<main class="main-content">

    <section class="hero-section">
        <div class="container">
            <div class="row align-items-center g-5">

                <div class="col-lg-7">
                    <c:choose>
                        <c:when test="${sessionScope.CURRENT_USER != null}">
                            <span class="eyebrow-tag">CHÀO MỪNG BẠN QUAY TRỞ LẠI</span>
                            <h1 class="hero-headline">
                                Tiếp tục học tập cùng <span class="text-brand">Courson.</span>
                            </h1>
                            <p class="hero-sub">
                                Xin chào <strong>${not empty sessionScope.CURRENT_USER.fullName ? sessionScope.CURRENT_USER.fullName : sessionScope.CURRENT_USER.username}</strong>! Hãy tiếp tục các bài giảng, kiểm tra tiến độ và tích lũy chứng chỉ kỹ năng ngay hôm nay.
                            </p>
                            <div class="hero-actions">
                                <c:choose>
                                    <c:when test="${sessionScope.CURRENT_USER.roleName == 'STUDENT'}">
                                        <a href="${pageContext.request.contextPath}/registrations/my" class="btn-pill-primary">
                                            Khóa học của tôi <i class="bi bi-arrow-right"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/courses/catalog" class="btn-pill-ghost">
                                            Khám phá thêm khóa học
                                        </a>
                                    </c:when>
                                    <c:when test="${sessionScope.CURRENT_USER.roleName == 'EXPERT'}">
                                        <a href="${pageContext.request.contextPath}/expert/dashboard" class="btn-pill-primary">
                                            Expert Studio <i class="bi bi-arrow-right"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/courses/catalog" class="btn-pill-ghost">
                                            Xem danh mục khóa học
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-pill-primary">
                                            Trang Quản trị <i class="bi bi-arrow-right"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/courses/catalog" class="btn-pill-ghost">
                                            Xem danh mục khóa học
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <span class="eyebrow-tag">LEARN YOUR WAY</span>
                            <h1 class="hero-headline">
                                Bắt đầu hành trình học tập cùng <span class="text-brand">Courson.</span>
                            </h1>
                            <p class="hero-sub">
                                Khám phá các khóa học thực chiến chuẩn đại học & quốc tế, học từng bài theo tiến độ riêng và làm chủ kỹ năng số trong tầm tay.
                            </p>
                            <div class="hero-actions">
                                <a href="${pageContext.request.contextPath}/courses/catalog" class="btn-pill-primary">
                                    Khám phá khóa học <i class="bi bi-arrow-right"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/auth/register" class="btn-pill-ghost">
                                    Tạo tài khoản miễn phí
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="col-lg-5">
                    <div class="hero-card-container">
                        <div class="hero-terminal-card">
                            <div class="terminal-dots">
                                <div class="terminal-dot active"></div>
                                <div class="terminal-dot"></div>
                                <div class="terminal-dot"></div>
                            </div>
                            <div class="terminal-icon-box">
                                <i class="bi bi-laptop"></i>
                            </div>
                            <h3 class="terminal-title">Học qua thực hành</h3>
                            <p class="terminal-desc">
                                Bài học thực tế, bài kiểm tra tương tác và trang bị kỹ năng ứng dụng doanh nghiệp chuẩn đầu ra.
                            </p>
                            <div class="terminal-bars">
                                <div class="terminal-bar filled"></div>
                                <div class="terminal-bar"></div>
                                <div class="terminal-bar"></div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <section class="topics-section">
        <div class="container">
            <div class="section-header-row">
                <div>
                    <span class="eyebrow-tag">KHÁM PHÁ THEO CHỦ ĐỀ</span>
                    <h2 class="section-title">Bạn muốn học gì tiếp theo?</h2>
                </div>
                <a href="${pageContext.request.contextPath}/courses/catalog" class="section-link">
                    Tất cả khóa học <i class="bi bi-arrow-right"></i>
                </a>
            </div>

            <div class="topic-pills-row">
                <c:choose>
                    <c:when test="${not empty categories}">
                        <c:forEach var="cat" items="${categories}">
                            <a href="${pageContext.request.contextPath}/courses/catalog?categoryId=${cat.id}" class="topic-pill">
                                <c:out value="${cat.name}"/>
                            </a>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=Nhân+Tướng" class="topic-pill">
                            Nhân tướng học & Nhân trắc học
                        </a>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=Tử+Vi" class="topic-pill">
                            Tử Vi & Phong Thủy
                        </a>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=Cung+Hoàng+Đạo" class="topic-pill">
                            Chiêm Tinh & Cung Hoàng Đạo
                        </a>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=Web" class="topic-pill">
                            Phát triển Web Fullstack
                        </a>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=Data" class="topic-pill">
                            Trí tuệ nhân tạo & Data
                        </a>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=SQL" class="topic-pill">
                            Cơ sở dữ liệu & Tối ưu hóa
                        </a>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=Java" class="topic-pill">
                            Lập trình Cốt lõi
                        </a>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=Cloud" class="topic-pill">
                            DevOps & Điện toán Đám mây
                        </a>
                        <a href="${pageContext.request.contextPath}/courses/catalog?keyword=Mobile" class="topic-pill">
                            Lập trình Mobile
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>

    <section class="featured-section">
        <div class="container">
            <div class="section-header-row">
                <div>
                    <span class="eyebrow-tag">BẮT ĐẦU KHÁM PHÁ</span>
                    <h2 class="section-title">Khóa học nổi bật</h2>
                    <p class="text-muted small mb-0 mt-1">Tìm khóa học phù hợp với mục tiêu và thời gian biểu của bạn.</p>
                </div>
                <a href="${pageContext.request.contextPath}/courses/catalog" class="section-link">
                    Xem tất cả khóa học <i class="bi bi-arrow-right"></i>
                </a>
            </div>

            <c:choose>
                <c:when test="${empty courses}">
                    <div class="text-center py-5 bg-light rounded-3 border">
                        <i class="bi bi-journal-x fs-1 text-muted"></i>
                        <p class="text-muted mt-2 mb-0">Chưa có khóa học nào được xuất bản.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                        <c:forEach var="c" items="${courses}" begin="0" end="2">
                            <c:set var="targetCourseUrl" value="${pageContext.request.contextPath}/courses/detail?id=${c.id}" />
                            <c:set var="targetCourseCta" value="Xem khóa học" />
                            <c:set var="targetCourseIcon" value="bi-arrow-right" />
                            <c:if test="${sessionScope.CURRENT_USER.roleName == 'EXPERT'}">
                                <c:set var="targetCourseUrl" value="${pageContext.request.contextPath}/expert/lessons?courseId=${c.id}" />
                                <c:set var="targetCourseCta" value="Quản lý bài học" />
                                <c:set var="targetCourseIcon" value="bi-pencil-square" />
                            </c:if>
                            <c:if test="${sessionScope.CURRENT_USER.roleName == 'ADMIN' || sessionScope.CURRENT_USER.roleName == 'MANAGER'}">
                                <c:set var="targetCourseUrl" value="${pageContext.request.contextPath}/admin/course-detail?id=${c.id}" />
                                <c:set var="targetCourseCta" value="Quản trị khóa học" />
                                <c:set var="targetCourseIcon" value="bi-gear-fill" />
                            </c:if>

                            <div class="col">
                                <a href="${targetCourseUrl}" class="course-card-custom">
                                    <div class="course-thumb-box">
                                        <img src="${c.thumbnailUrl}" class="course-thumb-img" alt="${c.title}"
                                             onerror="this.src='https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&auto=format&fit=crop&q=60'">
                                    </div>
                                    <div class="course-body-custom">
                                        <div class="course-category-tag">
                                            <c:out value="${c.categoryName != null ? c.categoryName : 'LẬP TRÌNH CỐT LÕI'}" />
                                        </div>
                                        <h3 class="course-title-custom" title="${c.title}">
                                            <c:out value="${c.title}" />
                                        </h3>
                                        <div class="course-expert-name">
                                            <i class="bi bi-person me-1"></i><c:out value="${c.expertName != null ? c.expertName : 'Expert'}" />
                                        </div>
                                        <div class="course-meta-text">
                                            ${fn:length(c.modules)} modules &bull; ${c.totalLessons} bài học
                                        </div>

                                        <div class="course-footer-custom">
                                            <div class="course-price-custom">
                                                <c:choose>
                                                    <c:when test="${c.price <= 0}">
                                                        <span class="text-success">Miễn phí</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        &#8363;<fmt:formatNumber value="${c.price}" pattern="#,###"/>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <span class="course-view-link">
                                                ${targetCourseCta} <i class="bi ${targetCourseIcon}"></i>
                                            </span>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <section class="values-section">
        <div class="container">
            <div class="mb-4">
                <span class="eyebrow-tag">HỌC THEO CÁCH CỦA BẠN</span>
                <h2 class="section-title">Tối ưu từng bước học tập</h2>
                <p class="text-muted small mt-1 mb-0">Từ bài học đầu tiên đến thực hành tự tin với hệ thống học tập toàn diện.</p>
            </div>

            <div class="row row-cols-1 row-cols-md-3 g-4">
                <div class="col">
                    <div class="value-card-custom">
                        <div class="value-icon-box">
                            <i class="bi bi-play-circle-fill"></i>
                        </div>
                        <h4 class="value-title">Học theo tiến độ riêng</h4>
                        <p class="value-desc">
                            Chủ động học mọi bài giảng video chất lượng cao bất kỳ khi nào phù hợp với lịch trình bận rộn của bạn.
                        </p>
                    </div>
                </div>

                <div class="col">
                    <div class="value-card-custom">
                        <div class="value-icon-box">
                            <i class="bi bi-check2-circle"></i>
                        </div>
                        <h4 class="value-title">Luyện tập thực chiến</h4>
                        <p class="value-desc">
                            Hệ thống kiểm tra trắc nghiệm Quiz trực tiếp sau mỗi module giúp đánh giá và củng cố kiến thức vững chắc.
                        </p>
                    </div>
                </div>

                <div class="col">
                    <div class="value-card-custom">
                        <div class="value-icon-box">
                            <i class="bi bi-graph-up-arrow"></i>
                        </div>
                        <h4 class="value-title">Theo dõi tiến trình</h4>
                        <p class="value-desc">
                            Dễ dàng kiểm soát tỉ lệ hoàn thành từng chương học và sẵn sàng tự tin bước vào môi trường doanh nghiệp.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="cta-banner-wrapper">
        <div class="container">
            <div class="cta-banner-dark">
                <div>
                    <h3 class="cta-banner-title">Sẵn sàng bắt đầu chưa?</h3>
                    <p class="cta-banner-sub">Tìm khóa học ưng ý và nâng tầm kỹ năng lập trình của bạn ngay hôm nay.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/courses/catalog" class="btn-pill-primary">
                        Khám phá khóa học <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </section>
</main>

<jsp:include page="../common/footer.jsp" />
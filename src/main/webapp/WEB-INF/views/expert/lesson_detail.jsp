<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Soạn thảo bài học - Courson LMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<!-- Quill WYSIWYG Editor CSS -->
<link href="https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.snow.css" rel="stylesheet">

<style>
    .ql-toolbar.ql-snow {
        border-top-left-radius: 8px;
        border-top-right-radius: 8px;
        border-color: #dee2e6;
        background-color: #f8f9fa;
        padding: 8px 12px;
    }
    .ql-container.ql-snow {
        border-bottom-left-radius: 8px;
        border-bottom-right-radius: 8px;
        border-color: #dee2e6;
        font-family: inherit;
        font-size: 15px;
        background-color: #ffffff;
    }
    .ql-editor {
        min-height: 200px;
        max-height: 480px;
        overflow-y: auto;
        line-height: 1.7;
    }
    .ql-editor.ql-blank::before {
        color: #adb5bd;
        font-style: normal;
    }
</style>

<main class="main-content py-5">
    <div class="container">
        <!-- Breadcrumb -->
        <nav class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/expert/dashboard">Expert Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/expert/lessons?courseId=${course.id}">${course.title}</a></li>
                <li class="breadcrumb-item active">${lesson != null ? 'Chỉnh sửa bài học' : 'Thêm bài học mới'}</li>
            </ol>
        </nav>

        <div class="row justify-content-center">
            <div class="col-lg-9">
                <div class="card border-0 shadow-sm rounded-3 p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                        <div>
                            <h4 class="fw-bold mb-1">
                                <i class="bi bi-pencil-square text-primary me-2"></i>
                                ${lesson != null ? 'Chỉnh sửa bài học' : 'Thêm bài học mới'}
                            </h4>
                            <p class="text-muted small mb-0">Nhập tiêu đề, tài liệu học tập và đường dẫn video bài giảng</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${course.id}" class="btn btn-outline-secondary btn-sm">
                            <i class="bi bi-arrow-left me-1"></i>Quay lại
                        </a>
                    </div>

                    <c:set var="displayError" value="${not empty errorMessage ? errorMessage : param.error}" />
                    <c:if test="${not empty displayError}">
                        <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${displayError}" escapeXml="true" />
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Container thông báo khôi phục bản nháp tự động -->
                    <div id="draftRecoveryAlertContainer"></div>

                    <form action="${pageContext.request.contextPath}/expert/save-lesson" method="POST" id="lessonForm">
                        <input type="hidden" name="courseId" id="lessonCourseId" value="${course.id}">
                        <c:if test="${lesson != null}">
                            <input type="hidden" name="id" id="lessonId" value="${lesson.id}">
                        </c:if>

                        <c:set var="curModId" value="${selectedModuleId != null ? selectedModuleId : (lesson != null ? lesson.moduleId : '')}" />
                        <div class="mb-3">
                            <label class="form-label small fw-semibold mb-1" for="lessonModuleId">
                                <i class="bi bi-folder2-open text-primary me-1"></i>Thuộc Chương học (Module) <span class="text-danger">*</span>
                            </label>
                            <c:choose>
                                <c:when test="${not empty course.modules}">
                                    <select name="moduleId" id="lessonModuleId" class="form-select saas-form-control" required onchange="handleModuleSelectChange(this.value)">
                                        <c:forEach var="moduleItem" items="${course.modules}">
                                            <option value="${moduleItem.id}" ${moduleItem.id == curModId ? 'selected' : ''}>
                                                Chương ${moduleItem.orderIndex}: ${moduleItem.title}
                                            </option>
                                        </c:forEach>
                                        <option value="__NEW__" class="fw-bold text-primary">+ Tạo Chương học mới...</option>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <input type="hidden" name="moduleId" id="lessonModuleId" value="__NEW__">
                                </c:otherwise>
                            </c:choose>

                            <!-- Nhập tên chương mới nếu chọn tạo chương mới hoặc khóa học chưa có chương nào -->
                            <div id="newModuleInputGroup" class="mt-2 ${empty course.modules ? '' : 'd-none'}">
                                <div class="input-group">
                                    <span class="input-group-text bg-light small"><i class="bi bi-folder-plus text-primary"></i></span>
                                    <input type="text" name="newModuleTitle" id="newModuleTitle" class="form-control"
                                           placeholder="Nhập tên chương học mới..."
                                           value="${empty course.modules ? 'Chương 1: Khởi động & Giới thiệu' : ''}">
                                </div>
                            </div>
                        </div>

                        <input type="hidden" name="orderIndex" id="lessonOrderIndex" value="${lesson != null ? lesson.orderIndex : (course.totalLessons + 1)}">

                        <div class="row g-3 mb-3">
                            <div class="col-md-8">
                                <label class="form-label small fw-semibold">Tiêu đề bài học <span class="text-danger">*</span></label>
                                <input type="text" name="title" id="lessonTitle" class="form-control" value="${lesson != null ? lesson.title : ''}" required placeholder="Ví dụ: Giới thiệu cú pháp Java cơ bản">
                                <div id="titleFetchFeedback" class="mt-1 small" style="display: none;"></div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-semibold">
                                    <i class="bi bi-eye text-primary me-1"></i>Trạng thái hiển thị
                                </label>
                                <select name="isActive" class="form-select">
                                    <option value="true" ${lesson == null || lesson.active ? 'selected' : ''}>Hiển thị (Công khai)</option>
                                    <option value="false" ${lesson != null && !lesson.active ? 'selected' : ''}>Tạm ẩn (Không công khai)</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <label class="form-label small fw-semibold mb-0"><i class="bi bi-youtube text-danger me-1"></i>URL Video bài giảng (YouTube hoặc MP4)</label>
                                <span class="text-muted small" style="font-size: 11px;"><i class="bi bi-lightning-charge text-warning me-1"></i>Tự động điền tiêu đề khi nhập link</span>
                            </div>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-link-45deg"></i></span>
                                <input type="url" id="lessonVideoUrl" name="videoUrl" class="form-control" value="${lesson != null ? lesson.videoUrl : ''}" placeholder="Dán link YouTube (vd: https://www.youtube.com/watch?v=... hoặc https://www.youtube.com/shorts/...)" oninput="handleVideoUrlChange()" onpaste="setTimeout(handleVideoUrlChange, 50)">
                            </div>
                            
                            <!-- Video Player (Fit 100% full width, No gap) -->
                            <div id="videoContainer" class="mt-2.5 text-center ${not empty lesson.videoUrl ? '' : 'd-none'}">
                                <div id="videoWrapper" class="w-100 rounded-3 overflow-hidden shadow-sm bg-black mx-auto" style="aspect-ratio: 16 / 9; transition: max-width 0.25s ease;">
                                    <iframe id="videoPreviewIframe" class="w-100 h-100" src="${lesson != null ? lesson.videoUrl : ''}" allowfullscreen style="border: 0; display: block;"></iframe>
                                </div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold"><i class="bi bi-file-earmark-text text-info me-1"></i>URL Tài liệu đính kèm (Slide / PDF / Google Docs)</label>
                            <input type="url" name="documentUrl" id="lessonDocumentUrl" class="form-control" value="${lesson != null ? lesson.documentUrl : ''}" placeholder="https://drive.google.com/...">
                        </div>

                        <!-- WYSIWYG Rich Text Content Editor -->
                        <div class="mb-4">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <label class="form-label small fw-semibold mb-0">Nội dung chi tiết bài học / Ghi chú lý thuyết</label>
                                <span class="badge bg-primary-subtle text-primary border small" style="font-size: 11px;">
                                    <i class="bi bi-pencil-square me-1"></i>Trình soạn thảo trực quan (WYSIWYG)
                                </span>
                            </div>

                            <!-- Hidden input to submit with the form -->
                            <textarea name="content" id="lessonContent" class="d-none">${lesson != null ? lesson.content : ''}</textarea>

                            <!-- Quill Editor Container -->
                            <div id="quillEditor">${lesson != null ? lesson.content : ''}</div>

                            <div class="form-text small d-flex justify-content-between align-items-center mt-1">
                                <span>Soạn thảo trực quan tức thì: Hỗ trợ phím tắt <code>Ctrl+B</code> (In đậm), <code>Ctrl+I</code> (In nghiêng), <code>Ctrl+U</code> (Gạch chân).</span>
                                <span class="text-muted" id="contentCharCount">0 ký tự</span>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center pt-3 border-top flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-3">
                                <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${course.id}" class="btn btn-light btn-sm">
                                    <i class="bi bi-arrow-left me-1"></i>Hủy bỏ
                                </a>
                                <div class="d-flex align-items-center gap-2">
                                    <span id="autoSaveStatusText" class="small text-muted"></span>
                                    <button type="button" class="btn btn-link btn-sm text-decoration-none p-0 small text-secondary" onclick="manualSaveDraft()" title="Lưu nháp ngay bây giờ">
                                        <i class="bi bi-cloud-arrow-up me-1"></i>Lưu nháp ngay
                                    </button>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary fw-semibold px-4 shadow-sm" id="btnSubmitLesson">
                                <i class="bi bi-save me-1"></i>Lưu bài học
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Quill WYSIWYG Editor JS -->
<script src="https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.min.js"></script>

<script>
    let quill = null;
    let isUserTypingTitleManually = ${lesson != null && not empty lesson.title ? 'true' : 'false'};
    let lastFetchedVideoId = null;
    let isFetchingTitle = false;

    document.addEventListener('DOMContentLoaded', function() {
        const titleInp = document.getElementById('lessonTitle');
        if (titleInp) {
            titleInp.addEventListener('input', function() {
                if (this.value.trim().length > 0) {
                    isUserTypingTitleManually = true;
                } else {
                    isUserTypingTitleManually = false;
                }
            });
        }
        
        // Initial check if video URL is present and title is empty
        const videoInp = document.getElementById('lessonVideoUrl');
        if (videoInp && videoInp.value.trim() && titleInp && !titleInp.value.trim()) {
            handleVideoUrlChange();
        }
    });

    function extractYoutubeId(url) {
        if (!url) return null;
        url = url.trim();
        // Match 11 char ID directly
        if (/^[a-zA-Z0-9_-]{11}$/.test(url)) {
            return url;
        }
        // Match embed, watch?v=, youtu.be/, shorts/
        const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|shorts\/|watch\?v=|\&v=)([^#\&\?]*).*/;
        const match = url.match(regExp);
        return (match && match[2].length === 11) ? match[2] : null;
    }

    function handleVideoUrlChange() {
        updateVideoPreview();
        const inputEl = document.getElementById('lessonVideoUrl');
        if (!inputEl) return;
        const url = inputEl.value.trim();
        const ytId = extractYoutubeId(url);

        const titleInput = document.getElementById('lessonTitle');
        const isTitleEmpty = !titleInput || !titleInput.value || titleInput.value.trim() === '';

        // Tự động lấy tiêu đề nếu bài học mới hoặc tiêu đề đang để trống / chưa được người dùng tự gõ
        if (ytId && (isTitleEmpty || !isUserTypingTitleManually)) {
            if (ytId !== lastFetchedVideoId) {
                fetchAndApplyVideoTitle(false);
            }
        }
    }

    async function fetchAndApplyVideoTitle(isManualClick = false) {
        const inputEl = document.getElementById('lessonVideoUrl');
        const titleInput = document.getElementById('lessonTitle');
        const feedbackEl = document.getElementById('titleFetchFeedback');
        if (!inputEl || !titleInput) return;

        const url = inputEl.value.trim();
        if (!url) {
            if (isManualClick && feedbackEl) {
                feedbackEl.style.display = 'block';
                feedbackEl.innerHTML = '<span class="text-danger"><i class="bi bi-exclamation-circle me-1"></i>Vui lòng nhập đường dẫn video trước!</span>';
                setTimeout(() => { feedbackEl.style.display = 'none'; }, 3000);
            }
            return;
        }

        const ytId = extractYoutubeId(url);
        if (isFetchingTitle) return;
        isFetchingTitle = true;

        if (feedbackEl) {
            feedbackEl.style.display = 'block';
            feedbackEl.innerHTML = '<span class="text-primary"><span class="spinner-border spinner-border-sm me-1" role="status"></span>Đang tự động lấy tiêu đề video...</span>';
        }

        let videoTitle = null;

        // 1. Nếu là YouTube, thử gọi trực tiếp YouTube oEmbed từ Client
        if (ytId) {
            try {
                const oembedUrl = 'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=' + ytId + '&format=json';
                const controller = new AbortController();
                const timeoutId = setTimeout(() => controller.abort(), 3500);
                const resp = await fetch(oembedUrl, { signal: controller.signal });
                clearTimeout(timeoutId);
                if (resp.ok) {
                    const data = await resp.json();
                    if (data && data.title) {
                        videoTitle = data.title;
                        lastFetchedVideoId = ytId;
                    }
                }
            } catch (err) {
                console.log('Client oEmbed fallback:', err);
            }
        }

        // 2. Fallback sang Backend API Courson: /expert/get-video-title
        if (!videoTitle) {
            try {
                const backendUrl = '${pageContext.request.contextPath}/expert/get-video-title?url=' + encodeURIComponent(url);
                const resp = await fetch(backendUrl);
                if (resp.ok) {
                    const data = await resp.json();
                    if (data && data.success && data.title) {
                        videoTitle = data.title;
                        if (ytId) lastFetchedVideoId = ytId;
                    }
                }
            } catch (err) {
                console.warn('Backend get-video-title error:', err);
            }
        }

        // 3. Fallback cho file MP4 trực tiếp: lấy tên file làm tiêu đề
        if (!videoTitle && (url.toLowerCase().endsWith('.mp4') || url.toLowerCase().endsWith('.webm'))) {
            try {
                const pathname = new URL(url).pathname;
                let filename = pathname.substring(pathname.lastIndexOf('/') + 1);
                filename = filename.replace(/\.(mp4|webm)$/i, '').replace(/[-_]+/g, ' ').trim();
                if (filename.length > 0) {
                    videoTitle = filename.charAt(0).toUpperCase() + filename.slice(1);
                }
            } catch (e) {}
        }

        isFetchingTitle = false;

        if (videoTitle) {
            titleInput.value = videoTitle;
            isUserTypingTitleManually = false;
            if (feedbackEl) {
                feedbackEl.style.display = 'block';
                feedbackEl.innerHTML = '<span class="text-success fw-medium"><i class="bi bi-check-circle-fill me-1"></i>Đã tự động đặt tiêu đề theo video: <strong>' + escapeHtml(videoTitle) + '</strong></span>';
                setTimeout(() => {
                    feedbackEl.style.display = 'none';
                }, 5000);
            }
        } else {
            if (feedbackEl) {
                if (isManualClick) {
                    feedbackEl.style.display = 'block';
                    feedbackEl.innerHTML = '<span class="text-warning"><i class="bi bi-exclamation-triangle me-1"></i>Không thể tự động nhận diện tiêu đề từ video này. Vui lòng nhập tiêu đề bằng tay.</span>';
                } else {
                    feedbackEl.style.display = 'none';
                }
            }
        }
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function updateVideoPreview() {
        const inputEl = document.getElementById('lessonVideoUrl');
        if (!inputEl) return;
        const inputVal = inputEl.value.trim();
        const container = document.getElementById('videoContainer');
        const wrapper = document.getElementById('videoWrapper');
        const iframe = document.getElementById('videoPreviewIframe');

        if (!inputVal) {
            if (container) container.classList.add('d-none');
            if (iframe) iframe.src = "";
            return;
        }

        const isShorts = /\/shorts\//i.test(inputVal);
        const id = extractYoutubeId(inputVal);
        let finalUrl = inputVal;
        if (id) {
            finalUrl = "https://www.youtube.com/embed/" + id;
            inputEl.value = finalUrl;
        }

        if (iframe) iframe.src = finalUrl;
        if (wrapper) {
            if (isShorts) {
                wrapper.style.maxWidth = '340px';
                wrapper.style.aspectRatio = '9 / 16';
            } else {
                wrapper.style.maxWidth = '100%';
                wrapper.style.aspectRatio = '16 / 9';
            }
        }
        if (container) container.classList.remove('d-none');
    }

    // =========================================================================
    // QUILL WYSIWYG RICH TEXT EDITOR LOGIC
    // =========================================================================
    function getEditorContent() {
        if (quill) {
            const text = quill.getText().trim();
            // Nếu không có ký tự thực tế nào, coi như rỗng
            return text.length === 0 ? '' : quill.root.innerHTML;
        }
        const el = document.getElementById('lessonContent');
        return el ? el.value : '';
    }

    function initQuillEditor() {
        const editorContainer = document.getElementById('quillEditor');
        if (!editorContainer) return;

        const toolbarOptions = [
            [{ 'header': [1, 2, 3, false] }],
            ['bold', 'italic', 'underline', 'strike'],
            [{ 'color': [] }, { 'background': [] }],
            [{ 'list': 'ordered'}, { 'list': 'bullet' }],
            ['blockquote', 'code-block'],
            [{ 'align': [] }],
            ['link', 'clean']
        ];

        quill = new Quill('#quillEditor', {
            theme: 'snow',
            placeholder: 'Nhập nội dung bài học hoặc ghi chú lý thuyết tại đây...',
            modules: {
                toolbar: toolbarOptions
            }
        });

        quill.on('text-change', function() {
            updateCharCount();
            const hiddenEl = document.getElementById('lessonContent');
            if (hiddenEl) {
                hiddenEl.value = getEditorContent();
            }
            triggerAutoSave(false);
        });

        updateCharCount();
    }

    function updateCharCount() {
        const counter = document.getElementById('contentCharCount');
        if (counter && quill) {
            const text = quill.getText().trim();
            counter.textContent = text.length.toLocaleString('vi-VN') + ' ký tự';
        }
    }

    // =========================================================================
    // AUTO-SAVE DRAFT SYSTEM (TỰ ĐỘNG LƯU LIÊN TỤC / REAL-TIME AUTO-SAVE)
    // =========================================================================
    const AUTO_SAVE_INTERVAL_MS = 15 * 1000; // 15 giây đồng bộ nền định kỳ
    let autoSaveTimeout = null;
    const courseId = document.getElementById('lessonCourseId') ? document.getElementById('lessonCourseId').value : '${course.id}';
    const lessonIdEl = document.getElementById('lessonId');
    const lessonId = lessonIdEl ? lessonIdEl.value : 'new';
    const DRAFT_KEY = 'courson_draft_lesson_' + courseId + '_' + lessonId;

    let isSubmitting = false;
    let isSavingDraft = false;
    let initialFormData = null;
    let cachedDraft = null;

    function getFormData() {
        return {
            courseId: courseId,
            lessonId: lessonId,
            moduleId: document.getElementById('lessonModuleId') ? document.getElementById('lessonModuleId').value : '',
            title: document.getElementById('lessonTitle') ? document.getElementById('lessonTitle').value : '',
            orderIndex: document.getElementById('lessonOrderIndex') ? document.getElementById('lessonOrderIndex').value : '1',
            videoUrl: document.getElementById('lessonVideoUrl') ? document.getElementById('lessonVideoUrl').value : '',
            documentUrl: document.getElementById('lessonDocumentUrl') ? document.getElementById('lessonDocumentUrl').value : '',
            content: getEditorContent()
        };
    }

    function isFormDirty() {
        if (!initialFormData) return false;
        const cur = getFormData();
        return cur.title !== initialFormData.title ||
               cur.moduleId !== initialFormData.moduleId ||
               cur.orderIndex !== initialFormData.orderIndex ||
               cur.videoUrl !== initialFormData.videoUrl ||
               cur.documentUrl !== initialFormData.documentUrl ||
               cur.content !== initialFormData.content;
    }

    function formatTime(d = new Date()) {
        const pad = (n) => String(n).padStart(2, '0');
        const hh = pad(d.getHours());
        const mm = pad(d.getMinutes());
        const ss = pad(d.getSeconds());
        const dd = pad(d.getDate());
        const mo = pad(d.getMonth() + 1);
        const yyyy = d.getFullYear();
        return hh + ':' + mm + ':' + ss + ' ' + dd + '/' + mo + '/' + yyyy;
    }

    function saveDraftLocalOnly() {
        if (isSubmitting) return;
        if (!isFormDirty()) return;
        try {
            const cur = getFormData();
            cur.savedAt = formatTime();
            localStorage.setItem(DRAFT_KEY, JSON.stringify(cur));
        } catch (e) {
            console.warn('Lỗi lưu nháp localStorage:', e);
        }
    }

    function triggerAutoSave(immediate = false) {
        if (isSubmitting) return;

        // 1. Lưu ngay vào localStorage tức thì (0ms) để không bao giờ mất ký tự
        saveDraftLocalOnly();

        // 2. Xóa bộ đếm debounce cũ
        if (autoSaveTimeout) {
            clearTimeout(autoSaveTimeout);
            autoSaveTimeout = null;
        }

        if (immediate) {
            saveDraft(false);
        } else {
            const statusEl = document.getElementById('autoSaveStatusText');
            if (statusEl && isFormDirty()) {
                statusEl.innerHTML = '<span class="text-muted"><span class="spinner-grow spinner-grow-sm me-1" style="width: 8px; height: 8px;"></span>Đang ghi nhận thay đổi...</span>';
            }
            // Debounce 1.5 giây sau khi ngừng gõ để gửi backup lên server
            autoSaveTimeout = setTimeout(function() {
                saveDraft(false);
            }, 1500);
        }
    }

    function saveDraft(isManual = false) {
        if (isSubmitting || isSavingDraft) return;

        // Nếu là tự động theo chu kỳ 5 phút mà form không có gì thay đổi thì bỏ qua
        if (!isManual && !isFormDirty()) {
            return;
        }

        isSavingDraft = true;
        const nowStr = formatTime();
        const currentData = getFormData();
        currentData.savedAt = nowStr;

        const statusEl = document.getElementById('autoSaveStatusText');
        if (statusEl) {
            statusEl.textContent = isManual ? 'Đang lưu nháp...' : 'Đang tự động lưu nháp...';
        }

        // 1. Lưu ngay vào localStorage của trình duyệt
        let localSuccess = false;
        try {
            localStorage.setItem(DRAFT_KEY, JSON.stringify(currentData));
            localSuccess = true;
        } catch (e) {
            console.warn('Lỗi lưu nháp localStorage:', e);
        }

        // 2. Gửi lưu backup lên Session server
        const params = new URLSearchParams();
        for (const key in currentData) {
            params.append(key, currentData[key]);
        }

        fetch('${pageContext.request.contextPath}/expert/save-lesson-draft', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params.toString()
        })
        .then(res => {
            if (!res.ok) throw new Error('HTTP ' + res.status);
            return res.json();
        })
        .then(data => {
            isSavingDraft = false;
            if (data && data.success) {
                const timeDisplay = (data && data.savedAt) ? data.savedAt : nowStr;
                if (statusEl) {
                    statusEl.innerHTML = '<span class="text-success"><i class="bi bi-check2 me-1"></i>Đã tự động lưu nháp (' + timeDisplay + ')</span>';
                    setTimeout(() => { if (statusEl) statusEl.innerHTML = ''; }, 4000);
                }
            } else {
                throw new Error(data && data.message ? data.message : 'Lỗi từ máy chủ');
            }
        })
        .catch(err => {
            isSavingDraft = false;
            if (statusEl) {
                if (localSuccess) {
                    statusEl.innerHTML = '<span class="text-warning"><i class="bi bi-exclamation-triangle me-1"></i>Đã lưu nháp cục bộ</span>';
                } else {
                    statusEl.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Lỗi lưu nháp</span>';
                }
                setTimeout(() => { if (statusEl) statusEl.innerHTML = ''; }, 4000);
            }
        });
    }

    function manualSaveDraft() {
        saveDraft(true);
    }

    function hasMeaningfulDiff(draft, current) {
        if (!draft) return false;
        const hasData = (draft.title && draft.title.trim() !== '') ||
                        (draft.content && draft.content.trim() !== '') ||
                        (draft.videoUrl && draft.videoUrl.trim() !== '');
        if (!hasData) return false;

        return (draft.title || '') !== (current.title || '') ||
               (draft.content || '') !== (current.content || '') ||
               (draft.videoUrl || '') !== (current.videoUrl || '') ||
               (draft.documentUrl || '') !== (current.documentUrl || '') ||
               (draft.moduleId || '') !== (current.moduleId || '') ||
               (draft.orderIndex || '') !== (current.orderIndex || '');
    }

    function showRecoveryBanner(draft) {
        cachedDraft = draft;
        const container = document.getElementById('draftRecoveryAlertContainer');
        if (!container) return;

        const timeStr = draft.savedAt ? ' (lúc ' + draft.savedAt + ')' : '';
        container.innerHTML = 
            '<div class="alert alert-warning alert-dismissible fade show shadow-sm mb-4 border-warning border-start border-4 rounded-3" role="alert">' +
                '<div class="d-flex align-items-center justify-content-between flex-wrap gap-2">' +
                    '<div class="d-flex align-items-center gap-3">' +
                        '<i class="bi bi-clock-history fs-3 text-warning"></i>' +
                        '<div>' +
                            '<strong class="text-dark">Phát hiện bản nháp chưa lưu trước đó' + timeStr + '!</strong>' +
                            '<div class="small text-muted">Hệ thống đã tự động lưu trữ dữ liệu soạn thảo bài học của bạn. Bạn có muốn khôi phục không?</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="d-flex gap-2">' +
                        '<button type="button" class="btn btn-warning btn-sm fw-bold shadow-sm" onclick="restoreDraft()">' +
                            '<i class="bi bi-arrow-counterclockwise me-1"></i>Khôi phục bài' +
                        '</button>' +
                        '<button type="button" class="btn btn-outline-secondary btn-sm" onclick="dismissDraft()">' +
                            'Bỏ qua' +
                        '</button>' +
                    '</div>' +
                '</div>' +
            '</div>';
    }

    function restoreDraft() {
        if (!cachedDraft) return;

        if (cachedDraft.title !== undefined) {
            const el = document.getElementById('lessonTitle');
            if (el) el.value = cachedDraft.title;
        }
        if (cachedDraft.moduleId !== undefined) {
            const el = document.getElementById('lessonModuleId');
            if (el) el.value = cachedDraft.moduleId;
        }
        if (cachedDraft.orderIndex !== undefined) {
            const el = document.getElementById('lessonOrderIndex');
            if (el) el.value = cachedDraft.orderIndex;
        }
        if (cachedDraft.videoUrl !== undefined) {
            const el = document.getElementById('lessonVideoUrl');
            if (el) {
                el.value = cachedDraft.videoUrl;
                updateVideoPreview();
            }
        }
        if (cachedDraft.documentUrl !== undefined) {
            const el = document.getElementById('lessonDocumentUrl');
            if (el) el.value = cachedDraft.documentUrl;
        }
        if (cachedDraft.content !== undefined) {
            if (quill) {
                quill.root.innerHTML = cachedDraft.content || '';
            }
            const el = document.getElementById('lessonContent');
            if (el) el.value = cachedDraft.content || '';
            updateCharCount();
        }

        const container = document.getElementById('draftRecoveryAlertContainer');
        if (container) {
            container.innerHTML = 
                '<div class="alert alert-success alert-dismissible fade show shadow-sm mb-4 py-2 px-3 small rounded-3" role="alert">' +
                    '<i class="bi bi-check-circle-fill me-2"></i>Đã khôi phục thành công dữ liệu từ bản nháp ' + (cachedDraft.savedAt ? '(' + cachedDraft.savedAt + ')' : '') + '.' +
                    '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                '</div>';
        }

        const statusEl = document.getElementById('autoSaveStatusText');
        if (statusEl) {
            statusEl.innerHTML = '<span class="text-success"><i class="bi bi-arrow-counterclockwise me-1"></i>Đã khôi phục bản nháp</span>';
        }
    }

    function dismissDraft() {
        const container = document.getElementById('draftRecoveryAlertContainer');
        if (container) {
            container.innerHTML = '';
        }
        try {
            localStorage.removeItem(DRAFT_KEY);
        } catch (e) {}
        fetch('/expert/delete-lesson-draft?courseId=' + encodeURIComponent(courseId) + '&lessonId=' + encodeURIComponent(lessonId), { method: 'POST' });
    }

    function checkExistingDraft() {
        // 1. Kiểm tra localStorage máy khách
        let localDraft = null;
        try {
            const raw = localStorage.getItem(DRAFT_KEY);
            if (raw) {
                localDraft = JSON.parse(raw);
            }
        } catch (e) {}

        if (localDraft && hasMeaningfulDiff(localDraft, initialFormData)) {
            showRecoveryBanner(localDraft);
            return;
        }

        // 2. Dự phòng: Kiểm tra Session máy chủ
        fetch('${pageContext.request.contextPath}/expert/get-lesson-draft?courseId=' + encodeURIComponent(courseId) + '&lessonId=' + encodeURIComponent(lessonId))
            .then(res => res.json())
            .then(data => {
                if (data && data.exists && hasMeaningfulDiff(data, initialFormData)) {
                    showRecoveryBanner(data);
                }
            })
            .catch(err => {
                // Ignore fetch error
            });
    }

    // Khởi tạo các sự kiện khi DOM sẵn sàng
    document.addEventListener('DOMContentLoaded', function() {
        initQuillEditor();
        initialFormData = getFormData();

        // Khởi tạo video nếu đã có sẵn URL
        const curVal = document.getElementById('lessonVideoUrl') ? document.getElementById('lessonVideoUrl').value.trim() : '';
        if (curVal) {
            updateVideoPreview();
        }

        // Kiểm tra xem có bản nháp chưa lưu không
        checkExistingDraft();

        // Lắng nghe thay đổi trên tất cả các trường để tự động lưu tức thì
        const inputsToWatch = ['lessonTitle', 'lessonVideoUrl', 'lessonDocumentUrl', 'lessonModuleId', 'lessonOrderIndex'];
        inputsToWatch.forEach(id => {
            const el = document.getElementById(id);
            if (el) {
                el.addEventListener('input', () => triggerAutoSave(false));
                el.addEventListener('change', () => triggerAutoSave(true));
                el.addEventListener('blur', () => triggerAutoSave(true));
            }
        });

        // Định kỳ kiểm tra đồng bộ nền mỗi 15 giây
        setInterval(function() {
            if (isFormDirty() && !isSavingDraft) {
                saveDraft(false);
            }
        }, AUTO_SAVE_INTERVAL_MS);

        // Bắt sự kiện nộp biểu mẫu: đồng bộ nội dung từ Quill (giữ nguyên nháp local phòng sự cố nộp lỗi)
        const formEl = document.getElementById('lessonForm');
        if (formEl) {
            formEl.addEventListener('submit', function() {
                const hiddenEl = document.getElementById('lessonContent');
                if (hiddenEl) {
                    hiddenEl.value = getEditorContent();
                }
                isSubmitting = true;
                // [Zero Data Loss]: KHÔNG xóa localStorage tại đây. Chỉ xóa khi server xác nhận lưu thành công.
            });
        }

        // Cảnh báo khi người dùng tắt tab/rời trang khi chưa lưu và cố gắng bảo toàn nháp
        window.addEventListener('beforeunload', function(e) {
            if (isSubmitting) return;
            if (isFormDirty()) {
                const cur = getFormData();
                cur.savedAt = formatTime();
                try {
                    localStorage.setItem(DRAFT_KEY, JSON.stringify(cur));
                } catch (err) {}

                if (navigator.sendBeacon) {
                    const params = new URLSearchParams();
                    for (const key in cur) {
                        params.append(key, cur[key]);
                    }
                    navigator.sendBeacon('${pageContext.request.contextPath}/expert/save-lesson-draft', params);
                }

                e.preventDefault();
                e.returnValue = 'Bạn có thay đổi chưa lưu. Dữ liệu đã được tự động bảo toàn.';
                return e.returnValue;
            }
        });
    });

    function handleModuleSelectChange(val) {
        const group = document.getElementById('newModuleInputGroup');
        const inp = document.getElementById('newModuleTitle');
        if (!group || !inp) return;
        if (val === '__NEW__') {
            group.classList.remove('d-none');
            inp.required = true;
            inp.focus();
        } else {
            group.classList.add('d-none');
            inp.required = false;
            inp.value = '';
        }
    }


</script>

<jsp:include page="../common/footer.jsp" />

package controller;

import dao.CourseDao;
import dao.ModuleDao;
import dao.QuestionDao;
import dao.QuizAttemptDao;
import dao.QuizDao;
import dao.RegistrationDao;
import dto.AnswerOptionDto;
import dto.CourseDto;
import dto.ModuleDto;
import dto.QuestionDto;
import dto.QuizAnswerDto;
import dto.QuizAttemptDto;
import dto.QuizDto;
import dto.QuizResultDto;
import entity.enums.QuestionType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;
import service.QuizService;

@WebServlet(name = "QuizServlet", urlPatterns = { "/quizzes/*" })
public class QuizServlet extends HttpServlet {
    private QuizService quizService;
    private CourseDao courseDao;
    private ModuleDao moduleDao;

    @Override
    public void init() throws ServletException {
        this.courseDao = new CourseDao();
        this.moduleDao = new ModuleDao();
        this.quizService = new QuizService(
                new QuizDao(), new QuestionDao(), new QuizAttemptDao(), new RegistrationDao(),
                this.courseDao, this.moduleDao);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "list";
        processAction(action, req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String action = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "save";
        processAction(action, req, resp);
    }

    private void processAction(String action, HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        switch (action) {
            case "list":
                showQuizList(req, resp);
                break;
            case "detail":
                showQuizDetail(req, resp);
                break;
            case "save":
                saveQuiz(req, resp);
                break;
            case "delete":
                deleteQuiz(req, resp);
                break;
            case "save-question":
                saveQuestion(req, resp);
                break;
            case "delete-question":
                deleteQuestion(req, resp);
                break;
            case "assign-question":
                assignQuestion(req, resp);
                break;
            case "remove-question":
                removeQuestion(req, resp);
                break;
            case "attempt":
                showAttempt(req, resp);
                break;
            case "submit":
                submitAttempt(req, resp);
                break;
            case "result":
                showResult(req, resp);
                break;
            default:
                showQuizList(req, resp);
                break;
        }
    }

    private void showQuizList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String courseIdStr = req.getParameter("courseId");
        String moduleIdStr = req.getParameter("moduleId");

        Long courseId = null;
        if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
            try {
                courseId = Long.parseLong(courseIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        } else if (moduleIdStr != null && !moduleIdStr.trim().isEmpty()) {
            try (java.sql.Connection con = util.DbConnection.getConnection()) {
                long modId = Long.parseLong(moduleIdStr.trim());
                java.util.Optional<entity.Module> modOpt = moduleDao.findById(con, modId);
                if (modOpt.isPresent()) {
                    courseId = modOpt.get().getCourseId();
                }
            } catch (Exception ignored) {
            }
        }

        if (courseId == null) {
            try (java.sql.Connection con = util.DbConnection.getConnection()) {
                List<entity.Course> allCourses = courseDao.findAll(con);
                if (!allCourses.isEmpty()) {
                    courseId = allCourses.get(0).getId();
                }
            } catch (Exception ignored) {
            }
        }

        if (courseId != null) {
            CourseDto course = quizService.getQuizManagementCourse(courseId);
            req.setAttribute("course", course);
            req.setAttribute("courseId", courseId);

            // Questions đã được nhóm sẵn vào từng module.questions bởi service
            int totalQuestions = 0;
            if (course != null && course.getModules() != null) {
                for (ModuleDto m : course.getModules()) {
                    totalQuestions += m.getQuestionCount();
                }
            }
            req.setAttribute("totalQuestions", totalQuestions);
        }

        req.getRequestDispatcher("/WEB-INF/views/quiz/list.jsp").forward(req, resp);
    }

    private void showQuizDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String quizIdStr = req.getParameter("id");
        String courseIdStr = req.getParameter("courseId");
        if (quizIdStr == null || quizIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/quizzes/list"
                    + (courseIdStr != null && !courseIdStr.trim().isEmpty() ? "?courseId=" + courseIdStr.trim() : ""));
            return;
        }

        try {
            long quizId = Long.parseLong(quizIdStr.trim());
            QuizDto quiz = quizService.getQuizDetail(quizId);
            req.setAttribute("quiz", quiz);

            Long courseId = null;
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                try {
                    courseId = Long.parseLong(courseIdStr.trim());
                } catch (NumberFormatException ignored) {
                }
            }

            try (java.sql.Connection con = util.DbConnection.getConnection()) {
                java.util.Optional<entity.Module> modOpt = moduleDao.findById(con, quiz.getModuleId());
                if (modOpt.isPresent()) {
                    entity.Module module = modOpt.get();
                    req.setAttribute("currentModule", module);
                    if (courseId == null) {
                        courseId = module.getCourseId();
                    }
                }
            } catch (Exception ignored) {
            }

            //lay thong tin course
            if (courseId != null) {
                req.setAttribute("courseId", courseId);
                try (java.sql.Connection con = util.DbConnection.getConnection()) {
                    courseDao.findById(con, courseId).ifPresent(c -> {
                        CourseDto cDto = new CourseDto();
                        cDto.setId(c.getId());
                        cDto.setTitle(c.getTitle());
                        req.setAttribute("course", cDto);
                    });
                } catch (Exception ignored) {
                }
            }

            // Danh sách câu hỏi trong ngân hàng của cùng Module
            List<QuestionDto> bankQuestions = quizService.getQuestionBank(quiz.getModuleId());
            req.setAttribute("bankQuestions", bankQuestions);

            java.util.Set<Long> assignedQuestionIds = quiz.getQuestions().stream()
                    .map(QuestionDto::getId)
                    .collect(Collectors.toSet());
            req.setAttribute("assignedQuestionIds", assignedQuestionIds);

        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/quizzes/list?error=" + java.net.URLEncoder.encode(
                    "Không tìm thấy bài thi hoặc lỗi: " + e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/quiz/detail.jsp").forward(req, resp);
    }

    private void saveQuiz(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String courseIdStr = req.getParameter("courseId");
        QuizDto dto = bindQuiz(req);
        try {
            long id = quizService.saveQuiz(dto);
            String target = req.getContextPath() + "/quizzes/detail?id=" + id;
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                target += "&courseId=" + courseIdStr.trim();
            }
            resp.sendRedirect(target + "&success=saved");
        } catch (Exception e) {
            String redirectUrl = req.getContextPath() + "/quizzes/detail?";
            if (dto.getId() != null && dto.getId() > 0) {
                redirectUrl += "id=" + dto.getId();
                if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                    redirectUrl += "&courseId=" + courseIdStr.trim();
                }
            } else {
                redirectUrl = req.getContextPath() + "/quizzes/list?";
                if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                    redirectUrl += "courseId=" + courseIdStr.trim();
                } else {
                    redirectUrl += "moduleId=" + dto.getModuleId();
                }
            }
            resp.sendRedirect(redirectUrl + "&error="
                    + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void deleteQuiz(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String quizIdStr = req.getParameter("id");
        String courseIdStr = req.getParameter("courseId");
        String moduleIdStr = req.getParameter("moduleId");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));
        try {
            if (quizIdStr != null) {
                quizService.deleteQuiz(Long.parseLong(quizIdStr));
            }
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":true,\"message\":\"Đã xóa bài kiểm tra thành công!\"}");
                return;
            }
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                resp.sendRedirect(
                        req.getContextPath() + "/quizzes/list?courseId=" + courseIdStr.trim() + "&success=deleted");
            } else {
                resp.sendRedirect(req.getContextPath() + "/quizzes/list?moduleId=" + moduleIdStr + "&success=deleted");
            }
        } catch (Exception e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"" + (e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Lỗi khi xóa bài kiểm tra.") + "\"}");
                return;
            }
            String redirectUrl = req.getContextPath() + "/quizzes/list?";
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                redirectUrl += "courseId=" + courseIdStr.trim();
            } else {
                redirectUrl += "moduleId=" + moduleIdStr;
            }
            resp.sendRedirect(redirectUrl + "&error="
                    + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void saveQuestion(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        QuestionDto dto = bindQuestion(req);
        String quizIdStr = req.getParameter("quizId");
        String courseIdStr = req.getParameter("courseId");
        try {
            long questionId = quizService.saveQuestion(dto);
            boolean isNewQuestion = (dto.getId() == null || dto.getId() <= 0);
            // Nếu có quizId VÀ câu hỏi mới tạo, tự động gán câu hỏi này vào Quiz luôn!
            if (quizIdStr != null && !quizIdStr.trim().isEmpty()) {
                long quizId = Long.parseLong(quizIdStr.trim());
                String target = req.getContextPath() + "/quizzes/detail?id=" + quizId;
                if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                    target += "&courseId=" + courseIdStr.trim();
                }
                if (isNewQuestion) {
                    BigDecimal points = dto.getDefaultPoints() != null ? dto.getDefaultPoints() : BigDecimal.ONE;
                    quizService.assignQuestion(quizId, questionId, points, 0);
                    resp.sendRedirect(target + "&success=question_created_and_assigned");
                } else {
                    resp.sendRedirect(target + "&success=question_updated");
                }
                return;
            }
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/quizzes/list?courseId=" + courseIdStr.trim()
                        + "&tab=questions&success=question_saved");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/quizzes/list?moduleId=" + dto.getModuleId()
                    + "&tab=questions&success=question_saved");
        } catch (Exception e) {
            if (quizIdStr != null && !quizIdStr.trim().isEmpty()) {
                String target = req.getContextPath() + "/quizzes/detail?id=" + quizIdStr.trim();
                if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                    target += "&courseId=" + courseIdStr.trim();
                }
                resp.sendRedirect(target + "&error="
                        + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
                return;
            }
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                resp.sendRedirect(
                        req.getContextPath() + "/quizzes/list?courseId=" + courseIdStr.trim() + "&tab=questions&error="
                                + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
                return;
            }
            resp.sendRedirect(
                    req.getContextPath() + "/quizzes/list?moduleId=" + dto.getModuleId() + "&tab=questions&error="
                            + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void deleteQuestion(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String qIdStr = req.getParameter("id");
        String courseIdStr = req.getParameter("courseId");
        String moduleIdStr = req.getParameter("moduleId");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));
        try {
            if (qIdStr != null) {
                quizService.deleteQuestion(Long.parseLong(qIdStr));
            }
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":true,\"message\":\"Đã xóa câu hỏi khỏi ngân hàng thành công!\"}");
                return;
            }
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/quizzes/list?courseId=" + courseIdStr.trim()
                        + "&tab=questions&success=question_deleted");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/quizzes/list?moduleId=" + moduleIdStr
                    + "&tab=questions&success=question_deleted");
        } catch (Exception e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"" + (e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Lỗi khi xóa câu hỏi.") + "\"}");
                return;
            }
            String redirectUrl = req.getContextPath() + "/quizzes/list?";
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                redirectUrl += "courseId=" + courseIdStr.trim() + "&tab=questions";
            } else {
                redirectUrl += "moduleId=" + moduleIdStr + "&tab=questions";
            }
            resp.sendRedirect(redirectUrl + "&error="
                    + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void assignQuestion(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String quizIdStr = req.getParameter("quizId");
        String questionIdStr = req.getParameter("questionId");
        String courseIdStr = req.getParameter("courseId");
        if (quizIdStr == null || questionIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/quizzes/list?error=invalid_params");
            return;
        }
        long quizId = Long.parseLong(quizIdStr.trim());
        long questionId = Long.parseLong(questionIdStr.trim());
        String pointsStr = req.getParameter("points");
        BigDecimal points = pointsStr != null && !pointsStr.trim().isEmpty() ? new BigDecimal(pointsStr.trim())
                : BigDecimal.ONE;
        String orderStr = req.getParameter("order");
        int order = (orderStr != null && !orderStr.trim().isEmpty()) ? Integer.parseInt(orderStr.trim()) : 0;

        try {
            quizService.assignQuestion(quizId, questionId, points, order);
            String target = req.getContextPath() + "/quizzes/detail?id=" + quizId;
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                target += "&courseId=" + courseIdStr.trim();
            }
            resp.sendRedirect(target + "&success=assigned");
        } catch (Exception e) {
            String target = req.getContextPath() + "/quizzes/detail?id=" + quizId;
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                target += "&courseId=" + courseIdStr.trim();
            }
            resp.sendRedirect(target + "&error="
                    + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void removeQuestion(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String quizIdStr = req.getParameter("quizId");
        String questionIdStr = req.getParameter("questionId");
        String courseIdStr = req.getParameter("courseId");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));
        if (quizIdStr == null || questionIdStr == null) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Thiếu tham số hợp lệ.\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/quizzes/list?error=invalid_params");
            return;
        }
        long quizId = Long.parseLong(quizIdStr.trim());
        long questionId = Long.parseLong(questionIdStr.trim());
        try {
            quizService.removeQuestion(quizId, questionId);
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":true,\"message\":\"Đã gỡ câu hỏi khỏi bài thi thành công!\"}");
                return;
            }
            String target = req.getContextPath() + "/quizzes/detail?id=" + quizId;
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                target += "&courseId=" + courseIdStr.trim();
            }
            resp.sendRedirect(target + "&success=removed");
        } catch (Exception e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"" + (e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Lỗi khi gỡ câu hỏi.") + "\"}");
                return;
            }
            String target = req.getContextPath() + "/quizzes/detail?id=" + quizId;
            if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
                target += "&courseId=" + courseIdStr.trim();
            }
            resp.sendRedirect(target + "&error="
                    + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void showAttempt(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long regId = Long.parseLong(req.getParameter("registrationId"));
        long quizId = Long.parseLong(req.getParameter("quizId"));
        QuizAttemptDto attempt = quizService.startAttempt(regId, quizId);
        QuizDto quiz = quizService.getQuizDetail(quizId);

        req.setAttribute("attempt", attempt);
        req.setAttribute("quiz", quiz);
        req.getRequestDispatcher("/WEB-INF/views/quiz/take.jsp").forward(req, resp);
    }

    private void submitAttempt(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        QuizAttemptDto dto = bindAttempt(req);
        QuizResultDto result = quizService.submitAttempt(dto);
        req.getSession().setAttribute("lastQuizResult", result);
        resp.sendRedirect(req.getContextPath() + "/quizzes/result?registrationId=" + dto.getRegistrationId()
                + "&quizId=" + dto.getQuizId());
    }

    private void showResult(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long regId = Long.parseLong(req.getParameter("registrationId"));
        long quizId = Long.parseLong(req.getParameter("quizId"));
        QuizResultDto result = quizService.getResult(regId, quizId);
        req.setAttribute("result", result);
        req.getRequestDispatcher("/WEB-INF/views/quiz/result.jsp").forward(req, resp);
    }

    private QuizDto bindQuiz(HttpServletRequest req) {
        QuizDto dto = new QuizDto();
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            dto.setId(Long.parseLong(idStr.trim()));
        }
        dto.setModuleId(Long.parseLong(req.getParameter("moduleId")));
        dto.setTitle(req.getParameter("title"));
        String passScoreStr = req.getParameter("passScore");
        dto.setPassScore(passScoreStr != null && !passScoreStr.trim().isEmpty() ? new BigDecimal(passScoreStr.trim())
                : BigDecimal.valueOf(50.0));
        String timeLimitStr = req.getParameter("timeLimitMinutes");
        dto.setTimeLimitMinutes(
                timeLimitStr != null && !timeLimitStr.trim().isEmpty() ? Integer.parseInt(timeLimitStr.trim()) : null);
        String orderStr = req.getParameter("orderIndex");
        dto.setOrderIndex(orderStr != null && !orderStr.trim().isEmpty() ? Integer.parseInt(orderStr.trim()) : 1);
        return dto;
    }

    private QuestionDto bindQuestion(HttpServletRequest req) {
        QuestionDto dto = new QuestionDto();
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            dto.setId(Long.parseLong(idStr.trim()));
        }
        dto.setModuleId(Long.parseLong(req.getParameter("moduleId")));
        dto.setQuestionText(req.getParameter("questionText"));
        dto.setQuestionType(QuestionType.fromDb(req.getParameter("questionType")));
        String pointsStr = req.getParameter("defaultPoints");
        dto.setDefaultPoints(
                pointsStr != null && !pointsStr.trim().isEmpty() ? new BigDecimal(pointsStr.trim()) : BigDecimal.ONE);

        String[] optionTexts = req.getParameterValues("optionText");
        String correctIndexStr = req.getParameter("correctOption");
        int correctIndex = (correctIndexStr != null && !correctIndexStr.trim().isEmpty())
                ? Integer.parseInt(correctIndexStr)
                : -1;

        if (optionTexts != null) {
            for (int i = 0; i < optionTexts.length; i++) {
                boolean isCorrect = (i == correctIndex);
                dto.getOptions().add(new AnswerOptionDto(null, dto.getId(), optionTexts[i], isCorrect, i + 1));
            }
        }
        return dto;
    }

    private QuizAttemptDto bindAttempt(HttpServletRequest req) {
        QuizAttemptDto dto = new QuizAttemptDto();
        String idStr = req.getParameter("attemptId");
        if (idStr != null && !idStr.trim().isEmpty()) {
            dto.setId(Long.parseLong(idStr.trim()));
        }
        dto.setRegistrationId(Long.parseLong(req.getParameter("registrationId")));
        dto.setQuizId(Long.parseLong(req.getParameter("quizId")));

        String[] questionIds = req.getParameterValues("questionId");
        if (questionIds != null) {
            for (String qIdStr : questionIds) {
                long qId = Long.parseLong(qIdStr);
                String selectedOptStr = req.getParameter("question_" + qId);
                Long selectedOpt = (selectedOptStr != null && !selectedOptStr.trim().isEmpty())
                        ? Long.parseLong(selectedOptStr)
                        : null;
                dto.getAnswers().add(new QuizAnswerDto(qId, selectedOpt, false, BigDecimal.ZERO));
            }
        }
        return dto;
    }
}

package dto;

import java.util.ArrayList;
import java.util.List;

public class ModuleDto {
    private Long id;
    private Long courseId;
    private String title;
    private int orderIndex;
    private List<LessonDto> lessons = new ArrayList<>();
    private List<QuizDto> quizzes = new ArrayList<>();
    private List<QuestionDto> questions = new ArrayList<>();

    public ModuleDto() {
    }

    public ModuleDto(Long id, Long courseId, String title, int orderIndex,
                     List<LessonDto> lessons, List<QuizDto> quizzes) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.orderIndex = orderIndex;
        this.lessons = lessons != null ? lessons : new ArrayList<>();
        this.quizzes = quizzes != null ? quizzes : new ArrayList<>();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getCourseId() {
        return courseId;
    }

    public void setCourseId(Long courseId) {
        this.courseId = courseId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    /**
     * Tiêu đề sạch đã loại bỏ tiền tố trùng lặp 'Chương X:', 'Module X:' (nếu có).
     */
    public String getCleanTitle() {
        if (title == null) return "";
        return title.replaceFirst("^(?iu)(chương|chuong|module|phần|phan)\\s*\\d+\\s*[:.-]?\\s*", "").trim();
    }

    /**
     * Chuỗi tiêu đề hiển thị chuẩn hóa duy nhất: 'Chương X: [Tên chương]'
     */
    public String getDisplayTitle() {
        String clean = getCleanTitle();
        if (clean.isEmpty()) {
            return "Chương " + orderIndex;
        }
        return "Chương " + orderIndex + ": " + clean;
    }

    public int getOrderIndex() {
        return orderIndex;
    }

    public void setOrderIndex(int orderIndex) {
        this.orderIndex = orderIndex;
    }

    public List<LessonDto> getLessons() {
        return lessons;
    }

    public void setLessons(List<LessonDto> lessons) {
        this.lessons = lessons != null ? lessons : new ArrayList<>();
    }

    public List<QuizDto> getQuizzes() {
        return quizzes;
    }

    public void setQuizzes(List<QuizDto> quizzes) {
        this.quizzes = quizzes != null ? quizzes : new ArrayList<>();
    }

    public int getQuizCount() {
        return quizzes != null ? quizzes.size() : 0;
    }

    public boolean isHasQuizzes() {
        return quizzes != null && !quizzes.isEmpty();
    }

    public List<QuestionDto> getQuestions() {
        return questions;
    }

    public void setQuestions(List<QuestionDto> questions) {
        this.questions = questions != null ? questions : new ArrayList<>();
    }

    public int getQuestionCount() {
        return questions != null ? questions.size() : 0;
    }

    public boolean isHasQuestions() {
        return questions != null && !questions.isEmpty();
    }
}

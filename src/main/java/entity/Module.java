package entity;

import java.time.OffsetDateTime;

public class Module {
    private Long id;
    private Long courseId;
    private String title;
    private int orderIndex;
    private OffsetDateTime createdAt;

    public Module() {
    }

    public Module(Long id, Long courseId, String title, int orderIndex, OffsetDateTime createdAt) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.orderIndex = orderIndex;
        this.createdAt = createdAt;
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

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }
}

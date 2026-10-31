package dto;

import entity.enums.AuthProvider;
import entity.enums.UserStatus;
import java.time.LocalDate;

public class UserDto {
    private Long id;
    private String username;
    private String email;
    private String fullName;
    private Long roleId;
    private String roleName;
    private AuthProvider authProvider;
    private UserStatus status;
    private String avatarUrl;
    private String phone;
    private LocalDate birthDate;

    public UserDto() {
    }

    public UserDto(Long id, String username, String email, String fullName, Long roleId,
                   String roleName, AuthProvider authProvider, UserStatus status) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.fullName = fullName;
        this.roleId = roleId;
        this.roleName = roleName;
        this.authProvider = authProvider;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public Long getRoleId() {
        return roleId;
    }

    public void setRoleId(Long roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public AuthProvider getAuthProvider() {
        return authProvider;
    }

    public void setAuthProvider(AuthProvider authProvider) {
        this.authProvider = authProvider;
    }

    public UserStatus getStatus() {
        return status;
    }

    public void setStatus(UserStatus status) {
        this.status = status;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public LocalDate getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }
}

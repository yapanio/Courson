package dto;

public class GoogleAuthResult {

    public enum Status {
        NEW_USER_CREATED,
        UNVERIFIED_ACTIVATED,
        EXISTING_USER
    }

    private final UserDto user;
    private final Status status;

    public GoogleAuthResult(UserDto user, Status status) {
        this.user = user;
        this.status = status;
    }

    public UserDto getUser() {
        return user;
    }

    public Status getStatus() {
        return status;
    }
}

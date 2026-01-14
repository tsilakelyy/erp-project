package com.erp.dto;

import lombok.Data;
import javax.validation.constraints.*;

@Data
public class LoginDTO {
    @NotBlank(message = "Login is required")
    @Size(min = 3, max = 50)
    private String login;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    public LoginDTO() {}

    public LoginDTO(String login, String password) {
        this.login = login;
        this.password = password;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}


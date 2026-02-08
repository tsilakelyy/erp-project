package com.erp.controller;

import com.erp.domain.User;
import org.springframework.security.core.Authentication;
import org.springframework.ui.Model;

import javax.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public final class ControllerHelper {
    private ControllerHelper() {}

    public static String resolveUsername(Model model, HttpSession session, Authentication auth) {
        String username = null;

        if (session != null) {
            Object userObj = session.getAttribute("user");
            if (userObj instanceof User) {
                User user = (User) userObj;
                if (user.getActive() != null && user.getActive()) {
                    username = user.getLogin();
                    if (model != null) {
                        model.addAttribute("user", user);
                        model.addAttribute("roles", user.getRoles());
                    }
                }
            }
        }

        if (username == null && auth != null && auth.isAuthenticated()) {
            username = auth.getName();
        }

        if (username != null && model != null) {
            model.addAttribute("username", username);
        }

        return username;
    }

    public static String urlEncode(String value) {
        if (value == null) {
            return "";
        }
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8);
        } catch (Exception e) {
            return "";
        }
    }
}

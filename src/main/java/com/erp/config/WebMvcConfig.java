package com.erp.config;

import org.springframework.format.FormatterRegistry;
import org.springframework.format.Formatter;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * Web MVC Configuration to register custom formatters for date/time handling
 */
@Component
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addFormatters(FormatterRegistry registry) {
        // Register formatter for LocalDateTime with the pattern used in forms (datetime-local input)
        registry.addFormatterForFieldType(LocalDateTime.class, new LocalDateTimeFormatter());
    }

    /**
     * Custom formatter for LocalDateTime that handles the datetime-local input format
     */
    private static class LocalDateTimeFormatter implements Formatter<LocalDateTime> {
        private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        private static final DateTimeFormatter FORMATTER_WITH_SECONDS = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

        @Override
        public LocalDateTime parse(String text, Locale locale) {
            if (text == null || text.isEmpty()) {
                return null;
            }
            try {
                // Try with seconds first (in case the browser sends seconds)
                if (text.length() > 16 && text.charAt(16) == ':') {
                    return LocalDateTime.parse(text, FORMATTER_WITH_SECONDS);
                }
                // Otherwise use the standard pattern
                return LocalDateTime.parse(text, FORMATTER);
            } catch (Exception e) {
                throw new IllegalArgumentException("Invalid date format: " + text, e);
            }
        }

        @Override
        public String print(LocalDateTime object, Locale locale) {
            if (object == null) {
                return "";
            }
            return FORMATTER.format(object);
        }
    }
}


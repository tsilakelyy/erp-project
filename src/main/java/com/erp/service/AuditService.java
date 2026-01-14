package com.erp.service;

import com.erp.domain.AuditLog;
import com.erp.domain.User;
import com.erp.repository.AuditLogRepository;
import com.erp.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class AuditService {
    @Autowired
    private AuditLogRepository auditLogRepository;

    @Autowired
    private UserRepository userRepository;

    public void logAction(String entityName, Long entityId, String action, String username) {
        Optional<User> user = userRepository.findByUsername(username);
        if (user.isPresent()) {
            AuditLog log = AuditLog.builder()
                .entityName(entityName)
                .entityId(entityId)
                .action(action)
                .user(user.get())
                .ipAddress(getClientIpAddress())
                .createdAt(LocalDateTime.now())
                .build();
            auditLogRepository.save(log);
        }
    }

    public void logActionWithValues(String entityName, Long entityId, String action, String username, String oldValues, String newValues) {
        Optional<User> user = userRepository.findByUsername(username);
        if (user.isPresent()) {
            AuditLog log = AuditLog.builder()
                .entityName(entityName)
                .entityId(entityId)
                .action(action)
                .oldValues(oldValues)
                .newValues(newValues)
                .user(user.get())
                .ipAddress(getClientIpAddress())
                .createdAt(LocalDateTime.now())
                .build();
            auditLogRepository.save(log);
        }
    }

    public List<AuditLog> getEntityAuditLog(String entityName, Long entityId) {
        return auditLogRepository.findByEntityNameAndEntityId(entityName, entityId);
    }

    private String getClientIpAddress() {
        try {
            ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                HttpServletRequest request = attrs.getRequest();
                String xForwardedFor = request.getHeader("X-Forwarded-For");
                if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
                    return xForwardedFor.split(",")[0];
                }
                return request.getRemoteAddr();
            }
        } catch (Exception e) {
            return "Unknown";
        }
        return "Unknown";
    }
}

package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KpiDTO {
    private String kpiName;
    private Object value;
    private String unit;
    private String period;
    private String trend;
    private BigDecimal target;
    private BigDecimal variance;
    private LocalDateTime calculatedAt;
    private List<KpiDataPoint> dataPoints;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class KpiDataPoint {
        private String label;
        private Object value;
    }
}

package com.kisansetu.modules.cart.dto;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class WeeklyCartDto {
    private UUID id;
    private String title;
    private String status;
    private int modificationCount;
    private boolean isModifiable;
    private List<WeeklyCartDayDto> days = new ArrayList<>();
    private BigDecimal weeklyEstimatedTotal = BigDecimal.ZERO;

    public WeeklyCartDto() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getModificationCount() { return modificationCount; }
    public void setModificationCount(int modificationCount) { this.modificationCount = modificationCount; }
    public boolean isModifiable() { return isModifiable; }
    public void setModifiable(boolean modifiable) { isModifiable = modifiable; }
    public List<WeeklyCartDayDto> getDays() { return days; }
    public void setDays(List<WeeklyCartDayDto> days) { this.days = days; }
    public BigDecimal getWeeklyEstimatedTotal() { return weeklyEstimatedTotal; }
    public void setWeeklyEstimatedTotal(BigDecimal weeklyEstimatedTotal) { this.weeklyEstimatedTotal = weeklyEstimatedTotal; }
}

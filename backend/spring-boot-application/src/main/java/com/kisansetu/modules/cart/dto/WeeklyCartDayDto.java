package com.kisansetu.modules.cart.dto;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class WeeklyCartDayDto {
    private String dayOfWeek;
    private List<WeeklyCartItemDto> items = new ArrayList<>();
    private BigDecimal dayTotal = BigDecimal.ZERO;

    public WeeklyCartDayDto() {}

    public WeeklyCartDayDto(String dayOfWeek, List<WeeklyCartItemDto> items, BigDecimal dayTotal) {
        this.dayOfWeek = dayOfWeek;
        this.items = items;
        this.dayTotal = dayTotal;
    }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }
    public List<WeeklyCartItemDto> getItems() { return items; }
    public void setItems(List<WeeklyCartItemDto> items) { this.items = items; }
    public BigDecimal getDayTotal() { return dayTotal; }
    public void setDayTotal(BigDecimal dayTotal) { this.dayTotal = dayTotal; }
}

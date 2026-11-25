package com.kisansetu.modules.cart.dto;

import jakarta.validation.constraints.NotBlank;
import java.util.ArrayList;
import java.util.List;

public class AssignWeeklyCartDayRequest {

    @NotBlank(message = "Day of week is required")
    private String dayOfWeek; // MONDAY, TUESDAY, etc.

    private List<WeeklyCartItemInput> items = new ArrayList<>();

    public AssignWeeklyCartDayRequest() {}

    public AssignWeeklyCartDayRequest(String dayOfWeek, List<WeeklyCartItemInput> items) {
        this.dayOfWeek = dayOfWeek;
        this.items = items;
    }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }
    public List<WeeklyCartItemInput> getItems() { return items; }
    public void setItems(List<WeeklyCartItemInput> items) { this.items = items; }
}

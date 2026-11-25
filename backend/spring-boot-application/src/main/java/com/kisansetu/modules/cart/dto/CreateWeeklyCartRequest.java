package com.kisansetu.modules.cart.dto;

import jakarta.validation.constraints.NotBlank;

public class CreateWeeklyCartRequest {

    @NotBlank(message = "Title is required")
    private String title = "My Weekly Produce Plan";

    public CreateWeeklyCartRequest() {}

    public CreateWeeklyCartRequest(String title) {
        this.title = title;
    }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
}

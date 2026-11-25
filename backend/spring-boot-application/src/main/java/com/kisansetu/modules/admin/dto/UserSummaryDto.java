package com.kisansetu.modules.admin.dto;

import com.kisansetu.modules.user.entity.Role;
import com.kisansetu.modules.user.entity.User;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

public class UserSummaryDto {

    private UUID id;
    private String phone;
    private String email;
    private String status;
    private List<String> roles;
    private Instant createdAt;

    public UserSummaryDto() {}

    public static UserSummaryDto fromEntity(User user) {
        UserSummaryDto dto = new UserSummaryDto();
        dto.setId(user.getId());
        dto.setPhone(user.getPhone());
        dto.setEmail(user.getEmail());
        dto.setStatus(user.getStatus());
        dto.setRoles(user.getRoles().stream().map(Role::getId).collect(Collectors.toList()));
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public List<String> getRoles() { return roles; }
    public void setRoles(List<String> roles) { this.roles = roles; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}

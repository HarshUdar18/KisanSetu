package com.kisansetu.auth.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "roles")
public class AuthRole {
    @Id
    @Column(length = 50)
    private String id;

    @Column(length = 255)
    private String description;

    public AuthRole() {}
    public AuthRole(String id, String description) {
        this.id = id;
        this.description = description;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}

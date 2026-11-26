package com.kisansetu.modules.hub.entity;

import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "hub_admin_assignments", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"hub_id", "admin_user_id"})
})
public class HubAdminAssignment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "hub_id", nullable = false)
    private Hub hub;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "admin_user_id", nullable = false)
    private User adminUser;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_by")
    private User assignedBy;

    @Column(name = "assigned_at", nullable = false)
    private Instant assignedAt = Instant.now();

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    public HubAdminAssignment() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public Hub getHub() { return hub; }
    public void setHub(Hub hub) { this.hub = hub; }

    public User getAdminUser() { return adminUser; }
    public void setAdminUser(User adminUser) { this.adminUser = adminUser; }

    public User getAssignedBy() { return assignedBy; }
    public void setAssignedBy(User assignedBy) { this.assignedBy = assignedBy; }

    public Instant getAssignedAt() { return assignedAt; }
    public void setAssignedAt(Instant assignedAt) { this.assignedAt = assignedAt; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}

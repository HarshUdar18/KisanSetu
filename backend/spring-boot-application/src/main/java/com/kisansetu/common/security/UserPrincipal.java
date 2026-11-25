package com.kisansetu.common.security;

import com.kisansetu.modules.user.entity.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

public class UserPrincipal implements UserDetails {

    private final UUID id;
    private final String phone;
    private final String email;
    private final String password;
    private final Set<String> roles;
    private final Collection<? extends GrantedAuthority> authorities;
    private final boolean active;

    public UserPrincipal(UUID id, String phone, String email, String password, Set<String> roles, boolean active) {
        this.id = id;
        this.phone = phone;
        this.email = email;
        this.password = password;
        this.roles = roles;
        this.authorities = roles.stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toSet());
        this.active = active;
    }

    public static UserPrincipal create(User user) {
        Set<String> roleNames = user.getRoles().stream()
                .map(r -> r.getId())
                .collect(Collectors.toSet());

        return new UserPrincipal(
                user.getId(),
                user.getPhone(),
                user.getEmail(),
                user.getPasswordHash(),
                roleNames,
                "ACTIVE".equalsIgnoreCase(user.getStatus())
        );
    }

    public UUID getId() {
        return id;
    }

    public String getPhone() {
        return phone;
    }

    public String getEmail() {
        return email;
    }

    public Set<String> getRoles() {
        return roles;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return phone != null ? phone : email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return active;
    }
}

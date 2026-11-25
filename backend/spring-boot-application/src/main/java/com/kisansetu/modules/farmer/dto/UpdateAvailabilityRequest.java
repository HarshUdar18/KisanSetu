package com.kisansetu.modules.farmer.dto;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class UpdateAvailabilityRequest {

    @NotNull(message = "isAvailable field is required")
    private Boolean isAvailable;

    private BigDecimal quantityAvailable;

    public UpdateAvailabilityRequest() {}

    public UpdateAvailabilityRequest(Boolean isAvailable, BigDecimal quantityAvailable) {
        this.isAvailable = isAvailable;
        this.quantityAvailable = quantityAvailable;
    }

    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }

    public BigDecimal getQuantityAvailable() { return quantityAvailable; }
    public void setQuantityAvailable(BigDecimal quantityAvailable) { this.quantityAvailable = quantityAvailable; }
}

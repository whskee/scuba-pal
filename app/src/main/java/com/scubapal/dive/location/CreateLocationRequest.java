package com.scubapal.dive.location;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record CreateLocationRequest(
        @NotBlank @Size(max = 160) String locationName,
        @Size(max = 1000) String description,
        @Size(max = 120) String city,
        @Size(max = 120) String state,
        @Size(max = 120) String country,
        @NotNull @DecimalMin("-90.0") @DecimalMax("90.0") BigDecimal latitude,
        @NotNull @DecimalMin("-180.0") @DecimalMax("180.0") BigDecimal longitude,
        @Size(max = 80) String difficultyLevel
) {
}

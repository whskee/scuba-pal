package com.scubapal.shared.domain;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

import org.hibernate.annotations.UpdateTimestamp;

@Getter
@Setter
@MappedSuperclass
public abstract class AuditableEntity extends CreatedEntity {

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}

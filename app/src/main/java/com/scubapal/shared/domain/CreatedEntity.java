package com.scubapal.shared.domain;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

@Getter
@Setter
@MappedSuperclass
public abstract class CreatedEntity extends BaseEntity {

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}

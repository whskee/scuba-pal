package com.social.scuba_pal.shared.domain;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@MappedSuperclass
public abstract class SoftDeletableAuditableEntity extends AuditableEntity {

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}

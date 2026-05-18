package com.scubapal.identity.role;

import com.scubapal.shared.domain.AuditableEntity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "role_id"))
@Table(schema = "identity", name = "roles")
public class Role extends AuditableEntity {

    @Column(name = "role_name", nullable = false, unique = true)
    private String name;

    @Column(name = "role_description")
    private String description;
}

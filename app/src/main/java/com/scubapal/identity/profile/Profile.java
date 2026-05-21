package com.scubapal.identity.profile;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

import com.scubapal.identity.user.User;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.shared.domain.AuditableEntity;
import com.scubapal.shared.domain.Gender;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "profile_id"))
@Table(schema = "identity", name = "profiles")
public class Profile extends AuditableEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender")
    private Gender gender;

    @Column(name = "phone_number")
    private String phoneNumber;

    private String city;
    private String state;
    private String country;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(name = "visibility_status", nullable = false)
    private VisibilityStatus visibilityStatus = VisibilityStatus.PUBLIC;

    @Column(name = "dive_count", nullable = false)
    private Integer diveCount = 0;

    private String bio;

    @Column(name = "profile_image_url", length = 500)
    private String profileImageUrl;
}

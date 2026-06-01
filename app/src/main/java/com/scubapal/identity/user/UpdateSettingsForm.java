package com.scubapal.identity.user;

import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.PositiveOrZero;

public class UpdateSettingsForm {
    @Size(max = 500)
    private String profileImageUrl;
    @Size(max = 400)
    private String bio;
    @Size(max = 120)
    private String city;
    @Size(max = 120)
    private String country;
    @PositiveOrZero
    private Integer diveCount;
    private String currentPassword;
    private String newPassword;
    private String confirmPassword;
    public String getProfileImageUrl() { return profileImageUrl; }
    public void setProfileImageUrl(String profileImageUrl) { this.profileImageUrl = profileImageUrl; }
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public Integer getDiveCount() { return diveCount; }
    public void setDiveCount(Integer diveCount) { this.diveCount = diveCount; }
    public String getCurrentPassword() { return currentPassword; }
    public void setCurrentPassword(String currentPassword) { this.currentPassword = currentPassword; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
}

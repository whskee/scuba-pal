package com.social.scuba_pal.identity.user;

public record UserView(
        Long id,
        String username,
        String firstName,
        String lastName,
        String email,
        String role,
        String city,
        String country,
        Integer diveCount,
        String bio,
        String profileImageUrl
) {
    public String displayName() {
        String name = ((firstName == null ? "" : firstName) + " " + (lastName == null ? "" : lastName)).trim();
        return name.isBlank() ? username : name;
    }

    public String initials() {
        String source = displayName();
        if (source == null || source.isBlank()) {
            return "D";
        }
        String[] parts = source.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0].substring(0, 1).toUpperCase();
        }
        return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
    }

    public String locationDisplay() {
        boolean hasCity = city != null && !city.isBlank();
        boolean hasCountry = country != null && !country.isBlank();
        if (hasCity && hasCountry) {
            return city + ", " + country;
        }
        if (hasCity) {
            return city;
        }
        if (hasCountry) {
            return country;
        }
        return "Location not set";
    }
}

import SwiftUI

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    var user: User
    var onSave: (ProfileUpdate) async -> Void

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var city = ""
    @State private var state = ""
    @State private var country = ""
    @State private var bio = ""
    @State private var imageURL = ""
    @State private var diveCount = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FloatingTextField(title: "First name", text: $firstName, systemImage: "person.fill", textContentType: .givenName)
                    FloatingTextField(title: "Last name", text: $lastName, systemImage: "person.text.rectangle.fill", textContentType: .familyName)
                    FloatingTextField(title: "City", text: $city, systemImage: "building.2.fill")
                    FloatingTextField(title: "State", text: $state, systemImage: "map.fill")
                    FloatingTextField(title: "Country", text: $country, systemImage: "globe.americas.fill")
                    FloatingTextField(title: "Profile image URL", text: $imageURL, systemImage: "photo.fill", keyboardType: .URL)
                    FloatingTextField(title: "Dive count", text: $diveCount, systemImage: "number", keyboardType: .numberPad)
                    ProfileBioEditor(text: $bio)
                    ScubaButton(title: "Save profile", systemImage: "checkmark.circle.fill", isLoading: isSaving, action: save)
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: populateFields)
        }
    }

    private func populateFields() {
        firstName = user.firstName ?? ""
        lastName = user.lastName ?? ""
        city = user.city ?? ""
        state = user.state ?? ""
        country = user.country ?? ""
        bio = user.bio ?? ""
        imageURL = user.profileImageUrl ?? ""
        diveCount = "\(user.diveCount)"
    }

    private func save() {
        isSaving = true
        let update = ProfileUpdate(
            firstName: firstName.nilIfBlank,
            lastName: lastName.nilIfBlank,
            phoneNumber: nil,
            city: city.nilIfBlank,
            state: state.nilIfBlank,
            country: country.nilIfBlank,
            bio: bio.nilIfBlank,
            diveCount: Int(diveCount),
            profileImageUrl: imageURL.nilIfBlank
        )
        Task {
            await onSave(update)
            isSaving = false
            dismiss()
        }
    }
}

private struct ProfileBioEditor: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bio")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(ScubaTheme.muted)
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
                .foregroundStyle(ScubaTheme.ink)
                .padding(10)
                .background(ScubaTheme.surface.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(ScubaTheme.border, lineWidth: 1))
        }
    }
}

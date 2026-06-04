import SwiftUI

struct FloatingTextField: View {
    var title: String
    @Binding var text: String
    var systemImage: String
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ScubaTheme.primary)
                .frame(width: 22)
            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .foregroundStyle(ScubaTheme.ink)
            .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(ScubaTheme.surface.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ScubaTheme.border, lineWidth: 1)
        )
    }
}

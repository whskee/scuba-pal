import Combine
import SwiftUI

struct ToastState: Identifiable, Equatable {
    let id = UUID()
    var message: String
    var systemImage: String
}

@MainActor
final class AppUIStore: ObservableObject {
    @Published var toast: ToastState?

    func showToast(_ message: String, systemImage: String = "checkmark.circle.fill") {
        let toast = ToastState(message: message, systemImage: systemImage)
        withAnimation(.snappy(duration: 0.25)) { self.toast = toast }
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.4))
            guard self?.toast?.id == toast.id else { return }
            withAnimation(.snappy(duration: 0.22)) { self?.toast = nil }
        }
    }
}

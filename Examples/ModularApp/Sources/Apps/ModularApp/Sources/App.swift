import SwiftUI
import DesignSystem
import UIKit
import Onboarding

@main
struct App: SwiftUI.App {
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environment(\.design, Design.shared)
        }.onChange(of: scenePhase, initial: true) { oldPhase, newPhase in
            // Monitoring the app's lifecycle changes
//            guard oldPhase != newPhase else { return }
            switch newPhase {
            case .active:
                Design.shared.setup()
            case .inactive:
                Design.shared.setup()
            case .background:
                print("App is in the background")
            @unknown default:
                print("Unknown state")
            }
        }
    }
}

public extension Design {
    @MainActor func setup() {
        typography.register(for: .onboardingCustomTitle) {
            Typography(value: "Test value")
        }
    }
}

struct ContentView: View {
    var body: some View {
        TestView()
    }
}

#Preview {
    ContentView()
}

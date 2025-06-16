import SwiftUI
import DesignSystem

public struct OnboardingView: View {
    @Environment(\.design) var design
    public init() {}
    public var body: some View {
        VStack {
            Text("Welcome to the Onboarding Screen")
            Text(design.typography.onboardingCustomTitle.temporaryValue)
        }
    }
}

public extension Typography.Key {
    static var onboardingCustomTitle: Self { "onboardingCustomTitle" }
}

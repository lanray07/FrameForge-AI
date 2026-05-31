import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedCreatorType: CreatorType = .founder
    @State private var selectedPrimaryUse: PrimaryUse = .productLaunches

    private let columns = [
        GridItem(.adaptive(minimum: 145), spacing: 12)
    ]

    var body: some View {
        ZStack {
            PremiumBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FrameForge AI")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.72)

                        Text("Make every screenshot look launch-ready.")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .padding(.top, 48)

                    selectionSection(
                        title: "Creator Type",
                        values: CreatorType.allCases,
                        selection: $selectedCreatorType
                    )

                    selectionSection(
                        title: "Primary Use",
                        values: PrimaryUse.allCases,
                        selection: $selectedPrimaryUse
                    )

                    UpgradeBanner()

                    PrimaryGradientButton(title: "Create Workspace", systemImage: "sparkles") {
                        appState.completeOnboarding(
                            creatorType: selectedCreatorType,
                            primaryUse: selectedPrimaryUse
                        )
                    }
                    .padding(.bottom, 34)
                }
                .padding(.horizontal, 22)
            }
        }
    }

    private func selectionSection<Value: RawRepresentable & CaseIterable & Identifiable & Equatable>(
        title: String,
        values: [Value],
        selection: Binding<Value>
    ) -> some View where Value.RawValue == String {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: title)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(values) { value in
                    let isSelected = selection.wrappedValue == value

                    Button {
                        selection.wrappedValue = value
                    } label: {
                        Text(value.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isSelected ? Color.black : Color.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                isSelected
                                ? Color.cyan
                                : Color.white.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

import SwiftUI

struct PremiumBackground: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            RadialGradient(
                colors: [Color.cyan.opacity(0.24), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 460
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.orange.opacity(0.18), Color.clear],
                center: .bottomTrailing,
                startRadius: 40,
                endRadius: 520
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [Color.black.opacity(0.1), Color.black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    var strokeOpacity: Double = 0.18

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: 18)
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = 24, strokeOpacity: Double = 0.18) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius, strokeOpacity: strokeOpacity))
    }
}

struct PrimaryGradientButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        colors: [Color.cyan, Color.white, Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct SectionHeader: View {
    let title: String
    var trailing: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.56))
            }
        }
    }
}

struct MetricPill: View {
    let metric: DashboardMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: metric.systemImage)
                .font(.title2)
                .foregroundStyle(.cyan)

            Text(metric.value)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(metric.title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.62))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .glassPanel(cornerRadius: 20)
    }
}

struct QuickActionTile: View {
    let action: QuickAction

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: action.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.85), Color.purple.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(action.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(action.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .padding(18)
        .glassPanel(cornerRadius: 22)
    }
}

struct ProjectCard: View {
    let project: DashboardProject

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.85), Color.orange.opacity(0.78)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 66, height: 84)
                .overlay {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title2)
                        .foregroundStyle(.black.opacity(0.72))
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(project.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(project.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.58))

                Text(project.template)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.cyan)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.white.opacity(0.42))
        }
        .padding(16)
        .glassPanel(cornerRadius: 22)
    }
}

struct TemplateCard: View {
    let template: FrameForgeTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.88), Color.cyan.opacity(0.72), Color.purple.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 116)
                .overlay(alignment: .bottomLeading) {
                    Text(template.style.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.black.opacity(0.72))
                        .padding(10)
                }

            Text(template.name)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(template.output)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.58))
                .lineLimit(1)
        }
        .frame(width: 190, alignment: .leading)
        .padding(14)
        .glassPanel(cornerRadius: 22)
    }
}

struct ExportCard: View {
    let format: ExportFormat
    let size: String

    var body: some View {
        HStack {
            Image(systemName: "arrow.down.doc.fill")
                .font(.title2)
                .foregroundStyle(.cyan)
                .frame(width: 46, height: 46)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(format.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(size)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.58))
            }

            Spacer()
        }
        .padding(16)
        .glassPanel(cornerRadius: 20)
    }
}

struct DesignVariationCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black, Color.cyan.opacity(0.55), Color.orange.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 180)
                .overlay {
                    DeviceMockupView(device: "iPhone", title: title)
                        .padding(22)
                }

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.58))
        }
        .padding(14)
        .glassPanel(cornerRadius: 24)
    }
}

struct GradientPicker: View {
    @Binding var selectedGradient: String

    private let gradients = ["Launch Neon", "Black Diamond", "Keynote Glass", "Creator Pop"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Background")

            HStack(spacing: 12) {
                ForEach(gradients, id: \.self) { gradient in
                    Button {
                        selectedGradient = gradient
                    } label: {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(fill(for: gradient))
                            .frame(height: 54)
                            .overlay {
                                if selectedGradient == gradient {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(gradient)
                }
            }
        }
    }

    private func fill(for gradient: String) -> LinearGradient {
        switch gradient {
        case "Black Diamond":
            return LinearGradient(colors: [.black, .gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Keynote Glass":
            return LinearGradient(colors: [.white.opacity(0.9), .cyan.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Creator Pop":
            return LinearGradient(colors: [.orange, .pink, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.cyan, .purple, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct UpgradeBanner: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 3) {
                Text("Pro Creator")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Unlimited exports, premium templates, AI assistant, voice input, and App Store sets.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .glassPanel(cornerRadius: 22)
    }
}

struct EmptyStateView: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.cyan)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .glassPanel(cornerRadius: 24)
    }
}

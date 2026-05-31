import SwiftUI

struct DeviceMockupView: View {
    let device: String
    let title: String

    var body: some View {
        Group {
            switch device {
            case "MacBook":
                macBook
            case "iPad":
                tablet
            case "Desktop":
                desktop
            case "Browser":
                browserWindow
            case "Apple Watch":
                watch
            default:
                phone
            }
        }
        .shadow(color: .cyan.opacity(0.28), radius: 24, x: 0, y: 18)
    }

    private var phone: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(screenGradient)
                    .padding(8)
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(Color.black.opacity(0.72))
                            .frame(width: 78, height: 22)
                            .padding(.top, 14)
                    }
            )
            .overlay(contentOverlay.padding(22))
            .aspectRatio(0.48, contentMode: .fit)
    }

    private var tablet: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(screenGradient)
                    .padding(10)
            )
            .overlay(contentOverlay.padding(30))
            .aspectRatio(0.72, contentMode: .fit)
    }

    private var macBook: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(screenGradient)
                        .padding(8)
                )
                .overlay(contentOverlay.padding(24))
                .aspectRatio(1.55, contentMode: .fit)

            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.white.opacity(0.26))
                .frame(height: 12)
        }
    }

    private var desktop: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(screenGradient)
                        .padding(8)
                )
                .overlay(contentOverlay.padding(24))
                .aspectRatio(1.55, contentMode: .fit)

            Capsule()
                .fill(Color.white.opacity(0.24))
                .frame(width: 92, height: 10)
        }
    }

    private var browserWindow: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Circle().fill(Color.red.opacity(0.82)).frame(width: 9, height: 9)
                Circle().fill(Color.yellow.opacity(0.82)).frame(width: 9, height: 9)
                Circle().fill(Color.green.opacity(0.82)).frame(width: 9, height: 9)
                Spacer()
            }
            .padding(12)
            .background(Color.white.opacity(0.12))

            Rectangle()
                .fill(screenGradient)
                .overlay(contentOverlay.padding(24))
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .aspectRatio(1.45, contentMode: .fit)
    }

    private var watch: some View {
        RoundedRectangle(cornerRadius: 38, style: .continuous)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(screenGradient)
                    .padding(8)
            )
            .overlay(contentOverlay.padding(20))
            .aspectRatio(0.82, contentMode: .fit)
    }

    private var screenGradient: LinearGradient {
        LinearGradient(
            colors: [Color.black, Color.cyan.opacity(0.55), Color.orange.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var contentOverlay: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .frame(height: 12)

            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.14))
        }
    }
}

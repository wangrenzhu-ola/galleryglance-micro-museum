import SwiftUI

struct GalleryBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.84, blue: 0.61),
                Color(red: 0.84, green: 0.72, blue: 0.55),
                Color(red: 0.34, green: 0.27, blue: 0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color(red: 1.0, green: 0.93, blue: 0.74).opacity(0.48))
                .frame(width: 240, height: 240)
                .blur(radius: 12)
                .offset(x: 70, y: -90)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(Color(red: 0.42, green: 0.18, blue: 0.12).opacity(0.30))
                .frame(width: 280, height: 280)
                .blur(radius: 24)
                .offset(x: -120, y: 120)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct GlassSurface<Content: View>: View {
    let radius: CGFloat
    let interactive: Bool
    let content: Content

    init(radius: CGFloat = 24, interactive: Bool = false, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.interactive = interactive
        self.content = content()
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            content
                .padding(16)
                .glassEffect(interactive ? .regular.interactive() : .regular, in: .rect(cornerRadius: radius))
        } else {
            content
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }
}

struct ArtworkFrame: View {
    let artwork: ArtworkCard
    let clue: ClueType

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(frameGradient)
                .frame(height: 270)
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color(red: 0.42, green: 0.25, blue: 0.12), lineWidth: 10)
                        .padding(8)
                }
                .overlay(alignment: .center) {
                    artworkGlyph
                }
                .shadow(color: .black.opacity(0.20), radius: 18, y: 10)

            MagnifierClueOverlay(clue: clue)
                .padding(18)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Framed artwork slot for \(artwork.title), with a \(clue.displayName) magnifier clue overlay")
    }

    private var frameGradient: LinearGradient {
        switch artwork.localImageSlot {
        case "courtyard-blue-frame":
            LinearGradient(colors: [Color(red: 0.29, green: 0.42, blue: 0.60), Color(red: 0.82, green: 0.76, blue: 0.63)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "red-thread-symbol":
            LinearGradient(colors: [Color(red: 0.90, green: 0.81, blue: 0.66), Color(red: 0.58, green: 0.12, blue: 0.09)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            LinearGradient(colors: [Color(red: 0.96, green: 0.68, blue: 0.34), Color(red: 0.28, green: 0.19, blue: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var artworkGlyph: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.20))
                .frame(width: 180, height: 155)
                .rotationEffect(.degrees(-4))
            GalleryStillLifeShape(slot: artwork.localImageSlot)
                .stroke(Color.white.opacity(0.86), style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
                .frame(width: 170, height: 145)
            Text(artwork.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.94))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.black.opacity(0.22), in: Capsule())
                .offset(y: 94)
        }
    }
}

struct MagnifierClueOverlay: View {
    let clue: ClueType

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: clue.systemImage)
                .font(.headline)
            VStack(alignment: .leading, spacing: 2) {
                Text("Look clue")
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
                    .opacity(0.75)
                Text(clue.displayName)
                    .font(.headline)
            }
        }
        .foregroundStyle(Color(red: 0.19, green: 0.13, blue: 0.10))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 1.0, green: 0.91, blue: 0.69).opacity(0.92), in: Capsule())
        .overlay(alignment: .topTrailing) {
            Circle()
                .stroke(Color(red: 0.28, green: 0.17, blue: 0.10).opacity(0.55), lineWidth: 2)
                .frame(width: 48, height: 48)
                .offset(x: 18, y: -18)
        }
    }
}

struct GalleryStillLifeShape: Shape {
    let slot: String

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        switch slot {
        case "courtyard-blue-frame":
            path.move(to: CGPoint(x: w * 0.12, y: h * 0.78))
            path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.20))
            path.move(to: CGPoint(x: w * 0.18, y: h * 0.22))
            path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.74))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.74))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.32))
        case "red-thread-symbol":
            path.move(to: CGPoint(x: w * 0.10, y: h * 0.62))
            path.addCurve(to: CGPoint(x: w * 0.88, y: h * 0.44), control1: CGPoint(x: w * 0.32, y: h * 0.20), control2: CGPoint(x: w * 0.60, y: h * 0.84))
            path.addRoundedRect(in: CGRect(x: w * 0.56, y: h * 0.20, width: w * 0.28, height: h * 0.18), cornerSize: CGSize(width: 8, height: 8))
        default:
            path.addEllipse(in: CGRect(x: w * 0.22, y: h * 0.28, width: w * 0.28, height: h * 0.40))
            path.move(to: CGPoint(x: w * 0.54, y: h * 0.30))
            path.addLine(to: CGPoint(x: w * 0.76, y: h * 0.30))
            path.addLine(to: CGPoint(x: w * 0.76, y: h * 0.70))
            path.addLine(to: CGPoint(x: w * 0.54, y: h * 0.70))
        }
        return path
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .font(.subheadline)
        .foregroundStyle(Color(red: 0.45, green: 0.12, blue: 0.08))
        .padding(12)
        .background(Color(red: 1.0, green: 0.88, blue: 0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}

struct SavedBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
            Text(message)
            Spacer(minLength: 0)
        }
        .font(.subheadline)
        .foregroundStyle(Color(red: 0.16, green: 0.34, blue: 0.20))
        .padding(12)
        .background(Color(red: 0.83, green: 0.94, blue: 0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

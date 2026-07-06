import SwiftUI

struct PremiumThemesView: View {
    @Environment(GalleryStore.self) private var galleryStore
    @Environment(PremiumStore.self) private var premiumStore
    @Binding var selectedTab: AppTab
    @State private var showFailureCopy = false

    var body: some View {
        ZStack {
            GalleryBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    themeShelfGrid
                    paywall
                    freeFlowReminder
                }
                .padding(20)
            }
        }
        .navigationTitle("Premium Themes")
        .toolbarTitleDisplayMode(.inline)
        .task {
            await premiumStore.loadProducts()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Premium Themes")
                .font(.largeTitle.bold())
            Text("Optional theme shelves add visual variety to your Micro Museum. The core free looking ritual is never locked.")
                .font(.body)
                .foregroundStyle(GalleryPalette.softInk)
        }
    }

    private var themeShelfGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: 12)], spacing: 12) {
            ForEach(galleryStore.themeShelves) { shelf in
                GlassSurface(radius: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: shelf.unlocked || premiumStore.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                            .font(.title2)
                            .foregroundStyle(shelf.unlocked || premiumStore.isUnlocked ? GalleryPalette.successText : GalleryPalette.oxide)
                        Text(shelf.name)
                            .font(.headline)
                        Text(shelf.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
                }
                .accessibilityLabel("Theme shelf \(shelf.name), \(shelf.unlocked || premiumStore.isUnlocked ? "unlocked" : "locked")")
            }
        }
    }

    private var paywall: some View {
        GlassSurface(radius: 28, interactive: true) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Premium Theme Pack", systemImage: premiumStore.isUnlocked ? "checkmark.seal.fill" : "sparkles")
                        .font(.headline)
                    Spacer()
                    Text(premiumStore.accessState.displayName)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial, in: Capsule())
                }

                Text(premiumStore.paywallSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let message = premiumStore.lastErrorMessage ?? (showFailureCopy ? "Purchase could not be completed. Your free gallery ritual is still available." : nil) {
                    ErrorBanner(message: message)
                }

                HStack(spacing: 12) {
                    Button("Purchase Premium Themes") {
                        Task {
                            await premiumStore.purchasePremiumThemes()
                            if premiumStore.isUnlocked {
                                try? galleryStore.unlockPremiumThemes()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Purchase Premium Themes with StoreKit 2")

                    Button("Restore Purchase") {
                        Task {
                            await premiumStore.restorePurchases()
                            if premiumStore.isUnlocked {
                                try? galleryStore.unlockPremiumThemes()
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Restore Premium Themes purchase")
                }

                Button("Simulate IAP Failure") {
                    showFailureCopy = true
                    Task { await premiumStore.purchasePremiumThemes(simulateFailure: true) }
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(GalleryPalette.oxide)
                .accessibilityLabel("Simulate IAP failure")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var freeFlowReminder: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Free flow remains open", systemImage: "leaf.fill")
                    .font(.headline)
                Text(AppCopy.privacyBoundary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("Return to Today Gallery Card") {
                    selectedTab = .today
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

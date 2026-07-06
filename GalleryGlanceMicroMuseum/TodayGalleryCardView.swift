import SwiftUI

struct TodayGalleryCardView: View {
    @Environment(GalleryStore.self) private var galleryStore
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack {
            GalleryBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    ArtworkFrame(artwork: galleryStore.todayArtwork, clue: galleryStore.todayArtwork.clueType)
                    storyCard
                    actionStack
                    privacyCard
                    if let message = galleryStore.lastErrorMessage {
                        ErrorBanner(message: message)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Today Gallery Card")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            Button("Premium") {
                selectedTab = .premium
            }
            .accessibilityLabel("Open Premium Themes")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today Gallery Card")
                .font(.largeTitle.bold())
            Text("Turn a short break into a quiet looking ritual: choose one clue, write one Eye Note, and keep building your private Micro Museum.")
                .font(.body)
                .foregroundStyle(GalleryPalette.softInk)
        }
        .accessibilityElement(children: .combine)
    }

    private var storyCard: some View {
        GlassSurface(radius: 28) {
            VStack(alignment: .leading, spacing: 12) {
                Label(galleryStore.todayArtwork.era, systemImage: "paintbrush.pointed.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(galleryStore.todayArtwork.title)
                    .font(.title2.bold())
                Text(galleryStore.todayArtwork.artist)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(galleryStore.todayArtwork.story)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Text(AppCopy.bundledContentDisclosure)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actionStack: some View {
        VStack(spacing: 12) {
            NavigationLink {
                LookClueChallengeView(selectedTab: $selectedTab, artworkID: galleryStore.todayArtwork.id)
            } label: {
                Label("Start Look Clue Challenge", systemImage: "magnifyingglass.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityLabel("Start Look Clue Challenge from Today Gallery Card")

            Button {
                selectedTab = .museum
            } label: {
                Label(galleryStore.hasNotes ? "Open My Micro Museum" : "View Empty Micro Museum", systemImage: "building.columns")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .accessibilityLabel("Open My Micro Museum")
        }
    }

    private var privacyCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Private by default", systemImage: "lock.fill")
                    .font(.headline)
                Text(AppCopy.privacyBoundary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

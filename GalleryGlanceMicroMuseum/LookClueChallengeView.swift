import SwiftUI

struct LookClueChallengeView: View {
    @Environment(GalleryStore.self) private var galleryStore
    @Binding var selectedTab: AppTab
    let artworkID: String

    @State private var selectedClue: ClueType
    @State private var errorMessage: String?

    init(selectedTab: Binding<AppTab>, artworkID: String) {
        _selectedTab = selectedTab
        self.artworkID = artworkID
        _selectedClue = State(initialValue: .color)
    }

    var body: some View {
        ZStack {
            GalleryBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if let artwork {
                        header(artwork)
                        ArtworkFrame(artwork: artwork, clue: selectedClue)
                        clueGrid
                        explanationCard
                        if let errorMessage {
                            ErrorBanner(message: errorMessage)
                        }
                        NavigationLink {
                            EyeNoteComposerView(
                                selectedTab: $selectedTab,
                                draft: EyeNoteDraft(artwork: artwork, chosenClue: selectedClue)
                            )
                        } label: {
                            Label("Continue to Eye Note Composer", systemImage: "square.and.pencil")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .simultaneousGesture(TapGesture().onEnded(saveSelectedClue))
                        .accessibilityLabel("Continue to Eye Note Composer with \(selectedClue.displayName) clue")
                    } else {
                        ErrorBanner(message: GalleryStoreError.artworkNotFound.localizedDescription)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Look Clue Challenge")
        .toolbarTitleDisplayMode(.inline)
        .onAppear {
            if let artwork {
                selectedClue = artwork.clueType
            }
        }
    }

    private var artwork: ArtworkCard? {
        galleryStore.artwork(with: artworkID)
    }

    private func header(_ artwork: ArtworkCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Look Clue Challenge")
                .font(.largeTitle.bold())
            Text("Choose how to look at \(artwork.title). This changes the card's active clue before you write your note.")
                .font(.body)
                .foregroundStyle(GalleryPalette.softInk)
        }
        .accessibilityElement(children: .combine)
    }

    private var clueGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            ForEach(ClueType.allCases) { clue in
                Button {
                    selectedClue = clue
                    saveSelectedClue()
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: clue.systemImage)
                            .font(.title2)
                        Text(clue.displayName)
                            .font(.headline)
                        Text(clue.challengeTitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
                    .padding(14)
                    .background(clue == selectedClue ? GalleryPalette.warmIvory : Color.white.opacity(0.35), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(clue == selectedClue ? GalleryPalette.oxide : .clear, lineWidth: 3)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select \(clue.displayName) clue")
                .accessibilityAddTraits(clue == selectedClue ? .isSelected : [])
            }
        }
    }

    private var explanationCard: some View {
        GlassSurface(radius: 28) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Selected clue: \(selectedClue.displayName)", systemImage: selectedClue.systemImage)
                    .font(.headline)
                Text(selectedClue.guideCopy)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Text("You can change this clue again in the composer before saving.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func saveSelectedClue() {
        do {
            _ = try galleryStore.updateClue(for: artworkID, clue: selectedClue)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

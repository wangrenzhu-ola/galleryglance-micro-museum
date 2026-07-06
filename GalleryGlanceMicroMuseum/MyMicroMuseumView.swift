import SwiftUI

struct MyMicroMuseumView: View {
    @Environment(GalleryStore.self) private var galleryStore
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack {
            GalleryBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if galleryStore.savedNotes.isEmpty && galleryStore.archivedNotes.isEmpty {
                        emptyState
                    } else {
                        notesSection(title: "Saved Eye Notes", notes: galleryStore.savedNotes, emptyCopy: "No saved Eye Notes yet.")
                        notesSection(title: "Archived Eye Notes", notes: galleryStore.archivedNotes, emptyCopy: "Archived notes will appear here.")
                    }
                    privacyCard
                    Button {
                        selectedTab = .premium
                    } label: {
                        Label("Open Premium Themes", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(20)
            }
        }
        .navigationTitle("My Micro Museum")
        .toolbarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Micro Museum")
                .font(.largeTitle.bold())
            Text("Review your saved looking moments, edit them, or archive older notes without leaving the local device boundary.")
                .font(.body)
                .foregroundStyle(GalleryPalette.softInk)
        }
    }

    private var emptyState: some View {
        GlassSurface(radius: 30) {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "building.columns.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(GalleryPalette.oxide)
                Text("Your Micro Museum is quiet for now.")
                    .font(.title2.bold())
                Text("Create one Eye Note from Today Gallery Card. The saved note will reappear here after you reopen the app.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Button {
                    selectedTab = .today
                } label: {
                    Label("Start Today Gallery Card", systemImage: "rectangle.stack.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel("Start Today Gallery Card from empty My Micro Museum")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func notesSection(title: String, notes: [EyeNote], emptyCopy: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
            if notes.isEmpty {
                Text(emptyCopy)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.30), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ForEach(notes) { note in
                    noteRow(note)
                }
            }
        }
    }

    private func noteRow(_ note: EyeNote) -> some View {
        let artwork = galleryStore.artwork(with: note.artworkId)
        return NavigationLink {
            EyeNoteComposerView(selectedTab: $selectedTab, note: note)
        } label: {
            GlassSurface(radius: 24, interactive: true) {
                HStack(alignment: .top, spacing: 14) {
                    miniArtwork(artwork: artwork, clue: note.chosenClue)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(artwork?.title ?? "Unknown Artwork")
                            .font(.headline)
                        Text("\(note.chosenClue.displayName) • \(note.mood.displayName) • \(note.status.displayName)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(note.observation)
                            .font(.subheadline)
                            .lineLimit(3)
                            .foregroundStyle(GalleryPalette.ink)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Eye Note for \(artwork?.title ?? "unknown artwork")")
    }

    private func miniArtwork(artwork: ArtworkCard?, clue: ClueType) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(GalleryPalette.linen)
            .frame(width: 72, height: 86)
            .overlay {
                Image(systemName: clue.systemImage)
                    .foregroundStyle(GalleryPalette.oxide)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(GalleryPalette.umber, lineWidth: 4)
            }
            .accessibilityHidden(true)
    }

    private var privacyCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Local archive", systemImage: "lock.doc.fill")
                    .font(.headline)
                Text(AppCopy.privacyBoundary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

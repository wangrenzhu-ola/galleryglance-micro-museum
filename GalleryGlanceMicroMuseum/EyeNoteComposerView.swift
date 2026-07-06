import SwiftUI

struct EyeNoteComposerView: View {
    @Environment(GalleryStore.self) private var galleryStore
    @Binding var selectedTab: AppTab
    @State private var draft: EyeNoteDraft
    @State private var editingNoteID: UUID?
    @State private var originalCreatedAt: Date?
    @State private var errorMessage: String?
    @State private var savedMessage: String?
    @State private var helperSkipped = false

    init(selectedTab: Binding<AppTab>, draft: EyeNoteDraft) {
        _selectedTab = selectedTab
        _draft = State(initialValue: draft)
        _editingNoteID = State(initialValue: nil)
        _originalCreatedAt = State(initialValue: nil)
    }

    init(selectedTab: Binding<AppTab>, note: EyeNote) {
        _selectedTab = selectedTab
        _draft = State(initialValue: EyeNoteDraft(note: note))
        _editingNoteID = State(initialValue: note.id)
        _originalCreatedAt = State(initialValue: note.createdAt)
    }

    var body: some View {
        ZStack {
            GalleryBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    if let errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    if let savedMessage {
                        SavedBanner(message: savedMessage)
                    }
                    if let artwork {
                        ArtworkFrame(artwork: artwork, clue: draft.chosenClue)
                    }
                    helperCard
                    editorFields
                    actions
                }
                .padding(20)
            }
        }
        .navigationTitle("Eye Note Composer")
        .toolbarTitleDisplayMode(.inline)
    }

    private var artwork: ArtworkCard? {
        galleryStore.artwork(with: draft.artworkId)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(editingNoteID == nil ? "Create an Eye Note" : "Edit Eye Note")
                .font(.largeTitle.bold())
            Text("The helper is local, editable, and optional. Your note is saved only after you confirm.")
                .font(.body)
                .foregroundStyle(Color(red: 0.22, green: 0.16, blue: 0.12))
        }
        .accessibilityElement(children: .combine)
    }

    private var helperCard: some View {
        GlassSurface(radius: 28) {
            VStack(alignment: .leading, spacing: 12) {
                Label("On-device prompt helper", systemImage: "wand.and.stars")
                    .font(.headline)
                TextEditor(text: $draft.helperPrompt)
                    .frame(minHeight: 92)
                    .padding(8)
                    .background(Color.white.opacity(0.40), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityLabel("Editable local observation prompt")
                HStack(spacing: 12) {
                    Button("Use Prompt") {
                        usePrompt()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Use editable helper prompt as a starting observation")

                    Button("Skip Helper") {
                        helperSkipped = true
                        if draft.observation.isEmpty {
                            draft.observation = ""
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Skip prompt helper and write manually")
                }
                if helperSkipped {
                    Text("Helper skipped. Manual note entry is fully available.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var editorFields: some View {
        GlassSurface(radius: 28) {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Look clue", selection: $draft.chosenClue) {
                    ForEach(ClueType.allCases) { clue in
                        Text(clue.displayName).tag(clue)
                    }
                }
                .accessibilityLabel("Chosen clue")

                Picker("Mood", selection: $draft.mood) {
                    ForEach(EyeMood.allCases) { mood in
                        Text(mood.displayName).tag(mood)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Eye Note mood")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your observation")
                        .font(.headline)
                    TextEditor(text: $draft.observation)
                        .frame(minHeight: 132)
                        .padding(8)
                        .background(Color.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .accessibilityLabel("Private Eye Note observation stored on this device")
                    HStack {
                        Text("Required • \(draft.observation.count)/360")
                            .font(.caption)
                            .foregroundStyle(draft.observation.count > 360 ? .red : .secondary)
                        Spacer()
                        Button("Fill Manual Example") {
                            draft.observation = "The warm edge makes the quiet room feel almost awake. I noticed the small contrast before the story."
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }

    private var actions: some View {
        GlassSurface(radius: 28, interactive: true) {
            VStack(spacing: 12) {
                Button(action: saveNote) {
                    Label(editingNoteID == nil ? "Save Eye Note" : "Save Changes", systemImage: "tray.and.arrow.down.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel(editingNoteID == nil ? "Save Eye Note" : "Save edited Eye Note")

                Button("Simulate Save Failure") {
                    galleryStore.simulateNextSaveFailure = true
                    saveNote()
                }
                .font(.caption)
                .buttonStyle(.plain)
                .accessibilityLabel("Simulate local save failure")

                if editingNoteID != nil {
                    HStack(spacing: 12) {
                        Button("Archive Eye Note", action: archiveNote)
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Archive Eye Note")
                        Button("Delete Eye Note", role: .destructive, action: deleteNote)
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Delete Eye Note")
                    }
                }

                Button("Open My Micro Museum") {
                    selectedTab = .museum
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func usePrompt() {
        draft.observation = draft.helperPrompt
        helperSkipped = false
    }

    private func saveNote() {
        let note = draft.makeNote(id: editingNoteID, createdAt: originalCreatedAt, status: .saved)
        do {
            try galleryStore.save(note)
            editingNoteID = note.id
            originalCreatedAt = note.createdAt
            errorMessage = nil
            savedMessage = "Eye Note saved to My Micro Museum."
        } catch {
            errorMessage = error.localizedDescription
            savedMessage = nil
        }
    }

    private func archiveNote() {
        guard let editingNoteID else { return }
        do {
            try galleryStore.archive(id: editingNoteID)
            errorMessage = nil
            savedMessage = "Eye Note archived. You can still review it in My Micro Museum."
        } catch {
            errorMessage = error.localizedDescription
            savedMessage = nil
        }
    }

    private func deleteNote() {
        guard let editingNoteID else { return }
        do {
            try galleryStore.delete(id: editingNoteID)
            errorMessage = nil
            savedMessage = "Eye Note deleted from this device."
            self.editingNoteID = nil
            draft.observation = ""
        } catch {
            errorMessage = error.localizedDescription
            savedMessage = nil
        }
    }
}

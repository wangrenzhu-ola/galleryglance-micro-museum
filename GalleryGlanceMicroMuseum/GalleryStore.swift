import Foundation
import Observation

enum GalleryStoreError: LocalizedError, Equatable {
    case emptyObservation
    case observationTooLong
    case simulatedSaveFailure
    case noteNotFound
    case artworkNotFound

    var errorDescription: String? {
        switch self {
        case .emptyObservation:
            "Add one observation or skip the helper and write your own sentence before saving."
        case .observationTooLong:
            "Keep the Eye Note under 360 characters, then try saving again."
        case .simulatedSaveFailure:
            "The Eye Note could not be saved. Review the fields and try again."
        case .noteNotFound:
            "This Eye Note is no longer available. Return to My Micro Museum and choose another note."
        case .artworkNotFound:
            "This artwork card is unavailable. Return to Today Gallery Card and start again."
        }
    }
}

@Observable
final class GalleryStore {
    private struct PersistedState: Codable {
        var artworkCards: [ArtworkCard]
        var notes: [EyeNote]
        var themeShelves: [ThemeShelf]
        var lastSelectedArtworkID: String?
    }

    private(set) var artworkCards: [ArtworkCard]
    private(set) var notes: [EyeNote] = []
    private(set) var themeShelves: [ThemeShelf]
    var lastSelectedArtworkID: String?
    var simulateNextSaveFailure = false
    var lastErrorMessage: String?

    private let storageURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(storageURL: URL? = nil) {
        self.artworkCards = ArtworkCard.seedCards
        self.themeShelves = ThemeShelf.defaults
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    var todayArtwork: ArtworkCard {
        if let lastSelectedArtworkID,
           let selected = artwork(with: lastSelectedArtworkID) {
            return selected
        }
        let index = abs(Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0) % max(artworkCards.count, 1)
        return artworkCards[index]
    }

    var savedNotes: [EyeNote] {
        notes
            .filter { $0.status == .saved }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var archivedNotes: [EyeNote] {
        notes
            .filter { $0.status == .archived }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var hasNotes: Bool { !notes.isEmpty }

    func artwork(with id: String) -> ArtworkCard? {
        artworkCards.first { $0.id == id }
    }

    func note(with id: UUID) -> EyeNote? {
        notes.first { $0.id == id }
    }

    func updateClue(for artworkID: String, clue: ClueType) throws -> ArtworkCard {
        guard let index = artworkCards.firstIndex(where: { $0.id == artworkID }) else {
            throw GalleryStoreError.artworkNotFound
        }
        artworkCards[index].clueType = clue
        lastSelectedArtworkID = artworkID
        try persist()
        return artworkCards[index]
    }

    func save(_ note: EyeNote) throws {
        if simulateNextSaveFailure {
            simulateNextSaveFailure = false
            lastErrorMessage = GalleryStoreError.simulatedSaveFailure.localizedDescription
            throw GalleryStoreError.simulatedSaveFailure
        }
        try validate(note)
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        } else {
            notes.append(note)
        }
        lastSelectedArtworkID = note.artworkId
        try persist()
        lastErrorMessage = nil
    }

    func archive(id: UUID) throws {
        guard let index = notes.firstIndex(where: { $0.id == id }) else {
            throw GalleryStoreError.noteNotFound
        }
        notes[index].status = .archived
        try persist()
    }

    func delete(id: UUID) throws {
        let originalCount = notes.count
        notes.removeAll { $0.id == id }
        guard notes.count < originalCount else {
            throw GalleryStoreError.noteNotFound
        }
        try persist()
    }

    func unlockPremiumThemes() throws {
        themeShelves = themeShelves.map { shelf in
            ThemeShelf(name: shelf.name, unlocked: true, description: shelf.description)
        }
        try persist()
    }

    func resetForPreview() {
        artworkCards = ArtworkCard.seedCards
        notes = []
        themeShelves = ThemeShelf.defaults
        lastSelectedArtworkID = nil
        lastErrorMessage = nil
    }

    private func validate(_ note: EyeNote) throws {
        let trimmed = note.observation.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            lastErrorMessage = GalleryStoreError.emptyObservation.localizedDescription
            throw GalleryStoreError.emptyObservation
        }
        if note.observation.count > 360 {
            lastErrorMessage = GalleryStoreError.observationTooLong.localizedDescription
            throw GalleryStoreError.observationTooLong
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            let state = try decoder.decode(PersistedState.self, from: data)
            artworkCards = state.artworkCards.isEmpty ? ArtworkCard.seedCards : state.artworkCards
            notes = state.notes
            themeShelves = state.themeShelves.isEmpty ? ThemeShelf.defaults : state.themeShelves
            lastSelectedArtworkID = state.lastSelectedArtworkID
        } catch {
            lastErrorMessage = "Saved museum data could not be read. You can keep using the starter gallery."
        }
    }

    private func persist() throws {
        let directory = storageURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let state = PersistedState(
            artworkCards: artworkCards,
            notes: notes,
            themeShelves: themeShelves,
            lastSelectedArtworkID: lastSelectedArtworkID
        )
        let data = try encoder.encode(state)
        try data.write(to: storageURL, options: [.atomic])
    }

    private static func defaultStorageURL() -> URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return directory
            .appendingPathComponent("GalleryGlanceMicroMuseum", isDirectory: true)
            .appendingPathComponent("museum-state.json")
    }
}

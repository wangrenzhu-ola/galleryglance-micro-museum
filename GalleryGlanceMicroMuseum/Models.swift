import Foundation

enum ClueType: String, Codable, CaseIterable, Identifiable, Hashable {
    case color
    case composition
    case symbol

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .color: "Color"
        case .composition: "Composition"
        case .symbol: "Symbol"
        }
    }

    var challengeTitle: String {
        switch self {
        case .color: "Start with the warmest color"
        case .composition: "Trace the quiet diagonal"
        case .symbol: "Find the small repeated sign"
        }
    }

    var guideCopy: String {
        switch self {
        case .color: "Name one color that sets the room temperature, then notice where your eye rests."
        case .composition: "Follow the main line of movement before reading the story."
        case .symbol: "Pick one object or gesture that might carry meaning, even if you are not sure yet."
        }
    }

    var systemImage: String {
        switch self {
        case .color: "paintpalette.fill"
        case .composition: "square.split.diagonal.2x2.fill"
        case .symbol: "sparkle.magnifyingglass"
        }
    }
}

enum EyeMood: String, Codable, CaseIterable, Identifiable, Hashable {
    case calm
    case curious
    case bright
    case unsettled
    case reflective

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .calm: "Calm"
        case .curious: "Curious"
        case .bright: "Bright"
        case .unsettled: "Unsettled"
        case .reflective: "Reflective"
        }
    }
}

enum EyeNoteStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case saved
    case archived

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .saved: "Saved"
        case .archived: "Archived"
        }
    }
}

struct ArtworkCard: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var artist: String
    var era: String
    var localImageSlot: String
    var clueType: ClueType
    var story: String

    static let seedCards: [ArtworkCard] = [
        ArtworkCard(
            id: "amber-window-study",
            title: "Amber Window Study",
            artist: "GalleryGlance Studio",
            era: "Original local starter card",
            localImageSlot: "warm-window-frame",
            clueType: .color,
            story: "A quiet room is described through amber light, a cropped chair, and one blue edge near the frame. The card is bundled locally for eye-training practice."
        ),
        ArtworkCard(
            id: "blue-courtyard-pause",
            title: "Blue Courtyard Pause",
            artist: "GalleryGlance Studio",
            era: "Original local starter card",
            localImageSlot: "courtyard-blue-frame",
            clueType: .composition,
            story: "A small courtyard is simplified into blocks of blue shade and a diagonal path. Use it to practice seeing structure before story."
        ),
        ArtworkCard(
            id: "red-thread-table",
            title: "Red Thread on the Table",
            artist: "GalleryGlance Studio",
            era: "Original local starter card",
            localImageSlot: "red-thread-symbol",
            clueType: .symbol,
            story: "A red thread crosses a pale table beside a closed envelope. The meaning is intentionally open so your own observation comes first."
        )
    ]
}

struct EyeNote: Codable, Identifiable, Hashable {
    var id: UUID
    var artworkId: String
    var mood: EyeMood
    var observation: String
    var chosenClue: ClueType
    var helperPrompt: String
    var createdAt: Date
    var status: EyeNoteStatus

    init(
        id: UUID = UUID(),
        artworkId: String,
        mood: EyeMood,
        observation: String,
        chosenClue: ClueType,
        helperPrompt: String,
        createdAt: Date = Date(),
        status: EyeNoteStatus = .saved
    ) {
        self.id = id
        self.artworkId = artworkId
        self.mood = mood
        self.observation = observation
        self.chosenClue = chosenClue
        self.helperPrompt = helperPrompt
        self.createdAt = createdAt
        self.status = status
    }
}

struct EyeNoteDraft: Equatable {
    var artworkId: String
    var mood: EyeMood
    var observation: String
    var chosenClue: ClueType
    var helperPrompt: String

    init(artwork: ArtworkCard, chosenClue: ClueType? = nil) {
        let clue = chosenClue ?? artwork.clueType
        self.artworkId = artwork.id
        self.mood = .curious
        self.observation = ""
        self.chosenClue = clue
        self.helperPrompt = ObservationPromptHelper.prompt(for: artwork, clue: clue)
    }

    init(note: EyeNote) {
        artworkId = note.artworkId
        mood = note.mood
        observation = note.observation
        chosenClue = note.chosenClue
        helperPrompt = note.helperPrompt
    }

    func makeNote(id: UUID? = nil, createdAt: Date? = nil, status: EyeNoteStatus = .saved) -> EyeNote {
        EyeNote(
            id: id ?? UUID(),
            artworkId: artworkId,
            mood: mood,
            observation: observation,
            chosenClue: chosenClue,
            helperPrompt: helperPrompt,
            createdAt: createdAt ?? Date(),
            status: status
        )
    }
}

struct ThemeShelf: Codable, Identifiable, Hashable {
    var id: String { name }
    var name: String
    var unlocked: Bool
    var description: String

    static let defaults: [ThemeShelf] = [
        ThemeShelf(name: "Warm Gallery Lighting", unlocked: true, description: "Included frame colors and soft museum-card surfaces."),
        ThemeShelf(name: "Quiet Frame Stickers", unlocked: false, description: "Premium accent marks for saved Eye Notes."),
        ThemeShelf(name: "Evening Salon Pack", unlocked: false, description: "Premium darker wall tones for the Micro Museum.")
    ]
}

enum ObservationPromptHelper {
    static func prompt(for artwork: ArtworkCard, clue: ClueType) -> String {
        switch clue {
        case .color:
            "Look at \(artwork.title) for one minute. Which color feels closest to the light source, and which color feels like an echo?"
        case .composition:
            "Trace the first line your eye follows in \(artwork.title). Where does that line pause, turn, or disappear?"
        case .symbol:
            "Choose one object, gesture, or edge in \(artwork.title). What might it be asking you to notice before you know the answer?"
        }
    }
}

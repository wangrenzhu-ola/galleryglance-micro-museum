import XCTest
@testable import GalleryGlanceMicroMuseum

final class GalleryGlanceMicroMuseumTests: XCTestCase {
    func testSaveReloadEditArchiveAndDeleteEyeNote() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("museum-state.json")
        let store = GalleryStore(storageURL: url)
        let artwork = store.todayArtwork
        let updated = try store.updateClue(for: artwork.id, clue: .symbol)
        XCTAssertEqual(updated.clueType, .symbol)

        var draft = EyeNoteDraft(artwork: updated, chosenClue: .symbol)
        draft.observation = "The red edge feels like a quiet signal near the frame."
        let note = draft.makeNote()
        try store.save(note)
        XCTAssertEqual(store.savedNotes.count, 1)

        let reloaded = GalleryStore(storageURL: url)
        XCTAssertEqual(reloaded.savedNotes.first?.observation, note.observation)
        XCTAssertEqual(reloaded.todayArtwork.clueType, .symbol)

        var edited = note
        edited.observation = "The symbol feels intentional after I follow the warm edge."
        try reloaded.save(edited)
        XCTAssertEqual(reloaded.savedNotes.first?.observation, edited.observation)

        try reloaded.archive(id: edited.id)
        XCTAssertEqual(reloaded.savedNotes.count, 0)
        XCTAssertEqual(reloaded.archivedNotes.count, 1)

        try reloaded.delete(id: edited.id)
        XCTAssertTrue(reloaded.archivedNotes.isEmpty)
    }

    func testValidationAndSimulatedFailureHaveRecoveryMessages() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("museum-state.json")
        let store = GalleryStore(storageURL: url)
        var draft = EyeNoteDraft(artwork: store.todayArtwork, chosenClue: .color)
        XCTAssertThrowsError(try store.save(draft.makeNote())) { error in
            XCTAssertEqual(error as? GalleryStoreError, .emptyObservation)
        }
        XCTAssertEqual(store.lastErrorMessage, GalleryStoreError.emptyObservation.localizedDescription)

        draft.observation = "A warm note."
        store.simulateNextSaveFailure = true
        XCTAssertThrowsError(try store.save(draft.makeNote())) { error in
            XCTAssertEqual(error as? GalleryStoreError, .simulatedSaveFailure)
        }
        XCTAssertEqual(store.lastErrorMessage, GalleryStoreError.simulatedSaveFailure.localizedDescription)
    }

    func testPromptHelperIsLocalEditableAndClueSpecific() {
        let artwork = ArtworkCard.seedCards[0]
        let colorPrompt = ObservationPromptHelper.prompt(for: artwork, clue: .color)
        let compositionPrompt = ObservationPromptHelper.prompt(for: artwork, clue: .composition)
        XCTAssertTrue(colorPrompt.contains(artwork.title))
        XCTAssertTrue(compositionPrompt.contains(artwork.title))
        XCTAssertNotEqual(colorPrompt, compositionPrompt)

        var draft = EyeNoteDraft(artwork: artwork, chosenClue: .color)
        draft.helperPrompt = "My edited local prompt."
        draft.observation = draft.helperPrompt
        XCTAssertEqual(draft.observation, "My edited local prompt.")
    }

    func testPremiumBoundaryUsesStoreKitProductIDAndFreeCopy() {
        let store = PremiumStore()
        XCTAssertTrue(store.productIDs.contains(AppCopy.premiumProductID))
        XCTAssertTrue(store.paywallSubtitle.contains("free"))
        store.unlockForTesting()
        XCTAssertTrue(store.isUnlocked)
    }

    func testPrivacyAndLocaleCopyIsEnglish() {
        XCTAssertEqual(AppCopy.privacyBoundary, "All notes and prompt choices stay private on device; no user-approved data leaves the device.")
        let joined = AppCopy.userVisibleSamples.joined(separator: " ")
        XCTAssertFalse(joined.contains("登录"))
        XCTAssertFalse(joined.contains("后端"))
        XCTAssertTrue(joined.contains("Premium Themes"))
    }
}

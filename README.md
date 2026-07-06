# GalleryGlance Micro Museum

GalleryGlance Micro Museum is a native SwiftUI iOS app for a three-minute art-looking ritual. Users open Today Gallery Card, choose a Color/Composition/Symbol clue, edit or skip a local observation helper, save an Eye Note, and revisit it in My Micro Museum.

## Open in Xcode

Open the human-debuggable project:

```bash
open /Users/wangrenzhu/work/galleryglance-micro-museum/GalleryGlanceMicroMuseum.xcodeproj
```

Scheme: `GalleryGlanceMicroMuseum`

## Product scope

- App language: English (United States) / en-US.
- Platform: iOS native SwiftUI.
- Local-first: JSON persistence in Application Support.
- AI/backend: local heuristic prompt templates only; no account, API key, or backend proxy.
- Premium: StoreKit 2 boundary for optional Premium Themes; the free gallery ritual is never blocked.
- Privacy: All notes and prompt choices stay private on device; no user-approved data leaves the device.

## Required screens

1. Today Gallery Card
2. Look Clue Challenge
3. Eye Note Composer
4. My Micro Museum
5. Premium Themes

## Acceptance coverage

- CRUD: create via Today Gallery Card → Look Clue Challenge → Eye Note Composer; edit/archive/delete from My Micro Museum detail.
- Persistence: saved cards are encoded to local JSON and reloaded by `GalleryStore`.
- Visual slot: museum-card editorial layout, framed artwork slot, magnifier clue overlay, warm gallery lighting palette.
- Empty state: My Micro Museum first-run copy includes starter action.
- Error state: empty observation, long observation, simulated save failure, StoreKit product miss, restore miss, and simulated IAP failure have recovery copy.
- Privacy: visible copy repeats the local-only note/prompt boundary.
- Premium: purchase, restore, failed, locked, and unlocked states are visible in Premium Themes.
- AI boundary: helper prompt is generated locally, editable, skippable, and never saved until the user confirms.

## Verification commands

```bash
cd /Users/wangrenzhu/work/galleryglance-micro-museum
xcodebuild -project GalleryGlanceMicroMuseum.xcodeproj -scheme GalleryGlanceMicroMuseum -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project GalleryGlanceMicroMuseum.xcodeproj -scheme GalleryGlanceMicroMuseum -destination 'platform=iOS Simulator,name=iPhone 17' test
```

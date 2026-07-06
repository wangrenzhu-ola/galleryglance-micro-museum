import SwiftUI

@main
struct GalleryGlanceMicroMuseumApp: App {
    @State private var galleryStore = GalleryStore()
    @State private var premiumStore = PremiumStore()

    var body: some Scene {
        WindowGroup {
            AppShell()
                .environment(galleryStore)
                .environment(premiumStore)
        }
    }
}

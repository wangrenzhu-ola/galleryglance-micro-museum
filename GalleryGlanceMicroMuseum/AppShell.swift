import SwiftUI

enum AppTab: Hashable {
    case today
    case museum
    case premium
}

struct AppShell: View {
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodayGalleryCardView(selectedTab: $selectedTab)
            }
            .tabItem { Label("Today", systemImage: "rectangle.stack.fill") }
            .tag(AppTab.today)

            NavigationStack {
                MyMicroMuseumView(selectedTab: $selectedTab)
            }
            .tabItem { Label("Museum", systemImage: "building.columns.fill") }
            .tag(AppTab.museum)

            NavigationStack {
                PremiumThemesView(selectedTab: $selectedTab)
            }
            .tabItem { Label("Premium", systemImage: "sparkles.rectangle.stack.fill") }
            .tag(AppTab.premium)
        }
        .tint(GalleryPalette.oxide)
    }
}

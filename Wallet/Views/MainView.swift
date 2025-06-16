import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            EmptyView()
                .tabItem {
                    Label("Расходы", systemImage: "star")
                }
        }
    }
}

#Preview {
    MainView()
}

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            EmptyView()
                .tabItem {
                    Label("Расходы", systemImage: "star")
                }
            
            EmptyView()
                .tabItem {
                    Label("Доходы", systemImage: "star")
                }
            
            EmptyView()
                .tabItem {
                    Label("Счет", systemImage: "star")
                }
            
            EmptyView()
                .tabItem {
                    Label("Статьи", systemImage: "star")
                }
            
            EmptyView()
                .tabItem {
                    Label("Настройки", systemImage: "star")
                }
        }
    }
}

#Preview {
    MainView()
}

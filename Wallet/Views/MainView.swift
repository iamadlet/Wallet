import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            OutcomesView()
                .tabItem {
                    Text("Расходы")
                    Image("OutcomesLogo")
                }
            
            IncomesView()
                .tabItem {
                    Text("Доходы")
                    Image("IncomesLogo")
                }
            
            BankAccountView()
                .tabItem {
                    Text("Счет")
                    Image("AccountLogo")
                }
            
            CategoriesView()
                .tabItem {
                    Text("Статьи")
                    Image("CategoriesLogo")
                }
            
            SettingsView()
                .tabItem {
                    Text("Настройки")
                    Image("SettingsLogo")
                }
        }
    }
}

#Preview {
    MainView()
}

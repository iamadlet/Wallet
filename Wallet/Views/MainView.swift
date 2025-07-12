import SwiftUI

struct MainView: View {
    @StateObject var model: TransactionsViewModel
    var body: some View {
        TabView {
            TransactionsListView(direction: .outcome)
                .environmentObject(model)
                .tabItem {
                    Text("Расходы")
                    Image("OutcomesLogo")
                }
            
            TransactionsListView(direction: .income)
                .environmentObject(model)
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
    MainView(model: TransactionsViewModel())
}

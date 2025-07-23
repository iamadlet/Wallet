import SwiftUI

struct MainView: View {
    @EnvironmentObject var deps: AppDependencies
    @EnvironmentObject var transactionsVM: TransactionsViewModel
    @EnvironmentObject var categoriesVM: CategoriesViewModel
    @EnvironmentObject var bankVM: BankAccountViewModel
    var body: some View {
        TabView {
            TransactionsListView(direction: .outcome)
                .environmentObject(transactionsVM)
                .environmentObject(bankVM)
                .environmentObject(deps)
                .tabItem {
                    Text("Расходы")
                    Image("OutcomesLogo")
                }
            
            TransactionsListView(direction: .income)
                .environmentObject(transactionsVM)
                .environmentObject(bankVM)
                .environmentObject(deps)
                .tabItem {
                    Text("Доходы")
                    Image("IncomesLogo")
                }
            
            BankAccountView()
                .environmentObject(bankVM)
                .tabItem {
                    Text("Счет")
                    Image("AccountLogo")
                }
            
            CategoriesView()
                .environmentObject(categoriesVM)
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
    let client = NetworkClient(
        baseURL: URL(string: "https://shmr-finance.ru/api/v1")!,
        token: "DHlsXvPvrVcHuK5T0u5LzH0x"
    )
    let transactionService = TransactionsService(client: client)
    let bankAccountService = BankAccountsService(client: client)
    let categoriesService = CategoriesService(client: client)

    let transactionsVM = TransactionsViewModel(service: transactionService)
    let categoriesVM = CategoriesViewModel(service: categoriesService)
    let bankVM = BankAccountViewModel(service: bankAccountService)
    MainView()
        .environmentObject(transactionsVM)
        .environmentObject(categoriesVM)
        .environmentObject(bankVM)
}

import SwiftUI
import SwiftData

@main
struct WalletApp: App {
    
    static let dependencies = AppDependencies(token: "DHlsXvPvrVcHuK5T0u5LzH0x")
    
    @StateObject private var transactionsVM = TransactionsViewModel(
        service: WalletApp.dependencies.transactionService
    )
    @StateObject private var categoriesVM = CategoriesViewModel(
        service:   WalletApp.dependencies.categoriesService
    )
    @StateObject private var bankVM       = BankAccountViewModel(
        service:   WalletApp.dependencies.bankService
    )

    init() {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.white

            UITabBar.appearance().standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var body: some Scene {
        WindowGroup {
            
            MainView()
                .environmentObject(WalletApp.dependencies)
                .environmentObject(transactionsVM)
                .environmentObject(categoriesVM)
                .environmentObject(bankVM)
                .task {
                    await bankVM.loadAccountInfo()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

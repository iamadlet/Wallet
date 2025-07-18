import Foundation

final class AppDependencies: ObservableObject {
    let client: NetworkClient
    let transactionService: TransactionsService
    let bankService: BankAccountsService
    let categoriesService: CategoriesService

    init(token: String) {
        self.client = NetworkClient(
            baseURL: URL(string: "https://shmr-finance.ru/api/v1/")!,
            token: token
        )
        self.transactionService = TransactionsService(client: client)
        self.bankService = BankAccountsService(client: client)
        self.categoriesService = CategoriesService(client: client)
    }
}

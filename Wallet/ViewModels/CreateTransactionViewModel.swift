import Foundation

@MainActor
final class CreateTransactionViewModel: ObservableObject {
    private let accountId: Int
    private let accountService: BankAccountsService
    private let transactionService: TransactionsService
    private let categoriesService: CategoriesService
    
    private(set) var existingTransaction: Transaction?
    
    @Published var categories: [Category] = []
    @Published var category: Category?
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var comment: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    init(
        accountId: Int,
        accountService: BankAccountsService,
        transactionService: TransactionsService,
        categoriesService: CategoriesService,
        existing: Transaction? = nil
    ) {
        self.accountId = accountId
        self.accountService = accountService
        self.transactionService = transactionService
        self.categoriesService = categoriesService
        self.existingTransaction = existing
        
        if let tx = existing {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.locale = .current
            
            self.amount = formatter.string(from: NSDecimalNumber(decimal: tx.amount)) ?? ""
            self.date = tx.transactionDate
            self.time = tx.transactionDate
            self.comment = tx.comment
        }
    }
    
    // MARK: - Методы связанные с категориями
    // MARK: - Асинхронный метод для загрузки категорий
    func loadCategories(of direction: Direction) async {
        do {
            self.categories = try await categoriesService.getCategories(of: direction)
            if category == nil {
                category = categories.first
            }
        } catch {
            self.error = error
        }
    }
    
    //MARK: - Асинхронный метод для выбора категории, и присвоить значение self.categoryId
    func selectCategoryId(from category: Category) async throws -> Int {
        category.id
    }
    
    private func buildTransactionRequest() throws -> TransactionRequest {
        guard let categoryId = category?.id else {
            throw TransactionRequestError.invalidCategory
        }
        
        let raw = amount.trimmingCharacters(in: .whitespaces)
        guard let amountDecimal = Decimal(string: raw), amountDecimal > 0 else {
            throw TransactionRequestError.invalidAmount
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        guard let finalDate = calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: date) else {
            throw TransactionRequestError.invalidDate
        }
        
        return TransactionRequest(
            accountId: accountId,
            categoryId: categoryId,
            amount: amountDecimal,
            transactionDate: finalDate,
            comment: comment
        )
    }
    
    func saveTransaction() async -> Bool {
        do {
            let request = try buildTransactionRequest()

            if let existing = existingTransaction {
                try await transactionService.editTransaction(id: existing.id, request: request)
            } else {
                _ = try await transactionService.createTransaction(from: request)
            }
            return true
        } catch {
            self.error = error
            return false
        }
    }
    
    func deleteTransaction(_ tx: Transaction) async throws {
        guard let tx = existingTransaction else { return }
        try await transactionService.deleteTransaction(by: tx.id)
    }
    
    func isEditing() -> Bool {
        existingTransaction != nil
    }
}

enum TransactionRequestError: Error {
    case invalidAmount
    case invalidDate
    case invalidCategory
    case invalidTime
    case failedToSaveTransaction
    case failedToDeleteTransaction
}

enum TransactionSheetState: Identifiable {
    case create, edit(Transaction)
    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let transaction): return transaction.id.description
        }
    }
}

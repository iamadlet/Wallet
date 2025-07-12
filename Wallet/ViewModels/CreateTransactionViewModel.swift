import Foundation

@MainActor
class CreateTransactionViewModel: ObservableObject {
    private(set) var existingTransaction: Transaction?
    
    @Published var categories: [Category] = []
    @Published var category: Category?
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var comment: String = ""
    @Published var transactionId: Int?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let accountId: Int
    
    private let accountService: BankAccountsService
    private let transactionService: TransactionsService
    private let categoriesService: CategoriesService
    
    init(
        accountService: BankAccountsService,
        transactionService: TransactionsService,
        categoriesService: CategoriesService,
        existing: Transaction?
    ) {
        self.accountService = accountService
        self.transactionService = transactionService
        self.categoriesService = categoriesService
        self.accountId = transactionService.accounts[0].id
        self.existingTransaction = existing
        
        if let tx = existing {
            let fmt = NumberFormatter()
            fmt.numberStyle = .decimal
            fmt.maximumFractionDigits = 2
            fmt.locale = Locale.current
            self.amount = fmt.string(
                from: NSDecimalNumber(decimal: tx.amount)
            ) ?? "0.00"
            self.date = tx.transactionDate
            self.time = tx.transactionDate
            self.comment = tx.comment ?? ""
            self.category = tx.category
            self.transactionId = tx.id
        }
    }
    
    // MARK: - Методы связанные с категориями
    // MARK: - Асинхронный метод для загрузки категорий
    func loadCategories(of direction: Direction) async throws {
        do {
            categories = try await categoriesService.getCategories(of: direction)
            if category == nil {
                category = categories.first
            }
        } catch {
            self.error = error
            print("не удалось загрузить категории", error)
        }
    }
    
    //MARK: - Асинхронный метод для выбора категории, и присвоить значение self.categoryId
    func selectCategoryId(from category: Category) async throws -> Int {
        category.id
    }
    
    func createTransactionRequest() async throws -> TransactionRequest {
        let calendar = Calendar.current
        
        let timeComponents = calendar.dateComponents([.hour, .minute], from: self.time)
        
        guard let transactionDate = calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: self.date) else {
            throw TransactionRequestError.invalidDate
        }
        
        guard let unwrappedCategoryId = category?.id else {
            throw TransactionRequestError.invalidCategory
        }
        guard let amountNumber = Decimal(string: amount) else {
            throw TransactionRequestError.invalidAmount
        }
        
        let transactionRequest = TransactionRequest(accountId: accountId, categoryId: unwrappedCategoryId, amount: amountNumber, transactionDate: transactionDate, comment: comment)
        
        return transactionRequest
    }
    
    func saveTransaction() async throws -> Bool {
        do {
            let validatedAmount = try validateAmount()
            let validatedTransactionDate = try makeTransactionDate()
            let validatedCategoryId = try validateCategory()
            
            if let existing = existingTransaction {
                let transactionDate = try makeTransactionDate()
                
                try await transactionService.editTransaction(
                    id: existing.id,
                    accountId: accountId,
                    categoryId: validatedCategoryId,
                    amount: validatedAmount,
                    transactionDate: validatedTransactionDate,
                    comment: self.comment,
                    createdAt: existing.createdAt
                )
            } else {
                let newTransaction = try await transactionService.createTransaction(from: createTransactionRequest())
                transactionService.transactions.append(newTransaction)
            }
            return true
        } catch {
            self.error = error
            return false
        }
    }
    
    func deleteTransaction(_ tx: Transaction) async throws {
        guard let existing = existingTransaction else {
            return
        }
        try await transactionService.deleteTransaction(by: existing.id)
    }
    
    func isEditing() -> Bool {
        guard let existing = existingTransaction else {
            return false
        }
        return true
    }
    
    func getTransaction() async throws -> Transaction {
        if let existing = existingTransaction {
            return existing
        } else {
            throw TransactionRequestError.failedToSaveTransaction
        }
    }
    
    func makeTransactionDate() throws -> Date {
        let calendar = Calendar.current
        
        let dayStart = calendar.startOfDay(for: self.date)
        let comps = calendar.dateComponents([.hour, .minute], from: self.time)
        
        guard let transactionDate = calendar.date(
            byAdding: comps,
            to: dayStart
        ) else {
            throw TransactionRequestError.invalidDate
        }
        return transactionDate
    }
    
    private func validateAmount() throws -> Decimal {
        let raw = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            throw TransactionRequestError.invalidAmount
        }
        
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.locale = Locale.current
        
        guard let num = fmt.number(from: self.amount)?.decimalValue, num > 0 else {
            throw TransactionRequestError.invalidAmount
        }
        return num
    }
    
    private func validateCategory() throws -> Int {
        guard let c = category else {
            throw TransactionRequestError.invalidCategory
        }
        return c.id
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

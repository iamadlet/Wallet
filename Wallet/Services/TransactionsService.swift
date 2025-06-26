import Foundation

final class TransactionsService: ObservableObject {
    let categories: [Category] = [
        Category(id: 0, name: "Аренда квартиры", emoji: "🏠", isIncome: false),
        Category(id: 1, name: "Машина", emoji: "🚘", isIncome: false),
        Category(id: 2, name: "Продукты", emoji: "🍬", isIncome: false),
        Category(id: 3, name: "Зарплата", emoji: "💵", isIncome: true),
        Category(id: 4, name: "На собачку", emoji: "🐕", isIncome: false),
        Category(id: 5, name: "Одежда", emoji: "👔", isIncome: false),
        Category(id: 6, name: "Ремонт квартиры", emoji: "🔨", isIncome: false),
        Category(id: 7, name: "Спортзал", emoji: "🏋️‍♂️", isIncome: false),
        Category(id: 8, name: "Рестораны", emoji: "🍽️", isIncome: false),
        Category(id: 9, name: "Аптека", emoji: "💜", isIncome: false),
        Category(id: 10, name: "Медицина", emoji: "💊", isIncome: false),
        Category(id: 11, name: "Подработка", emoji: "💵", isIncome: true),
    ]
    
    @Published var transactions: [Transaction]
    let accounts: [AccountBrief] = [AccountBrief(id: 0, name: "Adlet", balance: 100000, currency: "RUB")]
    
    init() {
        
        self.transactions = [
            Transaction(id: 0, account: accounts[0], category: categories[0], amount: 100000, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 1, account: accounts[0], category: categories[5], amount: 7500, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 2, account: accounts[0], category: categories[4], amount: 2500, transactionDate: Date.now, comment: "Джек", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 3, account: accounts[0], category: categories[4], amount: 4800, transactionDate: Date.now, comment: "Энни", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 4, account: accounts[0], category: categories[6], amount: 100000, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 5, account: accounts[0], category: categories[7], amount: 3223, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 6, account: accounts[0], category: categories[9], amount: 10000, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 7, account: accounts[0], category: categories[10], amount: 25000, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 8, account: accounts[0], category: categories[1], amount: 60000, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 9, account: accounts[0], category: categories[8], amount: 5000, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 10, account: accounts[0], category: categories[3], amount: 100000, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 11, account: accounts[0], category: categories[11], amount: 60000, transactionDate: Date.now, comment: "", createdAt: Date.now, updatedAt: Date.now)
        ]
    }
    
    
    //MARK: - Aсинхронный метод для получения списка операций за период
    func getTransactionsByPeriod(accountId: Int = 0, startDate: String, endDate: String) async throws -> [Transaction] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay]
        guard let start = formatter.date(from: startDate),
              let end   = formatter.date(from:   endDate) else {
            throw NetworkError.invalidDate
        }
        let calendar = Calendar.current
        let from = calendar.startOfDay(for: start)
        let until = calendar.date(
            bySettingHour: 23, minute: 59, second: 59,
            of: end
        )!

        return transactions.filter {
            $0.transactionDate >= from &&
            $0.transactionDate <= until
        }
    }
    //MARK: - Aсинхронный метод для создания транзакции
    func createTransaction(from request: TransactionRequest) async throws -> Transaction {
        let maxId = transactions.map(\.id).max() ?? 0
        let newId = maxId + 1
        
        let selectedCategory = categories[request.categoryId]
        
        guard let accountIndex = accounts.firstIndex(where: { $0.id == request.accountId }) else {
            throw NetworkError.transactionIdAlreadyExists
        }
        
        
        //ВОПРОС: - Какую дату ставить в createdAt и updatedAt ????
        let newTransaction = Transaction(
            id: newId,
            account: accounts[accountIndex],
            category: selectedCategory,
            amount: request.amount,
            transactionDate: request.transactionDate,
            comment: request.comment,
            createdAt: Date.now,
            updatedAt: Date.now
        )
        return newTransaction
    }
    
    //MARK: - Aсинхронный метод для редактирования транзакции
    func editTransaction(of id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: String, comment: String) async throws -> Transaction {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw NetworkError.invalidId
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let transactionDateFormatted = formatter.date(from: transactionDate) else {
            throw NetworkError.invalidDate
        }
        
        let updatedTransaction = Transaction(
            id: id,
            account: accounts[accountId],
            category: categories[categoryId],
            amount: amount,
            transactionDate: transactionDateFormatted,
            comment: comment,
            createdAt: Date.now,
            updatedAt: Date.now
        )
        transactions[index] = updatedTransaction
        return updatedTransaction
    }
    //MARK: - Aсинхронный метод для удаления транзакции
    func deleteTransaction(by id: Int) async throws -> Transaction {
        guard let index = transactions.firstIndex(where: { $0.id == id })  else {
            throw NetworkError.invalidId
        }
        let deletedTransaction = transactions.remove(at: index)
        return deletedTransaction
    }
    
    //MARK: - Метод для фильтрации транзакций по доходу/расходу
    func getTransactions(by direction: Direction, from start: Date, until end: Date, sortedBy type: SortType) -> [Transaction] {
        let calendar = Calendar.current
        
        let startDate = calendar.startOfDay(for: start)
        guard let end = calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: end
        ) else {
            return []
        }
        let filtered = self.transactions.filter
            {
                $0.category.direction == direction &&
                $0.transactionDate >= startDate &&
                $0.transactionDate <= end
            }
        
        return sort(transactions: filtered, by: type)
    }
    
    //MARK: - Метод для нахождения суммы транзакций по доходу/расходу
    func sumTransactionsAmount(by direction: Direction, from start: Date, until end: Date) -> Decimal {
        let transactionsByDirection = getTransactions(by: direction, from: start, until: end, sortedBy: .amountAscending)
        let sum = transactionsByDirection.reduce(0, {x, y in
            x + y.amount
        })
        return sum
    }
    
    //TODO: в будущем заменить символ рубля на enum, и в зависимости от настроек юзера уже форматировать. Пока только рубль )0))0)
    func formatAmount(_ amount: Decimal) -> String {
        
        return "\(amount) ₽"
    }
    
    func sort(transactions: [Transaction],by type: SortType) -> [Transaction] {
        switch type {
        case .dateAscending:
            return transactions.sorted { $0.transactionDate < $1.transactionDate }
        case .dateDescending:
            return transactions.sorted { $0.transactionDate > $1.transactionDate }
        case .amountAscending:
            return transactions.sorted { $0.amount < $1.amount }
        case .amountDescending:
            return transactions.sorted { $0.amount > $1.amount }
        }
    }
}

enum NetworkError: Error {
    case invalidId
    case invalidDate
    case transactionIdAlreadyExists
    case startDateIsLaterThanEndDate
}

enum SortType: String, CaseIterable, Identifiable {
    case dateAscending = "Сначала старые"
    case dateDescending = "Сначала новые"
    case amountAscending = "По возрастанию"
    case amountDescending = "По убыванию"
    
    var id: String { rawValue }
}

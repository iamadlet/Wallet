import Foundation

final class TransactionsService {
    let categories: [Category] = [
        Category(id: 0, name: "Дом", emoji: "🏠", isIncome: false),
        Category(id: 1, name: "Машина", emoji: "🚘", isIncome: false),
        Category(id: 2, name: "Продукты", emoji: "🥯", isIncome: false),
        Category(id: 3, name: "Зарплата", emoji: "💵", isIncome: true),
        Category(id: 3, name: "Ставки", emoji: "🎰", isIncome: true),
    ]
    
    var transactions: [Transaction]
    
    let accounts: [AccountBrief] = [AccountBrief(id: 0, name: "Adlet", balance: 100000, currency: "RUB")]
    
    init() {
        
        self.transactions = [
            Transaction(id: 0, account: accounts[0], category: categories[0], amount: 1000, transactionDate: Date.now, comment: "отопление", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 1, account: accounts[0], category: categories[1], amount: 1000, transactionDate: Date.now, comment: "бенизн", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 2, account: accounts[0], category: categories[2], amount: 1000, transactionDate: Date.now, comment: "макароны", createdAt: Date.now, updatedAt: Date.now),
            Transaction(id: 3, account: accounts[0], category: categories[3], amount: 10000, transactionDate: Date.now, comment: "all in на красное", createdAt: Date.now, updatedAt: Date.now)
        ]
    }
    
    
    //MARK: - Aсинхронный метод для получения списка операций за период
    func getTransactionsByPeriod(accountId: Int, startDate: String, endDate: String) async throws -> [Transaction] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay]
        
        guard let startDateFormatted = formatter.date(from: startDate) else {
            throw NetworkError.invalidDate
        }
        guard let endDateFormatted = formatter.date(from: endDate) else {
            throw NetworkError.invalidDate
        }
        
        guard startDateFormatted > endDateFormatted else {
            throw NetworkError.startDateIsLaterThanEndDate
        }
        
        return transactions.filter { $0.createdAt >= startDateFormatted && $0.createdAt <= endDateFormatted}
    }
    //MARK: - Aсинхронный метод для создания транзакции
    func createTransaction(from request: TransactionRequest) async throws -> Transaction {
        let selectedCategory = categories[request.categoryId]
        
        guard let accountIndex = accounts.firstIndex(where: { $0.id == request.accountId }) else {
            throw NetworkError.transactionIdAlreadyExists
        }
        
        
        //ВОПРОС: - Какую дату ставить в createdAt и updatedAt ????
        let newTransaction = Transaction(
            id: transactions.count,
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
    
    
}


enum NetworkError: Error {
    case invalidId
    case invalidDate
    case transactionIdAlreadyExists
    case startDateIsLaterThanEndDate
}

import Foundation

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var today: Date = Date()
    @Published var sortType: SortType = .dateDescending
    @Published var error: Error?

    let service: TransactionsService
    
    init(service: TransactionsService) {
        self.service = service
    }
    
    // MARK: - Метод для загрузки транзакций из сервиса по доходу/расходу
    func loadTransactions(accountId: Int, from start: Date, until end: Date) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withYear, .withMonth, .withDay]
            
            let raw = try await service
                .getTransactionsByPeriod(
                    accountId: accountId,
                    startDate: start,
                    endDate: end
                )
            self.transactions = raw
        } catch {
            print("DECODE ERROR:", error)
            self.error = error
        }
    }
    
    // MARK: - Метод для фильтрации транзакций по доходу/расходу
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
        let filtered = self.transactions.filter { transaction in
            let date = calendar.startOfDay(for: transaction.transactionDate)
            return transaction.category.direction == direction &&
                   date >= startDate &&
                   date <= end
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
    
    // MARK: - Для графика в BankAccountView
    func getSumsForOneMonth(from start: Date) -> [Date: Decimal] {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        
        var sumsByDay: [Date: Decimal] = [:]
        for offset in 0..<30 {
            let day = calendar.date(byAdding: .day, value: offset, to: startDay)!
            sumsByDay[day] = 0
        }
        
        for tx in transactions {
            let day = calendar.startOfDay(for: tx.transactionDate)
            guard sumsByDay[day] != nil else { continue }
            let sign: Decimal = (tx.category.direction == .income) ? 1 : -1
            sumsByDay[day]! += sign * tx.amount
        }
        
        return sumsByDay
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
    
    //TODO: в будущем заменить символ рубля на enum, и в зависимости от настроек юзера уже форматировать. Пока только рубль )0))0)
    func formatAmount(_ amount: Decimal) -> String {
        
        return "\(amount) ₽"
    }
    
}

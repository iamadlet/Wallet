import Foundation

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var today: Date = Date()
    @Published var sortType: SortType = .dateDescending
    @Published var error: Error?

    private let transactionsService: TransactionsService
    
    init(transactionsService: TransactionsService) {
        self.transactionsService = transactionsService
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
    
    func loadTransactions(accountId: Int, from start: Date, until end: Date) async {
        isLoading = true
          defer { isLoading = false }
          do {
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withYear, .withMonth, .withDay]
            let startString = iso.string(from: start)
            let endString   = iso.string(from: end)

            let raw = try await transactionsService
              .getTransactionsByPeriod(
                accountId: accountId,
                startDate: startString,
                endDate: endString
              )
            // now you have the freshly fetched array…
            // you can either store it directly:
            self.transactions = raw
            // …or post-process it with your sync filter/sort helpers:
            // self.transactions = sort(transactions: raw, by: sortType)
          } catch {
            self.error = error
          }
    }
}

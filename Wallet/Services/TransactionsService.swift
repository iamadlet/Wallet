import Foundation

final class TransactionsService: ObservableObject {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    
    //MARK: - Aсинхронный метод для получения списка операций за период
    func getTransactionsByPeriod(accountId: Int = 0, startDate: Date, endDate: Date) async throws -> [Transaction] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)

        let path = "transactions/account/\(accountId)/period?startDate=\(start)&endDate=\(end)"

        return try await client.request(
            path: path,
            method: "GET",
            body: EmptyBody()
        )
    }
    //MARK: - Aсинхронный метод для создания транзакции
    func createTransaction(from request: TransactionRequest) async throws -> Transaction {
        return try await client.request(
            path: "transactions",
            method: "POST",
            body: request
        )
    }
    
    //MARK: - Aсинхронный метод для редактирования транзакции
    func editTransaction(id: Int, request: TransactionRequest) async throws -> Transaction {
        let path = "transactions/\(id)"
        return try await client.request(
            path: path,
            method: "PUT",
            body: request
        )
    }
    //MARK: - Aсинхронный метод для удаления транзакции
    func deleteTransaction(by id: Int) async throws {
        let path = "transactions/\(id)"
        _ = try await client.request(
            path: path,
            method: "DELETE",
            body: EmptyBody()
        ) as EmptyResponse
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

enum TransactionError: Error {
    case invalidId
    case invalidDate
    case transactionIdAlreadyExists
    case startDateIsLaterThanEndDate
    case invalidAccount
    case invalidCategory
}

enum SortType: String, CaseIterable, Identifiable {
    case dateAscending = "Сначала старые"
    case dateDescending = "Сначала новые"
    case amountAscending = "По возрастанию"
    case amountDescending = "По убыванию"
    
    var id: String { rawValue }
}

struct EmptyBody: Encodable {}
struct EmptyResponse: Decodable {}

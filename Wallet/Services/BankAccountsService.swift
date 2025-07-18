import Foundation

final class BankAccountsService {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }
    
    func getInfo() async throws -> BankAccount {
        let accounts: [BankAccount] = try await client.request(
            path: "accounts",
            body: EmptyBody()
        )

        guard let first = accounts.first else {
            throw URLError(.badServerResponse)
        }

        return first
    }
    
    
    func changeAccount(name: String, balance: Decimal, currency: String) async throws {
        struct UpdateBody: Encodable {
            let name: String
            let balance: Decimal
            let currency: String
        }

        let body = UpdateBody(name: name, balance: balance, currency: currency)
        let account = try await getInfo()

        _ = try await client.request(
            path: "accounts/\(account.id)",
            method: "PUT",
            body: body
        ) as EmptyResponse
    }
}

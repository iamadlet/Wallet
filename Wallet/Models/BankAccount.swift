import Foundation

struct BankAccount {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: Currency
    let createdAt: Date
    let updatedAt: Date
}

enum Currency {
    case RUB, EUR, USD
}

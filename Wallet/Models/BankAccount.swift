import Foundation

struct BankAccount {
    let id: Int
    let userId: Int
    var name: String
    var balance: Decimal
    var currency: Currency
    var createdAt: Date
    var updatedAt: Date
}

enum Currency {
    case RUB, EUR, USD
}

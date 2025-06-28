import Foundation

struct BankAccount: Codable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, userId, name, balance, currency, createdAt, updatedAt
    }
    
    init(id: Int, userId: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.name = try container.decode(String.self, forKey: .name)
        
        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let balance = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(forKey: .balance, in: container, debugDescription: "Invalid decimal string")
        }
        self.balance = balance
        self.currency = try container.decode(String.self, forKey: .currency)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

enum Currency: String, CaseIterable, Codable, Identifiable {
    case RUB = "RUB"
    case EUR = "EUR"
    case USD = "USD"
    
    var symbol: String {
        switch self {
        case .RUB:
            return "₽"
        case .EUR:
            return "€"
        case .USD:
            return "$"
        }
    }
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .RUB:
            return "Российский рубль ₽"
        case .USD:
            return "Доллар США $"
        case .EUR:
            return "Евро €"
        }
    }
}

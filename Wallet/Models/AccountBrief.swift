import Foundation

struct AccountBrief: Codable, Equatable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let balance = Decimal(string: balanceString.replacingOccurrences(of: ",", with: ".")) else {
            throw DecodingError.dataCorruptedError(forKey: .balance, in: container, debugDescription: "Invalid decimal string")
        }
        self.balance = balance
        self.currency = try container.decode(String.self, forKey: .currency)
    }
    
    init(id: Int, name: String, balance: Decimal, currency: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
    }
}




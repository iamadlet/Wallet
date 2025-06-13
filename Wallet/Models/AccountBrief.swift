import Foundation

struct AccountBrief: Codable, Equatable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
}




import Foundation

struct Transaction: Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    
}

import Foundation

struct TransactionResponse: Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String
    let createdAt: Date
    let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(Int.self,     forKey: .id)
        accountId       = try c.decode(Int.self,     forKey: .accountId)
        categoryId      = try c.decode(Int.self,     forKey: .categoryId)
        
        let amountStr   = try c.decode(String.self,  forKey: .amount)
        guard let dec   = Decimal(string: amountStr) else {
            throw DecodingError.dataCorruptedError(
                forKey: .amount, in: c,
                debugDescription: "Invalid decimal: \(amountStr)"
            )
        }
        amount          = dec
        
        transactionDate = try c.decode(Date.self,    forKey: .transactionDate)
        comment         = try c.decode(String.self,  forKey: .comment)
        createdAt       = try c.decode(Date.self,    forKey: .createdAt)
        updatedAt       = try c.decode(Date.self,    forKey: .updatedAt)
    }
}

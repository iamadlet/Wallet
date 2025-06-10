import Foundation

extension Transaction {
    
    var jsonObject: Any {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return [
            "id": self.id,
            "accountId": self.accountId,
            "categoryId": self.categoryId,
            "amount": self.amount,
            "transactionDate": self.transactionDate,
            "comment": self.comment,
            "createdAt": formatter.string(from: self.createdAt),
            "updatedAt": formatter.string(from: self.updatedAt)
        ]
    }
    
    static func parse(jsonObject: Any) -> Transaction? {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let dict = jsonObject as? [String: Any],
              let id = dict["id"] as? Int,
              let accountId = dict["accountId"] as? Int,
              let categoryId = dict["categoryId"] as? Int,
              let amount = dict["amount"] as? Decimal,
              
              let transactionDateString = dict["transactionDate"] as? String,
              let transactionDate = formatter.date(from: transactionDateString),
              
              let comment = dict["comment"] as? String,
              
              let createdAtString = dict["createdAt"] as? String,
              let createdAt = formatter.date(from: createdAtString),
              
              let updatedAtString = dict["updatedAt"] as? String,
              let updatedAt = formatter.date(from: updatedAtString)
        else {
            return nil
        }
        
        let transaction = Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
        return transaction
        
    }
    
    
}

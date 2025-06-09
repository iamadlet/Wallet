import Foundation

extension Transaction {
    
    var jsonObject: Any {
        return [
            "id": self.id,
            "accountId": self.accountId,
            "categoryId": self.categoryId,
            "amount": self.amount,
            "transactionDate": self.transactionDate,
            "comment": self.comment,
            "createdAt": self.createdAt,
            "updatedAt": self.updatedAt
        ]
    }
    
    static func parse(jsonObject: Any) -> Transaction? {
        
        guard let dict = jsonObject as? [String: Any],
              let id = dict["id"] as? Int,
              let accountId = dict["accountId"] as? Int,
              let categoryId = dict["categoryId"] as? Int,
              let amount = dict["amount"] as? Decimal,
              let transactionDate = dict["transactionDate"] as? Date,
              let comment = dict["comment"] as? String,
              let createdAt = dict["createdAt"] as? Date,
              let updatedAt = dict["updatedAt"] as? Date else {
            return nil
        }
        
        let transaction = Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
        return transaction
        
    }
}

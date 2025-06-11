import Foundation

extension Transaction {
    
    //MARK: - Создать Transaction из TransactionRequest
//    init(from transactionRequest: TransactionRequest) {
//        self.account = transactionRequest.accountId
//        self.categoryId = transactionRequest.category.id
//        self.amount = transactionRequest.amount
//        self.transactionDate = transactionRe.transactionDate
//        self.comment = transaction.comment
//    }
    
    //MARK: - Computed property из Foundation объекта в jsonObject
    var jsonObject: Any {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return [
            "id": self.id,
            "accountId": self.account.id,
            "categoryId": self.category.id,
            "amount": NSDecimalNumber(decimal: amount).stringValue,
            "transactionDate": formatter.string(from: self.transactionDate),
            "comment": self.comment,
            //MARK: - мб оставить formatter.string(from: self.updateAt/createdAt)
            "createdAt": formatter.string(from: self.createdAt),
            "updatedAt": formatter.string(from: self.updatedAt)
        ]
    }
    
    //MARK: - Из jsonObject-а в Foundation объект
    static func parse(jsonObject: Any) -> Transaction? {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let dict = jsonObject as? [String: Any],
              let id = dict["id"] as? Int,
              let account = dict["account"] as? AccountBrief,
              let category = dict["categoryId"] as? Category,
              
                let amountString = dict["amount"] as? String,
              let amountDecimal = Decimal(string: amountString),
              
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
        
        let transaction = Transaction(id: id, account: account, category: category, amount: amountDecimal, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
        return transaction
        
    }
}

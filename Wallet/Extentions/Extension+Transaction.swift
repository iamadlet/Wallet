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
        
        let transaction = Transaction(
            id: id,
            account: account,
            category: category,
            amount: amountDecimal,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
        return transaction
    }
    
    func readFromCSV(from path: String) async throws -> [Transaction] {
        var result: [Transaction] = []
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw CSVError.failedToDecodeUTF8
        }
        
        let lines = content.components(separatedBy: .newlines)
        
        for i in 1..<lines.count {
            let column = lines[i].components(separatedBy: ",")
            
            guard let id = Int(column[0]) else {
                throw CSVError.invalidId
            }
            
            //MARK: - Parsing Account
            guard let accountId = Int(column[1]) else {
                throw CSVError.invalidAccountId
            }
            let accountName = column[2]
            guard let accountBalance = Decimal(string: column[3]) else {
                throw CSVError.invalidAccountBalance
            }
            let currency = column[4]
            
            let account = AccountBrief(id: accountId, name: accountName, balance: accountBalance, currency: currency)
            
            //MARK: - Parsing category
            guard let categoryId = Int(column[5]) else {
                throw CSVError.invalidCategoryId
            }
            let categoryName = column[6]
            guard let emoji = column[7].first else {
                throw CSVError.invalidEmoji
            }
            guard let isIncome = Bool(column[8]) else {
                throw CSVError.invalidBool
            }
            
            let category = Category(id: categoryId, name: categoryName, emoji: emoji, isIncome: isIncome)
            
            guard let amount = Decimal(string: column[9]) else {
                throw CSVError.invalidAccountBalance
            }
            
            guard let transactionDate = formatter.date(from: column[10]) else {
                throw CSVError.invalidTransactionDate
            }
            
            let comment = column[11]
            
            guard let createdAt = formatter.date(from: column[12]) else {
                throw CSVError.invalidCreatedAt
            }
            guard let updatedAt = formatter.date(from: column[13]) else {
                throw CSVError.invalidUpdatedAt
            }
                    
            let transaction = Transaction(id: id, account: account, category: category, amount: amount, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
            
            result.append(transaction)
        }
        return result
    }
    
    enum CSVError: Error {
        case failedToDecodeUTF8
        case invalidId
        case invalidAccountId
        case invalidAccountBalance
        case invalidCategoryId
        case invalidEmoji
        case invalidBool
        case invalidTransactionDate
        case invalidCreatedAt
        case invalidUpdatedAt
    }
}

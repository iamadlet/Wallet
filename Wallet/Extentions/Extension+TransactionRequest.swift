import Foundation

extension TransactionRequest {
    
    //MARK: - создать extension TransactionRequest, который собирает TransactionRequest из Transaction
    init(from transaction: Transaction) {
        self.accountId = transaction.account.id
        self.categoryId = transaction.category.id
        self.amount = transaction.amount
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
    }
}

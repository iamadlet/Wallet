import Foundation
import SwiftData

@Model
final class TransactionModel {
    @Attribute(.unique) var id: Int
    var accountId: Int
    var accountName: String
    var accountBalance: Decimal
    var accountCurrency: String
    
    var categoryId: Int
    var categoryName: String
    var categoryEmoji: String
    var isIncome: Bool
    
    var amount: Decimal
    var transactionDate: Date
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    
    var isSynced: Bool = false

    init(transaction: Transaction) {
        self.id = transaction.id
        self.accountId = transaction.account.id
        self.accountName = transaction.account.name
        self.accountBalance = NSDecimalNumber(decimal: transaction.account.balance) as Decimal
        self.accountCurrency = transaction.account.currency
        
        self.categoryId = transaction.category.id
        self.categoryName = transaction.category.name
        self.categoryEmoji = String(transaction.category.emoji)
        self.isIncome = transaction.category.isIncome == true
        
        self.amount = NSDecimalNumber(decimal: transaction.amount) as Decimal
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
    }
}

@MainActor
final class TransactionStorage {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func create(transaction: Transaction, isSynced: Bool = true) throws {
        let context = modelContainer.mainContext


        if try fetchEntity(by: transaction.id) != nil {
            throw NSError(domain: "TransactionStorage", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Transaction with this ID already exists."
            ])
        }

        let newEntity = TransactionModel(transaction: transaction)
        newEntity.isSynced = isSynced
        context.insert(newEntity)
        try context.save()
    }

    
    func fetchByAccountAndPeriod(accountId: Int, startDate: Date, endDate: Date) throws -> [TransactionModel] {
        let predicate = #Predicate<TransactionModel> {
            $0.accountId == accountId
        }

        let context = modelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<TransactionModel>(predicate: predicate)
        let results = try context.fetch(fetchDescriptor)

        let filtered = results.filter {
            let date = $0.transactionDate
            return date >= startDate && date <= endDate
        }

        return filtered
    }



    // MARK: - Read

    func fetchAll() throws -> [TransactionModel] {
        let context = modelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<TransactionModel>()
        return try context.fetch(fetchDescriptor)
    }

    func fetchEntity(by id: Int) throws -> TransactionModel? {
        let context = modelContainer.mainContext
        let predicate = #Predicate<TransactionModel> { $0.id == id }
        let fetchDescriptor = FetchDescriptor<TransactionModel>(predicate: predicate)
        return try context.fetch(fetchDescriptor).first
    }

    // MARK: - Update

    func update(id: Int, with transaction: Transaction) throws {
        guard let existing = try fetchEntity(by: id) else {
            throw NSError(domain: "TransactionStorage", code: 2, userInfo: [NSLocalizedDescriptionKey: "Transaction not found."])
        }

        updateEntity(existing, with: transaction)
        try modelContainer.mainContext.save()
    }

    // MARK: - Delete

    func delete(by id: Int) throws {
        guard let entity = try fetchEntity(by: id) else {
            throw NSError(domain: "TransactionStorage", code: 3, userInfo: [NSLocalizedDescriptionKey: "Transaction not found."])
        }

        let context = modelContainer.mainContext
        context.delete(entity)
        try context.save()
    }

    // MARK: - Helper

    private func updateEntity(_ entity: TransactionModel, with transaction: Transaction) {
        entity.accountId = transaction.account.id
        entity.accountName = transaction.account.name
        entity.accountBalance = transaction.account.balance
        entity.accountCurrency = transaction.account.currency

        entity.categoryId = transaction.category.id
        entity.categoryName = transaction.category.name
        entity.categoryEmoji = String(transaction.category.emoji)
        entity.isIncome = transaction.category.isIncome == true

        entity.amount = transaction.amount
        entity.transactionDate = transaction.transactionDate
        entity.comment = transaction.comment
        entity.createdAt = transaction.createdAt
        entity.updatedAt = transaction.updatedAt
    }
    
    func fetchPendingSync() throws -> [Transaction] {
        let context = modelContainer.mainContext
        let predicate = #Predicate<TransactionModel> { $0.isSynced == false }
        let entities = try context.fetch(FetchDescriptor(predicate: predicate))
        return entities.map { model in
            let account  = AccountBrief(id: model.accountId, name: model.accountName, balance: model.accountBalance, currency: model.accountCurrency)
            let category = Category(id: model.categoryId, name: model.categoryName, emoji: model.categoryEmoji.first ?? "1", isIncome: model.isIncome)

            return Transaction(
                id:              model.id,
                account:         account,
                category:        category,
                amount:          model.amount,
                transactionDate: model.transactionDate,
                comment:         model.comment,
                createdAt:       model.createdAt,
                updatedAt:       model.updatedAt
            )
        }
    }

    func markAsSynced(id: Int) throws {
        guard let entity = try fetchEntity(by: id) else { return }
        entity.isSynced = true
        try modelContainer.mainContext.save()
    }

}

extension TransactionStorage {
    func save(transactions: [Transaction]) throws {
        for transaction in transactions {
            do {
                try create(transaction: transaction)
            } catch {
                try update(id: transaction.id, with: transaction)
            }
        }
    }
}

import Foundation

class TransactionsFileCache {
    
    private var transactions: [Transaction] = []
    
    public func add(_ transaction: Transaction) {
        guard !transactions.contains(where: {$0.id == transaction.id}) else {
            return
        }
        transactions.append(transaction)
    }
    
    public func remove(by id: Int) { 
        guard let index = transactions.firstIndex(where: {$0.id == id}) else {
            return
        }
        transactions.remove(at: index)
    }
    
    //TODO: Сохранение всех операций в файл в формате JSON
    public func save(to filename: String) {}
    
    //TODO: Загрузка всех операций из файла в формате JSON
    public func load(from filename: String) {}
    
    
}

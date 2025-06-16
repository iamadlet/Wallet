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
    public func save(to filename: String) throws {
        let array: [Any] = transactions.map { $0.jsonObject }
        
        let data = try JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
        let url = getURL(for: filename)
        try data.write(to: url)
        
    }
    
    private func getURL(for filename: String) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(filename).appendingPathExtension("json")
    }
    
    //TODO: Загрузка всех операций из файла в формате JSON
    public func load(from filename: String) throws {
        let url = getURL(for: filename)
        
        let data = try Data(contentsOf: url)
        
        let rawArray = try JSONSerialization.jsonObject(with: data) as? [Any] ?? []
        
        transactions = rawArray.compactMap { Transaction.parse(jsonObject: $0) }
    }
    
    
}

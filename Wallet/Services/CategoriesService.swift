import Foundation

final class CategoriesService {
    
    let categories = [
        Category(id: 0, name: "Дом", emoji: "🏠", isIncome: false),
        Category(id: 1, name: "Машина", emoji: "🚘", isIncome: false),
        Category(id: 2, name: "Продукты", emoji: "🥯", isIncome: false),
        Category(id: 3, name: "Зарплата", emoji: "💵", isIncome: true),
        Category(id: 3, name: "Ставки", emoji: "🎰", isIncome: true),
    ]
    
    func categories() async throws -> [Category] {
        categories
    }
    
    func getCategories(of type: Direction) async throws -> [Category] {
        let res = type == .income ? true : false
        let outcomeArray = categories.filter { $0.isIncome == res }
        return outcomeArray
    }
}

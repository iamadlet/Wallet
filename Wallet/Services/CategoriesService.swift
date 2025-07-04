import Foundation

final class CategoriesService {
    
    let categories = [
        Category(id: 0, name: "Аренда квартиры", emoji: "🏠", isIncome: false),
        Category(id: 1, name: "Машина", emoji: "🚘", isIncome: false),
        Category(id: 2, name: "Продукты", emoji: "🍬", isIncome: false),
        Category(id: 3, name: "Зарплата", emoji: "💵", isIncome: true),
        Category(id: 4, name: "На собачку", emoji: "🐕", isIncome: false),
        Category(id: 5, name: "Одежда", emoji: "👔", isIncome: false),
        Category(id: 6, name: "Ремонт квартиры", emoji: "🔨", isIncome: false),
        Category(id: 7, name: "Спортзал", emoji: "🏋️‍♂️", isIncome: false),
        Category(id: 8, name: "Рестораны", emoji: "🍽️", isIncome: false),
        Category(id: 9, name: "Аптека", emoji: "💜", isIncome: false),
        Category(id: 10, name: "Медицина", emoji: "💊", isIncome: false),
        Category(id: 11, name: "Подработка", emoji: "💵", isIncome: true),
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

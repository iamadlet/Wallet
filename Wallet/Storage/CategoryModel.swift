import Foundation
import SwiftData

@Model
final class CategoryModel {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool
    private var incomeRawValue: String
    
    var income: Direction {
        get { Direction(rawValue: incomeRawValue) ?? .outcome }
        set { incomeRawValue = newValue.rawValue }
    }
    
    init(id: Int, name: String, emoji: String, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
        self.incomeRawValue = isIncome ? Direction.income.rawValue : Direction.outcome.rawValue
    }
}

@MainActor
final class CategoryStorage {
    private let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func save(categories: [Category]) throws {
        let context = modelContainer.mainContext
        
        for category in categories {
            let categoryID = category.id
            
            let fetchDescriptor = FetchDescriptor<CategoryModel>(
                predicate: #Predicate<CategoryModel> { $0.id == categoryID }
            )
            
            if let existing = try context.fetch(fetchDescriptor).first {
                existing.name = category.name
                existing.emoji = String(category.emoji)
                existing.isIncome = category.isIncome
            } else {
                let newEntity = CategoryModel(
                    id: category.id,
                    name: category.name,
                    emoji: String(category.emoji),
                    isIncome: category.isIncome
                )
                context.insert(newEntity)
            }
        }
        
        try context.save()
    }
    
    func fetchAll() throws -> [Category] {
        let context = modelContainer.mainContext
        let entities = try context.fetch(FetchDescriptor<CategoryModel>())
        return entities.map {
            Category(
                id: $0.id,
                name: $0.name,
                emoji: Character($0.emoji),
                isIncome: $0.isIncome
            )
        }
    }
    
    func fetch(by direction: Direction) throws -> [Category] {
        let context = modelContainer.mainContext
        
        let isIncome = (direction == .income)
        let predicate = #Predicate<CategoryModel> {
            $0.isIncome == isIncome
        }
        
        let entities = try context.fetch(FetchDescriptor<CategoryModel>(predicate: predicate))
        return entities.map {
            Category(
                id: $0.id,
                name: $0.name,
                emoji: Character($0.emoji),
                isIncome: $0.isIncome
            )
        }
    }
    
    func deleteAll() throws {
        let context = modelContainer.mainContext
        let allEntities = try context.fetch(FetchDescriptor<CategoryModel>())
        allEntities.forEach { context.delete($0) }
        try context.save()
    }
}

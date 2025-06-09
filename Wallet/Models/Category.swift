import Foundation


struct Category {
    var id: Int
    var name: String
    var emoji: Character
    var isIncome: Bool
    
    var direction: Direction {
        isIncome ? .income : .outcome
    }
}


enum Direction {
    case income
    case outcome
}

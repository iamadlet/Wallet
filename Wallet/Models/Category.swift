import Foundation


struct Category {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Bool
    
    var direction: Direction {
        isIncome ? .income : .outcome
    }
}


enum Direction {
    case income
    case outcome
}

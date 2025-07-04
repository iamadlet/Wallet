import Foundation

extension FuzzySearchable {
    func fuzzyMatch(query: String, characters: FuzzySearchString) -> FuzzySearchMatchResult {
        let compareString = characters.characters // строка, которую мы сравниваем
        let searchString = query.lowercased() // запрос, делаем его независимым от регистра
        
        var totalScore = 0 // "вес" сходства
        var matchedParts = [NSRange]() // диапазон который схож с compareString и searchString
        
        // Данные всегда для одноо "мэтча"
        var patternIndex = 0
        var currentScore = 0
        var currentMatchedPart = NSRange(location: 0, length: 0)
        
        for (index, character) in compareString.enumerated() {
            if let prefixLength = searchString.hasPrefix(prefix: character, startingAt: patternIndex) {
                // Если есть мэтч, то инкрементим вес и диапазон
                patternIndex += prefixLength
                currentScore += 1
                currentMatchedPart.length += 1
            } else {
                // Если нет мэтча
                currentScore = 0
                if currentMatchedPart.length != 0 {
                    matchedParts.append(currentMatchedPart)
                }
                currentMatchedPart = NSRange(location: index + 1, length: 0)
            }
            totalScore += currentScore
        }
        
        if currentMatchedPart.length > 0 {
            matchedParts.append(currentMatchedPart)
        }
        
        if searchString.count == matchedParts.reduce(0, { partialResults, range in
            range.length + partialResults
        }) {
            return FuzzySearchMatchResult(weight: totalScore, matchedParts: matchedParts)
        } else {
            return FuzzySearchMatchResult(weight: 0, matchedParts: [])
        }
    }
    
    func normaliseString() -> FuzzySearchString {
        return FuzzySearchString(characters: searchableString.normalise())
    }
    
    func fuzzyMatch(query: String) -> FuzzySearchMatchResult {
        let characters = normaliseString()
        
        return fuzzyMatch(query: query, characters: characters)
    }
}

import Foundation

extension String {
    func normalise() -> [FuzzySearchCharacter] {
        return self.lowercased().map { char in
            guard let data = String(char).data(using: .ascii, allowLossyConversion: true), let normalisedCharacter = String(data: data, encoding: .ascii) else {
                    return FuzzySearchCharacter(content: String(char), normalisedContent: String(char))
            }
            
            return FuzzySearchCharacter(content: String(char), normalisedContent: normalisedCharacter)
        }
    }
}

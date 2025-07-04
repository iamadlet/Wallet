import Foundation

extension String {
    func hasPrefix(prefix: FuzzySearchCharacter, startingAt index: Int) -> Int? {
        guard let stringIndex = self.index(self.startIndex, offsetBy: index, limitedBy: self.endIndex) else {
            return nil
        }
        let searchString = self.suffix(from: stringIndex)
        for prefix in [prefix.content, prefix.normalisedContent] where searchString.hasPrefix(prefix) {
            return prefix.count
        }
        return nil
    }
}

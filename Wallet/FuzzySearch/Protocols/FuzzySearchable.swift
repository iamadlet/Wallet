import Foundation

protocol FuzzySearchable {
    var searchableString: String { get }
    
    func fuzzyMatch(query: String, characters: FuzzySearchString) -> FuzzySearchMatchResult
    
    
}

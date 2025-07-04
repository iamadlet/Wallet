import Foundation

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var error: Error?
    
    var filteredCategories: [Category] {
        guard !searchText.isEmpty else {
            return categories
        }
        return categories
            .fuzzySearch(query: searchText)
            .map { $0.item }
    }
    
    private let categoriesService: CategoriesService
    
    init(categoriesService: CategoriesService) {
        self.categoriesService = categoriesService
        self.categories = categoriesService.categories
    }
    
    func loadCategories() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let rawCategories = try await categoriesService.categories()
            
            self.categories = rawCategories
        } catch {
            self.error = error
        }
    }
    
    func filteredCategories(categories: [Category], searchText: String) -> [Category] {
        guard !searchText.isEmpty else {
            return categories
        }
        
        return categories.filter {$0.name == searchText}
    }
}

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
    
    private let service: CategoriesService
    
    init(service: CategoriesService) {
        self.service = service
    }
    
    func loadCategories(of direction: Direction) async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.categories = try await service.getCategories(of: direction)
        } catch {
            self.error = error
        }
    }
    
    func allCategories() async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.categories = try await service.categories()
        } catch {
            self.error = error
        }
    }
    
    func filteredCategories(categories: [Category], searchText: String) -> [Category] {
        guard !searchText.isEmpty else {
            return categories
        }
        return categories.filter { $0.name == searchText }
    }
}

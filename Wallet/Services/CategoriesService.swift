import Foundation

final class CategoriesService {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }
    
    func categories() async throws -> [Category] {
        return try await client.request(
            path: "categories",
            method: "GET",
            body: EmptyBody()
        )
    }
    
    func getCategories(of direction: Direction) async throws -> [Category] {
        let isIncome = direction == .income
        let path = "categories/type/\(isIncome)"
        
        return try await client.request(
            path: path,
            method: "GET",
            body: EmptyBody()
        )
    }
}

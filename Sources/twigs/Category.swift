import Foundation

struct Category: Identifiable, Hashable, Codable {
    let budgetId: String
    let id: String
    let title: String
    let description: String?
    let amount: Int
    let expense: Bool
    let archived: Bool
}

protocol CategoryRepository {
    func getCategories(budgetId: String?, expense: Bool?, archived: Bool?, count: Int?, page: Int?) async throws -> [Category]
    func getCategory(_ categoryId: String) async throws -> Category
    func createCategory(_ category: Category) async throws -> Category
    func updateCategory(_ category: Category) async throws -> Category
    func deleteCategory(_ id: String) async throws
}

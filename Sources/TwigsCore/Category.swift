import Foundation

public struct Category: Identifiable, Hashable, Codable {
    public let budgetId: String
    public let id: String
    public let title: String
    public let description: String?
    public let amount: Int
    public let expense: Bool
    public let archived: Bool
}

public protocol CategoryRepository {
    func getCategories(budgetId: String?, expense: Bool?, archived: Bool?, count: Int?, page: Int?) async throws -> [Category]
    func getCategory(_ categoryId: String) async throws -> Category
    func createCategory(_ category: Category) async throws -> Category
    func updateCategory(_ category: Category) async throws -> Category
    func deleteCategory(_ id: String) async throws
}

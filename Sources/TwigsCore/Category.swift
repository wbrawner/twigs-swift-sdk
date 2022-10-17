import Foundation

public struct Category: Identifiable, Hashable, Codable {
    public let budgetId: String
    public let id: String
    public let title: String
    public let description: String?
    public let amount: Int
    public let expense: Bool
    public let archived: Bool
    
    public init(
        budgetId: String,
        id: String = "",
        title: String = "",
        description: String? = "",
        amount: Int = 0,
        expense: Bool = true,
        archived: Bool = false
    ) {
        self.budgetId = budgetId
        self.id = id
        self.title = title
        self.description = description
        self.amount = amount
        self.expense = expense
        self.archived = archived
    }
}

extension Category {
    public var type: TransactionType {
        if (self.expense) {
            return .expense
        } else {
            return .income
        }
    }

    public var amountString: String {
        return self.amount > 0 ? String(format: "%.02f", Double(self.amount) / 100.0) : ""
    }
}

public protocol CategoryRepository {
    func getCategories(budgetId: String?, expense: Bool?, archived: Bool?, count: Int?, page: Int?) async throws -> [Category]
    func getCategory(_ categoryId: String) async throws -> Category
    func createCategory(_ category: Category) async throws -> Category
    func updateCategory(_ category: Category) async throws -> Category
    func deleteCategory(_ id: String) async throws
}

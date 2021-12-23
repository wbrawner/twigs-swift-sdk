import Foundation

public struct Budget: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let currencyCode: String?
}

public struct BudgetOverview {
    public let budget: Budget
    public let balance: Int
    public var expectedIncome: Int = 0
    public var actualIncome: Int = 0
    public var expectedExpenses: Int = 0
    public var actualExpenses: Int = 0
}

public protocol BudgetRepository {
    func getBudgets(count: Int?, page: Int?) async throws -> [Budget]
    func getBudget(_ id: String) async throws -> Budget
    func newBudget(_ budget: Budget) async throws -> Budget
    func updateBudget(_ budget: Budget) async throws -> Budget
    func deleteBudget(_ id: String) async throws
}

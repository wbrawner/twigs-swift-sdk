import Foundation

public struct Budget: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let currencyCode: String?

    public init(id: String, name: String, description: String?, currencyCode: String?) {
        self.id = id
        self.name = name
        self.description = description
        self.currencyCode = currencyCode
    }
}

public struct BudgetOverview: Equatable {
    public let budget: Budget
    public let balance: Int
    public var expectedIncome: Int
    public var actualIncome: Int
    public var expectedExpenses: Int
    public var actualExpenses: Int
    
    public init(budget: Budget, balance: Int, expectedIncome: Int = 0, actualIncome: Int = 0, expectedExpenses: Int = 0, actualExpenses: Int = 0) {
        self.budget = budget
        self.balance = balance
        self.expectedIncome = expectedIncome
        self.actualIncome = actualIncome
        self.expectedExpenses = expectedExpenses
        self.actualExpenses = actualExpenses
    }
}

public protocol BudgetRepository {
    func getBudgets(count: Int?, page: Int?) async throws -> [Budget]
    func getBudget(_ id: String) async throws -> Budget
    func newBudget(_ budget: Budget) async throws -> Budget
    func updateBudget(_ budget: Budget) async throws -> Budget
    func deleteBudget(_ id: String) async throws
}

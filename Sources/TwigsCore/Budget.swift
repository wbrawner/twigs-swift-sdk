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
    public let transactionCount: Int
    public let categories: [Category]
    public var expectedIncome: Float
    public var actualIncome: Float
    public var expectedExpenses: Float
    public var actualExpenses: Float
    
    public init(
        budget: Budget,
        balance: Int,
        categories: [Category],
        transactionCount: Int,
        expectedIncome: Int = 0,
        actualIncome: Int = 0,
        expectedExpenses: Int = 0,
        actualExpenses: Int = 0
    ) {
        self.budget = budget
        self.balance = balance
        self.categories = categories
        self.transactionCount = transactionCount
        self.expectedIncome = Float(expectedIncome) / 100.0
        self.actualIncome = Float(actualIncome) / 100.0
        self.expectedExpenses = Float(expectedExpenses) / 100.0
        self.actualExpenses = Float(actualExpenses) / 100.0
    }
}

public protocol BudgetRepository {
    func getBudgets(count: Int?, page: Int?) async throws -> [Budget]
    func getBudget(_ id: String) async throws -> Budget
    func newBudget(_ budget: Budget) async throws -> Budget
    func updateBudget(_ budget: Budget) async throws -> Budget
    func deleteBudget(_ id: String) async throws
}

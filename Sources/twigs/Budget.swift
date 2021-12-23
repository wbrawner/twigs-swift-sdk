import Foundation

struct Budget: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String?
    let currencyCode: String?
}

struct BudgetOverview {
    let budget: Budget
    let balance: Int
    var expectedIncome: Int = 0
    var actualIncome: Int = 0
    var expectedExpenses: Int = 0
    var actualExpenses: Int = 0
}

protocol BudgetRepository {
    func getBudgets(count: Int?, page: Int?) async throws -> [Budget]
    func getBudget(_ id: String) async throws -> Budget
    func newBudget(_ budget: Budget) async throws -> Budget
    func updateBudget(_ budget: Budget) async throws -> Budget
    func deleteBudget(_ id: String) async throws
}

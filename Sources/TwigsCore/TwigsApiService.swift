//
//  File.swift
//  
//
//  Created by William Brawner on 12/22/21.
//

import Foundation

open class TwigsApiService: BudgetRepository, CategoryRepository, RecurringTransactionsRepository, TransactionRepository, UserRepository {
    let requestHelper: RequestHelper
    
    public convenience init() {
        self.init(RequestHelper())
    }
    
    init(_ requestHelper: RequestHelper) {
        self.requestHelper = requestHelper
    }
    
    public var baseUrl: String? {
        get {
            return requestHelper.baseUrl
        }
        set {
            requestHelper.baseUrl = newValue
        }
    }
    
    public var token: String? {
        get {
            return requestHelper.token
        }
        set {
            requestHelper.token = newValue
        }
    }
    
    // MARK: Budgets
    public func getBudgets(count: Int? = nil, page: Int? = nil) async throws -> [Budget] {
        var queries = [String: Array<String>]()
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return try await requestHelper.get("/api/budgets", queries: queries)
    }
    
    public func getBudget(_ id: String) async throws -> Budget {
        return try await requestHelper.get("/api/budgets/\(id)")
    }
    
    public func newBudget(_ budget: Budget) async throws -> Budget {
        return try await requestHelper.post("/api/budgets", data: budget, type: Budget.self)
    }
    
    public func updateBudget(_ budget: Budget) async throws -> Budget {
        return try await requestHelper.put("/api/budgets/\(budget.id)", data: budget)
    }
    
    public func deleteBudget(_ id: String) async throws  {
        return try await requestHelper.delete("/api/budgets/\(id)")
    }
    
    // MARK: Transactions
    
    public func getTransactions(
        budgetIds: [String],
        categoryIds: [String]? = nil,
        from: Date? = nil,
        to: Date? = nil,
        count: Int? = nil,
        page: Int? = nil
    ) async throws -> [Transaction] {
        var queries = [String: Array<String>]()
        queries["budgetIds"] = budgetIds
        if categoryIds != nil {
            queries["categoryIds"] = categoryIds!
        }
        if from != nil {
            queries["from"] = [from!.toISO8601String()]
        }
        if to != nil {
            queries["to"] = [to!.toISO8601String()]
        }
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return try await requestHelper.get("/api/transactions", queries: queries)
    }
    
    public func getTransaction(_ id: String) async throws -> Transaction {
        return try await requestHelper.get("/api/transactions/\(id)")
    }
    
    public func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        return try await requestHelper.post("/api/transactions", data: transaction, type: Transaction.self)
    }
    
    public func updateTransaction(_ transaction: Transaction) async throws -> Transaction {
        return try await requestHelper.put("/api/transactions/\(transaction.id)", data: transaction)
    }
    
    public func deleteTransaction(_ id: String) async throws  {
        return try await requestHelper.delete("/api/transactions/\(id)")
    }
    
    public func sumTransactions(budgetId: String? = nil, categoryId: String? = nil, from: Date? = nil, to: Date? = nil) async throws -> BalanceResponse {
        var queries = [String: Array<String>]()
        if let budgetId = budgetId {
            queries["budgetId"] = [budgetId]
        }
        if let categoryId = categoryId {
            queries["categoryId"] = [categoryId]
        }
        if let from = from {
            queries["from"] = [from.toISO8601String()]
        }
        if let to = to {
            queries["to"] = [to.toISO8601String()]
        }
        return try await requestHelper.get("/api/transactions/sum", queries: queries)
    }
    
    // MARK: Categories
    public func getCategories(budgetId: String? = nil, expense: Bool? = nil, archived: Bool? = nil, count: Int? = nil, page: Int? = nil) async throws -> [Category] {
        var queries = [String: Array<String>]()
        if budgetId != nil {
            queries["budgetIds"] = [String(budgetId!)]
        }
        if expense != nil {
            queries["expense"] = [String(expense!)]
        }
        if archived != nil {
            queries["archived"] = [String(archived!)]
        }
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return try await requestHelper.get("/api/categories", queries: queries)
    }
    
    public func getCategory(_ id: String) async throws -> Category {
        return try await requestHelper.get("/api/categories/\(id)")
    }
    
    public func getCategoryBalance(_ id: String) async throws -> Int {
        return try await requestHelper.get("/api/categories/\(id)/balance")
    }
    
    public func createCategory(_ category: Category) async throws -> Category {
        return try await requestHelper.post("/api/categories", data: category, type: Category.self)
    }
    
    public func updateCategory(_ category: Category) async throws -> Category {
        return try await requestHelper.put("/api/categories/\(category.id)", data: category)
    }
    
    public func deleteCategory(_ id: String) async throws  {
        return try await requestHelper.delete("/api/categories/\(id)")
    }
    
    // MARK: Users
    public func login(username: String, password: String) async throws -> LoginResponse {
        let response = try await requestHelper.post(
            "/api/users/login",
            data: LoginRequest(username: username, password: password),
            type: LoginResponse.self
        )
        self.requestHelper.token = response.token
        return response
    }
    
    public func register(username: String, email: String, password: String) async throws -> User {
        return try await requestHelper.post(
            "/api/users/register",
            data: RegistrationRequest(username: username, email: email, password: password),
            type: User.self
        )
    }
    
    public func getUser(_ id: String) async throws -> User {
        return try await requestHelper.get("/api/users/\(id)")
    }
    
    public func searchUsers(_ query: String) async throws -> [User] {
        return try await requestHelper.get(
            "/api/users/search",
            queries: ["query": [query]]
        )
    }
    
    public func getUsers(count: Int? = nil, page: Int? = nil) async throws -> [User] {
        var queries = [String: Array<String>]()
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return try await requestHelper.get("/api/Users", queries: queries)
    }
    
    public func newUser(_ user: User) async throws -> User {
        return try await requestHelper.post("/api/users", data: user, type: User.self)
    }
    
    public func updateUser(_ user: User) async throws -> User {
        return try await requestHelper.put("/api/users/\(user.id)", data: user)
    }
    
    public func deleteUser(_ user: User) async throws  {
        return try await requestHelper.delete("/api/users/\(user.id)")
    }
    
    // MARK: Recurring Transactions
    public func getRecurringTransactions(budgetId: String) async throws -> [RecurringTransaction] {
        return try await requestHelper.get("/api/recurringtransactions", queries: ["budgetId": [budgetId]])
    }
    
    public func getRecurringTransaction(_ id: String) async throws -> RecurringTransaction {
        return try await requestHelper.get("/api/recurringtransactions/\(id)")
    }
    
    public func createRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction {
        return try await requestHelper.post("/api/recurringtransactions", data: transaction, type: RecurringTransaction.self)
    }
    
    public func updateRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction {
        return try await requestHelper.put("/api/recurringtransactions/\(transaction.id)", data: transaction)
    }
    
    public func deleteRecurringTransaction(_ id: String) async throws {
        return try await requestHelper.delete("/api/recurringtransactions/\(id)")
    }
}

class RequestHelper {
    let decoder = JSONDecoder()
    private var _baseUrl: String? = nil
    var baseUrl: String? {
        get {
            self.baseUrl
        }
        set {
            guard var correctServer = newValue?.lowercased() else {
                return
            }
            if !correctServer.starts(with: "http://") && !correctServer.starts(with: "https://") {
                correctServer = "http://\(correctServer)"
            }
            self._baseUrl = correctServer
        }
    }
    var token: String?
    
    init() {
        self.decoder.dateDecodingStrategy = .formatted(Date.iso8601DateFormatter)
    }
    
    func get<ResultType: Codable>(
        _ endPoint: String,
        queries: [String: Array<String>]? = nil
    ) async throws -> ResultType {
        var combinedEndPoint = endPoint
        if (queries != nil) {
            for (key, values) in queries! {
                for value in values {
                    let separator = combinedEndPoint.contains("?") ? "&" : "?"
                    combinedEndPoint += separator + key + "=" + value
                }
            }
        }
        
        return try await buildRequest(endPoint: combinedEndPoint, method: "GET")
    }
    
    func post<ResultType: Codable>(
        _ endPoint: String,
        data: Codable,
        type: ResultType.Type
    ) async throws -> ResultType {
        return try await buildRequest(
            endPoint: endPoint,
            method: "POST",
            data: data
        )
    }
    
    func put<ResultType: Codable>(
        _ endPoint: String,
        data: ResultType
    ) async throws -> ResultType {
        return try await buildRequest(
            endPoint: endPoint,
            method: "PUT",
            data: data
        )
    }
    
    func delete(_ endPoint: String) async throws {
        // Delete requests return no body so they need a special request helper
        guard let url = URL(string: self.baseUrl + endPoint) else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        
        let (_, res) = try await URLSession.shared.data(for: request)
        guard let response = res as? HTTPURLResponse, 200...299 ~= response.statusCode else {
            switch (res as? HTTPURLResponse)?.statusCode {
            case 400: throw NetworkError.badRequest
            case 401, 403: throw NetworkError.unauthorized
            case 404: throw NetworkError.notFound
            default: throw NetworkError.unknown
            }
        }
    }
    
    private func buildRequest<ResultType: Codable>(
        endPoint: String,
        method: String,
        data: Encodable? = nil
    ) async throws -> ResultType {
        guard let url = URL(string: self.baseUrl + endPoint) else {
            print("Unable to build url from base: \(self.baseUrl)")
            throw NetworkError.invalidUrl
        }
        
        print("\(method) - \(url)")
        
        var request = URLRequest(url: url)
        request.httpBody = data?.toJSONData()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, res) = try await URLSession.shared.data(for: request)
        guard let response = res as? HTTPURLResponse, 200...299 ~= response.statusCode else {
            switch (res as? HTTPURLResponse)?.statusCode {
            case 400: throw NetworkError.badRequest
            case 401, 403: throw NetworkError.unauthorized
            case 404: throw NetworkError.notFound
            default: throw NetworkError.unknown
            }
        }
        return try self.decoder.decode(ResultType.self, from: data)
    }
}

public enum NetworkError: Error, Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.notFound, .notFound):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.badRequest, .badRequest):
            return true
        case (.invalidUrl, .invalidUrl):
            return true
        case (let .jsonParsingFailed(error1), let .jsonParsingFailed(error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
    
    public var name: String {
        get {
            switch self {
            case .unknown:
                return "unknown"
            case .notFound:
                return "notFound"
            case .deleted:
                return "deleted"
            case .unauthorized:
                return "unauthorized"
            case .badRequest:
                return "badRequest"
            case .invalidUrl:
                return "invalidUrl"
            case .jsonParsingFailed(_):
                return "jsonParsingFailed"
            }
        }
    }
    
    case unknown
    case notFound
    case deleted
    case unauthorized
    case badRequest
    case invalidUrl
    case jsonParsingFailed(Error)
}

extension Encodable {
    func toJSONData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(self)
    }
}

extension Date {
    static let iso8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }()
    
    func toISO8601String() -> String {
        return Date.iso8601DateFormatter.string(from: self)
    }
}


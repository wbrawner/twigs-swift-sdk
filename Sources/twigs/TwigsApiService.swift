//
//  File.swift
//  
//
//  Created by William Brawner on 12/22/21.
//

import Foundation

class TwigsApiService: BudgetRepository, CategoryRepository, RecurringTransactionsRepository, TransactionRepository, UserRepository {
    let requestHelper: RequestHelper
    
    convenience init(_ serverUrl: String) {
        self.init(RequestHelper(serverUrl))
    }
    
    init(_ requestHelper: RequestHelper) {
        self.requestHelper = requestHelper
    }
    
    var token: String? {
        get {
            return requestHelper.token
        }
        set {
            requestHelper.token = newValue
        }
    }
        
    // MARK: Budgets
    func getBudgets(count: Int? = nil, page: Int? = nil) async throws -> [Budget] {
        var queries = [String: Array<String>]()
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return try await requestHelper.get("/api/budgets", queries: queries)
    }
    
    func getBudget(_ id: String) async throws -> Budget {
        return try await requestHelper.get("/api/budgets/\(id)")
    }
    
    func newBudget(_ budget: Budget) async throws -> Budget {
        return try await requestHelper.post("/api/budgets", data: budget, type: Budget.self)
    }
    
    func updateBudget(_ budget: Budget) async throws -> Budget {
        return try await requestHelper.put("/api/budgets/\(budget.id)", data: budget)
    }
    
    func deleteBudget(_ id: String) async throws  {
        return try await requestHelper.delete("/api/budgets/\(id)")
    }
    
    // MARK: Transactions
    
  func getTransactions(
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
    
    func getTransaction(_ id: String) async throws -> Transaction {
        return try await requestHelper.get("/api/transactions/\(id)")
    }
    
    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        return try await requestHelper.post("/api/transactions", data: transaction, type: Transaction.self)
    }
    
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction {
        return try await requestHelper.put("/api/transactions/\(transaction.id)", data: transaction)
    }
    
    func deleteTransaction(_ id: String) async throws  {
        return try await requestHelper.delete("/api/transactions/\(id)")
    }
    
    func sumTransactions(budgetId: String? = nil, categoryId: String? = nil, from: Date? = nil, to: Date? = nil) async throws -> BalanceResponse {
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
    
    func getCategories(budgetId: String? = nil, expense: Bool? = nil, archived: Bool? = nil, count: Int? = nil, page: Int? = nil) async throws -> [Category] {
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
    
    func getCategory(_ id: String) async throws -> Category {
        return try await requestHelper.get("/api/categories/\(id)")
    }
    
    func getCategoryBalance(_ id: String) async throws -> Int {
        return try await requestHelper.get("/api/categories/\(id)/balance")
    }
    
    func createCategory(_ category: Category) async throws -> Category {
        return try await requestHelper.post("/api/categories", data: category, type: Category.self)
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        return try await requestHelper.put("/api/categories/\(category.id)", data: category)
    }
    
    func deleteCategory(_ id: String) async throws  {
        return try await requestHelper.delete("/api/categories/\(id)")
    }
    
    // MARK: Users
    func login(username: String, password: String) async throws -> LoginResponse {
        let response = try await requestHelper.post(
            "/api/users/login",
            data: LoginRequest(username: username, password: password),
            type: LoginResponse.self
        )
        self.requestHelper.token = response.token
        return response
    }
    
    func register(username: String, email: String, password: String) async throws -> User {
        return try await requestHelper.post(
            "/api/users/register",
            data: RegistrationRequest(username: username, email: email, password: password),
            type: User.self
        )
    }
    
    func getUser(_ id: String) async throws -> User {
        return try await requestHelper.get("/api/users/\(id)")
    }
    
    func searchUsers(_ query: String) async throws -> [User] {
        return try await requestHelper.get(
            "/api/users/search",
            queries: ["query": [query]]
        )
    }
    
    func getUsers(count: Int? = nil, page: Int? = nil) async throws -> [User] {
        var queries = [String: Array<String>]()
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return try await requestHelper.get("/api/Users", queries: queries)
    }
    
    func newUser(_ user: User) async throws -> User {
        return try await requestHelper.post("/api/users", data: user, type: User.self)
    }
    
    func updateUser(_ user: User) async throws -> User {
        return try await requestHelper.put("/api/users/\(user.id)", data: user)
    }
    
    func deleteUser(_ user: User) async throws  {
        return try await requestHelper.delete("/api/users/\(user.id)")
    }
    
    // MARK: Recurring Transactions
    func getRecurringTransactions(budgetId: String) async throws -> [RecurringTransaction] {
        return try await requestHelper.get("/api/recurringtransactions", queries: ["budgetId": [budgetId]])
    }
    
    func getRecurringTransaction(_ id: String) async throws -> RecurringTransaction {
        return try await requestHelper.get("/api/recurringtransactions/\(id)")
    }
    
    func createRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction {
        return try await requestHelper.post("/api/recurringtransactions", data: transaction, type: RecurringTransaction.self)
    }
    
    func updateRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction {
        return try await requestHelper.put("/api/recurringtransactions/\(transaction.id)", data: transaction)
    }
    
    func deleteRecurringTransaction(_ id: String) async throws {
        return try await requestHelper.delete("/api/recurringtransactions/\(id)")
    }
}

class RequestHelper {
    let decoder = JSONDecoder()
    private var _baseUrl: String = ""
    var baseUrl: String {
        get {
            self.baseUrl
        }
        set {
            var correctServer = newValue.lowercased()
            if !correctServer.starts(with: "http://") && !correctServer.starts(with: "https://") {
                correctServer = "http://\(correctServer)"
            }
            self._baseUrl = correctServer
        }
    }
    var token: String?
    
    init(_ serverUrl: String) {
        self.baseUrl = serverUrl
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

enum NetworkError: Error, Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
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
    
    var name: String {
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
    
    static let localeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale.current)
        return dateFormatter
    }()
    
    static var firstOfMonth: Date {
        get {
            return Calendar.current.dateComponents([.calendar, .year,.month], from: Date()).date!
        }
    }
    
    func toISO8601String() -> String {
        return Date.iso8601DateFormatter.string(from: self)
    }
    
    func toLocaleString() -> String {
        return Date.localeDateFormatter.string(from: self)
    }
}


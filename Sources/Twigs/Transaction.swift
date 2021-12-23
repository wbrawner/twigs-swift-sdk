//
//  File.swift
//  
//
//  Created by William Brawner on 12/22/21.
//

import Foundation

public struct Transaction: Identifiable, Hashable, Codable {
    public let id: String
    public let title: String
    public let description: String?
    public let date: Date
    public let amount: Int
    public let categoryId: String?
    public let expense: Bool
    public let createdBy: String
    public let budgetId: String
}

public struct BalanceResponse: Codable {
    public let balance: Int
}

public enum TransactionType: Int, CaseIterable, Identifiable, Hashable {
    case expense
    case income
    
    public var id: TransactionType { self }
}

extension Transaction {
    public var type: TransactionType {
        if (self.expense) {
            return .expense
        } else {
            return .income
        }
    }
    
    public var amountString: String {
        return String(Double(self.amount) / 100.0)
    }
}

public protocol TransactionRepository {
    func getTransactions(budgetIds: [String], categoryIds: [String]?, from: Date?, to: Date?, count: Int?, page: Int?) async throws -> [Transaction]
    func getTransaction(_ transactionId: String) async throws -> Transaction
    func createTransaction(_ transaction: Transaction) async throws -> Transaction
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction
    func deleteTransaction(_ transactionId: String) async throws
    func sumTransactions(budgetId: String?, categoryId: String?, from: Date?, to: Date?) async throws -> BalanceResponse
}

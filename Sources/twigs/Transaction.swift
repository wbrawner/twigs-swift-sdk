//
//  File.swift
//  
//
//  Created by William Brawner on 12/22/21.
//

import Foundation

struct Transaction: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let description: String?
    let date: Date
    let amount: Int
    let categoryId: String?
    let expense: Bool
    let createdBy: String
    let budgetId: String
}

struct BalanceResponse: Codable {
    let balance: Int
}

enum TransactionType: Int, CaseIterable, Identifiable, Hashable {
    case expense
    case income
    
    var id: TransactionType { self }
}

extension Transaction {
    var type: TransactionType {
        if (self.expense) {
            return .expense
        } else {
            return .income
        }
    }
    
    var amountString: String {
        return String(Double(self.amount) / 100.0)
    }
}

protocol TransactionRepository {
    func getTransactions(budgetIds: [String], categoryIds: [String]?, from: Date?, to: Date?, count: Int?, page: Int?) async throws -> [Transaction]
    func getTransaction(_ transactionId: String) async throws -> Transaction
    func createTransaction(_ transaction: Transaction) async throws -> Transaction
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction
    func deleteTransaction(_ transactionId: String) async throws
    func sumTransactions(budgetId: String?, categoryId: String?, from: Date?, to: Date?) async throws -> BalanceResponse
}

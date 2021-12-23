//
//  File.swift
//  
//
//  Created by William Brawner on 12/22/21.
//

import Foundation

public struct User: Codable, Equatable, Hashable {
    public let id: String
    public let username: String
    public let email: String?
    public let avatar: String?
}

public struct LoginRequest: Codable {
    public let username: String
    public let password: String
}

public struct LoginResponse: Codable {
    public let token: String
    public let expiration: String
    public let userId: String
}

public struct RegistrationRequest: Codable {
    public let username: String
    public let email: String
    public let password: String
}

public protocol UserRepository {
    func getUser(_ id: String) async throws -> User
    func searchUsers(_ withUsername: String) async throws -> [User]
    func login(username: String, password: String) async throws -> LoginResponse
    func register(username: String, email: String, password: String) async throws -> User
}

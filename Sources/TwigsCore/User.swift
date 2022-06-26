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
    public let password: String?
    public let email: String?
    public let avatar: String?
    
    public init(id: String, username: String, email: String?, password: String?, avatar: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.avatar = avatar
    }
    
    public func copy(
        username: String? = nil,
        email: String? = nil,
        password: String? = nil,
        avatar: String? = nil
    ) -> User {
        return User(
            id: self.id,
            username: username ?? self.username,
            email: email ?? self.email,
            password: password ?? self.password,
            avatar: avatar ?? self.avatar
        )
    }
}

public struct LoginRequest: Codable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public struct LoginResponse: Codable {
    public let token: String
    public let expiration: String
    public let userId: String
    
    public init(token: String, expiration: String, userId: String) {
        self.token = token
        self.expiration = expiration
        self.userId = userId
    }
}

public struct RegistrationRequest: Codable {
    public let username: String
    public let email: String
    public let password: String
    
    public init(username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }
}

public protocol UserRepository {
    func getUser(_ id: String) async throws -> User
    func searchUsers(_ withUsername: String) async throws -> [User]
    func login(username: String, password: String) async throws -> LoginResponse
    func register(username: String, email: String, password: String) async throws -> User
}

//
//  File.swift
//  
//
//  Created by William Brawner on 12/22/21.
//

import Foundation

struct User: Codable, Equatable, Hashable {
    let id: String
    let username: String
    let email: String?
    let avatar: String?
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let expiration: String
    let userId: String
}

struct RegistrationRequest: Codable {
    let username: String
    let email: String
    let password: String
}

protocol UserRepository {
    func getUser(_ id: String) async throws -> User
    func searchUsers(_ withUsername: String) async throws -> [User]
    func login(username: String, password: String) async throws -> LoginResponse
    func register(username: String, email: String, password: String) async throws -> User
}

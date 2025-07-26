//
//  Router+URLSession.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

protocol RouterSession {
    func perform(_ request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: RouterSession {
    func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        return try await self.data(for: request)
    }
}

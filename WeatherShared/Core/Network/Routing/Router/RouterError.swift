//
//  RouterError.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum RouterError: LocalizedError {
    case badRequest(underlyingError: RouteRequestBuildError)
    case serverError(errorCode: Int)
    case urlSessionError(underlyingError: Error)
    case decodingError(underlyingError: Error)
    case unknown(underlyingError: Error)

    var errorDescription: String? {
        switch self {
        case .badRequest(let underlyingError):
            return "Bad request error (underlying: \(underlyingError))"
        case .serverError(let errorCode):
            return "Server error: Status \(errorCode)"
        case .urlSessionError(let underlyingError):
            return "URL Session error (underlying: \(underlyingError))"
        case .decodingError(let underlyingError):
            return "Decoding error (underlying: \(underlyingError))"
        case .unknown(let underlyingError):
            return "Unknown error (underlying: \(underlyingError))"
        }
    }
}

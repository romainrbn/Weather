//
//  RouteRequestBuildError.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum RouteRequestBuildError: Error {
    case badBaseURL
    case badURL
    case badRequest
    case unknown(underlyingError: Error)
}

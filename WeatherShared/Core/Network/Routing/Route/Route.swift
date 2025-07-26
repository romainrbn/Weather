//
//  Route.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation
import Combine

protocol Route {
    associatedtype OutputType: Decodable
    associatedtype EncoderType: TopLevelEncoder

    var path: String { get }
    var encoder: EncoderType { get }

    var additionalQueryParameters: [URLQueryItem] { get }
    var pathParameters: [String] { get }

    func toRequest() throws -> URLRequest
}

extension Route {
    var additionalQueryParameters: [URLQueryItem] { [] }

    var pathParameters: [String] { [] }

    var encoder: JSONEncoder { JSONEncoder() }

    var queryParameters: [URLQueryItem]? {
        additionalQueryParameters
    }
}

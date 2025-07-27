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

    var queryParameters: [URLQueryItem] { get }
    func toRequest() throws -> URLRequest
}

extension Route {
    var encoder: JSONEncoder { JSONEncoder() }

    var queryParameters: [URLQueryItem] { [] }
}

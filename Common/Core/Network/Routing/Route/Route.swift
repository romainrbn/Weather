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

    var path: String { get }
    var queryParams: [String: String] { get }
    func toRequest() throws -> URLRequest
}

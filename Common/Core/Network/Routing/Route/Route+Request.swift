//
//  Route+Request.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

private enum Constants {
    static let baseURLString: String = "https://api.openweathermap.org/data/2.5"
    static let maxTimeout: TimeInterval = 30.0
}

extension Route {
    func toRequest() throws -> URLRequest {
        guard
            let baseURL = URL(string: Constants.baseURLString),
            var urlComponents = URLComponents(string: baseURL.appendingPathComponent(path).absoluteString)
        else {
            throw RouteRequestBuildError.badBaseURL
        }

        urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = urlComponents.url else { throw RouteRequestBuildError.badURL }

        var request = URLRequest(url: url)
        request.timeoutInterval = TimeInterval(Constants.maxTimeout)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = "GET"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}

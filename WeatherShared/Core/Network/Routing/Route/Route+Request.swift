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
            var urlComponents = URLComponents(string: baseURL.absoluteString)
        else {
            throw RouteRequestBuildError.badBaseURL
        }

        urlComponents.queryItems = queryParameters

        var url = urlComponents.url?.appendingPathComponent(path)

        pathParameters.forEach {
            url?.appendPathComponent($0)
        }

        guard let url else { throw RouteRequestBuildError.badURL }

        var request = URLRequest(url: url)
        request.timeoutInterval = TimeInterval(Constants.maxTimeout)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = "GET"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}

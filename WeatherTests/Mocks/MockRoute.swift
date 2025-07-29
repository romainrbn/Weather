//
//  MockRoute.swift
//  WeatherTests
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation
import Testing

@testable import Weather

struct MockRoute: Route {
    typealias OutputType = MockResponse

    let path: String = "weather"
    let queryParams: [String : String]

    func toRequest() throws -> URLRequest {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        return URLRequest(url: components.url!)
    }
}

struct MockResponse: Codable, Equatable {
    let temp: Double
    let city: String
}

final class MockSession: RouterSession {
    var result: Result<(Data, URLResponse), Error>

    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }

    func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        return try result.get()
    }
}

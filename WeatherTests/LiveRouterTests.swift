//
//  LiveRouterTests.swift
//  WeatherTests
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation
import Testing
@testable import Weather

@Suite
struct LiveRouterTests {

    private let url: URL

    init() throws {
        self.url = try #require(try URL(string: "https://api.openweathermap.org"))
    }

    @Test("Successfully decode valid JSON response")
    func successfulResponse() async throws {
        let mockData = try JSONEncoder().encode(MockResponse(temp: 21.5, city: "London"))
        let response = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))

        let session = MockSession(result: .success((mockData, response)))
        let router = LiveRouter(session: session)

        let output = try await router.performRequest(MockRoute(queryParams: [:]))
        #expect(output == MockResponse(temp: 21.5, city: "London"))
    }

    @Test("Decoding error with invalid response format")
    func decodingError() async throws {
        let badJSON = try #require(
            #"{"unexpected": "format"}"#.data(using: .utf8)
        )
        let response = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))

        let session = MockSession(result: .success((badJSON, response)))
        let router = LiveRouter(session: session)

        do {
            _ = try await router.performRequest(MockRoute(queryParams: [:]))
            Issue.record("Expected decodingError to be thrown")
        } catch let RouterError.decodingError(underlyingError) {
            #expect(type(of: underlyingError) == DecodingError.self)
        } catch {
            Issue.record("Unexpected error occured.")
        }
    }

    @Test("Server error with 500 status code")
    func serverError() async throws {
        let mockData = try JSONEncoder().encode(MockResponse(temp: 0, city: ""))
        let response = try #require(HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil))

        let session = MockSession(result: .success((mockData, response)))
        let router = LiveRouter(session: session)

        do {
            _ = try await router.performRequest(MockRoute(queryParams: [:]))
            Issue.record("Expected serverError to be thrown")
        } catch let RouterError.serverError(errorCode) {
            #expect(errorCode == 500)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}


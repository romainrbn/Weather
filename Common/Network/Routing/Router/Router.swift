//
//  Router.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

private enum RouterConstants {
    static let retryDelay: TimeInterval = 2
    static let retryAttemptsCount = 1
}

protocol Router {
    var session: RouterSession { get }

    @discardableResult
    func performRequest<T: Route>(_ route: T) async throws -> T.OutputType
}

extension Router {
    func requestResponse<T: Route>(_ route: T) async throws -> T.OutputType {
        let (data, response) = try await performHTTPRequest(route)

        return try decode(route, data, urlResponse: response)
    }

    private func decode<T: Route>(
        _ route: T,
        _ data: Data,
        urlResponse: URLResponse
    ) throws -> T.OutputType {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw RouterError.unknown(underlyingError: URLError(.badServerResponse))
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw RouterError.serverError(errorCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.OutputType.self, from: data)
        } catch {
            throw RouterError.decodingError(underlyingError: error)
        }
    }

    private func createFailure<T: Route>(
        _ route: T,
        with errorCode: Int
    ) throws -> T.OutputType {
        throw RouterError.serverError(errorCode: errorCode)
    }

    private func performHTTPRequest<T: Route>(
        _ route: T
    ) async throws -> (Data, URLResponse) {
        var request: URLRequest!

        do {
            request = try route.toRequest()
        } catch let specificError as RouteRequestBuildError {
            throw RouterError.badRequest(underlyingError: specificError)
        } catch {
            throw RouterError.badRequest(underlyingError: .unknown(underlyingError: error))
        }

        do {
            return try await session.perform(request)
        }
    }
}

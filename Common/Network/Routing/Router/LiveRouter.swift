//
//  LiveRouter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct LiveRouter: Router {
    let session: RouterSession

    init(session: RouterSession = URLSession.shared) {
        self.session = session
    }

    func performRequest<T>(
        _ route: T
    ) async throws -> T.OutputType where T : Route {
        return try await requestResponse(route)
    }
}

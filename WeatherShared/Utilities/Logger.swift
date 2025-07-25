//
//  Log.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation
import OSLog

struct Log {
    static var logger: Logger {
        return Logger(subsystem: OSLog.subsystem, category: "Weather")
    }

    static func log(
        _ message: String
    ) {
        logger.log("\(message, privacy: .public)")
    }
}

extension OSLog {
    nonisolated(unsafe) public static var subsystem = Bundle.main.bundleIdentifier ?? "WeatherHomeAssignment"
}

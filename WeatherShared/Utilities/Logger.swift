//
//  Log.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation
import OSLog

/// A simple logger to avoid putting `print` statements when displaying a development alert.
///
/// This **won't** have an impact in this small app, but let's treat it like it's a production-ready app,
/// where `print` can be relatively expensive in I/O and slow down the app if called frequently.
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

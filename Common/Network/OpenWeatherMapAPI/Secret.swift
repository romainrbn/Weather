//
//  Secret.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation

struct Secret {
    static var apiKey: String {
        if let environmentKey = ProcessInfo.processInfo.environment["OPENWEATHERMAP_APIKEY"] {
            return environmentKey
        } else {
            fatalError("Please add your OpenWeatherMap API key in the environment values in Xcode, for the OPENWEATHERMAP_APIKEY key")
        }
    }
}

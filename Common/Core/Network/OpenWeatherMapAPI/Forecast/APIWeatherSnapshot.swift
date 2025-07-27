//
//  APIWeatherSnapshot.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct APIWeatherSnapshot: Decodable {
    let timestamp: TimeInterval
    let main: APIWeatherMainInfo
    let weather: [APIWeatherCondition]
    let clouds: APIWeatherClouds
    let wind: APIWeatherWind
    let visibility: Int
    let precipitationProbability: Double
    let system: APIWeatherSystemInfo
    let dateText: String

    enum CodingKeys: String, CodingKey {
        case timestamp = "dt"
        case main
        case weather
        case clouds
        case wind
        case visibility
        case precipitationProbability = "pop"
        case system = "sys"
        case dateText = "dt_txt"
    }
}

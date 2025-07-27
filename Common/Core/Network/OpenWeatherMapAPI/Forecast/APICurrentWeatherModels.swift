//
//  APICurrentWeatherModels.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct APICurrentWeather: Decodable {
    let status: Int
    let timestamp: Int
    let coordinates: APICurrentWeatherCoordinates
    let weather: [APIWeatherCondition]
    let mainInfo: APIWeatherMainInfo
    let system: APICurrentWeatherSystem
    let timezone: Int

    enum CodingKeys: String, CodingKey {
        case status = "cod"
        case coordinates = "coord"
        case weather
        case mainInfo = "main"
        case timestamp = "dt"
        case timezone
        case system = "sys"
    }
}

struct APICurrentWeatherCoordinates: Decodable {
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}

struct APICurrentWeatherSystem: Decodable {
    let sunrise: Int
    let sunset: Int
}

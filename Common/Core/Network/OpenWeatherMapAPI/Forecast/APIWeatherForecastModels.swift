//
//  APIWeatherForecastModels.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct APIWeatherForecast: Decodable {
    let status: String
    let list: [APIWeatherSnapshot]
    let city: APIWeatherCity

    enum CodingKeys: String, CodingKey {
        case status = "cod"
        case list
        case city
    }
}

struct APIWeatherMainInfo: Decodable {
    let temperature: Double
    let feelsLike: Double
    let minTemperature: Double
    let maxTemperature: Double
    let pressure: Int
    let seaLevel: Int
    let groundLevel: Int
    let humidity: Int
    let temperatureKf: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case minTemperature = "temp_min"
        case maxTemperature = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
        case humidity
        case temperatureKf = "temp_kf"
    }
}

struct APIWeatherCity: Decodable {
    let name: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

struct APIWeatherCondition: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct APIWeatherClouds: Decodable {
    let cloudiness: Int

    enum CodingKeys: String, CodingKey {
        case cloudiness = "all"
    }
}

struct APIWeatherWind: Decodable {
    let speed: Double
    let degree: Int
    let gust: Double?

    enum CodingKeys: String, CodingKey {
        case speed
        case degree = "deg"
        case gust
    }
}

struct APIWeatherSystemInfo: Decodable {
    let partOfDay: String

    enum CodingKeys: String, CodingKey {
        case partOfDay = "pod"
    }
}

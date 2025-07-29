//
//  ForecastViewDescriptor.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation

struct ForecastViewDescriptor {
    struct SymbolDescriptor {
        let systemSymbolName: String
        let colorRepresentation: ConditionSymbolColorRepresentation
    }

    struct DailyForecastDescriptor: Identifiable {
        let id = UUID()
        let associatedTime: String
        let conditions: String
        let temperature: String
        let feelsLikeTemperature: String?
        let minimumTemperature: String?
        let maximumTemperature: String?
        let symbol: SymbolDescriptor
    }

    struct HourlyForecastDescriptor: Identifiable {
        let id = UUID()
        let date: Date
        let formattedTime: String
        let temperature: String
        let feelsLikeTemperature: String?
        let symbol: SymbolDescriptor
    }

    let cityName: String
    let currentConditions: DailyForecastDescriptor
    let dailyForecast: [DailyForecastDescriptor]
    let hourlyForecastByDay: [DateComponents: [HourlyForecastDescriptor]]
}

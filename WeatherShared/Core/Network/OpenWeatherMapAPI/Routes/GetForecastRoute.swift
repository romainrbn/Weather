//
//  GetForecastRoute.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct GetForecastRoute: Route {
    typealias OutputType = APIWeatherForecast

    var additionalQueryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "lat", value: "47.38502545"),
            URLQueryItem(name: "lon", value: "-0.4719574443962181"),
            URLQueryItem(name: "appid", value: "4aa698cc2572f540f79280272d0461c6"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "fr"),
        ]
    }

    var path: String {
        "forecast"
    }
}

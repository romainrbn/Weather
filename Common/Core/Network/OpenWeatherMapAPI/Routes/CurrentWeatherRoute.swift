//
//  CurrentWeatherRoute.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct CurrentWeatherRoute: Route {
    typealias OutputType = APICurrentWeather

    private let inputParameters: [String: String]

    init(inputParameters: [String : String]) {
        self.inputParameters = inputParameters
    }

    var additionalQueryParameters: [URLQueryItem] {
        inputParameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
    }

    var path: String {
        "forecast"
    }
}

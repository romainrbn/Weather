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

    var queryParams: [String : String] {
        inputParameters
    }

    init(inputParameters: [String : String]) {
        self.inputParameters = inputParameters
    }

    var path: String {
        "weather"
    }
}

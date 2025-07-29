//
//  GetForecastRoute.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct GetForecastRoute: Route {
    typealias OutputType = APIWeatherForecast

    private let inputParameters: [String: String]

    init(inputParameters: [String : String]) {
        self.inputParameters = inputParameters
    }

    var queryParams: [String : String] {
        inputParameters
    }

    var path: String {
        "forecast"
    }
}

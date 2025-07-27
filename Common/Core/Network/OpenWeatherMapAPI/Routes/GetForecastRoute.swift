//
//  GetForecastRoute.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct GetForecastRoute: Route {
    typealias OutputType = APIWeatherForecast

    var queryParams: [String : String] = [
        "lat": "47.38502545",
        "lon": "-0.4719574443962181",
        "appid": "4aa698cc2572f540f79280272d0461c6",
        "units": "metric",
        "lang": "fr",
    ]

    var path: String {
        "forecast"
    }
}

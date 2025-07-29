//
//  Secret.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation

struct Secret {
    static let noApiKeyValue: String = "YOUR_API_KEY"

    static var apiKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherMapAPIKey") as? String,
           !key.isEmpty,
           key != noApiKeyValue
        {
            return key
        }

        Log.log(
        """
        Missing OpenWeatherMap API key!
        Please define the API key in the OPENWEATHERMAP_APIKEY User-Defined build setting.
        """
        )

        return Secret.noApiKeyValue
    }
}

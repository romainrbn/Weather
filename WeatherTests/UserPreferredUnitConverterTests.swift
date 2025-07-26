//
//  UserPreferredUnitConverterTests.swift
//  WeatherTests
//
//  Created by Romain Rabouan on 7/26/25.
//

import Testing
@testable import Weather

struct UserPreferredUnitConverterTests {

    @Test
    func celsiusToFahrenheitConversion() {
        let epsilon = 0.0001
        let converter = UserPreferredUnitConverter()
        let inputCelsius = 0.0
        let expectedFahrenheit = 32.0

        let result = converter.convertToFahrenheit(celciusValue: inputCelsius)

        #expect(abs(result - expectedFahrenheit) < epsilon)
    }

    @Test
    func formatCelsius() {
        let converter = UserPreferredUnitConverter()
        let result = converter.formatValue(celsiusTemperatureValue: 25, unit: .celsius)

        #expect(result.contains("25"))
        #expect(result.localizedCaseInsensitiveContains("c") || result.contains("°"))
    }

    @Test
    func formatFahrenheit() {
        let converter = UserPreferredUnitConverter()
        let result = converter.formatValue(celsiusTemperatureValue: 0, unit: .fahrenheit)

        #expect(result.contains("32"))
        #expect(result.localizedCaseInsensitiveContains("f") || result.contains("°"))
    }
}

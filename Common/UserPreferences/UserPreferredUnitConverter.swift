//
//  UserPreferredUnitConverter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

/// Using a class instead of a struct to allow a lazy formatter, since formatters are expensive to create and should only be initialized once.
final class UserPreferredUnitConverter {

    private lazy var formatter: MeasurementFormatter = createMeasurementFormatter()

    func convertToFahrenheit(celsiusValue: Double) -> Double {
        let celsiusMeasurement = Measurement(value: celsiusValue, unit: UnitTemperature.celsius)
        let fahrenheitMeasurement = celsiusMeasurement.converted(to: .fahrenheit)
        return fahrenheitMeasurement.value
    }

    func formatValue(celsiusTemperatureValue: Double, unit: UserPreferredTemperatureUnit) -> String {
        switch unit {
        case .celsius:
            let measurement = Measurement(value: celsiusTemperatureValue, unit: UnitTemperature.celsius)
            return formatter.string(from: measurement)
        case .fahrenheit:
            let convertedMeasurement = convertToFahrenheit(celsiusValue: celsiusTemperatureValue)
            let measurement = Measurement(value: convertedMeasurement, unit: UnitTemperature.fahrenheit)
            return formatter.string(from: measurement)
        case .systemDefault:
            if UserPreferredTemperatureUnit.defaultForCurrentLocale == .systemDefault {
                assertionFailure("Should not happen!")
                return "-"
            }
            return formatValue(
                celsiusTemperatureValue: celsiusTemperatureValue,
                unit: UserPreferredTemperatureUnit.defaultForCurrentLocale
            )
        }
    }

    private func createMeasurementFormatter() -> MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        formatter.locale = .current
        formatter.numberFormatter.maximumFractionDigits = 0

        return formatter
    }
}

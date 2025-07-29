//
//  ForecastAggregator.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

private enum Constants {
    static let numberOfDays: Int = 5
}

/// A small helper to create a global daily weather condition, as the free tier of OpenWeatherMapAPI does not provide
/// conditions for days, only conditions every 3 hours over 5 days.
///
/// We use the "worst" or most important condition for the day to determine the global condition.
/// For example, if a day has both thunderstorm and cloudy conditions,
/// this is more valuable to display the thunderstorm to the user.
///
/// This might not be exactly how weather agencies compute conditions!
private struct DailyAccumulator {
    private var sumTemperature: Double = 0
    private var count: Int = 0
    private(set) var worstCondition: WeatherCondition = .unknown
    private(set) var worstConditionName: String? = nil

    private var minimumTemperature: Double?
    private var maximumTemperature: Double?

    var report: WeatherReport {
        let averageTemperature = count > 0 ? Int((sumTemperature / Double(count)).rounded()) : 0
        return WeatherReport(
            celsiusTemperature: averageTemperature,
            feelsLikeTemperature: nil,
            condition: worstCondition,
            temperatureRanges: temperatureRanges(minimum: minimumTemperature, maximum: maximumTemperature),
            conditionName: worstConditionName ?? "-"
        )
    }

    mutating func add(snapshot: APIWeatherSnapshot) {
        guard let mainWeather = snapshot.weather.first else {
            Log.log("Tried to map a snapshot without a weather conditionID.")
            return
        }
        sumTemperature += snapshot.main.temperature
        minimumTemperature = snapshot.main.minTemperature
        maximumTemperature = snapshot.main.maxTemperature

        count += 1

        let condition = APIWeatherConditionMapping.map(weatherID: mainWeather.id)
        if condition.priority > worstCondition.priority {
            worstCondition = condition
            worstConditionName = mainWeather.description
        }
    }

    private func temperatureRanges(minimum: Double?, maximum: Double?) -> CurrentDayTemperatureRange? {
        guard let minimum, let maximum else { return nil }

        return CurrentDayTemperatureRange(
            minimumCelsiusTemperature: Int(minimum.rounded()),
            maximumCelsiusTemperature: Int(maximum.rounded())
        )
    }
}

struct ForecastAggregator {
    static func makeHourlyAndDaily(
        from snapshots: [APIWeatherSnapshot],
        dayCount: Int = Constants.numberOfDays,
        calendar: Calendar = .current
    ) -> (hourly: [HourlyForecast], daily: [DailyForecast]) {
        guard !snapshots.isEmpty else {
            return (hourly: [], daily: [])
        }

        let hourlyBuckets = buildHourlyForecasts(from: snapshots)
        let dailyBuckets  = accumulateDailyBuckets(from: snapshots, calendar: calendar)
        let dailyForecasts = buildDailyForecasts(
            from: dailyBuckets,
            dayCount: dayCount
        )

        return (hourly: hourlyBuckets, daily: dailyForecasts)
    }

    private static func buildHourlyForecasts(
        from snapshots: [APIWeatherSnapshot]
    ) -> [HourlyForecast] {
        return snapshots.compactMap { snapshot in
            guard let mainWeather = snapshot.weather.first else {
                return nil
            }

            let time = Date(timeIntervalSince1970: snapshot.timestamp)
            let tempC = Int(snapshot.main.temperature.rounded())
            let condition = APIWeatherConditionMapping.map(weatherID: mainWeather.id)
            let report = WeatherReport(
                celsiusTemperature: tempC,
                feelsLikeTemperature: nil,
                condition: condition,
                temperatureRanges: nil,
                conditionName: mainWeather.description
            )

            return HourlyForecast(time: time, report: report)
        }
    }

    private static func accumulateDailyBuckets(
        from snapshots: [APIWeatherSnapshot],
        calendar: Calendar
    ) -> [Date: DailyAccumulator] {
        var buckets: [Date: DailyAccumulator] = [:]

        for snapshot in snapshots {
            let timestamp = Date(timeIntervalSince1970: snapshot.timestamp)
            let dayKey = calendar.startOfDay(for: timestamp)

            buckets[dayKey, default: DailyAccumulator()]
                .add(snapshot: snapshot)
        }

        return buckets
    }

    private static func buildDailyForecasts(
        from buckets: [Date: DailyAccumulator],
        dayCount: Int
    ) -> [DailyForecast] {
        return buckets.keys
            .sorted()
            .prefix(dayCount)
            .compactMap { day in
                guard let bucket = buckets[day] else { return nil }
                return DailyForecast(date: day, report: bucket.report)
            }
    }
}

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

    var report: WeatherReport {
        let averageTemperature = count > 0 ? Int((sumTemperature / Double(count)).rounded()) : 0
        return .init(celsiusTemperature: averageTemperature, condition: worstCondition)
    }

    mutating func add(snapshot: APIWeatherSnapshot) {
        guard let weatherID = snapshot.weather.first?.id else {
            Log.log("Tried to map a snapshot without a weather conditionID.")
            return
        }
        sumTemperature += snapshot.main.temperature
        count += 1

        let condition = APIWeatherConditionMapping.map(weatherID: weatherID)
        if condition.priority > worstCondition.priority {
            worstCondition = condition
        }
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
            guard let weatherID = snapshot.weather.first?.id else {
                return nil
            }

            let time = Date(timeIntervalSince1970: snapshot.timestamp)
            let tempC = Int(snapshot.main.temperature.rounded())
            let condition = APIWeatherConditionMapping.map(weatherID: weatherID)
            let report = WeatherReport(celsiusTemperature: tempC, condition: condition)

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

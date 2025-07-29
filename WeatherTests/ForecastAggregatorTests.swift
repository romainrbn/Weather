//
//  ForecastAggregatorTests.swift
//  WeatherTests
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation
import Testing
@testable import Weather

private enum Constants {
    static let hourTimeInterval: TimeInterval = 3600
    static let dayTimeInterval: TimeInterval = 86400
}

@Suite
struct ForecastAggregatorTests {

    @Test("Produces correct hourly and daily forecast with one snapshot")
    func testSingleSnapshot() {
        let temperature = 21.5
        let timestamp = Date().timeIntervalSince1970
        let weatherID = 800 // clear

        let snapshot = createWeatherSnapshot(timestamp: timestamp, temperature: temperature, conditionID: weatherID)

        let result = ForecastAggregator.makeHourlyAndDaily(from: [snapshot])

        #expect(result.hourly.count == 1)
        #expect(result.daily.count == 1)

        let expectedReport = WeatherReport(
            celsiusTemperature: Int(temperature.rounded()),
            condition: .clear,
            conditionName: "Clear"
        )

        #expect(result.hourly[0].report == expectedReport)
        #expect(result.daily[0].report == expectedReport)
    }

    @Test("DailyAccumulator picks worst condition based on priority")
    func testWorstConditionPriority() {
        let baseTemp1 = 10.0
        let baseTemp2 = 20.0
        let baseTime = Date().timeIntervalSince1970

        let cloudID = 801 // .clouds
        let thunderstormID = 200 // .thunderstorm

        let snapshots = [
            createWeatherSnapshot(timestamp: baseTime, temperature: baseTemp1, conditionID: cloudID),
            createWeatherSnapshot(timestamp: baseTime + Constants.hourTimeInterval, temperature: baseTemp2, conditionID: thunderstormID)
        ]

        let result = ForecastAggregator.makeHourlyAndDaily(from: snapshots)
        #expect(result.daily.count == 1)

        let expectedTemp = Int(((baseTemp1 + baseTemp2) / 2.0).rounded())
        let expectedReport = WeatherReport(
            celsiusTemperature: expectedTemp,
            condition: .thunderstorm,
            conditionName: "Storms"
        )

        #expect(result.daily[0].report == expectedReport)
    }

    @Test("Skips snapshots without weatherID")
    func testIgnoresSnapshotsWithoutWeatherID() {
        let temperature = 18.0
        let timestamp = Date().timeIntervalSince1970
        let clearID = 800

        let valid = createWeatherSnapshot(timestamp: timestamp, temperature: temperature, conditionID: clearID)
        let invalid = createWeatherSnapshot(timestamp: timestamp + Constants.hourTimeInterval, temperature: temperature + 2, conditionID: nil)

        let result = ForecastAggregator.makeHourlyAndDaily(from: [valid, invalid])

        #expect(result.hourly.count == 1)
        #expect(result.daily.count == 1)
    }

    @Test("Limits number of daily forecasts to dayCount")
    func testLimitsToDayCount() {
        let dayCountLimit = 5
        let snapshotCount = 10
        let baseTime = Date().timeIntervalSince1970
        let temp1 = 10.0
        let temp2 = 20.0
        let clearID = 800

        let snapshots = (0..<snapshotCount).flatMap { dayOffset -> [APIWeatherSnapshot] in
            let timestamp = baseTime + (Double(dayOffset) * Constants.dayTimeInterval)
            return [
                createWeatherSnapshot(timestamp: timestamp, temperature: temp1, conditionID: clearID),
                createWeatherSnapshot(timestamp: timestamp + Constants.hourTimeInterval, temperature: temp2, conditionID: clearID)
            ]
        }

        let result = ForecastAggregator.makeHourlyAndDaily(from: snapshots, dayCount: dayCountLimit)

        #expect(result.daily.count == dayCountLimit)
    }

    private func createWeatherSnapshot(timestamp: TimeInterval, temperature: Double, conditionID: Int?) -> APIWeatherSnapshot {
        APIWeatherSnapshot(
            timestamp: timestamp,
            main: .init(
                temperature: temperature,
                feelsLike: 0,
                minTemperature: 0,
                maxTemperature: 0,
                pressure: 0,
                seaLevel: 0,
                groundLevel: 0,
                humidity: 0
            ),
            weather: createWeatherCondition(conditionID: conditionID),
            clouds: .init(cloudiness: 0),
            wind: .init(speed: 30, degree: 30, gust: nil),
            visibility: 10000,
            precipitationProbability: 90,
            system: .init(partOfDay: "day"),
            dateText: ""
        )
    }

    private func createWeatherCondition(conditionID: Int?) -> [APIWeatherCondition] {
        guard let conditionID else { return [] }

        return [
            APIWeatherCondition(
                id: conditionID,
                main: "",
                description: "",
                icon: ""
            )
        ]
    }
}


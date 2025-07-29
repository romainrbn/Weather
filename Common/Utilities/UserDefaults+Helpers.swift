//
//  UserDefaults+Helpers.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation

@propertyWrapper
public struct UserDefault<T: Equatable> {
    public let key: String
    public let defaultValue: T

    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

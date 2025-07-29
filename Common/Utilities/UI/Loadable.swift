//
//  Loadable.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation

public enum Loadable<Value> {
    case loading
    case value(Value)
    case error(Error)
}

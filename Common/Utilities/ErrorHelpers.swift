//
//  ErrorHelpers.swift
//  Weather
//
//  Created by Romain Rabouan on 7/28/25.
//

import Foundation

extension Error {
    var message: String {
        let message: String

        if let localizedError = self as? LocalizedError {
            message = localizedError.errorDescription ?? localizedError.localizedDescription
        } else {
            message = localizedDescription
        }

        if message.isEmpty == false {
            return message
        }

        return "An unknown error occured. Please try again later."
    }
}

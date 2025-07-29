//
//  MKPlacemark+Helpers.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import MapKit

extension MKPlacemark {
    /// We need to identify a place uniquely.
    /// For example, if the user is in London and already has London as a favourite,
    /// we do not want to display the same item twice.
    ///
    /// Additionally, the coordinates returned in the placemark of MKLocalSearch
    /// will not be the same as the one returned by the CLLocationManager, so we need to differentiate them.
    var identifier: String? {
        guard
            let locality,
            let administrativeArea,
            let isoCountryCode
        else {
            return nil
        }

        return "\(locality)_\(administrativeArea)_\(isoCountryCode)"
    }
}

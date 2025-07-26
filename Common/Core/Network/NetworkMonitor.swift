//
//  NetworkMonitor.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private(set) var isConnected: Bool = false {
        didSet {
            guard isConnected != oldValue else { return }

            NotificationCenter.default.post(
                name: isConnected ? UIApplication.applicationDidConnectToNetwork : UIApplication.applicationDidDisconnectFromNetwork,
                object: nil
            )
        }
    }

    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}

extension UIApplication {
    static var applicationDidConnectToNetwork: Notification.Name {
        Notification.Name("applicationDidConnectToNetwork")
    }

    static var applicationDidDisconnectFromNetwork: Notification.Name {
        Notification.Name("applicationDidDisconnectFromNetwork")
    }
}

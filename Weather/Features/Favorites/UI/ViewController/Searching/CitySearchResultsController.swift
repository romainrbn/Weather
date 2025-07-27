//
//  CitySearchResultsController.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit
import MapKit

private enum Constants {
    static let cellReuseIdentifier: String = "Cell"
}

protocol CitySearchResultsControllerDelegate: AnyObject {
    func didSelectCity(_ city: MKMapItem)
    func retryQuery()
}

final class CitySearchResultsController: UITableViewController {

    var results: [MKMapItem] = [] {
        didSet {
            guard results != oldValue else { return }
            errorView.isHidden = true
            tableView.reloadData()
        }
    }

    var error: WeatherLocalCitySearchServiceError? = nil {
        didSet {
            errorView.isHidden = error == nil
            if let error {
                errorView.setError(error)
            }
        }
    }

    private lazy var errorView = createErrorView()

    weak var delegate: CitySearchResultsControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
        tableView.backgroundView = errorView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath)

        var config = UIListContentConfiguration.valueCell()
        config.text = item.placemark.locality ?? item.name
        config.secondaryText = [item.placemark.administrativeArea, item.placemark.country]
            .compactMap { $0 }
            .joined(separator: ", ")
        cell.contentConfiguration = config

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCity(results[indexPath.row])
    }

    private func createErrorView() -> CitySearchErrorView {
        let errorView = CitySearchErrorView { [weak self] in
            self?.delegate?.retryQuery()
        }
        errorView.isHidden = true
        return errorView
    }
}

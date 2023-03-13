//
//  ViewController.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/10/23.
//

import UIKit

class MainViewController: UIViewController {

    private enum Constants {
        static let navTitle = "Weather App"
        static let duration = 0.5
    }
    
    var searchController: UISearchController?
    let viewModel = ViewModel(service: WeatherService())
    
    // MARK: - Outlets
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.weatherDataFetchedHandler = { [weak self] in
            self?.populateUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchWeatherForCurrentLocation()
    }

    // MARK: -
    private func setup() {
        title = Constants.navTitle
        let resultsVc = ResultsViewController(viewModel: viewModel)
        let controller = UISearchController(searchResultsController: resultsVc)
        navigationItem.searchController = controller
        controller.searchResultsUpdater = self
        self.searchController = controller
        mainStack.alpha = 0.0
    }
    
    private func populateUI() {
        if let icon = viewModel.getIconName() {
            viewModel.getIconImage(name: icon) { [weak self] data in
                if let img = data {
                    self?.iconImageView.image = img
                }
            }
        }
        nameTitleLabel.text = viewModel.getCityName()
        dateLabel.text = viewModel.getDateString()
        temperatureLabel.text = viewModel.getTempString()
        descriptionLabel.text = viewModel.getDescription()
        humidityLabel.text = viewModel.getHumidity()
        windLabel.text = viewModel.getWindSpeed()
        UIView.animate(withDuration: Constants.duration) {
            self.mainStack.alpha = 1.0
        }
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        viewModel.checkCriteriaAndSearch(text)
    }
}

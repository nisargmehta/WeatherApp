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
    }
    
    var searchController: UISearchController?
    let viewModel = ViewModel(service: WeatherService())
    
    // outlets
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
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
        print("populate UI")
        print(viewModel.weatherData)
        UIView.animate(withDuration: 0.5) {
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

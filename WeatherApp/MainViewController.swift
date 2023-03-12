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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.weatherDataFetchedHandler = { [weak self] in
            self?.populateUI()
        }
    }

    private func setup() {
        title = Constants.navTitle
        let resultsVc = ResultsViewController(viewModel: viewModel)
        let controller = UISearchController(searchResultsController: resultsVc)
        navigationItem.searchController = controller
        controller.searchResultsUpdater = self
        self.searchController = controller
    }
    
    private func populateUI() {
        print("populate UI")
        print(viewModel.weatherData)
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        viewModel.checkCriteriaAndSearch(text)
    }
}

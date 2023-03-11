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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        title = Constants.navTitle
        let resultsVc = ResultsViewController()
        let controller = UISearchController(searchResultsController: resultsVc)
        navigationItem.searchController = controller
        controller.searchResultsUpdater = self
        self.searchController = controller
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text ?? "")
    }
}

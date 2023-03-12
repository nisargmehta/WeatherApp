//
//  ResultsViewController.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/10/23.
//

import UIKit

class ResultsViewController: UITableViewController {

    private enum Constants {
        static let cellReuseId = "resultCell"
    }
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        
        viewModel.citiesFetchedHandler = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath)

        let city = viewModel.cities[indexPath.row]
        var title = "\(city.name), \(city.country)"
        if let st = city.state {
            title = "\(city.name), \(st), \(city.country)"
        }
        // Configure the cell...
        var content = cell.defaultContentConfiguration()
        content.text = title
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // pass selection to view model
        let city = viewModel.cities[indexPath.row]
        viewModel.selectedCity = city
        if let search = self.parent as? UISearchController {
            search.isActive = false
        } else {
            // record error
        }
    }
}

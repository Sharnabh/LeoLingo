//
//  FilterViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 24/01/25.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilterOption(_ option: String)
}

class FilterViewController: UIViewController {

    @IBOutlet var filterTableView: UITableView!
    var option: String?
    var previouslySelectedIndexPath: IndexPath?
    
    var delegate : FilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
    
    func configureTableView() {
        filterTableView.delegate = self
        filterTableView.dataSource = self
        
        filterTableView.reloadData()
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FIlterOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filterTableView.dequeueReusableCell(withIdentifier: "FilterOption", for: indexPath)
        let optionValue = FIlterOptions.allCases[indexPath.row].rawValue
        cell.textLabel?.text = optionValue
        
        // Clear previous checkmarks to avoid multiple selections
        cell.accessoryType = .none

        // Check if the current option is selected, apply checkmark accordingly
        if option == optionValue {
            cell.accessoryType = .checkmark
            previouslySelectedIndexPath = indexPath
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previouslySelectedIndexPath = previouslySelectedIndexPath {
            if let previousCell = tableView.cellForRow(at: previouslySelectedIndexPath) {
                // Deselect the previously selected cell
                previousCell.accessoryType = .none
            }
        }

        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        // Select the new cell
        cell.accessoryType = .checkmark
        previouslySelectedIndexPath = indexPath

        // Store the selected option
        let selectedOption = FIlterOptions.allCases[indexPath.row].rawValue
        option = selectedOption
        
        self.delegate?.didSelectFilterOption(selectedOption)
        self.dismiss(animated: true)
    }
}

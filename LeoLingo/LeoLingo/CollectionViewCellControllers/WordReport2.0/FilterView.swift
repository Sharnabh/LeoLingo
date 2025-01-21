//
//  FilterView.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit

class FilterView: UIView {

    @IBOutlet var filterTableView: UITableView!
    var filterOptions: [String] = ["All", "Accurate", "Inaccurate"]
    var option: String?
    var previouslySelectedIndexPath: IndexPath?
    
    
    
    func configureTableView() {
        filterTableView.delegate = self
        filterTableView.dataSource = self
        
        filterTableView.reloadData()
    }
    
}

extension FilterView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filterTableView.dequeueReusableCell(withIdentifier: "FilterOption", for: indexPath)
        cell.textLabel?.text = filterOptions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previouslySelectedIndexPath = previouslySelectedIndexPath {
            if let previousCell = tableView.cellForRow(at: previouslySelectedIndexPath) {
                // Reset the color of the previously selected item
                previousCell.accessoryType = .none
            }
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        cell.accessoryType = .checkmark
    }
    
}

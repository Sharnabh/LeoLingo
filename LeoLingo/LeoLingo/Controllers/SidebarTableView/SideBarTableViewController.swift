//
//  SideBarTableViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit

class SideBarTableViewController: UITableViewController{
    
    let items: [[String]] = [["Word Report"], ["Account", "Notifications"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return items[0].count
        case 1:
            return items[1].count
        default:
            break
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Progress Path"
        case 1:
            return "Settings"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SidebarCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = items[indexPath.section][indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ParentMode", bundle: nil)
        var secondaryVC: UIViewController?
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            secondaryVC = storyboard.instantiateViewController(withIdentifier: "WordReportMain")
        case (1, 0):
            secondaryVC = storyboard.instantiateViewController(withIdentifier: "Account")
        case (1, 1):
            secondaryVC = storyboard.instantiateViewController(withIdentifier: "Notifications")
        default:
            break
        }
        
        if let secondaryVC = secondaryVC {
            let navController = UINavigationController(rootViewController: secondaryVC)
            splitViewController?.setViewController(secondaryVC, for: .secondary)
        }
    }

}

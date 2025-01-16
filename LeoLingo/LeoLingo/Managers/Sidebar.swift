//
//  Sidebar.swift
//  LeoLingo
//
//  Created by Sharnabh on 16/01/25.
//

import Foundation

func showSidebarVC() {
    let splitVC = UISplitViewController(style: .doubleColumn)

    let sidebarVC = SidebarViewController()  // Sidebar menu
    let detailVC = DetailViewController()    // Default detail content
    
    splitVC.setViewController(sidebarVC, for: .primary)
    splitVC.setViewController(detailVC, for: .secondary)
    
    splitVC.modalPresentationStyle = .fullScreen  // Makes it replace the current screen
    present(splitVC, animated: true, completion: nil)
}

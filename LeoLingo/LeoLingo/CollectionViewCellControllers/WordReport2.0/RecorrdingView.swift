//
//  RecorrdingView.swift
//  LeoLingo
//
//  Created by Sharnabh on 20/01/25.
//

import UIKit

class RecorrdingView: UIView {

    @IBOutlet var recordingTableView: UITableView!
    var recordCount: Int = 0
    var record: Record?
    var currentlyPlayingIndex: IndexPath?
    var isEnabled = true
    
    
    func configureTableData(with record: Record?, isEnabled: Bool) {
        self.record = record  // Corrected assignment
        self.isEnabled = isEnabled
        
        guard let record = record else {
            recordCount = 0
            recordingTableView.reloadData()
            return
        }
        
        recordCount = record.recording.count
        recordingTableView.delegate = self
        recordingTableView.dataSource = self
        recordingTableView.reloadData()

    }
}

extension RecorrdingView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEnabled ? recordCount : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recordingTableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! RecorrdingTableViewCell
        guard let record = record else { return  cell}
        cell.configureTitle(text: String(indexPath.row + 1))
        
        cell.playAction = { [weak self] in
            self?.handlePlayAction(for: indexPath)
        }

        return cell
    }
    
    func handlePlayAction(for indexPath: IndexPath) {
            // Check if a row is already playing
            if currentlyPlayingIndex == indexPath {
                print("Stopping recording \(indexPath.row)")
                currentlyPlayingIndex = nil
            } else {
                print("Playing recording \(indexPath.row)")
                currentlyPlayingIndex = indexPath
            }
            
            // Refresh table to update button titles
            recordingTableView.reloadData()
        }
}

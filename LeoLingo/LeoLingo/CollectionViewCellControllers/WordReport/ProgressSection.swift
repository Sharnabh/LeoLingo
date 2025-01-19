//
//  ProgressSection.swift
//  LeoLingo
//
//  Created by Sharnabh on 18/01/25.
//

import UIKit

class ProgressSection: UIView {

    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var avgAccuracyLabel: UILabel!
    @IBOutlet var graph: ProgressGraphView!
    @IBOutlet var recordingSegment: UISegmentedControl!
    
    func configureView(word: Word) {
        wordLabel.text = word.wordTitle
        avgAccuracyLabel.text = "\(word.avgAccuracy)"
        guard let records = word.record,
              word.record != nil else {
            recordingSegment.isEnabled = false
            graph.updateChartData(accuracyData: [0])
            return
        }
        
        graph.updateChartData(accuracyData: records.accuracy)
        
        recordingSegment.isEnabled = true
        for index in 0..<recordingSegment.numberOfSegments {
            let isEnabled = index < records.attempts
            recordingSegment.setEnabled(isEnabled, forSegmentAt: index)
        }
    }
    
}


//
//  ProgressGraphView.swift
//  LeoLingo
//
//  Created by Sharnabh on 18/01/25.
//

import UIKit
import Charts
import DGCharts

class ProgressGraphView: UIView {
    
    private var lineChartView: LineChartView!
    
    // Sample data (replace this with your actual accuracy collection)
    var accuracyCollection: [Double] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLineChart()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLineChart()
    }
    
    func updateChartData(accuracyData: [Double]) {
          // Update accuracy collection with new data
          accuracyCollection = accuracyData
          setData()  // Re-apply the data to update the chart
      }
    
    private func setupLineChart() {
        // Initialize the line chart view
        lineChartView = LineChartView()
        lineChartView.frame = self.bounds
        lineChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the line chart to the view
        self.addSubview(lineChartView)
        
        // Set up chart properties (optional)
        lineChartView.chartDescription.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true
        lineChartView.legend.enabled = true
        
        // Set the data
        setData()
    }
    
    private func setData() {
        // Convert the accuracy values into chart entries
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<accuracyCollection.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: accuracyCollection[i])
            dataEntries.append(dataEntry)
        }
        
        // Create a LineChartDataSet with the entries
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Accuracy")
        chartDataSet.colors = [NSUIColor.blue] // Set the line color
        chartDataSet.valueColors = [NSUIColor.black] // Set the value text color
        chartDataSet.valueFont = UIFont.systemFont(ofSize: 12)
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.circleRadius = 4.0
        chartDataSet.circleColors = [NSUIColor.red]
        
        // Create the LineChartData object with the dataSet
        let chartData = LineChartData(dataSet: chartDataSet)
        
        // Set the data for the chart
        lineChartView.data = chartData
    }
    
}

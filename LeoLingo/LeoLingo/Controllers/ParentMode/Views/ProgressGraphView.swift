////
////  ProgressGraphView.swift
////  LeoLingo
////
////  Created by Sharnabh on 18/01/25.
////
//
//import UIKit
//import Charts
//import DGCharts
//
//class ProgressGraphView: UIView {
//    
//    private var lineChartView: LineChartView!
//    
//    var accuracyCollection: [Double] = []
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLineChart()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupLineChart()
//    }
//    
//    func updateChartData(accuracyData: [Double]) {
//        accuracyCollection = accuracyData
//        setData()
//    }
//    
//    private func setupLineChart() {
//        lineChartView = LineChartView()
//        lineChartView.frame = self.bounds
//        lineChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.addSubview(lineChartView)
//        
//        lineChartView.backgroundColor = .clear
//        
//        // Chart configuration
//        lineChartView.chartDescription.enabled = false
//        lineChartView.dragEnabled = true
//        lineChartView.setScaleEnabled(false)  // Disable scaling
//        lineChartView.pinchZoomEnabled = false
//        lineChartView.legend.enabled = false // No legend
//
//        // X-Axis configuration
//        let xAxis = lineChartView.xAxis
//        xAxis.labelPosition = .bottom  // X-axis at bottom
//        xAxis.drawGridLinesEnabled = false // No vertical lines
//        xAxis.axisMinimum = 0
//        xAxis.axisMaximum = 5
//        xAxis.granularity = 1 // Force x-axis to show only whole numbers (0, 1, 2, 3, 4, 5)
//
//        // Y-Axis configuration
//        let leftAxis = lineChartView.leftAxis
//        leftAxis.axisMinimum = 0
//        leftAxis.axisMaximum = 100
//        leftAxis.drawGridLinesEnabled = true // Only horizontal lines
//        leftAxis.gridLineDashLengths = [5, 5] // Dashed horizontal lines
//
//        // Disable right Y-axis
//        lineChartView.rightAxis.enabled = false
//        
//        setData()
//    }
//    
//    private func setData() {
//        var dataEntries: [ChartDataEntry] = []
//        for i in 0..<accuracyCollection.count {
//            let dataEntry = ChartDataEntry(x: Double(i+1), y: accuracyCollection[i])
//            dataEntries.append(dataEntry)
//        }
//        
//        let chartDataSet = LineChartDataSet(entries: dataEntries)
//        chartDataSet.colors = [UIColor(red: 171/255, green: 87/255, blue: 174/255, alpha: 1)]
//        chartDataSet.lineWidth = 4.0
//        chartDataSet.drawCirclesEnabled = false // No circles on points
//        chartDataSet.drawValuesEnabled = false // No values on points
//        
//        let chartData = LineChartData(dataSet: chartDataSet)
//        lineChartView.data = chartData
//    }
//}

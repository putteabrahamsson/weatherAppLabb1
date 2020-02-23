//
//  CompareViewController.swift
//  weatherAppLabb1
//
//  Created by Putte on 2020-02-19.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit
import Charts

class CompareViewController: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var city1: UITextField!
    @IBOutlet weak var city2: UITextField!
    @IBOutlet weak var compareButton: UIButton!
    
    //Arrays
    var cities: [String] = []
    var tempValues:[Double] = []
    var dataArray:[ResponseData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set font size and text for "no available data"
        barChart.noDataFont = barChart.noDataFont.withSize(25)
        barChart.noDataText = "Ingen data hittades!"
        
        //Delegate textfields for resignFirstResponder
        city1.delegate = self
        city2.delegate = self
    }
    
    //Sets the corner radius of a button
    override func viewDidAppear(_ animated: Bool) {
        compareButton.layer.cornerRadius = 5
    }
    
    //Setting the Chart bar
    func setChart(dataPoints: [String], values: [Double]) {
        let celcius = "\u{00B0}c"
        
        //Fit the bars on chart
        barChart.fitBars = true
        
        //Set minimum and maximum chart values.
        barChart.leftAxis.axisMaximum = 50.0
        barChart.leftAxis.axisMinimum = -30.0
        barChart.rightAxis.axisMaximum = 50.0
        barChart.rightAxis.axisMinimum = -30.0
        
        //Align labels in the bottom
        barChart.xAxis.labelPosition = .bottom
        
        //Set a black line at 0 celcius
        let limitLine = ChartLimitLine(limit: 0.0, label: "0" + celcius)
        limitLine.lineColor = UIColor.black
        barChart.rightAxis.addLimitLine(limitLine)
        
        //Use labels as x-axis.
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:cities)
        barChart.xAxis.granularity = 1
        
        //Append the data to the chart
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count
        {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        //Cities to be compared
        let city = BarChartDataSet(entries: dataEntries, label: "Cities")
        
        //Sets color of the "cities" icon
        city.colors = [UIColor.blue]
        
        //Set the chart.
        let chartData = BarChartData(dataSet: city)
        self.barChart.data = chartData
    }
    
    //Button to compare temperature.
    @IBAction func compareTemperature(_ sender: Any) {
        //Lock components on click
        city1.isEnabled = false
        city2.isEnabled = false
        compareButton.isEnabled = false
        
        //Append cities to array
        cities.append(city1.text!)
        cities.append(city2.text!)
        
        //Hide keyboard on button click.
        city1.resignFirstResponder()
        city2.resignFirstResponder()
        
        //Loop through cities and add to chart.
        for index in cities{
            //Creating the URL
            let mainUrl = "http://api.openweathermap.org/data/2.5/weather?q="
            let city = index
            let endUrl = "&appid=9e73e77789b74d085856e30d5dda6285&units=metric&lang=se"
            let fullString = mainUrl+city+endUrl
            
            //Converting to non-american letters
            let urlString = fullString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            //Downloading data from JSON
            let data = JsonData.init()
            data.downloadJsonData(urlString: urlString!) { (responseArray) in
                print("Completed download JSON data")
                self.dataArray.append(contentsOf: responseArray)
                
                //Append temperature to tempValues
                if self.dataArray.count == 2{
                    self.tempValues.append(self.dataArray[0].main.temp)
                    self.tempValues.append(self.dataArray[1].main.temp)
                    
                    //Create the chart with preset values.
                    self.setChart(dataPoints: self.cities, values: self.tempValues)
                }
            }
            
        }
    }
}

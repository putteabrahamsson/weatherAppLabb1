//
//  DetailsViewController.swift
//  weatherAppLabb1
//
//  Created by Putte on 2020-02-19.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    //Strings for holding api data
    var location: String!
    var weather: String!
    var temperature: String!
    var feelsLike: String!
    var humidity: String!
    var weatherImage: String!
    
    //Array for holding the data
    var dataArray:[ResponseData] = []
    
    //IndexPath
    var indexPath:IndexPath!
    
    //Percentage and celcius
    let percent = "%"
    let celcius = "\u{00B0}c"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveData()
        
        //Datasource and Delegate
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //Retrieving data from array API
    func retrieveData(){
        location = dataArray[indexPath.row].name
        weather = dataArray[indexPath.row].weather[0].description
        temperature = String(format:"%.1f", dataArray[indexPath.row].main.temp)
        feelsLike = String(format:"%.1f", dataArray[indexPath.row].main.feels_like)
        humidity = String(dataArray[indexPath.row].main.humidity)
        
        let imgUrlString = "http://openweathermap.org/img/wn/"
        let weatherImg = dataArray[indexPath.row].weather[0].icon
        let imgUrlStringEnd = "@2x.png"
        
        weather = weather.capitalized
        weatherImage = imgUrlString + weatherImg + imgUrlStringEnd
        navTitle.title = location
    }
    
    //Tableview properties
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 //Should only display one row.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailsTableViewCell
        
        cell.weatherImage.downloaded(from: weatherImage)
        cell.temperature.text = temperature + celcius
        cell.feelsLike.text = feelsLike + celcius
        cell.weather.text = weather
        cell.humidity.text = humidity + percent
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 374
    }
}

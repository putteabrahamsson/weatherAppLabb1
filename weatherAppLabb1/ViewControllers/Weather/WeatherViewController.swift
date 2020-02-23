//
//  WeatherViewController.swift
//  weatherAppLabb1
//
//  Created by Putte on 2020-02-18.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //Temporarly string
    var urlString: String!
    
    //Arrays
    var dataArray:[ResponseData] = []
    var favArray:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate and Datasource
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //When the view did appear
    override func viewDidAppear(_ animated: Bool) {
        searchButton.layer.cornerRadius = 5
    }
    
    //Tableview properties
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Creating the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        
        //Retrieve data from array.
        let location = dataArray[indexPath.row].name
        let humidity = String(dataArray[indexPath.row].main.humidity)
        var weather = String(dataArray[indexPath.row].weather[0].description)
        
        //Creating URL for weather icon.
        let imgUrlString = "http://openweathermap.org/img/wn/"
        let weatherImg = dataArray[indexPath.row].weather[0].icon
        let imgUrlStringEnd = "@2x.png"
        let fullUrlString = imgUrlString + weatherImg + imgUrlStringEnd
        
        //Capitalizing first character
        weather = weather.capitalized
        
        //Easy calculation for using clothes
        let getTemp = dataArray[indexPath.row].main.temp
        
        if getTemp <= 10{
            cell.clothesInfo.text = "Använd varma kläder!"
        }
        else if getTemp > 10 && getTemp <= 15{
            cell.clothesInfo.text = "Bör använda en varm jacka!"
        }
        else if getTemp > 15 && getTemp < 20{
            cell.clothesInfo.text = "Använd en tjocktröja!"
        }
        else{
            cell.clothesInfo.text = "Det är varmt, shorts och t-shirt?"
        }
        
        //Round temperature to one decimal
        let temperature = String(format:"%.1f", getTemp)
        let feelTemperature = String(format:"%.1f", dataArray[indexPath.row].main.feels_like)
        
        //Extra text for strings
        let celcius = "\u{00B0}c"
        let percent = "%"
        
        //Adding text to tableView.
        cell.location.text = location
        cell.temperature.text = temperature + celcius
        cell.feelsLike.text = feelTemperature + celcius
        cell.humidity.text = humidity + percent
        cell.weather.text = weather
        cell.weatherImage.downloaded(from: fullUrlString)
        
        //Add weather to favorites
        cell.favoriteLocation.addTarget(self, action: #selector(setFavorite(sender:)), for: .touchUpInside)
        cell.favoriteLocation.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 475 //<-- Will return the height of each row
    }
    
    //Button for searching the city
    @IBAction func searchForCity(_ sender: Any) {
        
        //Refresh urlString and show tableview.
        urlString = ""
        tableView.isHidden = false
        
        //Hide keyboard on click
        searchBar.resignFirstResponder()
        
        //Create the API url
        let mainUrl = "http://api.openweathermap.org/data/2.5/weather?q="
        let city = searchBar.text!
        let endUrl = "&appid=9e73e77789b74d085856e30d5dda6285&units=metric&lang=se"
        
        let fullUrl = mainUrl + city + endUrl

        //Converting to non-american letters
        urlString = fullUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        //Retrieve data from JSON
        let data = JsonData.init()
        data.downloadJsonData(urlString: urlString!) { (responseArray) in
            self.dataArray = responseArray
            self.tableView.reloadData()
        }
    }

    //Adding location to favorites
    @objc func setFavorite(sender: UIButton){

        let defaults = UserDefaults.standard
        
        //Check if UserDefaults is not empty
        if (UserDefaults.standard.array(forKey: "myFavorites") != nil) {
            print("Not empty")
            favArray = defaults.stringArray(forKey: "myFavorites") ?? [String]()
        }

        //Add url to array
        if !favArray.contains(urlString!){
            favArray.append(urlString!)
            defaults.set(favArray, forKey: "myFavorites")
            defaults.synchronize()
            
            print(favArray)
        }
        else{
            //Create an alert if location already exists in favorites
            createAlert()
        }
    }
    
    func createAlert(){
        //Create the alert with title and message.
        let alert = UIAlertController(title: "Ops!", message: "Du har redan denna platsen i dina favoriter!", preferredStyle: .alert)
        
        //Create a button for the alert
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            print("Alert: OK button tapped")
        }))
        
        //Display the alert for users
        self.present(alert, animated: true, completion: nil)
    }
}

//Set image of tableview to weather icon
extension UIImageView {
    
    //Download the image from the API
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            //Continue in background
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}








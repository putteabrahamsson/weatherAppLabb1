//
//  FavoriteViewController.swift
//  weatherAppLabb1
//
//  Created by Putte on 2020-02-18.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var noFavImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    //Arrays
    var favArray: [String] = []
    var dataArray:[ResponseData] = []
    
    //Check if tableview should be asceding or desceding.
    var sortBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate & Datasource
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //View did appear
    override func viewDidAppear(_ animated: Bool) {
        //Get data from UserDefaults
        dataArray = []
        getDataFromUserDefaults()
    }
    
    //Tableview properties
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create the cell of the tableview
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteTableViewCell
        
        //Set data to variables
        let location = dataArray[indexPath.row].name
        let temperature = String(format:"%.1f", dataArray[indexPath.row].main.temp)
        let celcius = "\u{00B0}c"
        
        //Image properties
        let imgUrlString = "http://openweathermap.org/img/wn/"
        let weatherImg = dataArray[indexPath.row].weather[0].icon
        let imgUrlStringEnd = "@2x.png"
        let fullUrlString = imgUrlString + weatherImg + imgUrlStringEnd
        
        //Append items to cell
        cell.location.text = location
        cell.temperature.text = temperature + celcius
        cell.weatherImage.downloaded(from: fullUrlString)
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    //Remove location from favorites
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let defaults = UserDefaults.standard
        
        //Remove rows from favorites
        if editingStyle == .delete{
                        
            //Remove data from arrays
            favArray.remove(at: indexPath.row)
            dataArray.remove(at: indexPath.row)

            //Save new userdefaults
            defaults.set(favArray, forKey: "myFavorites")
            defaults.synchronize()
            
            //Get the updated values from getDataFromUserDefaults
            dataArray = []
            getDataFromUserDefaults()
        }
    }
    
    //Prepare for segue and pass array and indexPath
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"{
            let indexPath = tableView.indexPathForSelectedRow
            let vc = segue.destination as! DetailsViewController
            
            vc.dataArray = dataArray
            vc.indexPath = indexPath
        }
    }
    
    //Retrieve data from  UserDefaults
    func getDataFromUserDefaults(){
        let defaults = UserDefaults.standard
                
        //Check if userdefaults is not empty
        if (UserDefaults.standard.array(forKey: "myFavorites") != nil) {
            favArray = defaults.stringArray(forKey: "myFavorites") ?? [String]()

            //Display image if array is empty.
            if favArray.count == 0{
                noFavImage.isHidden = false
                tableView.isHidden = true
            }
            else{
                noFavImage.isHidden = true
                tableView.isHidden = false
            }
            
            //Retrieve data from API using URL
            for index in favArray{
                let data = JsonData.init()
                data.downloadJsonData(urlString: index) { (responseArray) in
                    self.dataArray.append(contentsOf: responseArray)
                    self.sortArray()
                }
            }
        }
    }
    
    //Set tableview sort to either true or false.
    @IBAction func sortButtonTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        //Descending
        if sortBool == false{
            sortBool = true
            defaults.set(sortBool, forKey: "sortedArray")
            defaults.synchronize()
            sortArray()
        }
        //Ascending
        else{
            sortBool = false
            defaults.set(sortBool, forKey: "sortedArray")
            defaults.synchronize()
            sortArray()
        }
    }
    
    //Sort tableview by ascending or descending
    func sortArray() {
        let defaults = UserDefaults.standard
        sortBool = defaults.bool(forKey: "sortedArray")
        
        //Descading
        if sortBool == false{
            dataArray = dataArray.sorted() { $0.main.temp > $1.main.temp }
            tableView.reloadData();
        }
            //Ascending
        else{
            dataArray = dataArray.sorted() { $0.main.temp < $1.main.temp }
            tableView.reloadData();
        }
    }
}



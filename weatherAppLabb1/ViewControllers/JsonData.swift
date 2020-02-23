//
//  JsonData.swift
//  weatherAppLabb1
//
//  Created by Putte on 2020-02-22.
//  Copyright © 2020 Putte. All rights reserved.
//

import Foundation

class JsonData{
    var dataArray:[ResponseData] = []
    
    func downloadJsonData(urlString: String, completed: @escaping (Array<ResponseData>) -> ()){
        
        //Check if URL is valid
        guard let url = URL(string: urlString) else {return}
        
        //Create the URLSession
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else{
                return
            }
            do{
                //Sets the dataArray to JSON data
                self.dataArray = [try JSONDecoder().decode(ResponseData.self, from: data)]
                
                //Complete task in background
                DispatchQueue.main.async {
                    completed(self.dataArray)
                }
            }
            catch let jsonErr{
                print(jsonErr)
            }
        }.resume()
    }
}

//Main structure
struct ResponseData : Codable{
    let weather: [Weather]
    let name: String
    let main: WeatherCondition
}

//Structure for weather array
struct Weather : Codable {
    let id: Int
    let description, icon: String
}

//Structure for weather dictionary
struct WeatherCondition: Codable{
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

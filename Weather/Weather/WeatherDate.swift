
//
//  AWeatherDate.swift
//  Weather
//
//  Created by Александр Цуканов on 22.03.2024.
//

import Foundation

struct Forecast: Codable {
    let list: [List]
    var city: City
    
    struct List: Codable {
        let date: Date
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let probability: Double
        let partOfDay: Sys
        let stringDate: String

        enum CodingKeys: String, CodingKey {
            case main, weather, wind, clouds
            case date = "dt"
            case probability = "pop"
            case partOfDay = "sys"
            case stringDate = "dt_txt"
        }
        
        
        struct Main: Codable {
            let temp: Double
            let tempMin: Double
            let tempMax: Double
            let pressure: Int

            enum CodingKeys: String, CodingKey {
                case temp, pressure
                case tempMin = "temp_min"
                case tempMax = "temp_max"
            }
        }
        
        struct Weather: Codable {
            let main: String
            let description: String
            let icon: String
            var weatherIconURL: URL? {
                let urlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
                guard let url = URL(string: urlString) else { return nil }
                return url
            }
        }
        
        struct Clouds: Codable {
            let all: Int
        }
        struct Wind: Codable {
            let speed: Double
            let deg: Int
        }
        
        struct Sys: Codable {
            let partOfDay: String
            
            enum CodingKeys: String, CodingKey {
                case partOfDay = "pod"
            }
        }
        
    }
    
    struct City: Codable {
        var name: String
        let sunrise, sunset: Date
    }
}
















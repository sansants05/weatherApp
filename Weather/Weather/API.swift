//
//  API.swift
//  Weather
//
//  Created by Александр Цуканов on 22.03.2024.
//

import UIKit
import CoreLocation
import MapKit
final class APIManager{
    private let apiKey = "e99d43b7b253d70050a0300de46a521c"
    func load(city: String , completion: @escaping (Result<WeatherData?, Error>) -> Void){
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)") else {return}
        let session = URLSession.shared.dataTask(with: URLRequest(url: url)){ data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                let weather = try? JSONDecoder().decode(WeatherData.self, from: data)
                completion(.success(weather))
            }
        }
        session.resume()
    }
    
    func loadLocation(lon: Double ,lat: Double , completion: @escaping (Result<WeatherData?, Error>) -> Void){
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)") else { return }
        let session = URLSession.shared.dataTask(with: URLRequest(url:url)) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                let weather = try? JSONDecoder().decode(WeatherData.self, from: data)
                completion(.success(weather))
            }
        }
        session.resume()
        
    }
    
    func requestWeatherForLocation(lon: Double ,lat: Double , completion: @escaping (Result<Forecast?, Error>) -> Void){
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&lang=ru&appid=\(apiKey)&units=metric") else { return }
        let session = URLSession.shared.dataTask(with: URLRequest(url:url)) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                let weather = try? JSONDecoder().decode(Forecast.self, from: data)
                completion(.success(weather))
            }
        }
        session.resume()
        
    }
    
   
}

//
//  Weather.swift
//  Weather
//
//  Created by Александр Цуканов on 23.03.2024.
//

import Foundation

let daysOfWeek = [
    "Mon": "Пн",
    "Tue": "Вт",
    "Wed": "Ср",
    "Thu": "Чт",
    "Fri": "Пт",
    "Sat": "Сб",
    "Sun": "Вс"
]

struct WeatherData: Codable{
    let main: Main
    let weather: [Weather]
    let wind: Wind
}
struct Main: Codable{
    let temp: Double
    let humidity: Int
}

struct Weather: Codable{
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Codable{
    let speed: Double
}
//
//  Weather.swift
//  VK Weather App
//
//  Created by Dmitry on 20.03.2024.
//


//
//  ViewController.swift
//  Weather
//
//  Created by Александр Цуканов on 22.03.2024.
//

import UIKit
import CoreLocation


class HomeViewController: UIViewController {
    let locationManager = CLLocationManager()
    private var searchedCity: String?
    var isLocationAvailable = false
    var lon = 0.0, lat : Double = 0.0
    var weatherForecasts = [Forecast]()
    var currentCity: String?
    private var shouldReloadWeatherData = false
    
    //Mark -GUI Variables
    private lazy var locationButton:UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        let icon = UIImage(systemName: "paperplane.circle")
        button.setImage(icon, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        button.setTitle("press", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        print(weatherForecasts)
        return button
    }()
    
    private lazy var textField:UITextField = {
        let text = UITextField()
        text.borderStyle = .roundedRect
        text.placeholder = "Введите текст"
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private lazy var conditionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 12)
        label.textColor = .grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "altTab")
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .boldSystemFont(ofSize: 81)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var windSpeed: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 12)
        label.textColor = .grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    private lazy var conditionView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 294, height: 95))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [textField, searchButton,
                                                  imageView,
                                                  tempLabel,
                                                  conditionLabel,
                                                  windSpeed])
        
        view.axis = .vertical
        view.spacing = 18
        view.alignment = .center
        view.distribution = .equalSpacing
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableViewHeight: CGFloat = 238
    
    
    //Mark: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkViolet
        
        textField.delegate = self
        setupNavigationController()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ForecastCell")
        addSubviews()
        setupConstraints()
        
        
        
        
    }
    //Mark: - adiing stackView and tableView in our view
    private func addSubviews(){
        view.addSubview(stackView)
        view.addSubview(tableView)
    }
    //Mark: - Navigation controller setup
    private func setupNavigationController() {
        navigationItem.title = "Прогноз погоды"
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"),
                                     style: .done,
                                     target: self,
                                     action: #selector(reload))
        let locationButton = UIBarButtonItem(image: UIImage(systemName: "paperplane.circle"),
                                             style: .done,
                                             target: self,
                                             action: #selector(getLocation))
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = button
        navigationController?.navigationBar.topItem?.leftBarButtonItem = locationButton
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    
    @objc
    private func reload() {
        weatherForecasts.removeAll()
        tableView.reloadData()
    }
    
    @objc
    private func getLocation(){
        shouldReloadWeatherData = true
        startLocationManager()
    }
    
    @objc private func searchButtonTapped() {
        if let searchText = textField.text {
            searchedCity = searchText
            weatherForecasts.removeAll()
            loadWeatherData(for: searchText)
            navigationItem.title = searchText
        }
    }
    //Mark: - setup constraints for stackView and tableView
    private func setupConstraints(){
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.heightAnchor.constraint(equalToConstant: tableViewHeight).isActive = true
        tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 30).isActive = true
        
        imageView.widthAnchor.constraint(equalToConstant: 160).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    private func loadWeatherData(for city: String) {
        let selectedCity = searchedCity ?? city
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(selectedCity) { placemarks, error in
            if let placemark = placemarks?.first {
                if let latitude = placemark.location?.coordinate.latitude,
                   let longitude = placemark.location?.coordinate.longitude {
                    self.lat = latitude
                    self.lon = longitude
                    self.requestWeatherForCity(lon: longitude, lat: latitude)
                }
            }
        }
        APIManager().load(city: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    if let weather = weather {
                        let num = Int(weather.main.temp - 273.15)
                        self?.tempLabel.text = "\(num)°С"
                        self?.windSpeed.text = "Cкорость ветра:\(weather.wind.speed)"
                        self?.conditionLabel.text = "Влажность:\(weather.main.humidity)"
                    } else {
                        self?.show(error: nil)
                    }
                case .failure(let error):
                    self?.show(error: error)
                }
            }
        }
    }
    
    private func show(error: Error?){
        let message = error == nil ? "Data is empty" : error?.localizedDescription
        let controller = UIAlertController(title: "Error",
                                           message: message,
                                           preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        present(controller, animated: true)
    }
    
    private func startLocationManager(){
        DispatchQueue.global().async {
            self.locationManager.requestWhenInUseAuthorization()
        }
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.pausesLocationUpdatesAutomatically = false
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    private func requestWeatherForCity(lon: Double,lat: Double) {
        weatherForecasts.removeAll()
        APIManager().requestWeatherForLocation(lon: lon, lat: lat) { [self] result in
            
            switch result {
            case .success(let weatherDates):
                if let unwrappedForecast = weatherDates {
                    print("Прогнозы получены.")
                    self.weatherForecasts.append(unwrappedForecast)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            case .failure(let apiError):
                print("Ошибка при получении прогнозов погоды: \(apiError.localizedDescription)")
            }
            
        }
    }
}

//Mark: - extension for working with CLCoreLocation
extension HomeViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
            
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            print(lat, lon)
            isLocationAvailable = true
            if shouldReloadWeatherData {
                requestWeatherForCity(lon: lon, lat: lat)
                shouldReloadWeatherData = false
            }
            
            // Вызовите метод для загрузки погоды на основе полученных координат только после установки значений lat и lon
            requestWeatherForCity(lon: lon, lat: lat)
            
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first, let city = placemark.locality {
                    self.currentCity = city
                    self.navigationItem.title = city
                }
            }
            
            APIManager().loadLocation(lon: location.coordinate.longitude, lat: location.coordinate.latitude) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let weather):
                        if let weather = weather {
                            let num = Int(weather.main.temp - 273.15)
                            self.tempLabel.text = "\(num)°С"
                            self.windSpeed.text = "Cкорость ветра:\(weather.wind.speed)"
                            self.conditionLabel.text = "Влажность:\(weather.main.humidity)"
                            print("Weather data for current location loaded successfully: \(weather)")
                        } else {
                            self.show(error: nil)
                        }
                    case .failure(let error):
                        self.show(error: error)
                    }
                }
            }
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
//Mark: - extensions for tableView
extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let forecast = weatherForecasts.first?.list else { return 0 }
        var count = 0
        for _ in forecast.filter({ $0.stringDate.hasSuffix("0:00:00") }) {
            count += 1
        }
        return count
    }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath)
        tableViewCell.backgroundColor = .lightViolet
        tableViewCell.textLabel?.textColor = .green
        tableViewCell.contentView.alpha = 1
        
        if let weatherForecast = weatherForecasts.first {
            let filteredList = weatherForecast.list.filter { $0.stringDate.hasSuffix("0:00:00") }
            
            if indexPath.row < filteredList.count {
                let weatherForecastWeek = filteredList[indexPath.row]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE"
                dateFormatter.locale = Locale(identifier: "ru_RU")
                let days = dateFormatter.string(from: weatherForecastWeek.date)
                
                tableViewCell.textLabel?.text = "\(daysOfWeek[days] ?? days)   \(weatherForecastWeek.main.temp)°C "
                
                if let url = weatherForecastWeek.weather.first?.weatherIconURL {
                    downloadImage(from: url) { image in
                        DispatchQueue.main.async {
                            tableViewCell.imageView?.image = image
                            tableViewCell.setNeedsLayout()
                        }
                    }
                }
                
                tableViewCell.isHidden = false
            }
        }
        
        return tableViewCell
    }
    
    
}

extension HomeViewController: UITableViewDelegate{
    
}
//Mark: - extension to allow use to remove the keyboard
extension HomeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

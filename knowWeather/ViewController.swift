//
//  ViewController.swift
//  knowWeather
//
//  Created by Renhao Zhang on 2021-03-20.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var minimumLabel: UILabel!
    @IBOutlet weak var feelsLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var maximumLabel: UILabel!
    
    
    let apiKey = "055431410a903050bfa6e6052c9f1cf7"
    var lat = 45.4910143
    var lon = -73.585322
    var activityIndicator: NVActivityIndicatorView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let indicatorSize:CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width - indicatorSize)/2, y: (view.frame.width - indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        //get language
        func getLanguage() -> String{
            let defs = UserDefaults.standard
            let allLanguages: [String] = defs.object(forKey: "AppleLanguages") as! [String]
            var chooseLanguage = allLanguages.first
            if chooseLanguage == "zh-Hans-US" {
                chooseLanguage = "zh_cn"
            }
            if chooseLanguage == "fr-CA" {
                chooseLanguage = "fr"
            }
            return chooseLanguage ?? "en"
        }
        let language = getLanguage()
        print(language)
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=mertic&lang=\(language)").responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value{
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
//                print("this is: " + iconName)
                
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.weatherImage.image = UIImage(named: iconName)
                self.weatherLabel.text = jsonWeather["description"].stringValue
                self.maximumLabel.text = "\(Int(round(jsonTemp["temp_max"].doubleValue - 273.15)))"
                self.temLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue - 273.15)))"
                self.minimumLabel.text = "\(Int(round(jsonTemp["temp_min"].doubleValue - 273.15)))"
                self.feelsLabel.text = "\(Int(round(jsonTemp["feels_like"].doubleValue - 273.15)))"
                self.humidityLabel.text = jsonTemp["humidity"].stringValue
                self.visibilityLabel.text = jsonResponse["visibility"].stringValue
                
                let date = Date()
                let weekFormatter = DateFormatter()
                let dateFormatter = DateFormatter()
                weekFormatter.dateFormat = "EEEE"
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.weekLabel.text = weekFormatter.string(from: date).uppercased()
                self.dateLabel.text = dateFormatter.string(from: date)
                

            }
        }
    }
    
}


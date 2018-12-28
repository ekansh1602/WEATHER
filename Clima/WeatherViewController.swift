
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate  {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let WEATHER_URL2 = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization() //location request authorization , triggers popup - change in infolist , once clicked xcode will look for the values of the two keys(made) present in the infolist file.
        
    // also copy xml code from the github site , since apple only allows location or weather apis with http request to work on the ios devices. So open the infolist file in xml format and copy the xml code from FIX FOR APP TRANSPORT SECURITY OVERRIDE
        
    locationManager.startUpdatingLocation()//asynchronous method - works in the background to grab the gps location
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    // CODE COPIED FROM ALAMOFIRE DOCUMENTATION
    //handles networking using get http request , sending the paramters to the url(website) to get the weather
   func getWeatherData(url: String,paramters:[String:String]){
        
        Alamofire.request(url, method: .get, parameters: paramters).responseJSON{
            URLResponse in
                if URLResponse.result.isSuccess{
                    print("success! got the data")
                    
                    let weatherJSON : JSON = JSON(URLResponse.result.value!)
                    print(weatherJSON)
                    self.updateWeatherData(json: weatherJSON)
                }
                else{
                    print("error\(String(describing: URLResponse.result.error))")
                }
            }
        }
 
 
   func getWeatherData2(url: String,parameters:[String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            URLResponse in
            if URLResponse.result.isSuccess{
                print("success! got the data")
                
                let weatherJSON : JSON = JSON(URLResponse.result.value!)
                print(weatherJSON)
                self.updateWeatherData2(json: weatherJSON)
            }
            else{
                print("error\(String(describing: URLResponse.result.error))")
            }
        }
    }

    
    

    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
   func updateWeatherData(json:JSON){
        if let tempResult = json["main"]["temp"].double{
        //find key from the data got in json format , complex if using/importing without swiftyjson files
        weatherDataModel.temperature = Int(tempResult - 273.15)//in celcius
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue//selected from the data got in json format which is printed on the console
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        //calling the update function to change the label , text , images etc. 
        updateUIWithWeatherData()
        
        }
        else{
            cityLabel.text = "weather unavailable"
        }
    }
 
 
   func updateWeatherData2(json:JSON){
        if let tempResultmax = json["list"][0]["main"]["temp_max"].double, let tempResultmin = json["list"][0]["main"]["temp_min"].double{
            //find key from the data got in json format , complex if using/importing without swiftyjson files
            weatherDataModel.maxtemperature = Int(tempResultmax-273.15)
            weatherDataModel.mintemperature = Int(tempResultmin-273.15)
            weatherDataModel.humidity = json["list"][0]["main"]["humidity"].intValue
           // weatherDataModel.city = json["city"]["city.name"].stringValue
            //calling the update function to change the label , text , images etc.
            updateUIWithWeatherData()
        
            
        }
        else{
            cityLabel.text = "weather unavailable"
        }
    }

  
  
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        cityLabel.text = "\(weatherDataModel.humidity)"
        temperatureLabel.text = "\(weatherDataModel.maxtemperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]//all the locations are stored in the locations array and we take the last value in the array since it would be the most accurate value
        if location.horizontalAccuracy>0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude = \(location.coordinate.longitude) , latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat":latitude,"lon":longitude,"appid":APP_ID]//dictionary
            
          getWeatherData(url: WEATHER_URL,paramters: params)
          getWeatherData2(url: WEATHER_URL2, parameters: params)
            
            
        }//stop updating once we get valid result
    }//send the location
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Error Occured"
    }//error occurs
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String){
        let params : [String:String] = ["q":city, "appid": APP_ID]//taken q because in the weather website documentation , q is used when searching wheather by name
       getWeatherData(url: WEATHER_URL, paramters: params)
       getWeatherData2(url: WEATHER_URL2, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
           let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
     //switch function
    @IBAction func changeToFarenheit(_ sender: UISwitch) {
        if (sender.isOn==false){
            let value = Double(weatherDataModel.maxtemperature) * 1.8 + 32
            temperatureLabel.text = "\(value)°F"
            print(value)
        }
        else{
            temperatureLabel.text = "\(weatherDataModel.maxtemperature)°"
        }
    }
    
    @IBAction func forecast(_ sender: Any) {
        performSegue(withIdentifier: "forecast", sender: nil)
    }
    
    
}


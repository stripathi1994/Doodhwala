//
//  LocationViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 8/9/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class LocationViewController: ProfileBaseViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var nextButton: UIButton!

    //let marker = GMSMarker()
    let geocoder = GMSGeocoder()
    var placesClient = GMSPlacesClient.shared()
    
    var locationAddress: GMSAddress?
    let marker = GMSMarker()

    var addressDetails: [String: Any]?
    var canGoBack = false
    
    var zoomLevel: Float {
        return 16
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(LocationAuthorizationStatus), name: Notification.Name(rawValue: "LocationAuthorizationStatus"), object: nil)

        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == .denied ||  authorizationStatus == .restricted) {
            self.showAlert(message: "App Permission Denied. To re-enable, please go to Settings and turn on Location Service for this app.")
        }

        
        if updateProfile {
        
            var deliverylocationValue = ""
            var addressValue = ""
            var landmarkValue = ""
            

            if let addressDetails = addressDetails {
                
                if let value = addressDetails["gps_address"] as? String  {
                    deliverylocationValue = value
                }

                if let value = addressDetails["address1"] as? String  {
                    addressValue = value
                }

                if let value = addressDetails["area"] as? String  {
                    landmarkValue = value
                }

            }

            profileInputFieldsArray = [["FieldId": "deliverylocation", "FieldValue": deliverylocationValue, "PaceholderValue": "DELIVERY LOCATION"], ["FieldId": "address", "FieldValue": addressValue, "PaceholderValue": "H.NO | FLOOR | LOCALITY | AREA"], ["FieldId": "landmark", "FieldValue": landmarkValue, "PaceholderValue": "LANDMARK"]]
            
            nextButton.setTitle("UPDATE", for: .normal)

        } else {
        
            profileInputFieldsArray = [["FieldId": "deliverylocation", "FieldValue": "", "PaceholderValue": "DELIVERY LOCATION"], ["FieldId": "address", "FieldValue": "", "PaceholderValue": "H.NO | FLOOR | LOCALITY | AREA"], ["FieldId": "landmark", "FieldValue": "", "PaceholderValue": "LANDMARK"]]
        }
        
        
        if canGoBack == false {
            
            self.navigationItem.hidesBackButton = true
        }
        mapView.isMyLocationEnabled = true

            if let addressDetails = addressDetails {
                
                var latitude = 0.0
                var longitude = 0.0

                if let stringValue = addressDetails["latitude"] as? String, let value = Double(stringValue)  {
                    latitude = value
                }

                if let stringValue = addressDetails["longitude"] as? String, let value = Double(stringValue)  {
                    longitude = value
                }

                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: zoomLevel)
                mapView.camera = camera

            }
            else {
                getCurrentPlace()
            }

    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setCurrentLocation(place: GMSPlace) {

        // Creates a marker in the center of the map.
        let camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: zoomLevel)
        mapView.camera = camera
    }
    
    func getCurrentPlace() {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {

                    //at 0 index location txt field is there
                   // self.profileInputFieldsArray[0].updateValue(place.formattedAddress!, forKey: "FieldValue")
                    self.setCurrentLocation(place: place)
                }
            }
        })
    }
    
    @IBAction func nextButtonAction() {
    
        if updateProfile {
            updateLocation()
        } else {
            showProfileViewController()
        }
    }
    
    func validateFlatNumber() -> Bool {
        
        var returnVal = false
        var address = ""
        for dict in  self.profileInputFieldsArray! {
            
            if dict["FieldId"] == "address" {
                address = dict["FieldValue"]!
                break;
            }
        }

        if address.count > 0 {
            returnVal = true
        }
        
        return returnVal
    }
    
    fileprivate func showProfileViewController() {
        
        if let controller = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            
            if validateFlatNumber() {
                controller.locationFieldsArray = self.profileInputFieldsArray
                controller.locationAddress = self.locationAddress
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.showAlert(message: "Please enter H.No, Floor etc.")
            }
        }
    }

    func LocationAuthorizationStatus() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == .denied ||  authorizationStatus == .restricted) {
            self.showAlert(message: "It is recommended to allow location access to help in finding address for delivery of productss. To re-enable, please go to Settings and turn on Location Service for this app.")
        } else {
            getCurrentPlace()
        }

    }
    
    @IBAction func resetToCurrentLocation(_ sender: Any) {
    
        getCurrentPlace()
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationViewController: GMSMapViewDelegate {
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        marker.icon = UIImage(named: "location")
        marker.position = position.target
//        if let lines = result.lines {
//
//            if lines.count > 0 {
//                marker.title = lines[0]
//            }
//            if lines.count > 1 {
//                marker.snippet = lines[1]
//            }
//        }
        
        marker.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        
        geocoder.reverseGeocodeCoordinate(position.target) { (response, error) in
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult() {
                
                self.locationAddress = result
               
                
                if let address = result.lines?.joined(separator: " ") {
                    self.profileInputFieldsArray[0].updateValue(address, forKey: "FieldValue")
                    self.tableView.reloadData()
                }
            }
        }
    }
}


//MARK:- webservice methods
extension LocationViewController {
    
    fileprivate func updateLocation() {
        
        self.view.endEditing(true)

        let userId = UserManager.defaultManager.userDict?["user_id"] as! Int
        
//        if let userprofileDict = UserManager.defaultManager.userProfileDict {
//
//            if let userProfile = userprofileDict["user_details"] as? [String: Any] {
//
//                if let value = userProfile["address_id"] as? String {
//
//                    addressId = value
//                }
//            }
//        }
        
        if !validateFlatNumber() {
            self.showAlert(message: "Please enter H.No, Floor etc.")
            return
        }
        
        var gpsAddress = ""
        var address1 = ""
        var area = ""
        for dict in  profileInputFieldsArray {
            
            if dict["FieldId"] == "deliverylocation" {
                gpsAddress = dict["FieldValue"]!
            }
            
            if dict["FieldId"] == "address" {
                address1 = dict["FieldValue"]!
            }
            
            if dict["FieldId"] == "landmark" {
                area = dict["FieldValue"]!
            }
        }
        
        var gpsName = ""
        if let value = self.locationAddress?.thoroughfare {
            gpsName = value
        }
        
        var locality = ""
        if let value = self.locationAddress?.locality {
            locality = value
        }
        
        var sublocality = ""
        if let value = self.locationAddress?.subLocality {
            sublocality = value
        }
        
        var state = ""
        if let value = self.locationAddress?.administrativeArea {
            state = value
        }
        
        var postalCode = ""
        if let value = self.locationAddress?.postalCode {
            postalCode = value
        }
        
        var country = ""
        if let value = self.locationAddress?.country {
            country = value
        }
        
        var latitude = 0.0
        var longitude = 0.0
        
        if let coordinate = self.locationAddress?.coordinate {
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
        
        let parameters = ["user_id": userId, "gps_address": gpsAddress, "address1": address1, "gps_name": gpsName,  "locality": locality, "sub_locality": sublocality, "city": locality, "region_code": country, "latitude": "\(latitude)", "longitude": "\(longitude)", "area": area, "state": state, "pincode": postalCode, "action": "update"] as [String : Any]
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        APIManager.defaultManager.requestJSON(apiRouter: .updateUserLocationInfo(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        print("SUCCESS")
                        
                        var message = "Request successful"
                        if let value = responseDict["msg"] as? String {
                            
                            message = value
                        }

                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "refreshprofiledetails")))

                        let controller = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2]

                        if self.canGoBack {
                            
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }

                        DispatchQueue.main.async {
                            controller?.showAlert(message: message)
                        }

                        


                    } else {
                        //Failure handle errors
                        
                        if let message = responseDict["msg"] as? String {
                            
                            self.showAlert(message: message)
                        }
                    }
                }
            }
        }
    }
    
}

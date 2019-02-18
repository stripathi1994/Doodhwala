//
//  ProfileViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 8/9/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import MBProgressHUD
import GoogleMaps

class ProfileViewController: ProfileBaseViewController {

    @IBOutlet weak var maleRadioButton: UIButton!
    @IBOutlet weak var femaleRadioButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mobileNumberLabel: UILabel!

    @IBOutlet weak var tableViewHeightConstraint: UITableView!
    @IBOutlet weak var maleStackView: UIStackView!
    @IBOutlet weak var femaleStackView: UIStackView!
    @IBOutlet weak var topEditViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButtonHeightConstraint: NSLayoutConstraint!
    
    var locationFieldsArray: [[String: String]]?
    var locationAddress: GMSAddress?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(setupData), name: Notification.Name(rawValue: "profiledetailsupdated"), object: nil)

        mobileNumberLabel.text = ""
        
        setupData()
        
        let selectedImage = UIImage(named: "radiobuttonselected")?.withRenderingMode(.alwaysTemplate)
        
        maleRadioButton.setImage(selectedImage, for: .selected)
        femaleRadioButton.setImage(selectedImage, for: .selected)
        
        maleRadioButton.isSelected = true
        profileImageView.layer.cornerRadius = 60
        

    }
    
   
    func setupData() {
        
        if updateProfile {
            
            var name = ""
            var email = ""
            var locationValue = ""
            var addressValue = ""
            var landmarkValue = ""
            
            if let userprofileDict = UserManager.defaultManager.userProfileDict {
                
                if let userProfile = userprofileDict["user_details"] as? [String: Any] {
                    
                    if let value = userProfile["first_name"] as? String {
                        name = value
                    }

                    if let value = userProfile["last_name"] as? String {
                        name = name + " " + value
                    }

                    if let value = userProfile["email"] as? String {
                        email = value
                    }
                }
                
                if let userProfile = userprofileDict["user"] as? [String: Any] {
                    if let value = userProfile["mobile"] as? String  {
                        mobileNumberLabel.text = value
                    }
                }
                
                if let addressDetails = userprofileDict["address"] as? [String: Any] {
                    
                    if let value = addressDetails["gps_address"] as? String {
                        locationValue = value
                    }
                    
                    if let value = addressDetails["address1"] as? String {
                        addressValue = value
                    }
                    
                    if let value = addressDetails["area"] as? String {
                        landmarkValue = value
                    }
                }
            }
            
            profileInputFieldsArray = [["FieldId": "name", "FieldValue": name, "PaceholderValue": "NAME"], ["FieldId": "email", "FieldValue": email, "PaceholderValue": "EMAIL"], ["FieldId": "addressdetails", "locationValue": locationValue, "addressValue": addressValue, "landmarkValue": landmarkValue, "PaceholderValue": ""]]
            
            tableView.reloadData()
            
        } else {
            profileInputFieldsArray = [["FieldId": "name", "FieldValue": "", "PaceholderValue": "NAME"], ["FieldId": "email", "FieldValue": "", "PaceholderValue": "EMAIL"], ["FieldId": "referral", "FieldValue": "", "PaceholderValue": "REFERRAL CODE [OPTIONAL]"]]
        }
        
    }
    
    override func setUpView() {
        super.setUpView()
    
        if updateProfile {
            
            MenuViewController.configureMenu(button: menuButton, controller: self)

            submitButtonHeightConstraint.constant = 0

            maleStackView.isHidden = true
            femaleStackView.isHidden = true
            mobileNumberLabel.isHidden = false
            
            
        } else {

            self.navigationItem.leftBarButtonItem = nil
            
            topEditViewHeightConstraint.constant = 0

            maleStackView.isHidden = false
            femaleStackView.isHidden = false
            mobileNumberLabel.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func maleRadioButtonAction(_ sender: UIButton) {
        
        maleRadioButton.isSelected = true
        femaleRadioButton.isSelected = false
        
        profileImageView.image = UIImage(named: "male")
    }
    
    @IBAction func femaleRadioButtonAction(_ sender: UIButton) {

        maleRadioButton.isSelected = false
        femaleRadioButton.isSelected = true

        profileImageView.image = UIImage(named: "female")

    }
    
    @IBAction func editButtonAction(_ sender: UIButton) {
        
        if editProfileButton.isSelected {
            
            updateUserProfile()
        }
        else {

            sender.isSelected = true
            setEditButtonTitle()
            
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileTableViewCell {
                cell.textField.becomeFirstResponder()
            }
        }
    }

    
    @IBAction func editLocationButtonAction(_ sender: UIButton) {
        
        showLocationViewController()
    }
    
    fileprivate func setEditButtonTitle() {
        
        if editProfileButton.isSelected {
            
            editProfileButton.setTitle("Save", for: .normal)
            
        } else {
            
            editProfileButton.setTitle("Edit", for: .normal)
            self.view.endEditing(true)
        }
    }
    
    
    @IBAction func submitButtonAction() {
        
        var referral = ""
        var email = ""
        var name = ""
        for dict in  profileInputFieldsArray {
            
            if dict["FieldId"] == "name" {
                name = dict["FieldValue"]!
            }
            
            if dict["FieldId"] == "email" {
                email = dict["FieldValue"]!
            }
            
            if dict["FieldId"] == "referral" {
                referral = dict["FieldValue"]!
            }
        }
        
        if name.count == 0 {
            self.showAlert(message: "Name can't be left empty.")
            return
        }
        if isEmailValid(email) == false {
            self.showAlert(message: "Please enter a valid email id.")
            return
        }
        
        if referral.count > 0 {
            
            validateReferral(referral: referral)
        } else {
            self.createUserProfile()
        }
    }

    
    fileprivate func showLocationViewController() {
        
        if let controller = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController {
            
            if let userprofileDict = UserManager.defaultManager.userProfileDict, let addressDetails = userprofileDict["address"] as? [String: Any] {
                controller.addressDetails = addressDetails
            }
            controller.updateProfile = true
            controller.canGoBack = true
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

//MARK:- webservice methods
extension ProfileViewController {
    
    //     POST Input :  deviceId,user_id, address1,address2, city, state_id, pincode , referral_code , first_name , last_name , phone , email ,gender ,latitude ,longitude,area ,gps_address ,locality ,gps_name ,sub_locality ,region_code

    fileprivate func createUserProfile() {
        
        self.view.endEditing(true)
       // POST Input :  deviceId,user_id, first_name, email, gps_address, address1, gps_name, city, locality, sub_locality, state_id,  pincode, region_code, referral_code  ,gender ,latitude ,longitude,area

        let userId = UserManager.defaultManager.userDict?["user_id"] as! Int
        let deviceId = (UIDevice.current.identifierForVendor?.uuidString)!
        var name = ""
        var email = ""
        var referral = ""
        var gender: String = ""
        
        for dict in  profileInputFieldsArray {
            
            if dict["FieldId"] == "name" {
                name = dict["FieldValue"]!
            }
            
            if dict["FieldId"] == "email" {
                email = dict["FieldValue"]!
            }
            
            if dict["FieldId"] == "referral" {
                referral = dict["FieldValue"]!
            }
        }
        
        
        //[["FieldId": "deliverylocation", "FieldValue": deliverylocationValue, "PaceholderValue": "DELIVERY LOCATION"], ["FieldId": "address", "FieldValue": addressValue, "PaceholderValue": "H.NO/FLOOR"], ["FieldId": "landmark", "FieldValue": landmarkValue, "PaceholderValue": "LANDMARK"]]
        var gpsAddress = ""
        var address1 = ""
        var area = ""
        for dict in  locationFieldsArray! {
            
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
        
        if maleRadioButton.isSelected {
            gender = "M"
        } else {
            gender = "F"
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

//        var nameArray = name.components(separatedBy: " ")
//
//        let firstname = nameArray.removeFirst()
//        let lastName = nameArray.joined(separator: " ")
//
       // let parameters = ["user_id": userId, "deviceId": deviceId, "first_name": name, "last_name": "adsads", "phone": "9818510843", "area": "saas", "email": email, "gps_address": gpsAddress, "address1": address1, "address2": "asdsds", "landmark": "sdaaads", "gps_name": gpsName, "city": locality, "locality": locality, "sub_locality": sublocality, "state": state, "state_id": state, "pincode": postalCode, "region_code": country,  "gender": gender, "latitude": latitude, "longitude": longitude] as [String : Any]

        let parameters = ["user_id": "\(userId)", "deviceId": deviceId, "first_name": name, "email": email, "gps_address": gpsAddress, "address1": address1, "gps_name": gpsName, "city": locality, "locality": locality, "sub_locality": sublocality, "state": state, "pincode": postalCode, "region_code": country, "gender": gender, "latitude": "\(latitude)", "longitude": "\(longitude)", "area": area, "referral_code": referral] as [String : Any]

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        APIManager.defaultManager.requestJSON(apiRouter: .createProfile(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        
                        print("SUCCESS")
                        
                        var message = "Request successful"
                        if let value = responseDict["msg"] as? String {
                            
                            message = value
                        }
                        
                        let controller = self.navigationController?.viewControllers.first
                        self.navigationController?.popToRootViewController(animated: false)
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "profileCreated")))
                        
                        if let controller = controller {
                            controller.showAlert(message: message)
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
    
    fileprivate func updateUserProfile() {

        self.view.endEditing(true)

        let userId = UserManager.defaultManager.userDict?["user_id"] as! Int
        var name = ""
        var email = ""
        var addressId = 0

        if let userprofileDict = UserManager.defaultManager.userProfileDict {
            
            if let userProfile = userprofileDict["user_details"] as? [String: Any] {
         
                if let value = userProfile["address_id"] as? Int {
                    
                    addressId = value
                } else {
                    return
                }
            }
        }
        
        for dict in  profileInputFieldsArray {
            
            if dict["FieldId"] == "name" {
                name = dict["FieldValue"]!
            }
            
            if dict["FieldId"] == "email" {
                email = dict["FieldValue"]!
            }
        }
        
        if name.count == 0 {
            self.showAlert(message: "Name can't be left empty.")
            return
        }
        if isEmailValid(email) == false {
            self.showAlert(message: "Please enter a valid email id.")
            return
        }

//        var nameArray = name.components(separatedBy: " ")
//
//        let firstname = nameArray.removeFirst()
//        let lastName = nameArray.joined(separator: " ")
        
        let parameters = ["user_id": userId, "address_id": addressId, "first_name": name, "email": email, "action": "update"] as [String : Any]
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        APIManager.defaultManager.requestJSON(apiRouter: .updateUserInfo(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        self.editProfileButton.isSelected = false
                        self.setEditButtonTitle()

                        print("SUCCESS")
                        
                        var message = "Request successful"
                        if let value = responseDict["msg"] as? String {
                            
                            message = value
                        }
                        self.showAlert(message: message)
                        
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "refreshprofiledetails")))

                        
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
    
    fileprivate func validateReferral(referral: String) {
        
        APIManager.defaultManager.requestJSON(apiRouter: .validateReferralCode(["referral_code": referral])) { (responseDict) in
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        self.createUserProfile()
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



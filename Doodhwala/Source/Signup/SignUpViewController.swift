//
//  SignUpViewController.swift
//  Doodhwala
//
//  Created by apple on 05/07/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var singupView: UIView!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var otpTextField: UITextField!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    @IBOutlet weak var nextButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var otpViewHeightConstraint: NSLayoutConstraint!
    
    var deviceId: String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setTitleView()

        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMilkDashboardController), name: Notification.Name(rawValue: "profileCreated"), object: nil)


        self.mobileNumberTextField.addDoneButtonOnKeyboard()
        
        singupView.isHidden = true
        otpViewHeightConstraint.constant = 0
        isUserRegistered()
    }

    override func viewWillAppear(_ animated: Bool) {
    
            super.viewWillAppear(true)
    
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

    @IBAction func nextButtonAction(_ sender: UIButton) {
        
        mobileNumberTextField.resignFirstResponder()
        signupUser()
    }
    
    @IBAction func registerButtonAction(_ sender: UIButton) {
        otpTextField.resignFirstResponder()
        verifyOtp()
    }

    @IBAction func resendOTPButtonAction(_ sender: UIButton) {
        
        sendOTP()
    }

}

//MARK:- REST APIs
extension SignUpViewController {
    
    func isUserRegistered() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."

        print("deviceId= \(deviceId)")
        APIManager.defaultManager.isRegister(deviceId) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)

            if let responseDict = responseDict {
                //check for status 000000 for regsitered, 000001 for not registered
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        
                        UserManager.defaultManager.userDict = responseDict

                        if let isProfileComplete = responseDict["is_profile"] as? Int {
                            
                            if isProfileComplete == 0 {
                                self.showMilkDashboardController()
                            } else {
                                //profile incomplete. update profile
                                self.showLocationViewController()
                            }
                        }

                    } else {
                        //Not registered
                        
                        self.singupView.isHidden = false
                    }
                }

            } else {
                //DO SignUp
                print("Something went wrong. Please try again")
            }
        }
        
    }
    
    fileprivate func signupUser() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let parameters = ["deviceId": deviceId, "mobile": mobileNumberTextField.text!]

        APIManager.defaultManager.requestJSON(apiRouter: .signUp(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for succes, 000001 for failure
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        // take user to verify OTP view
                        var message = "An OTP has been sent to your mobile number."
                        if let value = responseDict["msg"] as? String {
                            message = value
                        }
                        self.showVerifyOTPView(message: message)
                        
                    } else if status == "000002" {
                        //mobile number already registered, but device changed,Update your device ?.
                        self.handleAlreadyRegisteredMobile(responseDict: responseDict)
                    
                    } else if status == "000007" {
                        //Call send OTP API
                        self.sendOTP()
                    }
                }
                
            } else {
                print("Something went wrong. Please try again")
            }
        }
    }
    
    
    fileprivate func verifyOtp() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let parameters = ["deviceId": deviceId, "mobile": mobileNumberTextField.text!, "otp": otpTextField.text!]
        
        APIManager.defaultManager.requestJSON(apiRouter: .verifyOtp(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for succes, 000001 for failure
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        // OTP verified
                        UserManager.defaultManager.userDict = responseDict
                        self.updateDevice()
                        
                    } else if status == "000001" {
                        //OTP not valid
                        var message = "Please enter valid OTP."
                        if let value = responseDict["msg"] as? String {
                            message = value
                        }
                        self.showAlert(message: message)
                    }
                }
                
            } else {
                print("Something went wrong. Please try again")
            }
        }
    }
    
    fileprivate func handleAlreadyRegisteredMobile(responseDict: [String: Any]) {
        
        var message = "Mobile number already registered, but device changed, Update your device ?"
        if let value = responseDict["msg"] as? String {
            message = value
        }

        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            self.sendOTP()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(updateAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func updateDevice() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let parameters = ["deviceId": deviceId, "mobile": mobileNumberTextField.text!]
        
        APIManager.defaultManager.requestJSON(apiRouter: .updateDevice(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for succes, 000001 for failure
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Device Id Updated
                        
                        if let isProfileComplete = responseDict["is_profile"] as? Int {
                            
                            if isProfileComplete == 0 {
                                self.showMilkDashboardController()
                            } else {
                                //profile incomplete. update profile
                                self.showLocationViewController()
                            }
                        } else {
                            print("Something went wrong. Please try again")
                        }
                    } else  {
                        print("Something went wrong. Please try again")

                    }
                }
                
            } else {
                print("Something went wrong. Please try again")
            }
        }
    }

    
    fileprivate func sendOTP() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let parameters = ["deviceId": deviceId, "mobile": mobileNumberTextField.text!]
        
        APIManager.defaultManager.requestJSON(apiRouter: .sendOTP(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for succes, 000001 for failure
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //An OTP has been sent. Show the OTP View
                        self.showVerifyOTPView(message: "An OTP has been sent to your mobile number.")
                        
                    } else  {
                        print("Something went wrong. Please try again")
                        
                    }
                }
                
            } else {
                print("Something went wrong. Please try again")
            }
        }
    }

}

//MARK:- UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var characterCount: Int!
        var button: UIButton!
        
        if textField == mobileNumberTextField {
            characterCount = 10
            button = nextButton
        } else if textField == otpTextField {
            characterCount = 4
            button = registerButton
        } else {
            return true
        }
        
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count < characterCount {
            button.backgroundColor = UIColor.lightGray
            button.isEnabled = false
        } else {
            button.backgroundColor = UIColor.darkOrange
            button.isEnabled = true
        }
        
        return updatedText.count <= characterCount
    }
}

//MARK:- navigation methods
extension SignUpViewController {

    fileprivate func showLocationViewController() {
        
//        self.showMilkDashboardController()
//        return
        
        if let controller = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController {
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    @objc fileprivate func showMilkDashboardController() {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as? SWRevealViewController {
            
            self.present(controller, animated: true) {
                
                self.resetViewForLogoutScreen()
            }
        }
    }
    
    fileprivate func showVerifyOTPView(message: String) {
        
        self.showAlert(message: message)

        mobileNumberTextField.isUserInteractionEnabled = false
        otpTextField.addDoneButtonOnKeyboard()
        otpTextField.becomeFirstResponder()
        self.otpViewHeightConstraint.constant = 205
        self.nextButtonHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.2) {
            self.singupView.layoutIfNeeded()
        }
    }
    
    private func resetViewForLogoutScreen() {
        self.singupView.isHidden = false //needed when user log out
        self.mobileNumberTextField.isUserInteractionEnabled = true
        self.mobileNumberTextField.text = ""
        self.otpTextField.text = ""
        self.otpViewHeightConstraint.constant = 0
        self.nextButtonHeightConstraint.constant = 40

        self.nextButton.backgroundColor = UIColor.darkOrange
        self.nextButton.isEnabled = true

    }
}


//MARK:- Keyboard observers
extension SignUpViewController {
    
    func keyboardWillShow(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        UIView.animate(withDuration: duration, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -100)
        })
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        UIView.animate(withDuration: duration, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: 100)
        })
    }
}


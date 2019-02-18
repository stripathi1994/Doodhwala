//
//  SubscriptionSummaryViewController.swift
//  Doodhwala
//
//  Created by apple on 15/07/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit
import NotificationCenter

class SubscriptionSummaryViewController: UIViewController {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var quanityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var verifyButtonUnderline: UIView!

    @IBOutlet weak var promoCodeButton: UIButton!
    @IBOutlet weak var promoCodeButtonUnderline: UIView!

    @IBOutlet weak var promoTextField: UITextField!
    
    @IBOutlet weak var weekDaysStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var quanityValueViewHrightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weekDaysView: WeekDaysStackView!

    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var promoStatusButton: UIButton!
    @IBOutlet weak var successmessageLabel: UILabel!
    @IBOutlet weak var promomessageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var subscriptionTitleLabel: UILabel!

    //Data Properties
    var productSubDetailsDict: [String: Any]?
    var subscriptionView = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(setupAddress), name: Notification.Name(rawValue: "profiledetailsupdated"), object: nil)

        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func setupView() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

        self.setTitleView()

        promoStatusButton.isHidden = true
        promomessageLabel.isHidden = true
        successmessageLabel.isHidden = true
        descriptionLabel.isHidden = true

        if subscriptionView == false {
            promoCodeButton.isHidden = true
            promoCodeButtonUnderline.isHidden = true
            subscriptionTitleLabel.text = "Payment Mode"
        }
        
        showPromoFields(show: false)
        
        if let productSubDetailsDict = productSubDetailsDict {
            
            if subscriptionView {
            if let subscriptionId = productSubDetailsDict["subscriptionId"] as? Int {
                
                if subscriptionId > 0 {
                    self.updateButton.setTitle("UPDATE", for: .normal)
                }
            }
            } else {
                self.updateButton.setTitle("ORDER", for: .normal)
            }
            
            productNameLabel.text = productSubDetailsDict["productName"] as? String
            subscriptionLabel.text = productSubDetailsDict["subscriptionType"] as? String
            priceLabel.text = productSubDetailsDict["price"] as? String

            if let value = productSubDetailsDict["quantityText"] as? String {

                if value.count == 0 {
                    //custom Delivery
                    weekDaysStackViewHeightConstraint.constant = 60
                    quanityValueViewHrightConstraint.constant = 60
                    quanityLabel.text = ""
                    
                    if let value = productSubDetailsDict["customDaysDict"] as? [String : Int] {
                    
                        weekDaysView.daysDict = value
                        weekDaysView.setUpAsReadableView()
                    }
                    
                } else {
                    //every or alternate day
                    weekDaysStackViewHeightConstraint.constant = 0
                    quanityValueViewHrightConstraint.constant = 30
                    quanityLabel.text = value
                }
            }
        }

        setupAddress()
    }
    
    func setupAddress() {
        addressLabel.text = UserManager.defaultManager.getAddress()
    }
    
    private func showPromoFields(show: Bool) {
        
        self.verifyButton.isHidden = !show
        self.promoTextField.isHidden = !show
        self.verifyButtonUnderline.isHidden = !show
    }
    
    @IBAction func promoCodeButtonAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            showPromoFields(show: true)
        } else {
            showPromoFields(show: false)
        }
        
        promoStatusButton.isHidden = true
        promomessageLabel.isHidden = true
        descriptionLabel.isHidden = true

        promoTextField.text = ""
    }
    
    @IBAction func verifyButtonAction(_ sender: UIButton) {
        
        promoTextField.resignFirstResponder()
        
        let promocode = promoTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if promocode?.count == 0 {
            return
        }

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."

        let productId = productSubDetailsDict?["productId"] as? Int
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        
        let parameters = ["user_id": userId, "product_id": productId, "promo_code": promocode!] as [String : Any]
        
        APIManager.defaultManager.requestJSON(apiRouter: .verifyPromo(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        
                        var message = "You have updated subscription successfully."
                        if let value = responseDict["msg"] as? String {
                            message = value
                        }

                        var description = ""
                        if let value = responseDict["description"] as? String {
                            description = value
                        }

                        self.showMessage(message: message, description: description, isSucces: true)

                        
                    } else if let message = responseDict["msg"] as? String {
                        //Failure handle errors
                        self.showMessage(message: message, description: "", isSucces: false)
                    }
                }
            }
        }
    }
    
    @IBAction func updateButtonAction(_ sender: UIButton) {
        
        if sender.currentTitle == "OK" {
         
            gotoHomeScreen()
        } else {
            
            checkisServicePin()
        }
    }
    
    func gotoHomeScreen() {
        
        if let viewControllers = self.navigationController?.viewControllers {
            
            if viewControllers.count > 2 {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            }
        }
    }
    
    fileprivate func checkisServicePin() {
        
        guard let pinCode = UserManager.defaultManager.getPinCode() else {
            self.showAlert(message: "Please update pincode in your address.")
            return
        }
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."

        APIManager.defaultManager.requestJSON(apiRouter: .isServicePinCode(["user_id": userId, "pincode": pinCode])) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        
                        self.subscribeProduct()
                        
                    } else if let message = responseDict["msg"] as? String {
                        //Failure handle errors
                        
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        
                        let notifyAction =  UIAlertAction(title: "Notify", style: .default, handler: { (action) in
                            self.notify()
                        })
                        
                        let changeAddress =  UIAlertAction(title: "Change Address", style: .default, handler: { (action) in
                            self.showLocationController()
                        })
                        
                        
                        alertController.addAction(notifyAction)
                        alertController.addAction(changeAddress)
                        self.present(alertController, animated: true, completion: nil)

                    }
                }
            }
        }
    }
    
    
    fileprivate func notify() {
        
        guard let pinCode = UserManager.defaultManager.getPinCode() else {
            self.showAlert(message: "Please update pincode in your address.")
            return
        }
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        //if let productDict = productSubDetailsDict, let productId = productDict["productId"] as? Int, let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            let productId = productSubDetailsDict?["productId"] as? Int
        
        APIManager.defaultManager.requestJSON(apiRouter: .notifyService(["user_id": userId, "pincode": pinCode, "product_id": productId])) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        
                        self.gotoHomeScreen()
                        
                    } else if let message = responseDict["msg"] as? String {
                        
                        self.showAlert(message: message)
                    }
                }
            }
        }
    }
    
    
    fileprivate func showMessageOnSubscription(message: String) {
        
        successmessageLabel.isHidden = false
        successmessageLabel.text = message
        
        showPromoFields(show: false)
        
        promoCodeButton.isHidden = true
        promoStatusButton.isHidden = true
        promomessageLabel.isHidden = true
        descriptionLabel.isHidden = true

        promoCodeButtonUnderline.isHidden = true
    }

    fileprivate func showMessage(message: String, description: String, isSucces: Bool) {
        
        promoStatusButton.isHidden = false
        promomessageLabel.isHidden = false
        descriptionLabel.isHidden = false
        
        promomessageLabel.text = message
        descriptionLabel.text = description
        
        if isSucces {
            promoStatusButton.setImage(UIImage(named: "success"), for: .normal)
        } else {
            promoStatusButton.setImage(UIImage(named: "closeicon"), for: .normal)
        }
    }
    
    @IBAction func addressLabelTapAction(_ sender: UITapGestureRecognizer) {

        showLocationController()
    }

    func showLocationController() {
        
        if let controller = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController {
            
            if let userprofileDict = UserManager.defaultManager.userProfileDict, let addressDetails = userprofileDict["address"] as? [String: Any] {
                controller.addressDetails = addressDetails
            }
            controller.updateProfile = true
            controller.canGoBack = true
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
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


//MARK:- Subscribe methods
extension SubscriptionSummaryViewController {
    
    fileprivate func subscribeProduct() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        var parameters:[String : Any]?
        
        if subscriptionView {
            parameters = getSubscriptionParameters()
        } else {
            parameters = getSingleOrderParameters()
        }
        
        if let parameters = parameters {
            
            APIManager.defaultManager.requestJSON(apiRouter: .subscribeProduct(parameters)) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                        
                            self.updateButton.setTitle("OK", for: .normal)
                            self.navigationItem.hidesBackButton = true
                           
                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "subscriptionUpdated")))
                            
                            var message = "You have updated subscription successfully."
                            
                            if self.subscriptionView {
                                if let value = responseDict["msg"] as? String {
                                message = value
                                }
                            } else {
                                message = "You have ordered successfully"
                            }

                            if let value = responseDict["net_price"] as? Int {
                                self.priceLabel.text = "\(value) Rs/ "
                                
                                if let productSubDetailsDict = self.productSubDetailsDict, let productUnit = productSubDetailsDict["productUnit"] as? String {
                                
                                    self.priceLabel.text = self.priceLabel.text! + productUnit
                                }
                            }
                            
                            self.showMessageOnSubscription(message: message)
                            
                        } else if let message = responseDict["msg"] as? String {
                            //Failure handle errors
                            self.showAlert(message: message)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func getSubscriptionParameters() -> [String : Any]? {
        
        var parameters: [String: Any]?
        
        if let productDict = productSubDetailsDict, let productId = productDict["productId"] as? Int, let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            //"isUpdate": 0, "subscription_id": 0 For Create subscription. For Edit subscription these will have values
            
            let startDate = productDict["startDate"] as! String
            let quanity =   productDict["quantity"] as! Int
            let subscriptionType = productDict["subscriptionType"] as! String
            let deliveryFrequency = productDict["deliveryFrequency"] as! Int
            let alternateDaySelected = productDict["alternateDaySelected"] as! Int
            let ringBell = productDict["ringBell"] as! Int
            
            let request = productDict["nice_to_have_req"] as! String
            //type will be One Time or Daily ( for milk product  always Daily and for other products One Time)
            //
            //"promo_code": "",
            let subscriptionId = productDict["subscriptionId"] as! Int
            let isUpdate = subscriptionId > 0 ? 1 : 0
            
            parameters = ["isUpdate": isUpdate, "subscription_id": subscriptionId, "user_id": userId, "product_id": productId, "start_date": startDate, "type": "Daily", "quantity": quanity, "subscription_type": subscriptionType, "delivery_frequency": deliveryFrequency, "alternate": alternateDaySelected,  "is_ring_bell": ringBell, "nice_to_have_req": request]
            
            if let promocode = promoTextField.text {
                if promocode.count > 0 {
                    parameters!["promo_code"] = promocode
                }
            }

            
            if deliveryFrequency == DeliveryFrequency.custom.rawValue { //custom
                weekDaysView.daysDict.forEach { (arg) in
                    parameters![arg.key] = arg.value
                }
            }
        }
        
        return parameters
    }
    
    
    fileprivate func getSingleOrderParameters() -> [String : Any]? {
        
        var parameters: [String: Any]?
        
        if let productDict = productSubDetailsDict, let productId = productDict["productId"] as? Int, let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            let startDate = productDict["startDate"] as! String
            let quanity =   productDict["quantity"] as! Int
            let subscriptionType = productDict["subscriptionType"] as! String
            let deliveryFrequency = productDict["deliveryFrequency"] as! Int
            let alternateDaySelected = productDict["alternateDaySelected"] as! Int
            let ringBell = productDict["ringBell"] as! Int
            
            let request = productDict["nice_to_have_req"] as! String
            //type will be One Time or Daily ( for milk product  always Daily and for other products One Time)
            //
            //"promo_code": "",
            let subscriptionId = productDict["subscriptionId"] as! Int
            let isUpdate = subscriptionId > 0 ? 1 : 0
            //type will be One Time or Daily ( for milk product  always Daily and for other products One Time)
            //
            
       //     parameters = ["isUpdate": 0, "subscription_id": 0, "user_id": userId, "product_id": productId, "start_date": startDate, "type": "One Time", "quantity": quanity, "nice_to_have_req": request, "subscription_type": "Postpaid"]
            
            parameters = ["isUpdate": isUpdate, "subscription_id": 0, "user_id": userId, "product_id": productId, "start_date": startDate, "type": "One Time", "quantity": quanity, "subscription_type": "Cash On Delivery", "delivery_frequency": deliveryFrequency, "alternate": alternateDaySelected,  "is_ring_bell": ringBell, "nice_to_have_req": request]

            
        }
        
        return parameters
    }
}

//MARK:- UITextFieldDelegate
extension SubscriptionSummaryViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        textField.addDoneButtonOnKeyboard()
        return true
    }
}

//MARK:- Keyboard observers
extension SubscriptionSummaryViewController {
    
    func keyboardWillShow(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0

        UIView.animate(withDuration: duration, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -120)
        })
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        UIView.animate(withDuration: duration, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: 120)
        })
    }
}

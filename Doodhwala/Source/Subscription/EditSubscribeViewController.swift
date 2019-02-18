//
//  EditSubscribeViewController.swift
//  Doodhwala
//
//  Created by Rajinder Paul on 20/03/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol SubscriptionProtocol {
    
    func reloadData()
    func showChangeQuantityViewFor(productDict: [String: Any]?)

}

class EditSubscribeViewController: UIViewController {
    
    var viewToShow = "subscribe" //other values can be changequantity, unsubscribe
    var delegate: SubscriptionProtocol?
    var editForDate: Date?
    var disableView = false
    
    //SubscribeView
    @IBOutlet weak var subscribeView: UIView!
    @IBOutlet weak var subscribeStartDateTextField: UITextField!
    @IBOutlet weak var subscribeQuantityLabel: UILabel!
    @IBOutlet weak var subscribeSubmitButton: UIButton!
    
    
    //UnsubscribeView
    @IBOutlet weak var unsubscribeView: UIView!
    @IBOutlet weak var unsubscribeTitleLabel: UILabel!
    @IBOutlet weak var changeQuantityButton: UIButton!
    @IBOutlet weak var unsubscribeButton: UIButton!
    @IBOutlet weak var unsubscribeTopConstraint: NSLayoutConstraint!
    
    
    
    //Change Quantity View
    @IBOutlet weak var changeQuantityView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var changeQuantityLabel: UILabel!
    @IBOutlet weak var deliveryStatusLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!

    @IBOutlet weak var changeQuantitySubmitButton: UIButton!
    @IBOutlet weak var changeQuantityViewTopConstraint: NSLayoutConstraint!
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    var datePicker: UIDatePicker!
    
    var productDict: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView() {
        
        self.view.layer.cornerRadius = 16
        
        if viewToShow.lowercased() == "subscribe" {
            
            changeQuantityView.removeFromSuperview()
            unsubscribeView.removeFromSuperview()
            
            subscribeSubmitButton.layer.cornerRadius = 8
            
            setStartDate(date: Date())
            
        } else if viewToShow.lowercased() == "unsubscribe" {
            
            changeQuantityView.removeFromSuperview()
            subscribeView.removeFromSuperview()
            self.unsubscribeTopConstraint.constant = 0

            self.unsubscribeButton.layer.cornerRadius = 8
            self.changeQuantityButton.layer.cornerRadius = 8
            
            if let productName = productDict?["product_name"] as? String {
                unsubscribeTitleLabel.text = productName
            }
        } else if viewToShow.lowercased() == "changequantity"{
            //Change quantity View
            subscribeView.removeFromSuperview()
            unsubscribeView.removeFromSuperview()

            if disableView {
                self.changeQuantityView.backgroundColor = UIColor.extraLightGray
                minusButton.alpha = 0
                plusButton.alpha = 0
            }
            
            self.changeQuantityViewTopConstraint.constant = 0
            changeQuantitySubmitButton.layer.cornerRadius = 8

            if let date = self.editForDate {
                dateLabel.text = self.formatter.string(from: date)
            }
            if let value = productDict?["product_name"] as? String {
                productNameLabel.text = value
            }
            if let value = productDict?["quantity"] as? Int {
                changeQuantityLabel.text = "\(value)"
                if disableView {
                    changeQuantityLabel.text = changeQuantityLabel.text! + " Ltr"
                }
            }
            if let value = productDict?["delivery_status"] as? String {
                deliveryStatusLabel.text = value
            }
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
    @IBAction func addAction(_ sender: UIButton) {
        
        if viewToShow == "Subscribe" {
            
            if let quantity = Int(subscribeQuantityLabel.text!) {
                
                subscribeQuantityLabel.text = "\(quantity + 1)"
            }
        } else  if viewToShow == "changequantity" {
            
            if let quantity = Int(changeQuantityLabel.text!) {
                
                changeQuantityLabel.text = "\(quantity + 1)"
            }
        }
    }
    
    @IBAction func minusAction(_ sender: UIButton) {
        
        if viewToShow == "Subscribe" {
            if let quantity = Int(subscribeQuantityLabel.text!) {
                
                if quantity > 1 {
                    subscribeQuantityLabel.text = "\(quantity - 1)"
                }
            }
        } else if viewToShow == "changequantity" {
            if let quantity = Int(changeQuantityLabel.text!) {
                
                if quantity > 1 {
                    changeQuantityLabel.text = "\(quantity - 1)"
                }
            }
        }
    }
}

//MARK:- Subscribe methods
extension EditSubscribeViewController {
    
    @IBAction func subscribeAction(_ sender: UIButton) {

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        if let productDict = productDict, let productId = productDict["product_id"] as? Int, let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            APIManager.defaultManager.subscribeProduct(parameters: ["user_id": "\(userId)", "product_id": "\(productId)", "quantity": self.subscribeQuantityLabel.text!, "start_date": self.subscribeStartDateTextField.text!, "type": "One Time"]) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess

                            print("SUCCESS")
                            let alert = UIAlertController(title: "SUCCESS", message: "Subscription is successful.", preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.dismiss(animated: true, completion: {
                                   
                                    self.delegate?.reloadData()
                                })
                            })
                            alert.addAction(okAction)
                            
                            self.present(alert, animated: true, completion: nil)

                        } else {
                            //Failure handle errors
                            
                            if let message = responseDict["msg"] as? String {
                                
                                let alert = UIAlertController(title: "ERROR!", message: message, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func dateAction(_ sender: UIButton) {

        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donedatePicker))
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.dismissDatePicker))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        subscribeStartDateTextField.isUserInteractionEnabled = true
        // add toolbar to textField
        subscribeStartDateTextField.inputAccessoryView = toolbar
        // add datepicker to textField
        subscribeStartDateTextField.inputView = datePicker
        
        
        subscribeStartDateTextField.becomeFirstResponder()
    }
    
    fileprivate func setStartDate(date: Date) {
        
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        subscribeStartDateTextField.text = formatter.string(from: date)

    }
    
    func donedatePicker(){

        setStartDate(date: datePicker.date)
        dismissDatePicker()
    }
    
    func dismissDatePicker(){
        
        subscribeStartDateTextField.inputAccessoryView = nil
        subscribeStartDateTextField.inputView = nil
        subscribeStartDateTextField.isUserInteractionEnabled = false

        self.view.endEditing(true)
    }
}


//MARK:- UnSubscribe methods
extension EditSubscribeViewController {
    
    @IBAction func unsubscribeAction(_ sender: UIButton) {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        if let productDict = productDict, let subscriptionId = productDict["subscription_id"] as? String {
            
            APIManager.defaultManager.unsubscribeProduct(parameters: ["subscription_id": subscriptionId]) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess
                            print("SUCCESS")

                            let alert = UIAlertController(title: "SUCCESS", message: "Product is unsubscribed.", preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                
                                self.dismiss(animated: true, completion: {
                                    self.delegate?.reloadData()
                                })
                            })
                            alert.addAction(okAction)
                            
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            //Failure handle errors
                            
                            if let message = responseDict["msg"] as? String {
                                
                                let alert = UIAlertController(title: "ERROR!", message: message, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                    }
                }
            }
        }
    }
}

//ChangeQuantity methods
extension EditSubscribeViewController {

    @IBAction func changeQuantityAction(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            
            self.delegate?.showChangeQuantityViewFor(productDict: self.productDict)
        }
    }
    
    @IBAction func submitChangeQuantityAction(_ sender: UIButton) {
        
        if disableView {
            
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if let productDict = productDict, let subscriptionId = productDict["subscription_id"] as? Int, let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            if let originalQuantity = productDict["quantity"] as? Int {
                
                if originalQuantity == Int(self.changeQuantityLabel.text!)! {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
            }
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Please wait..."
            

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let startDate = formatter.string(from: self.editForDate!)
            
            let subscriptionsDictArray = [["id": subscriptionId, "quantity": Int(self.changeQuantityLabel.text!)!]]
            
            var subscriptionsString = ""
            if let jsonData = try? JSONSerialization.data(withJSONObject: subscriptionsDictArray, options: []) {
                
                if let value = String(data: jsonData, encoding: .utf8) {
                    subscriptionsString = value
                }
            }

            
            let parameters = ["user_id": "\(userId)", "start_date": startDate, "subscriptions": subscriptionsString] as [String : Any]
            
            
            APIManager.defaultManager.requestJSON(apiRouter: .updateSubscription(parameters)) { (responseDict) in

                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess
                            
                            print("SUCCESS")
                            let alert = UIAlertController(title: "SUCCESS", message: "Subscription has been updated successfully.", preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.dismiss(animated: true, completion: {
                                    
                                    self.dismiss(animated: true, completion: nil)
                                })
                            })
                            alert.addAction(okAction)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            //Failure handle errors
                            
                            if let message = responseDict["msg"] as? String {
                                
                                let alert = UIAlertController(title: "ERROR!", message: message, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                    }
                }
            }
        }
    }

}

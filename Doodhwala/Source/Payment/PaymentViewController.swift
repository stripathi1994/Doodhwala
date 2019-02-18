//
//  PaymentViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 8/4/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit
import PaymentSDK

class PaymentViewController: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var pendingDuesLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var bottleCollectionButton: UIButton!
    @IBOutlet weak var bottleCollectionUnderline: UIView!

    var rechargeAmount = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        getPendingDues()
        
        DispatchQueue.main.async {
            self.setupView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setupView() {
        
        self.setTitleView()
        amountTextField.addDoneButtonOnKeyboard()
        
        submitButton.layer.cornerRadius = 8
        pendingDuesLabel.layer.cornerRadius = pendingDuesLabel.frame.size.width / 2
    }
    
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        
        if let amountString = self.amountTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) {
            
            guard let amount = Double(amountString) else {
                
                showAlert(message: "Please enter valid amount.")
                return
            }
            
            if amount > 0.0 {
                generateChecksum()
            } else {
                showAlert(message: "Please enter valid amount.")
            }
        }
    }
    
    @IBAction func paymentCollectionAction() {
    
        showMessage(requestType: "Payment Collection")
    }

    @IBAction func bottleCollectionAction() {
        
        showMessage(requestType: "Bottle Collection")
    }

    fileprivate func showMessage(requestType: String) {
        
        let message = "Do you want to request for " + requestType + "?"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
            
            self.sendEmailRequest(requestType: requestType)
        }
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func sendEmailRequest(requestType: String) {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        
        let parameters = ["user_id": userId, "collection_type": requestType, "date": date] as [String : Any]
        
        APIManager.defaultManager.requestJSON(apiRouter: .emailRequest(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for succes, 000001 for failure
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //An OTP has been sent. Show the OTP View
                        if let message = responseDict["msg"] as? String {
                            self.showAlert(message: message)
                        }
                        
                    } else  {
                        //Failure handle errors
                        if let message = responseDict["msg"] as? String {
                            self.showAlert(message: message)
                        }
                    }
                }
                
            } else {
                print("Something went wrong. Please try again")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let controller = segue.destination as? AccountHistoryViewController {
            controller.canGoback = true
        }
    }
}

//MARK: - API methods
extension PaymentViewController {

    fileprivate func getPendingDues() {
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Please wait..."

            APIManager.defaultManager.requestJSON(apiRouter: .getAccountDetails(["user_id": userId])) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)

                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess
                            
                            if var amount = responseDict["pending_amount"] as? Double {
                                //-negative valu means cistomer has advance deposited
                                if amount > 0.0 {
                                    self.headerLabel.text = "Pending Dues"
                                } else {
                                    amount = abs(amount)
                                    self.headerLabel.text = "Wallet Balance"
                                }
                                
                                self.pendingDuesLabel.text = "₹ " + "\(amount)"
                                self.amountTextField.text = ""
                            }
                            
                        } else {
                            //Failure handle errors
                            
                            if let message = responseDict["msg"] as? String {
                                
                                print("ERROR: - \(message)")
                            }
                        }
                    }
                }
                
                self.collectBottles()
                
                
                if self.rechargeAmount > 0.0 {
                    self.amountTextField.text = "\(Int(self.rechargeAmount))"
                }
            }
        }
    }
    
    fileprivate func generateChecksum() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        let mobileNumber = UserManager.defaultManager.userDict?["user_mobile"] as! String
        let email = "doodhvale@gmail.com"
        let orderId = "DVTXP" + "\(10000 + arc4random_uniform(UInt32.max - 10001))"
        
        let parameters = ["ORDER_ID": orderId, "CUST_ID": userId, "TXN_AMOUNT": amountTextField.text!, "MOBILE_NO": mobileNumber, "EMAIL": email] as [String : Any]
        
        APIManager.defaultManager.requestJSON(apiRouter: .generateChecksum(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        
                        self.showPaytmTransactionController(responseDict: responseDict)
                        
                        
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
    
    fileprivate func verifyTransaction(responseString: String) {
        
        if let data = responseString.data(using: String.Encoding.utf8) {
            
            do {
            
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                    let userId = UserManager.defaultManager.userDict?["user_id"] as? Int

                    guard let trxId = dictionary["TXNID"] as? String else {
                        return
                    }
                    guard let amountString = dictionary["TXNAMOUNT"] as? String else {
                        return
                    }
                    guard let orderId = dictionary["ORDERID"] as? String else {
                        return
                    }
                    guard let amount = Double(amountString) else {
                        return
                    }
                    
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.label.text = "Please wait..."
                    
                    let parameters = ["ORDER_ID": orderId, "TXNAMOUNT":amount, "TXNID": trxId, "CUST_ID": userId, "Response": responseString] as [String : Any]
                    
                    print("parameters.....\(parameters)")
                    APIManager.defaultManager.requestJSON(apiRouter: .verifyTransaction(parameters)) { (responseDict) in
                        
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        if let responseDict = responseDict {
                            //check for status 000000 for success
                            
                            if let status = responseDict["status"] as? String {
                                
                                if status == "000000" {
                                    //Succcess
                                    if let message = responseDict["msg"] as? String {
                                        
                                        self.showAlert(message: message)
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
                
                
            } catch let  error as NSError {
                print(error)

            }
            
        }
    }
    
    
    fileprivate func collectBottles() {
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Please wait..."
            
            APIManager.defaultManager.requestJSON(apiRouter: .collectBottles(["customer_id": userId])) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {

                        if status == "000000" {
                            //Succcess
                            
                            if var bottleDetails = responseDict["bottle_details"] as? [String: Any] {

                                if let pendingBottles = bottleDetails["pending_bottle"] as? Int {
                                    
                                    if pendingBottles > 0 {

                                        self.bottleCollectionButton.setTitle("Request for Empty Bottle Collection(\(pendingBottles)) ?", for: .normal)
                                        self.bottleCollectionButton.isHidden = false
                                        self.bottleCollectionUnderline.isHidden = false
                                    }
                                }

                            }
                            
                        }
                    }
                }
            }
        }
    }
}


//MARK:- Paytm integration methods
extension PaymentViewController {
    
    fileprivate func showPaytmTransactionController(responseDict: [String: Any]) {
        
        var checkSum = ""
        if let value = responseDict["checkSum"] as? String {
            checkSum = value
        }
        
        if var responseDict = responseDict["post_value"] as? [String: Any]  {
            
            self.setMerchantConfiguration(dict: responseDict)
            
            let orderId = responseDict["ORDER_ID"] as! String
            let customerId = responseDict["CUST_ID"] as! String
            let amount = responseDict["TXN_AMOUNT"] as! String
            let email = responseDict["EMAIL"] as! String
            let mobile = responseDict["MOBILE_NO"] as! String
            responseDict.updateValue(checkSum, forKey: "CHECKSUMHASH")
            
            let pgOrder = PGOrder.init(orderID: orderId, customerID: customerId, amount: amount, eMail: email, mobile: mobile)
            
            pgOrder.params = responseDict
            
            if let orderDict = pgOrder.params as? Dictionary<String, String> {
                
                //let orderParameters = pgOrder.orderWithParams(dic: orderDict)
                
                let transactionController =  PGTransactionViewController(transactionParameters: orderDict)
                _ = transactionController.initTransaction(for: pgOrder)
                transactionController.serverType = ServerType.eServerTypeProduction
                transactionController.merchant = PGMerchantConfiguration.defaultConfiguration()
                
                transactionController.delegate = self
                
                self.navigationController?.pushViewController(transactionController, animated: true)
            }
            
        }
    }
    

    fileprivate func setMerchantConfiguration(dict: [String: Any]) {
        
        let merchantConfiguration = PGMerchantConfiguration.defaultConfiguration()
        
        if let value = dict["MID"] as? String {
            merchantConfiguration.merchantID = value
        }
        if let value = dict["CHANNEL_ID"] as? String {
            merchantConfiguration.channelID = value
        }
        if let value = dict["INDUSTRY_TYPE_ID"] as? String {
            merchantConfiguration.industryID = value
        }
        if let value = dict["WEBSITE"] as? String {
            merchantConfiguration.website = value
        }
    }

}

extension PaymentViewController: PGTransactionDelegate {
    
    func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
        
        controller.navigationController?.popViewController(animated: true)
        
        self.verifyTransaction(responseString: responseString)
        
        debugPrint(responseString)
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController) {
        
        controller.navigationController?.popViewController(animated: true)
        self.showAlert(message: "Transaction Canceled")
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController, error: NSError?) {
        controller.navigationController?.popViewController(animated: true)
        debugPrint(error?.localizedDescription)
    }
    
    
}

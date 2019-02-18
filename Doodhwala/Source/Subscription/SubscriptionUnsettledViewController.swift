//
//  SubscriptionUnsettledViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 8/31/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class SubscriptionUnsettledViewController: UIViewController {

    @IBOutlet weak var amountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.amountLabel.text = "₹ 0"
        getPendingDues()
        self.setTitleView()
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

    @IBAction func requestPaymentAction(_ sender: Any) {
        
        showMessage(requestType: "Payment Collection")
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
    
    
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func paymentAction(_ sender: Any) {
        
        if let controller = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

//MARK: - API methods
extension SubscriptionUnsettledViewController {
    
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
                                
                                if amount < 0.0 {
                                    amount = 0
                                }
                                
                                self.amountLabel.text = "₹ " + "\(amount)"
                            }
                            
                        } else {
                            //Failure handle errors
                            
                            if let message = responseDict["msg"] as? String {
                                
                                print("ERROR: - \(message)")
                            }
                        }
                    }
                }
            }
        }
}
}

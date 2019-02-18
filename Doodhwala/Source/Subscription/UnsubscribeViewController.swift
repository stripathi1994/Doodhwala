//
//  UnsubscribeViewController.swift
//  Doodhvale
//
//  Created by apple on 20/07/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class UnsubscribeViewController: UIViewController {

    var subscriptionId: Int!
    var productId: Int!
    
    var feedbackDictArray  = [[String: Any]]()
    @IBOutlet weak var feedbackTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        feedbackTableView.estimatedRowHeight = 50
        feedbackTableView.rowHeight = UITableViewAutomaticDimension
        self.setTitleView()
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadData() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            let parameters = ["user_id": userId]
            
            APIManager.defaultManager.requestJSON(apiRouter: .getFeedbackReasons(parameters)) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    if let status = responseDict["status"] as? String {
                        if status == "000000" {
                            //Succcess
                            if let responseDict = responseDict["feedbacklist"] as? [[String: Any]] {
                                self.feedbackDictArray = responseDict
                                self.feedbackTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func updateButtonAction(_ sender: UIButton) {

        submitFeedback()
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

//MARK:- REST API methods
extension UnsubscribeViewController {

    func submitFeedback() {
        
        guard let indexPath = feedbackTableView.indexPathForSelectedRow else {
            showAlert(message: "Please select reason for cancellation.")
            return
        }

        let feedbackId = feedbackDictArray[indexPath.row]["id"] as? Int
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        let parameters = ["user_id": userId, "product_id": productId, "sub_id": subscriptionId, "feedback": feedbackId]
        APIManager.defaultManager.requestJSON(apiRouter: .submitFeedback(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        print("SUCCESS")
                       
                        self.unsubscribeProduct()
                        
                    } else if let message = responseDict["msg"] as? String {
                        //Failure handle errors
                        self.showAlert(message: message)
                    }
                }
            }
        }
    }
    
    
    func unsubscribeProduct() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let parameters = ["subscription_id": subscriptionId]
        APIManager.defaultManager.requestJSON(apiRouter: .unsubscribe(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        print("SUCCESS")
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "subscriptionUpdated")))
                        
                        //var message = "Product is unsubscribed."
//                        if let value = responseDict["msg"] as? String {
//                            message = value
//                        }
                        
                        if let viewControllers = self.navigationController?.viewControllers {
                            
                            if viewControllers.count > 2 {
                               
                               let controller =  viewControllers[viewControllers.count - 3]
                                self.navigationController?.popToViewController(controller, animated: true)
                                controller.showAlert(message: "Product is unsubscribed.")
                            }
                        }
                        
                        
                    } else if let message = responseDict["msg"] as? String {
                        //Failure handle errors
                        self.showAlert(message: message)
                    }
                }
            }
        }
    }
}


//MARK: TableView delegate and datasource
extension UnsubscribeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feedbackDictArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReasonTableViewCell", for: indexPath) as! ReasonTableViewCell

        if let reasonText = feedbackDictArray[indexPath.row]["value"] as? String {
            cell.reasonLabel.text = reasonText
        }
        
        /*
         {
         "created_at" = 1527240398;
         "created_by" = "<null>";
         id = 5;
         reason = "Problem in delivery service.";
         "updated_at" = 1527879261;
         "updated_by" = "<null>";
         value = Other;
         }
         );
         */

        return cell        
    }
}

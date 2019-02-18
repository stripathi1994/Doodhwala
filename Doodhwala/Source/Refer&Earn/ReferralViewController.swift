//
//  ReferralViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 9/8/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class ReferralViewController: UIViewController, UIActivityItemSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var redeemPointsLabel: UILabel!
    @IBOutlet weak var balancePointsLabel: UILabel!
    
    var messageToBeShared = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setTitleView()
        MenuViewController.configureMenu(button: menuButton, controller: self)
        
        self.headerLabel.text = ""
        self.descriptionLabel.text = ""
        
        getReferralDescription()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func urlButtonAction(_ sender: UIButton) {
        
        var currentTitle = sender.currentTitle!
        if !currentTitle.contains("http:") {
            currentTitle = "http://" + currentTitle
        }
        if let url = URL(string: currentTitle) {
            if #available(iOS 10, *){
                UIApplication.shared.open(url)
            }else{
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
     
        getReferralShareMessage()
    }
    
    fileprivate func shareMessage(message: String) {
        
        messageToBeShared = message
        let activityViewController = UIActivityViewController(activityItems: [self] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return messageToBeShared
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        return messageToBeShared
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "Doodhvale.com - Farm Fresh Milk Service"
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


//MARK:- REST API metods
extension ReferralViewController {
    
    func getReferralDescription() {
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Please wait..."
            
            APIManager.defaultManager.requestJSON(apiRouter: .getreferralDescription(["user_id": userId])) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)

                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess
                            
                            if let value = responseDict["header"] as? String {
                                self.headerLabel.text = value
                            }

                            if let value = responseDict["description"] as? String {
                                self.descriptionLabel.text = value
                            }

                            if let value = responseDict["tc_url"] as? String {
                                self.urlButton.setTitle(value, for: .normal)
                            }

                            if let value = responseDict["total-earned-point"] as? Int {
                                self.pointsLabel.text = "\(value)"
                            }

                            if let value = responseDict["total-redeemed-point"] as? Int {
                                self.redeemPointsLabel.text = "\(value)"
                            }

                            if let value = responseDict["balance-earned-point"] as? Int {
                                self.balancePointsLabel.text = "\(value)"
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
    
    func getReferralShareMessage() {
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Please wait..."
            
            APIManager.defaultManager.requestJSON(apiRouter: .getreferralShareMessage(["user_id": userId])) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess
                            
                            if let message = responseDict["msg_to_share"] as? String {
                                self.shareMessage(message: message)
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
}

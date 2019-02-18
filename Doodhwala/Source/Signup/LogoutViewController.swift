//
//  LogoutViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 9/3/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class LogoutViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setTitleView()
        MenuViewController.configureMenu(button: menuButton, controller: self)

        if let userprofileDict = UserManager.defaultManager.userProfileDict {
            
            if let userProfile = userprofileDict["user_details"] as? [String: Any] {
                
                if let value = userProfile["first_name"] as? String {
                    nameLabel.text = value
                }
                if let value = userProfile["last_name"] as? String {
                    nameLabel.text = nameLabel.text! + " " + value
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutAction(_ sender: UIButton) {
        logoutUser()
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

//MARK:- REST APIs
extension LogoutViewController {
    
    fileprivate func logoutUser() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            APIManager.defaultManager.requestJSON(apiRouter: .logout("\(userId)")) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for succes, 000001 for failure
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            print("use unregistered successfully")
                            let revealViewControler = self.revealViewController()
                            revealViewControler?.dismiss(animated: true, completion: nil)
                            
                        } else if status == "000001" {
                            var message = "Something went wrong. Please try again."
                            if let value = responseDict["msg"] as? String {
                                message = value
                            }
                            self.showAlert(message: message)
                        }
                        
                    }
                    
                }
            }
        }
    }
}

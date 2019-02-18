//
//  FeedbackViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 9/3/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit
import Cosmos

class FeedbackViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var qualityRatingView: CosmosView!
    @IBOutlet weak var serviceRatingView: CosmosView!
    @IBOutlet weak var suggestionsLabel: UILabel!
    @IBOutlet weak var suggestionsTextView: UITextView!
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setTitleView()
        MenuViewController.configureMenu(button: menuButton, controller: self)
        
        qualityRatingView.rating = 0
        serviceRatingView.rating = 0
        
        suggestionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        suggestionsTextView.layer.borderWidth = 1
        
        suggestionsTextView.addDoneButtonOnKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

        suggestionsTextView.text = ""
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func submitAction(_ sender: UIButton) {
    
        suggestionsTextView.resignFirstResponder()

        if qualityRatingView.rating == 0.0 {
            
            self.showAlert(message: "Please select quality rating.")
            return
        }

        if serviceRatingView.rating == 0.0 {
            
            self.showAlert(message: "Please select service rating.")
            return
        }
        
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        let parameters = ["user_id": userId, "quality": qualityRatingView.rating, "service": serviceRatingView.rating, "suggestion": suggestionsTextView.text] as [String : Any]
        
        APIManager.defaultManager.requestJSON(apiRouter: .serviceFeedback(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        print("SUCCESS")
                        if let menuController = self.revealViewController()?.rearViewController as? MenuViewController {
                            
                            menuController.tableView(menuController.menuTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
                        }
                        
                    } else if let message = responseDict["msg"] as? String {
                        //Failure handle errors
                        self.showAlert(message: message)
                    }
                }
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

}


//MARK:- Keyboard observers
extension FeedbackViewController {
    
    func keyboardWillShow(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        UIView.animate(withDuration: duration, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -(self.suggestionsLabel.frame.origin.y - 64))
            self.submitButtonBottomConstraint.constant = 95
        })
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        UIView.animate(withDuration: duration, animations: {
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.submitButtonBottomConstraint.constant = 0

        })
    }
}

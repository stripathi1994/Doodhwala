//
//  InsufficientViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 9/6/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class InsufficientViewController: UIViewController {

    @IBOutlet weak var rechargeButton: UIButton!
    @IBOutlet weak var insuffMessageLabel: UILabel!

    @IBOutlet weak var insufficientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!

    var insufficientFundsTimer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rechargeButton.layer.cornerRadius = 4
        
        insufficientViewHeightConstraint.constant = 0
        

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getPrepaidPaymentReminder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func blinkView() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            if self.rechargeButton.alpha == 0 {
                self.rechargeButton.alpha = 1
            } else {
                self.rechargeButton.alpha = 0
            }

        }, completion: nil)
    }
    
    func showInSufficientView(show: Bool) {
        
        if show {
            insufficientViewHeightConstraint.constant = 50
            if insufficientFundsTimer == nil {
                insufficientFundsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(blinkView), userInfo: nil, repeats: true)
            }
        } else {
            insufficientViewHeightConstraint.constant = 0
            
            if insufficientFundsTimer != nil {
                insufficientFundsTimer.invalidate()
                insufficientFundsTimer = nil
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            if self.collectionView != nil {
                self.collectionView.reloadData()
            }
        }

    }

    @IBAction func rechargeAction() {
    
        if let controller = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
            navigationController?.pushViewController(controller, animated: true)
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


//MARK:- API Methods
extension InsufficientViewController {
    
    fileprivate func getPrepaidPaymentReminder() {
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            APIManager.defaultManager.requestJSON(apiRouter: .prepaidPaymentReminder(["user_id": userId])) { (responseDict) in
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess
                            if let message = responseDict["balance_amt"] as? String {
                                
                                self.showInSufficientView(show: true)
                                self.insuffMessageLabel.text = message

                            } else {
                                self.showInSufficientView(show: false)
                            }
                        }
                    }
                }
            }
        }
    }
}

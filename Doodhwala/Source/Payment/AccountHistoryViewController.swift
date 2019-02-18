//
//  AccountHistoryViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 8/28/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class AccountHistoryViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet weak var pendingAmountLabel: UILabel!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var canGoback = false
    
    var dataHistory: [[String: Any]]? {
        
        didSet {

            if tableView != nil {

                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setTitleView()

        if canGoback {
            self.navigationItem.leftBarButtonItem = nil
        } else {
            MenuViewController.configureMenu(button: menuButton, controller: self)
        }

        getAccountDetails()
        //"₹"
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

}


//MARK: - API methods
extension AccountHistoryViewController {
    
    fileprivate func getAccountDetails() {
        
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
                               
                                if amount > 0 {
                                    amount = 0
                                } else {
                                    amount = abs(amount) //-negative valu means cistomer has advance deposited
                                }
                                self.walletBalanceLabel.text = "₹ " + "\(amount)"
                            }
                            if let amount = responseDict["bill_amount"] as? Double {
                                self.pendingAmountLabel.text = "₹ " + "\(amount)"
                            }

                            if let list = responseDict["account_list"] as? [[String: Any]] {
                                self.dataHistory = list
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


//MARK: TableView delegate and datasource
extension AccountHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        if let value = dataHistory?.count {
            count = value
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        
        cell.configureCell(data: dataHistory![indexPath.row],row: indexPath.row,totalRows: dataHistory!.count)
        
        return cell
    }
    
}


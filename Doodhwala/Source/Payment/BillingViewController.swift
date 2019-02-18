//
//  BillingViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 8/28/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class BillingViewController: InsufficientViewController {

    @IBOutlet weak var tableView: UITableView!

    var billingDataArray: [[String: Any]]? {
        
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

        getBillingDetails()
        //"₹"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func viewDetailsAction(_ sender: UIButton) {
        
        if let controller = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "BillingDetailsViewController") as? BillingDetailsViewController {
            
            if let indexPath = tableView.getTableIndexPathFromCellSubView(subView: sender) {
            
                controller.billingDetailsDict = billingDataArray![indexPath.row]
                navigationController?.pushViewController(controller, animated: true)
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


//MARK: - API methods
extension BillingViewController {
    
    fileprivate func getBillingDetails() {

        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {

            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Please wait..."

            APIManager.defaultManager.requestJSON(apiRouter: .billingDetails(["user_id": userId])) { (responseDict) in

                MBProgressHUD.hide(for: self.view, animated: true)

                if let responseDict = responseDict {
                    //check for status 000000 for success

                    if let status = responseDict["status"] as? String {

                        if status == "000000" {
                            //Succcess
                            var showNoRecordMessage = true
                            if let list = responseDict["bill_list"] as? [[String: Any]] {
                                self.billingDataArray = list
                                if list.count > 0 {
                                    showNoRecordMessage = false
                                }
                            }
                            
                            if showNoRecordMessage {
                                self.showAlert(message: "No bill generated yet.")
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
extension BillingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        if let value = billingDataArray?.count {
            count = value
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillingTableViewCell", for: indexPath) as! BillingTableViewCell
        
        cell.configureCell(data: billingDataArray![indexPath.row],row: indexPath.row,totalRows: billingDataArray!.count)
        
        return cell
    }
    
}



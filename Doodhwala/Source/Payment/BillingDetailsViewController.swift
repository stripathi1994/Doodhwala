//
//  BillingDetailsViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 9/2/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class BillingDetailsViewController: InsufficientViewController {

    @IBOutlet weak var billDurationLabel: UILabel!
    @IBOutlet weak var billNumberLabel: UILabel!
    @IBOutlet weak var billDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var subtotalRows: Int {
        
        if let brokenBottleCount = billingDetailsDict["broken_bottle"] as? Int {
            if brokenBottleCount > 0 {
                return 4
            }
        }
        
        return 3
    }
    
    var billingDetailsDict: [String: Any]!
    
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
        
        self.setTitleView()

        if let value = billingDetailsDict["bill_no"] as? Int {
            billNumberLabel.text = ": \(value)"
        }
        if let value = billingDetailsDict["bill_cycle"] as? String {
            billDurationLabel.text = ":" + value
        }
        if let value = billingDetailsDict["billing_gen_date"] as? String {
            
            billDateLabel.text = ":" + value.components(separatedBy: " ")[0]
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


//MARK: TableView delegate and datasource
extension BillingDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = subtotalRows
        
        if let valueArray = billingDetailsDict["billing_detail"] as? [[String: Any]] {
            count = count + valueArray.count
        }

        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tableViewCell: UITableViewCell!
        var identifier: String! = "BillingDetailsTableViewCell"
        var data: [String: Any]!
        if let valueArray = billingDetailsDict["billing_detail"] as? [[String: Any]] {
            
            if indexPath.row >= valueArray.count {
                identifier = "BillingDetailsTotalCell"
                data = billingDetailsDict
            } else {
                identifier = "BillingDetailsTableViewCell"
                data = valueArray[indexPath.row]

            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BillingDetailsTableViewCell
            
            tableViewCell = cell
            

            var brokenBottleInfo = (count: 0, price: 0.0)
            if let brokenBottleCount = billingDetailsDict["broken_bottle"] as? Int {
                if brokenBottleCount > 0 {
                    brokenBottleInfo.count = brokenBottleCount
                    if let price = billingDetailsDict["broken_bottle_charge"] as? Double {
                        brokenBottleInfo.price = price
                    }
                }
            }
            
            cell.configureCell(data: data, row: indexPath.row,totalRows: valueArray.count, subTotalRows: subtotalRows,  brokenBottleInfo: brokenBottleInfo)
        }
        
        return tableViewCell
    }
    
    @IBAction func moreInfoButtonAction(_ sender: UIButton) {
        
        if let controller = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "BottleDetailsViewController") as? BottleDetailsViewController {
            
            controller.billingDetailsDict = self.billingDetailsDict
            controller.modalPresentationStyle = .custom
            controller.modalTransitionStyle = .crossDissolve
            controller.transitioningDelegate = self

            self.present(controller, animated: true, completion: nil)

        }
    }

}


//MARK:- UIViewControllerTransitioningDelegate
extension BillingDetailsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let customPresentationController = CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
        
        let height: CGFloat = 250

        customPresentationController.presentedControllerSize = CGRect(x: 20, y: self.view.center.y - (height/2 + 64), width: self.view.frame.size.width - 40, height: height)

        
        return customPresentationController
    }
}

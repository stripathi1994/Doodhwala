//
//  ProductListViewController.swift
//  Doodhwala
//
//  Created by admin on 9/6/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProductListViewController: InsufficientViewController {

    @IBOutlet weak var productListView: UIView!
    @IBOutlet var productListTableView: UITableView!
    //@IBOutlet weak var menuButton: UIBarButtonItem!

    var selectedCategory: [String: Any]!
    
    var productList: [[String: Any]]? {
        
        didSet {
            
            if productListTableView != nil {
                productListTableView.reloadData()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpView()
        //loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        
        self.setTitleView()

        //applyPlainShadow(view: productListView)

        //MenuViewController.configureMenu(button: menuButton, controller: self)

        productListTableView.estimatedRowHeight = 130
        productListTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
//     func loadData() {
//
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.label.text = "Please wait..."
//
//        if let categoryId = selectedCategory["cat_id"] as? String, let catid = Int(categoryId) {
//
//            APIManager.defaultManager.getProducts(parameters: ["user_id": UserDetails.user.userId, "cat_id": catid]) { (responseDict) in
//
//                MBProgressHUD.hide(for: self.view, animated: true)
//
//                if let responseDict = responseDict {
//                    //check for status 000000 for success
//
//                    if let status = responseDict["status"] as? String {
//
//                        if status == "000000" {
//                            //Succcess
//
//                            if let response = responseDict["product_list"] as? [[String: Any]] {
//
//                                self.productList = response
//
//                                self.productListTableView.reloadData()
//                            }
//
//                        } else {
//                            //Failure handle errors
//
//                            if let message = responseDict["msg"] as? String {
//
//                                let alert = UIAlertController(title: "ERROR!", message: message, preferredStyle: .alert)
//
//                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//                                self.present(alert, animated: true, completion: nil)
//                            }
//
//                        }
//                    }
//                }
//            }
//        }
//    }
    
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
extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        
        if let productList = productList {
            
            count = productList.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        
        if let product = productList?[indexPath.row] {
            
            cell.configure(productDict: product)
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

//MARK:- SUBSCRIBE FEATURE and change quantity
extension ProductListViewController: SubscriptionProtocol {

    private func getSubscribeController() -> EditSubscribeViewController? {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditSubscribeViewController") as? EditSubscribeViewController {
            
            controller.delegate = self//need to change to protocl
            controller.modalPresentationStyle = .custom
            controller.transitioningDelegate = self
            controller.modalTransitionStyle = .crossDissolve
            
            return controller
        }
    
        return nil
    }
    
    @IBAction func subscribeAction(_ sender: UIButton) {
        
        if let indexPath = productListTableView.getTableIndexPathFromCellSubView(subView: sender) {
            
            if let selectedProductDict = productList?[indexPath.row],  let subscription = selectedProductDict["subscription"] as? String {
                if subscription.lowercased() == "unsettled"  {
                    
                    showPaymentViewController()
                } else {
                    
                    var controllerIdentifier = ""
                    if indexPath.row == 0 {
                        controllerIdentifier = "SubscriptionViewController"
                    } else {
                        controllerIdentifier = "SingleOrderSubscriptionViewController"
                    }

                    showSubscriptionController(selectedProductDict: selectedProductDict, controllerIdentifier: controllerIdentifier)
                }
            }
        }
    }
    
    private func showSubscriptionController(selectedProductDict: [String: Any], controllerIdentifier: String) {
        
       if let controller = UIStoryboard(name: "Subscription", bundle: nil).instantiateViewController(withIdentifier: controllerIdentifier) as? SubscriptionViewController {
            
            controller.selectedProductDict = selectedProductDict
            
            if controllerIdentifier == "SingleOrderSubscriptionViewController" {
                controller.subscriptionView = false
            }
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    private func showPaymentViewController() {
        
        if let controller = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    func reloadData() {
        //loadData()
    }

    func showChangeQuantityViewFor(productDict: [String: Any]?) {
        
        if let controller = getSubscribeController() {
            
            controller.productDict = productDict
            controller.viewToShow = "changequantity"
            self.present(controller, animated: true, completion: nil)
        }
    }
}

//MARK:- UIViewControllerTransitioningDelegate
extension ProductListViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let customPresentationController = CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
        
        if let controller = presented as? EditSubscribeViewController {
        
            var height: CGFloat = 200
            if controller.viewToShow.lowercased() == "subscribe"  {
                height = 200
            }
            else if controller.viewToShow.lowercased() == "unsubscribe" {
                height = 160
            }
            else if controller.viewToShow.lowercased() == "changequantity" {
                height = 224
            }
            

            customPresentationController.presentedControllerSize = CGRect(x: 20, y: self.view.center.y - (height/2 + 64), width: self.view.frame.size.width - 40, height: height)
        }

        return customPresentationController
    }
}

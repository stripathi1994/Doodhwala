//
//  FaqViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 9/3/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class FaqViewController: UIViewController {

    @IBOutlet weak var mainSubView: UIView!
    @IBOutlet weak var faqTableView: UITableView!

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var faqsList: [[String: Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mainSubView.addShadowAndRadius(cornerRadius: 5)
        self.setTitleView()
        MenuViewController.configureMenu(button: menuButton, controller: self)
        
        faqTableView.estimatedRowHeight = 100
        faqTableView.rowHeight = UITableViewAutomaticDimension
        
        loadFaqData()
        
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

extension FaqViewController {
    
    func loadFaqData() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."

        APIManager.defaultManager.requestJSON(apiRouter: .getFaqs()) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)

            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess

                        if let list = responseDict["faq_list"] as? [[String: Any]] {

                            self.faqsList = list
                            self.faqTableView.reloadData()
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


//MARK: TableView delegate and datasource
extension FaqViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        if let faqsList = self.faqsList {
            count = faqsList.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaqTableViewCell", for: indexPath) as! FaqTableViewCell
        
        cell.configureCell(data: self.faqsList![indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        var isSelected = false
        if let value = self.faqsList![indexPath.row]["isSelected"] as? Bool {
            isSelected = value
        }
        
        self.faqsList![indexPath.row].updateValue(!isSelected, forKey: "isSelected")
    
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
}


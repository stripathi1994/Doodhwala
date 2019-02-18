//
//  ManageMilkDeliveryViewController.swift
//  Doodhwala
//
//  Created by admin on 7/16/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class ManageMilkDeliveryViewController: InsufficientViewController {
    
    @IBOutlet var calendar: FSCalendar!
    //Data Properties
    var selectedProductDict: [String: Any]?
    var subscriptionStartDate: Date?
    
    var subscriptionsList: [[String: String]]?
    
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setTitleView()
       // MenuViewController.addMenuButton(forController: self)
        calendar.allowsMultipleSelection = true
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.today = nil
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadData() {
        
        if let stringValue = selectedProductDict?["subscription_id"] as? String, let subscriptionId = Int(stringValue) {

            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Please wait..."
            

            let parameters = ["subscription_id": subscriptionId]
            APIManager.defaultManager.requestJSON(apiRouter: .getSubscriptionDetails(parameters)) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    if let status = responseDict["status"] as? String {
                        if status == "000000" {
                            //Succcess
                            
                            if let responseDict = responseDict["edit_subscription"] as? [String: Any], let startDate = responseDict["start_date"] as? String {
                                
                                self.subscriptionStartDate = self.formatter.date(from: startDate)
                                self.calendar.reloadData()
                            }
                        }
                    }
                }
                
                self.getSubscripionsListData()

            }
        } else {
            self.getSubscripionsListData()
        }
    }
    
    fileprivate func getSubscripionsListData() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        let productId = selectedProductDict?["product_id"] as? Int
        
        var startDate = ""
        var endDate = ""
       
        if let date = calendar.currentPage.getPreviousMonth(bySubtracting: -1) {
            startDate = formatter.string(from: date)
        }

        if let date = calendar.currentPage.getNextMonth(byAdding: 2) {
            endDate = formatter.string(from: date)
        }

        let parameters = ["user_id": userId, "product_id": productId, "start_date": startDate, "end_date": endDate] as [String : Any]
        
        APIManager.defaultManager.requestJSON(apiRouter: .getSubscriptionsList(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                if let status = responseDict["status"] as? String {
                    if status == "000000" {
                        //Succcess
                        
                        if let pauseDatesList = responseDict["pause_list"] as? [[String: Any]] {

                            for pausedate in pauseDatesList {
                                
                                if let dateString = pausedate["end_date"] as? String, let date =  self.formatter.date(from: dateString){
                                    
                                    self.calendar.select(date, scrollToDate: false)
                               }
                                
                            }
                        }
                        
                        
                        if let list =  responseDict["subscription_list"] as? [[String: String]] {

                            self.subscriptionsList = list
                            self.calendar.reloadData()

//                            for pausedate in pauseDatesList {
//
//                                if let dateString = pausedate["end_date"] as? String, let date =  self.formatter.date(from: dateString){
//
//                                    self.calendar.select(date, scrollToDate: false)
//                                }
//
//                            }
                            
                        }
                        
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

// MARK:- FSCalendarDataSource
extension ManageMilkDeliveryViewController: FSCalendarDataSource {
    
//    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
//        return self.gregorian.isDateInToday(date) ? "今天" : nil
//    }
    
//    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
//        guard self.lunar else {
//            return nil
//        }
//        return self.lunarFormatter.string(from: date)
//    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {

        if let date = calendar.currentPage.getPreviousMonth(bySubtracting: -1) {
            return date
        }
        
        return calendar.currentPage
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        
        if let date = calendar.currentPage.getNextMonth(byAdding: 2) {
            return date
        }
        
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
       // let day: Int! = self.gregorian.component(.day, from: date)
        
        if let subscriptionDate = self.subscriptionStartDate {
            
            if subscriptionDate.compare(date) == .orderedDescending {
                
                var value = 0
                if let subscriptionsList = self.subscriptionsList {
                    
                    for dict in subscriptionsList {
                        
                        if let startDateStr = dict["start_date"],  let endDateStr = dict["end_date"] {

                            if let startDate = self.formatter.date(from: startDateStr),  let endDate = self.formatter.date(from: endDateStr) {
                                
                                if ((startDate.compare(date) == .orderedAscending) || (startDate.compare(date) == .orderedSame))
                                    &&
                                    ((endDate.compare(date) == .orderedDescending) || (endDate.compare(date) == .orderedSame))
                                    {
                                
                                        value = 1
                                        break
                                }
                                
                            }

                        }
                        
                        
                    }
                }
                
                return value
            } else {
            
                return 1//day % 5 == 0 ? day/5 : 0;
            }
        }
        return 0

    }
    
//    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
//        let day: Int! = self.gregorian.component(.day, from: date)
//        return [13,24].contains(day) ? UIImage(named: "icon_cat") : nil
//    }
    
}

extension ManageMilkDeliveryViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        if (Date().compare(date) == .orderedDescending) || (Date().compare(date) == .orderedSame) {
            return false
        }

        return pauseResumeMilkSupply(date: date)
    }
    
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        if (Date().compare(date) == .orderedDescending) || (Date().compare(date) == .orderedSame) {
            return false
        }
        return pauseResumeMilkSupply(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, longPressOn date: Date, at monthPosition: FSCalendarMonthPosition) {
    
        getSubsctionDetailsOndate(date: date)
    }
    
    private func  pauseResumeMilkSupply(date: Date) -> Bool {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        
        let parameters = ["user_id": userId, "login_id": userId, "start_date": formatter.string(from: date), "end_date": formatter.string(from: date)] as [String : Any]
        
        APIManager.defaultManager.requestJSON(apiRouter: .pauseMilkSupply(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        self.calendar.select(date)
                    } else if status == "000005" {
                        self.calendar.deselect(date)
                    }
                    
                    if let message = responseDict["msg"] as? String {
                        self.showAlert(message: message)
                    }
                }
            }
        }
        
        return false
    }
    
    private func  getSubsctionDetailsOndate(date: Date) {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        
        let parameters = ["user_id": userId,  "start_date": formatter.string(from: date)] as [String : Any]
        
        APIManager.defaultManager.requestJSON(apiRouter: .getSubscriptionDetailsForEditOnDate(parameters)) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        
                        if let subscriptionsList =  responseDict["subscription_list"] as? [[String: Any]] {
                        
                            var lastSubscription:[String: Any]?
                            if subscriptionsList.count > 0 {
                        
                                if let stringValue = self.selectedProductDict?["subscription_id"] as? String, let subscriptionId = Int(stringValue) {
                        
                                    var showMsgOnNoSubscriptionFound = true
                                    for subscription in subscriptionsList {
                                        
                                        var idValue = subscription["subscription_id"] as? Int
                                        
                                        if idValue == nil { //this is done as sometimes subscription_id comes as String
                                            if let value = subscription["subscription_id"] as? String {
                                                
                                                idValue = Int(value)
                                            }
                                        }
                                        
                                        if let id = idValue {//subscription["subscription_id"] as? Int {
                                            
                                            if subscriptionId == id {
                                                
//                                                if let status = subscription["status"] as? String {
//
//                                                    if status.lowercased() == "unsubscribed" {
//                                                        break
//                                                    }
//                                                }
                                                
                                                showMsgOnNoSubscriptionFound = false
                                                self.showChangeQuantityViewFor(productDict: subscription, date: date)
                                                
                                                break

                                            } else {
                                                lastSubscription = subscription//TODO- later on all subscriptions will be shown in a list if there are mutiple subscriptions on a given day. Right now it a temporary fix to show only the last subscription if multiple subsctiions are found on same date and no subscribed subscription exist. This scenarion will rarely happen in production
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    if showMsgOnNoSubscriptionFound {
                                        
                                        if let lastSubscription = lastSubscription {
                                            self.showChangeQuantityViewFor(productDict: lastSubscription, date: date)

                                        }
                                        
                                        self.showAlert(message: "No subscription found for this date")

                                    }
                                    
                                }
                                
                                
                            }
                        }
                    } else  if let message = responseDict["msg"] as? String {
                        self.showAlert(message: message)
                    }
                }
            }
        }
        
    }
}

//Edit Subscription methods
extension ManageMilkDeliveryViewController {
    
    func showChangeQuantityViewFor(productDict: [String: Any]?, date: Date) {
        
        if let controller = getEditSubscribeController() {
            
            controller.editForDate = date
            controller.productDict = productDict
            controller.viewToShow = "changequantity"

            let pauseStatus = productDict?["pause"] as? Int
            let deliveryStatus = productDict?["delivery_status"] as? String
            let subscriptionStatus = productDict?["status"] as? String

            
            if (pauseStatus == 1) || deliveryStatus == "Delivered" || subscriptionStatus == "Unsubscribed" {
                controller.disableView = true
            }
            
//            if (Date().compare(date) == .orderedDescending) || (Date().compare(date) == .orderedSame) {
//                controller.disableView = true
//            }
            self.present(controller, animated: true, completion: nil)
        }
    }

    private func getEditSubscribeController() -> EditSubscribeViewController? {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditSubscribeViewController") as? EditSubscribeViewController {
            
           // controller.delegate = self//need to change to protocl
            controller.modalPresentationStyle = .custom
            controller.transitioningDelegate = self
            controller.modalTransitionStyle = .crossDissolve
            
            return controller
        }
        
        return nil
    }

}


//MARK:- UIViewControllerTransitioningDelegate
extension ManageMilkDeliveryViewController: UIViewControllerTransitioningDelegate {
    
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
                height = 240
            }
            
            
            customPresentationController.presentedControllerSize = CGRect(x: 20, y: self.view.center.y - (height/2 + 64), width: self.view.frame.size.width - 40, height: height)
        }
        
        return customPresentationController
    }
}

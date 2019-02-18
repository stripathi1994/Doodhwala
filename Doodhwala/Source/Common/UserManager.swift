//
//  UserManager.swift
//  Doodhwala
//
//  Created by apple on 11/07/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import Foundation

class UserManager {
    
    static let defaultManager = UserManager()

    var userDict: [String: Any]?
    var userProfileDict: [String: Any]?
    
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(getUserDetails), name: Notification.Name(rawValue: "refreshprofiledetails"), object: nil)

    }

    
    func getAddress() -> String {
        
        var address = ""
        
        if let userProfileDict = userProfileDict {
            
            if let userAddress = userProfileDict["address"] as? [String: Any], let value = userAddress["address1"] as? String  {
                address = value
            }
        }
        
        return address
    }
    
    
    func getPinCode() -> String? {
        
        var pincode: String?
        
        if let userProfileDict = userProfileDict {
            
            if let userAddress = userProfileDict["address"] as? [String: Any], let value = userAddress["pincode"] as? Int  {
                pincode = "\(value)"
            }
        }
        
        return pincode
    }
}


//MARK:- User details metods

extension UserManager {
    
    @objc func getUserDetails() {
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            APIManager.defaultManager.requestJSON(apiRouter: .getUserInfo(["user_id": userId])) { (responseDict) in
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess
                            
                            if let userDetails = responseDict["user_record"] as? [String: Any] {
                                
                                self.userProfileDict = userDetails
                                
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "profiledetailsupdated")))
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

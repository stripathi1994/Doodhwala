//
//  APIManager.swift
//  Doodhwala
//
//  Created by admin on 8/21/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import Foundation
import Alamofire


class APIManager {
    
    static let defaultManager = APIManager()

    func isRegister(_ deviceId: String, completionHandler: @escaping ([String: Any]?) -> Void) {
        
        Alamofire.request(APIRouter.isRegister(deviceId)).validate().responseJSON { (response) in
            
            switch response.result {
                
            case .success:

                print("response...\(response)")

                if let json = response.result.value as? [String: Any] {

                    completionHandler(json)
                }
                

            case .failure(let error):
                
                completionHandler(nil)
                
                print(error)
            }
        }
    }
    
    func requestJSON(apiRouter: APIRouter, completionHandler: @escaping ([String: Any]?) -> Void) {
        
        Alamofire.request(apiRouter).validate().responseJSON { (response) in
            
            print("response...\(response)")

            switch response.result {
                
            case .success:
                
                if let json = response.result.value as? [String: Any] {
                    
                    completionHandler(json)
                }
                
                
            case .failure(let error):
                
                completionHandler(nil)
                
                print(error)
            }
        }
    }
    
    func getProducts(parameters: [String: Any], completionHandler: @escaping ([String: Any]?) -> Void) {
        
        Alamofire.request(APIRouter.products(parameters)).validate().responseJSON { (response) in
            
            print("Request...\(String(describing: response.request))")
            print("Request...\(String(describing: response.request?.httpBody))")
            
            print("response...\(response)")

            switch response.result {

            case .success:
                
                if let json = response.result.value as? [String: Any] {
                    
                    completionHandler(json)
                }
                
                
            case .failure(let error):
                
                completionHandler(nil)
                
                print(error)
            }
        }
    }
    
    
    func subscribeProduct(parameters: [String: Any], completionHandler: @escaping ([String: Any]?) -> Void) {
        
        Alamofire.request(APIRouter.subscribeProduct(parameters)).validate().responseJSON { (response) in
            
            print("Request...\(String(describing: response.request))")
            print("Request...\(String(describing: response.request?.httpBody))")
            
            switch response.result {
                
            case .success:
                
                print("response...\(response)")
                
                if let json = response.result.value as? [String: Any] {
                    
                    completionHandler(json)
                }
                
                
            case .failure(let error):
                
                completionHandler(nil)
                
                print(error)
            }
        }
    }
    
    
    func unsubscribeProduct(parameters: [String: String], completionHandler: @escaping ([String: Any]?) -> Void) {
        
        Alamofire.request(APIRouter.unsubscribe(parameters)).validate().responseJSON { (response) in
            
            print("Request...\(String(describing: response.request))")
            print("Request...\(String(describing: response.request?.httpBody))")
            
            switch response.result {
                
            case .success:
                
                print("response...\(response)")
                
                if let json = response.result.value as? [String: Any] {
                    
                    completionHandler(json)
                }
                
                
            case .failure(let error):
                
                completionHandler(nil)
                
                print(error)
            }
        }
    }
    
    
    func changeQuantity(parameters: [String: String], completionHandler: @escaping ([String: Any]?) -> Void) {
        
        Alamofire.request(APIRouter.changeQuantity(parameters)).validate().responseJSON { (response) in
            
            print("Request...\(String(describing: response.request))")
            print("Request...\(String(describing: response.request?.httpBody))")
            
            switch response.result {
                
            case .success:
                
                print("response...\(response)")
                
                if let json = response.result.value as? [String: Any] {
                    
                    completionHandler(json)
                }
                
                
            case .failure(let error):
                
                completionHandler(nil)
                
                print(error)
            }
        }
    }
    
    
    func getProductPrice(parameters: [String: Any], completionHandler: @escaping ([String: Any]?) -> Void) {
        
        Alamofire.request(APIRouter.getProductPrice(parameters)).validate().responseJSON { (response) in
            
            switch response.result {
                
            case .success:
                
                print("response...\(response)")
                
                if let json = response.result.value as? [String: Any] {
                    
                    completionHandler(json)
                }
                
                
            case .failure(let error):
                
                completionHandler(nil)
                
                print(error)
            }
        }
    }
    
}

//
//  APIRouter.swift
//  Doodhwala
//
//  Created by admin on 8/21/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    static let baseURLString = "http://doodhvale.in/dv/doodhvale/api/web/v2/" //production

    //static let baseURLString = "http://doodhvale.in/dev/doodhvale/api/web/v2/"

    static let baseURLStringForResource = "http://doodhvale.in"
    
    case isRegister(String)

    case signUp([String: String])

    case getUserInfo([String: Any])

    case updateUserInfo([String: Any])

    case updateUserLocationInfo([String: Any])

    case verifyOtp([String: String])

    case sendOTP([String: String])

    case logout(String)

    case updateDevice([String: String])
    
    case createProfile([String: Any])

    case getBannerImages()

    case getCategories()

    case products([String: Any])

    case subscribeProduct([String: Any])

    case unsubscribe([String: Any])

    case getSubscriptionDetails([String: Any])

    case getSubscriptionsList([String: Any])

    case getSubscriptionDetailsForEditOnDate([String: Any])

    case changeQuantity([String: String])

    case getProductPrice([String: Any])
    
    case getFeedbackReasons([String: Any])
    
    case submitFeedback([String: Any])

    case verifyPromo([String: Any])

    case pauseMilkSupply([String: Any])

    case updateSubscription([String: Any])
    
    case generateChecksum([String: Any])

    case verifyTransaction([String: Any])

    case getAccountDetails([String: Any])
    
    case billingDetails([String: Any])
    
    case getFaqs()

    case serviceFeedback([String: Any])

    case emailRequest([String: Any])

    case prepaidPaymentReminder([String: Any])

    case validateReferralCode([String: Any])
    
    case getDeliveryBoyContact([String: Any])
    
    case getreferralDescription([String: Any])

    case getreferralShareMessage([String: Any])

    case collectBottles([String: Any])
    
    case isServicePinCode([String: Any])

    case notifyService([String: Any])

    
    
    func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {

            switch self {
                
                default:
                    return .post
                    
            }
        }
    
        let params: ([String: Any]?) = {
            
            switch self {
                
            case .isRegister(let deviceId):
                return ["deviceId": deviceId]
                
            case .signUp(let parameters):
                return parameters

            case .verifyOtp(let parameters):
                return parameters

            case .sendOTP(let parameters):
                return parameters
                
            case .logout(let userId):
                return ["user_id": userId]

            case .getUserInfo(let parameters):
                return parameters

            case .updateUserInfo(let parameters):
                return parameters

            case .updateUserLocationInfo(let parameters):
                return parameters

            case .updateDevice(let parameters):
                return parameters

            case .createProfile(let parameters):
                return parameters

            case .products(let parameters):
                return parameters
                
            case .subscribeProduct(let parameters):
                return parameters

            case .unsubscribe(let parameters):
                return parameters

            case .getSubscriptionDetails(let parameters):
                return parameters

            case .getSubscriptionsList(let parameters):
                return parameters

            case .getSubscriptionDetailsForEditOnDate(let parameters):
                return parameters
                
            case .changeQuantity(let parameters):
                return parameters

            case .getProductPrice(let parameters):
                return parameters
                
            case .getFeedbackReasons(let parameters):
                return parameters

            case .submitFeedback(let parameters):
                return parameters

            case .verifyPromo(let parameters):
                return parameters
                
            case .pauseMilkSupply(let parameters):
                return parameters

            case .updateSubscription(let parameters):
                return parameters

            case .generateChecksum(let parameters):
                return parameters

            case .verifyTransaction(let parameters):
                return parameters

            case .getAccountDetails(let parameters):
                return parameters

            case .billingDetails(let parameters):
                return parameters

            case .serviceFeedback(let parameters):
                return parameters

            case .emailRequest(let parameters):
                return parameters

            case .prepaidPaymentReminder(let parameters):
                return parameters

            case .validateReferralCode(let parameters):
                return parameters

            case .getDeliveryBoyContact(let parameters):
                return parameters

            case .getreferralDescription(let parameters):
                return parameters

            case .getreferralShareMessage(let parameters):
                return parameters

            case .collectBottles(let parameters):
                return parameters

            case .isServicePinCode(let parameters):
                return parameters

            case .notifyService(let parameters):
                return parameters


                
            default:
                return [:]

            }
        }()
        
        
        let url: URL = {
            // build up and return the URL for each endpoint
            let relativePath: String?
            
            switch self {
                
                case .isRegister:
                    relativePath = "users/isregister"
                
                case .signUp:
                    relativePath = "users/signup"

                case .getUserInfo:
                    relativePath = "users/user-info"

                case .updateUserInfo:
                    relativePath = "users/profile-detail"

                case .updateUserLocationInfo:
                    relativePath = "users/address-detail"

                case .verifyOtp:
                    relativePath = "users/verify-otp"

                case .sendOTP:
                    relativePath = "users/resend-otp"

                case .logout:
                    relativePath = "users/logout"

                case .updateDevice:
                    relativePath = "users/device-update"

                case .createProfile:
                    relativePath = "users/profile"

                case .getCategories:
                    relativePath = "categories/category-list"
                
                case .products:
                    relativePath = "products/product-list"

                case .subscribeProduct:
                    relativePath = "subscriptions/add"
                
                case .unsubscribe:
                    relativePath = "subscriptions/unsubscribe"
                
                case .getSubscriptionDetails:
                    relativePath = "subscriptions/edit-subscription"

                case .getSubscriptionDetailsForEditOnDate:
                    relativePath = "subscriptions/edit-list"

                case .getSubscriptionsList:
                    relativePath = "subscriptions/list"
                
                case .changeQuantity:
                    relativePath = "subscriptions/change-quantity"

                case .getProductPrice:
                    relativePath = "subscriptions/prepaid-product-price"
                
                case .getFeedbackReasons:
                    relativePath = "subscriptions/feedback-reason"

                case .submitFeedback:
                    relativePath = "subscriptions/submit-feedback"

                case .verifyPromo:
                    relativePath = "subscriptions/promo-verify"

                case .pauseMilkSupply:
                    relativePath = "subscriptions/pause-subscription"
                
                case .updateSubscription:
                    relativePath = "subscriptions/subscription-update"

                case .generateChecksum:
                    relativePath = "accounts/generate-checksum"

                case .verifyTransaction:
                    relativePath = "accounts/verify-transaction"

                case .getAccountDetails:
                    relativePath = "accounts/account-view"

                case .billingDetails:
                    relativePath = "accounts/customer-bill"

                case .getBannerImages:
                    relativePath = "subscriptions/home-slider"

                case .serviceFeedback:
                    relativePath = "subscriptions/service-feedback"

                case .getFaqs:
                    relativePath = "faqs/faq-list"
                
                case .emailRequest:
                    relativePath = "subscriptions/email-request"

                case .prepaidPaymentReminder:
                    relativePath = "accounts/prepaid-payment-reminder"

                case .validateReferralCode:
                    relativePath = "referrals/is-validate-referral-code"
                
                case .getDeliveryBoyContact:
                    relativePath = "subscriptions/call-by-customer"
                
                case .getreferralDescription:
                    relativePath = "referrals/description-to-display"
                
                case .getreferralShareMessage:
                    relativePath = "referrals/message-to-share"
                
                case .collectBottles:
                    relativePath = "accounts/customer-empty-bottle"

                case .isServicePinCode:
                    relativePath = "subscriptions/is-service-pincode"

                case .notifyService:
                    relativePath = "subscriptions/add-notify-service"


            }

            
            var url = URL(string: APIRouter.baseURLString)!

            if let relativePath = relativePath {
                url = url.appendingPathComponent(relativePath)
            }
            
            return url
        }()
        
        let encoding: ParameterEncoding = {
            
            switch method {
                
                case .post:
                    return URLEncoding.httpBody
                default:
                    return URLEncoding.default
            }
        }()
        
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

        
        return try encoding.encode(urlRequest, with: params)

    }
}

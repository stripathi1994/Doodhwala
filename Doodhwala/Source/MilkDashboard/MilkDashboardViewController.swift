//
//  MilkDashboardViewController.swift
//  Doodhwala
//
//  Created by Rajinder Paul on 16/09/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import UIKit
import ImageSlideshow
import MBProgressHUD


class DoodhvaleCustomSlideView: ImageSlideshow {
    
    override func layoutPageControl() {
        if case .hidden = self.pageControlPosition {
            pageControl.isHidden = true
        } else {
            pageControl.isHidden = self.images.count < 2
        }
        
        pageControl.frame = CGRect(x: frame.size.width - 70, y: frame.size.height - 25.0, width: 70, height: 20)
        
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }
    }
}

class MilkDashboardViewController: InsufficientViewController {

    let DEFAULTCATEGORYID = 2
    
    @IBOutlet var slideShowImageView: DoodhvaleCustomSlideView!
    @IBOutlet var overlayView: UIView!

    @IBOutlet weak var dashboardView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    var categoryList: [[String: Any]]?
    var productList: [[String: Any]]? {
        
        didSet {
            
            collectionView.reloadData()
            
            if let productListController = productListController {
                productListController.productList = productList
            }
        }
    }

    var dashBoardItems = [["name": "Subscribe Milk", "image": "subscribe-milk", "ItemId": "SubscribeMilk"], ["name": "Products", "image": "milkproducts", "ItemId": "Products"], ["name": "Manage Delivery", "image": "manage-milk-delivery", "ItemId": "ManageMilkDelivery"], ["name": "Billing Details", "image": "billing-detail", "ItemId": "BillingDetail"], ["name": "Payment", "image": "paymenticon", "ItemId": "Payment"], ["name": "Call Delivery Boy", "image": "call-delivery-boy", "ItemId": "CallDeliveryBoy"]] //last item dummy for white box
    
    
    weak var productListController: ProductListViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(loadProductListData), name: Notification.Name(rawValue: "subscriptionUpdated"), object: nil)

        setUpView()
        loadProductListData()
        
        getBannerImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    fileprivate func setUpView() {
        
        self.setTitleView()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil) //needed for hiding back text on next controller

        //applyPlainShadow(view: dashboardView)
        MenuViewController.configureMenu(button: menuButton, controller: self)
        
    }
    

    fileprivate func setUpSlideShowView(imagesArray: [SDWebImageSource]) {
        
        slideShowImageView.slideshowInterval = 8.0
        slideShowImageView.backgroundColor = UIColor.white
        
        if imagesArray.count > 0 {
            slideShowImageView.setImageInputs(imagesArray)
        } else {
            
            slideShowImageView.setImageInputs([ImageSource(image: UIImage(named: "banner1")!),
                                               ImageSource(image: UIImage(named: "banner2")!),
                                               ImageSource(image: UIImage(named: "banner3")!),
                                               ])
        }

        slideShowImageView.activityIndicator = DefaultActivityIndicator()

        slideShowImageView.contentScaleMode = .scaleToFill
        slideShowImageView.pageControl.pageIndicatorTintColor = UIColor.white
        slideShowImageView.pageControl.currentPageIndicatorTintColor = UIColor.orange
        slideShowImageView.bringSubview(toFront: self.overlayView)
        slideShowImageView.bringSubview(toFront: self.slideShowImageView.pageControl)
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


//MARK:- CollectionView delegate data source
extension MilkDashboardViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return dashBoardItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: floor((collectionView.frame.width) / 2), height: collectionView.frame.height / 3)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView.frame.width.truncatingRemainder(dividingBy: 2) == 0 {
            return UIEdgeInsetsMake(0, -1, 0, 0)

        } else {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MilkDashBoardCell", for: indexPath) as! MilkDashBoardCell
        
        cell.configure(dashBoardItem: dashBoardItems[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        switch dashBoardItems[indexPath.row]["ItemId"] {
            
        case "Products":
            
            if let productList = self.productList {
                
                if productList.count > 0 {
                    showProductList(productList: productList)
                }
            }
        
        case "SubscribeMilk":
            
            showSubscriptionController()
            
        case "ManageMilkDelivery":
            showManageMilkDeliveryController()
            
            
        case "BillingDetail":
            showBillingViewController()
            
        case "Payment":
            showPaymentViewController()

        case "CallDeliveryBoy":
            getDeliveryBoyContact()

        default:
            showSubscriptionController()

        }
        
    }
}

//Mark:- REST APIs
extension MilkDashboardViewController {
    
    func loadProductListData() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            APIManager.defaultManager.getProducts(parameters: ["user_id": userId, "cat_id": DEFAULTCATEGORYID]) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        
                        if status == "000000" {
                            //Succcess
                            
                            if let response = responseDict["product_list"] as? [[String: Any]] {
                                
                                self.productList = response
                            }
                            
                            UserManager.defaultManager.getUserDetails()
                            
                        } else {
                            //Failure handle errors
                            
                            if let message = responseDict["msg"] as? String {
                                
                                let alert = UIAlertController(title: "ERROR!", message: message, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    fileprivate func getBannerImages() {
        
        APIManager.defaultManager.requestJSON(apiRouter: .getBannerImages()) { (responseDict) in
            
            var sliderImagesArray = [SDWebImageSource]()
            
            if let responseDict = responseDict {
                //check for status 000000 for success
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000", let sliderImagesDictArray = responseDict["slider_image"] as? [[String: String]]{
                        //Succcess
                        
                        for dict in sliderImagesDictArray {
                            
                            if let imageUrl = dict["image"] {
                                
                                sliderImagesArray.append(SDWebImageSource(urlString: APIRouter.baseURLStringForResource + imageUrl, placeholder: UIImage(named: "defaultImage"))!)
                                
                            }
                        }
                    }
                }
            }
            
            self.setUpSlideShowView(imagesArray: sliderImagesArray)
        }
    }
    
    fileprivate func getDeliveryBoyContact() {
        
        if let userId = UserManager.defaultManager.userDict?["user_id"] as? Int {
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Please wait..."
            
            APIManager.defaultManager.requestJSON(apiRouter: .getDeliveryBoyContact(["user_id": userId])) { (responseDict) in
                
                MBProgressHUD.hide(for: self.view, animated: true)

                if let responseDict = responseDict {
                    //check for status 000000 for success
                    
                    if let status = responseDict["status"] as? String {
                        if status == "000000" {
                            //Succcess
                            if let number = responseDict["phone"] as? String {
                                //self.showAlert(message: message)
                                self.callDeliveryBoy(number: number)
                            } else if let number = responseDict["phone"] as? Int {
                                //self.showAlert(message: message)
                                self.callDeliveryBoy(number: "\(number)")
                            }
                            
                            
                        } else {
                            //Failure handle errors
                            
                            if let message = responseDict["msg"] as? String {
                                self.showAlert(message: message)
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK:- Navigation Methods
extension MilkDashboardViewController {
    
    fileprivate func showSubscriptionController() {
        
        guard let productList = self.productList else { return }
        
        if productList.count > 0 {

            let selectedproduct = productList[0]//Assuming first product will be Milk
            
            //unsettled, Yes, No
            if let subscriptionStatus = selectedproduct["subscription"] as? String {
                
                if subscriptionStatus.lowercased() == "unsettled" {
                    
                    if let controller = UIStoryboard(name: "Subscription", bundle: nil).instantiateViewController(withIdentifier: "SubscriptionUnsettledViewController") as? SubscriptionUnsettledViewController {
                        
                        //controller.selectedProductDict = selectedproduct
                        navigationController?.pushViewController(controller, animated: true)
                    }
                } else {
                    
                    if let controller = UIStoryboard(name: "Subscription", bundle: nil).instantiateViewController(withIdentifier: "SubscriptionViewController") as? SubscriptionViewController {
                        
                        controller.selectedProductDict = selectedproduct
                        navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }

        }
    }
    
    
    fileprivate func showManageMilkDeliveryController() {
        
        guard let productList = self.productList else { return }
        
        if productList.count > 0 {
            
            if let controller = UIStoryboard(name: "ManageMilkDelivery", bundle: nil).instantiateViewController(withIdentifier: "ManageMilkDeliveryViewController") as? ManageMilkDeliveryViewController {
                
                    controller.selectedProductDict = productList[0]
                    navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    fileprivate func showProductList(productList: [[String: Any]]) {
        
        productListController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        
        productListController?.productList = productList

        navigationController?.pushViewController(productListController!, animated: true)
    }
    
    
    fileprivate func showPaymentViewController() {
        
        if let controller = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    fileprivate func showBillingViewController() {
        
        if let controller = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "BillingViewController") as? BillingViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    fileprivate func callDeliveryBoy(number: String)  {
        
        if let url = URL(string: "TEL://\(number)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

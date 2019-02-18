//
//  HomeViewController.swift
//  Doodhwala
//
//  Created by admin on 8/18/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import UIKit
import ImageSlideshow
import MBProgressHUD

class HomeViewController: UIViewController {

    @IBOutlet var slideShowImageView: ImageSlideshow!
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet var categoryCollectionView: UICollectionView!
    
    @IBOutlet var categoryView: UIView!
    
    @IBOutlet var bottomView: UIView!
    
    var categoryList: [[String: Any]]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpView()
        
        loadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setUpView() {
    
        setUpSlideShowView()

        categoryView.addShadowAndRadius(cornerRadius: 8)
        bottomView.addShadowAndRadius(cornerRadius: 8)

        MenuViewController.configureMenu(button: menuButton, controller: self)

    }

    fileprivate func setUpSlideShowView() {
    
        slideShowImageView.setImageInputs([
            
            ImageSource(image: UIImage(named: "slider1")!),
            ImageSource(image: UIImage(named: "slider2")!),
            ImageSource(image: UIImage(named: "slider3")!),
            ImageSource(image: UIImage(named: "slider4")!),
            ImageSource(image: UIImage(named: "slider5")!),

            //AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080"),
            
            ])

        slideShowImageView.contentScaleMode = .scaleToFill
        slideShowImageView.pageControl.pageIndicatorTintColor = UIColor.white
        slideShowImageView.pageControl.currentPageIndicatorTintColor = UIColor.orange
        slideShowImageView.bringSubview(toFront: self.overlayView)
        slideShowImageView.bringSubview(toFront: self.slideShowImageView.pageControl)
    }
    
    func loadData() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait..."
        
        APIManager.defaultManager.requestJSON(apiRouter: .getCategories()) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for regsitered, 000001 for not registered
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        
                        if let categoryResponse = responseDict["cat_list"] as? [[String: Any]] {
                            
                            self.categoryList = categoryResponse
                            
                            self.categoryCollectionView.reloadData()
                        }
                        
                        
                        
                    } else {
                        //Failure handle errors
                        
                        if let message = responseDict["msg"] as? String {
                        
                            let alert = UIAlertController(title: "ERROR!", message: message, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                }
                
                print("Already registered, take it to category")
            } else {
                //DO SignUp
                
                print("Need to sign Up")
            }
        }

    }
    
    fileprivate func getLoginUserInfo() {
        
        let userId = UserManager.defaultManager.userDict?["user_id"] as? Int
        APIManager.defaultManager.requestJSON(apiRouter: .getUserInfo(["user_id" : userId])) { (responseDict) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let responseDict = responseDict {
                //check for status 000000 for regsitered, 000001 for not registered
                
                if let status = responseDict["status"] as? String {
                    
                    if status == "000000" {
                        //Succcess
                        
                        if let categoryResponse = responseDict["cat_list"] as? [[String: Any]] {
                            
                            self.categoryList = categoryResponse
                            
                            self.categoryCollectionView.reloadData()
                        }
                        
                        
                        
                    } else {
                        //Failure handle errors
                        
                        if let message = responseDict["msg"] as? String {
                            
                            let alert = UIAlertController(title: "ERROR!", message: message, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                }
                
                print("Already registered, take it to category")
            } else {
                //DO SignUp
                
                print("Need to sign Up")
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

//MARK:- CollectionView delegate data source
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        var numberOfItems = 0
        
        if let count = categoryList?.count {
            
            numberOfItems = count
        }

        return numberOfItems
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalWidth = collectionView.frame.width
        
        var cellWidth = floor(totalWidth / 3)
        
        if cellWidth > 200 {
            
            cellWidth = 200
        }
        
        let size = CGSize.init(width: cellWidth, height: collectionView.frame.height / 2)
        
        return size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell

        if let category = categoryList?[indexPath.row] {
         
            cell.configure(categoryDict: category)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let category = categoryList?[indexPath.row] {
            
            if let categoryName = category["cat_name"] as? String {
                
                if categoryName == "Dairy" {
                    
                    self.performSegue(withIdentifier: "MilkDashboardViewControllerSegue", sender: self)
                } else {
                    showProductsForCategory(category: category)
                }
                
                MenuViewController.setSelectedMenuIndex(index: nil)
            }
        }
    }

    fileprivate func showProductsForCategory(category: [String: Any]) {
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        
        controller.selectedCategory = category

        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    
    
}

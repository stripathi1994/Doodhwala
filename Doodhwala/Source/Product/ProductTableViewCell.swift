//
//  ProductTableViewCell.swift
//  Doodhwala
//
//  Created by Rajinder Paul on 07/09/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import UIKit
import SDWebImage

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!

    // @IBOutlet weak var brandNameLabel: UILabel!
   // @IBOutlet weak var discountPriceLabel: UILabel!
   // @IBOutlet weak var discountStrikeThroughLine: UIView!
   // @IBOutlet weak var quanityView: UIView!
    
   // var plusButtonAction =
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        DispatchQueue.main.async {
            self.productImageView.layer.cornerRadius = self.productImageView.frame.size.width / 2
            self.subscribeButton.layer.cornerRadius = 4
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configure(productDict: [String: Any]) {
        
        subscribeButton.isUserInteractionEnabled = true
        subscribeButton.backgroundColor = UIColor.darkOrange
        infoLabel.text = ""
        
        if let name = productDict["product_name"] as? String {
            
            nameLabel.text = name
        }
        if let price = productDict["product_price"] as? Int {
            
            priceLabel.text = "₹ \(price)"
        }
        if let quantity = productDict["product_description"] as? String {
            
            quantityLabel.text = quantity
        }
        
        subscribeButton.backgroundColor = UIColor.darkOrange
        if let subscription = productDict["subscription"] as? String {

             //else {
                
                if let productId = productDict["product_id"] as? Int, let stockStatus = productDict["status"] as? Int {
                    
                    if productId == 1 { //MILK
                        
                        
                        if subscription.lowercased() == "yes" {
                            subscribeButton.setTitle("EDIT PLAN", for: .normal)
                        } else if subscription.lowercased() == "unsettled" {
                            subscribeButton.backgroundColor = UIColor.red
                            subscribeButton.setTitle("PAYMENT", for: .normal)
                            infoLabel.text = "Can't Subscribe Clear your dues first."
                        }
                        else {
                            subscribeButton.setTitle("SUBSCRIBE", for: .normal)
                        }
                    } else {
                        
                        if stockStatus == 1 {
                            //AVAILABLE
                            subscribeButton.setTitle("ORDER", for: .normal)
                        }else if stockStatus == 2 {
                            //OUT Of Stock
                            subscribeButton.setTitle("OUT OF STOCK", for: .normal)
                            subscribeButton.isUserInteractionEnabled = false
                            subscribeButton.backgroundColor = UIColor.gray
                        }
                    }
                }
            //}
        }

        
//        if let brand_name = productDict["brand_name"] as? String {
//            
//            brandNameLabel.text = brand_name
//        }

        
        if let imageUrlStr = productDict["product_image_url"] as? String {
            
            self.productImageView.sd_setShowActivityIndicatorView(true)
            self.productImageView.sd_setIndicatorStyle(.gray)

            productImageView.sd_setImage(with: URL(string: APIRouter.baseURLStringForResource + imageUrlStr), placeholderImage: UIImage.defaultImage(), options: .cacheMemoryOnly)
        }
    }
}

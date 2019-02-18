//
//  CategoryCollectionViewCell.swift
//  Doodhwala
//
//  Created by admin on 8/23/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import UIKit
import SDWebImage


class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    
    func configure(categoryDict: [String: Any]) {
        
        if let name = categoryDict["cat_name"] as? String {
            
            nameLabel.text = name
        }

        if let imageUrlStr = categoryDict["cat_image_url"] as? String {
            
            imageView.sd_setImage(with: URL(string: APIRouter.baseURLStringForResource + imageUrlStr), placeholderImage: nil, options: .cacheMemoryOnly)
        }
    }
}

//
//  CategoryCollectionViewCell.swift
//  Doodhwala
//
//  Created by admin on 8/23/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import UIKit

class MilkDashBoardCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    func configure(dashBoardItem: [String: Any]) {
        
        if let name = dashBoardItem["name"] as? String {
            
            nameLabel.text = name
        }

        if let imageName = dashBoardItem["image"] as? String {
            
            imageView.image = UIImage(named: imageName)
        }
    }
}

//
//  MenuTableViewCell.swift
//  Doodhwala
//
//  Created by Rajinder Paul on 28/09/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import UIKit
import SDWebImage

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundSubView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        if selected {
            backgroundSubView.backgroundColor = UIColor.darkOrange
            nameLabel.textColor = UIColor.white
            menuIcon.tintColor = UIColor.white
        } else {
            backgroundSubView.backgroundColor = UIColor.white
            nameLabel.textColor = UIColor.black
            menuIcon.tintColor = UIColor.darkGray

        }
    }
}

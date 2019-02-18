//
//  AddressTableVewCell.swift
//  Doodhvale
//
//  Created by Rajinder on 8/14/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class AddressTableVewCell: UITableViewCell {

    @IBOutlet weak var deliveryLocationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var landmarkLabel: UILabel!
    
    var data: [String: String] = [:] {
        
        didSet {
            
            setupCell()
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func setupCell() {
        
        if let value = data["locationValue"] {
            deliveryLocationLabel.text = "Delivery Location: " + value
        }

        if let value = data["addressValue"] {
            addressLabel.text = "Address: " + value
        }

        if let value = data["landmarkValue"] {
            landmarkLabel.text = "Landmark: " + value
        }
    }
}

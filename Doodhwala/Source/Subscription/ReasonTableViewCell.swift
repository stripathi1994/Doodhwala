//
//  ReasonTableViewCell.swift
//  Doodhvale
//
//  Created by apple on 20/07/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class ReasonTableViewCell: UITableViewCell {

    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        checkImageView.isHighlighted = selected
    }

}

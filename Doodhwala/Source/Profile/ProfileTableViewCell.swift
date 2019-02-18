//
//  ProfileTableViewCell.swift
//  Doodhwala
//
//  Created by apple on 06/07/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: SkyFloatingLabelTextField!
    
    var isEditable = true

    var data: [String: String] = [:] {

        didSet {

            setupCell()

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if textField != nil {
            textField.addDoneButtonOnKeyboard()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    private func setupCell() {
        
        textField.text = data["FieldValue"]
        textField.placeholder = data["PaceholderValue"]
        
        if data["FieldId"] == "deliverylocation" {
            textField.textColor = UIColor.gray
        } else {
            textField.textColor = UIColor.black
        }
    }
}

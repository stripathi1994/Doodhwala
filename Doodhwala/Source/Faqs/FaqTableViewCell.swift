//
//  FaqTableViewCell.swift
//  Doodhvale
//
//  Created by Rajinder on 9/3/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class FaqTableViewCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(data: [String: Any]) {
        
        if let value = data["question"] as? String {
            questionLabel.text = value
        } else {
            questionLabel.text = ""
        }
        
        answerLabel.text = ""
        arrowIcon.isHighlighted = false

        if let isSelected = data["isSelected"] as? Bool {
            if isSelected {
                if let value = data["answer"] as? String {
                    answerLabel.text = value
                    arrowIcon.isHighlighted = true

                }
            }
        }
    }
}

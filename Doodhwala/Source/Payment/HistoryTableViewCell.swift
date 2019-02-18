//
//  HistoryTableViewCell.swift
//  Doodhvale
//
//  Created by Rajinder on 8/28/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var bottomHorizotalSeparator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(data: [String: Any], row: Int, totalRows: Int) {
        
        if (row == totalRows - 1) {
            bottomHorizotalSeparator.isHidden = false
            
        } else  {
            bottomHorizotalSeparator.isHidden = true
        }
        
        
        if let value = data["amount"] as? String {
            amountLabel.text = value
        }

        if let value = data["payment_mode"] as? String {
            modeLabel.text = value
        }

        if let value = data["transaction_date"] as? String {
            dateLabel.text = value
        }

        if let value = data["type"] as? String {
            typeLabel.text = value
        }

    }

}

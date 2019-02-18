//
//  BottleDetailsTableViewCell.swift
//  Doodhvale
//
//  Created by Rajinder on 8/28/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class BottleDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var amt1Label: UILabel!

    @IBOutlet weak var bottomHorizotalSeparator: UIView!
    


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(data: [String: Any], row: Int, totalRows: Int, subTotalRows: Int, billingDetailsDict: [String: Any]) {
        
        if (row == totalRows + subTotalRows - 1) {
            bottomHorizotalSeparator.isHidden = false
            
        } else  {
            bottomHorizotalSeparator.isHidden = true
        }
        
        if row >= totalRows {
            
            if row ==  totalRows {
                //Total row

                dateLabel.text = ""

                unitPriceLabel.text = "Total"

                if let value = data["broken_bottle"] as? Int {
                    qtyLabel.text = "\(value)"
                } else {
                    qtyLabel.text = ""
                }
                if let value = data["broken_bottle_charge"] as? Int {
                    
                    amt1Label.text = "\((data["broken_bottle"] as! Int)*value)"
                } else {
                    amt1Label.text = ""
                }
            }
            else {
                //Total Broken Amout trow
                unitPriceLabel.text = "Total Broken Bottle Amount(Rs)"

                if let charge = billingDetailsDict["broken_bottle_charge"] as? Int, let count = billingDetailsDict["broken_bottle"] as? Int  {
                    
                    amt1Label.text = "\(charge*count)"
                } else {
                    amt1Label.text = ""
                }
            }
            
        } else {
            
            if let value = data["delivery_date"] as? String {
                dateLabel.text = value
            } else {
                dateLabel.text = ""
            }
            
            if let value = billingDetailsDict["broken_bottle_charge"] as? Int {
                
                unitPriceLabel.text = "\(value)"
            } else {
                unitPriceLabel.text = ""
            }

            if let value = data["broken_bottle"] as? Int {
                qtyLabel.text = "\(value)"
            } else {
                qtyLabel.text = ""
            }
            
            if let charge = billingDetailsDict["broken_bottle_charge"] as? Int, let count = billingDetailsDict["broken_bottle"] as? Int  {
                
                amt1Label.text = "\(charge*count)"
            } else {
                amt1Label.text = ""
            }
        }

    }
    

}

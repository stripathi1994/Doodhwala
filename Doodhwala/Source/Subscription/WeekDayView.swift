//
//  WeekDayView.swift
//  Doodhwala
//
//  Created by apple on 21/06/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class DayView: UIView {
    
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var quantityLabel: UILabel!
}

class WeekDaysStackView: UIStackView {

    var daysDict = ["sunday": 1, "monday": 1, "tuesday": 1, "wednesday": 1, "thursday": 1, "friday": 1, "saturday": 1]
    
    var selectedQuantity = 0 {
    
        didSet {
            
            if selectedQuantity == 0 {
                selectedDayView?.imageView.isHighlighted = false
            } else {
                selectedDayView?.imageView.isHighlighted = true
            }
            
            selectedDayView?.quantityLabel.text = "\(selectedQuantity)"
            
            if let selectedDay = selectedDayView?.accessibilityValue {
               daysDict[selectedDay] = selectedQuantity
            }
        }
    }
    
    var selectedDayView: DayView? {
        
        willSet(dayView) {
            
            selectedDayView?.dayButton.isSelected = false
            selectedDayView?.dayButton.backgroundColor = UIColor.clear

            dayView?.dayButton.isSelected = true
            dayView?.dayButton.backgroundColor = UIColor.orange
        }
        
        
    }
    
    func setUpSubscriptionData(subscriptionDict: [String: Any]) {
        
        let weedDaysArray = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        for weekDay in weedDaysArray {

            if let quantity = subscriptionDict[weekDay] as? Int {
                
                daysDict.updateValue(quantity, forKey: weekDay)
                
            }
        }

        setUpAsReadableView()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setUpView() {
        
        var index = 0
        let weedDaysArray = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        for view in subviews {
            
            if let dayView =  view as? DayView {
                
                dayView.dayButton.layer.cornerRadius = dayView.dayButton.frame.size.width / 2
                dayView.imageView.layer.cornerRadius = dayView.imageView.frame.size.width / 2
                
                dayView.accessibilityValue = weedDaysArray[index]
                
                if let quantity  = daysDict[weedDaysArray[index]] {
                    dayView.quantityLabel.text = "\(quantity)"
                    
                    if quantity == 0 {
                        dayView.imageView.isHighlighted = false
                    } else {
                        dayView.imageView.isHighlighted = true
                    }
                }
                
                index = index + 1
            }
        }
        
        if subviews.count > 0 {
            selectedDayView = subviews[0] as? DayView
        }
    }

    func setUpAsReadableView() {
        
        var index = 0
        let weedDaysArray = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        for view in subviews {
            
            if let dayView =  view as? DayView {
                
                let day = weedDaysArray[index]
                
                if let quantity = daysDict[day] {
                    dayView.quantityLabel.text = "\(quantity)"
                    
                    if quantity > 0 && dayView.imageView != nil {
                        
                        dayView.imageView.isHighlighted = true
                    } else if dayView.imageView != nil{
                        dayView.imageView.isHighlighted = false
                    }
                }
                
                index = index + 1
            }
        }
    }
}

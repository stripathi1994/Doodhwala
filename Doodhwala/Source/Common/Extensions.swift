//
//  Extensions.swift
//  Doodhwala
//
//  Created by admin on 8/18/17.
//  Copyright © 2017 appzpixel. All rights reserved.
//

import UIKit
import NotificationCenter


extension UIViewController {
    
    func setTitleView() {
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "doodvale"))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil) //needed for hiding back text on next controller
    }
    
    func showAlert(message: String) {
    
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}


extension UIView {
//Source https://medium.com/bytes-of-bits/swift-tips-adding-rounded-corners-and-shadows-to-a-uiview-691f67b83e4a
    func addShadowAndRadius(cornerRadius: CGFloat) {
        
            let shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = self.backgroundColor?.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.5
            shadowLayer.shadowRadius = 3
            
            layer.insertSublayer(shadowLayer, at: 0)
    }
}

extension UIColor {

    class var darkOrange: UIColor {
        
        return UIColor(displayP3Red: 223.0/255.0, green: 107.0/255.0, blue: 34.0/255.0, alpha: 1)
    }

    class var extraLightGray: UIColor {
        
        return UIColor(displayP3Red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1)
    }

    class var extraDarkGray: UIColor {
        
        return UIColor(displayP3Red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1)
    }

}


extension UITextField {
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        
        self.resignFirstResponder()
    }
}


extension UITextView {
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        
        self.resignFirstResponder()
    }
}
extension UIButton {
    
    func setUnderlineTitle(title: String, for state: UIControlState) {
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: (title.count)))
        self.setAttributedTitle(attributedString, for: state)
    }
}


extension UILabel {
    
    func setUnderlineText(text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: (text.count)))
        self.attributedText = attributedString
    }
}

extension Date {

    func getNextMonth(byAdding numberOfMonths: Int) -> Date? {
        
        return Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
    }

    func getPreviousMonth(bySubtracting numberOfMonths: Int) -> Date? {
        
        return Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
    }

    func getNextDate(byAdding numberOfDays: Int) -> Date? {
        
        return Calendar.current.date(byAdding: .day, value: numberOfDays, to: self)
    }

}


extension UIImage {
    
    class func defaultImage() -> UIImage {
        
        return UIImage(named: "defaultImage")!
    }
}

extension UITableView {
    
    func getTableIndexPathFromCellSubView(subView: UIView) -> IndexPath? {
        
        var indexPath: IndexPath?
        var superview = subView.superview
        
        while superview != nil {
            
            if let cell = superview as? UITableViewCell {
                
                if let cellIndexPath = self.indexPath(for: cell) {
                    
                    indexPath = cellIndexPath
                }
                
                break
            } else {
                
                superview = superview?.superview
            }
        }
        
        return indexPath
    }
}

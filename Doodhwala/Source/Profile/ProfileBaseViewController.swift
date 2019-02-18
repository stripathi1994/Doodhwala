//
//  ProfileBaseViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 8/9/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class ProfileBaseViewController: UIViewController {
    
    @IBOutlet weak var mainSubView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topsectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var profileInputFieldsArray: [[String: String]]!
    
    var updateProfile = false
    @IBOutlet weak var editProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setUpView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        
        self.setTitleView()
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK: TableView delegate and datasource
extension ProfileBaseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return profileInputFieldsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if profileInputFieldsArray[indexPath.row]["FieldId"] == "addressdetails" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableVewCell", for: indexPath) as! AddressTableVewCell
            
            cell.data = profileInputFieldsArray[indexPath.row]
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
            
            cell.data = profileInputFieldsArray[indexPath.row]
            
            if cell.textField != nil {
                cell.textField.tag = indexPath.row
            }
            
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

//MARK:- UITextFieldDelegate
extension ProfileBaseViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.placeholder == "DELIVERY LOCATION" {
            return false
        }
        
        if updateProfile && editProfileButton != nil {
            
            if editProfileButton.isSelected {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let text = textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) {
            profileInputFieldsArray[textField.tag].updateValue(text, forKey: "FieldValue")
            textField.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextRowIndex = textField.tag + 1
        
        if nextRowIndex < profileInputFieldsArray.count {
            
            if let cell = tableView.cellForRow(at: IndexPath(row: nextRowIndex, section: 0)) as? ProfileTableViewCell {
                
                cell.textField.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

//MARK:- Keyboard observers
extension ProfileBaseViewController {
    
    func keyboardWillShow(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let height = keyboardFrame.height + 20
        tableView.contentInset.bottom = height
        tableView.scrollIndicatorInsets.bottom = height
        
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        if editProfileButton != nil && editProfileButton.isSelected {
            self.topsectionHeightConstraint.constant = 40
        }
        else {
            self.topsectionHeightConstraint.constant = -(self.view.bounds.size.height * 0.6)
        }
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo ?? [:]
        
        tableView.contentInset.bottom = 0
        tableView.scrollIndicatorInsets.bottom = 0
        tableView.scrollRectToVisible(CGRect.zero, animated: true)
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        if editProfileButton != nil && editProfileButton.isSelected {
            self.topsectionHeightConstraint.constant = 240
        }
        else {
            self.topsectionHeightConstraint.constant = 0
        }
        
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension ProfileBaseViewController {
    
    func isEmailValid(_ email: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
        
    }
}

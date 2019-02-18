//
//  ListTableViewCell.swift
//  Doodhwala
//
//  Created by apple on 25/06/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//


import UIKit


@objc protocol PopOverViewControllerDelegate: class {
    
    func selectedValue (_ value: String, index: Int, popOverViewController: PopOverViewController)
}

class PopOverViewController: UIViewController {

    @IBOutlet weak var valuesTableView: UITableView!
    var customBackgroundColor: UIColor?
    var customTextColor: UIColor?

    weak var delegate: PopOverViewControllerDelegate?
    var permittedArrowDirections: UIPopoverArrowDirection = .any

    var dataArray: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.valuesTableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentPopover(_ sender: UIView, fromController: UIViewController) {
        
        self.modalPresentationStyle = .popover

        let popover: UIPopoverPresentationController = self.popoverPresentationController!
        
        popover.sourceView = sender
        popover.sourceRect = CGRect(x: 0, y: 0, width: sender.frame.size.width, height: sender.frame.size.height)
        popover.delegate = self
        popover.permittedArrowDirections = permittedArrowDirections
        
        fromController.present(self, animated: true, completion: nil)

    }

    func presentPopoverFromBarButton(_ sender: UIBarButtonItem, fromController: UIViewController) {
        
        self.modalPresentationStyle = .popover
        
        let popover: UIPopoverPresentationController = self.popoverPresentationController!
        
        if let color = customBackgroundColor {
            popover.backgroundColor = color
            self.view.backgroundColor = color
        }
        
        popover.barButtonItem = sender
        popover.delegate = self
        popover.permittedArrowDirections = permittedArrowDirections
        fromController.present(self, animated: true, completion: nil)
        
    }
}

//MARK: - UITableViewDataSource methods
extension PopOverViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        
        cell.nameLabel.text = self.dataArray![indexPath.row]
        
        if let color = customBackgroundColor {
            cell.backgroundColor = color
        }
        
        if let color = customTextColor {
            cell.nameLabel.textColor = color
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.selectedValue(self.dataArray![indexPath.row], index: indexPath.row, popOverViewController: self)

        self.dismiss(animated: true, completion: nil)
    }
    
}

extension PopOverViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController)
    {
        print("dismiss popup")
        
    }
}


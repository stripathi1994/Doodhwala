//
//  ContactViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 9/3/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    @IBOutlet weak var mainSubView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainSubView.addShadowAndRadius(cornerRadius: 5)
        self.setTitleView()
        MenuViewController.configureMenu(button: menuButton, controller: self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

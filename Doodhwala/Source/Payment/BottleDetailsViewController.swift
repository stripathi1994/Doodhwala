//
//  BottleDetailsViewController.swift
//  Doodhvale
//
//  Created by Rajinder on 9/2/18.
//  Copyright © 2018 appzpixel. All rights reserved.
//

import UIKit

class BottleDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let subtotalRows = 2
    
    var bottleDetailsArray: [[String: Any]]!
    var billingDetailsDict: [String: Any]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupData() {
        
        if let valueArray = billingDetailsDict["billing_detail"] as? [[String: Any]] {

            bottleDetailsArray = valueArray.filter { (element) -> Bool in
                element["broken_bottle"] as! Int > 0
            }
        }
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
extension BottleDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bottleDetailsArray.count + subtotalRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tableViewCell: UITableViewCell!
        var identifier: String! = "BottleDetailsTableViewCell"
        var data: [String: Any]!

            if indexPath.row > bottleDetailsArray.count {
                
                identifier = "BottleDetailsTotalCell"
                data = billingDetailsDict
            } else if indexPath.row == bottleDetailsArray.count {
                identifier = "BottleDetailsTableViewCell"
                data = billingDetailsDict
            }
            else {
                identifier = "BottleDetailsTableViewCell"
                data = bottleDetailsArray[indexPath.row]

            }

            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BottleDetailsTableViewCell

            tableViewCell = cell


        cell.configureCell(data: data, row: indexPath.row,totalRows: bottleDetailsArray.count, subTotalRows: subtotalRows, billingDetailsDict: billingDetailsDict)
        
        return tableViewCell
    }

}



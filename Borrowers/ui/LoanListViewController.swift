//
//  LoanListViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-04-04.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class LoanListViewController: UITableViewController {

    // Model
    var coreModel: CoreModelController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoanCell", for: indexPath) as! LoanListViewCell

        // Configure the cell...
//        switch indexPath.row {
//        case 0:
//            cell.fieldLabel.text = NSLocalizedString("Name", comment: "Name Field")
//            cell.valueLabel.text = restaurant?.name
//        case 1:
//            cell.fieldLabel.text = NSLocalizedString("Type", comment: "Type Field")
//            cell.valueLabel.text = restaurant?.type
//        case 2:
//            cell.fieldLabel.text = NSLocalizedString("Location", comment: "Location/Address Field")
//            cell.valueLabel.text = restaurant?.location
//        case 3:
//            cell.fieldLabel.text = NSLocalizedString("Phone", comment: "Phone Field")
//            cell.valueLabel.text = restaurant?.phoneNumber
//        case 4:
//            cell.fieldLabel.text = NSLocalizedString("Been here", comment: "Have you been here Field")
//            if let restaurantVisited = restaurant?.isVisited {
//                cell.valueLabel.text = restaurantVisited ? NSLocalizedString("Yes, I've been here before", comment: "Yes, I've been here before") : NSLocalizedString("No", comment: "No, I haven't been here")
//            }
//        default:
//            cell.fieldLabel.text = ""
//            cell.valueLabel.text = ""
//        }

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("1: willDisplay")
        (cell as! LoanListViewCell).willDisplay()
    }

//    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("2: didEndDisplaying")
//        (cell as! LoanListViewCell).willDisplay()
//    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

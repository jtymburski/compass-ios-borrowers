//
//  NewLoanViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-28.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class NewLoanViewController: UIViewController {
    // Statics
    let BORDER_FORM = UIColor.init(red: 231.0/255.0, green: 234.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    let BORDER_HEADER = UIColor.init(red: 63.0/255.0, green: 205.0/255.0, blue: 168.0/255.0, alpha: 1.0)

    // UI
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var labelAmountAvailable: UILabel!
    @IBOutlet weak var labelPaymentAmount: UILabel!
    @IBOutlet weak var labelPaymentFrequency: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var textFrequency: UITextField!
    @IBOutlet weak var textTerm: UITextField!
    @IBOutlet weak var viewAmount: UIView!
    @IBOutlet weak var viewAmountAvailable: UIView!
    @IBOutlet weak var viewFrequency: UIView!
    @IBOutlet weak var viewNoPayment: UILabel!
    @IBOutlet weak var viewPayment: UIView!

    // Model
    var coreModel: CoreModelController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add borders to the view
        viewAmountAvailable.layoutIfNeeded()
        _ = viewAmountAvailable.layer.addBorder(edge: .right, color: BORDER_HEADER, thickness: 1.0)
        viewAmount.layoutIfNeeded()
        _ = viewAmount.layer.addBorder(edge: .bottom, color: BORDER_FORM, thickness: 1.0)
        viewFrequency.layoutIfNeeded()
        _ = viewFrequency.layer.addBorder(edge: .bottom, color: BORDER_FORM, thickness: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

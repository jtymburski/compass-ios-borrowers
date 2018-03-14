//
//  DetailsViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-14.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    // Constants
    let BACKGROUND_COLOR = UIColor.init(red: 74.0/255.0, green: 162.0/255.0, blue: 119.0/255.0, alpha: 1.0)
    let BORDER_COLOR_ACTIVE = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let BORDER_COLOR_DEFAULT = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    let BORDER_COLOR_ERROR = UIColor.init(red: 1.0, green: 0.255, blue: 0.212, alpha: 1.0)

    // UI
    @IBOutlet weak var labelErrorAddress1: UILabel!
    @IBOutlet weak var labelErrorCity: UILabel!
    @IBOutlet weak var labelErrorCompany: UILabel!
    @IBOutlet weak var labelErrorJobTitle: UILabel!
    @IBOutlet weak var labelErrorPhone: UILabel!
    @IBOutlet weak var textAddress1: UITextField!
    @IBOutlet weak var textAddress2: UITextField!
    @IBOutlet weak var textAddress3: UITextField!
    @IBOutlet weak var textCity: UITextField!
    @IBOutlet weak var textCompany: UITextField!
    @IBOutlet weak var textJobTitle: UITextField!
    @IBOutlet weak var textPhone: UITextField!
    @IBOutlet weak var textPostCode: UITextField!
    @IBOutlet weak var textProvince: UITextField!
    @IBOutlet weak var viewAddress1: UIView!
    @IBOutlet weak var viewAddress2: UIView!
    @IBOutlet weak var viewAddress3: UIView!
    @IBOutlet weak var viewCity: UIView!
    @IBOutlet weak var viewCompany: UIView!
    @IBOutlet weak var viewJobTitle: UIView!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var viewPostCode: UIView!
    @IBOutlet weak var viewProvince: UIView!
    @IBOutlet weak var viewSectionAddress1: UIView!
    @IBOutlet weak var viewSectionAddress2: UIView!
    @IBOutlet weak var viewSectionAddress3: UIView!
    @IBOutlet weak var viewSectionCity: UIView!
    @IBOutlet weak var viewSectionCompany: UIView!
    @IBOutlet weak var viewSectionJobTitle: UIView!
    @IBOutlet weak var viewSectionPhone: UIView!
    @IBOutlet weak var viewSectionPostCode: UIView!
    @IBOutlet weak var viewSectionProvince: UIView!

    // Control
    var borderAddress1: CALayer!
    var borderAddress2: CALayer!
    var borderAddress3: CALayer!
    var borderCity: CALayer!
    var borderCompany: CALayer!
    var borderJobTitle: CALayer!
    var borderPhone: CALayer!
    var borderPostCode: CALayer!
    var borderProvince: CALayer!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add gradient to main background
        self.view.setGradient(startColor: BACKGROUND_COLOR, endColor: UIColor.black)

        // Add borders to the view
        viewAddress1.layoutIfNeeded()
        borderAddress1 = viewAddress1.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
        viewAddress2.layoutIfNeeded()
        borderAddress2 = viewAddress2.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
        viewAddress3.layoutIfNeeded()
        borderAddress3 = viewAddress3.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
        viewCity.layoutIfNeeded()
        borderCity = viewCity.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
        viewCompany.layoutIfNeeded()
        borderCompany = viewCompany.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
        viewJobTitle.layoutIfNeeded()
        borderJobTitle = viewJobTitle.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
        viewPhone.layoutIfNeeded()
        borderPhone = viewPhone.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
        viewPostCode.layoutIfNeeded()
        borderPostCode = viewPostCode.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
        viewProvince.layoutIfNeeded()
        borderProvince = viewProvince.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT, thickness: 1.0)
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

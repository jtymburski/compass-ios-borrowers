//
//  DetailsViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-14.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITextFieldDelegate {
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
    @IBOutlet weak var scrollView: UIScrollView!
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

        // Connects the text fields to this class as delegates
        textAddress1.delegate = self
        textAddress2.delegate = self
        textAddress3.delegate = self
        textCity.delegate = self
        textCompany.delegate = self
        textJobTitle.delegate = self
        textPhone.delegate = self
        textPostCode.delegate = self
        textProvince.delegate = self

        // Add observers for the keyboard showing and hiding
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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

    // MARK: - Text Field Delegates

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == textAddress1 {
            borderAddress1.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
        else if textField == textAddress2 {
            borderAddress2.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
        else if textField == textAddress3 {
            borderAddress3.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
        else if textField == textCity {
            borderCity.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
        else if textField == textCompany {
            borderCompany.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
        else if textField == textJobTitle {
            borderJobTitle.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
        else if textField == textPhone {
            borderPhone.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
        else if textField == textPostCode {
            borderPostCode.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
        else if textField == textProvince {
            borderProvince.backgroundColor = BORDER_COLOR_ACTIVE.cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textAddress1 {
            if !checkForError(textField) {
                borderAddress1.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
            }
        }
        else if textField == textAddress2 {
            borderAddress2.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
        }
        else if textField == textAddress3 {
            borderAddress3.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
        }
        else if textField == textCity {
            if !checkForError(textField) {
                borderCity.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
            }
        }
        else if textField == textCompany {
            if !checkForError(textField) {
                borderCompany.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
            }
        }
        else if textField == textJobTitle {
            if !checkForError(textField) {
                borderJobTitle.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
            }
        }
        else if textField == textPhone {
            if !checkForError(textField) {
                borderPhone.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
            }
        }
        else if textField == textPostCode {
            borderPostCode.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
        }
        else if textField == textProvince {
            borderProvince.backgroundColor = BORDER_COLOR_DEFAULT.cgColor
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textAddress1 {
            textAddress2.becomeFirstResponder()
        }
        else if textField == textAddress2 {
            textAddress3.becomeFirstResponder()
        }
        else if textField == textAddress3 {
            textCity.becomeFirstResponder()
        }
        else if textField == textCity {
            textProvince.becomeFirstResponder()
        }
        else if textField == textProvince {
            textPostCode.becomeFirstResponder()
        }
        else if textField == textPostCode {
            textPhone.becomeFirstResponder()
        }
        else if textField == textPhone {
            textCompany.becomeFirstResponder()
        }
        else if textField == textCompany {
            textJobTitle.becomeFirstResponder()
        }
        else if textField == textJobTitle {
            textField.resignFirstResponder()
        }

        return true
    }

    // MARK: - Keyboard Control

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let scrollBottom = scrollView.frame.origin.y + scrollView.frame.height
            let coverage = keyboardSize.height - ( self.view.frame.height - scrollBottom )
            let contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: coverage, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    // MARK: - Internals

    func checkForError(_ textField: UITextField) -> Bool {
        if textField == textAddress1 {
            if let addressText = textField.text, addressText.count > 4 {
                labelErrorAddress1.isHidden = true
                labelErrorAddress1.text = " "
            } else {
                borderAddress1.backgroundColor = BORDER_COLOR_ERROR.cgColor
                labelErrorAddress1.text = "A valid address is required"
                labelErrorAddress1.textColor = BORDER_COLOR_ERROR
                labelErrorAddress1.isHidden = false
                return true
            }
        }
        else if textField == textCity {
            if let cityText = textField.text, cityText.count > 0 {
                labelErrorCity.isHidden = true
                labelErrorCity.text = " "
            } else {
                borderCity.backgroundColor = BORDER_COLOR_ERROR.cgColor
                labelErrorCity.text = "A valid city name is required"
                labelErrorCity.textColor = BORDER_COLOR_ERROR
                labelErrorCity.isHidden = false
                return true
            }
        }
        else if textField == textCompany {
            if let companyText = textField.text, companyText.count > 2 {
                labelErrorCompany.isHidden = true
                labelErrorCompany.text = " "
            } else {
                borderCompany.backgroundColor = BORDER_COLOR_ERROR.cgColor
                labelErrorCompany.text = "A valid company name is required"
                labelErrorCompany.textColor = BORDER_COLOR_ERROR
                labelErrorCompany.isHidden = false
                return true
            }
        }
        else if textField == textJobTitle {
            if let jobTitleText = textField.text, jobTitleText.count > 2 {
                labelErrorJobTitle.isHidden = true
                labelErrorJobTitle.text = " "
            } else {
                borderJobTitle.backgroundColor = BORDER_COLOR_ERROR.cgColor
                labelErrorJobTitle.text = "A valid job title is required"
                labelErrorJobTitle.textColor = BORDER_COLOR_ERROR
                labelErrorJobTitle.isHidden = false
                return true
            }
        }
        else if textField == textPhone {
            if let phoneText = textField.text, StringHelper.isValidPhone(phoneText) {
                labelErrorPhone.isHidden = true
                labelErrorPhone.text = " "
            } else {
                borderPhone.backgroundColor = BORDER_COLOR_ERROR.cgColor
                labelErrorPhone.text = "A valid phone number is required"
                labelErrorPhone.textColor = BORDER_COLOR_ERROR
                labelErrorPhone.isHidden = false
                return true
            }
        }

        return false
    }
}

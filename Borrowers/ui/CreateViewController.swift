//
//  CreateViewController.swift
//  Borrowers
//
//  Created by Kevin Smith on 2018-03-10.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, NVActivityIndicatorViewable {
    private let ANIMATION_SIZE = 90
    private let KEYBOARD_COVERAGE = 100 // This matches the amount that would be shown by the button

    // UI
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var labelCountryError: UILabel!
    @IBOutlet weak var labelEmailError: UILabel!
    @IBOutlet weak var labelNameError: UILabel!
    @IBOutlet weak var labelPasswordError: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textCountry: UITextField!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var viewCountrySection: UIView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewEmailSection: UIView!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var viewNameSection: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewPasswordSection: UIView!
    weak var viewActive: UIView?

    // Control
    var account: Account?
    var attemptingCreate = false
    let backgroundColor = UIColor.init(red: 74.0/255.0, green: 162.0/255.0, blue: 119.0/255.0, alpha: 1.0)
    let borderColorDefault = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    let borderColorError = UIColor.init(red: 1.0, green: 0.255, blue: 0.212, alpha: 1.0)
    let borderColorSelected = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var borderCountry: CALayer?
    var borderEmail: CALayer?
    var borderName: CALayer?
    var borderPassword: CALayer?

    // Picker control
    var countryList: [Country]?
    var countrySelected = -1

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add gradient to main background
        self.view.setGradient(startColor: backgroundColor, endColor: UIColor.black)

        // Add borders to the view
        viewCountry.layoutIfNeeded()
        borderCountry = viewCountry.layer.addBorder(edge: .bottom, color: borderColorDefault, thickness: 1.0)
        viewEmail.layoutIfNeeded()
        borderEmail = viewEmail.layer.addBorder(edge: .bottom, color: borderColorDefault, thickness: 1.0)
        viewName.layoutIfNeeded()
        borderName = viewName.layer.addBorder(edge: .bottom, color: borderColorDefault, thickness: 1.0)
        viewPassword.layoutIfNeeded()
        borderPassword = viewPassword.layer.addBorder(edge: .bottom, color: borderColorDefault, thickness: 1.0)

        // Connect the country text field to a picker
        let pickerCountry = UIPickerView()
        textCountry.inputView = pickerCountry
        pickerCountry.dataSource = self
        pickerCountry.delegate = self
        pickerCountry.backgroundColor = UIColor.white
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.sizeToFit()
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreateViewController.pickerDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textCountry.inputAccessoryView = toolBar

        // Connects the text fields to this class as delegates
        textCountry.delegate = self
        textEmail.delegate = self
        textName.delegate = self
        textPassword.delegate = self

        // Add observers for the keyboard showing and hiding
        NotificationCenter.default.addObserver(self, selector: #selector(CreateViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Fetch the list of countries
        startAnimating(CGSize.init(width: ANIMATION_SIZE, height: ANIMATION_SIZE), type: NVActivityIndicatorType.orbit)
        Session.countries() { (list, errorString, noNetwork) in
            DispatchQueue.main.async {
                self.updateCountriesList(result: list, error: errorString, noNetwork: noNetwork)
            }
        }
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

    // MARK: - Button Actions

    @IBAction func attemptCreate(_ sender: UIButton) {
        // TODO!
    }

    @IBAction func goBack(_ sender: UIButton) {
        // Resign any responders
        // TODO: Fix. This leaves the keyboard up!
        self.view.endEditing(true)

        dismiss(animated: true, completion: nil)
    }

    @objc func pickerDone() {
        textCountry.resignFirstResponder()
    }

    // MARK: - Picker Delegates

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if countryList != nil {
            return countryList!.count
        } else {
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        countrySelected = row
        return countryList![row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textCountry.text = countryList![row].name
    }

    // MARK: - Text Field Delegates

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == textCountry {
            viewActive = viewCountrySection
            borderCountry?.backgroundColor = borderColorSelected.cgColor
            if countrySelected < 0 && countryList != nil && countryList!.count > 0 {
                textField.text = countryList![0].name
                countrySelected = 0
            }
        }
        else if textField == textEmail {
            viewActive = viewEmailSection
            borderEmail?.backgroundColor = borderColorSelected.cgColor
        }
        else if textField == textName {
            viewActive = viewNameSection
            borderName?.backgroundColor = borderColorSelected.cgColor
        }
        else if textField == textPassword {
            viewActive = viewPasswordSection
            borderPassword?.backgroundColor = borderColorSelected.cgColor
        }

        // TODO: Need to update the keyboard checks even if the size doesn't change
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        viewActive = nil
        if textField == textCountry {
            borderCountry?.backgroundColor = borderColorDefault.cgColor
            labelCountryError.isHidden = true
        }
        else if textField == textEmail {
            borderEmail?.backgroundColor = borderColorDefault.cgColor
            labelEmailError.isHidden = true
        }
        else if textField == textName {
            borderName?.backgroundColor = borderColorDefault.cgColor
            labelNameError.isHidden = true
        }
        else if textField == textPassword {
            borderPassword?.backgroundColor = borderColorDefault.cgColor
            labelPasswordError.isHidden = true
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if attemptingCreate {
            return true
        }

        if textField == textCountry {
            var isError = false
            if let countryText = textField.text {
                if !isValidCountry(countryText) {
                    isError = true
                }
            } else {
                isError = true
            }

            if isError {
                setCountryError()
                return false
            }
        }
        else if textField == textEmail {
            var isError = false
            if let emailText = textField.text {
                if !StringHelper.isValidEmail(emailText) {
                    isError = true
                }
            } else {
                isError = true
            }

            if isError {
                setEmailError(preValidation: true)
                return false
            }
        }
        else if textField == textName {
            var isError = false
            if let nameText = textField.text {
                if !isValidName(nameText) {
                    isError = true
                }
            } else {
                isError = true
            }

            if isError {
                setNameError()
                return false
            }
        }
        else if textField == textPassword {
            var isError = false
            if let passwordText = textField.text {
                if !StringHelper.isValidPassword(passwordText, strong: true) {
                    isError = true
                }
            } else {
                isError = true
            }

            if isError {
                setPasswordError()
                return false
            }
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textName {
            textEmail.becomeFirstResponder()
        }
        else if textField == textEmail {
            textPassword.becomeFirstResponder()
        }
        else if textField == textPassword {
            textCountry.becomeFirstResponder()
        }
        else if textField == textCountry {
            textCountry.resignFirstResponder()
        }

        return true
    }

    // MARK: - Keyboard Control

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if viewActive != nil {
                let textBottom = viewActive!.frame.origin.y + viewActive!.frame.height
                let validScreen = self.view.frame.height - keyboardSize.height
                if validScreen < textBottom {
                    self.view.frame.origin.y = (-keyboardSize.height + CGFloat.init(KEYBOARD_COVERAGE))
                    buttonBack.isHidden = true
                    labelTitle.isHidden = true
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        buttonBack.isHidden = false
        labelTitle.isHidden = false
    }

    // MARK: - Internals

    func isValidCountry(_ country: String) -> Bool {
        // TODO: Replace with list validation!
        return country.count > 1
    }

    func isValidName(_ name: String) -> Bool {
        return name.count > 1
    }

    func setCountryError() {
        borderCountry?.backgroundColor = borderColorError.cgColor
        labelCountryError.textColor = borderColorError
        labelCountryError.text = "Your home country is required"
        labelCountryError.isHidden = false
    }

    func setEmailError(preValidation: Bool) {
        borderEmail?.backgroundColor = borderColorError.cgColor
        labelEmailError.textColor = borderColorError
        if preValidation {
            labelEmailError.text = "A valid email is required"
        } else {
            labelEmailError.text = "This email is already in use"
        }
        labelEmailError.isHidden = false
    }

    func setNameError() {
        borderName?.backgroundColor = borderColorError.cgColor
        labelNameError.textColor = borderColorError
        labelNameError.text = "Your name is required"
        labelNameError.isHidden = false
    }

    func setPasswordError() {
        borderPassword?.backgroundColor = borderColorError.cgColor
        labelPasswordError.textColor = borderColorError
        labelPasswordError.text = "The password must be at least 8 characters"
        labelPasswordError.isHidden = false
    }

    func updateCountriesList(result: [Country]?, error: String?, noNetwork: Bool) {
        stopAnimating()
        countryList = result
        if countryList == nil || countryList!.count == 0 {
            let alert = UIAlertController(title: "No Network", message: "A network connection is required to create an account", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//
//  CreateViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-10.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, NVActivityIndicatorViewable {
    // Statics
    private let ANIMATION_SIZE = 90
    private let BACKGROUND_COLOR = UIColorCompat(red: 74.0/255.0, green: 162.0/255.0, blue: 119.0/255.0, alpha: 1.0)
    private let BORDER_COLOR_DEFAULT = UIColorCompat(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    private let BORDER_COLOR_ERROR = UIColorCompat(red: 1.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    private let BORDER_COLOR_SELECTED = UIColorCompat(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    private let UNWIND_SEGUE = "unwindToLogin"

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
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewTitle: UIView!
    weak var textActive: UITextField?

    // Control
    var account: Account?
    var attemptingCreate = false
    var borderCountry: CALayer?
    var borderEmail: CALayer?
    var borderName: CALayer?
    var borderPassword: CALayer?
    var checkIgnored = false

    // Model
    var coreModel: CoreModelController!

    // Picker control
    var countryList: [Country]?
    var countrySelected = -1

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the country data, if relevant
        countryList = coreModel.supportedCountries

        // Add gradient to main background
        //self.view.setGradient(startColor: backgroundColor, endColor: UIColor.black)

        // Add borders to the view
        viewCountry.layoutIfNeeded()
        borderCountry = viewCountry.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT.get(), thickness: 1.0)
        viewEmail.layoutIfNeeded()
        borderEmail = viewEmail.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT.get(), thickness: 1.0)
        viewName.layoutIfNeeded()
        borderName = viewName.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT.get(), thickness: 1.0)
        viewPassword.layoutIfNeeded()
        borderPassword = viewPassword.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT.get(), thickness: 1.0)

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

        // Connect the view title click
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.titleClick))
        viewTitle.addGestureRecognizer(gesture)

        // Add observers for the keyboard showing and hiding
        NotificationCenter.default.addObserver(self, selector: #selector(CreateViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Fetch the list of countries, if it hasn't been fetched already
        if countryList == nil || countryList!.count == 0 {
            startAnimating(CGSize.init(width: ANIMATION_SIZE, height: ANIMATION_SIZE), type: NVActivityIndicatorType.orbit)
            Session.countries() { (list, errorString, noNetwork) in
                DispatchQueue.main.async {
                    self.updateCountriesList(result: list, error: errorString, noNetwork: noNetwork)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        checkIgnored = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Actions

    @IBAction func attemptCreate(_ sender: UIButton) {
        if attemptingCreate {
            return
        }
        attemptingCreate = true

        // Resign any responders
        self.view.endEditing(true)
        textFieldReset(border: borderCountry, label: labelCountryError)
        textFieldReset(border: borderEmail, label: labelEmailError)
        textFieldReset(border: borderName, label: labelNameError)
        textFieldReset(border: borderPassword, label: labelPasswordError)

        // Name validation
        let nameValid = textFieldIsValid(textName)

        // Email validation
        var emailValid = false
        if nameValid {
            emailValid = textFieldIsValid(textEmail)
        }

        // Password validation
        var passwordValid = false
        if emailValid {
            passwordValid = textFieldIsValid(textPassword)
        }

        // Country validation
        var countryValid = false
        if passwordValid {
            countryValid = textFieldIsValid(textCountry)
        }

        // Proceed if all are valid
        var attemptStarted = false
        if nameValid && emailValid && passwordValid && countryValid {
            attemptStarted = true
            attemptCreateToServer()
        }
        if attemptStarted {
            startAnimating(CGSize.init(width: 90, height: 90), type: NVActivityIndicatorType.orbit)
        } else {
            attemptingCreate = false
        }
    }

    @IBAction func goBack(_ sender: UIButton) {
        checkIgnored = true
        if textActive != nil {
            textActive!.resignFirstResponder()
        }
        performSegue(withIdentifier: UNWIND_SEGUE, sender: self)
    }

    @objc func pickerDone() {
        textCountry.resignFirstResponder()
    }

    @objc func titleClick() {
        checkIgnored = true
        if textActive != nil {
            textActive!.resignFirstResponder()
        }
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
        textActive = textField

        if textField == textCountry {
            borderCountry?.backgroundColor = BORDER_COLOR_SELECTED.getCG()
            if countrySelected < 0 && countryList != nil && countryList!.count > 0 {
                textField.text = countryList![0].name
                countrySelected = 0
            }
        }
        else if textField == textEmail {
            borderEmail?.backgroundColor = BORDER_COLOR_SELECTED.getCG()
        }
        else if textField == textName {
            borderName?.backgroundColor = BORDER_COLOR_SELECTED.getCG()
        }
        else if textField == textPassword {
            borderPassword?.backgroundColor = BORDER_COLOR_SELECTED.getCG()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textActive = nil

        if textField == textCountry {
            textFieldReset(border: borderCountry, label: labelCountryError)
        }
        else if textField == textEmail {
            textFieldReset(border: borderEmail, label: labelEmailError)
        }
        else if textField == textName {
            textFieldReset(border: borderName, label: labelNameError)
        }
        else if textField == textPassword {
            textFieldReset(border: borderPassword, label: labelPasswordError)
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if attemptingCreate {
            return true
        }
        if checkIgnored {
            checkIgnored = false
            return true
        }

        return textFieldIsValid(textField)
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewBottom = viewCountrySection.frame.origin.y + viewCountrySection.frame.height
            let viewChange = keyboardSize.origin.y - viewBottom
            self.view.frame.origin.y = viewChange

            buttonBack.isHidden = true
            labelTitle.isHidden = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        buttonBack.isHidden = false
        labelTitle.isHidden = false
    }

    // MARK: - Internals

    func attemptCreateToServer() {
        // Create the register request
        coreModel.userInfo = UserInfo(name: textName.text!, email: textEmail.text!.lowercased(), countryCode: countryList![countrySelected].code!)
        let registerRequest = RegisterRequest.init(name: coreModel.userInfo!.name!, email: coreModel.userInfo!.email, password: textPassword.text!, country: coreModel.userInfo!.countryCode!, deviceId: coreModel.account.deviceId!)

        // Start the request
        Session.borrowerCreate(input: registerRequest) { (response, errorString, noNetwork, emailExists) in

            DispatchQueue.main.async {
                self.updateCreateResult(result: response, error: errorString, noNetwork: noNetwork, emailExists: emailExists)
            }
        }
    }

    func isValidCountry(_ country: String) -> Bool {
        return countrySelected >= 0 && countrySelected < countryList!.count && countryList![countrySelected].name == country
    }

    func isValidName(_ name: String) -> Bool {
        return name.count > 1
    }

    func setCountryError(_ error: String?) {
        borderCountry?.backgroundColor = BORDER_COLOR_ERROR.getCG()
        labelCountryError.textColor = BORDER_COLOR_ERROR.get()
        if error != nil {
            labelCountryError.text = error
        } else {
            labelCountryError.text = "Your home country is required"
        }
        labelCountryError.isHidden = false
    }

    func setEmailError(preValidation: Bool) {
        borderEmail?.backgroundColor = BORDER_COLOR_ERROR.getCG()
        labelEmailError.textColor = BORDER_COLOR_ERROR.get()
        if preValidation {
            labelEmailError.text = "A valid email is required"
        } else {
            labelEmailError.text = "This email is already in use"
        }
        labelEmailError.isHidden = false
    }

    func setNameError() {
        borderName?.backgroundColor = BORDER_COLOR_ERROR.getCG()
        labelNameError.textColor = BORDER_COLOR_ERROR.get()
        labelNameError.text = "Your name is required"
        labelNameError.isHidden = false
    }

    func setPasswordError() {
        borderPassword?.backgroundColor = BORDER_COLOR_ERROR.getCG()
        labelPasswordError.textColor = BORDER_COLOR_ERROR.get()
        labelPasswordError.text = "The password must be at least 8 characters"
        labelPasswordError.isHidden = false
    }

    func textFieldIsValid(_ textField: UITextField) -> Bool {
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
                setCountryError(nil)
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

    func textFieldReset(border: CALayer?, label: UILabel) {
        border?.backgroundColor = BORDER_COLOR_DEFAULT.getCG()
        label.text = "Error text"
        label.isHidden = true
    }

    func updateCreateResult(result: AuthResponse?, error: String?, noNetwork: Bool, emailExists: Bool) {
        stopAnimating()

        if result != nil && result!.isValid() {
            coreModel.account.sessionKey = result!.sessionKey
            coreModel.account.userKey = result!.userKey

            performSegue(withIdentifier: UNWIND_SEGUE, sender: self)
        } else {
            attemptingCreate = false

            if noNetwork {
                let alert = UIAlertController(title: "No Network", message: "A network connection is required to create", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if emailExists {
                setEmailError(preValidation: false)
            } else {
                setCountryError(error)
            }
        }
    }

    func updateCountriesList(result: [Country]?, error: String?, noNetwork: Bool) {
        stopAnimating()
        countryList = result
        coreModel.supportedCountries = countryList
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

//
//  LoginViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-05.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {
    // Statics
    private let BORDER_COLOR_DEFAULT = UIColorCompat(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    private let BORDER_COLOR_ERROR = UIColorCompat(red: 1.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    private let BORDER_COLOR_SELECTED = UIColorCompat(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    private let SMALL_PHONE_HEIGHT: CGFloat = 500.0

    // UI
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var labelEmailError: UILabel!
    @IBOutlet weak var labelPasswordError: UILabel!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var viewControl: UIView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewPasswordSection: UIView!

    // Control
    var attemptingLogin = false
    var borderEmail: CALayer?
    var borderPassword: CALayer?
    var checkIgnored = false

    // Model
    var coreModel: CoreModelController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the initial core model
        coreModel = CoreModelController()

        // Add gradient to main background
        //let colorGreen = UIColor.init(red: 74.0/255.0, green: 162.0/255.0, blue: 119.0/255.0, alpha: 1.0)
        //self.view.setGradient(startColor: colorGreen, endColor: UIColor.black)

        // Add borders to the view
        viewEmail.layoutIfNeeded()
        borderEmail = viewEmail.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT.get(), thickness: 1.0)
        viewPassword.layoutIfNeeded()
        borderPassword = viewPassword.layer.addBorder(edge: .bottom, color: BORDER_COLOR_DEFAULT.get(), thickness: 1.0)
        
        // Connects the text fields to this class as delegates
        textEmail.delegate = self
        textPassword.delegate = self

        // Add observers for the keyboard showing and hiding
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        // Check if log in needs to be displayed
        if !coreModel.isLoggedIn() {
            showControls()
        } else {
            fetchInfo()
        }
        checkIgnored = false
    }

    override func viewWillAppear(_ animated: Bool) {
        // Clean up the view (remove all old text)
        textEmail.text = nil
        textPassword.text = nil

        // Hide the view control until it can be determined if a login is required
        if coreModel.isLoggedIn() {
            viewControl.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Create view
        if let createViewController = segue.destination as? CreateViewController {
            createViewController.coreModel = coreModel
        }
        // Details view
        else if let detailsViewController = segue.destination as? DetailsViewController {
            detailsViewController.coreModel = coreModel
        }
        // Main navigation
        else if let mainNavController = segue.destination as? MainNavController {
            mainNavController.coreModel = coreModel
        }
        // Welcome navigation
        else if let welcomeNavController = segue.destination as? WelcomeNavController {
            welcomeNavController.coreModel = coreModel
        }
    }

    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        // Make sure the context is saved and then re-fetch the core model
        CoreDataStack.saveContext()
        coreModel = CoreModelController()
    }

    // MARK: - Button Actions
    
    @IBAction func attemptLogin(_ sender: UIButton) {
        if attemptingLogin {
            return
        }
        attemptingLogin = true

        // Resign any responders
        self.view.endEditing(true)

        // Email validation
        var emailValid = false
        if let emailText = textEmail.text {
            if StringHelper.isValidEmail(emailText) {
                emailValid = true
            }
        }
        if !emailValid {
            setEmailError()
        }
        
        // Password validation (only if email is valid)
        var passwordValid = false
        if emailValid {
            if let passwordText = textPassword.text {
                if StringHelper.isValidPassword(passwordText) {
                    passwordValid = true
                }
            }
            if !passwordValid {
                setPasswordError(preValidation: true)
            }
        }

        // Proceed if both are valid
        var attemptStarted = false
        if emailValid && passwordValid {
            attemptStarted = true
            attemptLoginToServer()
        }
        if attemptStarted {
            startAnimating(CGSize.init(width: 90, height: 90), type: NVActivityIndicatorType.orbit)
        } else {
            attemptingLogin = false
        }
    }

    @IBAction func showCreate(_ sender: UIButton) {
        checkIgnored = true
        performSegue(withIdentifier: "showCreate", sender: self)
    }

    @IBAction func showForgotPassword(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Coming soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Text Field Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == textEmail {
            borderEmail?.backgroundColor = BORDER_COLOR_SELECTED.getCG()
        }
        else if textField == textPassword {
            borderPassword?.backgroundColor = BORDER_COLOR_SELECTED.getCG()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textEmail {
            borderEmail?.backgroundColor = BORDER_COLOR_DEFAULT.getCG()
            labelEmailError.text = "Error text"
            labelEmailError.isHidden = true
        }
        else if textField == textPassword {
            borderPassword?.backgroundColor = BORDER_COLOR_DEFAULT.getCG()
            labelPasswordError.text = "Error text"
            labelPasswordError.isHidden = true
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if attemptingLogin {
            return true
        }
        if checkIgnored {
            checkIgnored = false
            return true
        }

        if textField == textEmail {
            var isError = false
            if let emailText = textField.text {
                if !StringHelper.isValidEmail(emailText) {
                    isError = true
                }
            } else {
                isError = true
            }
            
            if isError {
                setEmailError()
                return false
            }
        }
        else if textField == textPassword {
            var isError = false
            if let passwordText = textField.text {
                if !StringHelper.isValidPassword(passwordText) {
                    isError = true
                }
            } else {
                isError = true
            }
            
            if isError {
                setPasswordError(preValidation: true)
                return false
            }
        }
        
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textEmail {
            textPassword.becomeFirstResponder()
        }
        else if textField == textPassword {
            textPassword.resignFirstResponder()
        }
        
        return true
    }

    // MARK: - Keyboard Control

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            imageLogo.isHidden = true
            if self.view.frame.height < SMALL_PHONE_HEIGHT {
                let frame = self.view.convert(viewPasswordSection.frame, from: viewControl)
                let passBottom = frame.origin.y + frame.height
                let diffFromBottom = self.view.frame.height - passBottom
                self.view.frame.origin.y = -(keyboardSize.height -  diffFromBottom)
            } else {
                self.view.frame.origin.y = -keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        imageLogo.isHidden = false
    }

    // MARK: - Internals
    
    func attemptLoginToServer() {
        // Initiate the session
        Session.borrowerLogin(input: AuthRequest.init(email: textEmail.text!.lowercased(), password: textPassword.text!, deviceId: coreModel.account.deviceId!)) { (response, errorString, noNetwork) in
            // Process the data
            var success = false
            if response != nil && response!.isValid() {
                self.coreModel.authenticate(response!)
                CoreDataStack.saveContext()
                success = true
            }

            // Send the result to the main UI thread
            DispatchQueue.main.async {
                self.updateLoginResult(success: success, error: errorString, noNetwork: noNetwork)
            }
        }
    }

    func fetchInfo() {
        Session.borrowerInfo(account: coreModel.account) { (borrowerInfo, errorString, noNetwork, unauthorized) in
            // Process the data
            var success = false
            if borrowerInfo != nil && borrowerInfo!.isValid() {
                self.coreModel.updateUserInfo(from: borrowerInfo!)
                success = true
            } else if unauthorized {
                self.coreModel.clear()
            }

            // Send the result to the main UI thread
            DispatchQueue.main.async {
                self.updateInfoResult(success: success, error: errorString, noNetwork: noNetwork, unauthorized: unauthorized)
            }
        }
    }

    func setEmailError() {
        borderEmail?.backgroundColor = BORDER_COLOR_ERROR.getCG()
        labelEmailError.textColor = BORDER_COLOR_ERROR.get()
        labelEmailError.text = "A valid email is required"
        labelEmailError.isHidden = false
    }

    func setPasswordError(preValidation: Bool, error: String? = nil) {
        borderPassword?.backgroundColor = BORDER_COLOR_ERROR.getCG()
        labelPasswordError.textColor = BORDER_COLOR_ERROR.get()
        if preValidation {
            labelPasswordError.text = "A valid password is required"
        } else {
            if error != nil {
                labelPasswordError.text = error!
            } else {
                labelPasswordError.text = "The username or password is invalid"
            }
        }
        labelPasswordError.isHidden = false
    }

    func showControls() {
        if viewControl.isHidden {
            viewControl.alpha = 0.0
            viewControl.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.viewControl.alpha = 1.0
            }, completion:  nil)
        }
    }

    func showErrorAlert() {
        let alert = UIAlertController(title: "No Network", message: "A network connection is required to log in", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func updateInfoResult(success: Bool, error: String?, noNetwork: Bool, unauthorized: Bool) {
        attemptingLogin = false
        stopAnimating()

        if success {
            if coreModel.hasValidDetails() && coreModel.hasBankConnections() && coreModel.hasSubmittedAssessment() {
                performSegue(withIdentifier: "showMain", sender: self)
            } else if coreModel.hasValidDetails() {
                performSegue(withIdentifier: "showWelcome", sender: self)
            } else {
                performSegue(withIdentifier: "showDetails", sender: self)
            }
        } else {
            if unauthorized {
                showControls()
            } else {
                showErrorAlert()
            }
        }
    }

    func updateLoginResult(success: Bool, error: String?, noNetwork: Bool) {
        if success {
            fetchInfo()
        } else {
            attemptingLogin = false
            stopAnimating()
            
            if noNetwork {
                showErrorAlert()
            } else {
                setPasswordError(preValidation: false, error: error)
            }
        }
    }
}

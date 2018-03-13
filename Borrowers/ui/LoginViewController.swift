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
    // UI
    @IBOutlet weak var labelEmailError: UILabel!
    @IBOutlet weak var labelPasswordError: UILabel!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!

    // Control
    var account: Account?
    var attemptingLogin = false
    var borderColorDefault = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    var borderColorError = UIColor.init(red: 1.0, green: 0.255, blue: 0.212, alpha: 1.0)
    var borderColorSelected = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var borderEmail: CALayer?
    var borderPassword: CALayer?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add gradient to main background
        let colorGreen = UIColor.init(red: 74.0/255.0, green: 162.0/255.0, blue: 119.0/255.0, alpha: 1.0)
        self.view.setGradient(startColor: colorGreen, endColor: UIColor.black)

        // Add borders to the view
        viewEmail.layoutIfNeeded()
        borderEmail = viewEmail.layer.addBorder(edge: .bottom, color: borderColorDefault, thickness: 1.0)
        viewPassword.layoutIfNeeded()
        borderPassword = viewPassword.layer.addBorder(edge: .bottom, color: borderColorDefault, thickness: 1.0)
        
        // Connects the text fields to this class as delegates
        textEmail.delegate = self
        textPassword.delegate = self

        // Add observers for the keyboard showing and hiding
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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

    @IBAction func showForgotPassword(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Coming soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Text Field Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == textEmail {
            borderEmail?.backgroundColor = borderColorSelected.cgColor
        }
        else if textField == textPassword {
            borderPassword?.backgroundColor = borderColorSelected.cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textEmail {
            borderEmail?.backgroundColor = borderColorDefault.cgColor
            labelEmailError.isHidden = true
        }
        else if textField == textPassword {
            borderPassword?.backgroundColor = borderColorDefault.cgColor
            labelPasswordError.isHidden = true
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if attemptingLogin {
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = -keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

    // MARK: - Internals
    
    func attemptLoginToServer() {
        // Fetch the account
        if account == nil {
            account = Account.getOrCreate()
        }

        // Initiate the session
        Session.borrowerLogin(input: AuthRequest.init(email: textEmail.text!.lowercased(), password: textPassword.text!, deviceId: account!.deviceId!)) { (response, errorString, noNetwork) in

            DispatchQueue.main.async {
                self.updateLoginResult(result: response, error: errorString, noNetwork: noNetwork)
            }
        }
    }

    func setEmailError() {
        borderEmail?.backgroundColor = borderColorError.cgColor
        labelEmailError.textColor = borderColorError
        labelEmailError.text = "A valid email is required"
        labelEmailError.isHidden = false
    }

    func setPasswordError(preValidation: Bool, error: String? = nil) {
        borderPassword?.backgroundColor = borderColorError.cgColor
        labelPasswordError.textColor = borderColorError
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

    func updateLoginResult(result: AuthResponse?, error: String?, noNetwork: Bool) {
        if result != nil && result!.isValid() {

            // TODO: Process the result!

        } else {
            attemptingLogin = false
            stopAnimating()
            
            if noNetwork {
                let alert = UIAlertController(title: "No Network", message: "A network connection is required to log in", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                setPasswordError(preValidation: false, error: error)
            }
        }
    }
}

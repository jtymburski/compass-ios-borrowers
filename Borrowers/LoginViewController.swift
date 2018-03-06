//
//  LoginViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-05.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    // UI
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textEmailError: UITextView!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textPasswordError: UITextView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    
    // Control
    var attemptingLogin = false
    var borderColorDefault = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    var borderColorError = UIColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
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
            if isValidEmail(emailText) {
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
                if isValidPassword(passwordText) {
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
            attemptStarted = attemptLoginToServer()
        }
        if !attemptStarted {
            attemptingLogin = false
        }
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
            textEmailError.text = nil
        }
        else if textField == textPassword {
            borderPassword?.backgroundColor = borderColorDefault.cgColor
            textPasswordError.text = nil
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if attemptingLogin {
            return true
        }
        
        if textField == textEmail {
            var isError = false
            if let emailText = textField.text {
                if !isValidEmail(emailText) {
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
                if !isValidPassword(passwordText) {
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
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    // MARK: - Helpers
    
    func attemptLoginToServer() -> Bool {
        let Url = "https://first-project-196541.appspot.com/core/v1/borrowers/login"
        guard let serviceUrl = URL(string: Url) else { return false }
        let inputJson = ["email" : textEmail.text!, "password" : textPassword.text!, "device_id" : "e7f9b371-74fa-4532-900d-2983b6e0e8ac"]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: inputJson, options: []) else {
            return false
        }
        request.httpBody = httpBody

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                }catch {
                    print(error)
                }
            }
        }.resume()
 
//        let urlString = "https://first-project-196541.appspot.com/core/v1/borrowers/login"
//        guard let url = URL(string: urlString) else { return }
//
//        URLSession.shared.
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if error != nil {
//                print(error!.localizedDescription)
//            }
//
//            guard let data = data else { return }
            //Implement JSON decoding and parsing
//            do {
//                //Decode retrived data with JSONDecoder and assing type of Article object
//                let articlesData = try JSONDecoder().decode([Article].self, from: data)
//
//                //Get back to the main queue
//                DispatchQueue.main.async {
//                    //print(articlesData)
//                    self.articles = articlesData
//                    self.collectionView?.reloadData()
//                }
//
//            } catch let jsonError {
//                print(jsonError)
//            }
//        }.resume()
        
        return true
    }

    func isValidEmail(_ testStr: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: testStr)
    }
    
    func isValidPassword(_ testStr: String) -> Bool {
        return testStr.count > 0
    }

    func setEmailError() {
        borderEmail?.backgroundColor = borderColorError.cgColor
        textEmailError.textColor = borderColorError
        textEmailError.text = "A valid email is required"
    }
    
    func setPasswordError(preValidation: Bool) {
        borderPassword?.backgroundColor = borderColorError.cgColor
        textPasswordError.textColor = borderColorError
        if preValidation {
            textPasswordError.text = "A valid password is required"
        } else {
            textPasswordError.text = "The username or password is invalid"
        }
    }
}

// MARK: - Extensions

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) -> CALayer {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;

        self.addSublayer(border)
        
        return border
    }
}

extension UIView
{
    func setGradient(startColor:UIColor,endColor:UIColor)
    {
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
}


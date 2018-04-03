//
//  BankCreateViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-27.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class BankCreateViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, NVActivityIndicatorViewable {
    private let ANIMATION_SIZE = 90
    private let MIN_ACCOUNT_LENGTH = 5
    private let MIN_TRANSIT_LENGTH = 3
    private let UNWIND_SEGUE = "unwindToWelcome"

    // UI
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var textAccount: UITextField!
    @IBOutlet weak var textBank: UITextField!
    @IBOutlet weak var textTransit: UITextField!

    // Control
    var attemptingCreate = false

    // Model
    var coreModel: CoreModelController!

    // Picker control
    var bankList: [Bank]?
    var bankSelected = -1

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the country data, if relevant
        bankList = coreModel.supportedBanks

        // Connect the country text field to a picker
        let pickerBank = UIPickerView()
        textBank.inputView = pickerBank
        pickerBank.dataSource = self
        pickerBank.delegate = self

        // Text field delegates
        textAccount.addTarget(self, action: #selector(BankCreateViewController.textFieldDidChange(_:)), for: .editingChanged)
        textBank.addTarget(self, action: #selector(BankCreateViewController.textFieldDidChange(_:)), for: .editingChanged)
        textBank.delegate = self
        textTransit.addTarget(self, action: #selector(BankCreateViewController.textFieldDidChange(_:)), for: .editingChanged)

        // Fetch the list of banks, if it hasn't been fetched already
        if bankList == nil || bankList!.count == 0 {
            startAnimating(CGSize.init(width: ANIMATION_SIZE, height: ANIMATION_SIZE), type: NVActivityIndicatorType.orbit)
            Session.banks(userInfo: coreModel.userInfo!) { (list, errorString, noNetwork) in
                DispatchQueue.main.async {
                    self.updateBanksList(result: list, error: errorString, noNetwork: noNetwork)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions

    @IBAction func onBankSave(_ sender: UIBarButtonItem) {
        if attemptingCreate {
            return
        }
        attemptingCreate = true
        self.view.endEditing(true)
        startAnimating(CGSize.init(width: 90, height: 90), type: NVActivityIndicatorType.orbit)

        // Create the bank create info
        let bankId = bankList![bankSelected].id
        let transit = Int(textTransit.text!)
        let account = Int(textAccount.text!)
        // TODO: This login ID should be a real value from flinks.io
        let loginId = UUID().uuidString
        let bankInfo = BankConnectionNew(bankId: bankId, transit: transit, account: account, loginId: loginId)

        // Start the request
        Session.bankCreate(account: coreModel.account, input: bankInfo) { (response, errorString, noNetwork, unauthorized) in
            DispatchQueue.main.async {
                self.updateCreateResult(result: response, error: errorString, noNetwork: noNetwork, unauthorized: unauthorized)
            }
        }
    }

    // MARK: - Picker Delegates

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if bankList != nil {
            return bankList!.count
        } else {
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        bankSelected = row
        return bankList![row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textBank.text = bankList![row].name
    }

    // MARK: - Text Field Delegates

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == textBank {
            if bankSelected < 0 && bankList != nil && bankList!.count > 0 {
                textField.text = bankList![0].name
                bankSelected = 0
            }
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        buttonSave.isEnabled = textAccount.text != nil && textAccount.text!.count >= MIN_ACCOUNT_LENGTH && textBank.text != nil && textBank.text!.count > 0 && textTransit.text != nil && textTransit.text!.count >= MIN_TRANSIT_LENGTH
    }

    // MARK: - Internals

    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func updateBanksList(result: [Bank]?, error: String?, noNetwork: Bool) {
        stopAnimating()
        bankList = result
        coreModel.supportedBanks = bankList
        if bankList == nil || bankList!.count == 0 {
            let alert = UIAlertController(title: "No Network", message: "A network connection is required to add your bank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.UNWIND_SEGUE, sender: self)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func updateCreateResult(result: BankConnectionSummary?, error: String?, noNetwork: Bool, unauthorized: Bool) {
        attemptingCreate = false
        stopAnimating()

        if result != nil && result!.isValid() {
            coreModel.addBankSummary(result!)
            performSegue(withIdentifier: UNWIND_SEGUE, sender: self)
        } else {
            attemptingCreate = false

            if noNetwork {
                showErrorAlert(title: "No Network", message: "A network connection is required to add a bank account")
            } else if unauthorized {
                performSegue(withIdentifier: "unwindToLogin", sender: self)
            } else {
                showErrorAlert(title: "Failed To Create", message: "A new bank account failed to be created. Try again later")
            }
        }
    }
}

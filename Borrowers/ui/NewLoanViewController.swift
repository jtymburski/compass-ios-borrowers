//
//  NewLoanViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-28.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class NewLoanViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, NVActivityIndicatorViewable {
    // Statics
    private let ANIMATION_SIZE = 90
    private let BORDER_FORM = UIColorCompat(red: 231.0/255.0, green: 234.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    private let BORDER_HEADER = UIColorCompat(red: 63.0/255.0, green: 205.0/255.0, blue: 168.0/255.0, alpha: 1.0)
    private let COLOR_BUTTON_DISABLED = UIColorCompat(red: 25.0/255.0, green: 167.0/255.0, blue: 130.0/255.0, alpha: 0.5)
    private let COLOR_BUTTON_ENABLED = UIColorCompat(red: 25.0/255.0, green: 167.0/255.0, blue: 130.0/255.0, alpha: 1.0)
    private let MIN_LOAN_AMOUNT = 100
    private let SEGUE_LOGIN = "unwindToLogin"
    private let SEGUE_TAB_VIEW = "unwindToTabView"

    // UI
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var labelAmountAvailable: UILabel!
    @IBOutlet weak var labelPaymentAmount: UILabel!
    @IBOutlet weak var labelPaymentFrequency: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var noRoomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
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
    var loanAvailableInfo: LoanAvailable?
    var loanResult: LoanInfo?

    // Control
    var amountValue = 0
    var attemptingCreate = false
    var currencyFormatLarge: NumberFormatter!
    var currencyFormatSmall: NumberFormatter!
    var frequencySelected = -1
    var pickerFrequency: UIPickerView?
    var pickerTerm: UIPickerView?
    var termSelected = -1
    var textActive: UITextField?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add borders to the view
        viewAmountAvailable.layoutIfNeeded()
        _ = viewAmountAvailable.layer.addBorder(edge: .right, color: BORDER_HEADER.get(), thickness: 1.0)
        viewAmount.layoutIfNeeded()
        _ = viewAmount.layer.addBorder(edge: .bottom, color: BORDER_FORM.get(), thickness: 1.0)
        viewFrequency.layoutIfNeeded()
        _ = viewFrequency.layer.addBorder(edge: .bottom, color: BORDER_FORM.get(), thickness: 1.0)

        // Currency formatters set-up
        currencyFormatLarge = NumberFormatter()
        currencyFormatLarge.numberStyle = .currency
        currencyFormatLarge.generatesDecimalNumbers = false
        currencyFormatLarge.maximumFractionDigits = 0
        currencyFormatSmall = NumberFormatter()
        currencyFormatSmall.numberStyle = .currency
        currencyFormatSmall.currencySymbol = ""

        // Connections for the UI
        textAmount.delegate = self
        textAmount.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        textFrequency.delegate = self
        textTerm.delegate = self

        // Scroll view click
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.mainViewTap))
        scrollView.addGestureRecognizer(gesture)

        // Add observers for the keyboard showing and hiding
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Start animating to block the UI. In viewDidAppear(), it will be executing an async data fetch
        startAnimating(CGSize.init(width: ANIMATION_SIZE, height: ANIMATION_SIZE), type: NVActivityIndicatorType.orbit)
    }

    override func viewDidAppear(_ animated: Bool) {
        // Fetch the loan create information
        // The core model is not valid until here so this cannot be started in viewDidLoad()
        Session.loanAvailable(account: coreModel.account) { (loanAvailableInfo, errorString, noNetwork, unauthorized) in
            DispatchQueue.main.async {
                self.updateLoanAvailableInfo(info: loanAvailableInfo, error: errorString, noNetwork: noNetwork, unauthorized: unauthorized)
            }
        }
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

    // MARK: - Actions

    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func mainViewTap(_ gestureRecognizer : UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            if textActive != nil {
                textActive!.resignFirstResponder()
            }
        }
    }

    @IBAction func submitClicked(_ sender: UIButton) {
        if !attemptingCreate && isValidInput() {
            // Resign responders
            if textActive != nil {
                textActive!.resignFirstResponder()
            }

            // Generate the new packet
            let newPacket = LoanNew(bank: coreModel.bankConnections?[0].reference, principal: amountValue, amortization: loanAvailableInfo?.amortizations?[termSelected].id, frequency: loanAvailableInfo?.frequencies?[frequencySelected].id)
            if newPacket.isValid() {
                // Start the create
                attemptingCreate = true
                startAnimating(CGSize.init(width: ANIMATION_SIZE, height: ANIMATION_SIZE), type: NVActivityIndicatorType.orbit)

                Session.loanCreate(account: coreModel.account, input: newPacket, completionHandler: { (infoPacket, errorString, noNetwork, unauthorized) in

                    DispatchQueue.main.async {
                        self.updateCreateResult(result: infoPacket, error: errorString, noNetwork: noNetwork, unauthorized: unauthorized)
                    }
                })
            }
        }
    }

    // MARK: - Picker Delegates

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerFrequency {
            if let count = loanAvailableInfo?.frequencies?.count {
                return count
            } else {
                return 0
            }
        } else if pickerView == pickerTerm {
            if let count = loanAvailableInfo?.amortizations?.count {
                return count
            } else {
                return 0
            }
        } else {
            // Just return nothing if the view is not recognized
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerFrequency {
            return loanAvailableInfo?.frequencies?[row].name
        } else if pickerView == pickerTerm {
            return loanAvailableInfo?.amortizations?[row].name
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerFrequency {
            frequencySelected = row
            textFrequency.text = loanAvailableInfo?.frequencies?[row].name
            updatePaymentInfo()
        } else if pickerView == pickerTerm {
            termSelected = row
            textTerm.text = loanAvailableInfo?.amortizations?[row].name
            updatePaymentInfo()
        }
    }

    // MARK: - Text Field Delegates

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textActive = textField

        if textField == textAmount {
            processAmountField()
        } else if textField == textFrequency {
            if frequencySelected < 0 && loanAvailableInfo?.frequencies != nil && loanAvailableInfo!.frequencies!.count > 0 {
                textField.text = loanAvailableInfo?.frequencies?[0].name
                frequencySelected = 0
                updatePaymentInfo()
            }
        } else if textField == textTerm {
            if termSelected < 0 && loanAvailableInfo?.amortizations != nil && loanAvailableInfo!.amortizations!.count > 0 {
                textField.text = loanAvailableInfo?.amortizations?[0].name
                termSelected = 0
                updatePaymentInfo()
            }
        }
    }

    @objc func textFieldDidChange(textField: UITextField) {
        if textField == textAmount {
            processAmountField()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textActive = nil
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

    private func calculatePayment() -> NSNumber {
        return PaymentHelper.paymentPerPeriod(principal: amountValue, rate: loanAvailableInfo!.assessment!.rate!, frequency: loanAvailableInfo!.frequencies![frequencySelected], term: loanAvailableInfo!.amortizations![termSelected])
    }

    private func getFrequencyText() -> String {
        let prefix = "/ "
        if let frequencyName = loanAvailableInfo?.frequencies?[frequencySelected].name {
            return prefix + frequencyName.lowercased()
        } else {
            return prefix + "frequency"
        }
    }

    private func isValidInput() -> Bool {
        return (amountValue >= MIN_LOAN_AMOUNT && frequencySelected >= 0 && termSelected >= 0)
    }

    private func processAmountField() {
        // Determine the amount first and store it
        amountValue = Int(StringHelper.removeAllButNumeric(textAmount.text)) ?? 0

        // Display the value using the formatter
        if amountValue > 0 {
            if let loanCap = loanAvailableInfo?.loanCap {
                let loanCapInt = Int(loanCap)
                if amountValue > loanCapInt {
                    amountValue = loanCapInt
                }
            }
            textAmount.text = currencyFormatLarge.string(from: amountValue as NSNumber)
        } else {
            textAmount.text = "$"
        }

        updatePaymentInfo()
    }

    private func showErrorAlert(title: String, message: String, dismissOnOk: Bool = true) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if dismissOnOk {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func updateLoanAvailableInfo(info: LoanAvailable?, error: String?, noNetwork: Bool, unauthorized: Bool) {
        stopAnimating()
        loanAvailableInfo = info

        if loanAvailableInfo != nil && loanAvailableInfo!.isValid() {
            if loanAvailableInfo!.loanCap! >= Float(MIN_LOAN_AMOUNT) {
                updateBaseView(headerOnly: false)
                scrollView.isHidden = false
            } else {
                updateBaseView(headerOnly: true)
                noRoomView.isHidden = false
            }
        } else {
            if noNetwork {
                showErrorAlert(title: "No Network", message: "A network connection is required to create a new loan application")
            } else if unauthorized {
                performSegue(withIdentifier: SEGUE_LOGIN, sender: self)
            } else {
                showErrorAlert(title: "Application Unavailable", message: "The loan application information could not be fetched. Please try again later")
                if error != nil {
                    print("Loan application info unavailable: \(error!)")
                }
            }
        }
    }

    private func updateBaseView(headerOnly: Bool) {
        // Amount available in header
        labelAmountAvailable.text = currencyFormatLarge.string(from: loanAvailableInfo!.loanCap! as NSNumber)

        // Rate in header
        let rateFormatter = NumberFormatter()
        rateFormatter.numberStyle = .decimal
        rateFormatter.maximumFractionDigits = 1
        labelRate.text = rateFormatter.string(from: loanAvailableInfo!.assessment!.getRatePercent())

        if !headerOnly {
            // Frequency text field custom picker
            if pickerFrequency == nil {
                pickerFrequency = UIPickerView()
                textFrequency.inputView = pickerFrequency
                pickerFrequency!.dataSource = self
                pickerFrequency!.delegate = self
            }

            // Term text field custom picker
            if pickerTerm == nil {
                pickerTerm = UIPickerView()
                textTerm.inputView = pickerTerm
                pickerTerm!.dataSource = self
                pickerTerm!.delegate = self
            }
        }
    }

    private func updateCreateResult(result: LoanInfo?, error: String?, noNetwork: Bool, unauthorized: Bool) {
        attemptingCreate = false
        stopAnimating()

        if result != nil {
            loanResult = result
            performSegue(withIdentifier: SEGUE_TAB_VIEW, sender: self)
        } else {
            if noNetwork {
                showErrorAlert(title: "No Network", message: "A network connection is required to submit a new loan application", dismissOnOk: false)
            } else if unauthorized {
                performSegue(withIdentifier: SEGUE_LOGIN, sender: self)
            } else {
                showErrorAlert(title: "Failed To Submit", message: "A new loan application failed to be submitted. Try again later", dismissOnOk: false)
            }
        }
    }

    private func updatePaymentInfo() {
        if isValidInput() {
            labelPaymentAmount.text = currencyFormatSmall.string(from: calculatePayment())
            labelPaymentFrequency.text = getFrequencyText()

            viewNoPayment.isHidden = true
            viewPayment.isHidden = false

            buttonSubmit.backgroundColor = COLOR_BUTTON_ENABLED.get()
            buttonSubmit.isEnabled = true
        } else {
            viewNoPayment.isHidden = false
            viewPayment.isHidden = true

            buttonSubmit.backgroundColor = COLOR_BUTTON_DISABLED.get()
            buttonSubmit.isEnabled = false
        }
    }
}

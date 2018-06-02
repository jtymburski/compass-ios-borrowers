//
//  NewLoanViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-28.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class NewLoanViewController: UIViewController, NVActivityIndicatorViewable {
    // Statics
    private let ANIMATION_SIZE = 90
    private let BORDER_FORM = UIColorCompat(red: 231.0/255.0, green: 234.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    private let BORDER_HEADER = UIColorCompat(red: 63.0/255.0, green: 205.0/255.0, blue: 168.0/255.0, alpha: 1.0)

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
    var loanAvailableInfo: LoanAvailable?

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

    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Internals

    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func updateLoanAvailableInfo(info: LoanAvailable?, error: String?, noNetwork: Bool, unauthorized: Bool) {
        stopAnimating()
        loanAvailableInfo = info

        if loanAvailableInfo != nil && loanAvailableInfo!.isValid() {
            // Amount available
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.generatesDecimalNumbers = false
            currencyFormatter.maximumFractionDigits = 0
            labelAmountAvailable.text = currencyFormatter.string(from: loanAvailableInfo!.loanCap! as NSNumber)

            // Rate
            let rateFormatter = NumberFormatter()
            rateFormatter.numberStyle = .decimal
            rateFormatter.maximumFractionDigits = 2
            labelRate.text = rateFormatter.string(from: loanAvailableInfo!.assessment!.getRatePercent())
        } else {
            if noNetwork {
                showErrorAlert(title: "No Network", message: "A network connection is required to create a new loan application")
            } else if unauthorized {
                performSegue(withIdentifier: "unwindToLogin", sender: self)
            } else {
                showErrorAlert(title: "Application Unavailable", message: "The loan application information could not be fetched. Please try again later")
                if error != nil {
                    print("Loan application info unavailable: \(error!)")
                }
            }
        }
    }
}

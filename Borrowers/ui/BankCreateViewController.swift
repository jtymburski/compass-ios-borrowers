//
//  BankCreateViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-27.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class BankCreateViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, NVActivityIndicatorViewable {
    private let ANIMATION_SIZE = 90

    // UI
    @IBOutlet weak var textAccount: UITextField!
    @IBOutlet weak var textBank: UITextField!
    @IBOutlet weak var textTransit: UITextField!

    // Model
    var coreModel: CoreModelController!

    // Picker control
    var bankList: [Bank]?
    var bankSelected = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Connect the country text field to a picker
        let pickerBank = UIPickerView()
        textBank.inputView = pickerBank
        pickerBank.dataSource = self
        pickerBank.delegate = self

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions

    @IBAction func onBankListClick(_ sender: UIButton) {
        print("TODO: on bank list click")
    }

    @IBAction func onBankSave(_ sender: UIBarButtonItem) {
        print("TODO: on bank save")
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

    // MARK: - Internals

    func updateBanksList(result: [Bank]?, error: String?, noNetwork: Bool) {
        stopAnimating()
        bankList = result
        coreModel.supportedBanks = bankList
        if bankList == nil || bankList!.count == 0 {
            let alert = UIAlertController(title: "No Network", message: "A network connection is required to add your bank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

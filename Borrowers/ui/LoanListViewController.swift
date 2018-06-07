//
//  LoanListViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-04-04.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class LoanListViewController: UITableViewController {
    // Statics
    private let CELL_ADD = "AddCell"
    private let CELL_LOADING = "LoadingCell"
    private let CELL_LOAN = "LoanCell"
    private let LOADING_COUNT = 3
    private let SEGUE_CREATE = "showCreate"
    private let SEGUE_LOGIN = "unwindToLogin"

    // Model
    var coreModel: CoreModelController!
    var loanList: [LoanSummary]?

    // Control
    var currencyFormat: NumberFormatter!
    var isLoading = false
    var principalFormat: NumberFormatter!
    var rateFormat: NumberFormatter!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Put a blank footer on the table view to allow some margin for scrolling
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 16))
        tableView.tableFooterView = footerView

        // Currency formatters set-up
        currencyFormat = NumberFormatter()
        currencyFormat.numberStyle = .currency
        rateFormat = NumberFormatter()
        rateFormat.numberStyle = .percent
        rateFormat.percentSymbol = ""
        rateFormat.maximumFractionDigits = 1
        principalFormat = NumberFormatter()
        principalFormat.numberStyle = .currency
        principalFormat.generatesDecimalNumbers = false
        principalFormat.maximumFractionDigits = 0
        principalFormat.currencySymbol = ""
    }

    override func viewDidAppear(_ animated: Bool) {
        // Load in information asynchronously (started in appear since the core model needs to be valid)
        if loanList == nil && !isLoading {
            isLoading = true
            tableView.reloadData()

            Session.loanList(account: coreModel.account) { (loanList, errorString, noNetwork, unauthorized) in
                DispatchQueue.main.async {
                    self.updateLoanList(list: loanList, error: errorString, noNetwork: noNetwork, unauthorized: unauthorized)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return LOADING_COUNT
        } else {
            if loanList != nil {
                if loanList!.count <= 1 {
                    return loanList!.count + 1
                } else {
                    return loanList!.count
                }
            } else {
                return 0
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            return tableView.dequeueReusableCell(withIdentifier: CELL_LOADING, for: indexPath)
        } else {
            // TODO: Properly tie to data stack for this index
            if indexPath.row < loanList!.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOAN, for: indexPath) as! LoanListCellLoan
                cell.setData(loanList![indexPath.row], principalFormatter: principalFormat, currencyFormatter: currencyFormat, rateFormatter: rateFormat)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ADD, for: indexPath) as! LoanListCellAdd
                cell.isOnlyCell(loanList!.count == 0)
                return cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cellLoan = cell as? LoanListCellLoan {
            cellLoan.willDisplay()
        }
    }

    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let cellAdd = cell as? LoanListCellAdd {
                cellAdd.setHighlighted(true)
            } else if let cellLoan = cell as? LoanListCellLoan {
                cellLoan.setHighlighted(true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let cellAdd = cell as? LoanListCellAdd {
                cellAdd.setHighlighted(false)
            } else if let cellLoan = cell as? LoanListCellLoan {
                cellLoan.setHighlighted(false)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Process the select
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell is LoanListCellAdd {
                performSegue(withIdentifier: SEGUE_CREATE, sender: self)
            } else if let cellLoan = cell as? LoanListCellLoan {
                // TODO: Process the loan cell click
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // New loan nav controller
        if let newLoanNavController = segue.destination as? NewLoanNavController {
            if newLoanNavController.coreModel == nil {
                newLoanNavController.coreModel = coreModel
            }
        }
    }

    // MARK: - Internals

    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func sortLoanList() {
        if loanList != nil {
            loanList!.sort(by: { (first, second) -> Bool in
                let firstInProgress = first.isInProgress()
                let secondInProgress = second.isInProgress()
                if firstInProgress && secondInProgress {
                    // Both valid and in progress
                    return first.nextPayment!.dueDate! < second.nextPayment!.dueDate!
                } else if firstInProgress {
                    // Only first is valid. Show above
                    return true
                } else if secondInProgress {
                    // Only second is valid. Show below
                    return false
                } else {
                    // Both are either completed, pending, or cancelled. Sort by started
                    return (first.started ?? 0) < (second.started ?? 0)
                }
            })
        }
    }

    private func updateLoanList(list: [LoanSummary]?, error: String?, noNetwork: Bool, unauthorized: Bool) {
        if list != nil {
            loanList = list
            sortLoanList()
        } else {
            if noNetwork {
                // TODO: Display error or no network conditions in the loan list with a load button or something similar
                showErrorAlert(title: "No Network", message: "A network connection is required to fetch the list of loans application")
            } else if unauthorized {
                performSegue(withIdentifier: SEGUE_LOGIN, sender: self)
            }
        }

        isLoading = false
        tableView.reloadData()
    }

    // MARK: - Externals

    func addLoan(_ loanInfo: LoanInfo) {
        if loanList != nil {
            loanList!.append(loanInfo.getSummary())
        } else {
            loanList = [ loanInfo.getSummary() ]
        }
        sortLoanList()
        tableView.reloadData()
    }
}

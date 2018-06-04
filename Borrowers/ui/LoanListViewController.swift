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

    // Model
    var coreModel: CoreModelController!

    // Control
    var isLoading = true

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Put a blank footer on the table view to allow some margin for scrolling
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 16))
        tableView.tableFooterView = footerView
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
            // TODO: Tie to data stack count
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            return tableView.dequeueReusableCell(withIdentifier: CELL_LOADING, for: indexPath)
        } else {
            // TODO: Properly tie to data stack for this index
            return tableView.dequeueReusableCell(withIdentifier: CELL_LOAN, for: indexPath)
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
            if let cellLoan = cell as? LoanListCellLoan {
                // TODO: Process the loan cell
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

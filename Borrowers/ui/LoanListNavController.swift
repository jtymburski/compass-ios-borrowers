//
//  LoanListNavController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-29.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class LoanListNavController: UINavigationController, UINavigationControllerDelegate {
    // Model
    var coreModel: CoreModelController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Pass along the model
        // Loan list view controller
        if let loanListViewController = viewController as? LoanListViewController {
            if loanListViewController.coreModel == nil {
                loanListViewController.coreModel = coreModel
            }
        }
    }
}

//
//  NewLoanNavController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-28.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class NewLoanNavController: UINavigationController, UINavigationControllerDelegate {

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
        // New loan view controller
        if let newLoanViewController = viewController as? NewLoanViewController {
            if newLoanViewController.coreModel == nil {
                newLoanViewController.coreModel = coreModel
            }
        }
    }
}

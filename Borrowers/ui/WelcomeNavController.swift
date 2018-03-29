//
//  WelcomeNavController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-27.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class WelcomeNavController: UINavigationController, UINavigationControllerDelegate {

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

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Pass along the model
        // Initial welcome view display (root view). Setting the model
        if let welcomeViewController = viewController as? WelcomeViewController {
            if welcomeViewController.coreModel == nil {
                welcomeViewController.coreModel = coreModel
            }
        }

        // Hide the nav bar if going home
        if viewController is WelcomeViewController {
            navigationController.setNavigationBarHidden(true, animated: animated)
        } else {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
    }
}

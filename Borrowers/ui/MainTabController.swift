//
//  MainTabController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-04-01.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController, UITabBarControllerDelegate {

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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Make sure the controller is passed along
        if let mainViewController = viewController as? MainViewController {
            if mainViewController.coreModel == nil {
                mainViewController.coreModel = coreModel
            }
        }

        return true
    }
}

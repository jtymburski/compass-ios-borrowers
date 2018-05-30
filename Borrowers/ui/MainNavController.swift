//
//  MainNavController.swift
//  Borrowers
//
//  Created by Kevin Smith on 2018-04-01.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class MainNavController: UINavigationController, UINavigationControllerDelegate {

    // Model
    var coreModel: CoreModelController!

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
        // Tab controller
        if let mainTabController = viewController as? MainTabController {
            if mainTabController.coreModel == nil {
                mainTabController.coreModel = coreModel
            }
        }
    }
}

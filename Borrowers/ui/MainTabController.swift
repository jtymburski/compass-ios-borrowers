//
//  MainTabController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-04-01.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController, UITabBarControllerDelegate {
    // Statics
    let ICON_MARGIN: CGFloat = 8.0
    let ICON_SIZE: CGFloat = 72.0
    let SEGUE_CREATE = "showCreate"
    let TITLE_HOME = "Home"

    // UI
    let createButton = UIButton.init(type: .custom)

    // Model
    var coreModel: CoreModelController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // Starting title
        self.navigationItem.title = TITLE_HOME

        // Load the center button
        createButton.setImage(#imageLiteral(resourceName: "IconAddNavSel"), for: .normal)
        createButton.addTarget(self, action:#selector(self.onCreateClicked), for: .touchUpInside)
        self.view.insertSubview(createButton, aboveSubview: self.tabBar)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // safe place to set the frame of button manually
        let iconHalf = (ICON_SIZE / 2)
        createButton.frame = CGRect.init(x: self.tabBar.center.x - iconHalf, y: self.view.bounds.height - ICON_SIZE - ICON_MARGIN, width: ICON_SIZE, height: ICON_SIZE)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func onCreateClicked() {
        performSegue(withIdentifier: SEGUE_CREATE, sender: self)
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is HomeViewController {
            self.navigationItem.title = TITLE_HOME
        } else if viewController is ProfileViewController {
            self.navigationItem.title = "Profile"
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Make sure the controller is passed along
        if let homeViewController = viewController as? HomeViewController {
            if homeViewController.coreModel == nil {
                homeViewController.coreModel = coreModel
            }
        } else if let profileViewController = viewController as? ProfileViewController {
            if profileViewController.coreModel == nil {
                profileViewController.coreModel = coreModel
            }
        }

        return true
    }
}

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
    let COLOR_TAB_BORDER = UIColor(red: 199.0/255.0, green: 204.0/255.0, blue: 210.0/255.0, alpha: 0.3)
    let ICON_MARGIN: CGFloat = 8.0
    let ICON_SIZE: CGFloat = 72.0
    let SEGUE_CREATE = "showCreate"
    let TITLE_HOME = "Loans"
    let TITLE_PROFILE = "Profile"

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
        createButton.setImage(#imageLiteral(resourceName: "IconNavAdd"), for: .normal)
        createButton.adjustsImageWhenHighlighted = false
        createButton.addTarget(self, action:#selector(self.onCreateClicked), for: .touchUpInside)
        self.view.insertSubview(createButton, aboveSubview: self.tabBar)

        // Clear the top bar line
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.clipsToBounds = true
        _ = tabBar.layer.addBorder(edge: .top, color: COLOR_TAB_BORDER, thickness: 1.0)
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

    // MARK: - Navigation

    @objc func onCreateClicked() {
        performSegue(withIdentifier: SEGUE_CREATE, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // New loan nav controller
        if let newLoanNavController = segue.destination as? NewLoanNavController {
            if newLoanNavController.coreModel == nil {
                newLoanNavController.coreModel = coreModel
            }
        }
    }

    // MARK: - Tab bar control

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is LoanListViewController {
            self.navigationItem.title = TITLE_HOME
        } else if viewController is ProfileViewController {
            self.navigationItem.title = TITLE_PROFILE
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Make sure the controller is passed along
        if let homeViewController = viewController as? LoanListViewController {
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

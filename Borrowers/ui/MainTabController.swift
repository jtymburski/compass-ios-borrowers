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
    let COLOR_TAB_BORDER = UIColorCompat(red: 199.0/255.0, green: 204.0/255.0, blue: 210.0/255.0, alpha: 0.3)
    let ICON_MARGIN: CGFloat = 6.0
    let ICON_SIZE: CGFloat = 72.0
    let SEGUE_CREATE = "showCreate"

    // UI
    let createButton = UIButton.init(type: .custom)

    // Model
    var coreModel: CoreModelController!
    var coreModelSent = false

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // Load the center button
        createButton.setImage(#imageLiteral(resourceName: "IconNavAdd"), for: .normal)
        createButton.adjustsImageWhenHighlighted = false
        createButton.addTarget(self, action:#selector(self.onCreateClicked), for: .touchUpInside)
        self.view.insertSubview(createButton, aboveSubview: self.tabBar)

        // Clear the top bar line
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.clipsToBounds = true
        _ = tabBar.layer.addBorder(edge: .top, color: COLOR_TAB_BORDER.get(), thickness: 1.0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // safe place to set the frame of button manually
        let iconHalf = (ICON_SIZE / 2)
        print(self.tabBar.bounds.height)
        createButton.frame = CGRect.init(x: self.tabBar.center.x - iconHalf, y: self.view.bounds.height - self.tabBar.bounds.height - iconHalf + ICON_MARGIN, width: ICON_SIZE, height: ICON_SIZE)

        if !coreModelSent && coreModel != nil && viewControllers != nil {
            for viewController in viewControllers! {
                loadInCoreModel(viewController: viewController)
            }
            coreModelSent = true
        }
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

    @IBAction func unwindToTabView(segue: UIStoryboardSegue) {
        // Check that the segue was from the expected source
        if let newLoanViewController = segue.source as? NewLoanViewController {
            // Try to find the loan list view controller
            if newLoanViewController.loanResult != nil && viewControllers != nil {
                for viewController in viewControllers! {
                    if let loanListNavController = viewController as? LoanListNavController {
                        loanListNavController.addLoan(newLoanViewController.loanResult!)
                    }
                }
            }
        }
    }

    // MARK: - Tab bar control

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        loadInCoreModel(viewController: viewController)
        return true
    }

    // MARK: - Internals

    private func loadInCoreModel(viewController: UIViewController) {
        if let loanListNavController = viewController as? LoanListNavController {
            if loanListNavController.coreModel == nil {
                loanListNavController.coreModel = coreModel
            }
        } else if let profileViewController = viewController as? ProfileViewController {
            if profileViewController.coreModel == nil {
                profileViewController.coreModel = coreModel
            }
        }
    }
}

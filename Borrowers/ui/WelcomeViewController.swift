//
//  WelcomeViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-27.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    // Model
    var coreModel: CoreModelController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //print("How is the model: \(coreModel.hasValidDetails())")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Create bank viewview
        if let bankCreateViewController = segue.destination as? BankCreateViewController {
            bankCreateViewController.coreModel = coreModel
        }
    }

    @IBAction func unwindToWelcome(segue: UIStoryboardSegue) {
        // Create bank view
        if let bankCreateViewController = segue.destination as? BankCreateViewController {
            coreModel = bankCreateViewController.coreModel
        }
    }

    // MARK: - Actions

    @IBAction func attemptGetStarted(_ sender: UIButton) {
        performSegue(withIdentifier: "showBankCreate", sender: self)
    }
}

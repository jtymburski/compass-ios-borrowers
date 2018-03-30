//
//  WelcomeViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-27.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    // UI
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var iconAddBank: UIImageView!
    @IBOutlet weak var iconVerifyIdentity: UIImageView!

    // Model
    var coreModel: CoreModelController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        updateView()
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

    // MARK: - Internals

    func updateView() {
        var hasBank = false
        let hasVerified = false

        // Bank connections icon
        if coreModel.hasBankConnections() {
            hasBank = true
            iconAddBank.image = #imageLiteral(resourceName: "IconCircleCheck")
        } else {
            iconAddBank.image = #imageLiteral(resourceName: "IconCircle1")
        }

        // Verify identity icon
        // TODO

        // Button text
        if hasBank && hasVerified {
            buttonNext.setTitle("Submit Your Application", for: .normal)
        } else if hasBank {
            buttonNext.setTitle("Keep Going", for: .normal)
        } else {
            buttonNext.setTitle("Get Started", for: .normal)
        }
    }
}

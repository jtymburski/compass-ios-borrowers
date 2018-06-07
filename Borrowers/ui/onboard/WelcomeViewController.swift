//
//  WelcomeViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-27.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class WelcomeViewController: UIViewController, NVActivityIndicatorViewable {
    private let UNWIND_SEGUE_LOGIN = "unwindToLogin"

    // UI
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var iconAddBank: UIImageView!
    @IBOutlet weak var iconVerifyIdentity: UIImageView!

    // Model
    var coreModel: CoreModelController!

    // Control
    var attemptingSubmit = false

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
        // Create bank view
        if let bankCreateViewController = segue.destination as? BankCreateViewController {
            bankCreateViewController.coreModel = coreModel
        }
        // Main navigation of the tab interface
        else if let mainNavController = segue.destination as? MainNavController {
            mainNavController.coreModel = coreModel
        }
        // Welcome navigation
        else if let welcomeNavController = segue.destination as? WelcomeNavController {
            welcomeNavController.coreModel = coreModel
        }
        // Verify view
        else if let verifyViewController = segue.destination as? VerifyViewController {
            verifyViewController.coreModel = coreModel
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
        if !coreModel.hasBankConnections() {
            performSegue(withIdentifier: "showBankCreate", sender: self)
        } else if !coreModel.hasReadyAssessment()  {
            performSegue(withIdentifier: "showVerification", sender: self)
        } else {
            if attemptingSubmit {
                return
            }
            attemptingSubmit = true
            startAnimating(CGSize.init(width: 90, height: 90), type: NVActivityIndicatorType.orbit)

            Session.assessmentSubmit(account: coreModel.account, assessment: coreModel.activeAssessment!, completionHandler: { (success, errorString, noNetwork, unauthorized) in

                DispatchQueue.main.async {
                    self.updateSubmitResult(success: success, error: errorString, noNetwork: noNetwork, unauthorized: unauthorized)
                }
            })
        }
    }

    // MARK: - Internals

    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func updateSubmitResult(success: Bool, error: String?, noNetwork: Bool, unauthorized: Bool) {
        attemptingSubmit = false
        stopAnimating()

        if success {
            coreModel.activeAssessment = nil
            performSegue(withIdentifier: "showMain", sender: self)
        } else {
            if noNetwork {
                showErrorAlert(title: "No Network", message: "A network connection is required to submit for assessment")
            } else if unauthorized {
                performSegue(withIdentifier: UNWIND_SEGUE_LOGIN, sender: self)
            } else {
                showErrorAlert(title: "Failed To Submit", message: "The assessment failed to be submitted. Try again later")
            }
        }
    }

    func updateView() {
        var hasBank = false
        var hasVerified = false

        // Bank connections icon
        if coreModel.hasBankConnections() {
            hasBank = true
            iconAddBank.image = #imageLiteral(resourceName: "IconCircleCheck")
        } else {
            iconAddBank.image = #imageLiteral(resourceName: "IconCircle1")
        }

        // Verify identity icon
        if coreModel.hasReadyAssessment() {
            hasVerified = true
            iconVerifyIdentity.image = #imageLiteral(resourceName: "IconCircleCheck")
        } else {
            iconVerifyIdentity.image = #imageLiteral(resourceName: "IconCircle2")
        }

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

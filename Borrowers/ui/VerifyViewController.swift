//
//  VerifyViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class VerifyViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {
    // Statics
    private let DEFAULT_FILE_NAME = "untitled.jpg"
    private let FILE_NAMES = [
        "90day_bank_statement.jpg",
        "pay_stub_last.jpg",
        "pay_stub_another.jpg",
        "government_id.jpg",
        "utility_bill.jpg"
    ]
    private let ICON_COLOR = UIColor(red: 25.0/255.0, green: 167.0/255.0, blue: 130.0/255.0, alpha: 1.0)
    private let UNWIND_SEGUE_LOGIN = "unwindToLogin"
    private let UNWIND_SEGUE_WELCOME = "unwindToWelcome"

    // UI
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var iconBankStatement: UIImageView!
    @IBOutlet weak var iconGovernmentId: UIImageView!
    @IBOutlet weak var iconPayStubLast: UIImageView!
    @IBOutlet weak var iconPayStubPrevious: UIImageView!
    @IBOutlet weak var iconUtilityBill: UIImageView!

    // Model
    var coreModel: CoreModelController!

    // Control
    var attemptingCreate = false
    var displayRow: Int?
    var selectedFile: String?
    var selectedRow: Int?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Extra loading here
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        updateView()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Verify preview controller
        if let verifyPreviewController = segue.destination as? VerifyPreviewController {
            if displayRow != nil {
                verifyPreviewController.verificationFile = coreModel.getVerificationFile(index: displayRow!)
                verifyPreviewController.verificationIndex = displayRow!
            }
        }
    }

    // MARK: - Actions

    @IBAction func onAssessmentSave(_ sender: UIBarButtonItem) {
        if attemptingCreate {
            return
        }
        attemptingCreate = true
        self.view.endEditing(true)
        startAnimating(CGSize.init(width: 90, height: 90), type: NVActivityIndicatorType.orbit)

        // Start the request
        Session.assessmentCreate(account: coreModel.account) { (response, errorString, noNetwork, unauthorized) in
            DispatchQueue.main.async {
                self.updateCreateResult(result: response, error: errorString, noNetwork: noNetwork, unauthorized: unauthorized)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Determine if a file has been found already
        if coreModel.isVerificationFileValid(index: indexPath.row) {
            // Set up the selected properties
            displayRow = indexPath.row

            // Show a picture
            performSegue(withIdentifier: "showVerificationFile", sender: self)
        } else {
            // Fetch a picture
            let sourceType = UIImagePickerControllerSourceType.photoLibrary
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                // Set up the image properties
                selectedRow = indexPath.row
                selectedFile = getFileName(index: selectedRow!)

                // Set up and open the picker
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = sourceType
                present(imagePicker, animated: true, completion: nil)
            }
        }

        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: false);
    }

    // MARK: - Image Picker Control

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if selectedRow != nil && selectedFile != nil {
            if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage {
                coreModel.setVerificationFile(index: selectedRow!, image: imagePicked, name: selectedFile!)
                updateView()
            }

            selectedRow = nil
            selectedFile = nil
        }

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Internals

    func getFileName(index: Int) -> String? {
        if index >= 0 && index < FILE_NAMES.count {
            return FILE_NAMES[index]
        }
        return nil
    }

    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func startUpload(uploadPath: String) {
        let uploadStartResult =
            Session.assessmentUpload(urlString: uploadPath, files: coreModel.verificationFiles) { (success, error, noNetwork) in

                DispatchQueue.main.async {
                    self.updateUploadResult(success: success, error: error, noNetwork: noNetwork)
                }
        }

        // Check if the upload failed to be started
        if !uploadStartResult {
            updateUploadResult(success: false, error: nil, noNetwork: false)
        }
    }

    func updateCreateResult(result: AssessmentInfo?, error: String?, noNetwork: Bool, unauthorized: Bool) {
        if result != nil && result!.isValid() && result!.uploadPath != nil {
            coreModel.activeAssessment = result
            startUpload(uploadPath: result!.uploadPath!)
        } else {
            attemptingCreate = false
            stopAnimating()

            if noNetwork {
                showErrorAlert(title: "No Network", message: "A network connection is required to create an assessment")
            } else if unauthorized {
                performSegue(withIdentifier: UNWIND_SEGUE_LOGIN, sender: self)
            } else {
                showErrorAlert(title: "Failed To Create", message: "A new assessment failed to be created. Try again later")
            }
        }
    }

    func updateUploadResult(success: Bool, error: String?, noNetwork: Bool) {
        attemptingCreate = false
        stopAnimating()

        if success {
            coreModel.activeAssessment!.setFiles(files: coreModel.verificationFiles)
            coreModel.verificationFiles.removeAll()

            performSegue(withIdentifier: UNWIND_SEGUE_WELCOME, sender: self)
        } else {
            if noNetwork {
                showErrorAlert(title: "No Network", message: "A network connection is required to upload the files")
            } else {
                showErrorAlert(title: "Failed to Upload", message: "The upload failed to be initialized. Try again later")
            }
        }
    }

    func updateView() {
        let isFirstValid = updateView(index: 0, imageView: iconBankStatement)
        let isSecondValid = updateView(index: 1, imageView: iconPayStubLast)
        let isThirdValid = updateView(index: 2, imageView: iconPayStubPrevious)
        let isFourthValid = updateView(index: 3, imageView: iconGovernmentId)
        let isFifthValid = updateView(index: 4, imageView: iconUtilityBill)

        buttonSave.isEnabled = isFirstValid && isSecondValid && isThirdValid && isFourthValid && isFifthValid
    }

    func updateView(index: Int, imageView: UIImageView) -> Bool {
        if coreModel.isVerificationFileValid(index: index) {
            imageView.image = #imageLiteral(resourceName: "IconCircleCheck").withRenderingMode(.alwaysTemplate)
            imageView.tintColor = ICON_COLOR
            return true
        } else {
            imageView.image = #imageLiteral(resourceName: "IconCircle")
            return false
        }
    }
}

//
//  VerifyViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class VerifyViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Statics
    private let DEFAULT_FILE_NAME = "untitled.jpg"
    private let FILE_NAMES = [
        "90day_bank_statement.jpg",
        "pay_stub_last.jpg",
        "pay_stub_another.jpg",
        "government_id.jpg",
        "utility_bill.jpg"
    ]
    //private let ICON_COLOR = UIColor(red: 29.0/255.0, green: 29.0/255.0, blue: 38.0/255.0, alpha: 0.3)
    private let ICON_COLOR = UIColor(red: 25.0/255.0, green: 167.0/255.0, blue: 130.0/255.0, alpha: 1.0)

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

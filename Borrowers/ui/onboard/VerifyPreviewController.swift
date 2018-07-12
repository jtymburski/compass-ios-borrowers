//
//  VerifyPreviewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class VerifyPreviewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UI
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    // Internals
    var verificationFile: VerificationFile!
    var verificationIndex: Int!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self

        imageView.image = verificationFile.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Image Picker Control

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = imagePicked
            verificationFile.image = imagePicked
        }

        dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
    }

    // MARK: - Scroll View Delegates

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    // MARK: - Actions

    @IBAction func retake(_ sender: UIBarButtonItem) {
        // Fetch a picture
        #if DEBUG
            let sourceType = UIImagePickerControllerSourceType.photoLibrary
        #else
            let sourceType = UIImagePickerControllerSourceType.camera
        #endif
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            // Set up and open the picker
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = sourceType
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

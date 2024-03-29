//
//  ProfileViewController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-04-04.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource {
    // Statics
    private let BORDER_HEADER = UIColorCompat(red: 63.0/255.0, green: 205.0/255.0, blue: 168.0/255.0, alpha: 1.0)
    private let SEGUE_EDIT_PROFILE = "showEditProfile"
    private let SEGUE_LOGIN = "unwindToLogin"

    // UI
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelRatingLetter: UILabel!
    @IBOutlet weak var labelRatingMod: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewRating: UIView!
    @IBOutlet weak var viewStatus: UIView!

    // Model
    var coreModel: CoreModelController!

    // Data
    var displayInfo = [Pair]()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Nar bar transparent settings (to show the view below)
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()

        // Borders inside large custom nav bar view
        viewRating.layoutIfNeeded()
        _ = viewRating.layer.addBorder(edge: .top, color: BORDER_HEADER.get(), thickness: 1.0)
        _ = viewRating.layer.addBorder(edge: .left, color: BORDER_HEADER.get(), thickness: 1.0)
        _ = viewRating.layer.addBorder(edge: .right, color: BORDER_HEADER.get(), thickness: 1.0)
        _ = viewRating.layer.addBorder(edge: .bottom, color: BORDER_HEADER.get(), thickness: 1.0)
        viewStatus.layoutIfNeeded()
        _ = viewStatus.layer.addBorder(edge: .top, color: BORDER_HEADER.get(), thickness: 1.0)

        // Table view
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self

        // Set up the header of the profile
        labelName.text = coreModel.userInfo?.name
        if let assessment = coreModel.getApprovedAssessment() {
            labelRatingLetter.text = assessment.getRatingLetter()
            labelRatingMod.text = assessment.getRatingMod()
        } else {
            labelRatingLetter.text = "--"
            labelRatingMod.text = ""
        }

        // Set up the array of data to display in table
        updateDisplayInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! ProfileTableViewCell
        cell.setPair(displayInfo[indexPath.row])
        return cell
    }

    // MARK: - Navigation

    @IBAction func moreClicked(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // Logout action
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.requestLogout()
        }
        optionMenu.addAction(logoutAction)

        // Edit profile action
        let editProfileAction = UIAlertAction(title: "Edit Profile", style: .default) { _ in
            self.performSegue(withIdentifier: self.SEGUE_EDIT_PROFILE, sender: self)
        }
        optionMenu.addAction(editProfileAction)

        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)

        // Show the view
        present(optionMenu, animated: true, completion: nil)
    }

    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    // MARK: - Internals

    private func executeLogout() {
        // Execute the logout
        Session.logout(account: coreModel.account, completionHandler: nil)

        // Clean up and leave before the session execution is complete
        coreModel.account.clear()
        CoreDataStack.saveContext()
        performSegue(withIdentifier: self.SEGUE_LOGIN, sender: self)
    }

    private func requestLogout() {
        let logoutMenu = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)

        // Logout action
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.executeLogout()
        }
        logoutMenu.addAction(logoutAction)

        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        logoutMenu.addAction(cancelAction)

        // Show the view
        present(logoutMenu, animated: true, completion: nil)
    }

    private func updateDisplayInfo() {
        tableView.beginUpdates()
        displayInfo.removeAll()

        if let userInfo = coreModel.userInfo {
            // Email
            displayInfo.append(Pair.init(key: "Email", value: userInfo.email))

            // Address top lines
            var addressString = ""
            if StringHelper.hasContent(userInfo.address1) {
                addressString = userInfo.address1!
            }
            if StringHelper.hasContent(userInfo.address2) {
                addressString = StringHelper.append(
                    appendTo: addressString, string: userInfo.address2!, divider: "\n")
            }
            if StringHelper.hasContent(userInfo.address3) {
                addressString = StringHelper.append(
                    appendTo: addressString, string: userInfo.address3!, divider: "\n")
            }

            // City, province, country line
            var locationString = ""
            if StringHelper.hasContent(userInfo.city) {
                locationString = userInfo.city!
            }
            if StringHelper.hasContent(userInfo.province) {
                locationString = StringHelper.append(
                    appendTo: locationString, string: userInfo.province!, divider: ", ")
            }
            if StringHelper.hasContent(userInfo.countryCode) {
                locationString = StringHelper.append(
                    appendTo: locationString, string: userInfo.countryCode!, divider: ", ")
            }
            if !locationString.isEmpty {
                addressString = StringHelper.append(
                    appendTo: addressString, string: locationString, divider: "\n")
            }

            // Postal code
            if StringHelper.hasContent(userInfo.postCode) {
                addressString = StringHelper.append(
                    appendTo: addressString, string: userInfo.postCode!, divider: "\n")
            }

            // Commit the address
            if !addressString.isEmpty {
                displayInfo.append(Pair.init(key: "Address", value: addressString))
            }

            // Phone
            if StringHelper.hasContent(userInfo.phone) {
                displayInfo.append(Pair.init(key: "Phone", value: userInfo.phone!))
            }

            // Employer
            if StringHelper.hasContent(userInfo.employer) {
                displayInfo.append(Pair.init(key: "Employer", value: userInfo.employer!))
            }

            // Job Title
            if StringHelper.hasContent(userInfo.jobTitle) {
                displayInfo.append(Pair.init(key: "Job Title", value: userInfo.jobTitle!))
            }
        }

        tableView.endUpdates()
    }
}

//
//  LoanListViewCell.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-25.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class LoanListViewCell: UITableViewCell {
    @IBOutlet weak var balanceRemaining: UILabel!
    @IBOutlet weak var cellCard: UIView!
    @IBOutlet weak var nextPaymentAmount: UILabel!
    @IBOutlet weak var nextPaymentDate: UILabel!
    @IBOutlet weak var nextPaymentString: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var viewCompleted: UIView!
    @IBOutlet weak var viewSectionDate: UIView!
    @IBOutlet weak var viewSectionMain: UIView!
    @IBOutlet weak var viewStatus: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Custom initialization code
        //_ = viewSectionMain.layer.addBorder(edge: .bottom, color: UIColor.red, thickness: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func willDisplay() {
        // Borders (the views have been sized so they can be added now)
        _ = viewSectionMain.layer.addBorder(edge: .bottom, color: UIColor.red, thickness: 1.0)
        _ = viewSectionMain.layer.addBorder(edge: .right, color: UIColor.orange, thickness: 1.0)

        _ = viewSectionDate.layer.addBorder(edge: .top, color: UIColor.blue, thickness: 1.0)
        _ = viewSectionDate.layer.addBorder(edge: .right, color: UIColor.green, thickness: 1.0)
    }
}

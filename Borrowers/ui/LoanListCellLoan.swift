//
//  LoanListViewCell.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-25.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class LoanListCellLoan: UITableViewCell {
    // Statics
    private let BORDER_COLOR = UIColorCompat(red: 231.0/255.0, green: 234.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    private let HIGHLIGHT_COLOR = UIColorCompat(red: 247.0/255.0, green: 255.0/255.0, blue: 254.0/255.0, alpha: 1.0)

    // UI
    @IBOutlet weak var balanceRemaining: UILabel!
    @IBOutlet weak var cellCard: UIView!
    @IBOutlet weak var nextPaymentAmount: UILabel!
    @IBOutlet weak var nextPaymentDate: UILabel!
    @IBOutlet weak var nextPaymentHeader: UILabel!
    @IBOutlet weak var nextPaymentString: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var viewCompleted: UIView!
    @IBOutlet weak var viewSectionDate: UIView!
    @IBOutlet weak var viewSectionRate: UIView!
    @IBOutlet weak var viewStatus: UIView!

    // Data
    var data: LoanSummary!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Custom initialization code
    }

    func setData(_ cellData: LoanSummary, principalFormatter: NumberFormatter, currencyFormatter: NumberFormatter, rateFormatter: NumberFormatter) {
        data = cellData

        // Update the interface
        // TODO: Once status is introduced, it will be used to gauge the loan information shown
        if data.isInProgress() {
            // TODO: Make circle the amount that has been paid off

            balanceRemaining.text = principalFormatter.string(from: data.balance! as NSNumber)

            // TODO: This should also handle over due states with yellow or red text for the status
            viewStatus.isHidden = false
            nextPaymentAmount.isHidden = false
            nextPaymentAmount.text = currencyFormatter.string(from: data.nextPayment!.amount! as NSNumber)
            nextPaymentString.isHidden = false
            nextPaymentHeader.text = "Next payment due"

            // Date analysis
            let calendar = Calendar.current
            let currentDate = calendar.startOfDay(for: Date())
            let dueDate = calendar.startOfDay(for: Date(timeIntervalSince1970: Double(data.nextPayment!.dueDate! / 1000)))
            let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)

            nextPaymentString.text = " due in \(components.day ?? 0) days"
            nextPaymentDate.text = StringHelper.getDateString(dueDate)
        } else  {
            // TODO: Make circle full green with a little check (if complete) OR X (if cancelled) OR ... (if pending) in the middle

            balanceRemaining.text = principalFormatter.string(from: data.principal! as NSNumber)
            viewStatus.isHidden = true
            nextPaymentAmount.isHidden = true
            nextPaymentString.isHidden = true

            nextPaymentHeader.text = "Status"
            if data.isCompleted() {
                nextPaymentDate.text = "Completed"
            } else {
                // TODO: This should have two states - one for cancelled and one for pending
                nextPaymentDate.text = "Pending"
            }

            // TODO: Make the whole cell card slightly washed, if cancelled or completed
        }

        // General settings that will always be set regardless of the state/status
        rate.text = rateFormatter.string(from: data.rate! as NSNumber)
    }

    func setHighlighted(_ highlighted: Bool) {
        if highlighted {
            UIView.animate(withDuration: 0.25, animations: {
                self.cellCard.backgroundColor = self.HIGHLIGHT_COLOR.get()
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.cellCard.backgroundColor = UIColor.white
            })
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func willDisplay() {
        layoutIfNeeded()

        // Borders (the views have been sized so they can be added now)
        _ = viewSectionRate.layer.addBorder(edge: .top, color: BORDER_COLOR.get(), thickness: 1.0)
        _ = viewSectionDate.layer.addBorder(edge: .top, color: BORDER_COLOR.get(), thickness: 1.0)
        _ = viewSectionDate.layer.addBorder(edge: .right, color: BORDER_COLOR.get(), thickness: 1.0)
    }
}

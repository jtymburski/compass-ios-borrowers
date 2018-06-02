//
//  LoanListViewCell.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-25.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class LoanListViewCell: UITableViewCell {
    // Statics
    private let BORDER_COLOR = UIColorCompat(red: 231.0/255.0, green: 234.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    private let HIGHLIGHT_COLOR = UIColorCompat(red: 247.0/255.0, green: 255.0/255.0, blue: 254.0/255.0, alpha: 1.0)

    // UI
    @IBOutlet weak var balanceRemaining: UILabel!
    @IBOutlet weak var cellCard: UIView!
    @IBOutlet weak var nextPaymentAmount: UILabel!
    @IBOutlet weak var nextPaymentDate: UILabel!
    @IBOutlet weak var nextPaymentString: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var viewCompleted: UIView!
    @IBOutlet weak var viewSectionDate: UIView!
    @IBOutlet weak var viewSectionRate: UIView!
    @IBOutlet weak var viewStatus: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Custom initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
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

    func willDisplay() {
        layoutIfNeeded()

        // Borders (the views have been sized so they can be added now)
        _ = viewSectionRate.layer.addBorder(edge: .top, color: BORDER_COLOR.get(), thickness: 1.0)
        _ = viewSectionDate.layer.addBorder(edge: .top, color: BORDER_COLOR.get(), thickness: 1.0)
        _ = viewSectionDate.layer.addBorder(edge: .right, color: BORDER_COLOR.get(), thickness: 1.0)
    }
}

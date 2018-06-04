//
//  LoanListCellAdd.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-06-04.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class LoanListCellAdd: UITableViewCell {
    // Statics
    private let HIGHLIGHT_COLOR = UIColorCompat(red: 247.0/255.0, green: 255.0/255.0, blue: 254.0/255.0, alpha: 1.0)

    // UI
    @IBOutlet weak var cellCard: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
}

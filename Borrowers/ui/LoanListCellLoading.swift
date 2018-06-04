//
//  LoanListCellLoading.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-06-03.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class LoanListCellLoading: UITableViewCell {
    // Statics
    private let ANIMATION_COLOR = UIColorCompat(red: 221.0/255.0, green: 242.0/255.0, blue: 237.0/255.0, alpha: 1.0)

    // UI
    @IBOutlet weak var viewAnimation: NVActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Start the animation in the cell
        viewAnimation.type = .ballScale
        viewAnimation.color = ANIMATION_COLOR.get()
        viewAnimation.startAnimating()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

//
//  ProfileTableViewCell.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-30.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var labelKey: UILabel!
    @IBOutlet weak var labelValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setPair(_ pair: Pair) {
        labelKey.text = pair.key
        labelValue.text = pair.value
    }
}

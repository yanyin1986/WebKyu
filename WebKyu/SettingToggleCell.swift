//
//  SettingToggleCell.swift
//  WebKyu
//
//  Created by Leon.yan on 07/03/2017.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit

class SettingToggleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

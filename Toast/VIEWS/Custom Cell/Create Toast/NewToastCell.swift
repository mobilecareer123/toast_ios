//
//  NewToastCell.swift
//  Toast
//
//  Created by Anish Pandey on 21/07/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit

class NewToastCell: UITableViewCell {

    @IBOutlet weak var view_DueDateBg: UIView!
    @IBOutlet weak var lbl_DueDate: UILabel!
    @IBOutlet weak var btn_Calendar: UIButton!
    @IBOutlet weak var lbl_PersonsEmail: UILabel!
    @IBOutlet weak var view_PersonsEmailBg: UIView!
    @IBOutlet weak var txtvw_IntendedPerson: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

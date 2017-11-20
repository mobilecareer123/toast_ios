//
//  IntendedPersonsCell.swift
//  Toast
//
//  Created by Anish Pandey on 17/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class IntendedPersonsCell: UITableViewCell {
    
    @IBOutlet weak var lbl_EmailID: UILabel!
    @IBOutlet weak var btn_Remove: UIButton!
    @IBOutlet weak var lbl_Name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

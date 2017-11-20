//
//  MemberPicker.swift
//  Toast
//
//  Created by Administrator on 10/17/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit

class MemberPicker: UITableViewCell {
    
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

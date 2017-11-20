//
//  AboutCell.swift
//  Toast
//
//  Created by Anish Pandey on 19/04/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit

class AboutCell: UITableViewCell {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    
    @IBOutlet weak var imgView_Icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

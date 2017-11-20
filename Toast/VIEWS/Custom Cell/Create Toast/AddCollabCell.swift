//
//  AddCollabCell.swift
//  Toast
//
//  Created by Anish Pandey on 20/07/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit

class AddCollabCell: UITableViewCell {
    
    @IBOutlet weak var switch_Notifctn: UISwitch!
    @IBOutlet weak var lbl_TstToCelebrtCategory: ResizableFontLabel!
    @IBOutlet weak var txtvw_ToastTheme: UITextView!
    @IBOutlet weak var txtFld_GroupName: UITextField!
    @IBOutlet weak var view_GroupNameBg: UIView!
    @IBOutlet weak var txtvw_Collaborators: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

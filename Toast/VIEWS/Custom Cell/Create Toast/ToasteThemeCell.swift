//
//  ToasteThemeCell.swift
//  Toast
//
//  Created by Anish Pandey on 17/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class ToasteThemeCell: UITableViewCell {

    @IBOutlet weak var Const_viewCategoryBgHeight: NSLayoutConstraint!
    @IBOutlet weak var txtvw_ToastTheme: UITextView!
    @IBOutlet weak var view_DueDateBg: UIView!
    @IBOutlet weak var view_GroupNameBg: UIView!
    @IBOutlet weak var switch_Notifctn: UISwitch!
    @IBOutlet weak var lbl_DueDate: UILabel!
    @IBOutlet weak var btn_Calendar: UIButton!
    
    @IBOutlet weak var lbl_PersonsEmail: UILabel!
    @IBOutlet weak var view_PersonsEmailBg: UIView!
    @IBOutlet weak var txtFld_GroupName: UITextField!
    @IBOutlet weak var view_categoryMain: UIView!
    @IBOutlet weak var view_categoryBg: UIView!
    @IBOutlet weak var btn_category: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

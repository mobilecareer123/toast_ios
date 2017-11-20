//
//  ViewToastDetailCell.swift
//  Toast
//
//  Created by Anish Pandey on 30/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class ViewToastDetailCell: UITableViewCell {

    @IBOutlet weak var imgView_Toast: AsyncImageView!
    @IBOutlet weak var lbl_ToastCategory: UILabel!
    
    @IBOutlet weak var lbl_DueOn: ResizableFontLabel!
    @IBOutlet weak var view_notifctnBg: UIView!
    @IBOutlet weak var switch_Notification: UISwitch!
    @IBOutlet weak var const_NotifctnBgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl_DueOnTime: UILabel!
    @IBOutlet weak var lbl_CreatedOnTime: UILabel!
    @IBOutlet weak var lbl_fromGroup: UILabel!
    @IBOutlet weak var lbl_ToastMsg: UILabel!
    @IBOutlet weak var lbl_WantToRecv: ResizableFontLabel!
    @IBOutlet weak var lbl_ToastToPeopleName: ResizableFontLabel!
    @IBOutlet weak var lbl_NumOfPerson: ResizableFontLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

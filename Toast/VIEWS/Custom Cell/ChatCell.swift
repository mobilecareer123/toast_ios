//
//  ChatCell.swift
//  Toast
//
//  Created by Anish Pandey on 02/12/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var lbl_Initiator: ResizableFontLabel!
    @IBOutlet weak var btn_EditMessage: UIButton!
    @IBOutlet weak var const_wishPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var view_Bg: UIView!
    @IBOutlet weak var lbl_message: UILabel!
    @IBOutlet weak var lbl_memberName: UILabel!
    @IBOutlet weak var imgView_memberPic: UIImageView!
    @IBOutlet weak var lbl_messageTime: UILabel!
    @IBOutlet weak var imgView_wishPhoto: UIImageView!
    @IBOutlet weak var imgView_Bg: UIImageView!
    @IBOutlet weak var imgView_arrow: UIImageView!
    @IBOutlet weak var arrow_leadingspace: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

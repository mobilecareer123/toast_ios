//
//  AddMemberNoImageCell.swift
//  Toast
//
//  Created by Anish Pandey on 21/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class AddMemberNoImageCell: UITableViewCell {

    //@IBOutlet weak var lbl_MemberType: UILabel!
    //@IBOutlet weak var imgView_MemberPhoto: AsyncImageView!
    @IBOutlet weak var lbl_MemberName: UILabel!
    @IBOutlet weak var lbl_MemberEmail: UILabel!
    @IBOutlet weak var btn_Close: UIButton!
    @IBOutlet weak var view_Bg: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

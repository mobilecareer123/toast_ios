//
//  DiaryCell.swift
//  Toast
//
//  Created by Anish Pandey on 16/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class DiaryCell: UITableViewCell {
    
    
    @IBOutlet weak var view_Bg: UIView!
    @IBOutlet weak var imgView_EventImg: UIImageView!
    @IBOutlet weak var lbl_EventName: UILabel!
    @IBOutlet weak var lbl_GreetingMessage: UILabel!
    @IBOutlet weak var lbl_PersonName: UILabel!
    @IBOutlet weak var lbl_MessageTime: UILabel!
    @IBOutlet weak var lbl_MessageCount: UILabel!
    @IBOutlet weak var imgView_arrow: UIImageView!
    
    @IBOutlet weak var arrow_leftspacing: NSLayoutConstraint!
    @IBOutlet weak var separatorLine: UILabel!
    @IBOutlet weak var imgView_messageSendrType: UIImageView!
    @IBOutlet weak var imgView_messageIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

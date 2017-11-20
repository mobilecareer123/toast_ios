//
//  LeftMenuCell.swift
//  CaseLog
//
//  Created by Arkenea on 18/05/16.
//  Copyright © 2016 Ashwini@Arkenea. All rights reserved.
//

import UIKit

class LeftMenuCell: UITableViewCell {
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var img_Arrow: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

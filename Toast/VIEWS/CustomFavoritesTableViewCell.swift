//
//  CustomFavoritesTableViewCell.swift
//  MYOS
//
//  Created by Pankaj on 27/12/16.
//  Copyright © 2016 Pankaj Arkenea. All rights reserved.
//

import UIKit

class CustomFavoritesTableViewCell: UITableViewCell {


    @IBOutlet weak var txtlbl: UILabel!
    
    @IBInspectable var selectedColor: UIColor = UIColor.clear {
        didSet {
            selectedBackgroundView = UIView()
            selectedBackgroundView?.backgroundColor = selectedColor
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
               // Configure the view for the selected state
    }
    
}

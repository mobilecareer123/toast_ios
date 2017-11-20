//
//  ResizableFontLabel.swift
//  CacheFunder
//
//  Created by Arkenea on 07/12/16.
//  Copyright © 2016 Ashwini@Arkenea. All rights reserved.
//

import UIKit

class ResizableFontLabel: UILabel {

    @IBInspectable var autoFont: Bool = false
    @IBInspectable var fontSize: CGFloat = 0

    
    override func awakeFromNib() {
        super.awakeFromNib()
        let size: CGFloat = UIScreen.main.bounds.size.height * (fontSize / 568.0)
        self.font = UIFont(name: self.font.fontName, size: size)
    }


    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

//
//  ResizableView.swift
//  Toast
//
//  Created by Anish Pandey on 11/12/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class ResizableView: UIView {

    @IBInspectable var autoResize: Bool = false
    @IBInspectable var viewHeight: CGFloat = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let newHeight: CGFloat = UIScreen.main.bounds.size.height * (viewHeight / 568.0)
        self.viewHeight = newHeight
        self.layoutIfNeeded()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

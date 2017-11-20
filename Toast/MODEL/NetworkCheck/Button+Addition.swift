//
//  Button+Addition.swift
//  MYOS
//
//  Created by Pankaj on 19/12/16.
//  Copyright © 2016 Pankaj Arkenea. All rights reserved.
//

import UIKit

class Button_Addition: UIButton {

    //@IBInspectable var isFontChange:Bool
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var autoFont: Bool = false
    @IBInspectable var fontSize: CGFloat = 0
    @IBInspectable var animateTap: Bool = false

    override func awakeFromNib() {
        
        if autoFont == true {
            let size: CGFloat = UIScreen.main.bounds.size.height * (fontSize / 568.0)
            self.titleLabel!.font = UIFont(name: self.titleLabel!.font.fontName, size: size)
        }
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if animateTap == true{
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if animateTap == true {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)

        }
    }
}

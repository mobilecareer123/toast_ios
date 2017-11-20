//
//  UIView+Adition.swift
//  Viva
//
//  Created by Mahesh Agrawal on 02/08/16.
//  Copyright © 2016 Mahesh Agrawal. All rights reserved.
//

import Foundation

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            self.layoutIfNeeded()
            self.layer.cornerRadius = UIScreen.main.bounds.size.height * (newValue / 568.0)
            self.layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    static func loadInstanceFromNib() -> UIView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)![0] as! UIView
    }
    
}

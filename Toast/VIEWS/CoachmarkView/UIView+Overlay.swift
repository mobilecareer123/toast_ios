//
//  UIView+Overlay.swift
//  CoachmarkText
//
//  Created by Mahesh Agrawal on 1/5/17.
//  Copyright © 2017 Mahesh Agrawal. All rights reserved.
//

import UIKit
import Foundation

var txtLbl = UILabel()
var btnNext = UIButton()
var vArr = [UIView]() // array of views
var strArr = [String]() // array of text
var nextIndex = 0 //  index to refer next control

extension UIView {
    
    func getViewsWithText(_ viewArr: [UIView], textArr:[String])
    {
        nextIndex = 0
        vArr = viewArr
        strArr =  textArr
        btnNext.isUserInteractionEnabled = true

        addOverlayByHighlightingSubView(vArr[nextIndex], withText: strArr[nextIndex])
        nextIndex += 1
    }
    
    func addOverlayByHighlightingSubView(_ view: UIView, withText:String) {
        // disable user interaction
        for  view in self.subviews {
            
            if view == btnNext
            {
                view.isUserInteractionEnabled = true
            }
            else
            {
                view.isUserInteractionEnabled = false

            }
            
            
        }
        
        
        let highlightRect = view.convert(view.bounds, to: self)
       // self.isUserInteractionEnabled = false
       // btnNext.isUserInteractionEnabled = true
        

        //txtLbl.alpha = 0.0
        
        
        let circlePath = UIBezierPath(roundedRect: highlightRect, cornerRadius: view.layer.cornerRadius)
        let path:UIBezierPath = UIBezierPath(roundedRect:self.bounds, cornerRadius: 0)
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        var fillLayer:CAShapeLayer!
        
        for layer in self.layer.sublayers! {
            if layer.name == "mk_layer_overlay" {
                fillLayer = layer as! CAShapeLayer
            }
        }
        
        if fillLayer == nil {
            fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillRule = kCAFillRuleEvenOdd
            fillLayer.fillColor = UIColor.black.cgColor
            fillLayer.opacity = 0
            fillLayer.name = "mk_layer_overlay"
            self.layer.addSublayer(fillLayer)
            
            let animationOpacity: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
            animationOpacity.duration = 0.3
            animationOpacity.fromValue = NSNumber(value: 0 as Float)
            animationOpacity.toValue = NSNumber(value: 0.6 as Float)
            animationOpacity.isRemovedOnCompletion = false
            fillLayer.add(animationOpacity, forKey: "opacity")
            fillLayer.opacity = 0.8
        } else {
            let animationPath: CABasicAnimation = CABasicAnimation(keyPath: "path")
            animationPath.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animationPath.duration = 0.8
            animationPath.isRemovedOnCompletion = false
            animationPath.fillMode = kCAFillModeForwards
            animationPath.fromValue = fillLayer.path
            animationPath.toValue = path.cgPath as AnyObject
            fillLayer.add(animationPath, forKey: "path")
            fillLayer.path = path.cgPath
        }
        
        
        // add lable to show details related to respective coach-marks
        UIView.animate(withDuration: 0.0, delay: 0.9, options: .beginFromCurrentState, animations: {() -> Void in
            
        }, completion: {(finished: Bool) -> Void in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
                txtLbl.text = withText
                txtLbl.frame = CGRect(x:10.0, y:highlightRect.origin.y + highlightRect.size.height, width:self.frame.width - 20, height:70.0)
                txtLbl.font = UIFont(name: "HelveticaNeue", size: 15.0)
                txtLbl.textColor = UIColor.white
                txtLbl.numberOfLines = 0
                txtLbl.textAlignment = .center
                self.addSubview(txtLbl)
                
                
                
                // add button
                btnNext.frame = CGRect(x:(self.frame.width/2) + 50, y:txtLbl.frame.origin.y + txtLbl.bounds.size.height, width: (100), height:35.0)
                btnNext.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                btnNext.tag = 100
                btnNext.setTitle("Done", for: .normal)
                btnNext.layer.cornerRadius = 5.0
                
                if vArr.count != 0
                {
                if nextIndex != vArr.count
                {
                    btnNext.setTitle("Next", for: .normal)
                }
                    else // for last button
                {
                    btnNext.setTitle("Done", for: .normal)
                    
                    }
                }
                btnNext.setTitleColor(UIColor.white, for: .normal)
                btnNext.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                self.addSubview(btnNext)
                
            }, completion: {(finished: Bool) -> Void in
                
            })
        })
        
    }
   
    
    func removeOverlay() {
        var fillLayer:CAShapeLayer!
        
      //  self.isUserInteractionEnabled = true
        
        // enable user interaction
        for  view in self.subviews {
            
                view.isUserInteractionEnabled = true
            }


        for layer in self.layer.sublayers! {
            if layer.name == "mk_layer_overlay" {
                fillLayer = layer as! CAShapeLayer
            }
        }
        
        if fillLayer != nil {
            
            /*
            CATransaction.begin()
            let animationOpacity: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
            animationOpacity.duration = 0.3
            animationOpacity.fromValue = NSNumber(value: fillLayer.opacity as Float)
            animationOpacity.toValue = NSNumber(value: 0 as Float)
            animationOpacity.isRemovedOnCompletion = false
            CATransaction.setCompletionBlock({
                
                
                txtLbl.removeFromSuperview()
                print( "overLay lbls removed")
                
                // remove button
                btnNext.removeFromSuperview()
                print( "overLay btns removed")
                
                fillLayer.opacity = 0
                
                fillLayer.removeFromSuperlayer()
            })
 */
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
//                txtLbl.alpha = 0.0
//                btnNext.alpha = 0.0
                fillLayer.opacity = 0
                
                
            }, completion: {(finished: Bool) -> Void in
                
                txtLbl.removeFromSuperview()
                print( "overLay lbls removed")
                
                // remove button
                btnNext.removeFromSuperview()
                print( "overLay btns removed")
                fillLayer.removeFromSuperlayer()
            })
                
                //fillLayer.add(animationOpacity, forKey: "opacity")
                //CATransaction.commit()
           
        }
        else
        {
           print( "fill layer is nil")
        }
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
        
          if vArr.count != 0 // for multiple views
            {
                
                if nextIndex <= vArr.count
                {
                    if nextIndex == vArr.count // if last view remove overlay
                    {
                        DispatchQueue.global().sync {
                            UIView.animate(withDuration: 0.2){
                                self.removeOverlay()
                            }
                        }
                    }
                    else
                    {
                    addOverlayByHighlightingSubView(vArr[nextIndex], withText: strArr[nextIndex])
                    nextIndex += 1
                    }
                    
                }
                
                
            }
        else // for single view
            {
                
                DispatchQueue.global().sync {
                    UIView.animate(withDuration: 0.2){
                        self.removeOverlay()
                    }
                }
                
        }
        
    
        
        
    }

}

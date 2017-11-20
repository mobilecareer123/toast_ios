//
//  Twinkle.swift
//
//  Created by patrick piemonte on 2/20/15.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-present patrick piemonte (http://patrickpiemonte.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Foundation
import CoreGraphics

private let TwinkleLayerEmitterShapeKey = "circle"
private let TwinkleLayerEmitterModeKey = "surface"
private let TwinkleLayerRenderModeKey = "unordered"
private let TwinkleLayerMagnificationFilter = "linear"
private let TwinkleLayerMinificationFilter = "trilinear"

// MARK: - TwinkleLayer

class TwinkleLayer: CAEmitterLayer {
    
    // MARK: object lifecycle
    
    override init() {
        super.init()
        
        var twinkleImage :UIImage?
        
        let frameworkBundle = Bundle(for: self.classForCoder)
        if let imagePath = frameworkBundle.path(forResource: "TwinkleImage", ofType: "png")
        {
            twinkleImage = UIImage(contentsOfFile: imagePath)
        }
        
        let emitterCells: [CAEmitterCell] = [CAEmitterCell(), CAEmitterCell()]
        for cell in emitterCells {
            cell.birthRate = 8
            cell.lifetime = 0.8
            cell.lifetimeRange = 0
            cell.emissionRange = CGFloat(Double.pi/4)
            cell.velocity = 1
            cell.velocityRange = 1
            cell.scale = 0.35
            cell.scaleRange = 1.0
            cell.scaleSpeed = 0.6
            cell.spin = 0.4
            cell.spinRange = CGFloat(Double.pi)
            cell.color = UIColor(white: 1.0, alpha: 0.3).cgColor
            cell.alphaSpeed = -0.4
            cell.contents = twinkleImage?.cgImage
            cell.magnificationFilter = TwinkleLayerMagnificationFilter
            cell.minificationFilter = TwinkleLayerMinificationFilter
            cell.isEnabled = true
        }
        self.emitterCells = emitterCells
        
        self.emitterPosition = CGPoint(x: (bounds.size.width * 0.5), y: (bounds.size.height * 0.5))
        self.emitterSize = bounds.size
        
        self.emitterShape = TwinkleLayerEmitterShapeKey
        self.emitterMode = TwinkleLayerEmitterModeKey
        self.renderMode = TwinkleLayerRenderModeKey
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}

// MARK: - TwinkleLayer animations

private let TwinkleLayerPositionAnimationKey = "positionAnimation"
private let TwinkleLayerTransformAnimationKey = "transformAnimation"
private let TwinkleLayerOpacityAnimationKey = "opacityAnimation"

extension TwinkleLayer {
    
    func addPositionAnimation() {
        CATransaction.begin()
        let keyFrameAnim = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnim.duration = 0.3
        keyFrameAnim.isAdditive = true
        keyFrameAnim.repeatCount = MAXFLOAT
        keyFrameAnim.isRemovedOnCompletion = false
        keyFrameAnim.beginTime = CFTimeInterval(arc4random_uniform(1000) + 1) * 0.2 * 0.25 // random start time, non-zero
        let points: [NSValue] = [NSValue(cgPoint: CGPoint().twinkleRandom(0.25)),
                                 NSValue(cgPoint: CGPoint().twinkleRandom(0.25)),
                                 NSValue(cgPoint: CGPoint().twinkleRandom(0.25)),
                                 NSValue(cgPoint: CGPoint().twinkleRandom(0.25)),
                                 NSValue(cgPoint: CGPoint().twinkleRandom(0.25))]
        keyFrameAnim.values = points
        self.add(keyFrameAnim, forKey: TwinkleLayerPositionAnimationKey)
        CATransaction.commit()
    }
    
    func addRotationAnimation() {
        CATransaction.begin()
        let keyFrameAnim = CAKeyframeAnimation(keyPath: "transform")
        keyFrameAnim.duration = 0.3
        keyFrameAnim.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)
        keyFrameAnim.isAdditive = true
        keyFrameAnim.repeatCount = MAXFLOAT
        keyFrameAnim.isRemovedOnCompletion = false
        keyFrameAnim.beginTime = CFTimeInterval(arc4random_uniform(1000) + 1) * 0.2 * 0.25 // random start time, non-zero
        let radians: Float = 0.104 // ~6 degrees
        keyFrameAnim.values = [-radians, radians, -radians]
        self.add(keyFrameAnim, forKey: TwinkleLayerTransformAnimationKey)
        CATransaction.commit()
    }
    
    func addFadeInOutAnimation(_ beginTime: CFTimeInterval) {
        CATransaction.begin()
        let fadeAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        fadeAnimation.fromValue = 0
        fadeAnimation.toValue = 1
        fadeAnimation.repeatCount = 1
        fadeAnimation.autoreverses = true // fade in then out
        fadeAnimation.duration = 0.4
        fadeAnimation.fillMode = kCAFillModeForwards
        fadeAnimation.beginTime = beginTime
        CATransaction.setCompletionBlock({
            self.removeFromSuperlayer()
        })
        self.add(fadeAnimation, forKey: TwinkleLayerOpacityAnimationKey)
        CATransaction.commit()
    }
    
}

// MARK: - CGPoint

extension CGPoint {
    
    func twinkleRandom(_ range: Float)->CGPoint {
        let x = Int(-range + (Float(arc4random_uniform(1000)) / 1000.0) * 2.0 * range)
        let y = Int(-range + (Float(arc4random_uniform(1000)) / 1000.0) * 2.0 * range)
        return CGPoint(x: x, y: y)
    }
    
}

// MARK: - UIView

extension UIView {
    
    public func twinkle() {
        var twinkleLayers: [TwinkleLayer]! = []
//        var count:Int = 0
//        let starCount: UInt = 4
        
        //        for i in 0..<starCount {
        //            let twinkleLayer: TwinkleLayer = TwinkleLayer()
        //            if(count == 0)
        //            {
        //                twinkleLayer.position = CGPoint(x: CGFloat(18), y: CGFloat(22))
        //            }
        //            else if(count == 1)
        //            {
        //                twinkleLayer.position = CGPoint(x: CGFloat(99), y: CGFloat(46))
        //
        //            }
        //            else if(count == 2)
        //            {
        //                twinkleLayer.position = CGPoint(x: CGFloat(128), y: CGFloat(46))
        //
        //            }
        //            else if(count == 3)
        //            {
        //                twinkleLayer.position = CGPoint(x: CGFloat(165), y: CGFloat(17))
        //            }
        //            twinkleLayer.opacity = 0
        //            twinkleLayers.append(twinkleLayer)
        //            self.layer.addSublayer(twinkleLayer)
        //
        //            twinkleLayer.addPositionAnimation()
        //            twinkleLayer.addRotationAnimation()
        //            twinkleLayer.addFadeInOutAnimation( CACurrentMediaTime() + CFTimeInterval(0.15 * Float(i)) )
        //            count += 1
        //        }
        
        let twinkleLayer: TwinkleLayer = TwinkleLayer()
        twinkleLayer.position = CGPoint(x: CGFloat(18), y: CGFloat(22))
        twinkleLayer.opacity = 0
        twinkleLayers.append(twinkleLayer)
        self.layer.addSublayer(twinkleLayer)
        twinkleLayer.addPositionAnimation()
        twinkleLayer.addRotationAnimation()
        twinkleLayer.addFadeInOutAnimation( CACurrentMediaTime() + CFTimeInterval(0.15 * Float(0)) )
        
        let twinkleLayer1: TwinkleLayer = TwinkleLayer()
        twinkleLayer1.position = CGPoint(x: CGFloat(99), y: CGFloat(46))
        twinkleLayer1.opacity = 0
        twinkleLayers.append(twinkleLayer1)
        self.layer.addSublayer(twinkleLayer1)
        twinkleLayer1.addPositionAnimation()
        twinkleLayer1.addRotationAnimation()
        twinkleLayer1.addFadeInOutAnimation( CACurrentMediaTime() + CFTimeInterval(0.15 * Float(0)) )
        
        let twinkleLayer2: TwinkleLayer = TwinkleLayer()
        twinkleLayer2.position = CGPoint(x: CGFloat(128), y: CGFloat(46))
        twinkleLayer2.opacity = 0
        twinkleLayers.append(twinkleLayer2)
        self.layer.addSublayer(twinkleLayer2)
        twinkleLayer2.addPositionAnimation()
        twinkleLayer2.addRotationAnimation()
        twinkleLayer2.addFadeInOutAnimation( CACurrentMediaTime() + CFTimeInterval(0.15 * Float(0)) )
        
        let twinkleLayer3: TwinkleLayer = TwinkleLayer()
        twinkleLayer3.position = CGPoint(x: CGFloat(165), y: CGFloat(17))
        twinkleLayer3.opacity = 0
        twinkleLayers.append(twinkleLayer3)
        self.layer.addSublayer(twinkleLayer3)
        twinkleLayer3.addPositionAnimation()
        twinkleLayer3.addRotationAnimation()
        twinkleLayer3.addFadeInOutAnimation( CACurrentMediaTime() + CFTimeInterval(0.15 * Float(0)) )
        
        
        twinkleLayers.removeAll(keepingCapacity: false)
    }
    
}

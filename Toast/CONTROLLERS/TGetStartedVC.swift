//
//  TGetStartedVC.swift
//  Toast
//
//  Created by Anish Pandey on 08/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class TGetStartedVC: UIViewController {
    
    @IBOutlet weak var imgView_YellowLogo: UIImageView!
    @IBOutlet weak var imgView_Background: UIImageView!
    @IBOutlet weak var lbl_IntroText: UILabel!
    @IBOutlet weak var btn_GetStarted: ZFRippleButton!
    @IBOutlet weak var imgView_WhiteLogo: UIImageView!
    @IBOutlet weak var imgView_whiteLine: UIImageView!
    @IBOutlet weak var const_WhiteLineWidth: NSLayoutConstraint!
    @IBOutlet weak var view_Twinkle: UIView!
    @IBOutlet weak var view_BGWhiteLine: UIView!
    @IBOutlet weak var view_Stars: UIView!
    @IBOutlet weak var const_startViewCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var const_imgWhiteLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var const_imgWhiteLineCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var imgView_star1: UIImageView!
    @IBOutlet weak var imgView_star2: UIImageView!
    @IBOutlet weak var imgView_star3: UIImageView!
    @IBOutlet weak var imgView_star4: UIImageView!
    @IBOutlet weak var imgView_star5: UIImageView!
    @IBOutlet weak var imgView_star6: UIImageView!
    @IBOutlet weak var view_Pagination: UIView!
    
    
    var leftSwipe: UISwipeGestureRecognizer!
    var rightSwipe: UISwipeGestureRecognizer!
    @IBOutlet weak var countlbl1: ZFRippleButton!
    @IBOutlet weak var countlbl2: ZFRippleButton!
    @IBOutlet weak var countlbl3: ZFRippleButton!
    var introImgArray : NSMutableArray = NSMutableArray()
    
    var imgCounter: Int = 0
    
    
    func setUpScroll()
    {
        introImgArray.add("ic_launce scree")
        introImgArray.add("ic_launce scree_1")
        introImgArray.add("ic_launce scree_2")
        
        countlbl1.backgroundColor = UIColor(hexCode: 0xCEAF5C) // selected
        countlbl2.backgroundColor = UIColor(hexCode: 0xFFFFFF)
        countlbl3.backgroundColor = UIColor(hexCode: 0xFFFFFF)
        
        // adding swipe
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TGetStartedVC.handleSwipes(_:)))
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TGetStartedVC.handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formattedString = NSMutableAttributedString()
        
        lbl_IntroText.attributedText = formattedString.big("Send a Cheer").small("")
        
        imgView_YellowLogo.alpha = 0.0
        lbl_IntroText.alpha = 0.0
        btn_GetStarted.alpha = 0.0
        view_Pagination.alpha = 0.0
        imgView_whiteLine.alpha = 0.0
        self.const_WhiteLineWidth.constant = 117
        self.view.layoutIfNeeded()
        
        //        let recognizer = UITapGestureRecognizer(target: self, action: #selector(TGetStartedVC.lbl_PersonsEmailTapped)) // add toastee clicked
        //        imgView_Background.isUserInteractionEnabled = true
        //        imgView_Background.addGestureRecognizer(recognizer)
        
        view_Stars.alpha = 0.0
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
            
        }, completion: {(finished: Bool) -> Void in
            self.imgView_whiteLine.alpha = 1.0
            
            UIView.animate(withDuration: 1.2, delay: 0.5, options: .beginFromCurrentState, animations: {() -> Void in
                
                self.const_WhiteLineWidth.constant = 1
                self.view.layoutIfNeeded()
                
            }, completion: {(finished: Bool) -> Void in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
                    self.view_Stars.alpha = 1.0
                    
                }, completion: {(finished: Bool) -> Void in
                    self.view_Twinkle.twinkle()
                    
                    _ = Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(TGetStartedVC.moveUp), userInfo: nil, repeats: false)
                })
            })
        })
        
        //        countlbl1.isHidden = true
        //        countlbl2.isHidden = true
        //        countlbl3.isHidden = true
        //        btn_GetStarted.isHidden = true
    }
    
    
    func moveUp()
    {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
            if(UIScreen.main.bounds.height == 568)
            {
                self.const_imgWhiteLineCenterY.constant = self.const_imgWhiteLineCenterY.constant - 174
                self.const_imgWhiteLogoCenterY.constant = self.const_imgWhiteLogoCenterY.constant - 174
                self.const_startViewCenterY.constant = self.const_startViewCenterY.constant - 174
                
            }
            else if(UIScreen.main.bounds.height == 667)
            {
                self.const_imgWhiteLineCenterY.constant = self.const_imgWhiteLineCenterY.constant - 224
                self.const_imgWhiteLogoCenterY.constant = self.const_imgWhiteLogoCenterY.constant - 224
                self.const_startViewCenterY.constant = self.const_startViewCenterY.constant - 224
            }
            else if(UIScreen.main.bounds.height == 736)
            {
                self.const_imgWhiteLineCenterY.constant = self.const_imgWhiteLineCenterY.constant - 262
                self.const_imgWhiteLogoCenterY.constant = self.const_imgWhiteLogoCenterY.constant - 262
                self.const_startViewCenterY.constant = self.const_startViewCenterY.constant - 262
            }
            self.view.layoutIfNeeded()
            //            self.emitterView.setIsEmitting(false)
            //            self.emitterView.stopAnimations()
        }, completion: {(finished: Bool) -> Void in
            
            let transition = CATransition()
            transition.duration = 0.7
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.imgView_Background.layer.add(transition, forKey: nil)
            self.imgView_Background.image = UIImage(named: "ic_launce scree")
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
                self.imgView_WhiteLogo.alpha = 0.0
                self.imgView_whiteLine.alpha = 0.0
                self.view_Stars.alpha = 0.0
                self.imgView_YellowLogo.alpha = 1.0
                self.lbl_IntroText.alpha = 1.0
                self.btn_GetStarted.alpha = 1.0
                self.view_Pagination.alpha = 1.0
                
            }, completion: {(finished: Bool) -> Void in
                self.setUpScroll()
            })
        })
    }
    
    //    // MARK: - UITapGestureRecognizer Delegate
    //    @objc fileprivate func lbl_PersonsEmailTapped(_ sender: UITapGestureRecognizer) {
    //
    //    }
    
    //MARK: - Swipe handle
    func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .right) {
            print("Swipe Right")
            
            
            
            imgCounter=imgCounter-1;
            if (imgCounter<0) {
                imgCounter=0;
            }
                
            else
            {
                imgView_Background.image = UIImage(named: "")
                
                //                UIView.animateWithDuration(1.5, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                //                    self.imgView_Background.image = UIImage(named: self.introImgArray.objectAtIndex(self.imgCounter) as! String)
                //
                //                }) { (Bool) -> Void in
                //                    //
                //                }
                
                
                let formattedString = NSMutableAttributedString()
                
                UIView.transition(with: self.imgView_Background, duration: 0.9, options: .transitionCrossDissolve, animations: {
                    
                    self.imgView_Background.image = UIImage(named: self.introImgArray.object(at: self.imgCounter) as! String)
                    
                    if (self.imgCounter==0) {
                        
                        self.lbl_IntroText.attributedText = formattedString.big("Send a Cheer").small("")
                        self.countlbl1.backgroundColor = UIColor(hexCode: 0xCEAF5C) // selected
                        self.countlbl2.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        self.countlbl3.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        
                    }
                    else if (self.imgCounter==1) {
                        
                        self.lbl_IntroText.attributedText = formattedString.big("Raise a Toast").small("")
                        self.countlbl1.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        self.countlbl2.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                        self.countlbl3.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                    }
                    else if (self.imgCounter==2) {
                        
                        self.lbl_IntroText.attributedText = formattedString.big("Cherish forever").small("")
                        self.countlbl1.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        self.countlbl2.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        self.countlbl3.backgroundColor = UIColor(hexCode: 0xCEAF5C)}
                        
                    else
                    {
                        
                        //                    self.performSelector(#selector(tourVC.skipBtnClicked(_:)), withObject: self, afterDelay: 0.0)
                    }
                    
                    NSLog("imageCounter %d",self.imgCounter);
                    
                }, completion: { (Bool) in
                    
                    
                    
                })
                
                
            }
            
            
        }
        
        if (sender.direction == .left) {
            print("Swipe Left")
            
            
            if (imgCounter<2) {
                imgCounter=imgCounter+1
                imgView_Background.image = UIImage(named: "")
                //                UIView.animateWithDuration(1.5, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                //                    self.imgView_Background.image = UIImage(named: self.introImgArray.objectAtIndex(self.imgCounter) as! String)
                //
                //                }) { (Bool) -> Void in
                //                    //
                //                }
                
                let formattedString = NSMutableAttributedString()
                
                UIView.transition(with: self.imgView_Background, duration: 0.9, options: .transitionCrossDissolve, animations: {
                    self.imgView_Background.image = UIImage(named: self.introImgArray.object(at: self.imgCounter) as! String)
                    
                    if (self.imgCounter==0) {
                        
                        self.lbl_IntroText.attributedText = formattedString.big("Send a Cheer").small("")
                        self.countlbl1.backgroundColor = UIColor(hexCode: 0xCEAF5C) // selected
                        self.countlbl2.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        self.countlbl3.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        
                    }
                    else if (self.imgCounter==1) {
                        
                        self.lbl_IntroText.attributedText = formattedString.big("Raise a Toast").small("")
                        self.countlbl1.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        self.countlbl2.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                        self.countlbl3.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                    }
                    else if (self.imgCounter==2) {
                        
                        self.lbl_IntroText.attributedText = formattedString.big("Cherish forever").small("")
                        self.countlbl1.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        self.countlbl2.backgroundColor = UIColor(hexCode: 0xFFFFFF)
                        self.countlbl3.backgroundColor = UIColor(hexCode: 0xCEAF5C)}
                        
                    else
                    {
                        //                    self.performSelector(#selector(tourVC.skipBtnClicked(_:)), withObject: self, afterDelay: 0.0)
                    }
                }, completion: { (Bool) in
                    
                    
                    
                })
            }
            else
            {
                //                    self.performSelector(#selector(tourVC.skipBtnClicked(_:)), withObject: self, afterDelay: 0.0)
                self.performSegue(withIdentifier: "landingVCSeg", sender: self)
            }
            
            //            self.performSegue(withIdentifier: "landingVCSeg", sender: self)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Actions
    
    @IBAction func btn_GetStartedClicked(_ sender: ZFRippleButton) {
        self.performSegue(withIdentifier: "landingVCSeg", sender: self)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//
//  CFForgotPasswordViewController.swift
//  Toast
//
//  Created by Arkenea on 29/09/16.
//  Copyright © 2016 Anish@Arkenea. All rights reserved.
//

import UIKit

class TForgotPwdVC: UIViewController {
    
    @IBOutlet weak var txtFld_Email: UITextField!
    @IBOutlet weak var btn_Send: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_Send.layer.borderWidth = 1.5
        btn_Send.layer.borderColor = UIColor.white.cgColor
        btn_Send.clipsToBounds = true
        
        _ = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(TForgotPwdVC.callSeg), userInfo: nil, repeats: false)
        
        self.CustomiseView()
    }
    func CustomiseView()
    {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TLogInViewController.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Log In")
    }
    
    func callSeg() {
        txtFld_Email.becomeFirstResponder()
    }
    
    // MARK: - Button Actions
    func backBtnClicked(_ sender: UIButton) {
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    @IBAction func btn_SendClicked(_ sender: UIButton) {
        self.forgotPasswordCalled()
    }
    
    func forgotPasswordCalled()
    {
        txtFld_Email.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.forgotPasswordCalled()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtFld_Email.resignFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

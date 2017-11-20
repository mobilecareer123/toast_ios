//
//  TEmailChangeVC.swift
//  Toast
//
//  Created by Anish Pandey on 11/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class TEmailChangeVC: UIViewController , UITextFieldDelegate {
    
    
    
    @IBOutlet weak var view_currentPassword: UIView!
    @IBOutlet weak var view_newEmail: UIView!
    
    @IBOutlet weak var txtFld_newEmail: UITextField!
    @IBOutlet weak var txtFld_currentPassword: UITextField!
    
    @IBOutlet weak var btn_Done: UIButton!
    
    var txt_active: UITextField!
    
    
    
    
    //**************************************************************************************************************
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CustomiseView()
        
    }
    
    func CustomiseView()
    {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TEmailChangeVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Change Email Id")
        
        view_currentPassword.layer.borderWidth = 1.0
        view_currentPassword.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_currentPassword.layer.cornerRadius = 3.0
        view_currentPassword.clipsToBounds = true
        
        view_newEmail.layer.borderWidth = 1.0
        view_newEmail.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_newEmail.layer.cornerRadius = 3.0
        view_newEmail.clipsToBounds = true
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if let txtFld = txt_active
        {
            txtFld .resignFirstResponder()
        }
    }
    
    // MARK: - WEB SERVICE Calls
    func ChangeEmailCalled()
    {
        /*
         
         {
         "service": "changeemail",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "current_password": "YXJrZW5lYUAxMjM=",
         "new_email_id": "meghna@gmail.com"
         }
         (txt_password.text! as String).base64String()
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            
            SVProgressHUD.show(withStatus: "Updating ...", maskType: .gradient)
            let parameters: NSDictionary = ["service": "changeemail", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!,"current_password": txtFld_currentPassword.text!.base64String(),"new_email_id": txtFld_newEmail.text ?? ""]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.show(withStatus: "Email successfully updated...", maskType: .gradient)
                        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
                        
                    })
                }
                if(statusToken as String == "Error" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        let error_message:NSString =  NSString(format: "%@",response["Error"]! as! NSString)
                        SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                    })
                }
            }
            
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
        
    }
    
    
    // MARK: - Button Actions
    @IBAction func btn_DoneClicked(_ sender: UIButton) {
        
        //            txt_password.isSecureTextEntry = txt_password.isSecureTextEntry ? false : true
        
        if (txtFld_newEmail.text?.isValidEmail())!
        {
            ChangeEmailCalled()
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: kValidEmailId, maskType: .gradient) 
        }
        
    }
    func  backBtnClicked(_ sender: UIButton!)
    {
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        txt_active = textField
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //            if(textField == txtFld_Email)
        //            {
        //                txt_password.becomeFirstResponder()
        //            }
        //            else if (textField == txt_password)
        //            {
        //                txt_password.resignFirstResponder()
        //                self.logIn()
        //            }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let txtFld = txt_active
        {
            txtFld .resignFirstResponder()
        }
    }
    
    override var hidesBottomBarWhenPushed: Bool
        {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
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

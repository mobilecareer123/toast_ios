//
//  ViewController.swift
//  Toast
//
//  Created by Arkenea on 19/09/16.
//  Copyright © 2016 Anish@Arkenea. All rights reserved.
//

import UIKit

class TLogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var view_Password: UIView!
    @IBOutlet weak var view_Email: UIView!
    
    @IBOutlet weak var txtFld_Email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    
    @IBOutlet weak var btn_logIn: UIButton!
    @IBOutlet weak var btn_forgotPassword: UIButton!
    
    
    @IBOutlet weak var btn_Send: ZFRippleButton!
    @IBOutlet weak var txtFld_PaswrdRecvryEmail: UITextField!
    @IBOutlet weak var btn_ClosePopUp: UIButton!
    
    @IBOutlet weak var view_ForgtPaswrdPopup: UIView!
    @IBOutlet weak var view_InnerPopup: UIView!
    @IBOutlet weak var view_popupEmail: UIView!
    
    var txt_active: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CustomiseView()
        
        _ = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(TLogInViewController.callSeg), userInfo: nil, repeats: false)
        
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
        
        
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Forgot Password?", attributes: underlineAttribute)
        btn_forgotPassword.titleLabel?.attributedText = underlineAttributedString
        
        
        view_Email.layer.borderWidth = 1.0
        view_Email.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_Email.layer.cornerRadius = 3.0
        view_Email.clipsToBounds = true
        
        view_Password.layer.borderWidth = 1.0
        view_Password.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_Password.layer.cornerRadius = 3.0
        view_Password.clipsToBounds = true
        
        view_popupEmail.layer.borderWidth = 1.0
        view_popupEmail.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_popupEmail.layer.cornerRadius = 3.0
        view_popupEmail.clipsToBounds = true
        
        view_ForgtPaswrdPopup.alpha = 0.0
        btn_ClosePopUp.alpha = 0.0
    }
    
    
    func callSeg() {
        txtFld_Email.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if let txtFld = txt_active
        {
            txtFld .resignFirstResponder()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Actions
    func  backBtnClicked(_ sender: UIButton!)
    {
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    @IBAction func lohInBtnBtnClicked(_ sender: UIButton) {
        //uncomment below
        self.logIn()
        
        //comment below
        //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        appDelegate.startAppForLoggedInUser()
    }
    
    @IBAction func btn_forgotPasswordClicked(_ sender: UIButton) {
        self.view_InnerPopup.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        self.btn_ClosePopUp.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        UIView.animate(withDuration: 0.5 ,animations: {
            self.view_ForgtPaswrdPopup.alpha = 1.0
            self.view_InnerPopup.transform = CGAffineTransform.identity
            
            self.btn_ClosePopUp.alpha = 1.0
            self.btn_ClosePopUp.transform = CGAffineTransform.identity
            
        },completion: { finish in
            if let txtFld = self.txt_active
            {
                txtFld .resignFirstResponder()
            }
            self.txtFld_PaswrdRecvryEmail.becomeFirstResponder()
        })
    }
    
    @IBAction func btn_signUpClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUpSeg", sender: self)
    }
    
    @IBAction func btn_SendClicked(_ sender: ZFRippleButton) {
        //uncomment below
        self.txtFld_PaswrdRecvryEmail.resignFirstResponder()
        _ = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(TLogInViewController.callForgotPassword), userInfo: nil, repeats: false)
    }
    
    func callForgotPassword()
    {
        self.forgotPassword()
    }
    
    @IBAction func btn_ClosePopUpClicked(_ sender: UIButton) {
        self.txtFld_PaswrdRecvryEmail.resignFirstResponder()
        UIView.animate(withDuration: 0.4 ,animations: {
            self.view_InnerPopup.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.view_ForgtPaswrdPopup.alpha = 0.0
            
            self.btn_ClosePopUp.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.btn_ClosePopUp.alpha = 0.0
        },completion: { finish in
        })
    }
    
    func logIn()
    {
        /*"{
         ""service"": ""login"",
         ""email_id"": ""John@gmail.com"",
         ""password"": ""YWRtaW5AMTIz"",
         ""device_token"": ""5asdw8921"",
         ""device_type"": ""I""
         }"*/
        
        
        if(!txtFld_Email.text!.isEmpty && !txt_password.text!.isEmpty)
        {
            if(txtFld_Email.text?.isValidEmail())!
            {
                if(txt_password.text?.isValidPassword())!
                {
                    let dataObj = NetworkData()
                    NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
                    if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
                    {
                        SVProgressHUD.show(withStatus: "Logging In", maskType: .gradient)
                        
                        var devicetoken:String = String()
                        if let deviceTokenTemp = UserDefaults.standard.value(forKey: KEY_DEVICE_TOKEN)
                        {
                            devicetoken = deviceTokenTemp as! String
                        }
                        if devicetoken.characters.count == 0 {
                            devicetoken = "5asdw8921"
                        }
                        print("Password **** \(txt_password.text! as String)")
                        let parameters: NSDictionary = ["service": "login", "email_id" : txtFld_Email.text!, "device_token" : devicetoken, "device_type" : "I", "password" : (txt_password.text! as String).base64String()]
                        
                        WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                            print(response)
                            /*"//If success
                             {
                             ""status"": ""Success"",
                             ""user_id"": 3,
                             ""access_token"": ""4168703259bWVnaG5hQGFya2VuZWEuY29t"",
                             ""notification_count"": 0
                             }
                             
                             // If have an account with social media
                             {
                             ""status"": ""Error"",
                             ""Error"": ""Email already registered from facebook. Login from facebook to access your account."",
                             ""ErrorCode"": ""10""
                             }"*/
                            
                            let statusToken:String =  String(format: "%@",response["status"]! as! String)
                            if(statusToken as String == "Success" as String)
                            {
                                DispatchQueue.main.async(execute: {
                                    SVProgressHUD.dismiss()
                                    if let txtFld = self.txt_active
                                    {
                                        txtFld .resignFirstResponder()
                                    }
                                    
                                    let userid:NSNumber =  response["user_id"] as! NSNumber
                                    let user_id:String = userid.stringValue
                                    let access_token:String =  String(format: "%@",response["access_token"]! as! String)
                                    let login_Key:String =  "UserLoggedIn"
                                    let email_id:String = self.txtFld_Email.text!
                                    let profile_photo:String =  String(format: "%@",response["profile_photo"]! as! String)
                                    let first_name:String =  String(format: "%@",response["first_name"]! as! String)
                                    let last_name:String =  String(format: "%@",response["last_name"]! as! String)
                                    
                                    
                                    let defaults = UserDefaults.standard
                                    defaults.setValue(user_id, forKey: KEY_USER_ID)
                                    defaults.setValue(access_token, forKey: KEY_ACCESS_TOKEN)
                                    defaults.setValue(login_Key, forKey: KEY_LOGIN)
                                    defaults.setValue(email_id, forKey: KEY_EMAIL_ID)
                                    defaults.setValue(first_name, forKey: KEY_FIRST_NAME)
                                    defaults.setValue(last_name, forKey: KEY_LAST_NAME)
                                    defaults.setValue(profile_photo, forKey: KEY_PROFILE_PIC_URL)
                                    defaults.setValue("Login", forKey: KEY_SOCIALMEDIA_TYPE)
                                    
                                    // Set to hide CoachMark tour on login
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_ToastVC)
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddCategoryVC)
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_ChatVC)
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_ViewToastDeatilsVC)
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_WriteMsgVC)
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_CreateToastVC)
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddToasteeVC)
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddMemberVC)
                                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddCollaborators)
 
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.startAppForLoggedInUser()
                                    
                                    
                                })
                            }
                            else if(statusToken as String == "Error" as String)
                            {
                                DispatchQueue.main.async(execute: {
                                    SVProgressHUD.dismiss()
                                    let error_message:String =  String(format: "%@",response["Error"]! as! String)
                                    SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                                })
                                
                            }
                            else
                            {
                                DispatchQueue.main.async(execute: {
                                    SVProgressHUD.dismiss()
                                    SVProgressHUD.showInfo(withStatus: "Server response failed" as String, maskType: .gradient)
                                })
                                
                                
                            }
                            
                        }
                        
                    }
                    else
                    {
                        SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
                    }
                    
                }
                else
                {
                    SVProgressHUD.showInfo(withStatus: kPwdValidation, maskType: .gradient)
                }
                
            }
            else
            {
                SVProgressHUD.showInfo(withStatus: kValidEmailId, maskType: .gradient)
            }
            
        }
        else {
            SVProgressHUD.showInfo(withStatus: "All fields are mandatory.", maskType: .gradient)
        }
    }
    
    func forgotPassword()
    {
        /*"{
         ""service"": ""forgotpassword"",
         ""email_id"": ""john@gmail.com""
         }"*/
        
        if(!txtFld_PaswrdRecvryEmail.text!.isEmpty)
        {
            if(txtFld_PaswrdRecvryEmail.text?.isValidEmail())!
            {
                let dataObj = NetworkData()
                if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
                {
                    SVProgressHUD.show(with: .gradient)
                    let parameters: NSDictionary = ["service": "forgotpassword", "email_id": txtFld_PaswrdRecvryEmail.text!]
                    
                    WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                        print(response)
                        let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                        if(statusToken as String == "Success" as String)
                        {
                            DispatchQueue.main.async(execute: {
                                
                                self.txtFld_PaswrdRecvryEmail.text = ""
                                
                                UIView.animate(withDuration: 0.4 ,animations: {
                                    
                                    self.view_InnerPopup.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                                    self.view_ForgtPaswrdPopup.alpha = 0.0
                                    
                                    self.btn_ClosePopUp.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                                    self.btn_ClosePopUp.alpha = 0.0
                                    
                                    SVProgressHUD.dismiss()
                                    
                                     SVProgressHUD.showInfo(withStatus: kResetPwd, maskType: .gradient)
                                    
                                    
                                },completion: { finish in

                                })
                                
                            })
                        }
                        else if(statusToken as String == "Error" as String)
                        {
                            DispatchQueue.main.async(execute: {
                                SVProgressHUD.dismiss()
                                let error_message:NSString = NSString(format: "%@",response["Error"]! as! NSString)
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
            else
            {
                SVProgressHUD.showInfo(withStatus: kValidEmailId, maskType: .gradient)
            }
            
        }
        else {
            SVProgressHUD.showInfo(withStatus: "Please enter recovery email.", maskType: .gradient)
        }
        
        
        
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        txt_active = textField
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtFld_Email)
        {
            txt_password.becomeFirstResponder()
        }
        else if (textField == txt_password)
        {
            txt_password.resignFirstResponder()
            //uncomment below
            self.logIn()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let txtFld = txt_active
        {
            txtFld .resignFirstResponder()
        }
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


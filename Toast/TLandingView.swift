//
//  ViewController.swift
//  Toast
//
//  Created by Anish Pandey on 04/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

import Social
import Accounts

import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class TLandingView: UIViewController ,FBSDKGraphRequestConnectionDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var btn_logIn: ZFRippleButton!
    @IBOutlet weak var btn_fbLogin: ZFRippleButton!
    @IBOutlet weak var btn_SignUp: ZFRippleButton!
    
    @IBOutlet weak var imgView_bg: UIImageView!
    
    // PopUp view
    
    @IBOutlet weak var btn_AddEmail: ZFRippleButton!
    @IBOutlet weak var txtFld_userEmail: UITextField!
    @IBOutlet weak var view_AddEmailPopupBg: UIView! // main view full screen
    @IBOutlet weak var view_EmailPopUp: UIView!
    @IBOutlet weak var view_addEmail: UIView!
    @IBOutlet weak var btn_ClosePopUp: UIButton!
    
    var signUpDict : NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For fb login
        
        if(FBSDKAccessToken.current() == nil)
        {
            NSLog("\n \n **************************** User NOT logged in ************************* \n \n")
        }
        else
        {
            NSLog("\n \n **************************** User logged in ************************* \n \n")
            print("\(FBSDKAccessToken.current().userID)")
        }
        
        
        
        view_addEmail.layer.borderWidth = 1.0
        view_addEmail.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_addEmail.layer.cornerRadius = 3.0
        view_addEmail.clipsToBounds = true
        view_AddEmailPopupBg.alpha = 0.0
        btn_ClosePopUp.alpha = 0.0
        
        
        
        
        //        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(TLandingView.changeImage), userInfo: nil, repeats: false)
    }
    
    func changeImage()
    {
        imgView_bg.image = UIImage(named: "ic_background_landing1")
        
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(TLandingView.changeImageOne), userInfo: nil, repeats: false)
    }
    
    func changeImageOne()
    {
        imgView_bg.image = UIImage(named: "ic_background_landing")
        
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(TLandingView.changeImage), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    // MARK: - Button Actions
    
    @IBAction func btn_logInClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LandingToLoginSeg", sender: self)
    }
    
    @IBAction func btn_signUpClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LandingToSignUpSeg", sender: self)
    }
    
    @IBAction func btn_ClosePopUpClicked(_ sender: UIButton) {
        self.txtFld_userEmail.resignFirstResponder()
        UIView.animate(withDuration: 0.4 ,animations: {
            self.view_EmailPopUp.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.view_AddEmailPopupBg.alpha = 0.0
            
            self.btn_ClosePopUp.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.btn_ClosePopUp.alpha = 0.0
        },completion: { finish in
        })
    }
    
    @IBAction func AddEmailBtnBtnClicked(_ sender: UIButton) {
        
        if ((self.txtFld_userEmail.text?.characters.count)! > 1 && (self.txtFld_userEmail.text?.isValidEmail())!)
        {
            
            UIView.animate(withDuration: 0.4 ,animations: {
                
                self.view_EmailPopUp.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                self.view_AddEmailPopupBg.alpha = 0.0
                
            },completion: { finish in
                
                self.txtFld_userEmail.resignFirstResponder()
            })
            
            
            Fb_SignUp(email: self.txtFld_userEmail.text!,
                      social_media_id: String(format: "%@",signUpDict["social_media_id"]! as! String),
                      social_media_profile_url: String(format: "%@",signUpDict["social_media_profile_url"]! as! String),
                      first_name: String(format: "%@",signUpDict["first_name"]! as! String),
                      last_name: String(format: "%@",signUpDict["last_name"]! as! String),
                      name: String(format: "%@",signUpDict["name"]! as! String))
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: "Please enter a valid email address.", maskType: .gradient)
        }
        
    }
    
    func ShowPopUp(email:String, social_media_id:String, social_media_profile_url:String, first_name: String, last_name: String, name: String)
    {
    }
    
    @IBAction func btn_FacebookLoginClicked(_ sender: UIButton)
    {
        
        FacebookHandler.getUserDetailsFromController(controller: self) { (response, error) in
            if error == nil {
                
                print(response ?? "")
                
                let responseDict:NSDictionary =  response as! NSDictionary
                
                let urlDict =  responseDict["picture"] as! NSDictionary
                let urlData =  urlDict["data"] as! NSDictionary
                let urlString = urlData["url"] as! String
                
                var userEmail:String =  getValueFromDictionary(dicData: responseDict, forKey: "email")
                
                
                if (userEmail.characters.count > 1 && userEmail.isValidEmail())
                {
                    Fb_SignUp(email: userEmail,
                              social_media_id: String(format: "%@",responseDict["id"]! as! String),
                              social_media_profile_url: urlString,
                              first_name: String(format: "%@",responseDict["first_name"]! as! String), last_name: String(format: "%@",responseDict["last_name"]! as! String),
                              name: String(format: "%@",responseDict["name"]! as! String))
                }
                else
                {
                    // call for setting email manually for furthur reference
                    
                    SVProgressHUD.showInfo(withStatus: "Email Id is not available for user", maskType: .gradient)
                    
                    // Ask user to add email manualy
                    
                    
                    self.view_EmailPopUp.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                    self.btn_ClosePopUp.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                    
                    UIView.animate(withDuration: 0.5 ,animations: {
                        
                        self.view_AddEmailPopupBg.alpha = 1.0
                        self.view_EmailPopUp.transform = CGAffineTransform.identity
                        
                        self.btn_ClosePopUp.alpha = 1.0
                        self.btn_ClosePopUp.transform = CGAffineTransform.identity
                        
                        
                    },completion: { finish in
                        
                        self.txtFld_userEmail.becomeFirstResponder()
                        
                    })
                    
                    
                    // set values in a dict for future use
                    self.signUpDict = ["email": userEmail,
                                       "social_media_id": String(format: "%@",responseDict["id"]! as! String),
                                       "social_media_profile_url": urlString,
                                       "first_name": String(format: "%@",responseDict["first_name"]! as! String),
                                       "last_name": String(format: "%@",responseDict["last_name"]! as! String),
                                       "name": String(format: "%@",responseDict["name"]! as! String)]
                    
                }
                
                
            }
                
            else {
                SVProgressHUD.showInfo(withStatus: error?.localizedDescription, maskType: .gradient)
            }
        }
    }
    //        self.performSegue(withIdentifier: "forgotPasswordSeg", sender: self)
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - WS Calls

func Fb_SignUp(email:String, social_media_id:String, social_media_profile_url:String, first_name: String, last_name: String, name: String)
{
    /*
     {
     "service": "socialmediasignup",
     "email_id": "john.doe@gmail.com",
     "social_media_id": "UYTG6yhjU",
     "social_media_type": "facebook",
     "social_media_profile_url": "http://www/facebook.com/john.doe",
     "first_name": "John",
     "last_name": "Doe",
     "device_type": "I",
     "device_token": "558975423dfsd-55"
     }
     */
    
    let dataObj = NetworkData()
    NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
    if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
    {
        SVProgressHUD.show(withStatus: "Connecting with Facebook ...", maskType: .gradient)
        
        var devicetoken:String = String()
        if let deviceTokenTemp = UserDefaults.standard.value(forKey: KEY_DEVICE_TOKEN)
        {
            devicetoken = deviceTokenTemp as! String
        }
        
        let parameters: NSDictionary = ["service": "socialmediasignup", "first_name" : first_name, "last_name" : last_name, "email_id" : email, "device_token" : devicetoken, "device_type" : "I", "social_media_id" : social_media_id, "social_media_type" : "facebook", "social_media_profile_url" : social_media_profile_url]
        
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
                    
                    /*
                     
                     "status": "Success",
                     "email_flag": false,
                     "user_id": 13,
                     "access_token": "1MzYzgAMH6Y7MwnIatHPqXgyPQdpABrj",
                     "notification_count": "0"
                     */
                    
                    let logInKey:NSNumber =  response["first_time_login"] as! NSNumber
                    let firstTimeLoginKey:String = logInKey.stringValue
                    
                    let userid:NSNumber =  response["user_id"] as! NSNumber
                    let user_id:String = userid.stringValue
                    let access_token:String =  String(format: "%@",response["access_token"]! as! String)
                    let login_Key:String =  "UserLoggedIn"
                    let email_id:String = email
                    let profile_photo:String =  social_media_profile_url
                    let first_name:String =  first_name
                    let last_name:String =  last_name
                    
                    //                                let profile_photo_url:String = String(format: "%@%@", KEY_PROFILEIMAGE_PATH, profile_photo)
                    
                    let defaults = UserDefaults.standard
                    defaults.setValue(user_id, forKey: KEY_USER_ID)
                    defaults.setValue(access_token, forKey: KEY_ACCESS_TOKEN)
                    defaults.setValue(login_Key, forKey: KEY_LOGIN)
                    defaults.setValue(email_id, forKey: KEY_EMAIL_ID)
                    defaults.setValue(first_name, forKey: KEY_FIRST_NAME)
                    defaults.setValue(last_name, forKey: KEY_LAST_NAME)
                    defaults.setValue(profile_photo, forKey: KEY_PROFILE_PIC_URL)
                    defaults.setValue("fbLogin", forKey: KEY_SOCIALMEDIA_TYPE)
                    
                    if firstTimeLoginKey == "1"// i.e no
                    {
                        NSLog(" SHOW COACH-MARKS >>>>>>>>>")
                        // Set to Show CoachMark tour on SignUp
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_ToastVC)
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_AddCategoryVC)
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_ChatVC)
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_ViewToastDeatilsVC)
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_WriteMsgVC)
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_CreateToastVC)
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_AddToasteeVC)
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_AddMemberVC)
                        UserDefaults.standard.setValue("Show", forKey: KEY_OverlayIndex_AddCollaborators)
                    }
                    else{
                        NSLog(" DO NOT SHOW COACH-MARKS >>>>>>>>>>")
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
 
                       
                    }
                    
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
        SVProgressHUD.dismiss()
        SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
    }
    
}

func SetEmailCalled(email:String, social_media_id:String, social_media_profile_url:String, first_name: String, last_name: String, name: String)
{
    //uncomment below
    
    /*
     
     {
     "service": "setemail",
     "user_id": "4",
     "access_token": "6850394721Y2hhbWFr",
     "email_id": "john.doe11@gmail.com"
     }
     
     */
    
    let dataObj = NetworkData()
    NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
    if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
    {
        SVProgressHUD.show(with: .gradient)
        let parameters: NSDictionary = ["service": "setemail", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "email_id" : email]
        
        WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
            print(response)
            let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
            if(statusToken as String == "Success" as String)
            {
                DispatchQueue.main.async(execute: {
                    SVProgressHUD.dismiss()
                    
                    
                    // perform signUp via FB
                    
                    Fb_SignUp(email: email,
                              social_media_id: social_media_id,
                              social_media_profile_url: social_media_profile_url,
                              first_name: first_name,
                              last_name: last_name,
                              name: name)
                    
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
        }
        
    }
    else
    {
        SVProgressHUD.dismiss()
        SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
    }
    
}

// MARK: - UITextFieldDelegate Methods
func textFieldDidBeginEditing(_ textField: UITextField)
{
}


func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    return true
}



/*
 LandingToSignUpSeg
 
 LandingToLoginSeg
 
 */

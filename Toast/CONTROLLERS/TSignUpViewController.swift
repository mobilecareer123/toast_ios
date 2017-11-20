//
//  CFSignUpViewController.swift
//  Toast
//
//  Created by Arkenea on 29/09/16.
//  Copyright © 2016 Anish@Arkenea. All rights reserved.
//

import UIKit
import MobileCoreServices

class TSignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, RSKImageCropViewControllerDelegate {
    
    @IBOutlet weak var imgView_profilePic: UIImageView!
    @IBOutlet weak var btn_OpenCamera: ZFRippleButton!
    @IBOutlet weak var btn_TermsOfServices: UIButton!
    @IBOutlet weak var btn_PrivacyPolicy: UIButton!
    @IBOutlet weak var btn_SignUp: ZFRippleButton!
    
    @IBOutlet weak var txtFld_FirstName: UITextField!
    @IBOutlet weak var txtFld_Email: UITextField!
    @IBOutlet weak var txtFld_LastName: UITextField!
    @IBOutlet weak var txtFld_Password: UITextField!
    
    @IBOutlet weak var view_Password: UIView!
    @IBOutlet weak var view_Email: UIView!
    @IBOutlet weak var view_FirstName: UIView!
    @IBOutlet weak var view_LastName: UIView!
    
    @IBOutlet weak var btn_PopupCamera: ZFRippleButton!
    @IBOutlet weak var btn_PopupLibrary: ZFRippleButton!
    @IBOutlet weak var btn_CancelPicker: ZFRippleButton!
    @IBOutlet weak var view_CameraPopup: UIView!
    @IBOutlet weak var view_CameraInner: UIView!
    @IBOutlet weak var constraint_PopupViewBottom: NSLayoutConstraint!
    
    var txtFld_Active:UITextField!
    var cameraUI: UIImagePickerController!
    var termsAndPricacyTag:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.CustomiseView()
        
        //        _ = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(TSignUpViewController.callSeg), userInfo: nil, repeats: false)
    }
    
    func CustomiseView()
    {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TSignUpViewController.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Sign Up")
        
        //underline to UILabel
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        var underlineAttributedString = NSAttributedString(string: "Terms of Service", attributes: underlineAttribute)
        btn_TermsOfServices.titleLabel?.attributedText = underlineAttributedString
        
        underlineAttributedString = NSAttributedString(string: "Privacy Policy", attributes: underlineAttribute)
        btn_PrivacyPolicy.titleLabel?.attributedText = underlineAttributedString
        
        view_Email.layer.borderWidth = 1.0
        view_Email.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_Email.layer.cornerRadius = 3.0
        view_Email.clipsToBounds = true
        
        view_Password.layer.borderWidth = 1.0
        view_Password.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_Password.layer.cornerRadius = 3.0
        view_Password.clipsToBounds = true
        
        view_FirstName.layer.borderWidth = 1.0
        view_FirstName.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_FirstName.layer.cornerRadius = 3.0
        view_FirstName.clipsToBounds = true
        
        view_LastName.layer.borderWidth = 1.0
        view_LastName.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_LastName.layer.cornerRadius = 3.0
        view_LastName.clipsToBounds = true
        
        imgView_profilePic.layer.borderWidth = 2.0
        imgView_profilePic.layer.borderColor = UIColor(hexCode: 0xFFFFFF).cgColor
        imgView_profilePic.layer.cornerRadius = UIScreen.main.bounds.size.height * (60.0 / 568.0)
        
        imgView_profilePic.clipsToBounds = true
        
        view_CameraInner.layer.cornerRadius = 5.0
        view_CameraInner.clipsToBounds = true
        
        
    }
    
    //    func callSeg() {
    //        txtFld_FirstName.becomeFirstResponder()
    //    }
    
    // MARK: - Button Actions
    func backBtnClicked(_ sender: UIButton) {
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    @IBAction func btn_TermsOfServicesClicked(_ sender: UIButton) {
        termsAndPricacyTag = 1
        self.performSegue(withIdentifier: "termsSeg", sender: self)
    }
    
    @IBAction func btn_OpenCameraClicked(_ sender: UIButton) {
        if let txtFld = txtFld_Active
        {
            txtFld .resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.constraint_PopupViewBottom.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    
    @IBAction func btn_PrivacyPolicyClicked(_ sender: UIButton) {
        termsAndPricacyTag = 2
        self.performSegue(withIdentifier: "termsSeg", sender: self)
    }
    
    @IBAction func btn_SignUpClicked(_ sender: ZFRippleButton) {
        //uncomment below
        self.createAccount()
        
        //comment below
        //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        appDelegate.startAppForLoggedInUser()
    }
    
    @IBAction func btn_PopupCameraClicked(_ sender: ZFRippleButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            self.cameraUI = UIImagePickerController()
            self.cameraUI.delegate = self
            self.cameraUI.sourceType = UIImagePickerControllerSourceType.camera
            self.cameraUI.allowsEditing = true
            self.cameraUI.modalPresentationStyle = .fullScreen
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            self.cameraUI.mediaTypes = mediaTypes as! [String]
            self.present(self.cameraUI, animated: true, completion: nil)
            // self.toggleFlash()
        }
        else
        {
            // error msg
        }
        self.hidePicker()
        
        
    }
    @IBAction func btn_PopupLibraryClicked(_ sender: ZFRippleButton) {
        self.hidePicker()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        {
            cameraUI = UIImagePickerController()
            cameraUI.delegate = self
            cameraUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraUI.mediaTypes = mediaTypes as! [String]
            cameraUI.allowsEditing = true
            
            self.present(cameraUI, animated: true, completion: nil)
        }
        else
        {
            // error msg
        }
        
    }
    
    @IBAction func btn_CancelPickerClicked(_ sender: ZFRippleButton) {
        self.hidePicker()
    }
    
    func hidePicker()
    {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.constraint_PopupViewBottom.constant = -155.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    // MARK: - WS Calls
    
    func checkEmailAvailability()
    {
        /*"{
         ""service"": ""checkemail"",
         ""email_id"":""johndoe@gmail.com""
         }"*/
        
        
        if(!txtFld_Email.text!.isEmpty)
        {
            if((txtFld_Email.text?.isValidEmail())!)
            {
                let dataObj = NetworkData()
                NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
                if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
                {
                    
                    let parameters: NSDictionary = ["service": "checkemail", "email_id": txtFld_Email.text!]
                    
                    WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                        print(response)
                        DispatchQueue.main.async(execute: {
                            let statusToken:String =  String(format: "%@",response["status"]! as! String)
                            if(statusToken as String == "Error" as String)
                            {
                                let error_code = response["ErrorCode"] as! NSNumber
                                if(error_code == 7)
                                {
                                    DispatchQueue.main.async(execute: {
                                        self.txtFld_Email.textColor = UIColor.red
                                    })
                                }
                            }
                        })
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
            // SVProgressHUD.showInfo(withStatus: "Please enter valid email.", maskType: .gradient)
        }
        
        
        
    }
    
    func createAccount()
    {
        
        /*"{
         ""service"": ""emailsignup"",
         ""password"": ""YWRtaW5AMTIz"",
         ""email_id"": ""John@gmail.com"",
         ""first_name"": ""Doe"",
         ""last_name"": ""Deshpande"",
         ""device_token"": ""dfsds356893fj-04s"",
         ""device_type"": ""I"",
         ""multipart"": ""Y""
         }
         
         $_FILES['image']"*/
        
        
        if(!txtFld_Email.text!.isEmpty && !txtFld_LastName.text!.isEmpty && !txtFld_Password.text!.isEmpty && !txtFld_FirstName.text!.isEmpty)
        {
            if(txtFld_Email.text?.isValidEmail())!
            {
                if(txtFld_Password.text?.isValidPassword())!
                {
                    let dataObj = NetworkData()
                    NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
                    if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
                    {
                        SVProgressHUD.show(withStatus: "Creating account", maskType: .gradient)
                        
                        var multipart:String = "N"
                        if imgView_profilePic.image != nil{
                            multipart = "Y"
                        }
                        var devicetoken:String = String()
                        if let deviceTokenTemp = UserDefaults.standard.value(forKey: KEY_DEVICE_TOKEN)
                        {
                            devicetoken = deviceTokenTemp as! String
                        }
                        if devicetoken.characters.count == 0 {
                            devicetoken = "dfsds356893fj-04s"
                        }
                        
                        let parameters: NSDictionary = ["service": "emailsignup", "first_name" : txtFld_FirstName.text!, "last_name" : txtFld_LastName.text!, "email_id" : txtFld_Email.text!, "device_token" : devicetoken, "device_type" : "I", "password" : (txtFld_Password.text! as String).base64String(), "multipart" : multipart]
                        
                        var profilePic: String = ""
                        if imgView_profilePic.image != nil {
                            let imageData = UIImagePNGRepresentation(imgView_profilePic.image!)
                            let filePath: NSString = (NSTemporaryDirectory() as NSString).appendingPathComponent("userimage.png") as NSString
                            
                            do {
                                try imageData?.write(to: URL(fileURLWithPath: filePath as String), options: .atomic)
                                profilePic = filePath as String
                            } catch {
                                
                            }
                        }
                        
                        WebService.multipartRequest(postDict: parameters, ProfileImage: profilePic){  (response, error) in
                            
                            // WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                            print(response)
                            let statusToken:String =  String(format: "%@",response["status"]! as! String)
                            if(statusToken as String == "Success" as String)
                            {
                                DispatchQueue.main.async(execute: {
                                    
                                    SVProgressHUD.dismiss()
                                    if let txtFld = self.txtFld_Active
                                    {
                                        txtFld .resignFirstResponder()
                                        self.viewDown()
                                    }
                                    
                                    let userid:NSNumber =  response["user_id"] as! NSNumber
                                    let user_id:String = userid.stringValue
                                    let social_media_type:String =  String(format: "%@",response["social_media_type"]! as! String)
                                    let last_name:String =  self.txtFld_LastName.text!
                                    let profile_photo:String =  String(format: "%@",response["profile_photo"]! as! String)
                                    let access_token:String =  String(format: "%@",response["access_token"]! as! String)
                                    let first_name:String =  self.txtFld_FirstName.text!
                                    let login_Key:String =  "UserLoggedIn"
                                    let email_id:String = self.txtFld_Email.text!
                                    
                                    let defaults = UserDefaults.standard
                                    defaults.setValue(user_id, forKey: KEY_USER_ID)
                                    defaults.setValue(social_media_type, forKey: KEY_SOCIALMEDIA_TYPE)
                                    defaults.setValue(first_name, forKey: KEY_FIRST_NAME)
                                    defaults.setValue(last_name, forKey: KEY_LAST_NAME)
                                    defaults.setValue(profile_photo, forKey: KEY_PROFILE_PIC_URL)
                                    defaults.setValue(access_token, forKey: KEY_ACCESS_TOKEN)
                                    defaults.setValue(login_Key, forKey: KEY_LOGIN)
                                    defaults.setValue(email_id, forKey: KEY_EMAIL_ID)
                                    
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
                                    
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.startAppForLoggedInUser()
                                    
                                    
                                })
                            }
                            else if(statusToken as String == "Error" as String)
                            {
                                let error_code = response["ErrorCode"] as! NSNumber
                                if(error_code == 8)
                                {
                                    DispatchQueue.main.async(execute: {
                                        SVProgressHUD.dismiss()
                                        self.txtFld_Email.textColor = UIColor.red
                                    })
                                }
                                else
                                {
                                    DispatchQueue.main.async(execute: {
                                        SVProgressHUD.dismiss()
                                        let error_message:NSString =  NSString(format: "%@",response["Error"]! as! NSString)
                                        SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                                    })
                                }
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
                    SVProgressHUD.showInfo(withStatus: kChangePwd_Validation, maskType: .gradient)
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
    
    
    //MARK:UIImagePickerController Delegate
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let selectedImage1: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        imgView_profilePic.image = selectedImage1.af_imageRoundedIntoCircle()
        btn_OpenCamera.setImage(UIImage(named:""), for: .normal)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //    //MARK:RSKImageCropViewController Delegate
    //    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
    //        var compressed_Image = croppedImage//.imageWithImageInSize(croppedImage)
    //
    //        compressed_Image = compressed_Image.af_imageScaled(to: CGSize(width: compressed_Image.size.width/2, height:compressed_Image.size.height/2))
    //        imgView_profilePic.image = compressed_Image.af_imageRoundedIntoCircle()
    //        btn_OpenCamera.setImage(UIImage(named:""), for: .normal)
    //
    //        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    //    }
    //
    //    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
    //        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    //    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if(self.constraint_PopupViewBottom.constant == 0.0)
        {
            self.hidePicker()
        }
        
        if(textField == txtFld_Email)
        {
            textField.textColor = UIColor.darkGray
        }
        txtFld_Active = textField
        if(self.view.frame.origin.y == 64)
        {
            self.viewUp()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == txtFld_Email)
        {
            //uncomment below
            self.checkEmailAvailability()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtFld_FirstName)
        {
            txtFld_LastName.becomeFirstResponder()
        }
        else if (textField == txtFld_LastName)
        {
            txtFld_Email.becomeFirstResponder()
        }
        else if (textField == txtFld_Email)
        {
            txtFld_Password.becomeFirstResponder()
        }
        else if (textField == txtFld_Password)
        {
            txtFld_Password.resignFirstResponder()
            self.viewDown()
            //uncomment below
            self.createAccount()
        }
        
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(self.constraint_PopupViewBottom.constant == 0.0)
        {
            self.hidePicker()
        }
        
        if let txtFld = txtFld_Active
        {
            txtFld .resignFirstResponder()
            if self.view.frame.origin.y != 0
            {
               self.viewDown()
            }
            
        }
    }
    
    func viewUp()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: .curveEaseOut, animations: {
                        self.view.frame = CGRect(x: self.view.frame.origin.x,  y: self.view.frame.origin.y-130,  width: self.view.frame.size.width,  height: self.view.frame.size.height)
                        
                        
        }, completion: nil)
    }
    
    func viewDown()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: .curveEaseOut, animations: {
                        self.view.frame = CGRect( x: self.view.frame.origin.x,  y: 64,  width: self.view.frame.size.width,  height: self.view.frame.size.height)
                        
        }, completion: nil)
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "termsSeg")
        {
            if let termsAndPrivacyVC: TTermsPolicyVC = segue.destination as? TTermsPolicyVC {

                    termsAndPrivacyVC.screenTag = termsAndPricacyTag
               
            }
        }
    }
}

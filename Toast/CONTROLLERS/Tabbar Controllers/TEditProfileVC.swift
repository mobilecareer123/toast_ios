//
//  TEditProfileVC.swift
//  Toast
//
//  Created by Anish Pandey on 11/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import MobileCoreServices
import SDWebImage

class TEditProfileVC: UIViewController , UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var btn_EditPhoto: UIButton!
    @IBOutlet weak var view_firstName: UIView!
    @IBOutlet weak var view_lastName: UIView!
    
    @IBOutlet weak var txtFld_firstName: UITextField!
    @IBOutlet weak var txtFld_lastName: UITextField!
    @IBOutlet weak var imgView_ProfilePic: UIImageView!
    
    @IBOutlet weak var btn_Done: UIButton!
    
    var txt_active: UITextField!
    
    @IBOutlet weak var btn_PopupCamera: ZFRippleButton!
    @IBOutlet weak var btn_PopupLibrary: ZFRippleButton!
    @IBOutlet weak var btn_CancelPicker: ZFRippleButton!
    @IBOutlet weak var view_CameraPopup: UIView!
    @IBOutlet weak var view_CameraInner: UIView!
    @IBOutlet weak var constraint_PopupViewBottom: NSLayoutConstraint!
    var cameraUI: UIImagePickerController!
    var selectedUserImage:UIImage!
    
    //**************************************************************************************************************
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CustomiseView()
        SVProgressHUD.show(with: .gradient)
       // let profileUrlStr = UserDefaults.standard.value(forKey: KEY_PROFILE_PIC_URL) as! String?
        
//        let profileUrlStr:String = String(format: "%@%@", KEY_PROFILEIMAGE_PATH, UserDefaults.standard.value(forKey: KEY_PROFILE_PIC_URL) as! String)
//        self.load_image(profileUrlStr)
//        
//        self.txtFld_firstName.text = UserDefaults.standard.value(forKey: KEY_FIRST_NAME) as! String?
//        self.txtFld_lastName.text = UserDefaults.standard.value(forKey: KEY_LAST_NAME) as! String?
        
        //no need to call profile details as at the time of login we are saving user basic details in userdefaults. after editing replace previous values in userdefaults
        
         FetchProfileDetails()
        
    }
    func load_image(_ urlString:String)
    {
        if(urlString.characters.count > 0)
        {
            let ProfileURL: URL = URL(string: urlString)!
            let manager:SDWebImageManager = SDWebImageManager.shared()
            manager.downloadImage(with: ProfileURL, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                let aspectScaledToFillImage = image?.af_imageRoundedIntoCircle()
                self.imgView_ProfilePic.image = aspectScaledToFillImage
                SVProgressHUD.dismiss()
            })
        }
        else
        {
            SVProgressHUD.dismiss()
        }
    }
    
    func CustomiseView()
    {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TEditProfileVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Edit Profile")
        
        
        view_firstName.layer.borderWidth = 1.0
        view_firstName.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_firstName.layer.cornerRadius = 3.0
        view_firstName.clipsToBounds = true
        
        view_lastName.layer.borderWidth = 1.0
        view_lastName.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        view_lastName.layer.cornerRadius = 3.0
        view_lastName.clipsToBounds = true
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if let txtFld = txt_active
        {
            txtFld .resignFirstResponder()
        }
    }
    // MARK: - Webservise Calls
    
    func FetchProfileDetails()
    {
        /*
         
         {
         "service": "viewprofile",
         "user_id": "4",
         "access_token": "9834120756Y2hhbXBhLms4OUBnbWFpbC5jb20=",
         "profile_id": "13"  // required to see the other ppl details.
         }
         
         */
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "viewprofile", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "profile_id" : UserDefaults.standard.value(forKey: KEY_USER_ID)!]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    
                    /*
                     {
                     "status": "Success",
                     "profile_photo": "default.jpg",
                     "first_name": "subodh",
                     "last_name": "deshmukh",
                     "email_id": "subodh@arkenea.com"
                     }
                     */
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        let PhotoUrlStr: String = NSString(format: "%@",response["profile_photo"]! as! NSString) as String
                        
                        let UrlStr: String = String(format: "%@%@", KEY_PROFILEIMAGE_PATH, PhotoUrlStr)
                        
                        if(UrlStr.characters.count > 0)
                        {
                            self.load_image(UrlStr)
                        }
                        
                        self.txtFld_firstName.text = NSString(format: "%@",response["first_name"]! as! NSString) as String
                        self.txtFld_lastName.text = NSString(format: "%@",response["last_name"]! as! NSString) as String
                    })
                }
                else if(statusToken as String == "Error" as String)
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
    
    func updateProfileDetails()
    {
        /*
         
         {
         "service": "editprofile",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "first_name": "Peter",
         "last_name": "Hadly",
         "multipart": "Y"
         }
         
         $_FILES['image']
         
         */
        
        
        var multipart = "N"
        if (selectedUserImage != nil)
        {
            multipart = "Y"
        }
        if(!txtFld_firstName.text!.isEmpty && !txtFld_lastName.text!.isEmpty)
        {
            let dataObj = NetworkData()
            if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
            {
                SVProgressHUD.show(with: .gradient)
                let parameters: NSDictionary = ["service": "editprofile", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "first_name" : txtFld_firstName.text ?? "","last_name": txtFld_lastName.text ?? "","multipart": multipart]
                
                
                /*
                 WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                 SVProgressHUD.dismiss()
                 print(response)
                 
                 let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                 if(statusToken as String == "Success" as String)
                 {
                 ((self.navigationController)! as UINavigationController).popViewController(animated: true)
                 }
                 else if(statusToken as String == "Error" as String)
                 {
                 let error_message:NSString =  NSString(format: "%@",response["Error"]! as! NSString)
                 SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                 }
                 }
                 
                 }
                 else
                 {
                 SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
                 }
                 */
                
                var userImg: String = ""
                if (selectedUserImage != nil) {
                    let imageData = UIImagePNGRepresentation(imgView_ProfilePic.image!)
                    let filePath: NSString = (NSTemporaryDirectory() as NSString).appendingPathComponent("userimage.png") as NSString
                    
                    do {
                        try imageData?.write(to: URL(fileURLWithPath: filePath as String), options: .atomic)
                        userImg = filePath as String
                    } catch {
                        
                    }
                }
                
                WebService.multipartRequest(postDict: parameters, ProfileImage: userImg){  (response, error) in
                    
                    print(response)
                    let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                    
                    if(statusToken as String == "Success" as String)
                    {
                        DispatchQueue.main.async(execute: {
                            
                            SVProgressHUD.dismiss()
                            
                            let profile_photo:String =  String(format: "%@",response["profile_photo"]! as! String)
                          //  let profile_photo_url:String = String(format: "%@%@", KEY_PROFILEIMAGE_PATH, profile_photo)
                            
                            let defaults = UserDefaults.standard
                            defaults.removeObject(forKey: KEY_PROFILE_PIC_URL)
                            defaults.removeObject(forKey: KEY_FIRST_NAME)
                            defaults.removeObject(forKey: KEY_LAST_NAME)
                            
                            defaults.setValue(profile_photo, forKey: KEY_PROFILE_PIC_URL)
                            defaults.setValue(self.txtFld_firstName.text, forKey: KEY_FIRST_NAME)
                            defaults.setValue(self.txtFld_lastName.text, forKey: KEY_LAST_NAME)
                            
                            
                            SVProgressHUD.showInfo(withStatus: "Profile updated successfully", maskType: .gradient)
                            
                            ((self.navigationController)! as UINavigationController).popViewController(animated: true)
                            
                        })
                    }
                    else if(statusToken as String == "Error" as String)
                    {
                        //                    let error_code = response["ErrorCode"] as! NSNumber
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
            SVProgressHUD.showInfo(withStatus: "First Name and Last Name are mandatory" as String, maskType: .gradient)
        }
        
    }
    
    
    // MARK: - Button Actions
    @IBAction func btn_DoneClicked(_ sender: UIButton) {
        
        updateProfileDetails()
    }
    func  backBtnClicked(_ sender: UIButton!)
    {
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    @IBAction func btn_EditPhotoClicked(_ sender: UIButton) {
        if let txtFld = txt_active
        {
            txtFld .resignFirstResponder()
        }
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.constraint_PopupViewBottom.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
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
    
    //MARK:UIImagePickerController Delegate
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let selectedImage1: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        imgView_ProfilePic.image = selectedImage1.af_imageRoundedIntoCircle()
        selectedUserImage = imgView_ProfilePic.image
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.hidePicker()
        
        txt_active = textField
        if(self.view.frame.origin.y == 64)
        {
            self.viewUp()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtFld_firstName)
        {
            txtFld_lastName.becomeFirstResponder()
        }
        else if (textField == txtFld_lastName)
        {
            txtFld_lastName.resignFirstResponder()
            self.viewDown()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let txtFld = txt_active
        {
            txtFld .resignFirstResponder()
            self.viewDown()
        }
    }
    
    func viewUp()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: .curveEaseOut, animations: {
                        self.view.frame = CGRect(x: self.view.frame.origin.x,  y: self.view.frame.origin.y-90,  width: self.view.frame.size.width,  height: self.view.frame.size.height)
                        
                        
        }, completion: nil)
    }
    
    func viewDown()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: .curveEaseOut, animations: {
                        self.view.frame = CGRect( x: self.view.frame.origin.x,  y: 64,  width: self.view.frame.size.width,  height: self.view.frame.size.height)
                        
        }, completion: nil)
        
        
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

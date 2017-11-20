//
//  TCreateToast_WriteMsgVC.swift
//  Toast
//
//  Created by Anish Pandey on 17/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import MobileCoreServices
import SDWebImage

class TCreateToast_WriteMsgVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var background_image: UIImageView!
    @IBOutlet weak var txtView_Message: UITextView!
    @IBOutlet weak var btn_AddImage: ZFRippleButton!
    @IBOutlet weak var view_AddImageBg: UIView!
    @IBOutlet weak var imgView_Wish: UIImageView!
    @IBOutlet weak var btn_deleteImage: UIButton!
    
    @IBOutlet weak var btn_PopupCamera: ZFRippleButton!
    @IBOutlet weak var btn_PopupLibrary: ZFRippleButton!
    @IBOutlet weak var btn_CancelPicker: ZFRippleButton!
    @IBOutlet weak var view_CameraPopup: UIView!
    @IBOutlet weak var view_CameraInner: UIView!
    @IBOutlet weak var constraint_PopupViewBottom: NSLayoutConstraint!
    @IBOutlet weak var btn_edit: UIButton!
    
    var cameraUI: UIImagePickerController!
    
    var isEditMode:Bool = false//true if editing post, false if creating post
    var isCreatingToast : Bool = false // true - if called while creating Toast
    
    var selected_ToastId:String = String()
    var selected_PostId:String = String()
    var selected_ToastTitle:String = String()
    
    var selected_Post_text:String = String()
    var selected_Post_image:String = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CustomiseView()

        self.txtView_Message.isEditable = false
        let def = UserDefaults.standard
        let value = def.value(forKey: "category") as! String
        if let showLabel = def.value(forKey: "showMessage") as? Bool
        {
            if showLabel != false
            {
                let message = def.value(forKey: "message") as! String
                self.txtView_Message.text = message
            }

        }
        if(value == "Achievement")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_achievment")
        }
        else if(value == "Anniversary")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_anniversary")

        }
        else if(value == "BabyShower")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_babyshower")

        }
        else if(value == "Birthday")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_birthday")

        }
        else if(value == "DotingDad")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_dotingdat")

        }
        else if(value == "Engagement")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_engagement")

        }
        else if(value == "Farewell")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_farewell")

        }
        else if(value == "Friendship")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_friendship")

        }
        else if(value == "Graduation")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_graduation")

        }
        else if(value == "Housewarming")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_housewarming")

        }
        else if(value == "MightyMom")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_teacher")

        }
        else if(value == "NewVenture")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_newventure")

        }
        else if(value == "Promotion")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_promotion")

        }
        else if(value == "TerrificTeacher")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_teacher")

        }
        else if(value == "ThankYou")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_thankyou")

        }
        else if(value == "Wedding")
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_wedding")

        }
        else
        {
            self.background_image.contentMode = .scaleAspectFill
            self.background_image.image = UIImage(named: "img_promotion")

        }
        
        
        if(isEditMode == false)
        {
//            txtView_Message.text = "Type your cheer..."
//            txtView_Message.textColor = UIColor(hexCode: 0xBEC0C0)
//            
            imgView_Wish.isHidden = true
            btn_deleteImage.isHidden = true
            
            
            let overlayIndex_WriteMsg = UserDefaults.standard.string(forKey: KEY_OverlayIndex_WriteMsgVC) as NSString?
            if let newOverlayIndex_WriteMsg = overlayIndex_WriteMsg
            {
                if(newOverlayIndex_WriteMsg == "Show")
                {
                    
                    // do not show keyboard when showing coachmark
                    
                }
                else
                {
                    _ = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(TCreateToast_WriteMsgVC.callSeg), userInfo: nil, repeats: false)
                }
            }
            
            
        }
        else // if Edit Mode
        {
//            SVProgressHUD.show(with: .gradient)
//            
//            let str = selected_Post_text
//            
//            // Convert to show Emoticons
//            let emojData : NSData = str.data(using: String.Encoding.utf8)! as NSData
//            let emojString:String = String(data: emojData as Data, encoding: String.Encoding.nonLossyASCII)!
//            
//            if(emojString.characters.count > 0)
//            {
//                txtView_Message.textColor = UIColor(hexCode: 0x666666)
//                
//                txtView_Message.text = emojString
//            }
//            else
//            {
//                txtView_Message.text = "Type your cheer..."
//                txtView_Message.textColor = UIColor(hexCode: 0xBEC0C0)
//            }
//            if(selected_Post_image.characters.count > 0)
//            {
//                view_AddImageBg.isHidden = true
//                
//                let toastURL: URL = URL(string: selected_Post_image)!
//                let manager:SDWebImageManager = SDWebImageManager.shared()
//                manager.downloadImage(with: toastURL, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
//                    let aspectScaledToFillImage = image //?.af_imageAspectScaled(toFill: (self.imgView_Wish.frame.size))
//                    self.imgView_Wish.image = aspectScaledToFillImage
//                    SVProgressHUD.dismiss()
//                })
//            }
//            else
//            {
//                imgView_Wish.isHidden = true
//                btn_deleteImage.isHidden = true
//                SVProgressHUD.dismiss()
//            }
        }
    }
    
    @IBAction func edit_clicked(_ sender: Any) {
        self.txtView_Message.isEditable = true
        self.btn_edit.isEnabled = false
    }
    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Toast To")
        
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        
        if self.isCreatingToast == true
        {
            buttonback.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15.5)
            buttonback.setTitle("Skip", for: .normal)
        }
        else
        {
            buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        }
        
        buttonback.addTarget(self, action: #selector(TCreateToast_WriteMsgVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        let btn_Post: UIButton = UIButton(type: UIButtonType.custom)
        btn_Post.frame = CGRect(x: 0, y: -25, width: 38, height: 30)
        btn_Post.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15.5)
        btn_Post.setTitle("Post", for: .normal)
        btn_Post.addTarget(self, action: #selector(TCreateToast_WriteMsgVC.btn_PostClicked(_:)), for: UIControlEvents.touchUpInside)
        let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_Post)
        //        let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        //        navigationItem.width = -10
        //        let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
        self.navigationItem.setRightBarButton(rightBarButtonItemShare, animated: true)
        
        txtView_Message.layer.cornerRadius = 3.0
        txtView_Message.clipsToBounds = true
        
        let overlayIndex_WriteMsg = UserDefaults.standard.string(forKey: KEY_OverlayIndex_WriteMsgVC) as NSString?
        if let newOverlayIndex_WriteMsg = overlayIndex_WriteMsg
        {
            if(newOverlayIndex_WriteMsg == "Show")
            {
                if(isEditMode == false)
                {
                    //show overlay after sometime
                    _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(TCreateToast_WriteMsgVC.startOverLay), userInfo: nil, repeats: false)
                }
            }
        }
        else{
            if(isEditMode == false)
            {
                //show overlay after sometime
                _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(TCreateToast_WriteMsgVC.startOverLay), userInfo: nil, repeats: false)
            }
        }
    }
    
    func startOverLay()
    {
        let item = self.navigationItem.rightBarButtonItem
        let button = item?.customView as! UIButton
        
        /*      self.view.window?.addOverlayByHighlightingSubView(self.txtView_Message, withText: "Write your cheer message. This is your chance to Say Cheers!")
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
         self.view.window?.addOverlayByHighlightingSubView(self.view_AddImageBg, withText: "Add an image to your cheer for a more personalised touch.")
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
         self.view.window?.addOverlayByHighlightingSubView(button, withText: "Click post to update your cheer on this toast.")
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
         self.view.window?.removeOverlay()
         UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_WriteMsgVC)
         }
         }
         }
         */
        
        // next button tap
        var vArr = [UIView]() // array of views
        var strArr = [String]() // array of text
        vArr = [self.txtView_Message,self.view_AddImageBg,button]
        strArr = ["Write your cheer message. This is your chance to wish and 'Say Cheers'!",
                  "You can add an image to personalize your wish. If you want to add multiple images, consider adding a collage image.",
                  "Click post to update your cheer on this toast."]
        
        
        self.view.window?.getViewsWithText(vArr, textArr: strArr)
        
        // remove comment to call it for one time
        UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_WriteMsgVC)
        
    }
    
    func callSeg() {
        txtView_Message.becomeFirstResponder()
    }
    
    // MARK: - Button Actions
    
    func backBtnClicked(_ sender: UIButton!)
    {
        if self.isCreatingToast == true
        {
            ((self.navigationController)! as UINavigationController).popToRootViewController(animated: true)
            
        }
        else
        {
            ((self.navigationController)! as UINavigationController).popViewController(animated: true)
            
        }
        
    }
    
    @IBAction func btn_addImageClicked(_ sender: ZFRippleButton) {
        txtView_Message.resignFirstResponder()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.constraint_PopupViewBottom.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func btn_PostClicked(_ sender: UIButton!)
    {
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        SVProgressHUD.show(with: .gradient)
        txtView_Message.resignFirstResponder()
        
        let  str = txtView_Message.text as String
        if str.isEmpty == true || str == "Type your cheer..."
        {
            //More
            func handleCancel(_ alertView: UIAlertAction!)
            {
                self.dismiss(animated: true, completion: nil)
            }
            
            let alert = UIAlertController(title: nil, message: kWriteCheer, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:handleCancel))
            alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
            self.present(alert, animated: true, completion: nil)
            SVProgressHUD.dismiss()
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            
        }
        else
        {
            // SVProgressHUD.dismiss()
            
            if(isEditMode == true)
            {
                UpdateMsgOnGroup()
            }
            else
            {
                PostMsgOnGroup()
            }
        }
    }
    
    // MARK: - WS Calls
    
    func PostMsgOnGroup()
    {
        /*
         // Post new message
         {
         "service": "postmessage",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "toast_id": "2",
         "message_text": "Happy Birthday",
         "multipart": "Y"
         }
         $_FILES['image']
         */
        
        let dataObj = NetworkData()
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(withStatus: "Adding post...", maskType: .gradient)
            
            var multipart = "N"
            if (imgView_Wish.image) != nil
            {
                multipart = "Y"
            }
            
            // convert text to support emoticons
            let  str = txtView_Message.text as String
            let textViewData : NSData = str.data(using: String.Encoding.nonLossyASCII)! as NSData
            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
            
            let parameters: NSDictionary = ["service": "postmessage", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selected_ToastId, "message_text" : valueUniCode, "multipart" : multipart]
            
            var toastImg: String = ""
            if (imgView_Wish.image) != nil {
                let imageData = UIImagePNGRepresentation(imgView_Wish.image!)
                // creates path for image if captured
                let filePath: NSString = (NSTemporaryDirectory() as NSString).appendingPathComponent("userimage.png") as NSString
                
                do {
                    try imageData?.write(to: URL(fileURLWithPath: filePath as String), options: .atomic)
                    toastImg = filePath as String
                } catch {
                    
                }
            }
            
            WebService.multipartRequest(postDict: parameters, ProfileImage: toastImg){  (response, error) in
                
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        
                        SVProgressHUD.dismiss()
                        
                        // create object to pass via notification
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        
                        let userInfo = ["newData": toastArray]
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kListCount_Notification), object: nil, userInfo: userInfo)
                        
                        
                        if self.isCreatingToast == true
                        {
                            self.performSegue(withIdentifier: "chatSeg", sender: self)
                        }
                        else
                        {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kEditPost_Notification), object: nil)
                            
                            
                            ((self.navigationController)! as UINavigationController).popViewController(animated: true)
                        }
                    })
                }
                else if(statusToken as String == "Error" as String)
                {
                    //                    let error_code = response["ErrorCode"] as! NSNumber
                    DispatchQueue.main.async(execute: {
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        
                        SVProgressHUD.dismiss()
                        let error_message:String =  String(format: "%@",response["Error"]! as! String)
                        SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                    })
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showInfo(withStatus: "Server response failed" as String, maskType: .gradient)
                    })
                }
            }
        }
        else
        {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
    }
    
    func UpdateMsgOnGroup()
    {
        /*
         // Edit post message
         {
         "service": "postmessage",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "toast_id": "2",
         "post_id": "6",
         "image_remove": "Y", // mapde optional not required in current scope
         "message_text": "Happy Birthday!!",
         "multipart": "N"
         }
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(withStatus: "Updating post...", maskType: .gradient)
            
            var multipart = "N"
            if (imgView_Wish.image) != nil
            {
                multipart = "Y"
            }
            
            // convert text to support emoticons
            let  str = txtView_Message.text as String
            let textViewData : NSData = str.data(using: String.Encoding.nonLossyASCII)! as NSData
            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
            
            let parameters: NSDictionary = ["service": "postmessage", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selected_ToastId, "message_text" : valueUniCode, "multipart" : multipart, "post_id" : selected_PostId, "image_remove" : ""]
            
            var toastImg: String = ""
            if (imgView_Wish.image) != nil {
                let imageData = UIImagePNGRepresentation(imgView_Wish.image!)
                let filePath: NSString = (NSTemporaryDirectory() as NSString).appendingPathComponent("userimage.png") as NSString
                
                do {
                    try imageData?.write(to: URL(fileURLWithPath: filePath as String), options: .atomic)
                    toastImg = filePath as String
                } catch {
                    
                }
            }
            
            WebService.multipartRequest(postDict: parameters, ProfileImage: toastImg){  (response, error) in
                
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        SVProgressHUD.dismiss()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kEditPost_Notification), object: nil)
                        
                        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
                        
                    })
                }
                else if(statusToken as String == "Error" as String)
                {
                    //                    let error_code = response["ErrorCode"] as! NSNumber
                    DispatchQueue.main.async(execute: {
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        SVProgressHUD.dismiss()
                        let error_message:String =  String(format: "%@",response["Error"]! as! String)
                        SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                    })
                    
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showInfo(withStatus: "Server response failed" as String, maskType: .gradient)
                    })
                }
            }
        }
        else
        {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
        
    }
    
    func callPopMethod()
    {
        
    }
    
    @IBAction func btn_deleteImageClicked(_ sender: UIButton) {
        imgView_Wish.isHidden = true
        imgView_Wish.image = nil
        view_AddImageBg.isHidden = false
        btn_deleteImage.isHidden = true
        
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
        btn_deleteImage.isHidden = false
        imgView_Wish.isHidden = false
        view_AddImageBg.isHidden = true
        
        //        let blurrImageViewObject = AsyncImageView(frame:CGRect(x:0, y:0, width:imgView_Wish.frame.size.width, height:imgView_Wish.frame.size.height))
        //        blurrImageViewObject.backgroundColor = UIColor.clear
        
        let selectedImage1: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        imgView_Wish.image = selectedImage1 //.imageWithSize(imgView_Wish.frame.size)
        
        // Uncomment to check cropping of image
        //        let aspectScaledToFillImage = selectedImage1.af_imageAspectScaled(toFill: imgView_Wish.frame.size)
        //        imgView_Wish.image = aspectScaledToFillImage
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK:textView Delegate Methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "Type your cheer..." {
            textView.text = nil
            textView.textColor = UIColor(hexCode: 0x666666)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text.isEmpty {
            textView.text = "Type your cheer..."
            textView.textColor = UIColor(hexCode: 0xBEC0C0)
        }
    }
    
    private func textViewShouldReturn(textView: UITextView) -> Bool
    {
        textView.resignFirstResponder()
        if textView.text.isEmpty {
            textView.text = "Type your cheer..."
            textView.textColor = UIColor(hexCode: 0xBEC0C0)
        }
        return true
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "chatSeg")
        {
            if let chatVC: TChatViewController = segue.destination as? TChatViewController {
                chatVC.screenTag = 2
                //uncomment below
                chatVC.selectedToastId = selected_ToastId
                chatVC.selectedToast_Title = selected_ToastTitle
            }
        }
    }
    
}

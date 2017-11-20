//
//  TChatViewController.swift
//  Toast
//
//  Created by Anish Pandey on 02/12/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import MobileCoreServices
import SDWebImage
import KSPhotoBrowser

class TChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    
    // :- Added by Ahsan Ali for ChatBar
    var bottomConstraint: NSLayoutConstraint?

    @IBOutlet weak var chatBar: UIView!
    @IBOutlet weak var userImageInput: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var view_bgTypeCheer: UIView!
    @IBOutlet weak var tblView_chat: UITableView!
    var arr_message:NSMutableArray = NSMutableArray()
    @IBOutlet weak var btn_Camera: UIButton!
    @IBOutlet weak var txtfld_Message: UITextField!
    var cameraUI: UIImagePickerController!
    var selectedImage1: UIImage!
    var screenTag:Int = 0 // 2 for Toast screen, 1 for diary screen
    @IBOutlet weak var const_textEnterView: NSLayoutConstraint!
    var chatFrame: CGRect?
    
    var selectedToastId:String = String()
    var selected_PostId:String = String()
    var selected_Post_text:String = String()
    var selected_Post_image:String = String()
    
    var isEditing_Post: Bool = false // True - if editing personal post
    
    var selectedToast_Title : String = String()
    var isAutoOpenViewToastDetails:Bool = false // set flag for push notifications
    @IBOutlet weak var view_NoResult: UIView!
    
    var releaseStatus:String = String()
    var favView : CustomFavorites!
    var bgView : UIView = UIView()
    
    var offset_Messages: String = "0" // to call data in group
    var overlayIndex:Int = 0
    
    var isImageSelected = false
    var toast_message = ""
    var toast_image = UIImage()
    
    var isUpated = false
    
    
    var keyboardY = 0
    func addInfiniteScrollHander(){
        self.tblView_chat.addInfiniteScroll { (scrollView) -> Void in
            if WebService.isFinish == true
            {
                self.FetchPostMsgList()
            }
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TDiaryVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    // MARK: - Pull to refresh Action
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        SVProgressHUD.show(withStatus: "Listing Posts", maskType: .gradient)
        
        DispatchQueue.global(qos: .default).async {
            print("handle Refresh run on the background queue")
            
            sleep(3)
            DispatchQueue.main.async(execute: {
                print("This is run on the main queue, after the previous block")
                
                let date = NSDate();
                // "Apr 1, 2015, 8:53 AM" <-- local without seconds
                
                let formatter = DateFormatter();
                formatter.dateFormat = "yyyy-MMM-dd HH:mm";
                let defaultTimeZoneStr = formatter.string(from: date as Date);
                // "2015-04-01 08:52:00 -0400" <-- same date, local, but with seconds
                formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!;
                //   let utcTimeZoneStr = formatter.stringFromDate(date);
                
                let lastUpdate = NSString(format: "Last updated on %@",(defaultTimeZoneStr) as String)
                refreshControl.attributedTitle = NSAttributedString(string: lastUpdate as String)
                
                if WebService.isFinish == true // To avoid clash with addInfiniteScrollHander
                {
                    self.arr_message.removeAllObjects()
                    self.offset_Messages = "0"
                    SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
                    self.FetchPostMsgList()
                }
                else
                {
                    if(self.refreshControl.isRefreshing)
                    {
                        self.refreshControl.endRefreshing()
                    }
                }
                
            })
        }
        
    }
    // MARK: - Input Acessory disapear
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let text = txtfld_Message.text else { return }
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            SVProgressHUD.showInfo(withStatus: "Please enter your cheer.", maskType: .gradient)
            return
        }
        if (self.isUpated)
        {
            UpdateMsgOnGroup()
            self.txtfld_Message.text = ""
        }
        else
        {
            PostMsgOnGroup()
            self.txtfld_Message.text = ""
        }
      
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("===current chat bar frame ===== \(self.chatBar.frame)")
        guard let cf = self.chatFrame else { return }
        self.chatBar.frame = cf
        print("===new chat bar frame ===== \(self.chatBar.frame)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.selectedToastId)
        print(self.selected_PostId)
        print(self.selected_Post_text)
        
        self.txtfld_Message.text = self.toast_message
        
        self.userImageInput.contentMode = .scaleAspectFit
        if self.toast_image != nil
        {
            self.isImageSelected = true
            self.userImageInput.isHidden = false
            self.userImageInput.image = self.toast_image
        }
        
        self.addInfiniteScrollHander()
        self.tblView_chat.addSubview(self.refreshControl)
        
        
        if(screenTag == 1) // 2 for Toast screen, 1 for diary screen
        {
            view_bgTypeCheer.isHidden = true
            const_textEnterView.constant = -45.0
            self.view.layoutIfNeeded()
        }
        
        
        self.view.addSubview(bgView)
        self.bgView.frame = self.view.frame
        self.bgView.backgroundColor = UIColor.black
        
        favView = Bundle.loadView(fromNib: "CustomFavorites", withType: CustomFavorites.self)
        let cellNib = UINib(nibName: "CustomFavoritesTableViewCell", bundle: nil)
        favView.tblFav.register(cellNib, forCellReuseIdentifier: "CustomFavoritesTableViewCell")
        self.view.addSubview(favView)
        self.favView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width , height: self.view.bounds.size.height)
        self.favView.btnCancel.addTarget(self, action: #selector(self.cancelButtonClicked), for: .touchUpInside)
        self.favView.BtnContinue.addTarget(self, action: #selector(self.continueButtonClicked), for: .touchUpInside)
        self.bgView.alpha = 0.0
        self.favView.alpha = 0.0
        
        self.txtfld_Message.delegate = self
        
        self.CustomiseView()
        
        let def = UserDefaults.standard
        let imageUrl = def.value(forKey: "pictureurl") as? String
        var popup = false
        if let tpopup = def.value(forKey: "popup") as? Bool {
            popup = tpopup
        }
        if(popup)
        {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in 
            
                var refreshAlert = UIAlertController(title: "Cheer Up", message: "Everyone has cheered, Raise the toast now ?", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    self.btn_ReleaseClicked()
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "No, I will raise later", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Handle Cancel Logic here")
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
                
            
            })

        }
        
        
        print(imageUrl ?? "")
        
        DispatchQueue.main.async {
            do
            {
                if let imageUrl = imageUrl // check imageUrl nil
                {
                    
                    self.backgroundImage.contentMode = .scaleToFill
                    self.backgroundImage.sd_setImage(with: URL(string: imageUrl))
                    //self.backgroundImage.setImageFromURl(stringImageUrl: imageUrl)
                }
                
            }
            catch
            {
                print("")
            }
        }
       
        
        tblView_chat.estimatedRowHeight = 100
        tblView_chat.rowHeight = UITableViewAutomaticDimension
        
        if(screenTag != 1) // 2 for Toast screen, 1 for diary scree
        {
//            _ = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(TChatViewController.scrollTblToBottom), userInfo: nil, repeats: false)
        }
        
        if(isAutoOpenViewToastDetails == true)
        {
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TChatViewController.CallSegViewToastDetail), userInfo: nil, repeats: false)
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(TChatViewController.hideChatWindow), name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TChatViewController.updateViewCalled1), name: NSNotification.Name(rawValue: kRedirectToViewToastViaChatVC_pushNotification), object: nil) // called from appD for navigation via this VC and open next VC
        
        
        self.FetchPostMsgList()
        self.tblView_chat.reloadData()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TChatViewController.PostEdited), name: NSNotification.Name(rawValue: kEditPost_Notification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TChatViewController.removeRaiseButton), name: NSNotification.Name(rawValue: kUpdateTransferedList_Notification), object: nil) //  fired when ownership is transfered or other action requirews refreshing list using object from action reponse
        
         NotificationCenter.default.addObserver(self, selector: #selector(TChatViewController.updateViewCalled_toastEdited), name: NSNotification.Name(rawValue: kRefreshToastList_Notification), object: nil)  // Fired from EditToastVC whenevr data is updated
        

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
        
    }
    
    func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.chatBar.backgroundColor = .clear
                self.view.bringSubview(toFront: self.chatBar)
                let y = (keyboardFrame?.origin.y)! - self.chatBar.frame.height - 60
                var f = self.chatBar.frame
                f.origin.y = y
                self.chatFrame = f
                self.chatBar.frame = f
                self.chatBar.layoutIfNeeded()
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
                if isKeyboardShowing {
                    
                    //let indexPath = NSIndexPath(forItem: self.messages!.count - 1, inSection: 0)
                }
                
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let def = UserDefaults.standard
        def.setValue(false, forKey: "popup")
        

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
            if (self.userImageInput.image) != nil
            {
                multipart = "Y"
            }
            
            // convert text to support emoticons
            let  str = self.txtfld_Message.text as! String
            let textViewData : NSData = str.data(using: String.Encoding.nonLossyASCII)! as NSData
            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
            
            let parameters: NSDictionary = ["service": "postmessage", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : self.selectedToastId, "message_text" : valueUniCode, "multipart" : multipart, "post_id" : self.selected_PostId, "image_remove" : ""]
            
            var toastImg: String = ""
            if (self.userImageInput.image) != nil {
                let imageData = UIImagePNGRepresentation(self.userImageInput.image!)
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
            if (self.isImageSelected)
            {
                multipart = "Y"
            }
            
            // convert text to support emoticons
            let  str = self.txtfld_Message.text
            let textViewData : NSData = str!.data(using: String.Encoding.nonLossyASCII)! as NSData
            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
            
            let parameters: NSDictionary = ["service": "postmessage", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : self.selectedToastId, "message_text" : valueUniCode, "multipart" : multipart]
            
            var toastImg: String = ""
            if (self.isImageSelected) {
                let imageData = UIImagePNGRepresentation(self.userImageInput.image!)
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
                        
                        
                        if true
                        {
                            
                            DispatchQueue.main.async(execute: {
                                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                                
                                SVProgressHUD.dismiss()
                                let error_message:String =  String("Posted successfully")
                                SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                                self.userImageInput.isHidden = true
                                self.FetchPostMsgList()
                                self.tblView_chat.reloadData()
                            })

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


    func typeSelected()
    {
        self.view.endEditing(true)
    }
    
    func startOverLay()
    {
        let item = self.navigationItem.rightBarButtonItem
        let button = item?.customView as! UIButton
        
        //        self.view.window?.addOverlayByHighlightingSubView(button, withText: "Finally, click Raise to raise this toast to the toastee.")
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        //            self.view.window?.removeOverlay()
        //}
        
        self.view.window?.addOverlayByHighlightingSubView(button, withText: "Finally, click Raise to raise this toast to the toastee.")
        
        // remove comment to call it for one time
        UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_ChatVC)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TChatViewController.refreshPostList), name: NSNotification.Name(rawValue: kCheersScreen_pushNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TChatViewController.updateViewCalledforUserAccess), name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: nil)//Push Notification Trigger: fired when received push notifications regarding  CreateNewToast , ChangeOwnership and user is on chat screen
        
//        NotificationCenter.default.addObserver(self, selector: #selector(TChatViewController.popToDiaryList), name: NSNotification.Name(rawValue: kPopDiaryToastVC_pushNotification), object: nil)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if self.bgView.alpha >= 0.2
        {
            UIView .animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.favView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                self.favView.alpha = 0.0
                self.bgView.alpha = 0.0
            }, completion: {(value: Bool) in
                self.favView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
            })
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCheersScreen_pushNotification), object: nil)
        
    }
    
    func CallSegViewToastDetail()
    {
        self.performSegue(withIdentifier: "viewToastDetail", sender: self)
        isAutoOpenViewToastDetails = false
    }
    
    // MARK: - Notification methods
    
    func hideChatWindow(notification: NSNotification) { // to check if Initiator and Colla are on same toast and its Raised
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        if(toastDict["toast_id"] as! String == self.selectedToastId)
        {
            self.view_bgTypeCheer.isHidden = true
            self.const_textEnterView.constant = -45.0
            self.screenTag = 1
        }
    }
    
    func removeRaiseButton(notification: NSNotification) {
        
        let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItem.width = -10
        let rightArray:NSArray = [navigationItem]
        self.navigationItem.setRightBarButtonItems(rightArray as?
            [UIBarButtonItem], animated: true)
        
    }
    
    func PostEdited(notification: NSNotification) {
        
        self.arr_message.removeAllObjects()
        self.offset_Messages = "0"
        
        _ = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(TChatViewController.callSeg), userInfo: nil, repeats: false)
    }
    
    
    
    func callSeg()
    {
        self.FetchPostMsgList()
    }
    
    // MARK: - Push Notification methods
    
    
//    func popToDiaryList(notification: NSNotification) {
//        
//        let toastDict:NSDictionary = notification.object! as! NSDictionary
//        
//        self.ClearNotificationOnBack()
//        
//        ((self.navigationController)! as UINavigationController).popToRootViewController(animated: true)
//        
//        //delay diary tab call when app is terminated
//        let deadlineTime = DispatchTime.now() + .seconds(2)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//            self.tabBarController?.selectedIndex = 0
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToCheersScreen_pushNotification), object: toastDict)
//        }
//
//    }
    
    
    func refreshPostList(notification: NSNotification) {
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        
        if(toastDict["toast_id"] != nil)
        {
            self.selectedToastId = toastDict["toast_id"] as! String
        }
        if(toastDict["toast_title"] != nil)
        {
            self.selectedToast_Title = toastDict["toast_title"] as! String
        }
        NSLog("selectedToast_Title in notification is  == \(selectedToast_Title)")
        
        // Clear array and offset to load new msg
        self.arr_message.removeAllObjects()
        self.offset_Messages = "0"
        
        
        FetchPostMsgList()
        
    }
    
     func updateViewCalled_toastEdited(notification: NSNotification) {
        
        // Clear array and offset to load new msg
        self.arr_message.removeAllObjects()
        self.offset_Messages = "0"
        
        
        FetchPostMsgList()

    }
    
    func updateViewCalled1(notification: NSNotification) { // to handle if visible view was TVTDVC and ownerShip transferred, on back update the chat view
        
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        
        if(toastDict["toast_id"] != nil)
        {
            self.selectedToastId = toastDict["toast_id"] as! String
        }
        
        // Clear array and offset to load new msg
        self.arr_message.removeAllObjects()
        self.offset_Messages = "0"
        
        
        FetchPostMsgList()
        
    }
    func updateViewCalledforUserAccess(notification: NSNotification) { //Push Notification Trigger: fired when received push notifications regarding  CreateNewToast , ChangeOwnership and user is on chat screen
        
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        
        if(toastDict["toast_id"] != nil)
        {
            self.selectedToastId = toastDict["toast_id"] as! String
        }
        
        // Clear array and offset to load new msg
        self.arr_message.removeAllObjects()
        self.offset_Messages = "0"
        
        
        FetchPostMsgList()
        
    }
    
    
//    func scrollTblToBottom()
//    {
//        if arr_message.count > 0
//        {
//            UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
//                let indexPath = NSIndexPath(row: self.arr_message.count-1, section: 0)
//                let cellRect = self.tblView_chat.rectForRow(at: indexPath as IndexPath)
//                let completelyVisible = self.tblView_chat.bounds.contains(cellRect)
//                if(completelyVisible)
//                {
//                    self.tblView_chat.scrollToRow(at: indexPath as IndexPath,at: UITableViewScrollPosition.bottom, animated: true)
//                }
//                
//            }, completion: {(finished: Bool) -> Void in
//            })
//        }
//        
//    }
    
    func CustomiseView()
    {
        
        self.view_NoResult.alpha = 0.0
        self.navigationItem.titleView = getNavigationTwoTitles(inputStr1: selectedToast_Title, inputStr2: "Tap to view details")
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(TChatViewController.HeaderViewTapped))
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.navigationItem.titleView?.addGestureRecognizer(recognizer)
        
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TChatViewController.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        
        self.btn_Camera.isUserInteractionEnabled = true
        self.txtfld_Message.isUserInteractionEnabled = true
        self.view_bgTypeCheer.isUserInteractionEnabled = true
        
//        let recognizer_ChatTxt = UITapGestureRecognizer(target: self, action: #selector(TChatViewController.WriteMsgTapped))
        //self.view_bgTypeCheer.addGestureRecognizer(recognizer_ChatTxt)
        
        
    }
    
//    func WriteMsgTapped(_ sender: UITapGestureRecognizer) {
//        
//        isEditing_Post = false
//        //self.performSegue(withIdentifier: "editMessageSeg", sender: self)
//        
//    }
    
    // MARK: - WS Calls
    
    func FetchPostMsgList()
    {
        /*
         
         {
         "service": "viewpostmessages",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "toast_id": "2"
         "offset":"1"
         }
         
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
           // let offset =  offset_Messages
            
            let offset = self.arr_message.count
            
            SVProgressHUD.show(withStatus: "Loading", maskType: .gradient)
            
            
            let parameters: NSDictionary = ["service": "viewpostmessages", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selectedToastId,"offset":offset]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                self.tblView_chat.finishInfiniteScroll()
                if(self.refreshControl.isRefreshing)
                {
                    self.refreshControl.endRefreshing()
                }
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        
                        SVProgressHUD.dismiss()
                        
                        
                        let next_offset:NSString = NSString(format: "%@",response["next_offset"]! as! NSString)
                        
                        //                        self.arr_message.removeAllObjects()
                        let postArray:NSArray = (response["post_list"] as! NSArray)
                        let chat_windowStatus:Bool =  response["chat_window"] as! Bool
                        NSLog("chat_window == \(chat_windowStatus)")
                        
                        let  toastTitle:NSString =  NSString(format: "%@",response["toast_title"]! as! NSString)
                        
                        self.selectedToast_Title = toastTitle as String
                        if(self.screenTag == 1)
                        {
                            self.view_bgTypeCheer.isHidden = true
                            self.const_textEnterView.constant = -45.0
                            // self.view.layoutIfNeeded()
                        }
                        else
                        {
                            if(chat_windowStatus == true)
                            {
                                self.view_bgTypeCheer.isHidden = false
                                //self.txtfld_Message.becomeFirstResponder()
                                //self.const_textEnterView.constant = 0.0
                                // self.view.layoutIfNeeded()
                            }
                            else
                            {
                                if (self.isUpated)
                                {
                                    self.view_bgTypeCheer.isHidden = false

                                }
                                else
                                {
                                    self.view_bgTypeCheer.isHidden = true

                                }
                               // self.const_textEnterView.constant = -45.0
                                //self.view.layoutIfNeeded()
                            }
                        }
                        
                        if(getValueFromDictionary(dicData: response as! NSDictionary, forKey: "owner_access") == "1")
                        {
                            isInitiator = true
                        }
                        else{
                            isInitiator = false
                        }
                        
                        if postArray.count > 0
                        {
                            for post in postArray
                            {
                                let postObj:PostList = PostList()
                                postObj.setData(fromDict: post as! NSDictionary)
                                self.arr_message.add(postObj)
                            }
                            self.offset_Messages = next_offset as String
                        }
                        
                        if self.arr_message.count > 0
                        {
                            self.view_NoResult.alpha = 0.0
                        }
                        else
                        {
                            self.view_NoResult.alpha = 1.0
                        }
                        
                        if self.screenTag == 2 // is from Toast screen
                        {
                            if(isInitiator == true)//required on notification calls
                            {
                                self.navigationItem.titleView = getNavigationTwoTitles(inputStr1: self.selectedToast_Title, inputStr2: "Tap to view details")
                                
                                let recognizer = UITapGestureRecognizer(target: self, action: #selector(TChatViewController.HeaderViewTapped))
                                self.navigationItem.titleView?.isUserInteractionEnabled = true
                                self.navigationItem.titleView?.addGestureRecognizer(recognizer)
                                
                                let btn_Release: UIButton = UIButton(type: UIButtonType.custom)
                                btn_Release.frame = CGRect(x: 0, y: -25, width: 50, height: 30)
                                btn_Release.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15.5)
                                btn_Release.setTitle("Raise", for: .normal)
                                btn_Release.addTarget(self, action: #selector(self.btn_ReleaseClicked), for: UIControlEvents.touchUpInside)
                                let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_Release)
                                //                                let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                                //                                navigationItem.width = -30
                                //                                let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
                                self.navigationItem.setRightBarButton(rightBarButtonItemShare, animated: true)
                                
                                let overlayIndex_chatVC = UserDefaults.standard.string(forKey: KEY_OverlayIndex_ChatVC) as NSString?
                                if let newOverlayIndex_chatVC = overlayIndex_chatVC
                                {
                                    if(newOverlayIndex_chatVC == "Show")
                                    {
                                        //show overlay after sometime
                                        _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(TChatViewController.startOverLay), userInfo: nil, repeats: false)
                                    }
                                }
                                else
                                {
                                    _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(TChatViewController.startOverLay), userInfo: nil, repeats: false)
                                }
                            }
                            else
                            { //  updating navBar required on notification calls
                                
                                self.navigationItem.titleView = getNavigationTwoTitles(inputStr1: self.selectedToast_Title, inputStr2: "Tap to view details")
                                
                                let recognizer = UITapGestureRecognizer(target: self, action: #selector(TChatViewController.HeaderViewTapped))
                                self.navigationItem.titleView?.isUserInteractionEnabled = true
                                self.navigationItem.titleView?.addGestureRecognizer(recognizer)
                                
                                let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                                navigationItem.width = -10
                                let rightArray:NSArray = [navigationItem]
                                self.navigationItem.setRightBarButtonItems(rightArray as?
                                    [UIBarButtonItem], animated: true)
                            }
                        }
                        
                        self.tblView_chat.reloadData()
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
    // MARK: - POP-Up Button Methods
    func cancelButtonClicked()  { // for custom pop-up
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.favView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.favView.alpha = 0.0
            self.bgView.alpha = 0.0
        }, completion: {(value: Bool) in
            self.favView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        })
    }
    
    func continueButtonClicked()  { // for custom pop-up
        
        //        self.ReleaseToast(toastIndex: self.favView.indexpath, release: "Y")
        
        releaseStatus = "Y"
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TChatViewController.btn_ReleaseClicked), userInfo: nil, repeats: false)
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.favView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.favView.alpha = 0.0
            self.bgView.alpha = 0.0
        }, completion: {(value: Bool) in
            self.favView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        })
    }
    
    // MARK: - Button Action
    
    func backBtnClicked(_ sender: UIButton!)
    {
        
        // to check the navigation array
        var exists = false
        
        if self.navigationController?.viewControllers == nil
        {
            return
        }
        
        for controller in (self.navigationController?.viewControllers)! {
            if (controller.isKind(of: TtoastVC.classForCoder()) == true) || (controller.isKind(of: TDiaryVC.classForCoder()) == true) {
                exists = true
                self.ClearNotificationOnBack()
            }
        }
        
        if exists == true {
            ((self.navigationController)! as UINavigationController).popToRootViewController(animated: true)
        }
        
    }
    
    // MARK: - Clear Notification On Back
    func ClearNotificationOnBack()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kEditPost_Notification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kUpdateTransferedList_Notification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRedirectToViewToastViaChatVC_pushNotification), object: nil) // remove becoz its fired only if view is visible
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRefreshToastList_Notification), object: nil)
    }
    
    func btn_ReleaseClicked()
    {
        /*
         {
         "service": "releasetoast",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "toast_id": "3"
         "release_confirm":""
         }
         */
        
        
        if releaseStatus != "Y"
        {
            releaseStatus = ""
        }
        else{
            releaseStatus = "Y"
        }
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "releasetoast", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selectedToastId,"release_confirm": releaseStatus]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showInfo(withStatus: kRaisedToast, maskType: .gradient)
                        
                        //notification fired to open diary tab via ToastVC
                        isToastRaised = true
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        
                        let userInfo = ["newData": toastArray]
                        
                        
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: nil)
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRedirectToViewToastViaChatVC_pushNotification), object: nil) // remove becoz its fired only if view is visible
                        
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRefreshToastList_Notification), object: nil)
                        
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kToastRaised_Notification), object: nil, userInfo: userInfo)
                        
                        ((self.navigationController)! as UINavigationController).popToRootViewController(animated: true)
                    })
                }
                else if(statusToken as String == "Error" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        
                        if (response["ErrorCode"]! as! NSNumber == 30)
                        {
                            let msgTxt:NSString =  NSString(format: "%@",response["Error"]! as! NSString)
                            self.favView.msgLbl.text = msgTxt as String!
                            let userArr = response["pending_user_names"]! as! NSArray
                            self.favView.arr_MemberList = userArr.mutableCopy() as! NSMutableArray
                            
                            if self.favView.arr_MemberList.count == 1
                            {
                                self.favView.TblView_Hconst.constant = CGFloat((self.favView.arr_MemberList.count * 30) + 70)
                            }
                            else if self.favView.arr_MemberList.count < 5
                            {
                                self.favView.TblView_Hconst.constant = CGFloat(((self.favView.arr_MemberList.count) * 30) + 70)
                            }
                            else
                            {
                                self.favView.TblView_Hconst.constant = CGFloat((5 * 30) + 70)
                            }
                            
                            self.favView.alpha = 1.0
                            self.favView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
                            self.view .addSubview(self.favView)
                            UIView .animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                                self.bgView.alpha = 0.3
                                self.favView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                            }, completion: {(value: Bool) in
                                
                                self.favView.layoutIfNeeded()
                                self.favView.tblFav.reloadData()
                                
                            })
                        }
                        else{
                            let error_message:NSString =  NSString(format: "%@",response["Error"]! as! NSString)
                            SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                        }
                    })
                }
            }
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
    }
    
    // called when user selects post to edit
    func btn_EditMessageClicked(_ sender: UIButton!)
    {
        if (arr_message.count > sender.tag) // check to handle regression
        {
            selected_PostId = (arr_message.object(at: sender.tag) as! PostList).post_msgid
            selected_Post_text = (arr_message.object(at: sender.tag) as! PostList).post_text
            selected_Post_image = (arr_message.object(at: sender.tag) as! PostList).post_image
            isEditing_Post = true
            self.isUpated = true

            self.view_bgTypeCheer.isHidden = false
            
            self.txtfld_Message.text = selected_Post_text
            DispatchQueue.main.async {
                self.userImageInput.sd_setImage(with: URL(string: self.selected_Post_image))
            }
            self.userImageInput.isHidden = false
            self.tblView_chat.isHidden = true
//            self.chatBar.isHidden = false
//            self.chatBar.frame.origin.x = 0
//            self.chatBar.frame.origin.y = self.view.frame.height - 120
//            self.chatBar.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func btn_CameraClicked(_ sender: UIButton) {
        txtfld_Message.resignFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
            //self.const_textEnterView.constant = 0
            self.view.layoutIfNeeded()
        }, completion: {(finished: Bool) -> Void in
        })
        
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
    
    @objc fileprivate func HeaderViewTapped(_ sender: UITapGestureRecognizer) {
        
        SVProgressHUD.show(with: .gradient)
        
        self.performSegue(withIdentifier: "viewToastDetail", sender: self)
        
        SVProgressHUD.dismiss()
    }
    
    func sendMessage()
    {
        //add one more cell
        let msgDict:NSDictionary!
        
        if(selectedImage1 != nil)
        {
            msgDict = ["memberPhoto" : "ic_birthday", "wishPhoto" : selectedImage1, "wishMessage": "Keep shining as one of the brightest star you have always been in our lives. Happy Birthday!", "memberName" : "Ana", "MessageTime" : "5 Oct, 16"]
        }
        else
        {
            msgDict = ["memberPhoto" : "ic_birthday", "wishMessage": "Keep shining as one of the brightest star you have always been in our lives. Happy Birthday!", "memberName" : "Ana", "MessageTime" : "5 Oct, 16"]
        }
        arr_message.add(msgDict)
        
        self.tblView_chat.reloadData()
        
        let indexPath = NSIndexPath(row: arr_message.count-1, section: 0)
        self.tblView_chat.scrollToRow(at: indexPath as IndexPath,
                                      at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    override var hidesBottomBarWhenPushed: Bool
        {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    //MARK:UIImagePickerController Delegate
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        selectedImage1 = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.userImageInput.isHidden = false
        self.userImageInput.image = info[UIImagePickerControllerEditedImage] as! UIImage

        self.isImageSelected = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Table View Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_message.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "ChatCell"
        var cell:ChatCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ChatCell
        if (cell == nil){
            tableView.register(UINib(nibName: "ChatCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ChatCell
            cell?.layoutMargins=UIEdgeInsets.zero
            cell?.preservesSuperviewLayoutMargins=false
            cell?.backgroundColor=UIColor.clear
        }
        
        if(UIScreen.main.bounds.size.height == 568)
        {
            cell?.arrow_leadingspace.constant = 4.5
            cell?.contentView.layoutIfNeeded()
        }
        
        
        
        if (arr_message.count > indexPath.row)
        {
            
            cell?.lbl_memberName.text = ("\(((arr_message.object(at: indexPath.row) as! PostList).post_first_name as String)) \(((arr_message.object(at: indexPath.row) as! PostList).post_last_name as String))")
            
            // Convert to show Emoticons
            
            let str = (arr_message.object(at: indexPath.row) as! PostList).post_text
            let emojData : NSData = str.data(using: String.Encoding.utf8)! as NSData
            let emojString:String = String(data: emojData as Data, encoding: String.Encoding.nonLossyASCII)!
            
            
            
            cell?.lbl_message.text = emojString
            cell?.lbl_message.lineBreakMode = .byWordWrapping
            cell?.lbl_message.numberOfLines = 0
            
            cell?.btn_EditMessage.tag = indexPath.row
            
            let editMode = (arr_message.object(at: indexPath.row) as! PostList).post_edit_flag
            let isInitiatorFlag = (arr_message.object(at: indexPath.row) as! PostList).post_initiator_flag
            
            
            
            let messageDate:String = (arr_message.object(at: indexPath.row) as! PostList).post_messaged_on
            
            cell?.lbl_messageTime.text = dateForChat(postDate: messageDate)
            
            
            let profilePhotoUrlStr: String = (arr_message.object(at: indexPath.row) as! PostList).post_profile_photo
            
            if(profilePhotoUrlStr.characters.count > 0)
            {
                let toastURL: URL = URL(string: profilePhotoUrlStr)!
                let manager:SDWebImageManager = SDWebImageManager.shared()
                manager.downloadImage(with: toastURL, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                    let aspectScaledToFillImage = image?.af_imageAspectScaled(toFill: (cell?.imgView_memberPic.frame.size)!)
                    cell?.imgView_memberPic.image = aspectScaledToFillImage?.af_imageRounded(withCornerRadius: (cell?.imgView_memberPic.frame.size.width)!)
                })
            }
            
            let postPhotoUrlStr: String = (arr_message.object(at: indexPath.row) as! PostList).post_image
            
            if postPhotoUrlStr.characters.count > 0
            {
                cell?.imgView_wishPhoto.isHidden = false
                cell?.const_wishPhotoHeight.constant = 160
                cell?.contentView.layoutIfNeeded()
                let toastURL: URL = URL(string: postPhotoUrlStr)!
                let manager:SDWebImageManager = SDWebImageManager.shared()
                manager.downloadImage(with: toastURL, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                    let aspectScaledToFillImage = image
                    cell?.imgView_wishPhoto.image = aspectScaledToFillImage
                })
                
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(TChatViewController.imageTapped(_:)))
                cell?.imgView_wishPhoto.isUserInteractionEnabled = true
                recognizer.delegate = self
                cell?.imgView_wishPhoto.tag = indexPath.row
                cell?.imgView_wishPhoto.addGestureRecognizer(recognizer)
            }
            else
            {
                cell?.imgView_wishPhoto.isHidden = true
                cell?.const_wishPhotoHeight.constant = 0
                cell?.contentView.layoutIfNeeded()
                
            }
            
            if(screenTag != 1) // for toast screen
            {
                if(editMode == "1") // for initiator show edit btn
                {
                    if(isInitiatorFlag == "1")
                    {
                        cell?.btn_EditMessage.isHidden = false
                        
                        cell?.btn_EditMessage.addTarget(self, action: #selector(TChatViewController.btn_EditMessageClicked(_:)), for: UIControlEvents.touchUpInside)
                        
                        cell?.lbl_Initiator.isHidden = true
                    }
                    else{
                        
                        cell?.btn_EditMessage.isHidden = false
                        cell?.btn_EditMessage.addTarget(self, action: #selector(TChatViewController.btn_EditMessageClicked(_:)), for: UIControlEvents.touchUpInside)
                        cell?.lbl_Initiator.isHidden = true
                    }
                    
                    //                    if(overlayIndex == 0)
                    //                    {
                    //                    self.view.window?.addOverlayByHighlightingSubView((cell?.btn_EditMessage)!, withText: "Edit your cheer message")
                    //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    //                        self.view.window?.removeOverlay()
                    //                    }
                    //                        overlayIndex = 1
                    //                    }
                }
                else
                {
                    if(isInitiatorFlag == "1")
                    {
                        cell?.lbl_Initiator.isHidden = false
                    }
                    else
                    {
                        cell?.lbl_Initiator.isHidden = true
                    }
                    cell?.btn_EditMessage.isHidden = true
                    
                }
            }
            else // for diary screen
            {
                cell?.btn_EditMessage.isHidden = true
                
                if(isInitiatorFlag == "1")
                {
                    cell?.lbl_Initiator.isHidden = false
                    
                }
                else
                {
                    cell?.lbl_Initiator.isHidden = true
                }
                
            }
            
        }
        else
        {
            print("arr_message.count < indexPath.row in TChatViewController")
        }
        
        
        
        
        //        let compressed_Image = UIImage(named: (arr_message.object(at: indexPath.row)as! NSDictionary).value(forKey: "memberPhoto") as! String)
        //        cell?.imgView_memberPic.image = compressed_Image?.imageWithImageInSize(compressed_Image!).imageWithRoudedCornersForBounds((cell?.imgView_memberPic.bounds)!, cornerRadius: (cell?.imgView_memberPic.frame.size.width)!/2)
        
        //        if(((arr_message.object(at: indexPath.row)as! NSDictionary).value(forKey: "wishPhoto")) != nil)
        //        {
        //            cell?.imgView_wishPhoto.isHidden = false
        //            let compressed_Image:UIImage = (arr_message.object(at: indexPath.row)as! NSDictionary).value(forKey: "wishPhoto") as! UIImage
        //            cell?.imgView_wishPhoto.image = compressed_Image.imageWithImageInSize(compressed_Image)
        //            cell?.const_wishPhotoHeight.constant = 160
        //            cell?.contentView.layoutIfNeeded()
        //        }
        //        else{
        //            cell?.imgView_wishPhoto.isHidden = true
        //            cell?.const_wishPhotoHeight.constant = 0
        //            cell?.contentView.layoutIfNeeded()
        //        }
        cell?.view_Bg.backgroundColor = UIColor.white
        cell?.view_Bg.layer.borderWidth = 1.0
        cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        cell?.view_Bg.layer.cornerRadius = 2.0
        cell?.view_Bg.clipsToBounds = true
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageTag = (sender.view?.tag)!
        
        let indexPath = IndexPath(row: imageTag, section: 0)
        let cell = self.tblView_chat.cellForRow(at: indexPath) as! ChatCell
        
        var items: [KSPhotoItem] = []
        //   for i in 0..<arr_message.count {
        
        let url: String = (arr_message.object(at: indexPath.row) as! PostList).post_image
        if(url.characters.count > 0)
        {
            guard let imageView = cell.imgView_wishPhoto  else { return }
            guard let imageUrl = URL(string: url) else { return }
            let item = KSPhotoItem(sourceView: imageView, imageUrl: imageUrl)
            items.append(item)
        }
        //    }
        let browser = KSPhotoBrowser(photoItems: items, selectedIndex: UInt(0))
        //browser.delegate = self
        browser.dismissalStyle = .rotation
        browser.backgroundStyle = .blurPhoto
        browser.loadingStyle = .indeterminate
        // browser?.pageindicatorStyle = .dot
        browser.bounces = false
        browser.show(from: self)
    }
    
    
    // MARK: - UITextFieldDelegate Methods
//        func textFieldDidBeginEditing(_ textField: UITextField)
//        {
//            UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
//                self.const_textEnterView.constant = 216
//                self.view.layoutIfNeeded()
//            }, completion: {(finished: Bool) -> Void in
//            })
//
//        }
    //
    //    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //        txtfld_Message.resignFirstResponder()
    //        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
    //            self.const_textEnterView.constant = 0
    //            self.view.layoutIfNeeded()
    //        }, completion: {(finished: Bool) -> Void in
    //        })
    //
    //        self.sendMessage()
    //        txtfld_Message.text = ""
    //        return true
    //    }
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        txtfld_Message.resignFirstResponder()
    //        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
    //            self.const_textEnterView.constant = 0
    //            self.view.layoutIfNeeded()
    //        }, completion: {(finished: Bool) -> Void in
    //        })
    //
    //        txtfld_Message.text = ""
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "viewToastDetail")
        {
            if let toastDetailVC: TViewToastDetailVC = segue.destination as? TViewToastDetailVC {
                toastDetailVC.screenTag = self.screenTag
                
                if toastDetailVC.screenTag == 1 //  set initiator tag if gng through diary (required incase on pushnotification case)
                {
                    isInitiator = false
                }
                toastDetailVC.selectedToastId = self.selectedToastId
            }
        }
        if(segue.identifier == "editMessageSeg")
        {
            if let writeMsgVc: TCreateToast_WriteMsgVC = segue.destination as? TCreateToast_WriteMsgVC {
                
                writeMsgVc.isEditMode = isEditing_Post
                writeMsgVc.selected_ToastId = selectedToastId
                writeMsgVc.isCreatingToast = false
                if isEditing_Post == true {
                    writeMsgVc.selected_PostId = selected_PostId
                    writeMsgVc.selected_Post_text = selected_Post_text
                    writeMsgVc.selected_Post_image = selected_Post_image
                }
            }
        }
    }
    
    
}

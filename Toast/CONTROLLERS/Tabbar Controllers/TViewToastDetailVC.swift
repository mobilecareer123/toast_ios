//
//  TViewToastDetailVC.swift
//  Toast
//
//  Created by Anish Pandey on 30/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import SDWebImage
import KSPhotoBrowser

class TViewToastDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cont_btnLeaveGrpBottm: NSLayoutConstraint!
    @IBOutlet weak var tblView_viewToast: UITableView!
    var array_Member:NSMutableArray = NSMutableArray()
    @IBOutlet weak var btn_LeaveGroup: ZFRippleButton!
    var selectedToastId:String = String()
    var screenTag:Int = 0// 1 for from Diary screen
    @IBOutlet weak var btn_ClickTorRelease: ZFRippleButton!
    
    
    @IBOutlet weak var const_clkToRaiseTop: NSLayoutConstraint!
    var releaseStatus:String = String()
    var favView : CustomFavorites!
    var bgView : UIView = UIView()
    
    var reminderSentTo_Name:String = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewToastObj = ViewToast()
        //uncomment below
        
        self.CustomiseView()
        
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
        
        
        self.navigationItem.titleView = getNavigationTitle(inputStr: kNavigationTitleToastDetails)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TViewToastDetailVC.updateViewCalled), name: NSNotification.Name(rawValue: kRefreshToastList_Notification), object: nil)  // Fired from EditToastVC whenevr data is updated
        
        NotificationCenter.default.addObserver(self, selector: #selector(TViewToastDetailVC.hideLeaveButton), name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil) // fired from appD
        
        
        tblView_viewToast.estimatedRowHeight = 83
        tblView_viewToast.rowHeight = UITableViewAutomaticDimension
        
        
        let overlayIndex_ViewToast = UserDefaults.standard.string(forKey: KEY_OverlayIndex_ViewToastDeatilsVC) as NSString?
        if let newOverlayIndex_ViewToast = overlayIndex_ViewToast
        {
            if(newOverlayIndex_ViewToast == "Show")
            {
                if isInitiator == true // show edit/raise coachmark if initiator only
                {
                    //show overlay after sometime
                    _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(TViewToastDetailVC.startOverLay), userInfo: nil, repeats: false)
                }
            }
        }
        else
        {
            if isInitiator == true // show edit/raise coachmark if initiator only
            {
                //show overlay after sometime
                _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(TViewToastDetailVC.startOverLay), userInfo: nil, repeats: false)
            }
            
        }
        
        self.getToastDetails()
    }
    
    func startOverLay()
    {
        let item = self.navigationItem.rightBarButtonItem
        let button = item?.customView as! UIButton
        
        self.view.window?.addOverlayByHighlightingSubView(button, withText: "Edit any of the details of this toast.")
        //   DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        
        //            self.view.window?.addOverlayByHighlightingSubView(self.btn_ClickTorRelease, withText: "Finally, click Raise to raise this toast to the toastee.")
        //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        //                self.view.window?.removeOverlay()
        //                UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_ViewToastDeatilsVC)
        //
        //            }//end closer of raise btn overlay
        
        //     self.view.window?.removeOverlay()
        
        //
        UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_ViewToastDeatilsVC)
        
        //end closer of edit btn overlay
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TViewToastDetailVC.updateViewCalled1), name: NSNotification.Name(rawValue: kRedirectToViewToastViaChatVC_pushNotification), object: nil) // called from appD
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
        
        
    }
    
    func CustomiseView()
    {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let btn_Back: UIButton = UIButton(type: UIButtonType.custom)
        btn_Back.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        btn_Back.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        btn_Back.addTarget(self, action: #selector(TViewToastDetailVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: btn_Back)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        //comment below
        self.navigationItem.titleView = getNavigationTwoTitles(inputStr1: "", inputStr2: "")
        
        if isInitiator == true // show Edit btn if initiator
        {
            self.btn_ClickTorRelease.isHidden = false
            let btn_edit: UIButton = UIButton(type: UIButtonType.custom)
            btn_edit.frame = CGRect(x: 0, y: -25, width: 30, height: 30)
            btn_edit.setImage(UIImage(named:"ic_edit button white"), for: UIControlState.normal)
            
            btn_edit.addTarget(self, action: #selector(TViewToastDetailVC.btn_editClicked(_:)), for: UIControlEvents.touchUpInside)
            let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_edit)
            //            let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            //            navigationItem.width = -10
            //            let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
            self.navigationItem.setRightBarButton(rightBarButtonItemShare, animated: true)
        }
        else
        {
            self.btn_ClickTorRelease.isHidden = true
            self.const_clkToRaiseTop.constant = -50.0
        }
        
        if screenTag == 1// if from Diary screen
        {
            btn_LeaveGroup.isHidden = true
            cont_btnLeaveGrpBottm.constant = UIScreen.main.bounds.size.height * (-49.0 / 568.0)
            self.view.layoutIfNeeded()
        }
    }
    
    func updateViewCalled(notification: NSNotification) {
        
        self.btn_ClickTorRelease.isHidden = false
        //        let btn_edit: UIButton = UIButton(type: UIButtonType.custom)
        //        btn_edit.frame = CGRect(x: 0, y: -25, width: 30, height: 30)
        //        btn_edit.setImage(UIImage(named:"ic_edit button white"), for: UIControlState.normal)
        //
        //        btn_edit.addTarget(self, action: #selector(TViewToastDetailVC.btn_editClicked(_:)), for: UIControlEvents.touchUpInside)
        //        let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_edit)
        //        let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        //        navigationItem.width = -10
        //        let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
        //        self.navigationItem.setRightBarButtonItems(rightArray as?
        //            [UIBarButtonItem], animated: true)
        
        
        //viewToastObj = nil
        //        if (viewToastObj == nil)
        //        {
        //            viewToastObj = ViewToast()        //        }
        
        
        self.const_clkToRaiseTop.constant = 0.0
        
        
        
        self.getToastDetails()
        
    }
    
    
    func updateViewCalled1(notification: NSNotification) { // CreateNewToast
        
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        
        if(toastDict["toast_id"] != nil)
        {
            self.selectedToastId = toastDict["toast_id"] as! String
        }
        
        self.btn_ClickTorRelease.isHidden = false
        btn_LeaveGroup.isHidden = false
        
        
        //        let btn_edit: UIButton = UIButton(type: UIButtonType.custom)
        //        btn_edit.frame = CGRect(x: 0, y: -25, width: 30, height: 30)
        //        btn_edit.setImage(UIImage(named:"ic_edit button white"), for: UIControlState.normal)
        //
        //        btn_edit.addTarget(self, action: #selector(TViewToastDetailVC.btn_editClicked(_:)), for: UIControlEvents.touchUpInside)
        //        let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_edit)
        //        let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        //        navigationItem.width = -10
        //        let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
        //        self.navigationItem.setRightBarButtonItems(rightArray as?
        //            [UIBarButtonItem], animated: true)
        
        self.const_clkToRaiseTop.constant = 0.0
        if screenTag == 1// if from Diary screen chenge the constant
        {
            self.cont_btnLeaveGrpBottm.constant = 0.0
        }
        
        self.getToastDetails()
        
    }
    
    // MARK: - Notification methods
    
    func hideLeaveButton(notification: NSNotification) {  // to check if Initiator and Collaborators are on same toast and its Raised
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        if(toastDict["toast_id"] as! String == self.selectedToastId)
        {
            self.btn_LeaveGroup.isHidden = true
            self.cont_btnLeaveGrpBottm.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: -UISwitch Calls
    func switchChanged(_ mySwitch: UISwitch) {
        if mySwitch.isOn {
            // handle on
            
            print("ON")
            updateNotificationSettingCalled("Y")
            
        } else {
            // handle off
            
            print("OFF")
            updateNotificationSettingCalled("N")
        }
    }
    
    // MARK: -Webservice Calls
    
    func getToastDetails()
    {
        /*{
         "service": "toasteditdetails",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "toast_id": "4",
         "action_flag": "view"
         }*/
        
        
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "toasteditdetails", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selectedToastId, "action_flag" : "view"]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        
                        // Added if for extra check to avoid viewToastObj being nil
                        // viewToastObj becomes nil at some point
                        if(viewToastObj != nil)
                        {
                            //                       viewToastObj = ViewToast()
                            viewToastObj.removePrevValues()
                            viewToastObj.setData(fromDict: response as! NSDictionary)
                            
                            if(getValueFromDictionary(dicData: response as! NSDictionary, forKey: "owner_flag") == "1")
                            {
                                isInitiator = true
                            }
                            else{
                                isInitiator = false
                            }
                            
                            if isInitiator == true // show Edit btn if initiator
                            {
                                self.btn_ClickTorRelease.isHidden = false
                                let btn_edit: UIButton = UIButton(type: UIButtonType.custom)
                                btn_edit.frame = CGRect(x: 0, y: -25, width: 30, height: 30)
                                btn_edit.setImage(UIImage(named:"ic_edit button white"), for: UIControlState.normal)
                                
                                btn_edit.addTarget(self, action: #selector(TViewToastDetailVC.btn_editClicked(_:)), for: UIControlEvents.touchUpInside)
                                let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_edit)
                                //            let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                                //            navigationItem.width = -10
                                //            let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
                                self.navigationItem.setRightBarButton(rightBarButtonItemShare, animated: true)
                            }
                            else
                            {
                                self.btn_ClickTorRelease.isHidden = true
                                self.const_clkToRaiseTop.constant = -50.0
                                
                                // hide navigation edit button
                                
                                let btn_edit: UIButton = UIButton(type: UIButtonType.custom)
                                btn_edit.frame = CGRect(x: 0, y: -25, width: 30, height: 30)
                                btn_edit.setImage(UIImage(named:""), for: UIControlState.normal)
                                let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_edit)
                                //            let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                                //            navigationItem.width = -10
                                //            let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
                                self.navigationItem.setRightBarButton(rightBarButtonItemShare, animated: true)
                                
                            }
                            
                            /* 
                             
                             // removed in CR
                            if viewToastObj.toasteeUsersArr.count == 1
                            {
                              //  self.navigationItem.titleView = getNavigationTwoTitles(inputStr1: viewToastObj.toastTitle, inputStr2: "\(viewToastObj.toasteeUsersArr.count) Person")
                                 self.navigationItem.titleView = getNavigationTitle(inputStr: kNavigationTitleToastDetails)
                            }
                            else
                            {
                               // self.navigationItem.titleView = getNavigationTwoTitles(inputStr1: viewToastObj.toastTitle, inputStr2: "\(viewToastObj.toasteeUsersArr.count) People")
                                self.navigationItem.titleView = getNavigationTitle(inputStr: kNavigationTitleToastDetails)
                            }
 */
                        }
                        self.tblView_viewToast.reloadData()
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
    
    func TransferOwnershipCalled(toastIndex:Int)
    {
        /*
         "service": "changeownership",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "toast_id": "6",
         "new_owner_user_id": "12"
         */
        
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "changeownership", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selectedToastId, "new_owner_user_id": (viewToastObj.toast_UsersArr.object(at: toastIndex) as! AddMemberModel).member_User_id]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        //                        viewToastObj = nil
                        //                        if (viewToastObj == nil)
                        //                        {
                        //                            viewToastObj = ViewToast()
                        //                        }
                        
                        self.btn_ClickTorRelease.isHidden = true
                        self.const_clkToRaiseTop.constant = -50.0
                        self.view.layoutIfNeeded()
                        
                        let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                        navigationItem.width = -10
                        let rightArray:NSArray = [navigationItem]
                        self.navigationItem.setRightBarButtonItems(rightArray as?
                            [UIBarButtonItem], animated: true)
                        
                        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLeftToast_Notification), object: nil)
                        
                        // create object to pass via notification
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        let userInfo = ["newData": toastArray ,  "Id": self.selectedToastId] as [String : Any]
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateTransferedList_Notification), object: nil, userInfo: userInfo)
                        
                        isInitiator = false//set to avoid cell editing for netwprk failure
                        self.tblView_viewToast.reloadData()
                        self.getToastDetails()
                        
                        //                        self.tblView_viewToast.reloadData()
                    })
                }
                else if(statusToken as String == "Error" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        if (response["ErrorCode"]! as! NSNumber == 31)
                        {
                            // Cannot tranfer the ownership to same Id
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
    
    func DeleteMemberCalled(toastIndex:String)
    {
        /*
         {
         "service": "deletemembertoastee",
         "user_id": "3",
         "access_token": "HpPeauPUA7Y7beTSF4wtPiZkJTt5sT24",
         "delete_id": "30"
         }
         */
        
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "deletemembertoastee", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "delete_id" : toastIndex]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        //viewToastObj = nil
                        //                        if (viewToastObj == nil)
                        //                        {
                        //                            viewToastObj = ViewToast()
                        //                        }
                        
                        // create object to pass via notification
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        
                        let userInfo = ["newData": toastArray]
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kMemberDeleted_Notification), object: nil, userInfo: userInfo) // To update the view call the notification. As its registered in ToastVC only
                        
                        
                        self.getToastDetails()
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
    
    func LeaveToastCalled()
    {
        //uncomment below
        
        /*"{
         ""service"": ""leavetoast"",
         ""user_id"": ""3"",
         ""access_token"": ""S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au"",
         ""toast_id"": ""1""
         }"*/
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "leavetoast", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selectedToastId]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLeftToast_Notification), object: nil)
                        
                        //viewToastObj = nil
                        ((self.navigationController)! as UINavigationController).popToRootViewController(animated: true)
                        
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
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
    }
    
    func updateNotificationSettingCalled(_ status: String)
    {
        //uncomment below
        
        /*
         {
         "service": "changenotification",
         "user_id": "3",
         "access_token": "HpPeauPUA7Y7beTSF4wtPiZkJTt5sT24",
         "toast_id": "5",
         "notification_flag": "N"
         }
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            let parameters: NSDictionary = ["service": "changenotification", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selectedToastId, "notification_flag": status]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        //viewToastObj = nil
                        
                        /*
                         if (viewToastObj == nil)
                         {
                         viewToastObj = ViewToast()
                         }
                         */
                        self.getToastDetails()
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
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
    }
    
    func SendReminderCalled(toastIndex:String)
    {
        /*
         // if we want to send reminder for specific email
         {
         "service": "sendreminder",
         "user_id": "3",
         "access_token": "HpPeauPUA7Y7beTSF4wtPiZkJTt5sT24",
         "toast_id": "16",
         "reminder_id": "80" //  send delete ID
         }
         */
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "sendreminder", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : selectedToastId, "reminder_id" : toastIndex]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        let msg = ("Reminder sent Successfully to \(self.reminderSentTo_Name)")
                        SVProgressHUD.showInfo(withStatus: msg, maskType: .gradient)
                    })                }
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
        
        releaseStatus = "Y"
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TViewToastDetailVC.btn_clickToReleaseClicked(_:)), userInfo: nil, repeats: false)
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.favView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.favView.alpha = 0.0
            self.bgView.alpha = 0.0
        }, completion: {(value: Bool) in
            self.favView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        })
    }
    
    
    
    // MARK: - Button Action
    func btn_editClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "editToastSeg", sender: self)
    }
    
    func backBtnClicked(_ sender : UIButton!) {
        
        // viewToastObj = nil
        
        
        
        // to check the navigation array
        var exists = false
        if self.navigationController?.viewControllers == nil
        {
            return
        }
        for controller in (self.navigationController?.viewControllers)! {
            if controller.isKind(of: TChatViewController.classForCoder()) == true {
                exists = true
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRefreshToastList_Notification), object: nil)
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil)
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil)
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRedirectToViewToastViaChatVC_pushNotification), object: nil) // remove becoz its fired only if view is visible
            }
        }
        
        if exists == true {
            ((self.navigationController)! as UINavigationController).popViewController(animated: true)
        }
        
        //((self.navigationController)! as UINavigationController).popViewController(animated: true)
        
        
    }
    
    @IBAction func btn_LeaveGroupClicked(_ sender: ZFRippleButton) {
        
        if isInitiator == true // show Edit btn if initiator
        {
            LeaveToastCalled()
        }
        else
        {
            func handleLeaveToast(_ alertView: UIAlertAction!)
            {
                LeaveToastCalled()
            }
            func handleCancel(_ alertView: UIAlertAction!)
            {
                self.dismiss(animated: true, completion: nil)
            }
            
            let alert = UIAlertController(title: nil, message: kLeaveGroup, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Leave", style: UIAlertActionStyle.default, handler:handleLeaveToast))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
            
            alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func btn_clickToReleaseClicked(_ sender: ZFRippleButton) {
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
                        //notification fired to refresh Toast list
                        isToastRaised = true
                        
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        
                        let userInfo = ["newData": toastArray]
                        
                        
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
    
    
    
    
    // MARK: - Table View Delegate and Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return 1
        }
        else
        {
            if (viewToastObj != nil)
            {
                return viewToastObj.toast_UsersArr.count
            }
            else
            {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0)
        {
            let currentSize:CGFloat = UIScreen.main.bounds.size.height * (11.7 / 568.0)
            let currentFont = UIFont(name: "HelveticaNeue", size: currentSize)
            
            if (viewToastObj != nil)
            {
                var currentheight = heightForView(text: viewToastObj.theme, font: currentFont!, width: UIScreen.main.bounds.size.height * (320.0 / 568.0))
                
                if(currentheight == 0.0)
                {
                    currentheight = 21.0
                }
                if isInitiator == true // show release btn if initiator
                {
                    if UIScreen.main.bounds.size.height == 480
                    {
                        return (UIScreen.main.bounds.size.height * (480.0 / 568.0)) + currentheight
                    }
                    else
                    {
                        return (UIScreen.main.bounds.size.height * (399.0 / 568.0)) + currentheight
                    }
                }
                else
                {
                    return UITableViewAutomaticDimension

                    //return (UIScreen.main.bounds.size.height * (365.0 / 568.0)) + currentheight // updated from 329 to check multiline
                }
            }
            else
            {
                if isInitiator == true // show release btn if initiator
                {
                    if UIScreen.main.bounds.size.height == 480
                    {
                        return (UIScreen.main.bounds.size.height * (480.0 / 568.0))
                    }

                    else
                    {
                    return (UIScreen.main.bounds.size.height * (378.0 / 568.0)) //  if line ovelaps notification switch update to (399.0 / 568.0)
                    }
                }
                else
                {
                    //return (UIScreen.main.bounds.size.height * (365.0 / 568.0))
                    return UITableViewAutomaticDimension
                }
            }
        }
        else
        {
            return UIScreen.main.bounds.size.height * (73.0 / 568.0)
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width,height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    //uncomment below
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0)
        {
            let cellIdentifier:String = "ViewToastDetailCell"
            var cell:ViewToastDetailCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ViewToastDetailCell
            if (cell == nil){
                tableView.register(UINib(nibName: "ViewToastDetailCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ViewToastDetailCell
                cell?.layoutMargins=UIEdgeInsets.zero
                cell?.preservesSuperviewLayoutMargins=false
                cell?.backgroundColor=UIColor.clear
            }
            
            if (viewToastObj != nil)
            {
                /*
                 let toastURL: URL = URL(string: viewToastObj.toastImageURL)!
                 let manager:SDWebImageManager = SDWebImageManager.shared()
                 manager.downloadImage(with: toastURL, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                 let aspectScaledToFillImage = image //.af_imageAspectScaled(toFill: (cell?.imgView_Toast.frame.size)!)
                 cell?.imgView_Toast.image = aspectScaledToFillImage
                 })
                 */
                
                
                if(viewToastObj.toastImageURL.characters.count > 0)
                {
                    let toastURL: URL = URL(string: viewToastObj.toastImageURL)!
                    cell?.imgView_Toast.af_setImage(withURL: toastURL)
                } else {
                    cell?.imgView_Toast.image = nil
                }
                
                cell?.lbl_ToastToPeopleName.text = viewToastObj.toastTitle
                
                if viewToastObj.toasteeUsersArr.count == 0
                {
                    cell?.lbl_NumOfPerson.text = ""
                }
                else if viewToastObj.toasteeUsersArr.count == 1
                {
                    cell?.lbl_NumOfPerson.text = "\(viewToastObj.toasteeUsersArr.count) Person"
                }
                else
                {
                    cell?.lbl_NumOfPerson.text = "\(viewToastObj.toasteeUsersArr.count) People"
                }
                
                
                // Convert to show Emoticons
                let str = viewToastObj.theme
                let emojData : NSData = str.data(using: String.Encoding.utf8)! as NSData
                let emojString:String = String(data: emojData as Data, encoding: String.Encoding.nonLossyASCII)!
                
                //  cell?.lbl_ToastMsg.text = emojString
                
               // cell?.lbl_ToastCategory.text = "Toast to celebrate \(viewToastObj.categoryName.characters.count > 0 ? viewToastObj.categoryName : viewToastObj.otherCategoryName)
                
                let themeText = viewToastObj.categoryName.characters.count > 0 ? viewToastObj.categoryName : viewToastObj.otherCategoryName
                
                if themeText.characters.count > 0
                {
                cell?.lbl_ToastMsg.text = "Toast to celebrate \(themeText). \(emojString)"
                }
                else
                {
                    cell?.lbl_ToastMsg.text = ""
                }
                
                cell?.lbl_ToastMsg.lineBreakMode = .byWordWrapping
                cell?.lbl_ToastMsg.numberOfLines = 0
                
                
               // cell?.lbl_ToastCategory.text = "Toast to celebrate \(viewToastObj.categoryName.characters.count > 0 ? viewToastObj.categoryName : viewToastObj.otherCategoryName)"
                
                cell?.lbl_ToastCategory.text = "\(viewToastObj.categoryName.characters.count > 0 ? viewToastObj.categoryName : viewToastObj.otherCategoryName)"
                
                cell?.lbl_fromGroup.text = viewToastObj.fromText.characters.count > 40 ? (viewToastObj.fromText.substring(to: viewToastObj.fromText.index(viewToastObj.fromText.startIndex, offsetBy: 33)) + "...") : viewToastObj.fromText
                
                cell?.lbl_CreatedOnTime.text = viewToastObj.createdDate
                
                if(viewToastObj.releasedDate.characters.count > 0)
                {
                    cell?.lbl_DueOnTime.text = viewToastObj.releasedDate
                }
                else
                {
                    cell?.lbl_DueOnTime.text = "N/A"
                }
                
                
                if isInitiator == true //if user is initiator
                {
                    /*
                     let str = viewToastObj.theme
                     let emojData : NSData = str.data(using: String.Encoding.utf8)! as NSData
                     let emojString:String = String(data: emojData as Data, encoding: String.Encoding.nonLossyASCII)!
                     
                     cell?.lbl_ToastMsg.text = emojString
                     
                     cell?.lbl_ToastMsg.lineBreakMode = .byWordWrapping
                     cell?.lbl_ToastMsg.numberOfLines = 0
                     
                     cell?.lbl_ToastCategory.text = viewToastObj.categoryName.characters.count > 0 ? viewToastObj.categoryName : viewToastObj.otherCategoryName
                     cell?.lbl_fromGroup.text = viewToastObj.fromText
                     
                     cell?.lbl_CreatedOnTime.text = viewToastObj.createdDate
                     
                     if(viewToastObj.releasedDate.characters.count > 0)
                     {
                     cell?.lbl_DueOnTime.text = viewToastObj.releasedDate
                     }
                     else
                     {
                     cell?.lbl_DueOnTime.text = "N/A"
                     }
                     */
                    
                    if isInitiator == true //if user is initiator
                    {
                        
                    }
                    else // If member
                    {
                        cell?.const_NotifctnBgViewHeight.constant = 0.0
                        cell?.view_notifctnBg.isHidden = true
                    }
                    
                    if screenTag == 1// if from Diary screen
                    {
                        cell?.lbl_DueOn.text = "Raised On"
                        cell?.view_notifctnBg.isHidden = true
                    }
                    else
                    {
                        if viewToastObj.toast_notification == "Y"
                        {
                            cell?.switch_Notification.isOn = true
                        }
                        else
                        {
                            cell?.switch_Notification.isOn = false
                        }
                        
                        cell?.switch_Notification.addTarget(self, action: #selector(TViewToastDetailVC.switchChanged(_:)), for: UIControlEvents.valueChanged)
                        
                        cell?.lbl_DueOn.text = "Raise On"
                    }
                }
                else
                {
                    if screenTag == 1// if from Diary screen
                    {
                        cell?.lbl_DueOn.text = "Raised On"
                    }
                    else
                    {
                        cell?.lbl_DueOn.text = "Raise On"
                    }
                    cell?.view_notifctnBg.isHidden = true
                }
            }
            else
            {
                print("viewToastObj = nil in VTDVC")
            }
            cell?.selectionStyle = .none
            
            return cell!
        }
        else
        {
            let cellIdentifier:String = "AddMemberCell"
            var cell:AddMemberCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AddMemberCell
            if (cell == nil){
                tableView.register(UINib(nibName: "AddMemberCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AddMemberCell
                cell?.layoutMargins=UIEdgeInsets.zero
                cell?.preservesSuperviewLayoutMargins=false
                cell?.backgroundColor=UIColor.clear
            }
            
            if (viewToastObj != nil)
            {
                if (viewToastObj.toast_UsersArr.count > indexPath.row)
                {
                    
                    cell?.lbl_MemberName.text = "\((viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_First_name) \((viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_Last_name)"
                    
                    cell?.lbl_MemberEmail.text = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_Email_id
                    
                    let memberPhotoURL = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_Profile_photoURL
                    
                    cell?.imgView_MemberPhoto.image = UIImage(named:"ic_default profile")
                    
                    if(memberPhotoURL.characters.count > 0)
                    {
                        /*
                         let toastURL: URL = URL(string: memberPhotoURL)!
                         let manager:SDWebImageManager = SDWebImageManager.shared()
                         manager.downloadImage(with: toastURL, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                         let aspectScaledToFillImage = image?.af_imageRoundedIntoCircle()
                         cell?.imgView_MemberPhoto.image = aspectScaledToFillImage
                         })
                         */
                        
                        let toastURL: URL = URL(string: memberPhotoURL)!
                        cell?.imgView_MemberPhoto.af_setImage(withURL: toastURL)
                        //let resizableWidth = UIScreen.main.bounds.size.height * ((cell?.imgView_MemberPhoto.frame.size.width)! / 568.0)
                        
                        cell?.imgView_MemberPhoto.cornerRadius = ((cell?.imgView_MemberPhoto.frame.size.width)! / 2) - 5.0
                    }
                    
                    //            if isInitiator == false // show if member
                    //            {
                    cell?.btn_Close.isHidden = true
                    let memberType = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).accessFlag
                    
                    if(memberType == "T")
                    {
                        cell?.lbl_MemberType.text = "Toastee"
                        cell?.lbl_MemberType.textColor = UIColor(hexCode: 0xE96474)
                    }
                    else if(memberType == "I")
                    {
                        cell?.lbl_MemberType.text = "Initiator"
                        cell?.lbl_MemberType.textColor = UIColor(hexCode: 0xE9C002)
                    }
                    else if(memberType == "M")
                    {
                        cell?.lbl_MemberType.text = "Collaborator"
                        cell?.lbl_MemberType.textColor = UIColor(hexCode: 0x20B9B9)
                    }
                }
            }
            else
            {
                print("viewToastObj = nil in VTDVC")
            }
            cell?.view_Bg.backgroundColor = UIColor.white
            cell?.view_Bg.layer.borderWidth = 1.0
            cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
            cell?.view_Bg.layer.cornerRadius = 2.0
            cell?.view_Bg.clipsToBounds = true
            
            
            cell?.selectionStyle = .none
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0) // Enlarge the image to full view
        {
            var items: [KSPhotoItem] = []
            
            let cell = tblView_viewToast.cellForRow(at: indexPath) as! ViewToastDetailCell
            let url: String = viewToastObj.toastImageURL
            if(url.characters.count > 0)
            {
                guard let imageView = cell.imgView_Toast else { return }
                guard let imageUrl = URL(string: url) else { return }
                let item = KSPhotoItem(sourceView: imageView, imageUrl: imageUrl)
                items.append(item)
                
                let browser = KSPhotoBrowser(photoItems: items, selectedIndex: UInt(0))
                //browser.delegate = self
                browser.dismissalStyle = .rotation
                browser.backgroundStyle = .blurPhoto
                browser.loadingStyle = .indeterminate
                browser.pageindicatorStyle = .dot
                browser.bounces = false
                browser.show(from: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if isInitiator == true && viewToastObj.toast_UsersArr.count > indexPath.row // show edit optn if initiator
        {
            var collaboratorName  = "\((viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_First_name) \((viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_Last_name)"
            
            if collaboratorName.characters.count < 2
            {
                collaboratorName = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_Email_id
            }
            
            //  Update "more" options for user type on swipe (Toastee will have Delete and Transfer Ownership only )
            
            let accesFlag = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).accessFlag
            
            var btnTitle = "         " // 9 char - for displaying/adjusting more
            if(accesFlag == "T")
            {
                if(currentScreen() as String == Device_iPhone5s)
                {
                    btnTitle = "        " // 8 char - for displaying/adjusting transfer ownership
                }
                else if(currentScreen() as String == Device_iPhone6)
                {
                    btnTitle = "           " // 11 char - for displaying/adjusting transfer ownership
                }
                else if(currentScreen() as String == Device_iPhone6p)
                {
                    btnTitle = "             " // 13 char - for displaying/adjusting transfer ownership
                }

                
            }
            
            let buttonMore = UITableViewRowAction(style: .default, title: btnTitle) { action, indexPath in
                
                if(accesFlag == "T")
                {
                    //                let buttonMore = UITableViewRowAction(style: .default, title: "         ") { action, indexPath in
                    
                    func handleOwnerTransfer(_ alertView: UIAlertAction!)
                    {
                        if viewToastObj.toast_UsersArr.count > indexPath.row
                        {
                            self.TransferOwnershipCalled(toastIndex: indexPath.row)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                    func handleCancel(_ alertView: UIAlertAction!)
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    let alert = UIAlertController(title: nil, message: ("\(kTransferOwnership_1) \(collaboratorName) \(kTransferOwnership_2)"), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:handleOwnerTransfer))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                    
                    alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    //More
                    //            let buttonMore = UITableViewRowAction(style: .default, title: "         ") { action, indexPath in
                    // Send Reminder
                    func handleReminder(_ alertView: UIAlertAction!)
                    {
                        self.dismiss(animated: true, completion: nil)
                        
                        
                        func handleSend(_ alertView: UIAlertAction!)
                        {
                            let deleteID = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).delete_id
                            
                            self.reminderSentTo_Name = collaboratorName
                            self.SendReminderCalled(toastIndex: deleteID)
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                        func handleCancel(_ alertView: UIAlertAction!)
                        {
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        let alert = UIAlertController(title: nil, message: ("\(kSendReminder_1) \(collaboratorName) \(kSendReminder_2)"), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:handleSend))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                        
                        alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    // Transfer OwenerShip
                    func handleTransfer(_ alertView: UIAlertAction!)
                    {
                        self.dismiss(animated: true, completion: nil)
                        
                        func handleOwnerTransfer(_ alertView: UIAlertAction!)
                        {
                            if viewToastObj.toast_UsersArr.count > indexPath.row
                            {
                                self.TransferOwnershipCalled(toastIndex: indexPath.row)
                            }
                            self.dismiss(animated: true, completion: nil)
                        }
                        func handleCancel(_ alertView: UIAlertAction!)
                        {
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        let alert = UIAlertController(title: nil, message: ("\(kTransferOwnership_1) \(collaboratorName) \(kTransferOwnership_2)") , preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:handleOwnerTransfer))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                        
                        alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    func handleCancel(_ alertView: UIAlertAction!)
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    let alert = UIAlertController(title: "Select Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                    alert.addAction(UIAlertAction(title: "Send Reminder", style: UIAlertActionStyle.default, handler:handleReminder))
                    alert.addAction(UIAlertAction(title: "Transfer Ownership", style: UIAlertActionStyle.default, handler:handleTransfer))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler:handleCancel))
                    
                    alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            
            //Delete
            let buttonDelete = UITableViewRowAction(style: .default, title: "         ") { action, indexPath in
                func handleDelete(_ alertView: UIAlertAction!)
                {
                    self.dismiss(animated: true, completion: nil)
                    //                    let tempToateeArr = NSMutableArray()
                    //                    for toasteeArr in viewToastObj.toast_UsersArr
                    //                    {
                    //                        if((toasteeArr as! AddMemberModel).accessFlag == "T")
                    //                        {
                    //                            tempToateeArr.add(toasteeArr as! AddMemberModel)
                    //                        }
                    //                    }
                    
                    
                    if (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).accessFlag == "T" // check if cell is of toastee
                    {
                        if(viewToastObj.toasteeUsersArr .count > 1)
                        {
                            
                            let deleteID = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).delete_id
                            
                            self.DeleteMemberCalled(toastIndex: deleteID)
                        }
                        else
                        {
                            SVProgressHUD.showInfo(withStatus: kCannotRemoveToaseeMsg, maskType: .gradient)
                        }
                        
                    }
                    else
                    {
                        let deleteID = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).delete_id
                        
                        self.DeleteMemberCalled(toastIndex: deleteID)
                        
                    }
                    
                }
                func handleCancel(_ alertView: UIAlertAction!)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                
                var msg : String = String()
                
                
                
                msg = ("\(kRemoveCollaborator_1) \(collaboratorName)\(kRemoveCollaborator_2)")
                
                if (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).accessFlag == "T" // check if cell is of toastee
                {
                    msg = kRemoveToastee
                }
                
                let alert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler:handleDelete))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                
                alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                self.present(alert, animated: true, completion: nil)
            }
            
            if(UIScreen.main.bounds.size.height == 667)
            {
                if(accesFlag == "T") // Transfer Ownership only
                {
                    buttonMore.backgroundColor = UIColor(patternImage: UIImage(named: "memberTransfer@183")!)
                }
                else
                {
                    buttonMore.backgroundColor = UIColor(patternImage: UIImage(named: "memberMore@183")!)
                }
                
                buttonDelete.backgroundColor = UIColor(patternImage: UIImage(named: "memberdelete@183")!)
                
            }
            else
            {
                if(accesFlag == "T") // Transfer Ownership only
                {
                    buttonMore.backgroundColor = UIColor(patternImage: UIImage(named: "memberTransfer@306")!)
                }
                else
                {
                    buttonMore.backgroundColor = UIColor(patternImage: UIImage(named: "memberMore@306")!)
                }
                
                buttonDelete.backgroundColor = UIColor(patternImage: UIImage(named: "memberdelete@306")!)
                
            }
            
            return [buttonDelete, buttonMore]
        } // bvbvbvbv
            
        else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        var returnBool = false
        if isInitiator == true // if initiator
        {
            if(viewToastObj != nil)
            {
                if viewToastObj.toast_UsersArr.count > indexPath.row {
                    let memberID = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_User_id
                    let accesFlag = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).accessFlag
                    
                    if(indexPath.section == 1)
                    {
                        if(UserDefaults.standard.value(forKey: KEY_USER_ID)! as! String == memberID && accesFlag == "I" )
                        {
                            // if initiator
                            returnBool = false
                        }
                        else
                        {
                            returnBool = true
                        }
                    }
                    else // for other sections
                    {
                        returnBool = false
                    }
                }
            }
            else{
                // If not Initiator
                returnBool = false
            }
        }
        return returnBool
    }
    
    //    @objc(tableView:canFocusRowAtIndexPath:) func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
    //    {
    //
    //        if isInitiator == true //  if initiator
    //        {
    //            let memberID = (viewToastObj.toast_UsersArr.object(at: indexPath.row) as! AddMemberModel).member_User_id
    //
    //            if(indexPath.section == 1 && (UserDefaults.standard.value(forKey: KEY_USER_ID)! as! String == memberID))
    //            {
    //                return true
    //            }
    //            else
    //            {
    //                return false
    //
    //            }
    //        }
    //        else{
    //            return false
    //        }
    //    }
    
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
        if(segue.identifier == "editToastSeg")
        {
            //            if let editToastVC: TEditToastViewController = segue.destination as? TEditToastViewController {
            //                    editToastVC.selectedToastObj = viewToastObj
            //            }
        }
    }
    
}

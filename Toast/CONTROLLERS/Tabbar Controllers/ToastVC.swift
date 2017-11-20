
//
//  TFirstViewController.swift
//  Toast
//
//  Created by Anish Pandey on 07/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import SDWebImage

class TtoastVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btn_Plus: UIButton!
    @IBOutlet weak var btn_Initiator: ZFRippleButton!
    @IBOutlet weak var btn_Member: ZFRippleButton!
    @IBOutlet weak var tblView_Toast: UITableView!
    var arr_ToastCollectn:NSMutableArray = NSMutableArray()
    @IBOutlet weak var lbl_InitiatorBase: UILabel!
    @IBOutlet weak var lbl_MemberBase: UILabel!
    var previousIndexPath:NSIndexPath!
    
    var isInitiator_Toast: Bool = false
    
    var favView : CustomFavorites!
    var bgView : UIView = UIView()
    
    var selectedToastId:String = String()
    var selectedToastTitle:String = String()
    var isAutoOpenViewToastDetails:Bool = false
    
    var arr_initiatorCollectn:NSMutableArray = NSMutableArray()
    var arr_memberCollectn:NSMutableArray = NSMutableArray()
    var offset_Initiator: String = "0" // to call data in group for initiator
    var offset_Member: String = "0" // to call data in group for member
    
    @IBOutlet weak var lbl_noResults: UILabel!
    @IBOutlet weak var view_noResult: UIView!
    @IBOutlet weak var btn_CreateNewToast: UIButton!
    
    var selectedIndexPath:NSIndexPath! //  sustains value for selected toast index
    
     var txtFld_Active:UITextField!
    
    func addInfiniteScrollHander(){
        self.tblView_Toast.addInfiniteScroll { (scrollView) -> Void in
            if WebService.isFinish == true
            {
                self.fetchToastList()
            }
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TtoastVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    // MARK: - Pull to refresh Action
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing data...")
        
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
                
                SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
                
                if WebService.isFinish == true // To avoid clash with addInfiniteScrollHander
                {
                    // Clear all the flags to load fresh data for selected user type
                    
                    if(self.isInitiator_Toast == true)//if initiator btn clicked
                    {
                        self.offset_Initiator = "0"
                        self.arr_initiatorCollectn.removeAllObjects()  //  remove previous records
                    }
                    else
                    {
                        self.offset_Member = "0"
                        self.arr_memberCollectn.removeAllObjects() //  remove previous records
                    }
                    
                    self.fetchToastList()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //uncomment below
        self.view_noResult.alpha = 0.0
        self.tblView_Toast.addSubview(self.refreshControl)
        
        self.addInfiniteScrollHander()
        
        self.view.addSubview(bgView)
        self.bgView.frame = self.view.frame
        self.bgView.backgroundColor = UIColor.black

        //self.view.bringSubview(toFront: favView)
        
        
        self.CustomiseView()
        self.animateTable()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.updateToastlistMsgCount), name: NSNotification.Name(rawValue: kListCount_Notification), object: nil) //  fired when new toast is created or other action for refreshing list using object from action reponse
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.updateToastlist), name: NSNotification.Name(rawValue: kUpdateList_Notification), object: nil) //  fired when new toast is created or other action for refreshing list using object from action reponse
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.openDiaryTab), name: NSNotification.Name(rawValue: kToastRaised_Notification), object: nil) // called when Toast is raised from chat list VC and toast detail VC
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.updateTransferedToastlist), name: NSNotification.Name(rawValue: kUpdateTransferedList_Notification), object: nil) //  fired when ownership is transfered or other action for refreshing list using object from action reponse
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.refreshToastList), name: NSNotification.Name(rawValue: kLeftToast_Notification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.openChatVC), name: NSNotification.Name(rawValue: kRedirectToCheersScreen_pushNotification), object: nil)//Push Notification Trigger: fired when received push notifications regarding opening of TChatViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.refreshAllToastList), name: NSNotification.Name(rawValue: kCheersScreen_pushNotification), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.openViewToastVCViaChatVC), name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: nil)//Push Notification Trigger: fired when received push notifications regarding opening of ViewToastDetails
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.refreshAllToastList), name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil) //  to handle duplicate entry in toast list for collaborator.
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.refreshAllToastList), name: NSNotification.Name(rawValue: kRedirectToViewToastViaChatVC_pushNotification), object: nil) // called from appD during transfer to update the list when user is on details page
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.memberDeleted), name: NSNotification.Name(rawValue: kMemberDeleted_Notification), object: nil) // called when Toast is raised from chat list VC and toast detail VC
        
        // NotificationCenter.default.addObserver(self, selector: #selector(TtoastVC.updateOffset), name: NSNotification.Name(rawValue: kUpdateOffset_Notification), object: nil) // called when Toast is raised from chat list VC and toast detail VC
        
        
        self.getAllImageUrls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        self.tabBarController?.setBadges(badgeValues: [0,101])
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.addBadge(index: 0, value: 0, color: UIColor.clear, font: UIFont(name: "Helvetica-Light", size: 11)!)
        
        isInitiator = isInitiator_Toast
        
        
        favView = Bundle.loadView(fromNib: "CustomFavorites", withType: CustomFavorites.self)
        let cellNib = UINib(nibName: "CustomFavoritesTableViewCell", bundle: nil)
        favView.tblFav.register(cellNib, forCellReuseIdentifier: "CustomFavoritesTableViewCell")
        self.favView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width , height: self.view.bounds.size.height)
        self.favView.btnCancel.addTarget(self, action: #selector(self.cancelButtonClicked), for: .touchUpInside)
        self.favView.BtnContinue.addTarget(self, action: #selector(self.continueButtonClicked), for: .touchUpInside)
        self.bgView.alpha = 0.0
        self.favView.alpha = 0.0
        self.favView.TblView_Hconst.constant = 0
        self.view.addSubview(favView)
        
       // self.btn_InitiatorClicked(btn_Initiator)
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
        
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kLeftToast_Notification), object: nil)
        
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kToastRaised_Notification), object: nil)
        
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCheersScreen_pushNotification), object: nil)
        //
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: nil)
        
        // NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kUpdateList_Notification), object: nil)
        
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kUpdateTransferedList_Notification), object: nil)
        
        //  NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kListCount_Notification), object: nil)
        
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil)
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRedirectToCheersScreen_pushNotification), object: nil)
    }
    
    func CustomiseView()
    {
        //comment below
       // self.navigationItem.titleView = getNavigationTitle(inputStr: kNavigationTitleToastTab)
        self.navigationItem.titleView = getNavigationTwoTitles(inputStr1:kNavigationTitleToastTab , inputStr2: kNavigationTitleSmallDairyTab)
        
        
        let btn_Add: UIButton = UIButton(type: UIButtonType.custom)
        btn_Add.frame = CGRect(x: 0, y: -25, width: 38, height: 30)
        btn_Add.setImage(UIImage(named:"ic_add white1"), for: UIControlState.normal)
        btn_Add.addTarget(self, action: #selector(TtoastVC.btn_AddClicked(_:)), for: UIControlEvents.touchUpInside)
        let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_Add)
        
        //        let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        //        navigationItem.width = -10
        //        let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
        
        self.navigationItem.setRightBarButton(rightBarButtonItemShare, animated: true)
        
        btn_Initiator.isSelected = true
        lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xffffff)
        isInitiator = true
        isInitiator_Toast = isInitiator
        
        
        let overlayIndex_ToastVC = UserDefaults.standard.string(forKey: KEY_OverlayIndex_ToastVC) as NSString?
        if let newOverlayIndex_ToastVC = overlayIndex_ToastVC
        {
            if(newOverlayIndex_ToastVC == "Show")
            {
                //show overlay after sometime
                _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(TtoastVC.startOverLay), userInfo: nil, repeats: false)
            }
        }
        else
        {
            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(TtoastVC.startOverLay), userInfo: nil, repeats: false)
        }
    }
    
    func startOverLay()
    {
        let item = self.navigationItem.rightBarButtonItem
        let button = item?.customView as! UIButton
        
        /*
        //added it on window to cover tabbar and navigation bar as well
        self.view.window?.addOverlayByHighlightingSubView(button, withText: " Initiate a new toast to someone.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.view.window?.removeOverlay()
            UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_ToastVC)
        }
 */
        
        // next button
        self.view.window?.addOverlayByHighlightingSubView(button, withText: " Initiate a new toast to someone.")
        UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_ToastVC)
    }
    
    func animateTable() {
        tblView_Toast.reloadData()
        
        let cells = tblView_Toast.visibleCells
        let tableHeight: CGFloat = tblView_Toast.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveLinear, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
            
            index += 1
        }
    }
    
    
    
    func removeDuplicate(dataArray : NSMutableArray) -> NSMutableArray {
        
//        let filteredArray : NSMutableArray = NSMutableArray()
//        for dupObj in dataArray
//        {
//                if !filteredArray.contains(dupObj) {
//                    filteredArray.add(dupObj)
//                }
//                else
//                {
//                    print("Duplicate found ****")
//                }
//        }
//
//        return filteredArray
        
        let unique : NSMutableArray = NSMutableArray()
        var seen = Set<String>()
        // var unique = [DiaryList]()
        for message in dataArray {
            if !seen.contains((message as! ToastList).toast_id) {
                unique.add(message as! ToastList)
                seen.insert((message as! ToastList).toast_id)
            }
        }
        
        return unique

    }
    
    // MARK: - WS Calls
    
    
    
    func fetchToastList()
    {
        /*"{
         ""service"": ""toastlist"",
         ""user_id"": ""3"",
         ""access_token"": ""S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au"",
         ""list_flag"": ""initiator""
         "offset":"1"
         }
         
         list_flag = member (For toast member)"*/
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            // Check and set offSet for WS call
            var offset =  ""
            
            let listFlag:String!
            if(isInitiator_Toast == true)//if initiator btn clicked
            {
                listFlag = "initiator"
                offset = self.offset_Initiator
                
                //offset = String(arr_initiatorCollectn.count)
                
                if offset == "0"//if offset sent is "" then remove all objects from array.
                {
                    self.arr_initiatorCollectn.removeAllObjects()
                }
                
            }
            else
            {
                listFlag = "member"
                offset = self.offset_Member
                
                //offset = String(arr_memberCollectn.count)
                
                if offset == "0" //if offset sent is "" then remove all objects from array.
                {
                    self.arr_memberCollectn.removeAllObjects()
                }
                
            }
            
            
            
            let parameters: NSDictionary = ["service": "toastlist", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "list_flag" : listFlag, "offset": offset]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                self.tblView_Toast.finishInfiniteScroll()
                
                if(self.refreshControl.isRefreshing)
                {
                    self.refreshControl.endRefreshing()
                }
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    let next_offset:NSString = NSString(format: "%@",response["next_offset"]! as! NSString)
                    //                     let next_offset = ""
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        // Check for count. Update next_offset only if array not empty

                        if(toastArray.count > 0)
                        {
                            self.view_noResult.alpha = 0.0
                            for toast in toastArray
                            {
                                let toastObj:ToastList = ToastList()
                                toastObj.setData(fromDict: toast as! NSDictionary)
                                
                                if(self.isInitiator_Toast == true)//if initiator btn clicked (listFlag = "initiator")
                                {
                                    self.arr_initiatorCollectn.add(toastObj)
                                }
                                else // listFlag = "member"
                                {
                                    self.arr_memberCollectn.add(toastObj)
                                }
                            }
                            
                            // Make a copy of arreay
                            var dataArrayInitiator : NSMutableArray = NSMutableArray()
                            var dataArrayMember : NSMutableArray = NSMutableArray()
                            
                            dataArrayInitiator = self.arr_initiatorCollectn.mutableCopy() as! NSMutableArray
                            dataArrayMember = self.arr_memberCollectn.mutableCopy() as! NSMutableArray
                            
                            self.arr_initiatorCollectn.removeAllObjects()
                            self.arr_memberCollectn.removeAllObjects()
                            
                            //remove duplicate elemets from array
                            self.arr_initiatorCollectn = self.removeDuplicate(dataArray: dataArrayInitiator)
                            self.arr_memberCollectn = self.removeDuplicate(dataArray: dataArrayMember)
                            
                            // Clear and copy to main array for display
                            self.arr_ToastCollectn.removeAllObjects()
                            
                            if(self.isInitiator_Toast == true)//if initiator btn clicked
                            {
                                if Int(self.offset_Initiator)! > Int(next_offset as String)!
                                {
                                    // Do not copy
                                }
                                else
                                {
                                    self.offset_Initiator = next_offset as String
                                }
                                
                                self.arr_ToastCollectn = self.arr_initiatorCollectn.mutableCopy() as! NSMutableArray
                                for dupObj in self.arr_ToastCollectn
                                {
                                    if (dupObj as! ToastList).owner_access as String != "1"{
                                       self.arr_ToastCollectn.remove(dupObj)
                                        print("Collab Duplicate found ****")
                                    }
                                    else
                                    {
                                        
                                    }
                                }

                            }
                            else
                            {
                                self.offset_Member = next_offset as String
                                self.arr_ToastCollectn = self.arr_memberCollectn.mutableCopy() as! NSMutableArray
                                for dupObj in self.arr_ToastCollectn
                                {
                                    if (dupObj as! ToastList).owner_access as String != "0"{
                                        self.arr_ToastCollectn.remove(dupObj)
                                        print("Initiator Duplicate found ****")
                                    }
                                    else
                                    {
                                        
                                    }
                                }

                            }
                            
                        }
                        else //  if no result found in response
                        {
                            self.arr_ToastCollectn.removeAllObjects()
                            if(self.isInitiator_Toast == true)//if initiator btn clicked
                            {
                                self.arr_ToastCollectn = self.arr_initiatorCollectn.mutableCopy() as! NSMutableArray
                                
                                for dupObj in self.arr_ToastCollectn
                                {
                                    if (dupObj as! ToastList).owner_access as String != "1"{
                                        self.arr_ToastCollectn.remove(dupObj)
                                        print("Collab Duplicate found ****")
                                    }
                                    else
                                    {
                                        
                                    }
                                }

                                
                                if(self.arr_ToastCollectn.count < 1)
                                {
                                    self.view_noResult.alpha = 1.0
                                    self.lbl_noResults.text = kNoToastForInitiator_Msg
                                    self.btn_CreateNewToast.alpha = 1.0 // used as lable for msg
                                    self.btn_Plus.isHidden = false
                                }
                                else
                                {
                                    self.view_noResult.alpha = 0.0
                                }
                            }
                            else //if collaborator btn clicked
                            {
                                self.arr_ToastCollectn = self.arr_memberCollectn.mutableCopy() as! NSMutableArray
                                
                                for dupObj in self.arr_ToastCollectn
                                {
                                    if (dupObj as! ToastList).owner_access as String != "0"{
                                        self.arr_ToastCollectn.remove(dupObj)
                                        print("Initiator Duplicate found ****")
                                    }
                                    else
                                    {
                                        
                                    }
                                }

                                if(self.arr_ToastCollectn.count < 1)
                                {
                                    self.view_noResult.alpha = 1.0
                                    self.lbl_noResults.text = kNoToastForCollaborator_Msg
                                    self.btn_CreateNewToast.alpha = 0.0 // used as lable for msg
                                    self.btn_Plus.isHidden = true
                                }
                                else
                                {
                                    self.view_noResult.alpha = 0.0
                                }
                            }
                        }
                        self.tblView_Toast.reloadData()
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
            SVProgressHUD.dismiss()
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
        
    }
    
    func getAllImageUrls()
    {
        /*"{
         ""service"": ""getimagepath""
         }"*/
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            //            SVProgressHUD.show(withStatus: "Listing Toast", maskType: .gradient)
            
            let parameters: NSDictionary = ["service": "getimagepath"]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                /*"{
                 ""status"": ""Success"",
                 ""image_paths"": {
                 ""userprofile"": ""http://clientprojects.info/qa/toastapp/images/uploads/user_profiles/"",
                 ""toast_images"": ""http://clientprojects.info/qa/toastapp/images/uploads/toast_images/"",
                 ""post_images"": ""http://clientprojects.info/qa/toastapp/images/uploads/post_images/""
                 }
                 }"*/
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        let image_paths =  response["image_paths"]! as! NSDictionary
                        
                        KEY_PROFILEIMAGE_PATH =  String(format: "%@",image_paths["userprofile"]! as! String)
                        KEY_POST_PATH =  String(format: "%@",image_paths["post_images"]! as! String)
                        KEY_TOAST_PATH =  String(format: "%@",image_paths["toast_images"]! as! String)
                        
                        SVProgressHUD.show(withStatus: "Listing Toast", maskType: .gradient)
                        let device_Token = UserDefaults.standard.value(forKey: KEY_DEVICE_TOKEN)
                        print("device_Token == \(String(describing: device_Token))")
                        self.fetchToastList()
                    })
                }
                else if(statusToken as String == "Error" as String)
                {
                    
                }
            }
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
            SVProgressHUD.dismiss()
        }
        
    }
    
    
    func ClearToastNotificationsCalled( index : Int, callFrom : String)
    {
        /*
         {
         "service": "clearnotification",
         "user_id": "12",
         "access_token": "82936104c3Vib2RoQGFya2VuZWEuY29t",
         "toast_id": "3"
         "clear_flag":"toast"
         
         "list_flag":"" // not required for ToastListing,
         
         }
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            
            //            SVProgressHUD.show(withStatus: "Listing Toast", maskType: .gradient)
            
            
            var toastID = callFrom as String
            
            if (callFrom == "" as String) // call from cell selection
            {
                toastID = (arr_ToastCollectn.object(at: index) as! ToastList).toast_id
            }
            else // call from push notification
            {
                
            }
            
            
          
            let parameters: NSDictionary = ["service": "clearnotification", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : toastID,  "clear_flag":"toast","list_flag":""]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        // Check for count. Update next_offset only if array not empty
                        if toastArray.count > 0
                        {
                            for toast in toastArray
                            {
                                let toastObj:ToastList = ToastList()
                                toastObj.setData(fromDict: toast as! NSDictionary)
                                if(self.arr_ToastCollectn.count > index)
                                {
                                    self.arr_ToastCollectn.replaceObject(at: index, with: toastObj)
                                }
                                if(self.isInitiator_Toast == true)//if initiator btn clicked
                                {
                                    if(self.arr_initiatorCollectn.count > index)
                                    {
                                        self.arr_initiatorCollectn.replaceObject(at: index, with: toastObj)
                                    }
                                }
                                else
                                {
                                    if(self.arr_memberCollectn.count > index)
                                    {
                                        self.arr_memberCollectn.replaceObject(at: index, with: toastObj)
                                    }
                                }
                            }
                        }
                        
                        self.tblView_Toast.reloadData()
                        
                        if (callFrom == "" as String) // call from cell selection
                        {
                            // do stuff
                        }
                        else // call from push notification
                        {
                             self.refreshAllToastList()
                        }
                        
                        //                        self.fetchToastList()
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
    
    func deleteToast(toastIndex:Int)
    {
        /*"{
         ""service"": ""deletetoast"",
         ""user_id"": ""3"",
         ""access_token"": ""S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au"",
         ""toast_id"": ""2""
         }"*/
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "deletetoast", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : (arr_ToastCollectn.object(at: toastIndex) as! ToastList).toast_id]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        self.arr_ToastCollectn.removeObject(at: toastIndex)
                        self.arr_initiatorCollectn.removeObject(at: toastIndex) // remove the copy from arr_initiatorCollectn
                        
                        let offset = Int(self.offset_Initiator) // Dec the offset everytime Toast is Added
                        let finalOffset = offset!-1
                        self.offset_Initiator = String(finalOffset)
                        
                        self.tblView_Toast.reloadData()
                        
                        if(self.arr_ToastCollectn.count > 0)
                        {
                            self.view_noResult.alpha = 0.0
                        }
                        else
                        {
                             self.lbl_noResults.text = kNoToastForInitiator_Msg
                            self.view_noResult.alpha = 1.0
                            self.btn_CreateNewToast.alpha = 1.0 // used as lable for msg
                            self.btn_Plus.isHidden = false
                        }
                        
                        self.selectedIndexPath = nil
                        self.previousIndexPath = nil

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
    
    func ReleaseToast(toastIndex:Int, release:String)
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
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "releasetoast", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : (arr_ToastCollectn.object(at: toastIndex) as! ToastList).toast_id,"release_confirm": release]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        // self.arr_ToastCollectn.removeObject(at: toastIndex)
                        // self.tblView_Toast.reloadData()
                        
                        //notification fired to open diary tab via ToastVC
                        
                        
                        
                        // create object to pass via notification
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        
                        let userInfo = ["newData": toastArray]
                        
                        /*  let appDelegate = UIApplication.shared.delegate as! AppDelegate
                         appDelegate.tabBarController.selectedIndex = 1
                         
                         //SVProgressHUD.showInfo(withStatus: "Toast Released Successfully", maskType: .gradient)
                         
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateDiary_Notification), object: nil, userInfo: userInfo)
                         
                         self.arr_initiatorCollectn.removeObject(at: self.selectedIndexPath.row)
                         
                         if(self.isInitiator_Toast == true)//if initiator btn clicked
                         {
                         self.arr_ToastCollectn.removeObject(at: self.selectedIndexPath.row)
                         }
                         self.tblView_Toast.reloadData()
                         isToastRaised = true
                         */
                        
                        
                        let offset = Int(self.offset_Initiator) // Inc the offset everytime Toast is Added
                        let finalOffset = offset!-1
                        self.offset_Initiator = String(finalOffset)
                        
                        self.handleDiaryUpdates(userInfo as NSDictionary)
                        
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
                            self.favView.indexpath = toastIndex
                            
                            if self.favView.arr_MemberList.count == 1
                            {
                                self.favView.TblView_Hconst.constant = CGFloat((self.favView.arr_MemberList.count * 30) + 70)
                            }
                            else if self.favView.arr_MemberList.count < 5
                            {
                                self.favView.TblView_Hconst.constant = CGFloat(((self.favView.arr_MemberList.count) * 30) + 100)
                            }
                            else
                            {
                                self.favView.TblView_Hconst.constant = CGFloat((5 * 30) + 70)
                            }
                            
                            self.favView.alpha = 1.0
                            
                            self.favView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
                            //self.view.bringSubview(toFront: self.favView)
                            self.view .addSubview(self.favView)
                            
                            self.favView.layoutIfNeeded()
                            self.favView.tblFav.reloadData()
                            UIView .animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                                self.bgView.alpha = 0.3
                                self.favView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                            }, completion: {(value: Bool) in
                                
                                
                                
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
    
    func SendReminderCalled(toastIndex:Int)
    {
        /*
         {
         "service": "sendreminder",
         "user_id": "3",
         "access_token": "HpPeauPUA7Y7beTSF4wtPiZkJTt5sT24",
         "toast_id": "8"
         }
         */
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "sendreminder", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : (arr_ToastCollectn.object(at: toastIndex) as! ToastList).toast_id]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        self.tblView_Toast.reloadData()
                        SVProgressHUD.showInfo(withStatus: "Reminder sent Successfully", maskType: .gradient)
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
    
    override var hidesBottomBarWhenPushed: Bool
        {
        get { return false }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    func refreshAllToastList()
    {
        // Clear all the flags to load fresh data
        self.offset_Initiator = "0"
        self.arr_initiatorCollectn.removeAllObjects()
        
        self.offset_Member = "0"
        self.arr_memberCollectn.removeAllObjects()
        
        
        self.fetchToastList()
    }
    // MARK: - Notification methods
    
    
    func updateToastlist(notification: NSNotification) {
        
        guard let notification1:NSDictionary = notification.userInfo! as NSDictionary? else{
            return
        }
        
        let newData = notification1["newData"] as! NSArray
        
        for toast in newData
        {
            let toastObj:ToastList = ToastList()
            toastObj.setData(fromDict: toast as! NSDictionary)
            if(btn_Member.isSelected == true)
            {
                btn_Initiator.isSelected = true
                lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xffffff)
                btn_Member.isSelected = false
                lbl_MemberBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                
                isInitiator = true
                isInitiator_Toast = isInitiator
                
                
                self.arr_initiatorCollectn.insert(toastObj, at: 0)
                self.arr_ToastCollectn.removeAllObjects()
                self.arr_ToastCollectn = self.arr_initiatorCollectn.mutableCopy() as! NSMutableArray
                /*
                if(self.offset_Initiator.characters.count < 1)if created toast is first toast then increment offset_Initiator count
                {
                    self.offset_Initiator = "1"
                }
 */
                let offset = Int(self.offset_Initiator) // Inc the offset everytime Toast is Added
                let finalOffset = offset!+1
                self.offset_Initiator = String(finalOffset)
                
            }
            else
            {
                
                self.arr_initiatorCollectn.insert(toastObj, at: 0)
                self.arr_ToastCollectn.insert(toastObj, at: 0)
                
                /*
                if(self.offset_Initiator.characters.count < 1)//if created toast is first toast then increment offset_Initiator count
                    
                {
                    self.offset_Initiator = "1"
                }
 */
                
                let offset = Int(self.offset_Initiator) // Inc the offset everytime Toast is Added
                let finalOffset = offset!+1
                self.offset_Initiator = String(finalOffset)
            }
        }
        if(self.arr_ToastCollectn.count > 0)
        {
            
            self.view_noResult.alpha = 0.0
        }
        else
        {
            
            
            if(self.isInitiator_Toast == true)//if initiator btn clicked
            {
                self.view_noResult.alpha = 1.0
                self.lbl_noResults.text = kNoToastForInitiator_Msg
                self.btn_CreateNewToast.alpha = 1.0 // used as lable for msg
                self.btn_Plus.isHidden = false
            }
            else //if collaborator btn clicked
            {
                self.view_noResult.alpha = 1.0
                self.lbl_noResults.text = kNoToastForCollaborator_Msg
                self.btn_CreateNewToast.alpha = 0.0 // used as lable for msg
                self.btn_Plus.isHidden = true
            }

            
        }
        self.tblView_Toast.reloadData()
    }
    
    
    func updateTransferedToastlist(notification: NSNotification) {
        
        guard let notification1:NSDictionary = notification.userInfo! as NSDictionary? else{
            return
        }
        let newData = notification1["newData"] as! NSArray // updated toast data after transfer
        
        for toast in newData
        {
            let toastObj:ToastList = ToastList()
            toastObj.setData(fromDict: toast as! NSDictionary)
            
            
            let offset = Int(self.offset_Member) // Inc the offset everytime Toast is Added
            let finalOffset = offset!+1
            self.offset_Member = String(finalOffset)
            
            
            self.arr_memberCollectn.insert(toastObj, at: 0) // add newData to memeber array after transfer
            if(selectedIndexPath != nil)
            {
                if(self.arr_initiatorCollectn.count > selectedIndexPath.row)
                {
                    self.arr_initiatorCollectn.removeObject(at: selectedIndexPath.row)
                }
            }
            else
            {
                if(self.arr_initiatorCollectn.count > 0)
                {
                    self.arr_initiatorCollectn.removeObject(at: 0)
                }
            }
            
            let offset1 = Int(self.offset_Initiator) // Inc the offset everytime Toast is Added
            let finalOffset1 = offset1!-1
            self.offset_Initiator = String(finalOffset1)
            
            if(self.isInitiator_Toast == true)//if initiator btn clicked
            {
                if(selectedIndexPath != nil)
                {
                    if(self.arr_ToastCollectn.count > selectedIndexPath.row)
                    {
                        self.arr_ToastCollectn.removeObject(at: selectedIndexPath.row)
                    }
                }
                else
                {
                    if(self.arr_ToastCollectn.count > 0)
                    {
                        self.arr_ToastCollectn.removeObject(at: 0)
                    }
                }
            }
            else
            {
                self.arr_ToastCollectn.insert(toastObj, at: 0)
            }
            
        }
        
        if(self.arr_ToastCollectn.count > 0)
        {
            self.view_noResult.alpha = 0.0
        }
        else
        {
            self.view_noResult.alpha = 1.0
        }
        
        previousIndexPath = nil
        
        
        
        self.tblView_Toast.reloadData()
    }
    
    
    /*
    func updateOffset(notification: NSNotification) { // Called when notification is received and needs to update offset
        
        // for CreateNewToast -1 for collab list , ChangeOwnership +1 for Initiator list
        
        
        guard let notification1:NSDictionary = notification.userInfo! as NSDictionary else{
            return
        }
        
        let newData = notification1["newData"] as! NSString
        
        if(newData == "CreateNewToast")
        {
            let offset = Int(self.offset_Member) // Inc the offset everytime Toast is Added
            let finalOffset = offset!+1
            self.offset_Member = String(finalOffset)
        }
        if(newData == "ChangeOwnership")
        {
            let offset = Int(self.offset_Initiator) // Inc the offset everytime Toast is Added
            let finalOffset = offset!+1
            self.offset_Initiator = String(finalOffset)
            
            let offset1 = Int(self.offset_Member) // Inc the offset everytime Toast is Added
            let finalOffset1 = offset1!-1
            self.offset_Member = String(finalOffset1)
        }
        
    
    }
 */

    
     func memberDeleted(notification: NSNotification) {
        
        guard let notification1:NSDictionary = notification.userInfo! as NSDictionary else{
            return
        }
        let newData = notification1["newData"] as! NSArray
        
        for toast in newData
        {
            let toastObj:ToastList = ToastList()
            toastObj.setData(fromDict: toast as! NSDictionary)
            
            if(selectedIndexPath != nil)//if edit post
            {
                if(self.isInitiator_Toast == true)//if initiator btn clicked
                {
                    if(self.arr_initiatorCollectn.count > selectedIndexPath.row)//checking array count is greater than selected index path always to avoid crash
                    {
                        self.arr_initiatorCollectn.replaceObject(at: selectedIndexPath.row, with: toastObj)
                    }
                    if(self.arr_ToastCollectn.count > selectedIndexPath.row)//checking array count is greater than selected index path always to avoid crash
                    {
                        self.arr_ToastCollectn.replaceObject(at: selectedIndexPath.row, with: toastObj)
                    }

                }
                self.tblView_Toast.reloadData()
            }
        }
    }
    
    func updateToastlistMsgCount(notification: NSNotification) {
        
        guard let notification1:NSDictionary = notification.userInfo! as NSDictionary else{
            return
        }
        let newData = notification1["newData"] as! NSArray
        
        for toast in newData
        {
            let toastObj:ToastList = ToastList()
            toastObj.setData(fromDict: toast as! NSDictionary)
            
            if(selectedIndexPath != nil)//if edit post
            {
                if(self.isInitiator_Toast == true)//if initiator btn clicked
                {
                    if(self.arr_initiatorCollectn.count > selectedIndexPath.row)//checking array count is greater than selected index path always to avoid crash
                    {
                        self.arr_initiatorCollectn.replaceObject(at: selectedIndexPath.row, with: toastObj)
                    }
                    if(self.arr_ToastCollectn.count > selectedIndexPath.row)//checking array count is greater than selected index path always to avoid crash
                    {
                        self.arr_ToastCollectn.replaceObject(at: selectedIndexPath.row, with: toastObj)
                    }
                }
                else
                {
                    if(self.arr_memberCollectn.count > selectedIndexPath.row)
                    {
                        self.arr_memberCollectn.replaceObject(at: selectedIndexPath.row, with: toastObj)
                    }
                    if(self.arr_ToastCollectn.count > selectedIndexPath.row)
                    {
                        self.arr_ToastCollectn.replaceObject(at: selectedIndexPath.row, with: toastObj)
                    }
                }
            }
            else//if create toast-> and successively post a message (in this case selectedIndexPath is nil)
            {
                if(self.isInitiator_Toast == true)//if initiator btn clicked
                {
                    if(self.arr_initiatorCollectn.count > 0)
                    {
                        self.arr_initiatorCollectn.replaceObject(at: 0, with: toastObj)
                    }
                    if(self.arr_ToastCollectn.count > 0)
                    {
                        self.arr_ToastCollectn.replaceObject(at: 0, with: toastObj)
                    }
                }
                else
                {
                    if(self.arr_memberCollectn.count > 0)
                    {
                        self.arr_memberCollectn.replaceObject(at: 0, with: toastObj)
                    }
                    if(self.arr_ToastCollectn.count > 0)
                    {
                        self.arr_ToastCollectn.replaceObject(at: 0, with: toastObj)
                    }
                }
            }
        }
        
        if(self.arr_ToastCollectn.count > 0)
        {
            self.view_noResult.alpha = 0.0
        }
        else
        {
            self.view_noResult.alpha = 1.0
        }
        
        self.tblView_Toast.reloadData()
    }
    
    func refreshToastList(notification: NSNotification) {
        SVProgressHUD.show(with: .gradient)
        previousIndexPath = nil
        
        isInitiator = isInitiator_Toast
        
        self.refreshAllToastList()
    }
    func openDiaryTab(notification: NSNotification) {
        
        let toastDict:NSDictionary = notification.userInfo! as NSDictionary
        
        let offset = Int(self.offset_Initiator) // Inc the offset everytime Toast is Added
        let finalOffset = offset!-1
        self.offset_Initiator = String(finalOffset)
        
        self.handleDiaryUpdates(toastDict)
        previousIndexPath = nil
        
    }
    func handleDiaryUpdates(_ userInfo: NSDictionary)
    {
        if(selectedIndexPath != nil)
        {
            if(self.arr_initiatorCollectn.count > self.selectedIndexPath.row)
            {
                self.arr_initiatorCollectn.removeObject(at: self.selectedIndexPath.row)
            }
            
            if(self.isInitiator_Toast == true)//if initiator btn clicked
            {
                if(self.arr_ToastCollectn.count > self.selectedIndexPath.row)
                {
                    self.arr_ToastCollectn.removeObject(at: self.selectedIndexPath.row)
                }
            }
        }
        else
        {
            if(self.arr_initiatorCollectn.count > 0)
            {
                self.arr_initiatorCollectn.removeObject(at: 0)
            }
            
            if(self.isInitiator_Toast == true)//if initiator btn clicked
            {
                if(self.arr_ToastCollectn.count > 0)
                {
                    self.arr_ToastCollectn.removeObject(at: 0)
                }
            }
        }
        
        
      
        
        self.tblView_Toast.reloadData()
        
        if(self.arr_ToastCollectn.count > 0)
        {
            self.view_noResult.alpha = 0.0
        }
        else
        {
            self.view_noResult.alpha = 1.0
        }

        isToastRaised = true
        
        let newData = userInfo["newData"] as! NSArray
        
        for toast in newData
        {
            raisedToastObj = DiaryList()
            raisedToastObj.setData(fromDict: toast as! NSDictionary)
        }
        
        // NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateDiary_Notification), object: nil, userInfo: userInfo as! [String : NSArray])
        
        _ = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(TtoastVC.callOpenDiary), userInfo: nil, repeats: false)
    }
    
    func callOpenDiary()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tabBarController.selectedIndex = 1
    }
    
    //  MARK: handle push notification
    func openChatVC(notification: NSNotification)
    {
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        
        let flag = toastDict["flag"] as! String
        
        if(toastDict["toast_id"] != nil)
        {
            self.selectedToastId = toastDict["toast_id"] as! String
            
            // clear notification indicator
            if(flag ==  "PostNewMessage" as String)
            {
                
                ClearToastNotificationsCalled(index: 0, callFrom: selectedToastId) //  selectedToastId only is used, index not required in this case
            }
            else
            {
                self.refreshAllToastList()
            }

        }
        if(toastDict["toast_title"] != nil)
        {
            self.selectedToastTitle = toastDict["toast_title"] as! String
        }
        
        isAutoOpenViewToastDetails = false
        
        
        
        // check if its PostNewMessage and update the server for readReciept status
        
        
        self.callChatVc()
        
    }
    
    func callChatVc()
    {
        self.performSegue(withIdentifier: "chatVCSeg", sender: self)
        
        isAutoOpenViewToastDetails = false
    }
    
    func openViewToastVCViaChatVC(notification: NSNotification)
    {
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        
        if(toastDict["toast_id"] != nil)
        {
            self.selectedToastId = toastDict["toast_id"] as! String
        }
        if(toastDict["toast_title"] != nil)
        {
            self.selectedToastTitle = toastDict["toast_title"] as! String
        }
        isAutoOpenViewToastDetails = true
        
        if (toastDict["flag"] as! String == "ChangeOwnership")
        {
            isInitiator = true
            btn_Initiator.isSelected = false
            self.offset_Initiator = "0"
            self.arr_initiatorCollectn.removeAllObjects()
            
            // to handle dupliacte entry form Collaborator list
            self.offset_Member = "0"
            self.arr_memberCollectn.removeAllObjects()
            
           // self.arr_ToastCollectn.removeAllObjects() //  to check duplicate entry, commented laer becoz it was emptying the array and causing crash
            
            btn_InitiatorClicked(btn_Initiator)
        }
        else // for CreateNewToast , added member
        {
            // set tag for initiator as false
            isInitiator = false
            btn_Member.isSelected = false
            self.offset_Member = "0"
            self.arr_memberCollectn.removeAllObjects()
            btn_MemberClicked(btn_Member)
        }
        
        self.callChatVc()
    }
    
    // MARK: - Button Methods
    func cancelButtonClicked()  { // for custom pop-up
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.favView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.favView.alpha = 0.0
            self.bgView.alpha = 0.0
        }, completion: {(value: Bool) in
            self.favView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        })
    }
    
    @IBAction func btn_CreateNewToastClicked(_ sender: UIButton) {
        previousIndexPath = nil
        selectedIndexPath = nil
        isInitiator = true
        self.performSegue(withIdentifier: "addOtherDetailsSeg", sender: self)
    }
    
    func continueButtonClicked()  { // for custom pop-up
        
        self.ReleaseToast(toastIndex: self.favView.indexpath, release: "Y")
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.favView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.favView.alpha = 0.0
            self.bgView.alpha = 0.0
        }, completion: {(value: Bool) in
            self.favView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        })
    }
    
    func btn_AddClicked(_ sender: UIButton) {
        previousIndexPath = nil
        selectedIndexPath = nil
        isInitiator = true
        self.performSegue(withIdentifier: "addOtherDetailsSeg", sender: self)
    }
    
    @IBAction func btn_InitiatorClicked(_ sender: ZFRippleButton) {
        if(btn_Initiator.isSelected == false)
        {
            selectedIndexPath = nil
            previousIndexPath = nil
            btn_Initiator.isSelected = true
            lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xffffff)
            btn_Member.isSelected = false
            
            lbl_MemberBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)

            isInitiator = true
            isInitiator_Toast = isInitiator
            
            //uncomment below
            //        self.getAllImageUrls()
            
            SVProgressHUD.show(withStatus: "Listing Toast", maskType: .gradient)
            NSLog("btn_InitiatorClicked and list fetching is called  ****************************************")
            self.fetchToastList()
        }
    }
    
    @IBAction func btn_MemberClicked(_ sender: ZFRippleButton) {
        if(btn_Member.isSelected == false)
        {
            selectedIndexPath = nil
            previousIndexPath = nil
            btn_Initiator.isSelected = false
            lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            btn_Member.isSelected = true
            lbl_MemberBase.backgroundColor =  UIColor(hexCode: 0xffffff)
        
            isInitiator = false
            isInitiator_Toast = isInitiator
            //uncomment below
            SVProgressHUD.show(withStatus: "Listing Toast", maskType: .gradient)
            
            self.fetchToastList()
        }
    }
    
    
    
    // MARK: - Table View Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var valueReturn = 0
        
        if arr_ToastCollectn.count>0
        {
            valueReturn = arr_ToastCollectn.count
        }
        
        return valueReturn
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height * (116.0 / 568.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    //uncomment below
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "ToastsCell"
        var cell:ToastsCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ToastsCell
        if (cell == nil){
            tableView.register(UINib(nibName: "ToastsCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ToastsCell
            cell?.layoutMargins=UIEdgeInsets.zero
            cell?.preservesSuperviewLayoutMargins=false
            cell?.backgroundColor=UIColor.clear
        }
        /*"toast_id": 6,
         "toast_title": "Farewell Toast for Swapnil,Meghna226666!",
         "from_text": "Tea Time Group",
         "category_name": "Farewell",
         "released_date": "2016-11-30 15:30:45",
         "theme": "Wish you all the best!",
         "toast_image": "default.jpg",
         "total_members": "4",
         "message_count": "0",
         "owner_access": true*/
        
        if arr_ToastCollectn.count > indexPath.row
        {
            
            cell?.lbl_EventName.text = (arr_ToastCollectn.object(at: indexPath.row) as! ToastList).toastTitle.Trim()
            
            // Convert to show Emoticons
            
            let str = (arr_ToastCollectn.object(at: indexPath.row) as! ToastList).theme
            let emojData : NSData = str.data(using: String.Encoding.utf8)! as NSData
            let emojString:String = String(data: emojData as Data, encoding: String.Encoding.nonLossyASCII)!
            
            cell?.lbl_GreetingMessage.text = emojString //"Cheers to the birthday celebrant! Be not afraid of again. It only proves how long you have lived on this world and how much you..."
            
            cell?.lbl_PersonName.text = "From \((arr_ToastCollectn.object(at: indexPath.row) as! ToastList).messageSender)"
            
            cell?.lbl_MessageCount.text = "\((arr_ToastCollectn.object(at: indexPath.row) as! ToastList).message_count)/\((arr_ToastCollectn.object(at: indexPath.row) as! ToastList).total_members) Cheers"
            
            let messageDate:String = (arr_ToastCollectn.object(at: indexPath.row) as! ToastList).releasedDate
            
            let toastReleaseDate = daysBetween(endDate: messageDate)
            
            if(toastReleaseDate.characters.count > 0)
            {
                cell?.lbl_MessageTime.text = daysBetween(endDate: messageDate)
            }
            else
            {
                cell?.lbl_MessageTime.text = "N/A"
            }
            
            let eventPhotoUrlStr: String = (arr_ToastCollectn.object(at: indexPath.row) as! ToastList).eventPhotoUrlStr
            
            cell?.imgView_EventImg.image = UIImage(named: "Toast_smallPlaceholder")
           // print("TOAST-IMG : \(eventPhotoUrlStr)")
            
            if(eventPhotoUrlStr.characters.count > 0)
            {
                
               // cell?.imgView_EventImg.image = UIImage(named: "Toast_smallPlaceholder")
                let toastURL: URL = URL(string: eventPhotoUrlStr)!
                let manager:SDWebImageManager = SDWebImageManager.shared()
                manager.downloadImage(with: toastURL, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                    let aspectScaledToFillImage = image?.af_imageAspectScaled(toFill: (cell?.imgView_EventImg.frame.size)!)
                    cell?.imgView_EventImg.image = aspectScaledToFillImage
                })
            }
         //   else
          //  {
          //      cell?.imgView_EventImg.image = UIImage(named: "Toast_smallPlaceholder")
        //    }
            
            //        cell?.btn_Follow.setImage(UIImage(named: (arr_ToastCollectn.object(at: indexPath.row)as! NSDictionary).value(forKey: "followUser") as! String), for: .normal)
            
            if ((arr_ToastCollectn.object(at: indexPath.row) as! ToastList).blue_dot_flag != "0")
            {
                cell?.imgView_messageIndicator.isHidden = false
            }
            else
            {
                cell?.imgView_messageIndicator.isHidden = true
            }
            
            
            // For NO user POST in toast
            if((arr_ToastCollectn.object(at: indexPath.row) as! ToastList).no_message_flag == "1")
            { // Highlight Cell
                cell?.view_Bg.backgroundColor = UIColor(hexCode: 0xFCF5E2).withAlphaComponent(0.2)
                cell?.view_Bg.layer.borderWidth = 1.0
                cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xa38c47).cgColor
                cell?.view_Bg.layer.cornerRadius = 2.0
                cell?.view_Bg.clipsToBounds = true
                cell?.separatorLine.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            }
            else
            {
                cell?.view_Bg.backgroundColor = UIColor.white
                cell?.view_Bg.layer.borderWidth = 1.0
                cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
                cell?.view_Bg.layer.cornerRadius = 2.0
                cell?.view_Bg.clipsToBounds = true
                cell?.separatorLine.backgroundColor = UIColor(hexCode: 0xE8E8E8)
            }
            
        }
        
        // for cell selection heighlight
        
        if(previousIndexPath != nil)
        {
            if(previousIndexPath.compare(indexPath) == .orderedSame)
            {
                //                        cell?.view_Bg.backgroundColor = UIColor(hexCode: 0xFCF5E2).withAlphaComponent(0.2)
                cell?.view_Bg.backgroundColor = UIColor.white
                cell?.view_Bg.layer.borderWidth = 1.0
                cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xa38c47).cgColor
                cell?.view_Bg.layer.cornerRadius = 2.0
                cell?.view_Bg.clipsToBounds = true
                //                        cell?.separatorLine.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            }
            else
            {
                cell?.view_Bg.backgroundColor = UIColor.white
                cell?.view_Bg.layer.borderWidth = 1.0
                cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
                cell?.view_Bg.layer.cornerRadius = 2.0
                cell?.view_Bg.clipsToBounds = true
                //                        cell?.separatorLine.backgroundColor = UIColor(hexCode: 0xE8E8E8)
            }
        }
        else
        {
            cell?.view_Bg.backgroundColor = UIColor.white
            cell?.view_Bg.layer.borderWidth = 1.0
            cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
            cell?.view_Bg.layer.cornerRadius = 2.0
            cell?.view_Bg.clipsToBounds = true
            //                    cell?.separatorLine.backgroundColor = UIColor(hexCode: 0xE8E8E8)
        }
        
        
        
        cell?.selectionStyle = .none
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ToastsCell
        //                        cell.view_Bg.backgroundColor = UIColor(hexCode: 0xFCF5E2)
        
        //        cell.view_Bg.backgroundColor = UIColor.white
        cell.view_Bg.layer.borderWidth = 1.0
        cell.view_Bg.layer.borderColor = UIColor(hexCode: 0xa38c47).cgColor
        cell.view_Bg.layer.cornerRadius = 2.0
        cell.view_Bg.clipsToBounds = true
        //                        cell.separatorLine.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        
        if(previousIndexPath != nil && indexPath.compare(previousIndexPath as IndexPath) != .orderedSame)
        {
            let preVIndexPath = previousIndexPath.copy() as! NSIndexPath
            previousIndexPath = indexPath as NSIndexPath
            tableView.reloadRows(at: [preVIndexPath as IndexPath], with: .none)
        }
        
        previousIndexPath = indexPath as NSIndexPath
        
        kSelectedToast_Id = ("\((arr_ToastCollectn.object(at: indexPath.row) as! ToastList).toast_id)")
        
        if ((arr_ToastCollectn.object(at: indexPath.row) as! ToastList).blue_dot_flag != "0")
        {
            ClearToastNotificationsCalled(index: indexPath.row, callFrom: "")
        }
        
        self.selectedToastId = (self.arr_ToastCollectn.object(at: (self.tblView_Toast.indexPathForSelectedRow?.row)!) as! ToastList).toast_id
        self.selectedToastTitle = (self.arr_ToastCollectn.object(at: (self.tblView_Toast.indexPathForSelectedRow?.row)!) as! ToastList).toastTitle
                selectedIndexPath = indexPath as NSIndexPath
        
        
        
        let pictureUrl = (self.arr_ToastCollectn.object(at: (self.tblView_Toast.indexPathForSelectedRow?.row)!) as! ToastList).eventPhotoUrlStr
        
        let messageCount = Int((self.arr_ToastCollectn.object(at: (self.tblView_Toast.indexPathForSelectedRow?.row)!) as! ToastList).message_count)
        
        let totalMembers = Int((self.arr_ToastCollectn.object(at: (self.tblView_Toast.indexPathForSelectedRow?.row)!) as! ToastList).total_members)

        let def = UserDefaults.standard
        def.setValue(pictureUrl, forKey: "pictureurl")
        def.setValue(false, forKey: "showMessage")
        if (messageCount! / totalMembers!) == 1
        {
            def.setValue(true, forKey: "popup")
        }
        else
        {
            def.setValue(false, forKey: "popup")
        }
       
        self.performSegue(withIdentifier: "chatVCSeg", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if arr_ToastCollectn.count > indexPath.row // show edit optn if initiator
        {
            let buttonMore = UITableViewRowAction(style: .default, title: "         ") { action, indexPath in
                // Handle style-sheet send Reminder
                func handleReminder(_ alertView: UIAlertAction!)
                {
                    // Alert for send Reminder
                    self.dismiss(animated: true, completion: nil)
                    
                    func handleSend(_ alertView: UIAlertAction!)
                    {
                        self.dismiss(animated: true, completion: nil)
                        
                        self.SendReminderCalled(toastIndex: indexPath.row)
                    }
                    func handleCancel(_ alertView: UIAlertAction!)
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    let alert = UIAlertController(title: nil, message: kSendReminderToAll, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:handleSend))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                    
                    alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                // Handle style-sheet Raise Toast
                func handleRelease(_ alertView: UIAlertAction!)
                {
                    self.selectedIndexPath = indexPath as NSIndexPath
                    self.ReleaseToast(toastIndex: indexPath.row, release: "")
                    
                }
                
                // Open style sheet
                func handleCancel(_ alertView: UIAlertAction!)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                
                let alert = UIAlertController(title: "Select Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                alert.addAction(UIAlertAction(title: "Send Reminder", style: UIAlertActionStyle.default, handler:handleReminder))
                alert.addAction(UIAlertAction(title: "Raise Toast", style: UIAlertActionStyle.default, handler:handleRelease))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler:handleCancel))
                
                alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                self.present(alert, animated: true, completion: nil)
            }
            
            //Delete
            let buttonDelete = UITableViewRowAction(style: .default, title: "         ") { action, indexPath in
                //uncomment below
                
                func handleDelete(_ alertView: UIAlertAction!)
                {
                    self.dismiss(animated: true, completion: nil)
                    self.deleteToast(toastIndex: indexPath.row)
                }
                func handleCancel(_ alertView: UIAlertAction!)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                
                let alert = UIAlertController(title: nil, message: kDeleteToast, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler:handleDelete))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                
                alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                self.present(alert, animated: true, completion: nil)
                
            }
            
            if(UIScreen.main.bounds.size.height == 667)
            {
                buttonMore.backgroundColor = UIColor(patternImage: UIImage(named: "ic-more@270")!)
                
                buttonDelete.backgroundColor = UIColor(patternImage: UIImage(named: "ic-delete@270")!)
                
            }
            else
            {
                buttonMore.backgroundColor = UIColor(patternImage: UIImage(named: "ic-more@232")!)
                
                buttonDelete.backgroundColor = UIColor(patternImage: UIImage(named: "ic-delete@232")!)
                
            }
            
            return [buttonDelete, buttonMore]
            
        }
        else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        var returnBool = false
        
        if(isInitiator_Toast == true)//if initiator btn clicked
        {
            returnBool = true
        }
        else
        {
            returnBool = false
        }
        
        return returnBool
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "chatVCSeg")
        {
            if let chatVC: TChatViewController = segue.destination as? TChatViewController {
                chatVC.screenTag = 2 // 2 for Toast screen, 1 for diary screen
                //uncomment below
                chatVC.selectedToastId = self.selectedToastId
                chatVC.selectedToast_Title = self.selectedToastTitle
                chatVC.isAutoOpenViewToastDetails = self.isAutoOpenViewToastDetails
            }
        }
    }
    
    
    
    //  // MARK: -  Badge Notification Positioning
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
}

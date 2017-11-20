//
//  TSecondViewController.swift
//  Toast
//
//  Created by Anish Pandey on 07/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import SDWebImage


class TDiaryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btn_Initiator: ZFRippleButton!
    @IBOutlet weak var btn_Toastee: ZFRippleButton!
    @IBOutlet weak var btn_Member: ZFRippleButton!
    
    @IBOutlet weak var lbl_InitiatorBase: UILabel!
    @IBOutlet weak var lbl_MemberBase: UILabel!
    @IBOutlet weak var lbl_ToasteeBase: UILabel!
    
    @IBOutlet weak var tblView_Diary: UITableView!
    
    var arr_DiaryCollectn:NSMutableArray = NSMutableArray()
    
    var arr_initiatorCollectn:NSMutableArray = NSMutableArray()
    var arr_toasteeCollectn:NSMutableArray = NSMutableArray()
    var arr_memberCollectn:NSMutableArray = NSMutableArray()
    
    var userFlag: String = String() // initiator , toastee , member
    
    var offset_Initiator: String = String() // to call data in group for initiator
    var offset_Toastee: String = String() // to call data in group for toastee
    var offset_Member: String = String() // to call data in group for member
    
    
    var selectedToastId:String = String()
    var selectedToast_Title : String = String()
    var isAutoOpenViewToastDetails:Bool = false // set flag for push notifications
    
    
    @IBOutlet weak var lbl_noResults: UILabel!
    var previousIndexPath:NSIndexPath!
    
    @IBOutlet weak var view_noResult: UIView!
    @IBOutlet weak var btn_NoResultRaiseToast: UIButton!
    
    func addInfiniteScrollHander(){
        self.tblView_Diary.addInfiniteScroll { (scrollView) -> Void in
            if WebService.isFinish == true
            {
                self.fetchDiaryList()
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
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Diary list...")
        
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
                    if(self.userFlag == "initiator")
                    {
                        self.offset_Initiator = ""
                        self.arr_initiatorCollectn.removeAllObjects()
                    }
                    else if(self.userFlag == "member")
                    {
                        self.offset_Member = ""
                        self.arr_memberCollectn.removeAllObjects()
                    }
                    else if(self.userFlag == "toastee")
                    {
                        self.offset_Toastee = ""
                        self.arr_toasteeCollectn.removeAllObjects()
                    }
                    SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
                    self.fetchDiaryList()
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
        
        self.CustomiseView()
        
        self.tblView_Diary.addSubview(self.refreshControl)
        
        self.addInfiniteScrollHander()
        
        userFlag = "toastee"
        SVProgressHUD.show(withStatus: "Listing Diary", maskType: .gradient)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TDiaryVC.refreshDiaryList), name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TDiaryVC.updateDiaryList), name: NSNotification.Name(rawValue: kUpdateDiary_Notification), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        //       self.tabBarController?.setBadges(badgeValues: [101,0])
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.addBadge(index: 1, value: 0, color: UIColor.clear, font: UIFont(name: "Helvetica-Light", size: 11)!)
        
        isInitiator = false
        if(isToastRaised == false)
        {
            fetchDiaryList()
        }
        else if(raisedToastObj != nil)//if saved raised toast locally
        {
            if(self.arr_DiaryCollectn.count > 0)//if fetchedDiary has called and just have to add new toast in diary list
            {
                self.arr_initiatorCollectn.insert(raisedToastObj, at: 0)
                
                self.userFlag = "initiator"
                
                if(self.userFlag == "initiator")
                {
                    self.arr_DiaryCollectn.insert(raisedToastObj, at: 0)
                }
                
                btn_Initiator.isSelected = true
                lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xffffff)
                btn_Member.isSelected = false
                lbl_MemberBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                btn_Toastee.isSelected = false
                lbl_ToasteeBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                
                if(self.arr_DiaryCollectn.count > 0)
                {
                    self.view_noResult.alpha = 0.0
                }
                self.tblView_Diary.reloadData()
            }
            else//if no toast in diary and when fetchDiary has not called yet
            {
                self.userFlag = "initiator"
                btn_Initiator.isSelected = true
                lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xffffff)
                btn_Member.isSelected = false
                lbl_MemberBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                btn_Toastee.isSelected = false
                lbl_ToasteeBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                
                if(self.arr_DiaryCollectn.count > 0)
                {
                    self.view_noResult.alpha = 0.0
                }
                
                fetchDiaryList()
            }
            raisedToastObj = nil
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kUpdateDiary_Notification), object: nil)
        
    }

    
    func CustomiseView()
    {
        self.view_noResult.alpha = 0.0
       // self.navigationItem.titleView = getNavigationTitle(inputStr: "\(UserDefaults.standard.value(forKey: KEY_FIRST_NAME)!) \(UserDefaults.standard.value(forKey: KEY_LAST_NAME)!)")
        self.navigationItem.titleView = getNavigationTwoTitles(inputStr1:kNavigationTitleDairyTab , inputStr2: kNavigationTitleSmallDairyTab)
       
        if(isToastRaised == false)
        {
            btn_Toastee.isSelected = true
            lbl_ToasteeBase.backgroundColor = UIColor(hexCode: 0xffffff)
        }
        
        
    }
    
    func animateTable() {
        tblView_Diary.reloadData()
        
        let cells = tblView_Diary.visibleCells
        let tableHeight: CGFloat = tblView_Diary.bounds.size.height
        
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
    
    // MARK: - Button Actions
    @IBAction func btn_InitiatorClicked(_ sender: ZFRippleButton) {
        if(btn_Initiator.isSelected == false)
        {
            previousIndexPath = nil
            isToastRaised = false
            userFlag = "initiator"
            isInitiator = false
            
            btn_Initiator.isSelected = true
            lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xffffff)
            btn_Member.isSelected = false
            lbl_MemberBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            btn_Toastee.isSelected = false
            lbl_ToasteeBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            SVProgressHUD.show(withStatus: "Listing Diary", maskType: .gradient)
            
            fetchDiaryList()
        }
    }
    @IBAction func btn_MemberClicked(_ sender: ZFRippleButton) {
        if(btn_Member.isSelected == false)
        {
            previousIndexPath = nil
            userFlag = "member"
            isInitiator = false
            
            btn_Initiator.isSelected = false
            lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            btn_Member.isSelected = true
            lbl_MemberBase.backgroundColor = UIColor(hexCode: 0xffffff)
            btn_Toastee.isSelected = false
            lbl_ToasteeBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            
            SVProgressHUD.show(withStatus: "Listing Diary", maskType: .gradient)
            
            fetchDiaryList()
        }
    }
    @IBAction func btn_ToasteeClicked(_ sender: ZFRippleButton) {
        if(btn_Toastee.isSelected == false)
        {
            previousIndexPath = nil
            userFlag = "toastee"
            isInitiator = false
            
            btn_Initiator.isSelected = false
            lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            btn_Toastee.isSelected = true
            lbl_ToasteeBase.backgroundColor = UIColor(hexCode: 0xffffff)
            btn_Member.isSelected = false
            lbl_MemberBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            SVProgressHUD.show(withStatus: "Listing Diary", maskType: .gradient)
            
            fetchDiaryList()
        }
    }
    
    @IBAction func btn_NoResultRaiseToastClicked(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    // MARK: - Notification handling
    
    func updateDiaryList(notification: NSNotification) {
        
        previousIndexPath = nil
        guard let notification1:NSDictionary = notification.userInfo! as NSDictionary? else{
            return
        }
        
        let newData = notification1["newData"] as! NSArray
        
        for toast in newData
        {
            let toastObj:DiaryList = DiaryList()
            toastObj.setData(fromDict: toast as! NSDictionary)
            
            self.arr_initiatorCollectn.insert(toastObj, at: 0)
            
            self.userFlag = "initiator"
            
            if(self.userFlag == "initiator")
            {
                self.arr_DiaryCollectn.insert(toastObj, at: 0)
            }
            
        }
        
        btn_Initiator.isSelected = true
        lbl_InitiatorBase.backgroundColor = UIColor(hexCode: 0xffffff)
        btn_Member.isSelected = false
        lbl_MemberBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        btn_Toastee.isSelected = false
        lbl_ToasteeBase.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        
        if(self.arr_DiaryCollectn.count > 0)
        {
            self.view_noResult.alpha = 0.0
        }
        
        
        self.tblView_Diary.reloadData()
    }
    
    func refreshDiaryList(notification: NSNotification) { // called for raised toast
        
        previousIndexPath = nil
        
        let toastDict:NSDictionary = notification.object! as! NSDictionary
        
        if(toastDict["toast_id"] != nil)
        {
            self.selectedToastId = toastDict["toast_id"] as! String
            ClearDiaryNotificationsCalled(index: 0, callFrom: selectedToastId) //  selectedToastId is used, index not required in this case
        }

        if(self.userFlag == "member")
        {
            self.offset_Member = ""
            self.arr_memberCollectn.removeAllObjects()
        }
        else if(self.userFlag == "toastee")
        {
            self.offset_Toastee = ""
            self.arr_toasteeCollectn.removeAllObjects()
        }
        
        // check for user flag
        
        if(toastDict["access_flag"] != nil)
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            
            if(toastDict["access_flag"] as! String == "member")
            {
                btn_Member.isSelected = false

                // add delay to update read receipt status at server
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.btn_MemberClicked(self.btn_Member)
                }
                
            }
            else if(toastDict["access_flag"] as! String == "toastee")
            {
                self.offset_Toastee = ""
                btn_Toastee.isSelected = false
                
                 // add delay to update read receipt status at server
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.btn_ToasteeClicked(self.btn_Toastee)
                }

            }
            
            selectedToastId = toastDict["toast_id"] as! String
            selectedToast_Title = toastDict["toast_title"] as! String
            
            self.callChatVc()
        }
        
    }
    
    func callChatVc()
    {
        self.performSegue(withIdentifier: "chatVCSeg", sender: self)
        
        isAutoOpenViewToastDetails = false
    }
    
    
    
    func removeDuplicate(dataArray : NSMutableArray) -> NSMutableArray {
        
//        let filteredArray : NSMutableArray = NSMutableArray()
//        for dupObj in dataArray
//        {
//            if !filteredArray.contains(dupObj) {
//                filteredArray.add(dupObj)
//                print(" added ID **  \((dupObj as! DiaryList).toast_id)")
//            }
//            else
//            {
//                print("Duplicate found ************************************************************  \((dupObj as! DiaryList).toast_id)")
//            }
//        }
//        
//        return filteredArray
        
        let unique : NSMutableArray = NSMutableArray()
        var seen = Set<String>()
        // var unique = [DiaryList]()
        for message in dataArray {
            if !seen.contains((message as! DiaryList).toast_id) {
                unique.add(message as! DiaryList)
                seen.insert((message as! DiaryList).toast_id)
            }
        }
        
        return unique

    }
    
    
    // MARK: - WS Call
    func fetchDiaryList()
    {
        /*
         {
         "service": "diary",
         "user_id": "14",
         "access_token": "95423870c3dhcG5pbEBhcmtlbmVhLmNvbQ==",
         "list_flag": ""
         "offset":"1"
         }
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            
            // Check and set offSet for WS call
            var offset =  ""
            if(self.userFlag == "initiator")
            {
//                offset = self.offset_Initiator
                
                offset = String(arr_initiatorCollectn.count)
                
                /*
                 if offset == "1"
                 {
                 self.arr_initiatorCollectn.removeAllObjects()
                 }
                 */
            }
            else if(self.userFlag == "member")
            {
//                offset = self.offset_Member
                
                offset = String(arr_memberCollectn.count)
                /*
                 if offset == "1"
                 {
                 self.arr_memberCollectn.removeAllObjects()
                 }
                 */
            }
            else if(self.userFlag == "toastee")
            {
//                offset = self.offset_Toastee
                
                offset = String(arr_toasteeCollectn.count)
                
                /*
                 if offset == "1"
                 {
                 self.arr_toasteeCollectn.removeAllObjects()
                 }
                 */
            }

            let parameters: NSDictionary = ["service": "diary", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "list_flag" : userFlag, "offset":offset]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                self.tblView_Diary.finishInfiniteScroll()
                if(self.refreshControl.isRefreshing)
                {
                    self.refreshControl.endRefreshing()
                }
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    let next_offset:NSString = NSString(format: "%@",response["next_offset"]! as! NSString)
                    
                    
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        let diaryArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        if(diaryArray.count > 0)
                        {
                            // Check for count. Update next_offset only if array not empty
                            self.view_noResult.alpha = 0.0
                            for toast in diaryArray
                            {
                                let diaryObj:DiaryList = DiaryList()
                                diaryObj.setData(fromDict: toast as! NSDictionary)
                                
                                if(self.userFlag == "initiator")
                                {
                                    self.arr_initiatorCollectn.add(diaryObj)
                                }
                                else if(self.userFlag == "member")
                                {
                                    self.arr_memberCollectn.add(diaryObj)
                                }
                                else if(self.userFlag == "toastee")
                                {
                                    self.arr_toasteeCollectn.add(diaryObj)
                                }
                            }
                            
                            
                            
                            // Make a copy of array
                            var dataArrayInitiator : NSMutableArray = NSMutableArray()
                            var dataArrayMember : NSMutableArray = NSMutableArray()
                             var dataArrayToastee : NSMutableArray = NSMutableArray()
                            
                            
                            dataArrayInitiator = self.arr_initiatorCollectn.mutableCopy() as! NSMutableArray
                            dataArrayMember = self.arr_memberCollectn.mutableCopy() as! NSMutableArray
                            dataArrayToastee = self.arr_toasteeCollectn.mutableCopy() as! NSMutableArray
                            
                            self.arr_initiatorCollectn.removeAllObjects()
                            self.arr_memberCollectn.removeAllObjects()
                            self.arr_toasteeCollectn.removeAllObjects()
                            
                            //remove duplicate elemets from array
                            self.arr_initiatorCollectn = self.removeDuplicate(dataArray: dataArrayInitiator)
                            self.arr_memberCollectn = self.removeDuplicate(dataArray: dataArrayMember)
                            self.arr_toasteeCollectn = self.removeDuplicate(dataArray: dataArrayToastee)
                            
                            
                            
                            // Clear and copy to main array for display
                            self.arr_DiaryCollectn.removeAllObjects()
                            
                            if(self.userFlag == "initiator")
                            {
                                self.offset_Initiator = next_offset as String
                                self.arr_DiaryCollectn = self.arr_initiatorCollectn.mutableCopy() as! NSMutableArray
                            }
                            else if(self.userFlag == "member")
                            {
                                self.offset_Member = next_offset as String
                                self.arr_DiaryCollectn = self.arr_memberCollectn.mutableCopy() as! NSMutableArray
                            }
                            else if(self.userFlag == "toastee")
                            {
                                self.offset_Toastee = next_offset as String
                                self.arr_DiaryCollectn = self.arr_toasteeCollectn.mutableCopy() as! NSMutableArray
                            }
                        }
                        else{
                            
                            // Clear and copy to main array for display
                            self.arr_DiaryCollectn.removeAllObjects()
                            
                            if(self.userFlag == "initiator")
                            {
                                self.arr_DiaryCollectn = self.arr_initiatorCollectn.mutableCopy() as! NSMutableArray
                                if(self.arr_DiaryCollectn.count < 1)
                                {
                                    self.view_noResult.alpha = 1.0
                                    self.lbl_noResults.text = kNoRaisedToastForInitiator_MsgNew;
                                    self.btn_NoResultRaiseToast.alpha = 1.0
                                }
                                else
                                {
                                    self.view_noResult.alpha = 0.0
                                }
                            }
                            else if(self.userFlag == "member")
                            {
                                self.arr_DiaryCollectn = self.arr_memberCollectn.mutableCopy() as! NSMutableArray
                                if(self.arr_DiaryCollectn.count < 1)
                                {
                                    self.view_noResult.alpha = 1.0
                                    self.lbl_noResults.text =  kNoRaisedToastForCollaborator_MsgNew
                                    self.btn_NoResultRaiseToast.alpha = 0.0
                                }
                                else
                                {
                                    self.view_noResult.alpha = 0.0
                                }
                            }
                            else if(self.userFlag == "toastee")
                            {
                                self.arr_DiaryCollectn = self.arr_toasteeCollectn.mutableCopy() as! NSMutableArray
                                if(self.arr_DiaryCollectn.count < 1)
                                {
                                    self.view_noResult.alpha = 1.0
                                    self.lbl_noResults.text = kNoRaisedToastForToastee_MsgNew //kNoRaisedToastForToastee_Msg
                                    self.btn_NoResultRaiseToast.alpha = 0.0
                                }
                                else
                                {
                                    self.view_noResult.alpha = 0.0
                                }
                            }
                            
                        }
                        
//                        //remove duplicate elemets from array
//                        let orderedSet:NSOrderedSet = NSOrderedSet(array: self.arr_DiaryCollectn as [AnyObject])
//                        let arrayWithoutDuplicates:NSArray = orderedSet.array as NSArray
//                        self.arr_DiaryCollectn = arrayWithoutDuplicates.mutableCopy() as! NSMutableArray
                        
                        
                        self.tblView_Diary.reloadData()
                        
                        
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
    
    func ClearDiaryNotificationsCalled( index : Int, callFrom : String)
    {
        /*
         {
         "service": "clearnotification",
         "user_id": "12",
         "access_token": "82936104c3Vib2RoQGFya2VuZWEuY29t",
         "toast_id": "3"
         "clear_flag":"diary"
         "list_flag":"initiator" //  required for Diary Listing,
         }
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            
            var toastID = callFrom as String
            
            if (callFrom == "" as String) // call from cell selection
            {
                toastID = (arr_DiaryCollectn.object(at: index) as! DiaryList).toast_id
            }
            else // call from push notification
            {
                
            }

            
            
            var list_flag = ""
            
            if(self.userFlag == "initiator")
            {
                list_flag = "initiator"
            }
            else if(self.userFlag == "member")
            {
                list_flag = "member"
            }
            else if(self.userFlag == "toastee")
            {
                list_flag = "toastee"
            }
            
            
            //            SVProgressHUD.show(withStatus: "Listing Toast", maskType: .gradient)
            
            let parameters: NSDictionary = ["service": "clearnotification", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : toastID, "clear_flag":"diary","list_flag":list_flag]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        let diaryArray:NSArray = (response["toast_list"] as! NSArray)
                        if diaryArray.count > 0
                        {
                            for toast in diaryArray
                            {
                                let diaryObj:DiaryList = DiaryList()
                                diaryObj.setData(fromDict: toast as! NSDictionary)
                                
                                if(self.arr_DiaryCollectn.count > index)
                                {
                                    self.arr_DiaryCollectn.replaceObject(at: index, with: diaryObj)
                                }
                                
                                if(self.userFlag == "initiator")
                                {
                                    if(self.arr_initiatorCollectn.count > index)
                                    {
                                        self.arr_initiatorCollectn.replaceObject(at: index, with: diaryObj)
                                    }
                                }
                                else if(self.userFlag == "member")
                                {
                                    if(self.arr_memberCollectn.count > index)
                                    {
                                        self.arr_memberCollectn.replaceObject(at: index, with: diaryObj)
                                    }
                                }
                                else if(self.userFlag == "toastee")
                                {
                                    if(self.arr_toasteeCollectn.count > index)
                                    {
                                        self.arr_toasteeCollectn.replaceObject(at: index, with: diaryObj)
                                    }
                                }
                            }
                        }
                        
                        self.tblView_Diary.reloadData()
                        //                        self.fetchDiaryList()
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
    
    
    // MARK: - Table View Delegate and Datasource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_DiaryCollectn.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //  let aspectRatio = 118.0/UIScreen.main.bounds.size.height
        return UIScreen.main.bounds.size.height * (116.0 / 568.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        var rotation: CATransform3D
        //        rotation = CATransform3DMakeRotation((90.0 * .pi) / 180, 0.0, 0.7, 0.4)
        //        rotation.m34 = 1.0 / -600
        //        cell.layer.transform = rotation
        //        cell.layer.shadowColor = UIColor.black.cgColor
        //        cell.layer.shadowOffset = CGSize(width: 10, height: 10)
        //        cell.alpha = 0
        //        //    cell.layer.anchorPoint = CGPointMake(0, 0.5);
        //        UIView.beginAnimations("rotation", context: nil)
        //        UIView.setAnimationDuration(0.8)
        //        cell.layer.transform = CATransform3DIdentity
        //        cell.alpha = 1
        //        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        //        UIView.commitAnimations()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cellIdentifier:String = "DiaryCell"
        var cell:DiaryCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? DiaryCell
        if (cell == nil){
            tableView.register(UINib(nibName: "DiaryCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? DiaryCell
            cell?.layoutMargins=UIEdgeInsets.zero
            cell?.preservesSuperviewLayoutMargins=false
            cell?.backgroundColor=UIColor.clear
        }
        
        if(UIScreen.main.bounds.size.height == 568)
        {
            cell?.arrow_leftspacing.constant = 10.0
            cell?.contentView.layoutIfNeeded()
        }
        
        
        
        cell?.lbl_EventName.text = (arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).toastTitle.Trim()
        
        // Convert to show Emoticons
        
       // let str = (arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).messageText
        let str = (arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).theme
        let emojData : NSData = str.data(using: String.Encoding.utf8)! as NSData
        let emojString:String = String(data: emojData as Data, encoding: String.Encoding.nonLossyASCII)!
        
        cell?.lbl_GreetingMessage.text = emojString //"Cheers to the birthday celebrant! Be not afraid of again. It only proves how long you have lived on this world and how much you..."
        
        cell?.lbl_PersonName.text = "From \((arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).fromText)"
        
        cell?.lbl_MessageCount.text = "\((arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).message_count) Cheers"
        
        let messageDate:String = (arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).releasedDate
        
        cell?.lbl_MessageTime.text = dateForDiary(endDate: messageDate)
        
        let eventPhotoUrlStr: String = (arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).eventPhotoUrlStr
        
        cell?.imgView_EventImg.image = UIImage(named: "Toast_smallPlaceholder")
        
        if(eventPhotoUrlStr.characters.count > 0)
        {
            let toastURL: URL = URL(string: eventPhotoUrlStr)!
            let manager:SDWebImageManager = SDWebImageManager.shared()
            manager.downloadImage(with: toastURL, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                let aspectScaledToFillImage = image?.af_imageAspectScaled(toFill: (cell?.imgView_EventImg.frame.size)!)
                cell?.imgView_EventImg.image = aspectScaledToFillImage
            })
        }
        else
        {
            cell?.imgView_EventImg.image = UIImage(named: "Toast_smallPlaceholder")
        }
        
        //show toastee image
        if(userFlag == "initiator")
        {
            cell?.imgView_messageSendrType.image = UIImage(named: "ic_InitiatorYellow")
        }
        else if(userFlag == "member")
        {
            cell?.imgView_messageSendrType.image = UIImage(named: "ic_member blue bcknd")
        }
        else if(userFlag == "toastee")
        {
            cell?.imgView_messageSendrType.image = UIImage(named: "ic_toastee pin backgrond")
        }
        
        
        if ((arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).blue_dot_flag != "0")
        {
            cell?.imgView_messageIndicator.isHidden = false
        }
        else
        {
            cell?.imgView_messageIndicator.isHidden = true
        }
        
        
        
        // For static UI
        
        /*
         cell?.lbl_EventName.text = (arr_DiaryCollectn.object(at: indexPath.row)as! NSDictionary).value(forKey: "eventName") as! String?
         cell?.lbl_GreetingMessage.text = (arr_DiaryCollectn.object(at: indexPath.row)as! NSDictionary).value(forKey: "eventMessage") as! String?
         cell?.lbl_PersonName.text = (arr_DiaryCollectn.object(at: indexPath.row)as! NSDictionary).value(forKey: "messageSender") as! String?
         cell?.lbl_MessageTime.text = (arr_DiaryCollectn.object(at: indexPath.row)as! NSDictionary).value(forKey: "MessageTime") as! String?
         cell?.lbl_MessageCount.text = (arr_DiaryCollectn.object(at: indexPath.row)as! NSDictionary).value(forKey: "MessageCount") as! String?
         
         if indexPath.row == 0
         {
         cell?.imgView_messageIndicator.isHidden = false
         }
         else
         {
         cell?.imgView_messageIndicator.isHidden = true
         }
         
         let compressed_Image = UIImage(named: (arr_DiaryCollectn.object(at: indexPath.row)as! NSDictionary).value(forKey: "eventPhoto") as! String)
         
         
         cell?.imgView_EventImg.image = compressed_Image?.imageWithImageInSize(compressed_Image!)
         
         cell?.imgView_messageSendrType.image = UIImage(named: (arr_DiaryCollectn.object(at: indexPath.row)as! NSDictionary).value(forKey: "messageSender_Type") as! String)
         
         */
        
        if(previousIndexPath != nil)
        {
            if(previousIndexPath.compare(indexPath) == .orderedSame)
            {
                cell?.view_Bg.backgroundColor = UIColor(hexCode: 0xFCF5E2)
                cell?.view_Bg.layer.borderWidth = 1.0
                cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xa38c47).cgColor
                cell?.view_Bg.layer.cornerRadius = 2.0
                cell?.view_Bg.clipsToBounds = true
                cell?.separatorLine.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                cell?.imgView_arrow.image = UIImage(named: "ic_arrowSelected")
                
            }
            else
            {
                cell?.view_Bg.backgroundColor = UIColor.white
                cell?.view_Bg.layer.borderWidth = 1.0
                cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
                cell?.view_Bg.layer.cornerRadius = 2.0
                cell?.view_Bg.clipsToBounds = true
                cell?.separatorLine.backgroundColor = UIColor(hexCode: 0xE8E8E8)
                cell?.imgView_arrow.image = UIImage(named: "ic_cell_arrow")
            }
        }
        else
        {
            cell?.view_Bg.backgroundColor = UIColor.white
            cell?.view_Bg.layer.borderWidth = 1.0
            cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
            cell?.view_Bg.layer.cornerRadius = 2.0
            cell?.view_Bg.clipsToBounds = true
            cell?.separatorLine.backgroundColor = UIColor(hexCode: 0xE8E8E8)
            cell?.imgView_arrow.image = UIImage(named: "ic_cell_arrow")
        }
        cell?.selectionStyle = .none
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! DiaryCell
        cell.view_Bg.backgroundColor = UIColor(hexCode: 0xFCF5E2)
        cell.view_Bg.layer.borderWidth = 1.0
        cell.view_Bg.layer.borderColor = UIColor(hexCode: 0xa38c47).cgColor
        cell.view_Bg.layer.cornerRadius = 2.0
        cell.view_Bg.clipsToBounds = true
        cell.separatorLine.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        cell.imgView_arrow.image = UIImage(named: "ic_arrowSelected")
        
        if(previousIndexPath != nil && indexPath.compare(previousIndexPath as IndexPath) != .orderedSame)
        {
            let preVIndexPath = previousIndexPath.copy() as! NSIndexPath
            previousIndexPath = indexPath as NSIndexPath
            tableView.reloadRows(at: [preVIndexPath as IndexPath], with: .none)
        }
        previousIndexPath = indexPath as NSIndexPath
        
        //        SVProgressHUD.showInfo(withStatus: "Coming soon", maskType: .gradient)
        
        if ((arr_DiaryCollectn.object(at: indexPath.row) as! DiaryList).blue_dot_flag != "0")
        {
            ClearDiaryNotificationsCalled(index: indexPath.row, callFrom: "")
        }
        
        selectedToastId = (self.arr_DiaryCollectn.object(at: (self.tblView_Diary.indexPathForSelectedRow?.row)!) as! DiaryList).toast_id
        selectedToast_Title = (self.arr_DiaryCollectn.object(at: (self.tblView_Diary.indexPathForSelectedRow?.row)!) as! DiaryList).toastTitle
        
        
        self.performSegue(withIdentifier: "chatVCSeg", sender: self)
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "chatVCSeg")
        {
            if let chatVC: TChatViewController = segue.destination as? TChatViewController {
                chatVC.screenTag = 1
                //uncomment below whn diary screen WS called and pass toast id to next screen
                //                chatVC.selectedToastId = (self.arr_DiaryCollectn.object(at: (self.tblView_Diary.indexPathForSelectedRow?.row)!) as! ToastList).toast_id
                chatVC.selectedToastId = selectedToastId
                chatVC.selectedToast_Title = selectedToast_Title
                
            }
        }
    }
}

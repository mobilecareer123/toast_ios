//
//  File.swift
//  CacheFunder
//
//  Created by Arkenea on 19/09/16.
//  Copyright © 2016 Ashwini@Arkenea. All rights reserved.
//

import UIKit

/*
 //let HOST_URL = "http://clientprojects.info/qa/toastapp/api"
 
 //let HOST_URL = "http://ec2-34-192-77-2.compute-1.amazonaws.com/api"
 
 //let HOST_URL = "http://app.toastafriend.com/api"
 
 //let SelfSignCert = "ec2-34-192-77-2.compute-1.amazonaws.com"
 
 //let SelfSignCert = "app.toastafriend.com/api"

 */

let kHOST_URL = "https://app.toastafriend.com/api"

let kSelfSignCert = "app.toastafriend.com"

// check before updating to https
let kTermsAndCondition = "http://app.toastafriend.com/terms-and-condition"
let kPrivacyPolicy = "http://app.toastafriend.com/privacy-policy"



let KEY_USER_ID = "UserId"
let KEY_DEVICE_TOKEN = "DEVICETOKENKEY"
let KEY_ACCESS_TOKEN = "ACCESSTOKENKEY"
let KEY_PROFILE_PIC_URL = "PROFILEPICURLKEY"
let KEY_LOGIN = "USER_LOGGEDIN_KEY"
let KEY_SOCIALMEDIA_TYPE = "KEY_SOCIALMEDIA_TYPE"
let KEY_EMAIL_ID = "KEY_EMAIL_ID"
let KEY_USER_NAME = "KEY_USER_NAME"
let KEY_FIRST_NAME = "KEY_FIRST_NAME"
let KEY_LAST_NAME = "KEY_LAST_NAME"

var KEY_POST_PATH:String = String()
var KEY_TOAST_PATH:String = String()
var KEY_PROFILEIMAGE_PATH:String = String()

// Coach Marks KEYS
let KEY_OverlayIndex_ToastVC = "KEY_OverlayIndex_ToastVC"
let KEY_OverlayIndex_AddCategoryVC = "KEY_OverlayIndex_AddCategoryVC"
let KEY_OverlayIndex_ChatVC = "KEY_OverlayIndex_ChatVC"
let KEY_OverlayIndex_ViewToastDeatilsVC = "KEY_OverlayIndex_ViewToastDeatilsVC"
let KEY_OverlayIndex_WriteMsgVC = "KEY_OverlayIndex_WriteMsgVC"
let KEY_OverlayIndex_CreateToastVC = "KEY_OverlayIndex_CreateToastVC"
let KEY_OverlayIndex_AddToasteeVC = "KEY_OverlayIndex_AddtoasteeVC"
let KEY_OverlayIndex_AddMemberVC = "KEY_OverlayIndex_AddMemberVC"
let KEY_OverlayIndex_AddCollaborators = "KEY_OverlayIndex_CreateToastVC_AddCollaborators"



let TIME_ZONE = "UTC"
let Device_iPhone4 = "Device_iPhone4"
let Device_iPhone5s = "Device_iPhone5s"
let Device_iPhone6 = "Device_iPhone6"
let Device_iPhone6p = "Device_iPhone6p"


// view constants
var isInitiator: Bool = false
var kSelectedToast_Id: String = String()
var isToastRaised: Bool = false

// Modal Class Objects
var createToast_modal:CreateToastModal!
var viewToastObj:ViewToast!
var raisedToastObj:DiaryList!//to temporary save raised toast to show in diary tab

// ************************ Alert Messages *******************************************************************

// Toast

let kSelectCategory = "Please select a toast category."
let kSendReminderToAll = "Do you want to remind collaborators who have not yet Cheered?"
let kReleaseToast = "Are you sure you want to raise the toast? Once raised, it can no longer be changed and it moves to diary section."
let kDeleteToast = "Are you sure you want to delete this toast?"
let kTransferOwnership_1 = "Are you sure? Once transfered, only"
let kTransferOwnership_2 = "can edit this toast."
let kAlertMI = "Initiator can not be added as a collaborator."
let kLeaveGroup = "Are you sure? Your Cheer will also be deleted."
let kRemoveToastee = "Are you sure you want to remove this toastee?"
let kRemoveCollaborator_1 = "Are you sure?"
let kRemoveCollaborator_2 = "'s Cheer will also be deleted."

let kSendReminder_1 = "Are you sure?" // kSendReminder_1 $memberName kSendReminder_2
let kSendReminder_2 = "will receive an email and an app notification."

let kChangePwd_Validation = "Password must be atleast 6 characters."
let kChangePwd_Validation_old = "Password must be atleast 6 characters long and must include a number."

let kChangePwdMatch = "Confirm password should match New Password."

let kCannotRemoveToaseeMsg = "Please add toastees before removing. You cannot have a toast without a toastee."
let kInvalidEmail = "Please enter a valid email."
let kNoEmailInContact = "You have no email address associated with this contact"
let kAddToasteeCreateToast = "Click on the user item to add to the toastee list"
let kAddCollabCreateToast = "Click on the user item to add to the collaborator list"
// Create Toast
//let kHiglightFieldMsg = "Please enter data in the highlighted fields."

let kHiglightFieldMsg = "Please enter a from group name for your group toast."
let kToasteeCountMsg = "You cannot have a toast without a toastee."
let kToastCreatedMsg = "Toast created successfully. You can now Cheer."
let kAddMember = "Member is already on this toast."
let kRaisedToast = "You raised a toast."

//no result messages
//Diary screen
let kNoRaisedToastForCollaborator_Msg = "You will start seeing activity in this section\n once an initiator raises a toast on which\nyou are a collaborator."
let kNoRaisedToastForToastee_Msg = "You will start seeing activity in this section\n once an initiator raises a toast to you."

let kNoRaisedToastForInitiator_Msg = "You will start seeing activity in this section\n once you raise a toast"
let kNoRaisedToastForInitiator_MsgNew = "You will see activity as soon as\n you Raise a Toast."
let kNoRaisedToastForToastee_MsgNew = "You will see activity as soon as a\n Toast is Raised to you."
let kNoRaisedToastForCollaborator_MsgNew = "You will see activity as soon as a\n Toast is Raised from \nthe group you are added to."

//Toast screen
let kNoToastForInitiator_Msg = "No \"ongoing\" toasts created \nby you or transferred to you."
let kNoToastForCollaborator_Msg = "No \"ongoing\" toasts \n on which you are a collaborator."

//chat screen
let kNoChat_Msg = "No Cheer have been posted on this toast.."
let kWriteCheer = "Cheer text cannot be blank."


// SignUp and pwd

let kValidEmailId = "Please enter a valid email id"
let kPwdValidation = "Password must be atleast 6 characters."
let kResetPwd = "Reset password link has been sent to your registered email address."

// *******************************************************************************************
let kAddIntendedMember_Notification = "AddIntendedMember_Notification"
let kAddCollaborator_Notification = "AddCollaborator_Notification"
let kLeftToast_Notification = "LeftToast"
let kCategoryAdded_Notification = "CategoryAdded"
let kEditIntendedMember_Notification = "EditIntendedMember_Notification"
let kToastRaised_Notification = "EditToast_Notification"
let kEditPost_Notification = "EditPost_Notification"
let kToastRaised_PushNotification = "ToastRaised_PushNotification"
let kMemberDeleted_Notification = "MemberDeleted_Notification"
let kUpdateOffset_Notification = "UpdateOffset_Notification"
let kKeyboardShow_Notification = "KeyboardShow_Notification"
let kKeyboardHide_Notification = "KeyboardHide_Notification"

// *******************************************************************************************

let kRefreshViewToast_Notification = "RefreshViewToast_Notification"
let kRefreshToastList_Notification = "RefreshToastList_Notification"

let kUpdateList_Notification = "UpdateList_Notification"
let kUpdateTransferedList_Notification = "UpdateTransferedList_Notification"
let kListCount_Notification = "ListCount_Notification"
let kUpdateDiary_Notification = "UpdateDiary_Notification"

//******************************************** Navigation Title ************************************************


let kNavigationTitleDairyTab = "Personal Diary"
let kNavigationTitleSmallDairyTab = "You as a"

let kNavigationTitleWriteMsg = "Message to Toastee"
let kNavigationTitleToastTab = "Ongoing Toasts"
let kNavigationTitleToastDetails = "Toast Details"
let kNavigationTitleAddCollaborators = "Collaborators"

//********************************************************************************************
let kRedirectToCheersScreen_pushNotification = "RedirectToCheersScreen_pushNotification"
let kRedirectToViewToastScreen_pushNotification = "RedirectToViewToastScreen_pushNotification"
let kCheersScreen_pushNotification = "CheersScreen_pushNotification"
let kRedirectToViewToastViaChatVC_pushNotification = "RedirectToViewToastViaChatVC_pushNotification"

let kPopDiaryToastVC_pushNotification = "PopDiaryToastVC_pushNotification"



//*****************************************************************************************************************

// ToastList
func daysBetween(endDate: String) -> String {
    let startDate = Date()
    
    let timeZone = TimeZone(identifier: TIME_ZONE)
    let formatter: DateFormatter = DateFormatter()
    
    formatter.dateFormat = "dd MMM, yyyy"
    formatter.timeZone = timeZone
    
    let end = formatter.date(from: endDate as String)
    let startStr = formatter.string(from: startDate)
    let start = formatter.date(from: startStr)! as Date
    
    
    if(end != nil)
    {
        if(start.isLessThanDate(end!))
        {
            let final = Calendar.current.dateComponents([.day], from: start, to: end!).day!
            
            var str  = ""
            
            if final == 1
            {
//                str = "\(final) day to go"
                str = "Tomorrow"

            }
            else if final <= 7
            {
                str = "\(final) days to go"
            }
            else
            {
                str = endDate
                //str = "\(start)"
            }
            return str
        }
        else if(start.equalToDate(end!))
        {
            return "Today"
        }
        else if(start.isGreaterThanDate(end!))
        {
            let final = Calendar.current.dateComponents([.day], from: start, to: end!).day!
            
            var str  = ""
            
            if final == -1
            {
                let str1 = "\(final) day overdue"
                str = str1.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
            }
            else if final >= -7
            {
                let str1 = "\(final) days overdue"
                str = str1.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
            }
            else
            {
                str = endDate
            }
            //            else
            //            {
            //                 str = "\(start)"
            //            }
            return str
        }
        else
        {
            let str1 = "N/A"
            return str1
        }
    }
    return ""
}




func dateForDiary(endDate: String) -> String {
    let startDate = Date()
    
    let timeZone = TimeZone(identifier: TIME_ZONE)
    let formatter: DateFormatter = DateFormatter()
    
    formatter.dateFormat = "dd MMM, yyyy"
    formatter.timeZone = timeZone
    
    let end = formatter.date(from: endDate as String)
    let startStr = formatter.string(from: startDate)
    let start = formatter.date(from: startStr)! as Date
    
    
    if(end != nil)
    {
        if(start.isLessThanDate(end!))
        {
            let final = Calendar.current.dateComponents([.day], from: start, to: end!).day!
            
            var str  = ""
            
            if final == 1
            {
                str = "\(final) day to go"
            }
            else
            {
                str = "\(final) days to go"
            }
            return str
        }
        else if(start.equalToDate(end!))
        {
            return "Today"
        }
            //        else if(start.isGreaterThanDate(end!))
            //        {
            //            let final = Calendar.current.dateComponents([.day], from: start, to: end!).day!
            //
            //            var str  = ""
            //
            //            if final == -1
            //            {
            //                let str1 = "\(final) day overdue"
            //                str = str1.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
            //            }
            //            else
            //            {
            //                let str1 = "\(final) days overdue"
            //                str = str1.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
            //            }
            //            return str
            //        }
        else
        {
            return endDate
        }
    }
    return ""
}

func dateForChat(postDate: String) -> String {
    let startDate = Date()
    
    let timeZone = TimeZone(identifier: TIME_ZONE)
    let formatter: DateFormatter = DateFormatter()
    
    formatter.dateFormat = "dd MMM, yy"
    formatter.timeZone = timeZone
    
    let end = formatter.date(from: postDate as String)
    let startStr = formatter.string(from: startDate)
    let start = formatter.date(from: startStr)! as Date
    
    
    if(end != nil)
    {
        if(start.equalToDate(end!))
        {
            return "Today"
        }
        else if(start.isGreaterThanDate(end!))
        {
            let final = Calendar.current.dateComponents([.day], from: start, to: end!).day!
            
            var str  = ""
            
            if final == -1
            {
                str = "Yesterday"
            }
            else
            {
                str = postDate
            }
            return str
        }
        else
        {
            return postDate
        }
    }
    return ""
}


func getDataUsinfEncoding(dict:NSDictionary, key:String) ->String  {
    do{
        let data = try JSONSerialization.data(withJSONObject: (dict[key] as? NSArray)!, options: JSONSerialization.WritingOptions.prettyPrinted)
        var string = String(data: data, encoding: String.Encoding.utf8)
        //            string = string?.stringByReplacingOccurrencesOfString("\n", withString: "")
        //            string = string?.stringByReplacingOccurrencesOfString("'\"", withString: "")
        string = string?.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
        string = string?.replacingOccurrences(of: "'\"", with: "", options: .literal, range: nil)
        string = string?.replacingOccurrences(of: " \"", with: "", options: .literal, range: nil)
        string = string?.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        string = string?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        string = string?.replacingOccurrences(of: "[", with: "", options: .literal, range: nil)
        string = string?.replacingOccurrences(of: "]", with: "", options: .literal, range: nil)
        return string!
        
    }
    catch{
        
    }
    return ""
}


extension UIColor{
    convenience init(hexCode:UInt32) {
        let red = CGFloat((hexCode & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hexCode & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hexCode & 0xFF)/256.0
        self.init(red:red, green:green, blue:blue, alpha:1.0)
    }
}

extension UIViewController{
    func currentScreen()->NSString{
        let result = UIScreen.main.bounds.size
        if result.height == 568 {
            // 4 inch display - iPhone 5
            return Device_iPhone5s as NSString
        }
        else if result.height == 667 {
            // 4.7 inch display - iPhone 6
            return Device_iPhone6 as NSString
            
        }
        else if result.height == 736 {
            // 5.5 inch display - iPhone 6 Plus
            return Device_iPhone6p as NSString
        }
        else{
            return Device_iPhone4 as NSString
            
        }
        
    }
    
}

//extension NSDictionary
//{
//    func encodeDictionary() -> String {
//        var bodyData = String()
//        var i = 0
//        for key: String in self.allKeys {
//            i += 1
//            bodyData += "\(key)="
//            var value = (dictionary.value(forKey: key) as! String)
//            var newString = value.replacingOccurrencesOf(" ", withString: "+")
//            bodyData += newString
//            if i < dictionary.allKeys().count {
//                bodyData += "&"
//            }
//        }
//        return bodyData
//    }
//}

extension NSString{
    func isValidEmailObjeC()->Bool{
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
        
    }
    
    func Trim() ->NSString{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
    }
}

extension UITableView {
    
    /// Check if cell at the specific section and row is visible
    /// - Parameters:
    /// - section: an Int reprenseting a UITableView section
    /// - row: and Int representing a UITableView row
    /// - Returns: True if cell at section and row is visible, False otherwise
    func isCellVisible(section:Int, row: Int) -> Bool {
        let indexes = self.indexPathsForVisibleRows!
        return indexes.contains {$0.section == section && $0.row == row }
    }
}

extension NSMutableAttributedString {
    func bold(text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 23.0)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    func normal(text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}


func getNavigationTitle(inputStr:String) -> ResizableFontLabel {
    let titleView = ResizableFontLabel()
    titleView.autoFont = true
    titleView.fontSize = 20.0
    titleView.frame = CGRect(x: 0, y: 30, width: 150, height: 40)
    titleView.textColor = UIColor.white
    titleView.text = inputStr
    titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 20.0)
    titleView.textAlignment = NSTextAlignment.left
    titleView.sizeToFit()
    return titleView
}
extension Array where Element: NSAttributedString {
    func joined(separator: NSAttributedString) -> NSAttributedString {
        var isFirst = true
        return self.reduce(NSMutableAttributedString()) {
            (r, e) in
            if e.isEqual(to: NSAttributedString()) // only if not empty
            {
                if isFirst {
                    isFirst = false
                } else {
                    r.append(separator)
                }
                r.append(e)
            }
            return r
        }
    }
}

func getNavigationTwoTitles(inputStr1:String, inputStr2:String) -> UIView {
    let title_View = UIView()
    title_View.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.size.height == 568) ? 150 : 180, height: 50)
    
    let titleView = ResizableFontLabel()
    titleView.autoFont = true
    titleView.fontSize = 18.0
    titleView.frame = CGRect(x: 0, y: 9, width: (UIScreen.main.bounds.size.height == 568) ? 150 : 180, height: 21)
    titleView.textColor = UIColor.white
    titleView.text = inputStr1
    titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
    titleView.textAlignment = .center
    
    let titleView2 = UILabel()
    titleView2.frame = CGRect(x: 0, y: 27, width: (UIScreen.main.bounds.size.height == 568) ? 150 : 180, height: 20)
    titleView2.textColor = UIColor.white
    titleView2.text = inputStr2
    titleView2.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)
    titleView2.textAlignment = .center
    
    title_View.addSubview(titleView)
    title_View.addSubview(titleView2)
    
    return title_View
}
func getValueFromDictionary(dicData: NSDictionary, forKey key: String) -> String! {
    var boolCheck:[String:Bool]?
    
    if ((dicData.object(forKey: key) as AnyObject).isKind(of: NSNull.classForCoder()) == true) {
        return ""
    } else if (dicData.object(forKey: key) == nil) {
        return ""
    } else if ((dicData.object(forKey: key) as AnyObject).isKind(of: NSNumber.classForCoder()) == true) {
        let value: NSNumber = dicData[key] as! NSNumber
        return value.stringValue
    } else if (boolCheck?[key] == true) {
        return "true"
    } else if (boolCheck?[key] == false) {
        return "false"
    }
    else {
        return dicData[key] as! String
    }
}
// app rating 
func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
    guard let url = URL(string : "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=" + appId) else {
        completion(false)
        return
    }
    guard #available(iOS 10, *) else {
        completion(UIApplication.shared.openURL(url))
        return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: completion)
}

extension String{
    
    func isValidEmail()->Bool{
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
        
    }
    
    func base64String()->String{
        return self.data(using: String.Encoding.utf8, allowLossyConversion: false)!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    
    func isContainsAllValidChar() -> Bool {
        let passwordRegEx =  "^(?=.*\\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[$@$!%*#?&]).{8,15}$"//"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\\s).{4,8}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }
    
    func isValidPassword()->Bool{
        
        if(self.characters.count >= 6) && (self.characters.count < 30){
            
//            let alphabetSet: CharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
//            let numberSet: CharacterSet = CharacterSet(charactersIn: "0123456789")
//            
//            let string: NSString = NSString(string: self)
//            
//            var range: NSRange = string .rangeOfCharacter(from: alphabetSet)
//            
//            if range.length > 0 {
//                range = string.rangeOfCharacter(from: numberSet)
//                if range.length > 0{
//                    return true
//                }
//            }
            
            return true
            
        }
        
        return false
    }
    func isAlphaneumeric()->Bool
    {
        let alphabetSet: CharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/")
        let numberSet: CharacterSet = CharacterSet(charactersIn: "0123456789")
        
        let string: NSString = NSString(string: self)
        
        var range: NSRange = string.rangeOfCharacter(from: alphabetSet)
        
        if range.length > 5 {
            range = string.rangeOfCharacter(from: numberSet)
            if range.length > 0{
                return true
            }
            
        }
        return false
    }
    
    func getLocalDateFromServerDate()->Date{
        let timeZone = TimeZone(identifier: TIME_ZONE)
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = timeZone
        
        let date = formatter.date(from: self as String)
        return date!
        
    }
    
    func Trim() ->String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func convertDateFormatWithTime()->String
    {
        let timeZone = TimeZone(identifier: TIME_ZONE)
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = timeZone
        
        let date = formatter.date(from: self as String)
        var stringDate: String = String()
        if(date != nil)
        {
            formatter.dateFormat = "dd MMM, yyyy"
            stringDate = formatter.string(from: date!)
        }
        
        return stringDate
    }
    
    func convertDateFormatWithTimeForPostMsg()->String
    {
        let timeZone = TimeZone(identifier: TIME_ZONE)
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = timeZone
        
        let date = formatter.date(from: self as String)
        var stringDate: String = String()
        if(date != nil)
        {
            formatter.dateFormat = "dd MMM, yy"
            stringDate = formatter.string(from: date!)
        }
        
        return stringDate
    }
    
    
    func convertDateToServerFormat()->String
    {
        let timeZone = TimeZone(identifier: TIME_ZONE)
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "dd MMM, yyyy"
        formatter.timeZone = timeZone
        
        let date = formatter.date(from: self as String)
        var stringDate: String = String()
        if(date != nil)
        {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            stringDate = formatter.string(from: date!)
        }
        
        return stringDate
    }
    
    
    func convertDateFormat()->String
    {
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        let date = formatter.date(from: self as String)
        
        formatter.dateFormat = "dd MMM, yyyy"
        var stringDate: String = String()
        if(date != nil)
        {
            stringDate = formatter.string(from: date!)
        }
        
        return stringDate
    }
    
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleToFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func setImageFromURl(stringImageUrl url: String){
        
        if let url = NSURL(string: url) {
            let data = try? Data(contentsOf: url as URL) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                let imageNew = UIImage(data: data!)
                self.image = imageNew?.af_imageAspectScaled(toFill: self.frame.size)
            }
        }
    }
}

extension UIImage{
    
    func imageWithSize(_ size: CGSize) -> UIImage
    {
        let newSize: CGSize = size
        UIGraphicsBeginImageContext( newSize )
        self.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageWithImageInSize(_ image: UIImage) -> UIImage
    {
        let newSize: CGSize = CGSize(width: 300.0, height: 300.0)
        UIGraphicsBeginImageContext( newSize )
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func encodeToBase64String()->String{
        return String(format: "data:image/jpg;base64,%@", UIImageJPEGRepresentation(self, 1.0)!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))
    }
    
    func imageWithRoudedCornersForBounds(_ bounds: CGRect, cornerRadius: CGFloat) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0)
        UIBezierPath(roundedRect: bounds, cornerRadius: bounds.size.width).addClip()
        self.draw(in: bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func roundedImageWithView(_ view: UIView) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        UIBezierPath(roundedRect: view.bounds, cornerRadius: view.bounds.size.width).addClip()
        self.draw(in: view.bounds)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func cropToBounds(width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: self.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x:posX, y:posY, width:cgwidth, height:cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
}


extension Date{
    
    func daySuffix() -> String {
        
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: self)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    func stringFromDate(_ formatter:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: self)
    }
    
    func convertToGMT(_ dateFormat: String) -> String{
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: TIME_ZONE)
        df.dateFormat = dateFormat
        return df.string(from: self)
    }
    func dateFromString(_ date: String, format: String) -> Date {
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.date(from: date)!
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
}
extension Bundle {
    
    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        fatalError("Could not load view with type " + String(describing: type))
    }
}
extension UITabBarController {
    
    func setBadges(badgeValues: [Int]) {
        
//            for view in self.tabBar.subviews {
//                if view is CustomTabBadge {
//                    
//                     if badgeValues[0] == 101 && self.tabBar.subviews.index(of: view)! == 1{ // Clear Toast Tab
//                    view.removeFromSuperview()
//                    }
//                    if badgeValues[1] == 101 && self.tabBar.subviews.index(of: view)! == 0{ // Clear Diary Tab
//                        view.removeFromSuperview()
//                    }
//                }
//            }
        
        for view in self.tabBar.subviews {
            if view is CustomTabBadge {
                
                view.removeFromSuperview()
            }
        }
        
        for index in 0...badgeValues.count-1 {
            if badgeValues[index] != 0  &&  badgeValues[index] != 101 { //  create
                
                addBadge(index: index, value: badgeValues[index], color: UIColor.blue, font: UIFont(name: "Helvetica-Light", size: 11)!)
            }
            else if badgeValues[index] == 101
            {
                addBadge(index: index, value: badgeValues[index], color: UIColor.clear, font: UIFont(name: "Helvetica-Light", size: 11)!)
            }
        }
    }
    
    func addBadge(index: Int, value: Int, color: UIColor, font: UIFont) {
        
        let badgeView = CustomTabBadge()
        badgeView.clipsToBounds = true
        badgeView.textColor = UIColor.white
        badgeView.textAlignment = .center
        badgeView.font = font
        badgeView.text = " "
        badgeView.backgroundColor = color
        badgeView.tag = index
        tabBar.addSubview(badgeView)
        
        self.positionBadges()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.positionBadges()
    }
    
    // Positioning
    func positionBadges() {
        
        var tabbarButtons = self.tabBar.subviews.filter { (view: UIView) -> Bool in
            return view.isUserInteractionEnabled // only UITabBarButton are userInteractionEnabled
        }
        
        tabbarButtons = tabbarButtons.sorted(by: { $0.frame.origin.x < $1.frame.origin.x })
        
        for view in self.tabBar.subviews {
            if view is CustomTabBadge {
                let badgeView = view as! CustomTabBadge
                self.positionBadge(badgeView: badgeView, items:tabbarButtons, index: badgeView.tag)
            }
        }
    }
    
    func positionBadge(badgeView: UIView, items: [UIView], index: Int) {
        
        let itemView = items[index]
        let center = itemView.center
        
        let xOffset: CGFloat = 12
        let yOffset: CGFloat = -14
        badgeView.frame.size = CGSize(width: 17, height: 17)
        badgeView.center = CGPoint(x: center.x + xOffset, y: center.y + yOffset)
        badgeView.layer.cornerRadius = badgeView.bounds.width/2
        tabBar.bringSubview(toFront: badgeView)
    }
}

class CustomTabBadge: UILabel {}

extension NSMutableAttributedString {
    func small(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 16)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    func big(_ text:String)->NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 24)!]
        let normal = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(normal)
        return self
    }
}


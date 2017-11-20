//
//  TCreateToast_AddCollabVC.swift
//  Toast
//
//  Created by Anish Pandey on 19/07/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SDWebImage

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

class TCreateToast_AddCollabVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var txt_groupname: UITextField!
    @IBOutlet weak var txt_additional_message: UITextView!
    @IBOutlet weak var txt_due_date: UITextField!
    @IBOutlet weak var txt_collaborators: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var suggestion_table: UITableView!
    @IBOutlet weak var notification_switch: UISwitch!
    @IBOutlet weak var lbl_category: UILabel!
    
    @IBOutlet weak var collabolators_picker: THContactPickerView!
    
    var category = ""
    var message = ""
    var toast_to_emails = [String]()
    var toast_image = UIImage()
    var isImageSelected = false
    var ohter_category = ""
    
    let datePicker = UIDatePicker()

    
    var contactStore = CNContactStore()
    var emailArray = ["test@test.com","ahsan@exelion.com"]
    var filteredEmails = [String]()
    var selectedEmails = [String]()
    var emailDictionary = [String : String]()


    var selectedDateTime : String = ""

    var toast_id = ""
    var toast_title = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.category)
        print(self.toast_to_emails)
        
        self.notification_switch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8);
        self.fetchContacts()
        self.suggestion_table.isHidden = true
        
        self.suggestion_table.delegate = self
        self.suggestion_table.dataSource = self
        
        self.txt_collaborators.delegate = self
        self.txt_groupname.delegate = self
        self.txt_additional_message.delegate = self
        self.txt_due_date.delegate = self

        self.txt_additional_message.textColor = UIColor(hexCode: 0x666666)
        self.txt_collaborators.textColor = UIColor(hexCode: 0x666666)
        self.txt_due_date.textColor = UIColor(hexCode: 0x666666)
        self.txt_groupname.textColor = UIColor(hexCode: 0x666666)

        self.txt_additional_message.layer.borderWidth = 1.0
        self.txt_additional_message.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        self.txt_additional_message.layer.cornerRadius = 5.0
        
        self.txt_collaborators.layer.borderWidth = 1.0
        self.txt_collaborators.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        self.txt_collaborators.layer.cornerRadius = 5.0
        
        self.txt_due_date.layer.borderWidth = 1.0
        self.txt_due_date.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        self.txt_due_date.layer.cornerRadius = 5.0
        
        self.txt_groupname.layer.borderWidth = 1.0
        self.txt_groupname.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        self.txt_groupname.layer.cornerRadius = 5.0

        self.setLeftPaddingPoints(3, textField: self.txt_due_date)
        self.setLeftPaddingPoints(3, textField: self.txt_groupname)
        self.createTimePicker()
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem : .done,target: nil, action: #selector(typeSelected))
        
        toolbar.setItems(([doneButton]), animated: true)
        
        txt_collaborators.inputAccessoryView = toolbar
        txt_additional_message.inputAccessoryView = toolbar
        
        
        self.CustomiseView()
        
        self.lbl_category.text = "   A toast to celebrate \(category)"
        
        collabolators_picker.delegate = self
        collabolators_picker.maxNumberOfLines = 4
    }
    
    func createTimePicker()
    {
        datePicker.datePickerMode = .date
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem : .done,target: nil, action: #selector(donePressed))
        
        toolbar.setItems(([doneButton]), animated: true)
        
        txt_due_date.inputAccessoryView = toolbar
        
        txt_due_date.inputView = datePicker
    }
    
    
    @IBAction func CollaborationCompleted(_ sender: Any) {
        
        self.CreateCollaborationToastCalled()
        //self.PostMsgOnGroup()
    }
    
    func createToastBtnClicked()
    {
        self.CreateSingleToastCalled()
        //self.PostMsgOnGroup()
    }
    
    func donePressed()
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "YYYY-MM-d"
        self.selectedDateTime = dateFormatter.string(from: datePicker.date)
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        txt_due_date.text = dateFormatter.string(from: datePicker.date)
        self.scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)

        self.view.endEditing(true)
        
    }

    
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized: completion(true) // authorized previously
        case .denied, .notDetermined: // needs to ask for authorization
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (accessGranted, error) -> Void in
                completion(accessGranted)
            })
        default: // not authorized.
            completion(false)
        }
    }
    
    
    
    func fetchContacts()
    {
        //Fetch
        let contactStore: CNContactStore = CNContactStore()
        var contacts: [CNContact] = [CNContact]()
        let fetchRequest: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        
        do {
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: {
                contact, _ in
                contacts.append(contact)
                
            })
            
        } catch {
            print("Get contacts \(error)")
        }
        
        for item in contacts {
            
            for email in item.emailAddresses {
                print(email.value)
                self.emailArray.append(email.value as String)
                self.emailDictionary[email.value as String] = item.givenName + " " + item.familyName

            }
        }
        
    }
    
    func typeSelected()
    {
        self.suggestion_table.isHidden = true
        self.scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)

        self.view.endEditing(true)
    }
    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: kNavigationTitleAddCollaborators)
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: -20, y: -20, width: 0, height: 0)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
       // buttonback.addTarget(self, action: #selector(TCreateToast_AddCollabVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        let btn_Done: UIButton = UIButton(type: UIButtonType.custom)
        btn_Done.frame = CGRect(x: 0, y: -25, width: 44, height: 30)
        btn_Done.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15.5)
        btn_Done.setTitle("Skip", for: .normal)
        btn_Done.addTarget(self, action: #selector(createToastBtnClicked), for: UIControlEvents.touchUpInside)
        let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_Done)
        self.navigationItem.setRightBarButton(rightBarButtonItemShare, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    
//    @objc func  backBtnClicked(_ sender: UIButton!)
//    {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kAddCollaborator_Notification), object: nil)
//        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
//    }

    // MARK: - Table View Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredEmails.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "personscell")
        let email = self.filteredEmails[indexPath.row]
        cell.detailTextLabel?.text = email
        
        if let name = emailDictionary[email] {
            cell.textLabel?.text = name
        } else {
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!self.selectedEmails.contains(self.filteredEmails[indexPath.row]))
        {
            let email = self.filteredEmails[indexPath.row]
            self.selectedEmails.append(email)
            self.addContact(contact: email, contactPicker: collabolators_picker)
        }
        self.showselectedEmails()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == suggestion_table {
            if section == 0 {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
                label.text = "CONTACTS"
                label.font = UIFont.init(name: "REFSANB", size: 15)
                label.textColor = .black
                let v = UIView()
                v.addSubview(label)
                v.sizeToFit()
                return v
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == suggestion_table {
            if section == 0 {
                return 45
            }
        }
        
        return 0
    }
    
    func showselectedEmails()
    {
        return
        self.txt_collaborators.text = ""
        var attributedText = NSMutableAttributedString()
        
        
        for email in self.selectedEmails
        {
            var tempEmail = ""
            if let temp = self.emailDictionary[email]
            {
                tempEmail = temp
            }
            else
            {
                tempEmail = email
            }
            
            let attribstart = self.txt_collaborators.attributedText
            
            let emailAttrib = NSMutableAttributedString(string: tempEmail, attributes: [NSBackgroundColorAttributeName : UIColor(hex : "e3d1a1"), NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)])
            
            let comma = NSMutableAttributedString(string: " , ", attributes: [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(emailAttrib)
            
            attributedText.append(comma)
            
            
            self.txt_collaborators.attributedText = attributedText
            
        }
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let  char = text.cString(using: String.Encoding.utf8)!
        let isReturnKey = strcmp(char,"\\n")
        
        if(textView == self.txt_collaborators)
        {
            //if (isBackSpace == -92) {
            //    print(self.txt_toaste.text)
            //    self.deleteEmail(allEmails: self.txt_toaste.text)
            //    self.showselectedEmails()
            //    return false
            //}
            
            if (isReturnKey == -82) {
                
                let arr = self.txt_collaborators.text.components(separatedBy: ",")
                print(arr[arr.count - 1])
                if(!self.selectedEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedEmails.append(arr[arr.count - 1])
                }
                self.showselectedEmails()
                return false
                
            }
            
            if(text.characters.count > 1)
            {
                let arr = text.components(separatedBy: "\n")
                for item in arr
                {
                    if(!self.selectedEmails.contains(item))
                    {
                        if(item.characters.count != 0)
                        {
                            self.selectedEmails.append(item)
                        }
                    }
                }
                self.showselectedEmails()
                return false
            }
            if(text == ",")
            {
                let arr = self.txt_collaborators.text.components(separatedBy: ",")
                print(arr[arr.count - 1])
                if(!self.selectedEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedEmails.append(arr[arr.count - 1])
                }
                self.showselectedEmails()
                return false
            }
            if(text == " ")
            {
                let arr = self.txt_collaborators.text.components(separatedBy: " ")
                print(arr[arr.count - 1])
                if(!self.selectedEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedEmails.append(arr[arr.count - 1])
                }
                self.showselectedEmails()
                return false
            }
            
        }
        return true
    }
    
    func checkIfEmailsValid() -> Bool
    {
        for item in self.selectedEmails
        {
            if !self.isValidEmail(testStr: item)
            {
                return false
            }
        }
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func returnTextAfterComman() -> String
    {
        var text : String = ""
        let arr = self.txt_collaborators.text.components(separatedBy: ",")
        for item in arr
        {
            if(!self.selectedEmails.contains(item))
            {
                text =  item
            }
        }
        let finalText = text.components(separatedBy: " ")
        if finalText.count == 2
        {
            return finalText[1]
        }
        else
        {
            return finalText[0]
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == self.txt_collaborators{
            self.filteredEmails.removeAll()
            self.suggestion_table.isHidden = false
            let textToSearch = self.returnTextAfterComman()
            for email in self.emailArray
            {
                if email.contains(textToSearch)
                {
                    self.filteredEmails.append(email)
                }
            }
            self.suggestion_table.reloadData()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.txt_collaborators
        {
            if textView.text == "Enter emails separated by a space or a newline"
            {
                textView.text = ""
            }
            self.suggestion_table.isHidden = true
            self.scrollView.setContentOffset(CGPoint(x:0,y:300), animated: true)
        }
        else if textView == self.txt_additional_message
        {
            if textView.text == "Additional details to the collaborators about the toast"
            {
                textView.text = ""
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.becomeFirstResponder()
        self.view.endEditing(true)
        self.scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txt_groupname
        {
            let temp = textField.text
            if temp == " From Group Name"
            {
                textField.text = ""
            }
        }
        else if textField == self.txt_due_date
        {
            let temp = textField.text
            if temp == " Due Date"
            {
                textField.text = ""
            }

        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        return true
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat,textField :UITextField){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
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
            let  str = self.message
            let textViewData : NSData = str.data(using: String.Encoding.nonLossyASCII)! as NSData
            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
            
            let parameters: NSDictionary = ["service": "postmessage", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : self.toast_id, "message_text" : valueUniCode, "multipart" : multipart]
            
            var toastImg: String = ""
            if (self.isImageSelected) {
                let imageData = UIImagePNGRepresentation(self.toast_image)
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
                            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "TChatViewController") as! TChatViewController
                            chatVC.selectedToastId = self.toast_id
                            chatVC.selectedToast_Title = self.toast_title
                            chatVC.screenTag = 2
                            chatVC.toast_message = self.message
                            chatVC.toast_image = self.toast_image
                            self.navigationController?.pushViewController(chatVC, animated: true)
                            
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
    
    func CreateSingleToastCalled()
    {
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(withStatus: "Creating Toast ... ", maskType: .gradient)
            
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let finalStringDate = dateFormatter.string(from: date)
            
            print(finalStringDate)
            
            let parameters: NSDictionary = ["service": "createnewtoast", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "category_name":self.category,"released_date":finalStringDate, "other_category_name":self.ohter_category, "toast_notification":"Y", "toastee_users":self.toast_to_emails, "multipart":"N"]
            
            var toastImg: String = ""
            if (self.isImageSelected) {
                let imageData = UIImagePNGRepresentation(self.toast_image)
                let filePath: NSString = (NSTemporaryDirectory() as NSString).appendingPathComponent("userimage.png") as NSString
                
                do {
                    try imageData?.write(to: URL(fileURLWithPath: filePath as String), options: .atomic)
                    toastImg = filePath as String
                } catch {
                    
                }
            }
            
            WebService.multipartRequest(postDict: parameters, ProfileImage: toastImg){  (response, error) in
                
                SVProgressHUD.dismiss()
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        
                        SVProgressHUD.dismiss()
                        
                        let markValue : Int = response["toast_id"] as! Int
                        
                        self.toast_id = ("\(markValue)")
                        
                        self.toast_title = String(format: "%@",response["toast_title"]! as! String)

                        
                        // create object to pass via notification
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        
                        let userInfo = ["newData": toastArray]
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateList_Notification), object: nil, userInfo: userInfo)
                        
                        func handleCancel(_ alertView: UIAlertAction!)
                        {
                            
                            self.dismiss(animated: true, completion: nil)
                            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "TChatViewController") as! TChatViewController
                            chatVC.selectedToastId = self.toast_id
                            chatVC.selectedToast_Title = self.toast_title
                            chatVC.screenTag = 2
                            chatVC.toast_message = self.message
                            chatVC.toast_image = self.toast_image
                            self.navigationController?.pushViewController(chatVC, animated: true)
                        }
                        
                        let alert = UIAlertController(title: nil, message: kToastCreatedMsg, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:handleCancel))
                        
                        alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                        self.present(alert, animated: true, completion: nil)
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

    
    func CreateCollaborationToastCalled()
    {
        /*"
         {
         "service": "createnewtoast",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "theme": "Wish you all the best!",
         "released_date": "2016-11-30 15:30:45",
         "from_text": "Tea Time Group",
         "category_name": "Farewell",
         "other_category_name": "",
         "toast_notification": "Y",
         "toastee_users": ["swapnil@arkenea.com", "meghna226666@arkenea.com"],
         "members": ["subodh@arkenea.com", "dinesh@arkenea.com", "john.doe@gmail.com"],
         "multipart": "Y"
         }
         
         $_FILES['image']
         
         
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(withStatus: "Creating Toast ... ", maskType: .gradient)
            
            var multipart = "N"
            if (self.isImageSelected)
            {
                multipart = "Y"
            }
            // prepare array
            
//            let intendedUserArray : NSMutableArray = NSMutableArray()
//            
//            for user1 in createToast_modal.intended_users_s1
//            {
//                //                let dict : NSMutableDictionary = NSMutableDictionary()
//                intendedUserArray.add((user1 as! AddMemberModel).member_Email_id.lowercased())
//            }
//            
//            let memberArray : NSMutableArray = NSMutableArray()
//            
//            for user1 in createToast_modal.members_s4
//            {
//                //                let dict : NSMutableDictionary = NSMutableDictionary()
//                memberArray.add((user1 as! AddMemberModel).member_Email_id.lowercased())
//            }
//            
            //                       SVProgressHUD.show(with: .gradient)
            
            //            let dateFormatter1:DateFormatter = DateFormatter()
            //            dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //            let date = dateFormatter1.date(from: createToast_modal.due_date_s1 as String)
            //            let dueDate = dateFormatter1.string(from: (date)!)
            
            // convert text to support emoticons
            //let  str = createToast_modal.toast_Theme_s1
//            let textViewData : NSData = str.data(using: String.Encoding.nonLossyASCII)! as NSData
//            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
//            
            
//            let Intended_swiftArray = NSArray(array:intendedUserArray)
//            let Intended_stringRepresentation = (Intended_swiftArray as! Array).joined(separator: ",")
//            print(Intended_stringRepresentation.description)
//            
//            let Member_swiftArray = NSArray(array:memberArray)
//            let Member_stringRepresentation = (Member_swiftArray as! Array).joined(separator: ",")
//            print(Member_stringRepresentation.description)
            
            var _notification = "N"
            if self.notification_switch.isOn
            {
                _notification = "Y"
            }
            else
            {
                _notification = "N"
            }
            
            print(self.txt_due_date.text!)
            print(self.txt_due_date.text!.convertDateToServerFormat())
            
            let parameters: NSDictionary = ["service": "createnewtoast", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "theme":self.txt_additional_message.text, "released_date":self.selectedDateTime, "from_text":txt_groupname.text!, "category_name":self.category, "other_category_name":"", "toast_notification":_notification, "toastee_users":self.toast_to_emails, "members":self.selectedEmails, "multipart":multipart]
            
            var toastImg: String = ""
            if (self.isImageSelected) {
                let imageData = UIImagePNGRepresentation(self.toast_image)
                let filePath: NSString = (NSTemporaryDirectory() as NSString).appendingPathComponent("userimage.png") as NSString
                
                do {
                    try imageData?.write(to: URL(fileURLWithPath: filePath as String), options: .atomic)
                    toastImg = filePath as String
                } catch {
                    
                }
            }
            
            WebService.multipartRequest(postDict: parameters, ProfileImage: toastImg){  (response, error) in
                
                SVProgressHUD.dismiss()
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        
                        SVProgressHUD.dismiss()
                        
                        let markValue : Int = response["toast_id"] as! Int
                        
                        self.toast_id = ("\(markValue)")
                        self.toast_title = String(format: "%@",response["toast_title"]! as! String)

                        
                        // create object to pass via notification
                        
                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
                        
                        
                        let userInfo = ["newData": toastArray]
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateList_Notification), object: nil, userInfo: userInfo)
                        
                        //                        SVProgressHUD.showInfo(withStatus: "Toast Added Successfully", maskType: .gradient)
                        
                        //More
                        func handleCancel(_ alertView: UIAlertAction!)
                        {
                            self.dismiss(animated: true, completion: nil)
                            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "TChatViewController") as! TChatViewController
                            chatVC.selectedToastId = self.toast_id
                            chatVC.selectedToast_Title = self.toast_title
                            chatVC.screenTag = 2
                            chatVC.toast_message = self.message
                            chatVC.toast_image = self.toast_image
                            self.navigationController?.pushViewController(chatVC, animated: true)
                            //self.performSegue(withIdentifier: "chatViewUpdate", sender: self)
                        }
                        
                        let alert = UIAlertController(title: nil, message: kToastCreatedMsg, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:handleCancel))
                        
                        alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                        //                        ((self.navigationController)! as UINavigationController).popToRootViewController(animated: true)
                        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "chatViewUpdate")
        {
//            if let writeMsgVc: TCreateToast_WriteMsgVC = segue.destination as? TCreateToast_WriteMsgVC {
//                
//                writeMsgVc.isEditMode = false
//                writeMsgVc.isCreatingToast = true
//                writeMsgVc.selected_ToastId = toast_id as String
//                writeMsgVc.selected_ToastTitle = toast_title as String
//                
//            }
        }
    }
}

extension TCreateToast_AddCollabVC: THContactPickerDelegate {
    func contactPicker(_ contactPicker: THContactPickerView!, textFieldDidChange textField: UITextField!) {
        if contactPicker == self.collabolators_picker {
            self.filteredEmails.removeAll()
            self.suggestion_table.isHidden = false
            guard let textToSearch = textField.text else { return }
            for email in self.emailArray
            {
                if email.lowercased().contains(textToSearch.lowercased())
                {
                    self.filteredEmails.append(email)
                }
            }
            if(self.filteredEmails.count == 0)
            {
                self.suggestion_table.isHidden = true
            }
            else{
                self.suggestion_table.isHidden = false
                self.suggestion_table.reloadData()
                
            }
        }
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, textFieldDidBeginEditing textField: UITextField!) {
        if contactPicker == self.collabolators_picker
        {
            let temp = textField.text
            if temp == "Enter emails separated by a space or a newline"
            {
                textField.text = ""
            }
            self.suggestion_table.isHidden = true
            self.scrollView.setContentOffset(CGPoint(x:0,y:300), animated: true)
        }
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, textFieldShouldReturn textField: UITextField!) -> Bool {
        return true
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, didSelectContact contact: Any!) {
        
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, didRemoveContact contact: Any!) {
        if contactPicker == collabolators_picker {
            guard let contact = contact as? String else { return }
            self.remove(contact: contact, contacts: &self.selectedEmails)
        }
    }
    
    // MARK: Helper
    func addContact(contact: String, contactPicker: THContactPickerView) {
        let style = THContactViewStyle(textColor: UIColor.black, backgroundColor: UIColor(hex : "e3d1a1"), cornerRadiusFactor: 2)
        let seletedStyle = THContactViewStyle(textColor: UIColor.black, backgroundColor: UIColor(hex : "e3d1a1"), cornerRadiusFactor: 2)
        contactPicker.addContact(contact, withName: contact, with: style, andSelectedStyle: seletedStyle)
    }
    
    func remove(contact: String, contacts: inout [String]) {
        contacts = contacts.filter({ $0 != contact })
    }
    
    func clearContact(contacts: inout [String]) {
        contacts.removeAll()
    }
}

//
//  TEditToastViewController.swift
//  Toast
//
//  Created by Anish Pandey on 22/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import MobileCoreServices
import Contacts
import ContactsUI
import SDWebImage

class TEditToastViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource   {

    
    @IBOutlet weak var txt_additional_message: UITextView!
    @IBOutlet weak var txt_due_date: UITextField!
    @IBOutlet weak var txt_group_name: UITextField!
    @IBOutlet weak var txt_category: UITextField!
    @IBOutlet weak var txt_toastes: UITextView!
    
    @IBOutlet var toastes_picker: THContactPickerView!
    @IBOutlet weak var txt_collaborators: UITextView!
    
    @IBOutlet var collaborators_picker: THContactPickerView!
    @IBOutlet weak var switch_notification: UISwitch!
    @IBOutlet weak var table_toates: UITableView!
    @IBOutlet weak var table_collaborators: UITableView!
    @IBOutlet weak var table_categories: UITableView!
    @IBOutlet weak var scroll_view: UIScrollView!
    
    var contactStore = CNContactStore()
    var emailArray = ["test@test.com","ahsan@exelion.com"]
    var filteredEmails = [String]()
    var selectedCollaboraterEmails = [String]()
    var selectedToatesEmails = [String]()
    var emailDictionary = [String : String]()
    var filteredCategories = [String]()
    var deletedToasteeEmails = [String]()
    var deletedCollaboratorEmails = [String]()
    let datePicker = UIDatePicker()
    var selectedDateTime = ""


    
    var categories = ["Current","Upcoming"]
    let categoriesPicker = UIPickerView()
    
    // to copy respective field values
    var selectedTheme:String = String()
    var selectedGategory:String = String()
    var selectedDueDate:String = String()
    var selectedGroupName:String = String()
    var selectedOtherGategory:String = String()
    var selectedSwitchStatus:String = String() //switch status
    
    var passFlag = "Y" // for txtvw_ToastTheme
    var passFlag1 = "Y" // for txtFld_GroupName
    var passFlag2 = "Y" // for btn_category
    var dummyTheme:String = "Additional details to the collaborators about the Toast."
    
    
    var toasteeUsersArr: NSMutableArray = NSMutableArray() // carries all toastees from modal class
    var membersArr: NSMutableArray = NSMutableArray() // carries all members from modal class
    var kbHeight: CGFloat = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.GetAllCategories()
        self.fetchContacts()
        self.table_toates.isHidden = true
        self.table_toates.isHidden = true
        
        self.table_toates.isHidden = true
        self.table_toates.isHidden = true
        
        self.table_collaborators.delegate = self
        self.table_collaborators.dataSource = self
        
        self.table_categories.delegate = self
        self.table_categories.dataSource = self
        
        self.table_toates.delegate = self
        self.table_toates.dataSource = self
        
        self.toastes_picker.delegate = self
        self.toastes_picker.maxNumberOfLines = 4
        self.collaborators_picker.delegate = self
        self.collaborators_picker.maxNumberOfLines = 4
        
        self.CustomiseView()
        
        self.txt_additional_message.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_additional_message.clipsToBounds = true
        self.txt_additional_message.layer.borderWidth = 1.0
        self.txt_additional_message.layer.cornerRadius = 5.0
        
        self.txt_due_date.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_due_date.clipsToBounds = true
        self.txt_due_date.layer.borderWidth = 1.0
        self.txt_due_date.layer.cornerRadius = 5.0

        self.txt_group_name.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_group_name.clipsToBounds = true
        self.txt_group_name.layer.borderWidth = 1.0
        self.txt_group_name.layer.cornerRadius = 5.0

        
        self.txt_additional_message.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_additional_message.clipsToBounds = true
        self.txt_additional_message.layer.borderWidth = 1.0
        self.txt_additional_message.layer.cornerRadius = 5.0

        
        self.txt_category.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_category.clipsToBounds = true
        self.txt_category.layer.borderWidth = 1.0
        self.txt_category.layer.cornerRadius = 5.0
        self.txt_category.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        
        self.txt_toastes.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_toastes.clipsToBounds = true
        self.txt_toastes.layer.borderWidth = 1.0
        self.txt_toastes.layer.cornerRadius = 5.0
        
        self.txt_collaborators.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_collaborators.clipsToBounds = true
        self.txt_collaborators.layer.borderWidth = 1.0
        self.txt_collaborators.layer.cornerRadius = 5.0
    
        
        self.setLeftPaddingPoints(3, textField: self.txt_group_name)
        self.setLeftPaddingPoints(3, textField: self.txt_due_date)
        self.setLeftPaddingPoints(3, textField: self.txt_category)
        
        self.switch_notification.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem : .done,target: nil, action: #selector(donePressedForEmails))
        
        toolbar.setItems(([doneButton]), animated: true)
        
        self.txt_collaborators.inputAccessoryView = toolbar
        self.txt_toastes.inputAccessoryView = toolbar
        
        self.txt_category.delegate = self
        self.txt_group_name.delegate = self
        self.txt_due_date.delegate = self
        self.txt_additional_message.delegate = self
        self.txt_toastes.delegate = self
        self.txt_collaborators.delegate = self
        
        self.createTimePicker()

        
        self.txt_category.text = viewToastObj.categoryName
        self.txt_group_name.text = viewToastObj.from_text_original
        self.txt_due_date.text = viewToastObj.releasedDate
        self.txt_additional_message.text = viewToastObj.theme
        if(viewToastObj.toast_notification == "Y")
        {
            self.switch_notification.isOn = true
        }
        else
        {
            self.switch_notification.isOn = false

        }
        
        toasteeUsersArr =  viewToastObj.toasteeUsersArr.mutableCopy() as! NSMutableArray
        membersArr =  viewToastObj.membersArr.mutableCopy() as! NSMutableArray
        
        for item in toasteeUsersArr
        {
            self.selectedToatesEmails.append((item as! AddMemberModel).member_Email_id)
            self.selectedToatesEmails = Array(Set(self.selectedToatesEmails))
            self.addContact(contact: (item as! AddMemberModel).member_Email_id, contactPicker: toastes_picker)
        }
        self.showsToatesselectedEmails()
        
        for item in membersArr
        {
            self.selectedCollaboraterEmails.append((item as! AddMemberModel).member_Email_id)
            self.selectedCollaboraterEmails = Array(Set(self.selectedCollaboraterEmails))
            self.addContact(contact: (item as! AddMemberModel).member_Email_id, contactPicker: collaborators_picker)
        }
        self.showsCollaboratorselectedEmails()
        
        
        if(self.txt_group_name.text?.characters.count == 0)
        {
            self.txt_group_name.text = "From Group Name"
        }
        
        if(self.txt_additional_message.text?.characters.count == 0)
        {
            self.txt_additional_message.text = "Additional details to the collaborators about the toast"
        }
        
        if(self.txt_additional_message.text?.characters.count == 0)
        {
            self.txt_additional_message.text = "Additional details to the collaborators about the toast"
        }

        if(self.txt_collaborators.text.characters.count == 0)
        {
            self.txt_collaborators.text = "Enter emails separated by a space or a comma"
        }
    }
    
    func donePressedForEmails()
    {
        self.view.endEditing(true)
        self.table_categories.isHidden = true
        self.table_toates.isHidden = true
        self.table_collaborators.isHidden = true
    }
    func createTimePicker()
    {
        datePicker.datePickerMode = .date
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem : .done,target: nil, action: #selector(donePressed))
        
        toolbar.setItems(([doneButton]), animated: true)
        
        self.txt_due_date.inputAccessoryView = toolbar
        
        self.txt_due_date.inputView = datePicker
    }
    
    func donePressed()
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "YYYY-MM-d"
        self.selectedDateTime = dateFormatter.string(from: datePicker.date)
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        txt_due_date.text = dateFormatter.string(from: datePicker.date)
        
        self.view.endEditing(true)
        
    }

    
    
    func setLeftPaddingPoints(_ amount:CGFloat,textField :UITextField){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func btn_DoneClicked(_ sender: UIButton) {
        //uncomment below
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        SVProgressHUD.show(with: .gradient)
        
    
        self.editToastDetails()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCategoryAdded_Notification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kEditIntendedMember_Notification), object: nil)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    
    func checkIfCategoryIsListed() -> Bool
    {
        return self.categories.contains(self.txt_category.text!)
    }
    
    // MARK: - WS Calls
    func editToastDetails()
    {
        /*{
         "service": "toasteditdetails",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "toast_id": "4",
         "action_flag": "edit",
         "theme": "Wish you all the best buddy!",
         "released_date": "2016-12-10 15:30:45",
         "from_text": "Play Group",
         "category_name": "Other",
         "other_category_name": "Cricket",
         "toast_notification": "N",
         "multipart": "Y",
         "deleted_toastee": ["swapnil@arkenea.com"],
         "toastee_users": ["pankaj@arkenea.com", "meghna226666@arkenea.com"],
         "deleted_members": ["subodh@arkenea.com"],
         "members": ["dasharath@arkenea.com", "dinesh@arkenea.com"]
         }
         // For image
         $_FILES['image']*/
        
        //let indexPathForSection1 = NSIndexPath(row: 0, section: 1)
        //let cell = tblView_EditToast.cellForRow(at: indexPathForSection1 as IndexPath) as! ToasteThemeCell
        
        if(((self.txt_category.text?.characters.count)! > 0))
        {
            
//            //let finalTosteeArray : NSMutableArray = NSMutableArray()
//            for tostee in toasteeUsersArr
//            {
//                finalTosteeArray.add((tostee as! AddMemberModel).member_Email_id)
//            }
//            
//            let finalMemberArray : NSMutableArray = NSMutableArray()
//            for member in membersArr
//            {
//                finalMemberArray.add((member as! AddMemberModel).member_Email_id)
//            }
//            
//            // for Toastees
//            let Intended_swiftArray = NSArray(array:finalTosteeArray)
//            let Intended_stringRepresentation = (Intended_swiftArray as! Array).joined(separator: ",")
//            print(Intended_stringRepresentation.description)
//            
//            // for Members
//            let Member_swiftArray = NSArray(array:finalMemberArray)
//            let Member_stringRepresentation = (Member_swiftArray as! Array).joined(separator: ",")
//            print(Member_stringRepresentation.description)
//            
//            // Deleted data
//            let deletedToastee_swiftArray = NSArray(array:arr_deletedToastee)
//            let deletedToastee_stringRepresentation = (deletedToastee_swiftArray as! Array).joined(separator: ",")
//            print(deletedToastee_stringRepresentation.description)
//            
//            let deletedMember_swiftArray = NSArray(array:arr_deletedMember)
//            let deletedMember_stringRepresentation = (deletedMember_swiftArray as! Array).joined(separator: ",")
//            print(deletedMember_stringRepresentation.description)
//            
            //            // convert text to support emoticons
            //            let  str = viewToastObj.theme
            //            let textViewData : NSData = str.data(using: String.Encoding.nonLossyASCII)! as NSData
            //            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
            
            if (selectedGroupName.characters.count < 1 || selectedGroupName == "Group Name" )
            {
                selectedGroupName = ""
            }
            var category = ""
            var other_category = ""
            if(self.checkIfCategoryIsListed())
            {
                category = self.txt_category.text!
            }
            else
            {
                other_category = self.txt_category.text!
            }
            
            let dataObj = NetworkData()
            NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
            if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
            {
                SVProgressHUD.show(with: .gradient)
                let parameters: NSDictionary = ["service": "toasteditdetails", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "toast_id" : viewToastObj.toast_id, "action_flag" : "edit", "theme" : self.txt_additional_message.text!, "released_date" : self.selectedDateTime, "from_text": self.txt_group_name.text!, "category_name" : category, "other_category_name" : other_category, "toast_notification" : selectedSwitchStatus, "multipart" : "N", "deleted_toastee" : self.deletedToasteeEmails, "toastee_users" : self.selectedToatesEmails, "members" : self.selectedCollaboraterEmails, "deleted_members" : self.deletedCollaboratorEmails]
                
                var profilePic: String = ""
//                if !true {
////                    let imageData = UIImagePNGRepresentation(selectedToatesEmails)
////                    let filePath: NSString = (NSTemporaryDirectory() as NSString).appendingPathComponent("userimage.png") as NSString
////                    do {
////                        try imageData?.write(to: URL(fileURLWithPath: filePath as String), options: .atomic)
////                        profilePic = filePath as String
////                    } catch {
////                        
////                    }
//                }
                
                WebService.multipartRequest(postDict: parameters, ProfileImage: profilePic){  (response, error) in
                    print(response)
                    let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                    if(statusToken as String == "Success" as String)
                    {
                        DispatchQueue.main.async(execute: {
                            
                            self.navigationController?.navigationBar.isUserInteractionEnabled = true
                            
                            SVProgressHUD.dismiss()
                            // create object to pass via notification
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshToastList_Notification), object: nil)
                            
                            let toastArray:NSArray = (response["toast_list"] as! NSArray)
                            
                            
                            let userInfo = ["newData": toastArray]
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLeftToast_Notification), object: nil, userInfo: userInfo) // To reload the view call the notification. As its registered in ToastVC only
                            
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
            
        }else
        {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            // SVProgressHUD.showInfo(withStatus: "Please fill all the mandatory fields.", maskType: .gradient)
            
            if passFlag1 == "N"
            {
                SVProgressHUD.showInfo(withStatus: kHiglightFieldMsg, maskType: .gradient)
            }
            else
            {
                SVProgressHUD.showInfo(withStatus: "Please fill all the mandatory fields.", maskType: .gradient)
            }
        }
        
    }

    func textFieldDidChange(_ textField: UITextField) {
        
        if textField == self.txt_category{
            self.filteredCategories.removeAll()
            self.table_categories.isHidden = false
            let textToSearch = self.txt_category.text
            for item in self.categories
            {
                if item.lowercased().contains(textToSearch!.lowercased())
                {
                    self.filteredCategories.append(item)
                }
            }
            if(self.filteredCategories.count == 0)
            {
                self.table_categories.isHidden = true
            }
            else{
                self.table_categories.isHidden = false
                self.table_categories.reloadData()
                
            }
            
        }
    }

    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Edit Toast Details")
        
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TEditToastViewController.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        let btn_Done: UIButton = UIButton(type: UIButtonType.custom)
        btn_Done.frame = CGRect(x: 0, y: -25, width: 38, height: 30)
        btn_Done.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15.5)
        btn_Done.setTitle("Done", for: .normal)
        btn_Done.addTarget(self, action: #selector(self.btn_DoneClicked(_:)), for: UIControlEvents.touchUpInside)
        let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_Done)
        let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItem.width = -10
        let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
        self.navigationItem.setRightBarButtonItems(rightArray as?
            [UIBarButtonItem], animated: true)
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
                self.emailArray.append(email.value as String)
                self.emailDictionary[email.value as String] = item.givenName + " " + item.familyName
            }
        }
        
    }

    // MARK: - WS Calls
    func GetAllCategories()
    {
        /*"{
         ""service"": ""toastcategories"",
         ""user_id"": ""3"",
         ""access_token"": ""S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au""
         }"*/
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "toastcategories", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    print(response["toast_categories"])
                    if let dataRec = response["toast_categories"] as? NSArray
                    {
                        print(dataRec)
                        self.categories = (dataRec as? [String])!
                    }
                    
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
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

    
    override var hidesBottomBarWhenPushed: Bool
        {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    
    @objc func  backBtnClicked(_ sender: UIButton!)
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCategoryAdded_Notification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kEditIntendedMember_Notification), object: nil)
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.table_collaborators || tableView == self.table_toates)
        {
            return self.filteredEmails.count
        }
        if(tableView == self.table_categories)
        {
            return self.filteredCategories.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if(tableView == self.table_toates)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "personscell")
            let email = self.filteredEmails[indexPath.row]
            cell.detailTextLabel?.text = email
            
            if let name = emailDictionary[email] {
                cell.textLabel?.text = name
            } else {
                cell.textLabel?.text = ""
            }
        }
        else if(tableView == self.table_collaborators)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "personscell")
            let email = self.filteredEmails[indexPath.row]
            cell.detailTextLabel?.text = email
            
            if let name = emailDictionary[email] {
                cell.textLabel?.text = name
            } else {
                cell.textLabel?.text = ""
            }
        }
        else if(tableView == self.table_categories)
        {
            cell.textLabel?.text = self.filteredCategories[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.table_collaborators)
        {
            self.table_collaborators.isHidden = true
            if self.filteredEmails.count < indexPath.row { return }
            if(!self.selectedCollaboraterEmails.contains(self.filteredEmails[indexPath.row]))
            {
                self.selectedCollaboraterEmails.append(self.filteredEmails[indexPath.row])
                self.addContact(contact: self.filteredEmails[indexPath.row], contactPicker: collaborators_picker)
            }
            self.showsCollaboratorselectedEmails()
        }
        else if(tableView == self.table_toates)
        {
            self.table_toates.isHidden = true
            if self.filteredEmails.count < indexPath.row { return }
            if(!self.selectedToatesEmails.contains(self.filteredEmails[indexPath.row]))
            {
                self.selectedToatesEmails.append(self.filteredEmails[indexPath.row])
                self.addContact(contact: self.filteredEmails[indexPath.row], contactPicker: toastes_picker)
            }
            self.showsToatesselectedEmails()
        }
        else
        {
            self.txt_category.text = self.filteredCategories[indexPath.row]
            self.table_categories.isHidden = true
            self.view.endEditing(true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == table_collaborators || tableView == table_toates {
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
        if tableView == table_collaborators || tableView == table_toates {
            if section == 0 {
                return 45
            }
        }
        
        return 0
    }
    
    func showsCollaboratorselectedEmails()
    {
        return
        self.txt_collaborators.text = ""
        let attributedText = NSMutableAttributedString()
        
        
        for email in self.selectedCollaboraterEmails
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
            
            
            let emailAttrib = NSMutableAttributedString(string: tempEmail, attributes: [NSBackgroundColorAttributeName : UIColor(hex : "e3d1a1"), NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)])
            
            
            let comma = NSMutableAttributedString(string: " , ", attributes: [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(emailAttrib)
            
            attributedText.append(comma)
            
            
            self.txt_collaborators.attributedText = attributedText
            
        }
    }
    
    func showsToatesselectedEmails()
    {
        return
        self.txt_toastes.text = ""
        let attributedText = NSMutableAttributedString()
        
        
        for email in self.selectedToatesEmails
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
            
            
            let emailAttrib = NSMutableAttributedString(string: tempEmail, attributes: [NSBackgroundColorAttributeName : UIColor(hex : "e3d1a1"), NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)])
            
            
            let comma = NSMutableAttributedString(string: " , ", attributes: [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(emailAttrib)
            
            attributedText.append(comma)
            
            
            self.txt_toastes.attributedText = attributedText
            
        }
    }

    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let  char = text.cString(using: String.Encoding.utf8)!
        let isReturnKey = strcmp(char,"\\n")
        
        if(textView == self.txt_toastes)
        {
            self.table_collaborators.isHidden = true
            if (isReturnKey == -82) {
                
                let arr = self.txt_toastes.text.components(separatedBy: ",")
                print(arr[arr.count - 1])
                if(!self.selectedToatesEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedToatesEmails.append(arr[arr.count - 1])
                }
                self.showsToatesselectedEmails()
                return false
                
            }

            if(text.characters.count > 1)
            {
                let arr = text.components(separatedBy: "\n")
                for item in arr
                {
                    if(!self.selectedToatesEmails.contains(item))
                    {
                        self.selectedToatesEmails.append(item)
                    }
                }
                self.showsToatesselectedEmails()
                return false
            }
            if(text == ",")
            {
                let arr = self.txt_toastes.text.components(separatedBy: ",")
                print(arr[arr.count - 1])
                if(!self.selectedToatesEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedToatesEmails.append(arr[arr.count - 1])
                }
                self.showsToatesselectedEmails()
                return false
            }
            if(text == " ")
            {
                let arr = self.txt_toastes.text.components(separatedBy: " ")
                print(arr[arr.count - 1])
                if(!self.selectedToatesEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedToatesEmails.append(arr[arr.count - 1])
                }
                self.showsToatesselectedEmails()
                return false
            }
            
        }
        
        if(textView == self.txt_collaborators)
        {
            self.table_toates.isHidden = true
            if (isReturnKey == -82) {
                
                let arr = self.txt_collaborators.text.components(separatedBy: ",")
                print(arr[arr.count - 1])
                if(!self.selectedCollaboraterEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedCollaboraterEmails.append(arr[arr.count - 1])
                }
                self.showsCollaboratorselectedEmails()
                return false
                
            }
            if(text.characters.count > 1)
            {
                let arr = text.components(separatedBy: "\n")
                for item in arr
                {
                    if(!self.selectedCollaboraterEmails.contains(item))
                    {
                        self.selectedCollaboraterEmails.append(item)
                    }
                }
                self.showsCollaboratorselectedEmails()
                return false
            }
            if(text == ",")
            {
                let arr = self.txt_toastes.text.components(separatedBy: ",")
                print(arr[arr.count - 1])
                if(!self.selectedCollaboraterEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedCollaboraterEmails.append(arr[arr.count - 1])
                }
                self.showsCollaboratorselectedEmails()
                return false
            }
            if(text == " ")
            {
                let arr = self.txt_toastes.text.components(separatedBy: " ")
                print(arr[arr.count - 1])
                if(!self.selectedCollaboraterEmails.contains(arr[arr.count - 1]))
                {
                    self.selectedCollaboraterEmails.append(arr[arr.count - 1])
                }
                self.showsCollaboratorselectedEmails()
                return false
            }
            
        }

        
        
        return true
    }
    
    func checkIfEmailsValid(selectedEmails : [String]) -> Bool
    {
        for item in selectedEmails
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
    
    func returnTextAfterComman(txt_toaste : String,type : String) -> String
    {
        var text : String = ""
        let arr = txt_toaste.components(separatedBy: ",")
        for item in arr
        {
            if(type == "toaste")
            {
                if(!self.selectedToatesEmails.contains(item))
                {
                    text =  item
                }
            }
            else if(type == "collaborator")
            {
                if(!self.selectedToatesEmails.contains(item))
                {
                    text =  item
                }
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
        
        
        if textView == self.txt_toastes{
            self.filteredEmails.removeAll()
            self.table_toates.isHidden = false
            let textToSearch = self.returnTextAfterComman(txt_toaste: self.txt_toastes.text,type: "toaste")
            for email in self.emailArray
            {
                if email.contains(textToSearch)
                {
                    self.filteredEmails.append(email)
                }
            }
            if(self.filteredEmails.count == 0)
            {
                self.table_toates.isHidden = true
            }
            else{
                self.table_toates.isHidden = false
                self.table_toates.reloadData()
                
            }
        }
        
        if textView == self.txt_collaborators{
            self.filteredEmails.removeAll()
            self.table_collaborators.isHidden = false
            let textToSearch = self.returnTextAfterComman(txt_toaste: self.txt_collaborators.text, type :"collaborator")
            for email in self.emailArray
            {
                if email.contains(textToSearch)
                {
                    self.filteredEmails.append(email)
                }
            }
            if(self.filteredEmails.count == 0)
            {
                self.table_collaborators.isHidden = true
            }
            else{
                self.table_collaborators.isHidden = false
                self.table_collaborators.reloadData()
                
            }
        }

    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == self.txt_toastes
        {
            
            self.table_toates.isHidden = false
            self.table_collaborators.isHidden = true
            
            self.scroll_view.setContentOffset(CGPoint(x:0,y:300), animated: true)
        }
        
        if textView == self.txt_collaborators
        {
            if(self.txt_collaborators.text == "Enter emails separated by a space or a comma")
            {
                self.txt_collaborators.text = ""
            }
            
            self.table_toates.isHidden = true
            self.table_collaborators.isHidden = false
            
            self.scroll_view.setContentOffset(CGPoint(x:0,y:450), animated: true)
        }

        
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.becomeFirstResponder()
        self.view.endEditing(true)
        self.scroll_view.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == self.txt_group_name)
        {
            if(self.txt_group_name.text == "From Group Name")
            {
                self.txt_group_name.text = ""
            }
        }
        if(textField == self.txt_due_date)
        {
            if(self.txt_group_name.text == "Due Date")
            {
                self.txt_group_name.text = ""
            }
        }
        

        
        //self.scroll_view.setContentOffset(CGPoint(x:0,y:250), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
}

extension TEditToastViewController: THContactPickerDelegate {
    func contactPicker(_ contactPicker: THContactPickerView!, textFieldDidChange textField: UITextField!) {
        if contactPicker == self.toastes_picker{
            self.filteredEmails.removeAll()
            guard let textToSearch = textField.text else { return }
            self.table_toates.isHidden = textToSearch.isEmpty
            for email in self.emailArray
            {
                if email.lowercased().contains(textToSearch.lowercased())
                {
                    self.filteredEmails.append(email)
                }
            }
            if(self.filteredEmails.count == 0)
            {
                self.table_toates.isHidden = true
            }
            else{
                self.table_toates.isHidden = false
                self.table_toates.reloadData()
                
            }
        } else if contactPicker == self.collaborators_picker {
            self.filteredEmails.removeAll()
            guard let textToSearch = textField.text else { return }
            self.table_collaborators.isHidden = textToSearch.isEmpty
            for email in self.emailArray
            {
                if email.lowercased().contains(textToSearch.lowercased())
                {
                    self.filteredEmails.append(email)
                }
            }
            if(self.filteredEmails.count == 0)
            {
                self.table_collaborators.isHidden = true
            }
            else{
                self.table_collaborators.isHidden = false
                self.table_collaborators.reloadData()
                
            }
        }
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, textFieldDidBeginEditing textField: UITextField!) {
        if contactPicker == self.toastes_picker
        {
            self.table_toates.isHidden = false
            self.table_collaborators.isHidden = true
            
            self.scroll_view.setContentOffset(CGPoint(x:0,y:300), animated: true)
        }
        
        if contactPicker == self.collaborators_picker
        {
            if(self.txt_collaborators.text == "Enter emails separated by a space or a comma")
            {
                self.txt_collaborators.text = ""
            }
            
            self.table_toates.isHidden = true
            self.table_collaborators.isHidden = false
            
            self.scroll_view.setContentOffset(CGPoint(x:0,y:450), animated: true)
        }
        
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, textFieldShouldReturn textField: UITextField!) -> Bool {
        return true
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, didSelectContact contact: Any!) {
        
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, didRemoveContact contact: Any!) {
        guard let contact = contact as? String else { return }
        if contactPicker == toastes_picker {
            self.remove(contact: contact, contacts: &self.selectedToatesEmails)
        } else if contactPicker == collaborators_picker {
            self.remove(contact: contact, contacts: &self.selectedCollaboraterEmails)
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


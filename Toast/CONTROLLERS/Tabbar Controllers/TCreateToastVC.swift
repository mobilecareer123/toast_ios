//
//  TCreateToastVC.swift
//  Toast
//
//  Created by Anish Pandey on 17/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SDWebImage

class TCreateToastVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    

    var contactStore = CNContactStore()
    var emailArray = ["test@test.com","ahsan@exelion.com"]
    var filteredEmails = [String]()
    var selectedEmails = [String]()
    var emailDictionary = [String : String]()
    var filteredCategories = [String]()

    var isUploadImage = false

    
    var categories = ["Current","Upcoming"]
    let categoriesPicker = UIPickerView()
    var searchController = UISearchController()
    var resultController = UITableViewController()
    
    @IBOutlet weak var category_suggestion: UITableView!
    @IBOutlet weak var txt_categories: UITextField!
    @IBOutlet weak var txt_toaste: UITextView!
    
    @IBOutlet weak var toaste_picker: THContactPickerView!
    @IBOutlet weak var suggestion_table: UITableView!
    @IBOutlet weak var scroll_view: UIScrollView!
    
    @IBOutlet weak var btn_Next: ZFRippleButton!
    @IBOutlet weak var btn_Done: ZFRippleButton!
    
    @IBOutlet weak var tblView_CreatToast: UITableView!
    
    
    
    let toasteePicker = CNContactPickerHandler()
    var arr_intenedUsers:NSMutableArray = NSMutableArray()
    var rmDateSelectionViewController: RMDateSelectionViewController!
    var txtFld_Active:UITextField!
    
    var toast_id : String = String() // set value in response for addition of toast
    var toast_title : String = String() // set value in response for addition of toast
    var contactPicker = CNContactPickerViewController()
    let dummyEmailPlaceholder = "Enter emails separated by a space or a newline. Press enter to return."
    var selectedDueDate:String = String()
    var segTag = "Y" // to check if the value is set for the filed -  and highlight the field
    var segTag1 = "Y"
    
    var isCategorySelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.GetAllCategories()
        self.fetchContacts()
        self.suggestion_table.isHidden = true
        self.category_suggestion.isHidden = true
        
        self.suggestion_table.delegate = self
        self.suggestion_table.dataSource = self
        
        self.category_suggestion.delegate = self
        self.category_suggestion.dataSource = self
        
        self.txt_categories.delegate = self
        self.txt_toaste.delegate = self
        
        self.txt_categories.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        self.txt_categories.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_categories.clipsToBounds = true
        self.txt_categories.layer.borderWidth = 1.0
        self.txt_categories.layer.cornerRadius = 5.0
        self.setLeftPaddingPoints(3, textField: self.txt_categories)

        self.txt_toaste.borderColor = UIColor(hexCode: 0xE8E8E8)
        self.txt_toaste.clipsToBounds = true
        self.txt_toaste.layer.borderWidth = 1.0
        self.txt_toaste.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        self.txt_toaste.layer.cornerRadius = 5.0

      
        //self.view.backgroundColor = UIColor.clear
        
        self.view.layoutIfNeeded()
        
        self.CustomiseView()
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem : .done,target: nil, action: #selector(typeSelected))
        
        toolbar.setItems(([doneButton]), animated: true)
        
        self.txt_toaste.inputAccessoryView = toolbar
        
//        let tapGesture = UITapGestureRecognizer(target: self,action: #selector(tapped))
//        tapGesture.numberOfTapsRequired = 1
//        self.view.addGestureRecognizer(tapGesture)
        
        // regis table view cell
        
        // contact pickerview
        toaste_picker.delegate = self
        toaste_picker.maxNumberOfLines = 4
    }
    
    func tapped(recongnizer : UITapGestureRecognizer)
    {
                print("Print")
    }


    
//    @IBAction func addImageClicked(_ sender: Any) {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
//        {
//            let image = UIImagePickerController()
//            image.delegate = self
//            image.sourceType = UIImagePickerControllerSourceType.photoLibrary
//            image.allowsEditing = true
//            
//            self.present(image, animated: true)
//            {
//                
//            }
//            
//        }
//    }

   
    
    func checkIfCategoryIsListed() -> Bool
    {
        return self.categories.contains(self.txt_categories.text!)
    }
    
//    func imagePickerControllerDidCancel(_ picker:UIImagePickerController)
//    {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
//    {
//        self.isUploadImage = true
//        self.image_toast.image = info[UIImagePickerControllerEditedImage] as! UIImage
//        self.image_toast.alpha = 1
//        self.dismiss(animated: true, completion: nil)
//        
//    }

    
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
    
    func typeSelected()
    {
        let def = UserDefaults.standard
        def.setValue(self.txt_categories.text, forKey: "Category")
        self.suggestion_table.isHidden = true
        self.view.endEditing(true)
        self.scroll_view.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    @IBAction func groupToast(_ sender: Any) {
        if (self.selectedEmails.count == 0)
        {
            
            let alert = UIAlertController(title: "Toastes", message: "Please enter emails of toastes", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if (!self.isCategorySelected || !categoriyIsValid())
        {
            let alert = UIAlertController(title: "Category", message: "Please select category of toast", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        if !self.checkIfEmailsValid()
        {
            let alert = UIAlertController(title: "Email", message: "Please specify correct emails", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }


        //self.CreateToastCalled()
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "TCreateToast_AddCollabVC") as! TCreateToast_AddCollabVC
        if(self.checkIfCategoryIsListed())
        {
            nextVC.category = self.txt_categories.text!
            nextVC.ohter_category = ""
        }
        else
        {
            nextVC.category = "Other"
            nextVC.ohter_category = self.txt_categories.text!
        }
        nextVC.toast_to_emails = self.selectedEmails
        nextVC.isImageSelected = self.isUploadImage
        navigationController?.pushViewController(nextVC, animated: true)
        //self.performSegue(withIdentifier: "create2addCollabSeg", sender: self)
    }
    
    
//    func CreateSingleToastCalled()
//    {
//        let dataObj = NetworkData()
//        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
//        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
//        {
//            SVProgressHUD.show(withStatus: "Creating Toast ... ", maskType: .gradient)
//            
//            // prepare array
//            
//            
//            let parameters: NSDictionary = ["service": "createnewtoast", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "category_name":self.txt_categories.text, "other_category_name":"", "toast_notification":"Y", "toastee_users":self.selectedEmails, "multipart":"N"]
//            
//            var toastImg: String = ""
//            if (self.isUploadImage) {
//                let imageData = UIImagePNGRepresentation(self.image_toast.image!)
//                let filePath: NSString = (NSTemporaryDirectory() as NSString).appendingPathComponent("userimage.png") as NSString
//                
//                do {
//                    try imageData?.write(to: URL(fileURLWithPath: filePath as String), options: .atomic)
//                    toastImg = filePath as String
//                } catch {
//                    
//                }
//            }
//            
//            WebService.multipartRequest(postDict: parameters, ProfileImage: toastImg){  (response, error) in
//                
//                SVProgressHUD.dismiss()
//                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
//                
//                if(statusToken as String == "Success" as String)
//                {
//                    DispatchQueue.main.async(execute: {
//                        
//                        SVProgressHUD.dismiss()
//                        
//                        let markValue : Int = response["toast_id"] as! Int
//                        
//                        self.toast_id = ("\(markValue)")
//                        self.toast_title = String(format: "%@",response["toast_title"]! as! String)
//                        
//                        // create object to pass via notification
//                        
//                        let toastArray:NSArray = (response["toast_list"] as! NSArray)
//                        
//                        
//                        let userInfo = ["newData": toastArray]
//                        
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateList_Notification), object: nil, userInfo: userInfo)
//                        
//                        func handleCancel(_ alertView: UIAlertAction!)
//                        {
//                            self.dismiss(animated: true, completion: nil)
//                            self.performSegue(withIdentifier: "create2addCollabSeg", sender: self)
//                        }
//                        
//                        let alert = UIAlertController(title: nil, message: kToastCreatedMsg, preferredStyle: UIAlertControllerStyle.alert)
//                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:handleCancel))
//                        
//                        alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
//                        self.present(alert, animated: true, completion: nil)
//                    })
//                }
//                else if(statusToken as String == "Error" as String)
//                {
//                    //                    let error_code = response["ErrorCode"] as! NSNumber
//                    DispatchQueue.main.async(execute: {
//                        SVProgressHUD.dismiss()
//                        let error_message:String =  String(format: "%@",response["Error"]! as! String)
//                        SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
//                    })
//                    
//                }
//                else
//                {
//                    DispatchQueue.main.async(execute: {
//                        SVProgressHUD.dismiss()
//                        SVProgressHUD.showInfo(withStatus: "Server response failed" as String, maskType: .gradient)
//                    })
//                    
//                    
//                }
//                
//            }
//        }
//        else
//        {
//            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
//        }
//        
//    }

    
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

    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Start a Toast")
        
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 20)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TCreateToastVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
    }
    
    override var hidesBottomBarWhenPushed: Bool
        {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        contactPicker = toasteePicker.configuredPeoplePickerViewController(sendingVC: self, memberType: "toastee")
        // set all data in view
        
        //        let indexPath = NSIndexPath(row: 0, section: 0)
        //        let cell = tblView_CreatToast.cellForRow(at: indexPath as IndexPath) as! ToasteThemeCell
        //
        //        cell.txtvw_ToastTheme.text = createToast_modal.toast_Theme_s1
        //        cell.lbl_DueDate.text! = createToast_modal.due_date_s1
        //        cell.txtFld_GroupName.text! = createToast_modal.groupName_s1
        //        arr_intenedUsers = createToast_modal.intended_users_s1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    // MARK: - Button Actions
    @IBAction func btn_DoneClicked(_ sender: Any) {
        hideKeyboard()
        
        if (segTag == "Y" && segTag1 == "Y")
        {
            if self.selectedEmails.count > 0
            {
                //createToast_modal.due_date_s1 = selectedDueDate
                //createToast_modal.intended_users_s1 = arr_intenedUsers
                //CreateToastCalled()

            }
            else
            {
                SVProgressHUD.dismiss()
                SVProgressHUD.showInfo(withStatus: kToasteeCountMsg, maskType: .gradient)
            }
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: kHiglightFieldMsg, maskType: .gradient)
            if(self.tblView_CreatToast.isCellVisible(section: 0, row: 0))
            {
                self.tblView_CreatToast.reloadData()
            }
            else
            {
                let indexPath = NSIndexPath(row: 0, section: 0)
                self.tblView_CreatToast.scrollToRow(at: indexPath as IndexPath,
                                                    at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    @IBAction func btn_NextClicked(_ sender: UIButton) {
        hideKeyboard()
        
        if (segTag == "Y" && segTag1 == "Y")
        {
            if arr_intenedUsers.count > 0
            {
                createToast_modal.due_date_s1 = selectedDueDate
                createToast_modal.intended_users_s1 = arr_intenedUsers
                self.performSegue(withIdentifier: "create2addCollabSeg", sender: self)
            }
            else
            {
                SVProgressHUD.dismiss()
                SVProgressHUD.showInfo(withStatus: kToasteeCountMsg, maskType: .gradient)
            }
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: kHiglightFieldMsg, maskType: .gradient)
            if(self.tblView_CreatToast.isCellVisible(section: 0, row: 0))
            {
                self.tblView_CreatToast.reloadData()
            }
            else
            {
                let indexPath = NSIndexPath(row: 0, section: 0)
                self.tblView_CreatToast.scrollToRow(at: indexPath as IndexPath,
                                                    at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    
    func hideKeyboard()
    {
        if(txtFld_Active != nil)
        {
            txtFld_Active.resignFirstResponder()
        }
    }
    
    @objc func  backBtnClicked(_ sender: UIButton!)
    {
        hideKeyboard()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kAddIntendedMember_Notification), object: nil)
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    // MARK: - Table View Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.suggestion_table)
        {
            return self.filteredEmails.count
        }
        else
        {
            return self.filteredCategories.count
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if(tableView == self.suggestion_table)
        {
            let pcell = UITableViewCell(style: .subtitle, reuseIdentifier: "personscell")
            let email = self.filteredEmails[indexPath.row]
            pcell.detailTextLabel?.text = email
            
            if let name = emailDictionary[email] {
                pcell.textLabel?.text = name
            } else {
                pcell.textLabel?.text = ""
            }
            cell = pcell
        }
        else if(tableView == self.category_suggestion)
        {
            self.isCategorySelected = true
            cell.textLabel?.text = self.filteredCategories[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if(tableView == self.suggestion_table)
        {
            print(self.filteredEmails[indexPath.row])
            if(!self.selectedEmails.contains(self.filteredEmails[indexPath.row]))
            {
                let email = self.filteredEmails[indexPath.row]
                self.selectedEmails.append(email)
                self.addContact(contact: email, contactPicker: toaste_picker)
            }
            self.showselectedEmails()
        }
        else
        {
            self.txt_categories.text = self.filteredCategories[indexPath.row]
            self.view.endEditing(true)
            self.category_suggestion.isHidden = true
        }
      
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
        self.txt_toaste.text = ""
        let attributedText = NSMutableAttributedString()
        
        
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

            
            let emailAttrib = NSMutableAttributedString(string: tempEmail, attributes: [NSBackgroundColorAttributeName : UIColor(hex : "e3d1a1"), NSForegroundColorAttributeName : UIColor.black ,NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)])
            
            
            let comma = NSMutableAttributedString(string: ", ", attributes: [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(emailAttrib)
            
            attributedText.append(comma)
    
            self.txt_toaste.attributedText = attributedText
            
        }
    }
    
    func deleteEmail(allEmails : String)
    {
        let emailArr = allEmails.components(separatedBy: ",")
        for email in emailArr
        {
            if(!self.selectedEmails.contains(email))
            {
                let index = self.selectedEmails.index(of: email)!
                self.selectedEmails.remove(at: index)
            }
        }
    }
   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let  char = text.cString(using: String.Encoding.utf8)!
        let isReturnKey = strcmp(char,"\\n")
        
        if(textView == self.txt_toaste)
        {
            //if (isBackSpace == -92) {
            //    print(self.txt_toaste.text)
            //    self.deleteEmail(allEmails: self.txt_toaste.text)
            //    self.showselectedEmails()
            //    return false
            //}
            
            if (isReturnKey == -82) {
                
                let arr = self.txt_toaste.text.components(separatedBy: ",")
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
                let arr = self.txt_toaste.text.components(separatedBy: ",")
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
                let arr = self.txt_toaste.text.components(separatedBy: " ")
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
        let arr = self.txt_toaste.text.components(separatedBy: ",")
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
        
        if textView == self.txt_toaste{
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
    
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if textField == self.txt_categories{
            self.filteredCategories.removeAll()
            self.category_suggestion.isHidden = false
            let textToSearch = self.txt_categories.text
            for item in self.categories
            {
                if item.lowercased().contains(textToSearch!.lowercased())
                {
                    self.filteredCategories.append(item)
                }
            }
            if(self.filteredCategories.count == 0)
            {
                self.category_suggestion.isHidden = true
            }
            else{
                self.category_suggestion.isHidden = false
                self.category_suggestion.reloadData()

            }

    }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.txt_toaste
        {
            //self.txt_toaste.textColor = UIColor.black

            let temp = textView.text
            if textView.text == "Enter emails separated by a space or a newline"
            {
                textView.text = ""
            }
        
            self.suggestion_table.isHidden = true
            
            self.scroll_view.setContentOffset(CGPoint(x:0,y:300), animated: true)
        }
        
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat,textField :UITextField){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.becomeFirstResponder()
        self.view.endEditing(true)
        self.scroll_view.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txt_categories
        {
            //self.txt_categories.textColor = UIColor.black
            let temp = textField.text
            if temp == "Select or type your category"
            {
                textField.text = ""
            }
            
            // display all categories
            if textField.text == "" {
                displayAllCategories()
            }
        }
        //self.scroll_view.setContentOffset(CGPoint(x:0,y:250), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.scroll_view.setContentOffset(CGPoint(x:0,y:0), animated: true)
        self.txt_categories.becomeFirstResponder()
        self.txt_toaste.becomeFirstResponder()
        hideKeyboard()
        self.view.endEditing(true)
        return true
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let txtFld = txtFld_Active
        {
            txtFld .resignFirstResponder()
        }
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addToastee2WriteCheerSeg")
        {
            if let writeMsgVc: TCreateToast_WriteMsgVC = segue.destination as? TCreateToast_WriteMsgVC {
                
                writeMsgVc.isEditMode = false
                writeMsgVc.isCreatingToast = true
                writeMsgVc.selected_ToastId = toast_id as String
                writeMsgVc.selected_ToastTitle = toast_title as String
                
            }
        }
    }
    
    // MARK: - Hepler
    func displayAllCategories() {
        self.filteredCategories = self.categories
        if(self.filteredCategories.count == 0)
        {
            self.category_suggestion.isHidden = true
        }
        else{
            self.category_suggestion.isHidden = false
            self.category_suggestion.reloadData()
        }
    }
    
    func categoriyIsValid() -> Bool
    {
        for item in self.categories
        {
            if item == self.txt_categories.text
            {
                return true
            }
        }
        return false
    }
}


extension TCreateToastVC: THContactPickerDelegate {
    func contactPicker(_ contactPicker: THContactPickerView!, textFieldDidChange textField: UITextField!) {
        if contactPicker == self.toaste_picker {
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
        if contactPicker == self.toaste_picker
        {
            let temp = textField.text
            if temp == "Enter emails separated by a space or a newline"
            {
                textField.text = ""
            }
            
            self.suggestion_table.isHidden = true
            
            self.scroll_view.setContentOffset(CGPoint(x:0,y:300), animated: true)
        }
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, textFieldShouldReturn textField: UITextField!) -> Bool {
        return true
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, didSelectContact contact: Any!) {
        
    }
    
    func contactPicker(_ contactPicker: THContactPickerView!, didRemoveContact contact: Any!) {
        if contactPicker == toaste_picker {
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

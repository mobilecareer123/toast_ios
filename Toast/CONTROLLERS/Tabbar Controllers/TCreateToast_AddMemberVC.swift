
//
//  TCreateToast_AddMemberVC.swift
//  Toast
//
//  Created by Anish Pandey on 17/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SDWebImage

class TCreateToast_AddMemberVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, CNContactPickerDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView_Member: UITableView!
    var array_Member:NSMutableArray = NSMutableArray()
    var array_searchResult:NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var btn_OpenContact: UIButton!
    @IBOutlet weak var lbl_noResults: UILabel!
    
    var screenTag:Int = 0 // 0 from createToast>> add intended person, 1 from createToast>> add Members, 2 from Edit Toast >> Addmember, 3 from Edit Toast >> add intended person, 4 from AddsCollabVC>> add Members
    
    var isSearchActive : Bool = false
    var isValidEmailMembr : Bool = false // true if searched with valid email Id
    var isForTostee:Int = 0
    var toast_id : String = String() // set value in response for addition of toast
    var toast_title : String = String() // set value in response for addition of toast
    
    let store = CNContactStore()
    var objects = [CNContact]()
    //    var isSearchingContacts : Bool = false // true if ADDRESS BOOK is open
    
    let peoplePicker = CNContactPickerViewController()
    
    
    var arr_oldUser:NSMutableArray = NSMutableArray()//array of carried user to match delete
    var arr_newAddeduser:NSMutableArray = NSMutableArray()//array of added users for "Edit toaste "WS call
    var arr_newDeleteduser:NSMutableArray = NSMutableArray()//array of deleted users for "Edit toaste "WS call
    
    
    var toasteeUsersArr: NSMutableArray = NSMutableArray() // carries all toastees from modal class
    var membersArr: NSMutableArray = NSMutableArray() // carries all members from modal class
    
    
    // set callback to Edit Toast VC
    
    var updatedUserList:(( _ array_Member:NSMutableArray,  _ arrNewAddeduser:NSMutableArray, _ arrNewDeleteduser:NSMutableArray ) -> Void) = { array_User, array_addedUser, array_deletedUser in }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.keyboardType = .asciiCapable
        peoplePicker.delegate = self
        
        peoplePicker.predicateForEnablingContact = NSPredicate(format: "emailAddresses.@count > 0")
        
        lbl_noResults.alpha = 0.0
        
        if(screenTag == 0) // from intended User
        {
            let overlayIndex_AddToasteeVC = UserDefaults.standard.string(forKey: KEY_OverlayIndex_AddToasteeVC) as NSString?
            
            if let newOverlayIndex_AddToasteeVC = overlayIndex_AddToasteeVC
            {
                if(newOverlayIndex_AddToasteeVC == "Show")
                {
                    _ = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(TCreateToast_AddMemberVC.startOverLay), userInfo: nil, repeats: false)
                }
            }
            else{
                _ = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(TCreateToast_AddMemberVC.startOverLay), userInfo: nil, repeats: false)
            }
        }
        if(screenTag == 4) // from add member
        {
            
            let overlayIndex_AddMemberVC = UserDefaults.standard.string(forKey: KEY_OverlayIndex_AddMemberVC) as NSString?
            if let newOverlayIndex_AddMemberVC = overlayIndex_AddMemberVC
            {
                if(newOverlayIndex_AddMemberVC == "Show")
                {
                    _ = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(TCreateToast_AddMemberVC.startOverLay), userInfo: nil, repeats: false)
                }
            }
            else{
                _ = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(TCreateToast_AddMemberVC.startOverLay), userInfo: nil, repeats: false)
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        imgView_ToastImage.image! = createToast_modal.toastImage_added
        
        self.CustomiseView()
        
        if(screenTag == 0) // from intended User
        {
            array_Member = createToast_modal.intended_users_s1
        }
        if(screenTag == 4) //  4 from AddsCollabVC>> add Members
        {
            
            array_Member = createToast_modal.members_s4
            
        }
        if(screenTag == 2)
        {
            // called from edit toast Addmember
            
            array_Member = membersArr
        }
        if(screenTag == 3)
        {
            // called from edit toast intended User
            array_Member = toasteeUsersArr
            
        }
        
        arr_oldUser = array_Member.mutableCopy() as! NSMutableArray
        arr_newAddeduser.removeAllObjects()
        
        
    }
    
    
    /*
    func startOverLay()
    {
        let item = self.navigationItem.rightBarButtonItem
        let button = item?.customView as! UIButton
        
        self.view.window?.addOverlayByHighlightingSubView(self.searchBar, withText: "Search for a \(screenTag == 0 ? "toastee" : "collaborator") or enter email address of a \(screenTag == 0 ? "toastee" : "collaborator") not yet registered.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.view.window?.addOverlayByHighlightingSubView(self.btn_OpenContact, withText: "Lookup a \(self.screenTag == 0 ? "toastee" : "collaborator") from your contact book.")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.view.window?.addOverlayByHighlightingSubView(button, withText: "\(self.screenTag == 0 ? "" : "Finally,") Click Done to update the \(self.screenTag == 0 ? "toastee" : "collaborator") list.")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    self.view.window?.removeOverlay()
                    
                    if(self.screenTag == 0) // from intended User
                    {
                        UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddToasteeVC)
                    }
                    if(self.screenTag == 4) // 4 from AddsCollabVC>> add Members
                    {
                        UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddMemberVC)
                    }
                    
                    
                }
            }
        }
    }*/
    
    
    func startOverLay()
    {
        let item = self.navigationItem.rightBarButtonItem
        let button = item?.customView as! UIButton
        // next button tap
        var vArr = [UIView]() // array of views
        var strArr = [String]() // array of text
        vArr = [self.searchBar,self.btn_OpenContact,button]
        
        
     //   strArr = ["Search for \(screenTag == 0 ? "a toastee" : "a collaborator") or enter email address of a \(screenTag == 0 ? "toastee" : "collaborator") not yet registered.",
     //       "Lookup a \(self.screenTag == 0 ? "toastee" : "collaborator") from your contact book.",
     //       "\(self.screenTag == 0 ? "" : "Finally,") Click Done to update the \(self.screenTag == 0 ? "toastee" : "collaborator") list."]
        
        
        if self.screenTag == 0
        {
            strArr = ["Search for an individual by email or their registered app user name.","Lookup from your contact book.","Finally, Click Done to update the toastee list."]
             self.view.window?.getViewsWithText(vArr, textArr: strArr)
        }

        if(self.screenTag == 0) // from intended User
        {
            UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddToasteeVC)
        }
        if(self.screenTag == 4) // from add member
        {
            UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddMemberVC)
        }
        
    }
    
    
    func CustomiseView()
    {
        
        // 0 from createToast>> add intended person, 1 from createToast>> add Members, 2 from Edit Toast >> Addmember, 3 from Edit Toast >> add intended person, 4 from AddsCollabVC>> add Members
        
        if(screenTag == 4 || screenTag == 2) // 4 from AddsCollabVC>> add Members
        {
            self.navigationItem.titleView = getNavigationTitle(inputStr: kNavigationTitleAddCollaborators)
        }
        else
        {
            self.navigationItem.titleView = getNavigationTitle(inputStr: "Add Toastees")
        }
        
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TCreateToast_AddMemberVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        if(screenTag == 0 || screenTag == 1 || screenTag == 2 || screenTag == 3 || screenTag == 4)// 4 from AddsCollabVC>> add Members
        {
            let btn_Done: UIButton = UIButton(type: UIButtonType.custom)
            btn_Done.frame = CGRect(x: 0, y: -25, width: 44, height: 30)
            btn_Done.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15.5)
            btn_Done.setTitle("Done", for: .normal)
            btn_Done.addTarget(self, action: #selector(TCreateToast_AddMemberVC.btn_DoneClicked(_:)), for: UIControlEvents.touchUpInside)
            let rightBarButtonItemShare: UIBarButtonItem = UIBarButtonItem(customView: btn_Done)
            //            let navigationItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            //            navigationItem.width = -10
            //            let rightArray:NSArray = [navigationItem, rightBarButtonItemShare]
            self.navigationItem.setRightBarButton(rightBarButtonItemShare, animated: true)
        }
        
        var textField : UITextField
        textField = (searchBar.value(forKey: "searchField") as? UITextField)!
        textField.borderStyle = .none
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        textField.layer.cornerRadius = 3.0
        textField.clipsToBounds = true
        textField.background = nil;
        textField.backgroundColor = UIColor.white
        
    }
    
    // MARK: - Button Actions
    
    func backBtnClicked(_ sender: UIButton!)
    {
        if(screenTag == 0) // from intended User
        {
            // Post notification:
        }
        if(screenTag == 4) // 4 from AddsCollabVC>> add Members
        {
            // push to write msg for
            createToast_modal.members_s4 = array_Member// change ANish
        }
        if(screenTag == 2)
        {
            // called from edit toast
        }
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    func btn_DoneClicked(_ sender: UIButton!)
    {
        if(screenTag == 0) // from intendedUser/ TOASTEE (Create Toast)
        {
            //uncomment below
            
            if array_Member.count > 0
            {
                // Post notification:
                let userInfo = ["userArray": array_Member as NSMutableArray]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kAddIntendedMember_Notification),
                                                object: nil,
                                                userInfo: userInfo)
                
                ((self.navigationController)! as UINavigationController).popViewController(animated: true)
            }
            else
            {
                func handleCancel(_ alertView: UIAlertAction!)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                
                let alert = UIAlertController(title: nil, message: kAddToasteeCreateToast, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:handleCancel))
                
                alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        else if(screenTag == 1) // from add member (Create Toast)
        {
            //uncomment below
            
            /*
             createToast_modal.members_s4 = array_Member
             CreateToastCalled()
             */
        }
        else if(screenTag == 4){ // 4 from AddsCollabVC>> add Members
            if array_Member.count > 0
            {
                // Post notification:
                let userInfo = ["userArray": array_Member as NSMutableArray]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kAddCollaborator_Notification),
                                                object: nil,
                                                userInfo: userInfo)
                
                ((self.navigationController)! as UINavigationController).popViewController(animated: true)
            }
            else
            {
                func handleCancel(_ alertView: UIAlertAction!)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                
                let alert = UIAlertController(title: nil, message: kAddCollabCreateToast, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:handleCancel))
                
                alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
        else if (screenTag == 3 || screenTag == 2)// 0 from createToast>> add intended person, 1 from createToast>> add Members, 2 from Edit Toast >> Addmember, 3 from Edit Toast >> add intended person, 4 from AddsCollabVC>> add Members
        {
            let arrNewAddeduser : NSMutableArray = NSMutableArray()
            
            for user1 in arr_newAddeduser
            {
                //                let dict : NSMutableDictionary = NSMutableDictionary()
                arrNewAddeduser.add((user1 as! AddMemberModel).member_Email_id)
            }
            
            let arrNewDeleteduser : NSMutableArray = NSMutableArray()
            
            for user1 in arr_newDeleteduser
            {
                //                let dict : NSMutableDictionary = NSMutableDictionary()
                arrNewDeleteduser.add((user1 as! AddMemberModel).member_Email_id)
            }
            
            /*
            let userInfo = ["userArray": array_Member as NSMutableArray, "addedArray":arrNewAddeduser as NSMutableArray, "Deleteduser":arrNewDeleteduser as NSMutableArray]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kEditIntendedMember_Notification),
                                            object: nil,
                                            userInfo: userInfo)
 */

            self.updatedUserList(array_Member, arrNewAddeduser, arrNewDeleteduser)

            ((self.navigationController)! as UINavigationController).popViewController(animated: true)
        }
    }
    
    @IBAction func btn_OpenContactClicked(_ sender: UIButton) {
        
        /*
         isSearchActive = true
         isSearchingContacts = true
         //        getContacts()
         
         store.requestAccess(for: .contacts, completionHandler: {
         granted, error in
         
         guard granted else {
         let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         self.present(alert, animated: true, completion: nil)
         return
         }
         
         //            let groups = try store.groups(matching: nil) // pass predicate for match
         //            let predicate = CNContact.predicateForContactsInGroup(withIdentifier: groups[0].identifier)
         //            //let predicate = CNContact.predicateForContactsMatchingName("John")
         //            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactEmailAddressesKey, CNContactImageDataKey, CNContactImageDataAvailableKey] as [Any]
         //
         //            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
         //            self.objects = contacts
         //            NSLog("self.objects.count %d", self.objects.count)
         
         let predicate = CNContact.predicateForContacts(matchingName: "John")
         
         let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactEmailAddressesKey, CNContactImageDataKey, CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey] as [Any]
         let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
         var cnContacts = [CNContact]()
         
         do {
         try self.store.enumerateContacts(with: request){
         (contact, cursor) -> Void in
         cnContacts.append(contact)
         }
         } catch let error {
         NSLog("Fetch contact error: \(error)")
         }
         
         NSLog(">>>> Contact list:")
         self.objects = cnContacts
         NSLog("self.objects.count %d", self.objects.count)
         
         //            let contact = self.objects[indexPath.row]
         //            let formatter = CNContactFormatter()
         //
         //            cell.textLabel?.text = formatter.string(from: contact)
         //            cell.detailTextLabel?.text = contact.emailAddresses.first?.value as? String
         
         self.array_searchResult.removeAllObjects()
         self.array_searchResult.addObjects(from: self.objects) //  copy to maintain same array for count
         NSLog("array_searchResult %d", self.array_searchResult.count)
         DispatchQueue.main.async(execute: {
         self.tblView_Member.reloadData()
         })
         
         
         
         for contact in cnContacts {
         let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
         NSLog(" \n list \(contact.emailAddresses.description)")
         }
         })
         */
        
        self.present(peoplePicker, animated: true, completion: nil)
        
    }
    
    // MARK: ADDRESS BOOK - Native contact list
    
    // MARK: - ContactPicker Delegate
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //Dismiss the picker VC
        picker.dismiss(animated: true, completion: nil)
        if contact.emailAddresses.count > 1
        {
            
            //        }
            //        //See if the contact has multiple phone numbers
            //        if contact.phoneNumbers.count > 1 {
            //If so we need the user to select which phone number we want them to use
            let multiplePhoneNumbersAlert = UIAlertController(title: "Which one?", message: "This contact has multiple Email Ids, which one did you want use?", preferredStyle: UIAlertControllerStyle.alert)
            //Loop through all the phone numbers that we got back
            for number in contact.emailAddresses {
                //Each object in the phone numbers array has a value property that is a CNPhoneNumber object, Make sure we can get that
                if let actualNumber = number.value as? String{
                    //Get the label for the phone number
                    var phoneNumberLabel = number.label
                    //Strip off all the extra crap that comes through in that label
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "_", with: "", options: .literal, range: nil)
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "$", with: "", options: .literal, range: nil)
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "!", with: "", options: .literal, range: nil)
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "<", with: "", options: .literal, range: nil)
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: ">", with: "", options: .literal, range: nil)
                    
                    if phoneNumberLabel != nil
                    {
                        
                    }
                    else
                    {
                        phoneNumberLabel = "Other"
                    }
                    //Create a title for the action for the UIAlertVC that we display to the user to pick phone numbers
                    let actionTitle = phoneNumberLabel! + " - " + actualNumber
                    //Create the alert action
                    let numberAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: { (theAction) -> Void in
                        //Create an empty string for the contacts name
                        var nameToSave = ""
                        //See if we can get A frist name
                        if contact.givenName == ""
                        {
                            //If Not check for a last name
                            if contact.familyName == ""
                            {
                                //If no last name set name to Unknown Name
                                nameToSave = "Unknown Name"
                            }
                            else
                            {
                                nameToSave = contact.familyName
                            }
                        }
                        else
                        {
                            nameToSave = contact.givenName
                        }
                        
                        // See if we can get image data
                        if let imageData = contact.imageData
                        {
                            //If so create the image
                            let userImage = UIImage(data: imageData)
                        }
                        //Do what you need to do with your new contact information here!
                        //Get the string value of the phone number like this:
                        if let userContactEmail : String = actualNumber as String
                        {
                            do {
                                if(userContactEmail.isValidEmail())
                                {
                                    //                                "email_id" = "anish123@yopmail.com";
                                    //                                "first_name" = Anish123;
                                    //                                "last_name" = Pandey;
                                    //                                "profile_photo" = "default.jpg";
                                    //                                "user_id" = 22;
                                    
                                    let addMemberObj:AddMemberModel = AddMemberModel()
                                    addMemberObj.member_Email_id = userContactEmail.lowercased()
                                    
                                    //                        if (!(cell.lbl_MemberName.text?.isEmpty)!)
                                    //                        {
                                    if let nameToSave : String = nameToSave as String
                                    {
                                        addMemberObj.member_First_name =  nameToSave
                                    }
                                    else
                                    {
                                        addMemberObj.member_First_name = ""
                                        addMemberObj.member_Last_name = ""
                                    }
                                    
                                    
                                    addMemberObj.member_Profile_photoURL = "default.jpg"
                                    
                                    addMemberObj.member_User_id =  ""
                                    
                                    
                                    var addFlag : Bool = true
                                    
                                    // common check for toastee and members
                                    for i in 0..<self.array_Member.count
                                    {
                                        if (self.array_Member.object(at: i) as! AddMemberModel).member_Email_id.lowercased() == userContactEmail.lowercased()
                                        {
                                            addFlag = false
                                        }
                                        else
                                        {
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    if self.screenTag == 1 || self.screenTag == 2
                                    {
                                        if addFlag == true
                                        {
                                            // Check if memeber aaded is Initiator
                                            if ((UserDefaults.standard.value(forKey: KEY_EMAIL_ID)! as! String).lowercased() == userContactEmail.lowercased())
                                            {
                                                // Show alert
                                                SVProgressHUD.showInfo(withStatus: kAlertMI, maskType: .gradient)
                                            }
                                                
                                            else
                                            {
                                                // add member
                                                self.array_searchResult.removeAllObjects()
                                                self.array_Member.add(addMemberObj)
                                                self.arr_newAddeduser.add(addMemberObj)
                                                
                                                
                                                self.isSearchActive = false
                                                self.tblView_Member.reloadData()
                                            }
                                        }
                                        else
                                        {
                                            // SVProgressHUD.showInfo(withStatus: "Duplicate entry for Member", maskType: .gradient)
                                        }
                                    }
                                    else
                                    {
                                        
                                        if self.screenTag == 4 // 4 from AddsCollabVC>> add Members
                                        {
                                            if addFlag == true
                                            {
                                                // Check if memeber aaded is Initiator
                                                if ((UserDefaults.standard.value(forKey: KEY_EMAIL_ID)! as! String).lowercased() == userContactEmail.lowercased())
                                                {
                                                    // Show alert
                                                    SVProgressHUD.showInfo(withStatus: kAlertMI, maskType: .gradient)
                                                }
                                                    
                                                else
                                                {
                                                    // add member
                                                    self.array_searchResult.removeAllObjects()
                                                    self.array_Member.add(addMemberObj)
                                                    self.arr_newAddeduser.add(addMemberObj)
                                                    
                                                    
                                                    self.isSearchActive = false
                                                    self.tblView_Member.reloadData()
                                                }
                                            }
                                            else
                                            {
                                                // SVProgressHUD.showInfo(withStatus: "Duplicate entry for Member", maskType: .gradient)
                                            }
                                        }
                                            
                                        else
                                        {
                                            if addFlag == true
                                            {
                                                
                                                self.array_searchResult.removeAllObjects()
                                                self.array_Member.add(addMemberObj)
                                                self.arr_newAddeduser.add(addMemberObj)
                                                self.isSearchActive = false
                                                self.tblView_Member.reloadData()
                                            }
                                            else
                                            {
                                                // SVProgressHUD.showInfo(withStatus: "Duplicate entry for Toastee", maskType: .gradient)
                                            }
                                        }
                                    }
                                    
                                }
                            } catch {
                                print(error)
                            }
                        }
                    })
                    //Add the action to the AlertController
                    multiplePhoneNumbersAlert.addAction(numberAction)
                }
            }
            //Add a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (theAction) -> Void in
                //Cancel action completion
            })
            //Add the cancel action
            multiplePhoneNumbersAlert.addAction(cancelAction)
            //Present the ALert controller
            self.present(multiplePhoneNumbersAlert, animated: true, completion: nil)
        }
        else
        {
            //Make sure we have at least one phone number
            //            if contact.phoneNumbers.count > 0 {
            if contact.emailAddresses.count > 0
            {
                //If so get the CNPhoneNumber object from the first item in the array of phone numbers
                if let actualNumber = contact.emailAddresses.first?.value  {
                    //Get the label of the phone number
                    var phoneNumberLabel = contact.emailAddresses.first!.label
                    //Strip out the stuff you don't need
                    //                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "_", with: "", options: .literal, range: nil)
                    //                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "$", with: "", options: .literal, range: nil)
                    //                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "!", with: "", options: .literal, range: nil)
                    //                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "<", with: "", options: .literal, range: nil)
                    //                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: ">", with: "", options: .literal, range: nil)
                    
                    //Create an empty string for the contacts name
                    var nameToSave = ""
                    //See if we can get A frist name
                    if contact.givenName == ""
                    {
                        
                        //If Not check for a last name
                        if contact.familyName == ""
                        {
                            //If no last name set name to Unknown Name
                            nameToSave = "Unknown Name"
                        }
                        else
                        {
                            nameToSave = contact.familyName
                        }
                    }
                    else
                    {
                        nameToSave = contact.givenName
                    }
                    
                    // See if we can get image data
                    if let imageData = contact.imageData
                    {
                        //If so create the image
                        let userImage = UIImage(data: imageData)
                    }
                    //Do what you need to do with your new contact information here!
                    //Get the string value of the phone number like this:
                    
                    if let userContactEmail : String = actualNumber as String
                    {
                        do {
                            if(userContactEmail.isValidEmail())
                            {
                                //                                "email_id" = "anish123@yopmail.com";
                                //                                "first_name" = Anish123;
                                //                                "last_name" = Pandey;
                                //                                "profile_photo" = "default.jpg";
                                //                                "user_id" = 22;
                                
                                let addMemberObj:AddMemberModel = AddMemberModel()
                                addMemberObj.member_Email_id = userContactEmail.lowercased()
                                
                                //                        if (!(cell.lbl_MemberName.text?.isEmpty)!)
                                //                        {
                                if let nameToSave : String = nameToSave as String
                                {
                                    addMemberObj.member_First_name =  nameToSave
                                }
                                else
                                {
                                    addMemberObj.member_First_name = ""
                                    addMemberObj.member_Last_name = ""
                                }
                                
                                
                                addMemberObj.member_Profile_photoURL = "default.jpg"
                                addMemberObj.member_User_id =  ""
                                
                                
                                var addFlag : Bool = true
                                
                                for i in 0..<self.array_Member.count
                                {
                                    if (self.array_Member.object(at: i) as! AddMemberModel).member_Email_id.lowercased() == userContactEmail.lowercased()
                                    {
                                        addFlag = false
                                    }
                                    else
                                    {
                                        
                                    }
                                    
                                }
                                
                                
                                if self.screenTag == 1 || self.screenTag == 2
                                {
                                    if addFlag == true
                                    {
                                        // Check if memeber aaded is Initiator
                                        if (UserDefaults.standard.value(forKey: KEY_EMAIL_ID)! as! String == userContactEmail)
                                        {
                                            // Show alert
                                            SVProgressHUD.showInfo(withStatus: kAlertMI, maskType: .gradient)
                                        }
                                            
                                        else
                                        {
                                            // add member
                                            self.array_searchResult.removeAllObjects()
                                            self.array_Member.add(addMemberObj)
                                            self.arr_newAddeduser.add(addMemberObj)
                                            
                                            self.isSearchActive = false
                                            self.tblView_Member.reloadData()
                                        }
                                    }
                                    else
                                    {
                                        //SVProgressHUD.showInfo(withStatus: "Duplicate entry for Member", maskType: .gradient)
                                    }
                                }
                                else
                                {
                                    
                                    if self.screenTag == 4 // 4 from AddsCollabVC>> add Members
                                    {
                                        if addFlag == true
                                        {
                                            // Check if memeber aaded is Initiator
                                            if ((UserDefaults.standard.value(forKey: KEY_EMAIL_ID)! as! String).lowercased() == userContactEmail.lowercased())
                                            {
                                                // Show alert
                                                SVProgressHUD.showInfo(withStatus: kAlertMI, maskType: .gradient)
                                            }
                                                
                                            else
                                            {
                                                // add member
                                                self.array_searchResult.removeAllObjects()
                                                self.array_Member.add(addMemberObj)
                                                self.arr_newAddeduser.add(addMemberObj)
                                                
                                                
                                                self.isSearchActive = false
                                                self.tblView_Member.reloadData()
                                            }
                                        }
                                        else
                                        {
                                            // SVProgressHUD.showInfo(withStatus: "Duplicate entry for Member", maskType: .gradient)
                                        }
                                    }
                                        
                                    else
                                    {

                                    if addFlag == true
                                    {
                                        self.array_searchResult.removeAllObjects()
                                        self.array_Member.add(addMemberObj)
                                        self.arr_newAddeduser.add(addMemberObj)
                                        self.isSearchActive = false
                                        self.tblView_Member.reloadData()
                                    }
                                    else
                                    {
                                        // SVProgressHUD.showInfo(withStatus: "Duplicate entry for Toastee", maskType: .gradient)
                                    }
                                    
                                }
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            else
            {
                //If there are no email associated with the contact I display an alert Controller to the user
                func handleCancel(_ alertView: UIAlertAction!)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                let alert = UIAlertController(title: "Missing info", message: kNoEmailInContact, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                
                alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    //    func getContacts() {
    //
    //        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
    //            store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
    //                if authorized {
    //                    self.retrieveContactsWithStore(store: self.store)
    //                }
    //                } as! (Bool, Error?) -> Void)
    //        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
    //            self.retrieveContactsWithStore(store: store)
    //        }
    //    }
    //
    //    func retrieveContactsWithStore(store: CNContactStore) {
    //        do {
    //            let groups = try store.groups(matching: nil) // pass predicate for match
    //            let predicate = CNContact.predicateForContactsInGroup(withIdentifier: groups[0].identifier)
    //            //let predicate = CNContact.predicateForContactsMatchingName("John")
    //            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactEmailAddressesKey, CNContactImageDataKey, CNContactImageDataAvailableKey] as [Any]
    //
    //            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
    //            self.objects = contacts
    //            NSLog("self.objects.count %d", self.objects.count)
    //
    //            //            let contact = self.objects[indexPath.row]
    //            //            let formatter = CNContactFormatter()
    //            //
    //            //            cell.textLabel?.text = formatter.string(from: contact)
    //            //            cell.detailTextLabel?.text = contact.emailAddresses.first?.value as? String
    //
    //            self.array_searchResult.removeAllObjects()
    //            self.array_searchResult.addObjects(from: self.objects) //  copy to maintain same array for count
    //            NSLog("array_searchResult %d", self.array_searchResult.count)
    //            DispatchQueue.main.async(execute: {
    //                self.tblView_Member.reloadData()
    //            })
    //        } catch {
    //            print(error)
    //        }
    //    }
    
    
    func animateTable() {
        tblView_Member.reloadData()
        
        let cells = tblView_Member.visibleCells
        let tableHeight: CGFloat = tblView_Member.bounds.size.height
        
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
    
    // MARK: - Table View Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count : Int
        if isSearchActive
        {
            count = array_searchResult.count
        }
        else
        {
            count =  array_Member.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height * (73.0 / 568.0)
    }
    
    
    //uncomment below
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "AddMemberCell"
        var cell:AddMemberCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AddMemberCell
        if (cell == nil){
            tableView.register(UINib(nibName: "AddMemberCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AddMemberCell
            cell?.layoutMargins=UIEdgeInsets.zero
            cell?.preservesSuperviewLayoutMargins=false
            cell?.backgroundColor=UIColor.clear
        }
        //        if isSearchingContacts && isSearchActive && array_searchResult.count>0
        //        {
        //
        //            let contact = self.objects[indexPath.row]
        //            let formatter = CNContactFormatter()
        //
        //            cell?.lbl_MemberName.text = formatter.string(from: contact)
        //            cell?.lbl_MemberEmail.text = contact.emailAddresses.first?.value as? String // will take out first entry if multiple addresses are available
        //
        //            cell?.btn_Close.isHidden = true
        //
        //
        //
        //            if contact.imageDataAvailable {
        //                if let data = contact.imageData {
        ////                    self.contactImage.image = UIImage(data: data)
        //                    cell?.imgView_MemberPhoto.image = UIImage(data: data)
        //                }
        //            }
        //            else if ((contact.thumbnailImageData) != nil) {
        //                if let data = contact.imageData {
        //                    //                    self.contactImage.image = UIImage(data: data)
        //                    cell?.imgView_MemberPhoto.image = UIImage(data: data)
        //                }
        //            }
        //            else{
        //                // do stuff
        //                let urlString:String = "profile_default_cell_iphone"
        //
        //                let url = URL(string: urlString)
        //
        //                cell?.imgView_MemberPhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_default_cell_iphone"))
        //            }
        //
        //        }
        if isSearchActive && array_searchResult.count>0
        {
            let name:NSString =  NSString(format: "%@ %@",((array_searchResult.object(at: indexPath.row)as! AddMemberModel).member_First_name as String?)!,((array_searchResult.object(at: indexPath.row)as! AddMemberModel).member_Last_name as String?)!)
            cell?.lbl_MemberName.text = "\(name)"
            cell?.lbl_MemberEmail.text = (array_searchResult.object(at: indexPath.row)as! AddMemberModel).member_Email_id as String?
            
            //(array_searchResult.object(at: indexPath.row)as! AddMemberModel).member_Profile_photo as String?
            
            let urlString:String = (array_searchResult.object(at: indexPath.row)as! AddMemberModel).member_Profile_photoURL
            
            cell?.imgView_MemberPhoto.image = UIImage(named:"ic_default profile")
            
            if(urlString.characters.count > 0)
            {
                //                let url = URL(string: urlString)
                //                let manager:SDWebImageManager = SDWebImageManager.shared()
                //                manager.downloadImage(with: url, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                //                    let aspectScaledToFillImage = image?.af_imageAspectScaled(toFill: (cell?.imgView_MemberPhoto.frame.size)!)
                //                    cell?.imgView_MemberPhoto.image = aspectScaledToFillImage?.af_imageRoundedIntoCircle()
                //                })
                
                let toastURL: URL = URL(string: urlString)!
                cell?.imgView_MemberPhoto.af_setImage(withURL: toastURL)
                //let resizableWidth = UIScreen.main.bounds.size.height * ((cell?.imgView_MemberPhoto.frame.size.width)! / 568.0)
                
                cell?.imgView_MemberPhoto.cornerRadius = ((cell?.imgView_MemberPhoto.frame.size.width)! / 2) - 5.0
            }
            
            //            cell?.btn_Close.isHidden = true
            cell?.btn_Close.tag = indexPath.row
            cell?.btn_Close.isHidden = false
            cell?.btn_Close.setImage(UIImage(named: "AddMem_un_SeLImg"), for: .normal)
            //            cell?.btn_Close.addTarget(self, action: #selector(TCreateToast_AddMemberVC.btn_removePersonClicked(_:)), for: UIControlEvents.touchUpInside)
        }
        else
        {
            let name:NSString =  NSString(format: "%@ %@",((array_Member.object(at: indexPath.row)as! AddMemberModel).member_First_name as String?)!,((array_Member.object(at: indexPath.row)as! AddMemberModel).member_Last_name as String?)!)
            cell?.lbl_MemberName.text = "\(name)"
            
            cell?.lbl_MemberEmail.text = (array_Member.object(at: indexPath.row)as! AddMemberModel).member_Email_id as String?
            
            let urlString:String = (array_Member.object(at: indexPath.row)as! AddMemberModel).member_Profile_photoURL
            
            cell?.imgView_MemberPhoto.image = UIImage(named:"ic_default profile")
            
            if(urlString.characters.count > 0)
            {
                //                let url = URL(string: urlString)
                //                let manager:SDWebImageManager = SDWebImageManager.shared()
                //                manager.downloadImage(with: url, options: .continueInBackground, progress: nil, completed: { (image, error, nil, true, imgURL) in
                //                    let aspectScaledToFillImage = image?.af_imageAspectScaled(toFill: (cell?.imgView_MemberPhoto.frame.size)!)
                //                    cell?.imgView_MemberPhoto.image = aspectScaledToFillImage?.af_imageRoundedIntoCircle()
                //                })
                
                let toastURL: URL = URL(string: urlString)!
                cell?.imgView_MemberPhoto.af_setImage(withURL: toastURL)
                //let resizableWidth = UIScreen.main.bounds.size.height * ((cell?.imgView_MemberPhoto.frame.size.width)! / 568.0)
                
                cell?.imgView_MemberPhoto.cornerRadius = ((cell?.imgView_MemberPhoto.frame.size.width)! / 2) - 5.0
                
            }
            
            cell?.btn_Close.tag = indexPath.row
            cell?.btn_Close.isHidden = false
            cell?.btn_Close.setImage(UIImage(named: "ic_cross button"), for: .normal)
            cell?.btn_Close.addTarget(self, action: #selector(TCreateToast_AddMemberVC.btn_removePersonClicked(_:)), for: UIControlEvents.touchUpInside)
        }
        
        cell?.lbl_MemberType.isHidden = true
        cell?.view_Bg.backgroundColor = UIColor.white
        cell?.view_Bg.layer.borderWidth = 1.0
        cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        cell?.view_Bg.layer.cornerRadius = 2.0
        cell?.view_Bg.clipsToBounds = true
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(hexCode: 0xFCF5E2).withAlphaComponent(0.2)
        cell!.selectedBackgroundView = bgColorView
        
        cell?.selectionStyle = .none
        
        return cell!
    }
    
    
    //comment below
    //*******************************************************
    /*
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
     
     let cellIdentifier:String = "AddMemberCell"
     var cell:AddMemberCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AddMemberCell
     if (cell == nil){
     tableView.register(UINib(nibName: "AddMemberCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
     cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AddMemberCell
     cell?.layoutMargins=UIEdgeInsets.zero
     cell?.preservesSuperviewLayoutMargins=false
     cell?.backgroundColor=UIColor.clear
     }
     cell?.lbl_MemberName.text = (array_Member.object(at: indexPath.row)as! NSDictionary).value(forKey: "memberName") as! String?
     cell?.lbl_MemberEmail.text = (array_Member.object(at: indexPath.row)as! NSDictionary).value(forKey: "memberEmail") as! String?
     
     let compressed_Image = UIImage(named: (array_Member.object(at: indexPath.row)as! NSDictionary).value(forKey: "memberPhoto") as! String)
     
     
     cell?.imgView_MemberPhoto.image = compressed_Image?.imageWithImageInSize(compressed_Image!)
     cell?.lbl_MemberType.isHidden = true
     cell?.view_Bg.backgroundColor = UIColor.white
     cell?.view_Bg.layer.borderWidth = 1.0
     cell?.view_Bg.layer.borderColor = UIColor(hexCode: 0xE4E4E4).cgColor
     cell?.view_Bg.layer.cornerRadius = 2.0
     cell?.view_Bg.clipsToBounds = true
     
     let bgColorView = UIView()
     bgColorView.backgroundColor = UIColor(hexCode: 0xFCF5E2).withAlphaComponent(0.2)
     cell!.selectedBackgroundView = bgColorView
     
     
     cell?.selectionStyle = .none
     
     return cell!
     
     }
     */
    //*******************************************************
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearchActive
        {
            var addFlag : Bool = true
            
            for i in 0..<self.array_Member.count
            {
                if ((self.array_Member.object(at: i) as! AddMemberModel).member_Email_id.lowercased() == (array_searchResult.object(at: indexPath.row) as! AddMemberModel).member_Email_id.lowercased())
                {
                    addFlag = false
                }
                else
                {
                    
                }
            }
            
            if screenTag == 1 || screenTag == 2 // 1 from createToast>> add Members, 2 from Edit Toast >> Addmember
            {
                if (addFlag == true)
                {
                    // Check if memeber added is Initiator
                    if (UserDefaults.standard.value(forKey: KEY_EMAIL_ID)! as! String == (array_searchResult.object(at: indexPath.row) as! AddMemberModel).member_Email_id.lowercased())
                    {
                        // Show alert
                        //                        SVProgressHUD.showInfo(withStatus: kAlertMI, maskType: .gradient)
                        SVProgressHUD.showInfo(withStatus: kAddMember, maskType: .gradient)
                    }
                    else
                    {
                        // add member
                        array_Member.add(array_searchResult.object(at: indexPath.row) as! AddMemberModel)
                        if screenTag == 2 // edit member
                        {
                            arr_newAddeduser.add(array_searchResult.object(at: indexPath.row) as! AddMemberModel)
                        }
                    }
                }
                else{
                    // SVProgressHUD.showInfo(withStatus: "Duplicate entry for Member", maskType: .gradient)
                }
            }
            else
            {
                
                if screenTag == 4 // 4 from AddsCollabVC>> add Members
                {
                    if (addFlag == true)
                    {
                        // Check if memeber added is Initiator
                        if (UserDefaults.standard.value(forKey: KEY_EMAIL_ID)! as! String == (array_searchResult.object(at: indexPath.row) as! AddMemberModel).member_Email_id.lowercased())
                        {
                            // Show alert
                            //                        SVProgressHUD.showInfo(withStatus: kAlertMI, maskType: .gradient)
                            SVProgressHUD.showInfo(withStatus: kAddMember, maskType: .gradient)
                        }
                        else
                        {
                            // add member
                            array_Member.add(array_searchResult.object(at: indexPath.row) as! AddMemberModel)
                            if screenTag == 2 // edit member
                            {
                                arr_newAddeduser.add(array_searchResult.object(at: indexPath.row) as! AddMemberModel)
                            }
                        }
                    }
                    else{
                        // SVProgressHUD.showInfo(withStatus: "Duplicate entry for Member", maskType: .gradient)
                    }
                }

                
                else {
                if (addFlag == true)
                {
                    array_Member.add(array_searchResult.object(at: indexPath.row) as! AddMemberModel)
                    if screenTag == 3 // edit toastee
                    {
                        arr_newAddeduser.add(array_searchResult.object(at: indexPath.row) as! AddMemberModel)
                    }
                }
                else{
                    // SVProgressHUD.showInfo(withStatus: "Duplicate entry for Toastee", maskType: .gradient)
                }
            }
            }
            
            array_searchResult.removeAllObjects()
            
            let transition:CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.delegate = self
            tblView_Member.layer.add(transition, forKey: nil)
            
        }
        isSearchActive = false
        //        isSearchingContacts = false
        
        //remove duplicate elemets from array
        //        let orderedSet:NSOrderedSet = NSOrderedSet(array: array_Member as [AnyObject])
        //        let arrayWithoutDuplicates:NSArray = orderedSet.array as NSArray
        //        array_Member = arrayWithoutDuplicates.mutableCopy() as! NSMutableArray
        
        
        tblView_Member.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    func btn_removePersonClicked(_ sender: UIButton)
    {
        if array_Member.count>0
        {
            if array_Member.contains(array_Member.object(at: sender.tag)) && arr_oldUser.contains(array_Member.object(at: sender.tag))
            {
                print("arr_newDeleteduser 1- ",arr_newDeleteduser)
                print("arr_oldUser 1 - ",arr_oldUser)
                print("array_Member 1 - ",array_Member.count)
                
                arr_newDeleteduser.add(array_Member.object(at: sender.tag) as! AddMemberModel)
                arr_oldUser.removeObject(identicalTo: array_Member.object(at: sender.tag))
                array_Member.removeObject(at: sender.tag)
                
                print("arr_newDeleteduser 2 - ",arr_newDeleteduser.count)
                print("arr_oldUser 2 - ",arr_oldUser.count)
                print("array_Member 2 - ",array_Member.count)
                
                tblView_Member.reloadData()
            }
            else
            {
                
                if array_Member.contains(array_Member.object(at: sender.tag)) && arr_newAddeduser.contains(array_Member.object(at: sender.tag))
                {
                    arr_newAddeduser.removeObject(identicalTo: array_Member.object(at: sender.tag))
                    array_Member.removeObject(at: sender.tag)
                    
                    tblView_Member.reloadData()
                }
                else if array_Member.contains(array_Member.object(at: sender.tag))
                {
                    array_Member.removeObject(at: sender.tag)
                    
                    tblView_Member.reloadData()
                }
                
            }
            
            
            
        }
    }
    
    // MARK: - Search Bar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        
        array_searchResult.removeAllObjects()
        if(screenTag == 0)
        {
            // Intended User
            
        }
        if(screenTag == 1)
        {
            // Push to write msg for
            
        }
        if(screenTag == 2)
        {
            // Called from Edit Toast
            
        }
        
        if (!searchBar.text!.isEmpty)
        {
            if(searchBar.text?.isValidEmail())!
            {
                isValidEmailMembr = true
            }
            else
            {
                isValidEmailMembr = false
            }
            //uncomment below
            
            
            //            if isSearchingContacts
            //            {
            //                // Call search from AddressBook
            ////                array_Member.add(array_searchResult.object(at: indexPath.row) as! AddMemberModel)
            ////                array_searchResult.removeAllObjects()
            //
            //            }
            //            else
            //            {
            
            
            // convert text to support emoticons
            let  str:String = searchBar.text! as String
            let textViewData : NSData = str.data(using: String.Encoding.nonLossyASCII)! as NSData
            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
            
            
            SearchServerCalled(searchText:valueUniCode )
            //            }
            
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: "Please enter search text.", maskType: .gradient)
        }
        
        
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool
    {
        //        searchBar.showsCancelButton = true
        //        if let _cancelButton = searchBar.valueForKey("_cancelButton"),
        //            let cancelButton = _cancelButton as? UIButton {
        //            cancelButton.setTitle(nil, forState: .Normal)
        //            cancelButton.setImage(UIImage(named: "close_Search"), forState: .Normal)
        //        }
        
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) // called when text changes (including clear)
    {
        // The user clicked the [X] button or otherwise cleared the text.
        if (searchText.characters.count == 0) {
            searchBar.perform(#selector(UIResponder.resignFirstResponder), with: nil, afterDelay: 0.1)
            
            if isSearchActive
            {
                self.array_searchResult.removeAllObjects()
                self.isSearchActive = false
                //            isSearchingContacts = false
                self.tblView_Member.reloadData()
            }
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        
        if isSearchActive
        {
            self.array_searchResult.removeAllObjects()
            self.isSearchActive = false
            //            isSearchingContacts = false
            self.tblView_Member.reloadData()
        }
        
        searchBar.resignFirstResponder()
    }
    
    // MARK: - WebService Calls
    
    func SearchServerCalled(searchText : String)
    {
        /*"{
         {
         "service": "registereduserlist",
         "user_id": "3",
         "access_token": "S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au",
         "search_text":"john"
         }
         }"
         
         {
         "status": "Success",
         "user_list": [
         {
         "user_id": 4,
         "email_id": "john.k89@gmail.com",
         "first_name": "John",
         "last_name": "Day",
         "profile_photo": "default.jpg"
         },
         {
         "user_id": 13,
         "email_id": "john.doe@gmail.com",
         "first_name": "John",
         "last_name": "Doe",
         "profile_photo": "default.jpg"
         }
         ]
         }
         
         */
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "registereduserlist", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "search_text":searchText]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                SVProgressHUD.dismiss()
                
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        
                        
                        
                        self.array_searchResult.removeAllObjects()
                        
                        let userList:NSArray = (response["user_list"] as! NSArray)
                        for member in userList
                        {
                            let memberObj:AddMemberModel = AddMemberModel()
                            memberObj.setData(fromDict: member as! NSDictionary)
                            
                            self.array_searchResult.add(memberObj)
                        }
                        
                        
                        if self.array_searchResult.count == 0
                        {
                            self.lbl_noResults.alpha = 0.0
                            if self.isValidEmailMembr
                            {
                                
                                let transition1:CATransition = CATransition()
                                transition1.duration = 0.5
                                transition1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                transition1.type = kCATransitionPush
                                transition1.subtype = kCATransitionFromLeft
                                transition1.delegate = self
                                self.tblView_Member.layer.add(transition1, forKey: nil)
                                
                                //                                "email_id" = "anish123@yopmail.com";
                                //                                "first_name" = Anish123;
                                //                                "last_name" = Pandey;
                                //                                "profile_photo" = "default.jpg";
                                //                                "user_id" = 22;
                                
                                let addMemberObj:AddMemberModel = AddMemberModel()
                                
                                addMemberObj.member_Email_id = "\(searchText.lowercased())"
                                addMemberObj.member_First_name =  ""
                                addMemberObj.member_Last_name = ""
                                addMemberObj.member_Profile_photoURL =  "default.jpg"
                                addMemberObj.member_User_id =  ""
                                
                                self.array_searchResult.add(addMemberObj)
                                self.isSearchActive = true
                                self.tblView_Member.reloadData()
                            }
                            else
                            {
                                if(self.array_Member.count < 1 &&  self.isSearchActive == false)
                                {
                                    self.lbl_noResults.alpha = 1.0
                                }
                                else if (self.array_Member.count > 0 &&  self.isSearchActive == false)
                                {
                                    // IF not a valid email or no result found
                                    //                                SVProgressHUD.showInfo(withStatus: "No result found ! \n Try again.", maskType: .gradient)
                                    
                                    let alert = UIAlertController(title: "", message: "No result found ! \n Try again.", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                                else
                                {
                                    self.lbl_noResults.alpha = 1.0
                                }
                                self.tblView_Member.reloadData()
                                
                            }
                        }
                        else // for normal flow count >0
                        {
                            let transition1:CATransition = CATransition()
                            transition1.duration = 0.5
                            transition1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                            transition1.type = kCATransitionPush
                            transition1.subtype = kCATransitionFromLeft
                            transition1.delegate = self
                            self.tblView_Member.layer.add(transition1, forKey: nil)
                            
                            self.lbl_noResults.alpha = 0.0
                            
                            self.isSearchActive = true //  to show search result on tableview
                            self.tblView_Member.reloadData()
                        }
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
    
    
    // MARK: - WebService Calls
    
    func CreateToastCalled()
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
            if (createToast_modal.toastImage_added) != nil
            {
                multipart = "Y"
            }
            // prepare array
            
            let intendedUserArray : NSMutableArray = NSMutableArray()
            
            for user1 in createToast_modal.intended_users_s1
            {
                //                let dict : NSMutableDictionary = NSMutableDictionary()
                intendedUserArray.add((user1 as! AddMemberModel).member_Email_id.lowercased())
            }
            
            let memberArray : NSMutableArray = NSMutableArray()
            
            for user1 in createToast_modal.members_s4
            {
                //                let dict : NSMutableDictionary = NSMutableDictionary()
                memberArray.add((user1 as! AddMemberModel).member_Email_id.lowercased())
            }
            
            //                       SVProgressHUD.show(with: .gradient)
            
            //            let dateFormatter1:DateFormatter = DateFormatter()
            //            dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //            let date = dateFormatter1.date(from: createToast_modal.due_date_s1 as String)
            //            let dueDate = dateFormatter1.string(from: (date)!)
            
            // convert text to support emoticons
            let  str = createToast_modal.toast_Theme_s1
            let textViewData : NSData = str.data(using: String.Encoding.nonLossyASCII)! as NSData
            let valueUniCode : String = String(data: textViewData as Data, encoding: String.Encoding.utf8)!
            
            
            let Intended_swiftArray = NSArray(array:intendedUserArray)
            let Intended_stringRepresentation = (Intended_swiftArray as! Array).joined(separator: ",")
            print(Intended_stringRepresentation.description)
            
            let Member_swiftArray = NSArray(array:memberArray)
            let Member_stringRepresentation = (Member_swiftArray as! Array).joined(separator: ",")
            print(Member_stringRepresentation.description)
            
            let parameters: NSDictionary = ["service": "createnewtoast", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!, "theme":valueUniCode, "released_date":createToast_modal.due_date_s1.convertDateToServerFormat(), "from_text":createToast_modal.group_Name_s1, "category_name":createToast_modal.category_name_s2, "other_category_name":createToast_modal.other_category_name_s2, "toast_notification":createToast_modal.toast_notification_s1, "toastee_users":Intended_stringRepresentation, "members":Member_stringRepresentation, "multipart":multipart]
            
            var toastImg: String = ""
            if (createToast_modal.toastImage_added) != nil {
                let imageData = UIImagePNGRepresentation(createToast_modal.toastImage_added)
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
                            self.performSegue(withIdentifier: "writeMsgSeg", sender: self)
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
            /*
             WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
             print(response)
             let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
             if(statusToken as String == "Success" as String)
             {
             DispatchQueue.main.async(execute: {
             
             SVProgressHUD.dismiss()
             //                        self.toast_id = NSString(format: "%d",response["toast_id"]! as! NSString)
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshToastList_Notification), object: nil)
             
             SVProgressHUD.showInfo(withStatus: "Toast Added Successfully", maskType: .gradient)
             
             ((self.navigationController)! as UINavigationController).popToRootViewController(animated: true)
             
             //                         self.performSegue(withIdentifier: "writeMsgSeg", sender: self)
             
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
             */
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
        
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isSearchActive && array_searchResult.count > 0
        {
            self.array_searchResult.removeAllObjects()
            self.isSearchActive = false
            searchBar.resignFirstResponder()
            self.tblView_Member.reloadData()
            
        }
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "writeMsgSeg")
        {
            if let writeMsgVc: TCreateToast_WriteMsgVC = segue.destination as? TCreateToast_WriteMsgVC {
                
                writeMsgVc.isEditMode = false
                writeMsgVc.isCreatingToast = true
                writeMsgVc.selected_ToastId = toast_id as String
                writeMsgVc.selected_ToastTitle = toast_title as String
                
            }
        }
    }
    
}

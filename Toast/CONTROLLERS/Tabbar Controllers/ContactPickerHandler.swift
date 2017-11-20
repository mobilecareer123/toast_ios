//
//  ContactPickerHandler.swift
//  Toast
//
//  Created by Administrator on 10/15/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class CNContactPickerHandler: NSObject, CNContactPickerDelegate, UITextViewDelegate {
    var sendingVC : UIViewController = UIViewController()
    var memberType : String = "toastee"
    let dummyEmailPlaceholder = "Enter emails separated by a space or a newline. Press enter to return."
    var txtView_Active:UITextView!
    var memberTypeTag: Int = 1
    
    
    func setupEmailPicker(textView: UITextView, memberTag: Int) {
        
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 3.0
        textView.layer.borderColor = UIColor(hexCode: 0xE8E8E8).cgColor
        textView.clipsToBounds = true
        textView.delegate = self
        textView.autocorrectionType = .no
        textView.text = dummyEmailPlaceholder
        textView.textColor = UIColor(hexCode: 0xBEC0C0)
        textView.tag = memberTag
    }
    
    func setMemberTypeTag(tag: Int)
    {
        memberTypeTag = tag
    }
    
    func configuredPeoplePickerViewController(sendingVC: UIViewController, memberType: String) -> CNContactPickerViewController {
        let peoplePickerVC = CNContactPickerViewController()
        peoplePickerVC.delegate = self
        peoplePickerVC.predicateForEnablingContact = NSPredicate(format: "emailAddresses.@count > 0")
        self.sendingVC = sendingVC
        self.memberType = memberType
        return peoplePickerVC
    }
    
    func getAttributedStrings(text: String, font: UIFont) -> [String]
    {
        let whitespaceCharacterSet = NSCharacterSet.whitespacesAndNewlines
        let components = text.components(separatedBy: whitespaceCharacterSet)
        var hasInvalid = false;
        
        let attribWords = components.map({ (word) -> String in
            let trimWord = word.trimmingCharacters(in: .whitespaces)
            
            if trimWord.isEmpty == false {
                if trimWord.isValidEmail() {
                    checkAndAddMember(trimWord, nameToSave: "")
                    return ""
                } else {
                    hasInvalid = true;
                    return "\(trimWord)"
                    
                }
            } else {
                return ""
            }
        })
        
        if hasInvalid == true {
            SVProgressHUD.showInfo(withStatus: kInvalidEmail, maskType: .gradient)
        }
        
        return attribWords
    }
        
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == dummyEmailPlaceholder {
            textView.text = nil
        }
        textView.textColor = UIColor(hexCode: 0x666666)
        txtView_Active = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text.isEmpty {
            textView.text = dummyEmailPlaceholder
            textView.textColor = UIColor(hexCode: 0xBEC0C0)
        }
        txtView_Active = nil
    }
    
    private func textViewShouldReturn(textView: UITextView) -> Bool
    {
        if textView.text.isEmpty {
            textView.text = dummyEmailPlaceholder
            textView.textColor = UIColor(hexCode: 0xBEC0C0)
        }
        textView.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text == " " || text == "\n" || text == "," {
            textViewShouldReturn(textView: textView)
            self.memberTypeTag = textView.tag
            let attribWords = getAttributedStrings(text: textView.text, font: textView.font!)
            let filteredAttribWords = attribWords.filter { $0.isEmpty == false }
            textView.text = filteredAttribWords.joined(separator: " ")
            
            
            if textView.text.isEmpty {
                textView.text = dummyEmailPlaceholder
                textView.textColor = UIColor(hexCode: 0xBEC0C0)
            }
        }
        
        return true
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func checkAndAddMember(_ userContactEmail: String, nameToSave: String) {
        do {
            if(userContactEmail.isValidEmail())
            {
                let addMemberObj:AddMemberModel = AddMemberModel()
                addMemberObj.member_Email_id = userContactEmail.lowercased()
                
                if nameToSave.isEmpty == false
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
                
                let userInfo = ["selectedUser": addMemberObj as AddMemberModel, "memberTypeTag": memberTypeTag as Int] as [String : Any]
                
                if memberType == "toastee"
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kAddIntendedMember_Notification),
                                                    object: nil,
                                                    userInfo: userInfo)
                }
                else if memberType == "collaborator"
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kAddCollaborator_Notification),
                                                    object: nil,
                                                    userInfo: userInfo)
                }
                else
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kEditIntendedMember_Notification),
                                                    object: nil,
                                                    userInfo: userInfo)
                }
                
            }
        } catch {
            print(error)
        }
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //Dismiss the picker VC
        picker.dismiss(animated: true, completion: nil)
        if contact.emailAddresses.count > 1
        {
            //If so we need the user to select which phone number we want them to use
            let multiplePhoneNumbersAlert = UIAlertController(title: "Which one?", message: "This contact has multiple Email Ids, which one did you want use?", preferredStyle: UIAlertControllerStyle.alert)
            //Loop through all the phone numbers that we got back
            for number in contact.emailAddresses {
                //Each object in the phone numbers array has a value property that is a CNPhoneNumber object, Make sure we can get that
            
                //Get the label for the phone number
                let actualNumber = number.value as String
                var phoneNumberLabel = number.label
                //Strip off all the extra crap that comes through in that label
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "_", with: "", options: .literal, range: nil)
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "$", with: "", options: .literal, range: nil)
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "!", with: "", options: .literal, range: nil)
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "<", with: "", options: .literal, range: nil)
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: ">", with: "", options: .literal, range: nil)
                
                if phoneNumberLabel == nil
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
                    let userContactEmail = actualNumber as String
                    self.checkAndAddMember(userContactEmail, nameToSave: nameToSave)
                })
                //Add the action to the AlertController
                multiplePhoneNumbersAlert.addAction(numberAction)
            }
            
            //Add a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (theAction) -> Void in
                //Cancel action completion
            })
            //Add the cancel action
            multiplePhoneNumbersAlert.addAction(cancelAction)
            
            self.sendingVC.present(multiplePhoneNumbersAlert, animated: true, completion: nil)
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
                    let userContactEmail = actualNumber as String
                    checkAndAddMember(userContactEmail, nameToSave: nameToSave)
                }
            }
            else
            {
                //If there are no email associated with the contact I display an alert Controller to the user
                func handleCancel(_ alertView: UIAlertAction!)
                {
                    self.sendingVC.dismiss(animated: true, completion: nil)
                }
                let alert = UIAlertController(title: "Missing info", message: kNoEmailInContact, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                
                alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                self.sendingVC.present(alert, animated: true, completion: nil)
                
            }
        }
    }
}

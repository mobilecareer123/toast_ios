//
//  ViewToast.swift
//  Toast
//
//  Created by Anish Pandey on 24/12/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class ViewToast: NSObject {
    
    /*{
     "toast_id": 4,
     "toast_title": "Toast for Swapnil,Meghna226666",
     "toastee_count": 2,
     "from_text": "Tea Time Group",
     "category_name": "Farewell",
     "other_category_name": "",
     "theme": "Wish you all the best!",
     "toast_image": "default.jpg",
     "released_date": "2016-11-30 15:30:45",
     "created_date": "2016-11-29 08:02:13",
     "owner_flag": true,
     
     "initiator_details": {
     "user_id": 3,
     "email_id": "meghna@arkenea.com",
     "first_name": "Peter",
     "last_name": "Hadly",
     "profile_photo": "default.jpg"
     },
     "toastee_users": [
     {
     "user_id": 14,
     "email_id": "swapnil@arkenea.com",
     "first_name": "Swapnil",
     "last_name": "Shahane",
     "profile_photo": "default.jpg"
     }
     ],
     "members": [
     {
     "user_id": 16,
     "email_id": "dinesh@arkenea.com",
     "first_name": "Dinesh",
     "last_name": "Patil",
     "profile_photo": "default.jpg"
     }
     ]
     
     }*/
    
    
    var toast_id: String = String()
    var toastTitle: String = String()
    var toasteeCount: String = String()
    var fromText: String = String()
    var categoryName: String = String()
    var otherCategoryName: String = String()
    var theme: String = String()
    var toastImageURL: String = String()
    var releasedDate: String = String()
    var createdDate: String = String()
    var ownerFlag: String = String()
    var toast_notification: String = String()
    var from_text_original: String = String()

    
    var initiatorDetailsArr: NSMutableArray = NSMutableArray() // carries INITIATOR data
    var toasteeUsersArr: NSMutableArray = NSMutableArray() // carries all initiators
    var membersArr: NSMutableArray = NSMutableArray() // carries all members
    var toast_UsersArr: NSMutableArray = NSMutableArray() // carries all data
    
    
    override init() {
        super.init()
    }
    
    func removePrevValues()
    {
        toast_id = ""
        toastTitle = ""
        toasteeCount = ""
        fromText = ""
        from_text_original = ""

        categoryName = ""
        otherCategoryName = ""
        theme = ""
        toastImageURL = ""
        releasedDate = ""
        createdDate = ""
        ownerFlag = ""
        toast_notification = ""
        
        
        initiatorDetailsArr.removeAllObjects() // carries INITIATOR data
        toasteeUsersArr.removeAllObjects() // carries all initiators
        membersArr.removeAllObjects() // carries all members
        toast_UsersArr.removeAllObjects() // carries all data
 
    }
    
    func setData(fromDict dict: NSDictionary)
    {
        self.toast_id = getValueFromDictionary(dicData: dict, forKey: "toast_id")
        self.toastTitle = getValueFromDictionary(dicData: dict, forKey: "toast_title")
        self.toasteeCount = getValueFromDictionary(dicData: dict, forKey: "toastee_count")
        self.fromText = getValueFromDictionary(dicData: dict, forKey: "from_text")
        self.categoryName = getValueFromDictionary(dicData: dict, forKey: "category_name")
        self.otherCategoryName = getValueFromDictionary(dicData: dict, forKey: "other_category_name")
        self.theme = getValueFromDictionary(dicData: dict, forKey: "theme")
        self.toast_notification = getValueFromDictionary(dicData: dict, forKey: "toast_notification")
        
        let toastImage:String = getValueFromDictionary(dicData: dict, forKey: "toast_image")
        if(toastImage.characters.count > 0)
        {
            self.toastImageURL = String(format: "%@%@", KEY_TOAST_PATH, toastImage)
        }
        self.releasedDate = getValueFromDictionary(dicData: dict, forKey: "released_date").convertDateFormatWithTime()
        self.createdDate = getValueFromDictionary(dicData: dict, forKey: "created_date").convertDateFormatWithTime()
        self.ownerFlag = getValueFromDictionary(dicData: dict, forKey: "owner_flag")
        
        
        self.from_text_original = getValueFromDictionary(dicData: dict, forKey: "from_text_original")
        
        if(dict.object(forKey: "initiator_details") != nil)
        {
            
            let initiator = dict["initiator_details"] as! NSDictionary
            let initiatorObj: AddMemberModel = AddMemberModel()
            initiatorObj.setData(fromDict: initiator)
            
            initiatorDetailsArr.add(initiatorObj)
            toast_UsersArr.add(initiatorObj)
        }
        
        if(dict.object(forKey: "toastee_users") != nil)
        {
            let toastee_users = dict["toastee_users"] as! NSArray
         
            for users in toastee_users
            {
                let userObj: AddMemberModel = AddMemberModel()
                userObj.setData(fromDict: users as! NSDictionary)
                
                toasteeUsersArr.add(userObj)
                toast_UsersArr.add(userObj)
            }
        }
        
        
        
        if(dict.object(forKey: "members") != nil)
        {
            let members = dict["members"] as! NSArray
            for member in members
            {
                let memberObj: AddMemberModel = AddMemberModel()
                memberObj.setData(fromDict: member as! NSDictionary)
                
                membersArr.add(memberObj)
                toast_UsersArr.add(memberObj)
            }
        }
        
        
    }
    
}

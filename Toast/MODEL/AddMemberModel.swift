//
//  AddMemberModel.swift
//  Toast
//
//  Created by Anish Pandey on 12/12/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class AddMemberModel: NSObject {

    /*
 
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
    
    var member_User_id: String = String()
    var member_Email_id: String = String()
    var member_First_name: String = String()
    var member_Last_name: String = String()
    var member_Profile_photoURL: String = String()
    
    var accessFlag: String = String()
    var delete_id: String = String()
    var displayName: NSMutableAttributedString = NSMutableAttributedString()
    
    func setData(fromDict dict: NSDictionary)
    {
        self.member_User_id = getValueFromDictionary(dicData: dict, forKey: "user_id")
        self.member_Email_id = getValueFromDictionary(dicData: dict, forKey: "email_id")
        self.member_First_name = getValueFromDictionary(dicData: dict, forKey: "first_name")
        self.member_Last_name = getValueFromDictionary(dicData: dict, forKey: "last_name")
        
        self.accessFlag = getValueFromDictionary(dicData: dict, forKey: "access_flag")
        self.delete_id = getValueFromDictionary(dicData: dict, forKey: "delete_id")
        
        let member_Profile_photo = getValueFromDictionary(dicData: dict, forKey: "profile_photo")
        self.member_Profile_photoURL = String(format: "%@%@", KEY_PROFILEIMAGE_PATH, member_Profile_photo!)

    }
    
    func containsDuplicateEntry(memberArr: NSArray) -> Bool
    {
        for i in 0..<memberArr.count
        {
            if (memberArr.object(at: i) as! AddMemberModel).member_Email_id.lowercased() == self.member_Email_id.lowercased()
            {
                return true
            }
        }
        
        return false
    }
}

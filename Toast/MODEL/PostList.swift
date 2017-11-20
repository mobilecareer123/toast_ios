//
//  PostList.swift
//  Toast
//
//  Created by Anish Pandey on 04/01/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit

class PostList: NSObject {
    
    /*
     "status": "Success",
     "release_button": false,
     "post_list": [
     {
     "user_id": 3,
     "first_name": "Peter",
     "last_name": "Hadly",
     "profile_photo": "default.jpg",
     "post_id": 6,
     "post_text": "Happy Birthday!!",
     "post_image": "",
     "message_posted_on": "2016-12-07 06:14:47",
     "edit_flag": true
     },
     */
    
    var post_user_id: String = String()
    var post_first_name: String = String()
    var post_last_name: String = String()
    var post_profile_photo: String = String()
    var post_msgid: String = String()
    var post_text: String = String()
    var post_image: String = String()
    var post_messaged_on: String = String()
    var post_edit_flag: String = String()
    var post_initiator_flag: String = String()
    
    
    
    func setData(fromDict dict: NSDictionary)
    {
        self.post_user_id = getValueFromDictionary(dicData: dict, forKey: "user_id")
        self.post_first_name = getValueFromDictionary(dicData: dict, forKey: "first_name")
        self.post_last_name = getValueFromDictionary(dicData: dict, forKey: "last_name")
        
        let post_ProfileImgStr:String = getValueFromDictionary(dicData: dict, forKey: "profile_photo")
        
        if post_ProfileImgStr.characters.count > 1
        {
            self.post_profile_photo = String(format: "%@%@", KEY_PROFILEIMAGE_PATH, post_ProfileImgStr)
        }
        else
        {
            self.post_profile_photo = ""
        }
        
        
        self.post_msgid = getValueFromDictionary(dicData: dict, forKey: "post_id")
        self.post_text = getValueFromDictionary(dicData: dict, forKey: "post_text")
        
        self.post_initiator_flag = getValueFromDictionary(dicData: dict, forKey: "initiator_flag")
        
        let post_imageStr:String = getValueFromDictionary(dicData: dict, forKey: "post_image")
        if(post_imageStr.characters.count > 0)
        {
            self.post_image = String(format: "%@%@", KEY_POST_PATH, post_imageStr)
        }
        
        self.post_messaged_on = getValueFromDictionary(dicData: dict, forKey: "message_posted_on").convertDateFormatWithTimeForPostMsg()
        self.post_edit_flag = getValueFromDictionary(dicData: dict, forKey: "edit_flag")
        
    }
}


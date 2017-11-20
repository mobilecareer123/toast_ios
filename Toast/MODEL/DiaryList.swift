//
//  DiaryList.swift
//  Toast
//
//  Created by Anish Pandey on 17/01/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit

class DiaryList: NSObject {
    
    /*
     {
     "status": "Success",
     "toast_list": [
     {
     "blue_dot_flag" = 0;
     "category_name" = Friendship;
     "from_text" = "Anish push";
     "initiator_flag" = 1;
     "member_flag" = 0;
     "message_count" = 1;
     "message_text" = Hi;
     "notification_count" = 0;
     "released_date" = "2017-01-17 12:35:18";
     theme = "Anish test nitification toast";
     "toast_id" = 239;
     "toast_image" = "1484640578.png";
     "toast_title" = "Friendship Toast for Prasad!";
     "toastee_and_member_flag" = 0;
     "toastee_flag" = 0;
     }
     ]
     }
     */
    
    var toast_id: String = String()
    var toastTitle: String = String()
    var fromText: String = String() // from_text
    var categoryName: String = String()
    var releasedDate: String = String()
    var theme: String = String()
    var messageText: String = String()
    
    var eventPhotoUrlStr: String = String() //toast_image
    
    var message_count: String = String()
    
    var initiator_flag: String = String()
    var member_flag: String = String()
    var toastee_flag: String = String()
    var toastee_and_member_flag: String = String()
    var blue_dot_flag: String = String()
   
    
    
    
    func setData(fromDict dict: NSDictionary)
    {
        self.toast_id = getValueFromDictionary(dicData: dict, forKey: "toast_id")
        self.toastTitle = getValueFromDictionary(dicData: dict, forKey: "toast_title")
        self.fromText = getValueFromDictionary(dicData: dict, forKey: "from_text")
        self.categoryName = getValueFromDictionary(dicData: dict, forKey: "category_name")
        self.releasedDate = getValueFromDictionary(dicData: dict, forKey: "released_date").convertDateFormatWithTime()
        self.theme = getValueFromDictionary(dicData: dict, forKey: "theme")
        let toast_image:String = getValueFromDictionary(dicData: dict, forKey: "toast_image")
        if(toast_image.characters.count > 0)
        {
            self.eventPhotoUrlStr = String(format: "%@%@", KEY_TOAST_PATH, toast_image)
        }
        
        
        self.message_count = getValueFromDictionary(dicData: dict, forKey: "message_count")
        self.messageText = getValueFromDictionary(dicData: dict, forKey: "message_text")

        self.initiator_flag = getValueFromDictionary(dicData: dict, forKey: "initiator_flag")
        self.member_flag = getValueFromDictionary(dicData: dict, forKey: "member_flag")
        self.toastee_flag = getValueFromDictionary(dicData: dict, forKey: "toastee_flag")
        self.toastee_and_member_flag = getValueFromDictionary(dicData: dict, forKey: "toastee_and_member_flag")
        self.blue_dot_flag = getValueFromDictionary(dicData: dict, forKey: "blue_dot_flag")
        
    }
    
    
}

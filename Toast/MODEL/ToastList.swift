//
//  ToastList.swift
//  Toast
//
//  Created by Anish Pandey on 12/12/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class ToastList: NSObject {
    /*
     {
     "blue_dot_flag" = 0;
     "category_name" = "Terrific Teacher";
     "from_text" = hello;
     "message_count" = 0;
       "message_sent" = 1; // 1 (true) - if msg not posted
     "notification_count" = 0;
     "owner_access" = 1;
     "released_date" = "0000-00-00 00:00:00";
     theme = "Toast Theme";
     "toast_id" = 21;
     "toast_image" = "1482586384.png";
     "toast_title" = "Terrific Teacher Toast for B!";
     "total_members" = 2;
     }"
     */
    
    var toast_id: String = String()
    var toastTitle: String = String()
    var messageSender: String = String()
    var category_name: String = String()
    var releasedDate: String = String()
    var theme: String = String()
    var eventPhotoUrlStr: String = String()
    var total_members: String = String()
    var message_count: String = String()
    var owner_access: String = String()
    var blue_dot_flag: String = String()
    var no_message_flag: String = String()
    
    
    
    func setData(fromDict dict: NSDictionary)
    {
        self.toast_id = getValueFromDictionary(dicData: dict, forKey: "toast_id")
        self.toastTitle = getValueFromDictionary(dicData: dict, forKey: "toast_title")
        self.messageSender = getValueFromDictionary(dicData: dict, forKey: "from_text")
        self.category_name = getValueFromDictionary(dicData: dict, forKey: "category_name")
        self.releasedDate = getValueFromDictionary(dicData: dict, forKey: "released_date").convertDateFormatWithTime()
        self.theme = getValueFromDictionary(dicData: dict, forKey: "theme")
        let toast_image:String = getValueFromDictionary(dicData: dict, forKey: "toast_image")
        if(toast_image.characters.count > 0)
        {
            self.eventPhotoUrlStr = String(format: "%@%@", KEY_TOAST_PATH, toast_image)
        }
        self.total_members = getValueFromDictionary(dicData: dict, forKey: "total_members")
        self.message_count = getValueFromDictionary(dicData: dict, forKey: "message_count")
        self.owner_access = getValueFromDictionary(dicData: dict, forKey: "owner_access")
        self.blue_dot_flag = getValueFromDictionary(dicData: dict, forKey: "blue_dot_flag")
        self.no_message_flag = getValueFromDictionary(dicData: dict, forKey: "message_sent")
    }
    
}

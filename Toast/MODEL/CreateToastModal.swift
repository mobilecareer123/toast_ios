//
//  CreateToastModal.swift
//  Toast
//
//  Created by Anish Pandey on 12/12/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class CreateToastModal: NSObject {

    
    var toast_Theme_s1: String = String()
    var due_date_s1: String = String()
    var group_Name_s1: String = String()
    var toast_notification_s1: String = "Y"
   
    var intended_users_s1:NSMutableArray = NSMutableArray() // toastee list

    var category_name_s2: String = String()
    var other_category_name_s2: String = String()
    var isCategoryByTxtFld:Bool = false
     // Send TOAST_Image_s3 in multipart
    
    var members_s4:NSMutableArray = NSMutableArray()
    
    var toastImage_added : UIImage!
    
    override init() {
        super.init()
    }
}


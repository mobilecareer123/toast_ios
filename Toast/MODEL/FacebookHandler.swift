//
//  FacebookHandler.swift
//  Viva
//
//  Created by Mahesh Agrawal on 8/19/16.
//  Copyright © 2016 Mahesh Agrawal. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookHandler: NSObject {
    
    typealias FacebookCompletion = (_ response: AnyObject?, _ error: NSError?) -> Void
    static let userFields: String = "id,name,email, first_name, last_name, gender, picture"
    static let readPermissions: [AnyObject] = ["public_profile" as AnyObject, "email" as AnyObject,"user_friends" as AnyObject]
    static let successMessage: String = "Facebook login successful"
    static let failedMessage: String = "Facebook login failed due to unexpected error. Please try again."
    static let cancelledMessage: String = "Facebook login cancelled by user"
    
    static func loginToFacebookFromController(controller:UIViewController, fbCompletion: @escaping FacebookCompletion) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: readPermissions, from: controller) { (result:FBSDKLoginManagerLoginResult?, error:Error?) in
           DispatchQueue.main.async(execute: {
                if error == nil && result?.isCancelled == false {
                    fbCompletion(successMessage as AnyObject?, nil)
                } else if (result?.isCancelled == true) {
                    fbCompletion(nil, NSError(domain: NSURLErrorDomain, code: 102, userInfo: [NSLocalizedDescriptionKey:cancelledMessage]))
                } else {
                    fbCompletion(nil, NSError(domain: NSURLErrorDomain, code: 103, userInfo: [NSLocalizedDescriptionKey:failedMessage]))
                }
            })
        }
    }
    
    static func getUserDetailsFromController(controller:UIViewController, fbCompletion: @escaping FacebookCompletion) {
        if FBSDKAccessToken.current() != nil {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": userFields])
            graphRequest.start(completionHandler: { (connection:FBSDKGraphRequestConnection?, response:Any?, error:Error?) in
                DispatchQueue.main.async(execute: {
                    fbCompletion(response as AnyObject?, error as NSError?)
                })
            })
        } else {
            FacebookHandler.loginToFacebookFromController(controller: controller, fbCompletion: { (response, error) in
                if error == nil {
                    FacebookHandler.getUserDetailsFromController(controller: controller, fbCompletion: fbCompletion)
                } else {
                    fbCompletion(nil, error)
                }
            })
        }
    }
    
    static func logoutFromAllAcounts() {
        FBSDKAccessToken.setCurrent(nil)
        print("**************************** FaceBook logoutFromAllAcounts done ****************************")
    }
}

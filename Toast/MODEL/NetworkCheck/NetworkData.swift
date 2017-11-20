//
//  Data.swift
//  DocRounds
//
//  Created by Arkenea on 01/06/15.
//  Copyright (c) 2015 Ashwini@Arkenea. All rights reserved.
//

import UIKit

class NetworkData: NSObject {
    
//    var firstName: NSString
//    var lastName: NSString
//    var profileImage: UIImage // no need (!). It will be initialised from controller
    
    let useClosures = false
    var reachability = Reachability.init()
    var networkSTR: NSString = NSString()
  
    override init()
    {
        
        super.init()
        self.checkNetwork()
    }
    
//    init(fromDict dict: NSDictionary) {
//        NSLog("dict=%@",dict)
//        self.firstName =  NSString(format: "%@",dict["firstName"]! as! NSString)
//        self.lastName =  NSString(format: "%@",dict["lastName"]! as! NSString)
//        self.profileImage = dict["profileImage"]! as! UIImage
//       
//    super.init()
//        
//        //self.setValuesFromDict(dict)
//        
//    }
    
    func setValuesFromDict(_ dict:NSDictionary){
        
    }
    
    func checkNetwork(){
        if (useClosures) {
            reachability!.whenReachable = { reachability in
                self.updateLabelColourWhenReachable(reachability)
            }
            reachability!.whenUnreachable = { reachability in
                self.updateLabelColourWhenNotReachable(reachability)
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(NetworkData.reachabilityChanged(_:)), name:ReachabilityChangedNotification, object: reachability)

        }
        
        self.startNotifier()
        
        // Initial reachability check
        if reachability!.isReachable {
            updateLabelColourWhenReachable(reachability!)
        } else {
            updateLabelColourWhenNotReachable(reachability!)
        }
 
    }
    
    deinit {
        
        reachability!.stopNotifier()
        
        if (!useClosures) {
            NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
//            self.networkStatus.textColor = .red
//            self.networkStatus.text = "Unable to start\nnotifier"
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    func updateLabelColourWhenReachable(_ reachability: Reachability) {
//        if reachability.isReachableViaWiFi() {
//            self.networkStatus.textColor = UIColor.greenColor()
//            NSLog("reachability = %@", reachability.currentReachabilityString)
//        } else {
//           
//        }
        
         NSLog("reachability = %@", reachability.currentReachabilityString)
        self.networkSTR = reachability.currentReachabilityString as NSString
    }
    
    func updateLabelColourWhenNotReachable(_ reachability: Reachability) {
        NSLog("reachability = %@", reachability.currentReachabilityString)
        self.networkSTR = reachability.currentReachabilityString as NSString
    }
    
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            updateLabelColourWhenReachable(reachability)
        } else {
            updateLabelColourWhenNotReachable(reachability)
        }
        self.networkSTR = reachability.currentReachabilityString as NSString
    }

}

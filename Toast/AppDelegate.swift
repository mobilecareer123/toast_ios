 ////
//  AppDelegate.swift
//  Toast
//
//  Created by Anish Pandey on 04/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import Social
import Accounts

import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import UserNotifications
import Crittercism

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIGestureRecognizerDelegate, UITabBarDelegate, UITabBarControllerDelegate,FBSDKGraphRequestConnectionDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    var tabBarController = UITabBarController()
    var startNavController = UINavigationController()
    var logInID : NSString?
    
    var transfer : NSString?
    var notiDict:NSDictionary = NSDictionary()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.startApp()
        
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
            
        }
        application.registerForRemoteNotifications()
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        Crittercism.enable(withAppID: "aa78c906bda545588b16294e8ddec12200555300")
        
        return true
    }
    
    
    func startApp()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let defaults = UserDefaults.standard
        logInID = defaults.string(forKey: KEY_LOGIN) as NSString?
        
        if let newlogInID = logInID
        {
            if(newlogInID == "UserLoggedIn") //verified user and profile created
            {
                self.startAppForLoggedInUser()
            }
            else
            {
                let getStartedVC = storyboard.instantiateViewController(withIdentifier: "getStartedVC") as! TGetStartedVC
                startNavController = storyboard.instantiateViewController(withIdentifier: "StartNavController") as! UINavigationController
                startNavController = UINavigationController(rootViewController: getStartedVC)
                
                let font:UIFont = UIFont(name: "HelveticaNeue-Medium", size: 17.0)!
                startNavController.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(hexCode: 0xFFFFFF)]
                startNavController.navigationBar.tintColor = UIColor(hexCode:0xFFFFFF)
                startNavController.navigationBar.barTintColor = UIColor(hexCode: 0xCEAF5C)
                startNavController.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
                startNavController.navigationBar.isTranslucent = false
                startNavController.navigationBar.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                startNavController.navigationBar.shadowImage = UIImage()
                self.setStausBarColorAndMerageWithNavigationBar(navBar: startNavController.navigationBar)
                
                startNavController.setNavigationBarHidden(true, animated: true)
                self.window?.rootViewController = startNavController
                
                
            }
        }
        else
        {
            let getStartedVC = storyboard.instantiateViewController(withIdentifier: "getStartedVC") as! TGetStartedVC
            startNavController = storyboard.instantiateViewController(withIdentifier: "StartNavController") as! UINavigationController
            startNavController = UINavigationController(rootViewController: getStartedVC)
            
            let font:UIFont = UIFont(name: "HelveticaNeue-Medium", size: 17.0)!
            startNavController.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(hexCode: 0xFFFFFF)]
            startNavController.navigationBar.tintColor = UIColor(hexCode:0xFFFFFF)
            startNavController.navigationBar.barTintColor = UIColor(hexCode: 0xCEAF5C)
            startNavController.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
            startNavController.navigationBar.isTranslucent = false
            startNavController.navigationBar.backgroundColor = UIColor(hexCode: 0xCEAF5C)
            startNavController.navigationBar.shadowImage = UIImage()
            self.setStausBarColorAndMerageWithNavigationBar(navBar: startNavController.navigationBar)
            
            startNavController.setNavigationBarHidden(true, animated: true)
            self.window?.rootViewController = startNavController
            
        }
        
        window?.makeKeyAndVisible()
        window?.backgroundColor = UIColor.white
    }
    
    func startAppForLoggedInUser()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let firstVC = storyboard.instantiateViewController(withIdentifier: "TFirstVC") as! TtoastVC
        var firstNavController = storyboard.instantiateViewController(withIdentifier: "firstNavController") as! UINavigationController
        firstNavController = UINavigationController(rootViewController: firstVC)
        
        let SecondVC = storyboard.instantiateViewController(withIdentifier: "TSecondVC") as! TDiaryVC
        var secondNavController = storyboard.instantiateViewController(withIdentifier: "secondNavController") as! UINavigationController
        secondNavController = UINavigationController(rootViewController: SecondVC)
        
        let thirdVC = storyboard.instantiateViewController(withIdentifier: "TThirdVC") as! TSettingsVC
        var thirdNavController = storyboard.instantiateViewController(withIdentifier: "thirdNavController") as! UINavigationController
        thirdNavController = UINavigationController(rootViewController: thirdVC)
        
        let forthVC = storyboard.instantiateViewController(withIdentifier: "TForthVC") as! TMoreVC
        var forthNavController = storyboard.instantiateViewController(withIdentifier: "forthNavController") as! UINavigationController
        forthNavController = UINavigationController(rootViewController: forthVC)
        
        // UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        let font:UIFont = UIFont(name: "HelveticaNeue-Medium", size: 17.0)!
        firstNavController.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(hexCode: 0xFFFFFF)]
        firstNavController.navigationBar.tintColor = UIColor(hexCode:0xFFFFFF)
        firstNavController.navigationBar.barTintColor = UIColor(hexCode: 0xCEAF5C)
        firstNavController.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        firstNavController.navigationBar.isTranslucent = false
        firstNavController.navigationBar.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        firstNavController.navigationBar.shadowImage = UIImage()
        self.setStausBarColorAndMerageWithNavigationBar(navBar: firstNavController.navigationBar)
        
        secondNavController.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(hexCode: 0xFFFFFF)]
        secondNavController.navigationBar.tintColor = UIColor(hexCode:0xFFFFFF)
        secondNavController.navigationBar.barTintColor = UIColor(hexCode: 0xCEAF5C)
        secondNavController.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        secondNavController.navigationBar.isTranslucent = false
        
        secondNavController.navigationBar.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        secondNavController.navigationBar.shadowImage = UIImage()
        self.setStausBarColorAndMerageWithNavigationBar(navBar: secondNavController.navigationBar)
        
        thirdNavController.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(hexCode: 0xFFFFFF)]
        thirdNavController.navigationBar.tintColor = UIColor(hexCode:0xFFFFFF)
        thirdNavController.navigationBar.barTintColor = UIColor(hexCode: 0xCEAF5C)
        thirdNavController.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        thirdNavController.navigationBar.isTranslucent = false
        
        thirdNavController.navigationBar.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        thirdNavController.navigationBar.shadowImage = UIImage()
        self.setStausBarColorAndMerageWithNavigationBar(navBar: thirdNavController.navigationBar)
        
        
        forthNavController.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(hexCode: 0xFFFFFF)]
        forthNavController.navigationBar.tintColor = UIColor(hexCode:0xFFFFFF)
        forthNavController.navigationBar.barTintColor = UIColor(hexCode: 0xCEAF5C)
        forthNavController.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        forthNavController.navigationBar.isTranslucent = false
        
        forthNavController.navigationBar.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        forthNavController.navigationBar.shadowImage = UIImage()
        self.setStausBarColorAndMerageWithNavigationBar(navBar: forthNavController.navigationBar)
        
        tabBarController.viewControllers = [firstNavController, secondNavController,  thirdNavController, forthNavController]
        tabBarController.delegate = self
        tabBarController.selectedIndex = 0
        let screenHeight = UIScreen.main.bounds.height
        
        var item1 = UITabBarItem()
        var item2 = UITabBarItem()
        var item3 = UITabBarItem()
        var item4 = UITabBarItem()
        
        if(screenHeight == 667)
        {
            item1 = UITabBarItem(title: nil, image: UIImage(named: "UnselectTab_Toast6")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "selectTab_Toast6")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
            item1.tag = 0
            
            item2 = UITabBarItem(title: nil, image: UIImage(named: "UnselectTab_Diary6")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named:"selectTab_Diary6")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
            item2.tag = 1
            
            item3 = UITabBarItem(title: nil, image: UIImage(named: "UnselectTab_Settings6")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named:"selectTab_Settings6")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
            item3.tag = 2
            
            item4 = UITabBarItem(title: nil, image: UIImage(named: "UnselectTab_More6")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "selectTab_More6")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
            item4.tag = 3
            
        }else{
            item1 = UITabBarItem(title: nil, image: UIImage(named: "UnselectTab_Toast")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "selectTab_Toast")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
            item1.tag = 0
            
            item2 = UITabBarItem(title: nil, image: UIImage(named: "UnselectTab_Diary")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named:"selectTab_Diary")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
            item2.tag = 1
            
            item3 = UITabBarItem(title: nil, image: UIImage(named: "UnselectTab_Settings")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named:"selectTab_Settings")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
            item3.tag = 2
            
            item4 = UITabBarItem(title: nil, image: UIImage(named: "UnselectTab_More")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "selectTab_More")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
            item4.tag = 3
            
        }
        
        
        tabBarController.tabBar.barTintColor = UIColor(hexCode: 0xCEAF5C)
        tabBarController.tabBar.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        
        firstNavController.tabBarItem = item1
        secondNavController.tabBarItem = item2
        thirdNavController.tabBarItem = item3
        forthNavController.tabBarItem = item4
        
        firstNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        secondNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        thirdNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        forthNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
        tabBarController.tabBar.layer.borderColor = UIColor(hexCode: 0xCEAF5C).cgColor
        
        tabBarController.tabBar.shadowImage = UIImage(named : "tabbar_gray_line")
        //tabBarController.tabBar.backgroundImage = UIImage()
        tabBarController.tabBar.isTranslucent = false
        
        self.window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let fromView: UIView = tabBarController.selectedViewController!.view
        let toView  : UIView = viewController.view
        if fromView == toView {
            return false
        }
        UIView.transition(from: fromView, to: toView, duration: 0.0, options: UIViewAnimationOptions.transitionCrossDissolve) { (finished:Bool) in
            
        }
        
        return true
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        viewController.tabBarItem.badgeValue = nil
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //This method will be called when user changes tab.
        
        if(item.tag == 1) {
            //your code for tab item 1
            item.badgeValue = nil
        }
        else if(item.tag == 2) {
            //your code for tab item 2
            
            item.badgeValue = nil
        }
    }
    
    func setStausBarColorAndMerageWithNavigationBar(navBar:UINavigationBar)
    {
        let statusBarView = UIView()
        statusBarView.backgroundColor = navBar.backgroundColor
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(statusBarView)
        
        let views = ["statusBarView": statusBarView]
        let hConstraint = "H:|-0-[statusBarView]-0-|"
        let vConstraint = "V:|-(-20)-[statusBarView(20)]"
        
        var allConstraints = NSLayoutConstraint.constraints(withVisualFormat: hConstraint,
                                                            options: [], metrics: nil, views: views)
        
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: vConstraint,
                                                         options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(allConstraints)
        
    }
    
    // MARK : - Register Notifications
    
    func application(_ application: UIApplication, didRegister notificationSettings: UNNotificationSettings) {
        // if notificationSettings.alertStyle != .none {
        application.registerForRemoteNotifications()
        // }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        
        
        var deviceTokenString = ""
        for i in 0..<deviceToken.count {
            deviceTokenString = deviceTokenString + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(deviceTokenString)
        
        
        
        let defaults = UserDefaults.standard
        defaults.setValue(deviceTokenString, forKey: KEY_DEVICE_TOKEN)
        
        print( "devicetoken==\(deviceTokenString )")
    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        
        print("didFailToRegisterForRemoteNotificationsWithError== \(error.localizedDescription) ")
    }
    
    func addBadge(index: Int, value: Int, color: UIColor, font: UIFont) {
        
        for view in self.tabBarController.tabBar.subviews {
            
            if view is CustomTabBadge {
                
                if value == 0 && (view.tag == index)
                {
                    view.removeFromSuperview()
                }
            }
        }
        
        let badgeView = CustomTabBadge()
        badgeView.clipsToBounds = true
        badgeView.textColor = UIColor.white
        badgeView.textAlignment = .center
        badgeView.font = font
        badgeView.text = " "
        badgeView.backgroundColor = color
        badgeView.tag = index
        tabBarController.tabBar.addSubview(badgeView)
        
        self.positionBadges()
    }
    
    
    // Positioning
    func positionBadges() {
        
        var tabbarButtons = self.tabBarController.tabBar.subviews.filter { (view: UIView) -> Bool in
            return view.isUserInteractionEnabled // only UITabBarButton are userInteractionEnabled
        }
        
        tabbarButtons = tabbarButtons.sorted(by: { $0.frame.origin.x < $1.frame.origin.x })
        
        for view in self.tabBarController.tabBar.subviews {
            if view is CustomTabBadge {
                let badgeView = view as! CustomTabBadge
                self.positionBadge(badgeView: badgeView, items:tabbarButtons, index: badgeView.tag)
            }
        }
    }
    
    func positionBadge(badgeView: UIView, items: [UIView], index: Int) {
        
        let itemView = items[index]
        let center = itemView.center
        
        let xOffset: CGFloat = 12
        let yOffset: CGFloat = -14
        badgeView.frame.size = CGSize(width: 17, height: 17)
        badgeView.center = CGPoint(x: center.x + xOffset, y: center.y + yOffset)
        badgeView.layer.cornerRadius = badgeView.bounds.width/2
        tabBarController.tabBar.bringSubview(toFront: badgeView)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo as NSDictionary)
        
        //        let tabArray = self.tabBarController.tabBar.items as NSArray!
        //        let tabItem = tabArray?.object(at: 0) as! UITabBarItem
        //        tabItem.badgeValue = ""
        
        notiDict = userInfo["aps"] as! NSDictionary
        
        let state: UIApplicationState = application.applicationState
        
        
        // Handle for inactive and background mode
        
        if state == UIApplicationState.inactive || state == UIApplicationState.background {
            
            //delay notification method handling when app is terminated
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.delayNotificationAction), userInfo: nil, repeats: false)
            
        }
        else{
            //Show an alert view
            let state: UIApplicationState = application.applicationState
            if (state == UIApplicationState.active)
            {
                if(notiDict["flag"] as! NSString == "PostNewMessage" || notiDict["flag"] as! NSString == "SendReminder" || notiDict["flag"] as! NSString == "CreateNewToast" || notiDict["flag"] as! NSString == "ChangeOwnership") // for Toast Tab
                {
                    
                    self.addBadge(index: 0, value: 1, color: UIColor.blue, font: UIFont(name: "Helvetica-Light", size: 11)!)
                    
                }
                else // For Diary Tab
                {
                    
                    self.addBadge(index: 1, value: 1, color: UIColor.blue, font: UIFont(name: "Helvetica-Light", size: 11)!)
                }
                
                /*
                if(userInfo["flag"] as! NSString == "CreateNewToast" || userInfo["flag"] as! NSString == "ChangeOwnership")
                {
                // for CreateNewToast , ChangeOwnership
                    
                    // Called when notification is received and needs to update offset
                    
                    let userInfo = ["newData": userInfo["flag"] as! NSString]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateOffset_Notification), object: userInfo)
                    
                }
 */

                
                self.showNotificationPopup(userInfo: notiDict )
            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func delayNotificationAction()
    {
        self.handleInactiveStateNotification(userInfo: notiDict )
    }
    
    func handleInactiveStateNotification(userInfo : NSDictionary)
    {
        if(notiDict["flag"] as! NSString != "ToastRelease")
        {
            if(notiDict["flag"] as! NSString == "PostNewMessage" || notiDict["flag"] as! NSString == "SendReminder") //Trigger to open ChatVC
            {
                if(self.getTopViewController().isKind(of: TtoastVC().classForCoder))//if visible viewcontroller is TToastVC then carry notification Dict with local notification and received it in TToastVC.
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToCheersScreen_pushNotification), object: notiDict)
                }
                else if(self.getTopViewController().isKind(of: TChatViewController().classForCoder))//if visible viewcontroller is TChatViewController then carry notification Dict with local notification and received it in TChatViewController.
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kCheersScreen_pushNotification), object: notiDict)
                }
                else//else first open tabbarcontroller's first tab i.e. TToastVC and carry notification Dict with local notification and received it in TToastVC.
                {
                    self.tabBarController.selectedIndex = 0
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToCheersScreen_pushNotification), object: notiDict)
                }
            }
            else//Trigger to open View Toast Details , for CreateNewToast , ChangeOwnership
            {
                if(self.getTopViewController().isKind(of: TtoastVC().classForCoder))//if visible viewcontroller is TToastVC then carry notification Dict with local notification and received it in TToastVC.
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: notiDict)
                }
                else if(self.getTopViewController().isKind(of: TViewToastDetailVC().classForCoder))//if visible viewcontroller is TViewToastDetailVC then carry notification Dict with local notification and received it in TViewToastDetailVC.
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToViewToastViaChatVC_pushNotification), object: notiDict)
                }
                else//else first open tabbarcontroller's first tab i.e. TToastVC and carry notification Dict with local notification and received it in TToastVC.
                {
                    self.tabBarController.selectedIndex = 0
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: notiDict)
                }
            }
        }
            
        else{
            // code for Release Toast
            if(self.getTopViewController().isKind(of: TDiaryVC().classForCoder))//if visible viewcontroller is TDiaryVC then carry notification Dict with local notification and received it in TDiaryVC.
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: notiDict)
                
            }
            else//else first open tabbarcontroller's first tab i.e. TDiaryVC and carry notification Dict with local notification and received it in TDiaryVC.
            {
                self.tabBarController.selectedIndex = 1
                
                //delay diary tab call when app is terminated
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: self.notiDict)
                }
                
            }
        }
    }
    
    
    func showNotificationPopup(userInfo : NSDictionary)
    {
        AGPushNoteView.show(withNotificationMessage: userInfo["alert"] as! String)
        AGPushNoteView.setMessageAction { (String) in
            
            // Handle for Active mode
            if(userInfo["flag"] as! NSString != "ToastRelease")
            {
                if(userInfo["flag"] as! NSString == "PostNewMessage" || userInfo["flag"] as! NSString == "SendReminder")
                {
                    if(self.getTopViewController().isKind(of: TtoastVC().classForCoder))//if visible viewcontroller is TToastVC then carry notification Dict with local notification and received it in TToastVC.
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToCheersScreen_pushNotification), object: userInfo)
                    }
                    else if(self.getTopViewController().isKind(of: TChatViewController().classForCoder))//if visible viewcontroller is TChatViewController then carry notification Dict with local notification and received it in TChatViewController.
                    {
                        if self.tabBarController.selectedIndex == 1 //  user is on chatVC via diary flow
                        {
                            // first open tabbarcontroller's first tab i.e. TToastVC and carry notification Dict with local notification and received it in TToastVC.
                            
                            //                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPopDiaryToastVC_pushNotification), object: userInfo) // fire to pop the chat view first else diary tab will show updated toast data and then fire "kRedirectToCheersScreen_pushNotification"
                            
                            self.tabBarController.selectedIndex = 0
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToCheersScreen_pushNotification), object: userInfo)
                        }
                        else{
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kCheersScreen_pushNotification), object: userInfo)
                        }
                        
                    }
                    else//else first open tabbarcontroller's first tab i.e. TToastVC and carry notification Dict with local notification and received it in TToastVC.
                    {
                        self.tabBarController.selectedIndex = 0
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToCheersScreen_pushNotification), object: userInfo)
                    }
                }
                else // for CreateNewToast , ChangeOwnership
                {
                    if(self.getTopViewController().isKind(of: TtoastVC().classForCoder))//if visible viewcontroller is TToastVC then carry notification Dict with local notification and received it in TToastVC.
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: userInfo)
                    }
                    else if(self.getTopViewController().isKind(of: TViewToastDetailVC().classForCoder))//if visible viewcontroller is TViewToastDetailVC then carry notification Dict with local notification and received it in TViewToastDetailVC.
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToViewToastViaChatVC_pushNotification), object: userInfo)
                    }
                    else//else first open tabbarcontroller's first tab i.e. TToastVC and carry notification Dict with local notification and received it in TToastVC.
                        
                        // else => chat screen or any other screen
                    {
                        self.tabBarController.selectedIndex = 0
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRedirectToViewToastScreen_pushNotification), object: userInfo)
                    }
                }
            }
            else{  // code for Release Toast
                
                if(self.getTopViewController().isKind(of: TDiaryVC().classForCoder))//if visible viewcontroller is TDiaryVC then carry notification Dict with local notification and received it in TDiaryVC.
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: userInfo)
                    
                }
                else//else first open tabbarcontroller's second tab i.e. TDiaryVC and carry notification Dict with local notification and received it in TDiaryVC.
                {
                    self.tabBarController.selectedIndex = 1
                    
                    let deadlineTime = DispatchTime.now() + .seconds(1)
                    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kToastRaised_PushNotification), object: userInfo)
                    }
                    
                    
                }
            }
        }
    }
    
    
    func getTopViewController()->UIViewController
    {
        let rootViewController:UIViewController? = self.window?.rootViewController
        if((rootViewController?.isKind(of: UITabBarController.classForCoder())) != nil)
        {
            let tabVC:UITabBarController = rootViewController as! UITabBarController
            //            var navVC:UINavigationController = UINavigationController(rootViewController: tabVC.selectedViewController!)
            let navVC:UINavigationController = tabVC.selectedViewController as! UINavigationController
            if (navVC .isKind(of: UINavigationController.classForCoder()))
            {
                let topVc:UIViewController = navVC.topViewController!
                return topVc
            }
        }
        return UIViewController()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
}


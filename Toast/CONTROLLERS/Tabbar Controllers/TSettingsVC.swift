//
//  TThirdViewController.swift
//  Toast
//
//  Created by Anish Pandey on 07/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class TSettingsVC:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView_Settings: UITableView!
    var arr_Settings:NSMutableArray = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let loginType = UserDefaults.standard.value(forKey: KEY_SOCIALMEDIA_TYPE)
        
        if loginType as! String == "fbLogin" as String //  hide change pwd option
        {
            arr_Settings = [["Name" : "Profile", "Image" : "ic_setting profile golden"],
                            ["Name" : "Change Email", "Image" : "ic_change email golden" ],
                            ["Name" : "Logout", "Image" : "ic_logout golden"]]

        }
        else
        {
            arr_Settings = [["Name" : "Profile", "Image" : "ic_setting profile golden"],
                            ["Name" : "Change Email", "Image" : "ic_change email golden" ],
                            ["Name" : "Change Password", "Image" : "ic_change pswd golden" ],
                            ["Name" : "Logout", "Image" : "ic_logout golden"]]

        }
        
        self.CustomiseView()
        
    }
    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Settings")
    }
    // MARK: - Table View Delegate and Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_Settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height * (45.0 / 568.0)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "leftMenuCell"
        var cell:LeftMenuCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? LeftMenuCell
        
        if (cell == nil){
            tableView.register(UINib(nibName: "LeftMenuCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? LeftMenuCell
            cell?.layoutMargins = UIEdgeInsets.zero
            cell?.preservesSuperviewLayoutMargins=false
            cell?.backgroundColor = UIColor.clear
        }
        
        cell?.menuTitle.text = (arr_Settings[indexPath.row] as? NSDictionary)?.value(forKey: "Name") as? String
        cell?.menuImage.image = UIImage(named:((arr_Settings[indexPath.row] as? NSDictionary)?.value(forKey: "Image") as? String)!
        )
        if(indexPath.row == 3)
        {
            cell?.img_Arrow.isHidden = true
        }
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.white
        cell!.selectedBackgroundView = bgColorView
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0
        {
            self.performSegue(withIdentifier: "SetToEditProfileSeg", sender: self)
        }
        else if indexPath.row == 1
        {
            self.performSegue(withIdentifier: "SetToEmailChangeSeg", sender: self)
        }
        else if indexPath.row == 2
        {
            let loginType = UserDefaults.standard.value(forKey: KEY_SOCIALMEDIA_TYPE)
            
            if loginType as! String == "fbLogin" //  hide change pwd option
            {
                func handleLogout(_ alertView: UIAlertAction!)
                {
                    self.logout()
                }
                func handleCancel(_ alertView: UIAlertAction!)
                {
                    
                }
                
                let alert = UIAlertController(title: "Confirm", message: "Do you want to Logout?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler:handleLogout))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
                
                alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
                self.present(alert, animated: true, completion: nil)

            }
            else
            {
                self.performSegue(withIdentifier: "SetToPwdChangeSeg", sender: self)
            }
            
        }
        else
        {
            func handleLogout(_ alertView: UIAlertAction!)
            {
                self.logout()
            }
            func handleCancel(_ alertView: UIAlertAction!)
            {
                
            }
            
            let alert = UIAlertController(title: "Confirm", message: "Do you want to Logout?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler:handleLogout))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:handleCancel))
            
            alert.view.tintColor = UIColor(hexCode:0xCEAF5C)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func logout()
    {
        /*"{
         ""service"": ""logout"",
         ""user_id"": ""4"",
         ""access_token"": ""6850394721Y2hhbWFr""
         }"*/
        
        let device_Token = UserDefaults.standard.value(forKey: KEY_DEVICE_TOKEN)
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            
            SVProgressHUD.show(withStatus: "Logging out", maskType: .gradient)
            let parameters: NSDictionary = ["service": "logout", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        let device_Token = UserDefaults.standard.value(forKey: KEY_DEVICE_TOKEN)
                        let defaults = UserDefaults.standard
                        let appDomain:NSString = Bundle.main.bundleIdentifier! as NSString
                        defaults.removePersistentDomain(forName: appDomain as String)
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.startApp()
                        
                        UserDefaults.standard.setValue(device_Token, forKey: KEY_DEVICE_TOKEN)
                    })
                    FacebookHandler.logoutFromAllAcounts()
                }
                if(statusToken as String == "Error" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        let error_message:NSString =  NSString(format: "%@",response["Error"]! as! NSString)
                        SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                    })
                }
            }
            
        }
        else
        {
            SVProgressHUD.showInfo(withStatus: "Please check your internet connection.", maskType: .gradient)
        }
        
    }
    /*
     
     ** Seg List
     
     SetToPwdChangeSeg
     SetToEmailChangeSeg
     SetToEditProfileSeg
     
     */
    
    
    override var hidesBottomBarWhenPushed: Bool
        {
        get { return false }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

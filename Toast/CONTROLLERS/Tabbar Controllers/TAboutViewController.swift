//
//  TAboutViewController.swift
//  Toast
//
//  Created by Anish Pandey on 06/12/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class TAboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView_About: UITableView!
    @IBOutlet weak var lbl_showAppVersion: UILabel!
    
    var arr_aboutData:NSMutableArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CustomiseView()
        
        arr_aboutData = NSMutableArray(array:[
            ["Title":"Create", "Description":"Toast with a custom theme.","Image":"ic_About_create"],
            ["Title":"Invite", "Description":"Collaborators to the Toast. Collaborators get notified via email and app notification.","Image":"ic_About_invite"],
            ["Title":"Remind", "Description":"Collaborators to Cheer.","Image":"ic_About_remind"],
            ["Title":"Raise", "Description":"Raise the Toast to the Toastee. Toastees get notified via email and app notification.","Image":"ic_About_raise"],
            ["Title":"Cherish", "Description":"The memory forever.","Image":"ic_About_cherish"]
            ])
        
        tblView_About.estimatedRowHeight = 83.0
        tblView_About.rowHeight = UITableViewAutomaticDimension
        
        let buildVersion: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String // use for buildVersion
        let shortBundleVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String // use for shortBundleVersion
        
        let abtStr = NSString(format: "Version: %@ (%@)", shortBundleVersion,buildVersion) as String
        
        lbl_showAppVersion.text = abtStr

    }
    
    func CustomiseView()
    {
         self.navigationItem.titleView = getNavigationTitle(inputStr: "About")
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TAboutViewController.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        self.navigationItem.titleView = getNavigationTitle(inputStr: "About")
    }
    
    // MARK: - Button Action
    func backBtnClicked(_ sender: UIButton) {
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    override var hidesBottomBarWhenPushed: Bool
        {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arr_aboutData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "AboutCell"
        var cell:AboutCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AboutCell
        if (cell == nil){
            tableView.register(UINib(nibName: "AboutCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AboutCell
            cell?.layoutMargins=UIEdgeInsets.zero
            cell?.preservesSuperviewLayoutMargins=false
            cell?.backgroundColor=UIColor.clear
        }
        cell?.selectionStyle = .none
        
        let dicData: NSDictionary = self.arr_aboutData.object(at: indexPath.row) as! NSDictionary
        
        cell?.lbl_Title.text = dicData.value(forKey: "Title") as? String
        cell?.imgView_Icon.image = UIImage(named: dicData.value(forKey: "Image") as! String)
        
        cell?.lbl_Description.text = dicData.value(forKey: "Description") as? String
        cell?.lbl_Description.lineBreakMode = .byWordWrapping
        cell?.lbl_Description.numberOfLines = 0
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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

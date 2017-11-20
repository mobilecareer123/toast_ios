//
//  TForthViewController.swift
//  Toast
//
//  Created by Anish Pandey on 07/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import MessageUI

class TMoreVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tblView_More: UITableView!
    var arr_More:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arr_More = [[["Name" : "How to use the App", "Image" : "ic_use app golden"],
                     ["Name" : "About", "Image" : "ic_about golden" ],
                     ["Name" : "Terms and Conditions", "Image" : "ic_t&c golden"]],
                    
                    [["Name" : "Contact Us", "Image" : "ic_contact golden"]],
                    
                    [["Name" : "Share the App", "Image" : "ic_share golden"],
                     ["Name" : "Rate Us", "Image" : "ic_rate us golden"]]]
        self.CustomiseView()
        
        // Do any additional setup after loading the view.
    }
    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: "More")
    }
    // MARK: - Table View Delegate and Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return 3
        }
        else if(section == 1)
        {
            return 1
        }
        else
        {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height * (45.0 / 568.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width - 20, height: 45.0))
        headerView.backgroundColor = UIColor.clear
        
        let titleView = ResizableFontLabel()
        titleView.autoFont = true
        titleView.fontSize = 17.0
        titleView.frame = CGRect(x: 10, y: 0, width: self.view.frame.size.width-10, height: 44)
        titleView.textColor = UIColor.black
        titleView.font = UIFont(name: "sans-serif-Bold", size: 14.0)
        titleView.textAlignment = NSTextAlignment.left
        
        if(section == 0)
        {
            titleView.text = "Info"
            
        }
        else if (section == 1)
        {
            titleView.text = "Support"
        }
        else if(section == 2)
        {
            titleView.text = "Feedback"
            
        }
        headerView.addSubview(titleView)
        
        
        let lineLbl = UILabel()
        lineLbl.frame = CGRect(x: 0, y: 44, width: self.view.frame.size.width, height: 1)
        lineLbl.backgroundColor = UIColor(hexCode: 0xE6E6E6)
        headerView.addSubview(lineLbl)
        
        return headerView
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
        
        cell?.menuTitle.text = ((arr_More[indexPath.section] as! NSArray)[indexPath.row] as? NSDictionary)?.value(forKey: "Name") as? String
        cell?.menuImage.image = UIImage(named:(((arr_More[indexPath.section] as! NSArray)[indexPath.row] as? NSDictionary)?.value(forKey: "Image") as? String)!
        )
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.white
        cell!.selectedBackgroundView = bgColorView
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)//how to use this app
            {
                self.performSegue(withIdentifier: "howToUseAppSeg", sender: self)
            }
            if(indexPath.row == 1)//about
            {
                self.performSegue(withIdentifier: "aboutSeg", sender: self)
            }
            if(indexPath.row == 2)//termsAnd conditions
            {
                self.performSegue(withIdentifier: "termsPolicySeg", sender: self)
            }
            
            
        }
        else if(indexPath.section == 1)
        {
            
            if(indexPath.row == 0)//contact us
            {
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail()
                {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                }
                else
                {
//                    self.showSendMailErrorAlert()
                }
            }
        }
        else
        {
            if(indexPath.row == 0)//share this app
            {
                let textToShare = "Toast - Send a Cheer, Raise a Toast, Cherish forever."
                if let myWebsite = NSURL(string: "https://itunes.apple.com/us/app/raise-a-toast/id1242873327?ls=1&mt=8") //  app link
                {
                    let objectsToShare = [textToShare, myWebsite] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
            if(indexPath.row == 1)//rate us
            {
               
                let appIdd = "1242873327"
                rateApp(appId: appIdd) { success in
                    print("RateApp \(success)")
                }
            }
        }
    }
    
    // MARK: MFMailComposeViewController Method
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["support@toastafriend.com"])
        mailComposerVC.setSubject("Feedback for Raise a Toast")
        mailComposerVC.setMessageBody("", isHTML: false)
        mailComposerVC.navigationBar.tintColor = UIColor(hexCode:0xCEAF5C)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        SVProgressHUD.showInfo(withStatus: "Your device could not send e-mail. Please check e-mail configuration and try again.", maskType: .gradient)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var hidesBottomBarWhenPushed: Bool
        {
        get { return false }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "termsPolicySeg")
        {
            if let termsAndPrivacyVC: TTermsPolicyVC = segue.destination as? TTermsPolicyVC {
                
                termsAndPrivacyVC.screenTag = 1
                
            }
        }
    }
    
    
}

//
//  THowToUseAppVC.swift
//  Toast
//
//  Created by Anish Pandey on 19/04/17.
//  Copyright © 2017 Anish Pandey. All rights reserved.
//

import UIKit

class THowToUseAppVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblVw_HowToUseApp: UITableView!
    var arr_data:NSMutableArray = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arr_data = NSMutableArray(array:[[], // step 1
                                         ["Description":"You are an \"Initiator\" if you wish to raise a Toast to celebrate somebody's special occasion. That somebody is a \"Toastee\". Create a Toast with combination of theme and an image.. Be creative! Your toast may be addressed to an individual or a group."],
                                         [], // step 2
                                         ["Description":"Get others on board: We call all others you want to be added to your Toast, \"Collaborators\". Toast app sends invites through email and inApp. You may also (if you wish to), transfer the ownership of the created Toast to one of the collaborators at any point in time you like."],
                                         [], //step 3
                                         ["Description":"Once all your collaborators have added to your Toast... \n\n RAISE the TOAST!\n"],
                                         [], // bigger last cell
                                         ["Description":"Toastee, Initiator and Collaborators cherish the Memories Forever!"]])
        
        /*
         
         arr_data = NSMutableArray(array:[[],
         ["Description":"Initiator creates a toast with a theme,image and Collaborators, intended to a person or a group called Toastees."],
         ["Description":"Initiator Cheers. A Cheer contains text and an image."],
         ["Description":"Initiator can remind Collaborators to Cheer via the Send Reminder feature."],
         ["Description":"Once everyone has Cheered, Initiator raises the toast to the Toastee."],
         [],
         ["Description":"Collaborator get notified via email and in app to Cheer when an Initiator adds him to the toast."],
         ["Description":"Collaborator also Cheers."],
         ["Description":"Initiator can transfer ownership to Collaborator, if he no longer wants to be an owner of the toast. Collaborator becomes the Initiator."],
         [],
         ["Description":"Toastee can also initiate the toast and raise it."],
         ["Description":"Toastee gets notified via email and in app when a toast is raised."],
         [],
         ["Description":"Toastee, Initiator and Collaborators cherish Toast memory forever."]])

         
 */
        
        tblVw_HowToUseApp.estimatedRowHeight = 45.0
        tblVw_HowToUseApp.rowHeight = UITableViewAutomaticDimension
        self.CustomiseView()
    }
    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: "How to use the App")

        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(THowToUseAppVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
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
    
    
    // MARK: - Table View Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arr_data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4)
        {
            let cellIdentifier:String = "HowToUseAppCellHeader"
            var cell:HowToUseAppCellHeader? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HowToUseAppCellHeader
            if (cell == nil){
                tableView.register(UINib(nibName: "HowToUseAppCellHeader", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HowToUseAppCellHeader
                cell?.layoutMargins=UIEdgeInsets.zero
                cell?.preservesSuperviewLayoutMargins=false
                cell?.backgroundColor=UIColor.clear
            }
            cell?.selectionStyle = .none
           // cell?.btn_Header.titleLabel?.font = ui
            if(indexPath.row == 0)
            {
                //cell?.btn_Header.setImage(UIImage(named:"ic_initiator orange"), for: .normal)
                cell?.btn_Header.setTitle(" Step 1", for: .normal)
            }
            else if(indexPath.row == 2)
            {
                //cell?.btn_Header.setImage(UIImage(named:"ic_member"), for: .normal)
                cell?.btn_Header.setTitle(" Step 2", for: .normal)
            }
            else if(indexPath.row == 4)
            {
                //cell?.btn_Header.setImage(UIImage(named:"ic_toastee pink"), for: .normal)
                cell?.btn_Header.setTitle(" Step 3", for: .normal)
            }
            
            return cell!
        }
        else if (indexPath.row != 6)
        {
            let cellIdentifier:String = "HowToUseAppDescCell"
            var cell:HowToUseAppDescCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HowToUseAppDescCell
            if (cell == nil){
                tableView.register(UINib(nibName: "HowToUseAppDescCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HowToUseAppDescCell
                cell?.layoutMargins=UIEdgeInsets.zero
                cell?.preservesSuperviewLayoutMargins=false
                cell?.backgroundColor=UIColor.clear
            }
            cell?.selectionStyle = .none
            
            let dicData: NSDictionary = self.arr_data.object(at: indexPath.row) as! NSDictionary
            
            cell?.lbl_Desc.text = dicData.value(forKey: "Description") as? String
            cell?.lbl_Desc.lineBreakMode = .byWordWrapping
            cell?.lbl_Desc.numberOfLines = 0
            
            return cell!
        }
        else
        {
            let cellIdentifier:String = "HowToUseCellOne"
            var cell:HowToUseCellOne? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HowToUseCellOne
            if (cell == nil){
                tableView.register(UINib(nibName: "HowToUseCellOne", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HowToUseCellOne
                cell?.layoutMargins=UIEdgeInsets.zero
                cell?.preservesSuperviewLayoutMargins=false
                cell?.backgroundColor=UIColor.clear
            }
            cell?.selectionStyle = .none
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if(indexPath.row == 0 || indexPath.row == 5 || indexPath.row == 9 || indexPath.row == 11)
//        {
//            return 45.0
//        }
//        else
//        {
            return UITableViewAutomaticDimension
      //  }
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

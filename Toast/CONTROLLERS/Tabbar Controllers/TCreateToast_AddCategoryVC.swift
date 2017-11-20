//
//  TCreateToast_AddCategoryVC.swift
//  Toast
//
//  Created by Anish Pandey on 17/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class TCreateToast_AddCategoryVC: UIViewController, ZFTokenFieldDelegate, ZFTokenFieldDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var btn_Next: ZFRippleButton!
    @IBOutlet weak var view_Token: ZFTokenField!
    var tokens:NSMutableArray = NSMutableArray()
    var preSelectedCategoryBtn:UIButton!
    var isEditMode:Bool = false//true if editing toast, false if creating toast
    var overlayIndex:Int = 0 // Show if "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createToast_modal = CreateToastModal()
        
        self.view_Token.dataSource = self
        self.view_Token.delegate = self
        self.view_Token.textField.placeholder = "Enter other Category"
        self.view_Token.textField.keyboardType = .asciiCapable
        self.view_Token.reloadData()
        
        self.view_Token.textField.isHidden = true
        
        
        //uncomment below
        self.GetAllCategories()
        
        self.CustomiseView()
        NotificationCenter.default.addObserver(self, selector: #selector(TCreateToast_AddCategoryVC.downTheView), name: NSNotification.Name(rawValue: "viewDown"), object: nil)
        
    }
    
    func startOverLay()
    {
        if let selectedView = self.view_Token.view(for: 7)
        {
            let overlayIndex_categoty = UserDefaults.standard.string(forKey: KEY_OverlayIndex_AddCategoryVC) as NSString?
            
            if let newOverlayIndex_categoty = overlayIndex_categoty
            {
                if(newOverlayIndex_categoty == "Show")
                {
                    if(overlayIndex == 0)
                    {
                        //                        self.view.window?.addOverlayByHighlightingSubView(selectedView, withText: "Select a category of your toast and proceed to the next step.")
                        //                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(4.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                        //                            self.view.window?.removeOverlay()
                        //                            UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddCategoryVC)
                        //                        }
                        
                        
                        self.view.window?.addOverlayByHighlightingSubView(selectedView, withText: "Select a category of your toast and proceed to the next step.")
                        UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddCategoryVC)
                        
                        
                        overlayIndex = 1
                    }
                }
            }
            else
            {
                if(overlayIndex == 0)
                {
                    //                    self.view.window?.addOverlayByHighlightingSubView(selectedView, withText: "Select a category of your toast and proceed to the next step.")
                    //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    //                        self.view.window?.removeOverlay()
                    //                        UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddCategoryVC)
                    //                }
                    
                    self.view.window?.addOverlayByHighlightingSubView(selectedView, withText: "Select a category of your toast and proceed to add Toastees.")
                    UserDefaults.standard.setValue("DoNotShow", forKey: KEY_OverlayIndex_AddCategoryVC)
                }
                overlayIndex = 1
                
            }
        }
    }
    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Category")
        
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TCreateToast_AddCategoryVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        scroller.contentSize = CGSize(width: self.view.frame.size.width, height: 535)
        
        if(isEditMode == true)
        {
            btn_Next.setTitle("Select", for: .normal)
        }
        
    }
    
    
    // MARK: - WS Calls
    func GetAllCategories()
    {
        /*"{
         ""service"": ""toastcategories"",
         ""user_id"": ""3"",
         ""access_token"": ""S5P_Q0MaFZtWbwDk5AB_bGZBOSRTa4Au""
         }"*/
        
        let dataObj = NetworkData()
        NSLog("dataObj.networkSTR = %@", dataObj.networkSTR)
        if (dataObj.networkSTR as String == "WiFi" as String || dataObj.networkSTR as String == "Cellular" as String)
        {
            SVProgressHUD.show(with: .gradient)
            let parameters: NSDictionary = ["service": "toastcategories", "user_id": UserDefaults.standard.value(forKey: KEY_USER_ID)!, "access_token" : UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN)!]
            
            WebService.sendPostRequest(postDict: parameters, serviceCount: 0) { (response, error) in
                print(response)
                let statusToken:NSString =  NSString(format: "%@",response["status"]! as! NSString)
                if(statusToken as String == "Success" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        
                        self.tokens.addObjects(from: (response["toast_categories"]! as! NSArray) as! [Any])
                        
                        if self.tokens.count == 0
                        {
                            SVProgressHUD.showInfo(withStatus: "No result found !\nTry again.", maskType: .gradient)
                        }
                        else
                        {
                            if(self.tokens.contains("Other"))
                            {
                                self.tokens.remove("Other")
                            }
                            self.tokens.add("Other")
                            
                            self.view_Token.reloadData()
                            
                            
                            _ = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(TCreateToast_AddCategoryVC.startOverLay), userInfo: nil, repeats: false)
                        }
                        
                    })
                    
                }
                else if(statusToken as String == "Error" as String)
                {
                    DispatchQueue.main.async(execute: {
                        SVProgressHUD.dismiss()
                        let error_message:String =  String(format: "%@",response["Error"]! as! String)
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
    
    // MARK: - Button Actions
    func backBtnClicked(_ sender: UIButton!)
    {
        
        //clear modal object when goint back to toast list screen.
        createToast_modal = nil
        
        //previously done when category screen was on second number
        /*   if isEditMode == false
         {
         if(self.view_Token.textField.isHidden == true)
         {
         if(preSelectedCategoryBtn != nil)
         {
         if((preSelectedCategoryBtn.titleLabel?.text)! != " Other" &&  (preSelectedCategoryBtn.titleLabel?.text)!.characters.count > 0)
         {
         createToast_modal.category_name_s2 = (preSelectedCategoryBtn.titleLabel?.text)!.Trim()
         createToast_modal.isCategoryByTxtFld = false
         
         }
         }
         }
         else
         {
         //            if(!(self.view_Token.textField.text?.isEmpty)!)
         //            {
         createToast_modal.other_category_name_s2 = (self.view_Token.textField.text?.isEmpty)! ? "" : self.view_Token.textField.text!
         createToast_modal.isCategoryByTxtFld = true
         
         //            }
         }
         }
         */
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    @IBAction func btn_NextClicked(_ sender: ZFRippleButton) {
        if(self.view_Token.textField.isHidden == true)
        {
            if(preSelectedCategoryBtn != nil)
            {
                if((preSelectedCategoryBtn.titleLabel?.text)! != " Other" &&  (preSelectedCategoryBtn.titleLabel?.text)!.characters.count > 0)
                { // IF any category selected
                    if(isEditMode == true)
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kCategoryAdded_Notification), object: ["category" : preSelectedCategoryBtn.titleLabel?.text , "value" : "Category"])
                        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
                    }
                    else
                    {
                        createToast_modal.category_name_s2 = (preSelectedCategoryBtn.titleLabel?.text)!.Trim()
                        createToast_modal.isCategoryByTxtFld = false
                        self.performSegue(withIdentifier: "addOtherDetailsSeg", sender: self)
                    }
                }
                else
                {// IF only other selected with no text input
                    SVProgressHUD.showInfo(withStatus: kSelectCategory, maskType: .gradient)
                }
            }
            else
            {
                SVProgressHUD.showInfo(withStatus: kSelectCategory, maskType: .gradient)
            }
        }
        else
        {
            if(!(self.view_Token.textField.text?.isEmpty)!)
            {
                if(isEditMode == true)
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kCategoryAdded_Notification), object: ["category" : self.view_Token.textField.text!, "value" : "Other_Category"])
                    ((self.navigationController)! as UINavigationController).popViewController(animated: true)
                }
                else
                {
                    createToast_modal.other_category_name_s2 = self.view_Token.textField.text!
                    createToast_modal.isCategoryByTxtFld = true
                    
                    self.view_Token.textField.resignFirstResponder()
                    self.performSegue(withIdentifier: "addOtherDetailsSeg", sender: self)
                }
            }
            else
            {
                SVProgressHUD.showInfo(withStatus: "Please select a category", maskType: .gradient)
            }
        }
    }
    
    @IBAction func btn_CaregorySelected(_ sender: UIButton) {
        if(sender.titleLabel?.text == " Other")
        {
            self.view_Token.textField.isHidden = false
            self.view_Token.textField.becomeFirstResponder()
        }
        else
        {
            self.view_Token.textField.isHidden = true
            self.view_Token.textField.resignFirstResponder()
            if(self.view.frame.origin.y != 64)
            {
                self.viewDown()
            }
        }
        if let preSelectedCategoryBtnTemp = preSelectedCategoryBtn
        {
            preSelectedCategoryBtnTemp.isSelected = false
            preSelectedCategoryBtnTemp.backgroundColor = UIColor.white
        }
        sender.isSelected = true
        sender.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        preSelectedCategoryBtn = sender
    }
    
    // MARK: - Notification methods
    func downTheView(notification: NSNotification) {
        //        if(self.view.frame.origin.y != 64)
        //        {
        //            self.viewDown()
        //            if let preSelectedCategoryBtnTemp = preSelectedCategoryBtn
        //            {
        //                preSelectedCategoryBtnTemp.isSelected = false
        //                preSelectedCategoryBtnTemp.backgroundColor = UIColor.white
        //            }
        //            preSelectedCategoryBtn = nil
        //        }
        self.btn_NextClicked(btn_Next)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    // MARK: - ZFTokenField DataSource
    
    func lineHeightForToken(in tokenField: ZFTokenField!) -> CGFloat {
        return 33
    }
    
    func numberOfToken(in tokenField: ZFTokenField!) -> UInt {
        return UInt(self.tokens.count)
    }
    
    func tokenField(_ tokenField: ZFTokenField!, viewForTokenAt index: UInt) -> UIView! {
        let nibContents:[UIView] = Bundle.main.loadNibNamed("TokenView", owner: nil, options: nil) as! [UIView]
        let view:UIView = nibContents[0]
        let btn_Tag:UIButton = view.viewWithTag(100) as! UIButton
        btn_Tag.addTarget(self, action: #selector(TCreateToast_AddCategoryVC.btn_CaregorySelected(_:)), for: UIControlEvents.touchUpInside)
        btn_Tag.setTitle(NSString(format: " %@", (tokens.object(at: Int(index)) as? String)!) as String, for: .normal)
        btn_Tag.layer.cornerRadius = 2.0
        btn_Tag.layer.borderColor = UIColor(hexCode: 0xD0D0D0).cgColor
        btn_Tag.layer.borderWidth = 1.0
        btn_Tag.clipsToBounds = true
        btn_Tag.isSelected = true
        let size = btn_Tag.titleLabel?.sizeThatFits(CGSize(width: CGFloat(1000), height: CGFloat(40)))
        
        
        //let count:UInt = UInt(self.tokens.count-1)
        //        if(index == count) // select last user entered category button
        //        {
        //            btn_Tag.isSelected = true
        //            btn_Tag.backgroundColor = UIColor(hexCode: 0xCEAF5C)
        //            //            for buttonCategory in btn_Categories // deselect other button if user added category
        //            //            {
        //            //                if(buttonCategory.tag == 9)
        //            //                {
        //            //                    buttonCategory.isSelected = false
        //            //                    buttonCategory.backgroundColor = UIColor.white
        //            //                }
        //            //            }
        //        }
        
        if isEditMode == true
        {
            
            if(viewToastObj.otherCategoryName.characters.count > 0)
            {
                if((tokens.object(at: Int(index)) as? String)! == "Other")//check "other" button and show textfield with privious category
                {
                    btn_Tag.isSelected = true
                    btn_Tag.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                    self.view_Token.textField.isHidden = false
                    self.view_Token.textField.text = viewToastObj.otherCategoryName
                    preSelectedCategoryBtn = btn_Tag
                    
                }
                else // deselect other user added category buttons
                {
                    btn_Tag.isSelected = false
                    btn_Tag.backgroundColor = UIColor.white
                }
            }
            else{
                
                if(viewToastObj.categoryName == (tokens.object(at: Int(index)) as? String)!)
                {
                    btn_Tag.isSelected = true
                    btn_Tag.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                    preSelectedCategoryBtn = btn_Tag
                }
                else // deselect other user added category buttons
                {
                    btn_Tag.isSelected = false
                    btn_Tag.backgroundColor = UIColor.white
                }
            }
        }
        else{
            
            if(createToast_modal.isCategoryByTxtFld == true)//if last selected category is by text field
            {
                if((tokens.object(at: Int(index)) as? String)! == "Other")//check "other" button and show textfield with privious category
                {
                    btn_Tag.isSelected = true
                    btn_Tag.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                    self.view_Token.textField.isHidden = false
                    self.view_Token.textField.text = createToast_modal.other_category_name_s2
                    preSelectedCategoryBtn = btn_Tag
                }
                else // deselect other user added category buttons
                {
                    btn_Tag.isSelected = false
                    btn_Tag.backgroundColor = UIColor.white
                }
            }
            else//else chck the predfined categories and checkmark it
            {
                if(createToast_modal.category_name_s2 == (tokens.object(at: Int(index)) as? String)!)
                {
                    btn_Tag.isSelected = true
                    btn_Tag.backgroundColor = UIColor(hexCode: 0xCEAF5C)
                    preSelectedCategoryBtn = btn_Tag
                    
                }
                else // deselect other user added category buttons
                {
                    btn_Tag.isSelected = false
                    btn_Tag.backgroundColor = UIColor.white
                }
            }
        }
        btn_Tag.tag = Int(index)+10
        
        view.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat((size?.width)! + 47), height: CGFloat(33))
        
        return view as UIView?
    }
    
    func viewUp()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: .curveEaseOut, animations: {
                        self.view.frame = CGRect(x: self.view.frame.origin.x,  y: self.view.frame.origin.y-220,  width: self.view.frame.size.width,  height: self.view.frame.size.height)
                        
        }, completion: nil)
    }
    
    func viewDown()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: .curveEaseOut, animations: {
                        self.view.frame = CGRect( x: self.view.frame.origin.x,  y: 64,  width: self.view.frame.size.width,  height: self.view.frame.size.height)
                        
        }, completion: nil)
        
        
    }
    
    // MARK: - ZFTokenField Delegate
    func tokenMarginInToken(in tokenField: ZFTokenField) -> CGFloat {
        return 7
    }
    
    func tokenField(_ tokenField: ZFTokenField, didReturnWithText text: String) {
        //        self.tokens.add(text)
        //        tokenField.reloadData()
        tokenField.resignFirstResponder()
    }
    
    private func tokenField(_ tokenField: ZFTokenField, didRemoveTokenAt index: Int) {
        //self.tokens.remove(at: index)
    }
    
    func tokenFieldDidBeginEditing(_ tokenField: ZFTokenField!) {
        self.viewUp()
    }
    
    func tokenFieldShouldEndEditing(_ textField: ZFTokenField) -> Bool {
        return true
    }
    
    func tokenField(_ tokenField: ZFTokenField!, didTextChanged text: String!) {
        print(text)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

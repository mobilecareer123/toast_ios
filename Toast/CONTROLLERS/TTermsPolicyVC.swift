//
//  TTermsPolicyVC.swift
//  Toast
//
//  Created by Anish Pandey on 12/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit

class TTermsPolicyVC: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView_Terms: UIWebView!
    var screenTag:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CustomiseView()
        if(screenTag == 1)
        {
            webView_Terms.loadRequest(URLRequest(url: URL(string: kTermsAndCondition)!))
        }
        else if(screenTag == 2){
            webView_Terms.loadRequest(URLRequest(url: URL(string: kPrivacyPolicy)!))
        }

        
        webView_Terms.isOpaque = false
        webView_Terms.backgroundColor = UIColor.clear
        if #available(iOS 9.0, *) {
            webView_Terms.allowsLinkPreview = true
        } else {
            // Fallback on earlier versions
        }

    }
    
    func CustomiseView()
    {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TTermsPolicyVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        
        if(screenTag == 1)
        {
            self.navigationItem.titleView = getNavigationTitle(inputStr: "Terms and Conditions")
        }
        else if(screenTag == 2){
            self.navigationItem.titleView = getNavigationTitle(inputStr: "Privacy Policy")
        }
        
    }
    
    // MARK: - Button Action
    func backBtnClicked(_ sender: UIButton) {
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        SVProgressHUD.show(with: .gradient)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        SVProgressHUD.dismiss()
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

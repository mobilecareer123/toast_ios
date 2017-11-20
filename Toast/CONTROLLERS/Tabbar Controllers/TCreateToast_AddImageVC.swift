//
//  TCreateToast_AddImageVC.swift
//  Toast
//
//  Created by Anish Pandey on 17/11/16.
//  Copyright © 2016 Anish Pandey. All rights reserved.
//

import UIKit
import MobileCoreServices

class TCreateToast_AddImageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgView_ToastImage: UIImageView!
    @IBOutlet weak var btn_addToastImage: UIButton!
    @IBOutlet weak var btn_Next: ZFRippleButton!
    
    @IBOutlet weak var btn_PopupCamera: ZFRippleButton!
    @IBOutlet weak var btn_PopupLibrary: ZFRippleButton!
    @IBOutlet weak var btn_CancelPicker: ZFRippleButton!
    @IBOutlet weak var view_CameraPopup: UIView!
    @IBOutlet weak var view_CameraInner: UIView!
    @IBOutlet weak var constraint_PopupViewBottom: NSLayoutConstraint!
    
    var cameraUI: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CustomiseView()
        
        if createToast_modal.toastImage_added != nil {
            
            imgView_ToastImage.image = createToast_modal.toastImage_added
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func CustomiseView()
    {
        self.navigationItem.titleView = getNavigationTitle(inputStr: "Add Toast Image")
        
        let buttonback: UIButton = UIButton(type: UIButtonType.custom)
        buttonback.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        buttonback.setTitleColor(UIColor.white, for: .normal)
        buttonback.setImage(UIImage(named:"Arrow"), for: UIControlState.normal)
        buttonback.addTarget(self, action: #selector(TCreateToast_AddImageVC.backBtnClicked(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItemBack: UIBarButtonItem = UIBarButtonItem(customView: buttonback)
        let navigationItemLeft: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        navigationItemLeft.width = -12
        let Array:NSArray = [navigationItemLeft, leftBarButtonItemBack]
        self.navigationItem.setLeftBarButtonItems(Array as? [UIBarButtonItem], animated: true)
        
        view_CameraInner.layer.cornerRadius = 5.0
        view_CameraInner.clipsToBounds = true
        
        //        UIView.animate(withDuration: 0.3, delay: 0.0, animations: {
        //            self.constraint_PopupViewBottom.constant = 0.0
        //            self.view.layoutIfNeeded()
        //            }, completion: nil)
        
    }
    
    // MARK: - Button Actions
    
    @IBAction func btn_addToastImageClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.constraint_PopupViewBottom.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func backBtnClicked(_ sender: UIButton!)
    {
        //uncomment below
        if imgView_ToastImage.image != nil
        {
            createToast_modal.toastImage_added = imgView_ToastImage.image!
        }
        
        ((self.navigationController)! as UINavigationController).popViewController(animated: true)
    }
    
    @IBAction func btn_NextClicked(_ sender: ZFRippleButton) {
        
        if imgView_ToastImage.image != nil {
            
            createToast_modal.toastImage_added = imgView_ToastImage.image!
        }
        
        
        self.performSegue(withIdentifier: "addMemberSeg", sender: self)
    }
    
    @IBAction func btn_PopupCameraClicked(_ sender: ZFRippleButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            self.cameraUI = UIImagePickerController()
            self.cameraUI.delegate = self
            self.cameraUI.sourceType = UIImagePickerControllerSourceType.camera
            self.cameraUI.allowsEditing = true
            self.cameraUI.modalPresentationStyle = .fullScreen
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            self.cameraUI.mediaTypes = mediaTypes as! [String]
            self.present(self.cameraUI, animated: true, completion: nil)
            // self.toggleFlash()
        }
        else
        {
            // error msg
        }
        self.hidePicker()
        
        
    }
    @IBAction func btn_PopupLibraryClicked(_ sender: ZFRippleButton) {
        self.hidePicker()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        {
            cameraUI = UIImagePickerController()
            cameraUI.delegate = self
            cameraUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraUI.mediaTypes = mediaTypes as! [String]
            cameraUI.allowsEditing = true
            
            self.present(cameraUI, animated: true, completion: nil)
        }
        else
        {
            // error msg
        }
        
    }
    @IBAction func btn_CancelPickerClicked(_ sender: ZFRippleButton) {
        self.hidePicker()
    }
    
    func hidePicker()
    {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.constraint_PopupViewBottom.constant = -155.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    //MARK:UIImagePickerController Delegate
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let selectedImage1: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        imgView_ToastImage.image = selectedImage1 // .af_imageAspectScaled(toFill: imgView_ToastImage.frame.size)
        //uncomment below
        createToast_modal.toastImage_added = imgView_ToastImage.image!
        
        self.dismiss(animated: true, completion: nil)
        
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
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addMemberSeg")
        {
            if let addMemberVC: TCreateToast_AddMemberVC = segue.destination as? TCreateToast_AddMemberVC {
                
                addMemberVC.screenTag = 1 // from createToast>> add Members
            }
        }
        //        if(segue.identifier == "selectCategorySeg")
        //        {
        //            if let addCategotyVC: TCreateToast_AddCategoryVC = segue.destination as? TCreateToast_AddCategoryVC {
        //
        //                addCategotyVC.isEditMode = true
        //            }
        //        }
    }
    
}

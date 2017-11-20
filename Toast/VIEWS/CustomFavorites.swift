//
//  CustomFavorites.swift
//  MYOS
//
//  Created by Pankaj on 27/12/16.
//  Copyright © 2016 Pankaj Arkenea. All rights reserved.
//

import UIKit

class CustomFavorites: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnCancel: Button_Addition!
    @IBOutlet weak var BtnContinue: Button_Addition!
    @IBOutlet weak var tblFav: UITableView!
     @IBOutlet weak var msgLbl: UILabel!
    
    @IBOutlet weak var TblView_Hconst: NSLayoutConstraint!
    
    var arr_MemberList:NSMutableArray = NSMutableArray()
    
     var indexpath:Int = 0

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.tblFav.tableFooterView = UIView()
    }
 
    // MARK:UITableView Delegate and Datasource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_MemberList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "CustomFavoritesTableViewCell"
        let cell:CustomFavoritesTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CustomFavoritesTableViewCell
        cell?.layoutMargins = UIEdgeInsets.zero
        cell?.backgroundColor = UIColor.clear
        cell?.preservesSuperviewLayoutMargins=false
        cell?.txtlbl.text = arr_MemberList.object(at: indexPath.row) as? String
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if(indexPath.row == 0){
            
        }
    }

}

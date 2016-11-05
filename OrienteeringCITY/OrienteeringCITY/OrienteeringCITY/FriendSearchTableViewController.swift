//
//  FriendSearchTableViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/10/25.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class FriendSearchTableViewController: UITableViewController{
 
    let firebaseRef = FIRDatabase.database().reference()
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredusersName: [String] = [String](){
        didSet{
        tableView.reloadData()
        }
    }
    
//    var filteredusersID : [String] = [String](){
//        didSet{
//         tableView.reloadData()
//        }
//    }
    
//    var filteredusersPicUrl: [String] = [String](){
//        didSet{
//         tableView.reloadData()
//        }
//    }
    
    var filteredUsersPicUrl = [String]()
    var testDictionary : [[String]] = [[],[]]
    
    var usersName = [String]()
//    var usersID = [String]()
    var usersPicUrl = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        FIRAnalytics.logEventWithName("ToFriendListPage", parameters: nil)
        
        FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
            kFIRParameterContentType:"PageSelection",
            kFIRParameterItemID:"ToFriendListPage"
            ])
        
        //這行可以把每個cell的分隔線藏起來
        tableView.separatorStyle = .None
             
            firebaseRef.child("users").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
                
                if let users = snapshot.value as? [String:AnyObject]{
                    
                    for usersValue in users {
                        
                        self.firebaseRef.child("usersNameWithID").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
                            
                            if let usersNameWithID = snapshot.value as? [String:String]{
                                
                                for usersNameWithIDValue in usersNameWithID {
                                    
                                    if usersNameWithIDValue.1 == usersValue.0 {
                                        
                                        guard let url = (usersValue.1)["user_photoPathInStorage"] as? String else {
                                            //待修
//                                            fatalError()
                                            return
                                        }
                                        
                                        print(usersNameWithIDValue.0)
                                        print(url)
                                        
                                        self.usersName.append(usersNameWithIDValue.0)
                                        self.usersPicUrl.append(url)
                                        
                                        self.testDictionary[0].append(usersNameWithIDValue.0)
                                        self.testDictionary[1].append(url)
                                        
                                    }
                                }
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.active {
            
            return filteredusersName.count

        } else {
            //也可以用 return 0 來讓tableView在沒有搜尋的時候不顯示cell
            //不過目前看起來會load不到圖片
//        return 0
//        return usersName.count
            return testDictionary[0].count
        }
        
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FriendSearchTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FriendSearchTableViewCell

        if searchController.active {
            
            //這行目前會讓array被清空造成crash
//            filteredUsersPicUrl = []

            for userNameValue in filteredusersName {                                                           //輸入filteredName
                firebaseRef.child("usersNameWithID").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in //由這個name去firebase上面撈uid
                    if let usersNameWithID = snapshot.value as? [String:String]{                               //
                        for usersNameWithIDValue in usersNameWithID {                                          //將此snapshot轉tuple
                            if usersNameWithIDValue.0 == userNameValue {                                       //判斷名字是否相同之後抓uid
                                let filteredUserUid = usersNameWithIDValue.1                                   //get此次filter出來使用者的uid
                                self.firebaseRef.child("users").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in //進入firebase users分支
                                    if let users = snapshot.value as? [String:AnyObject]{
                                        for usersValue in users {                                              //每次看一個分支
                                            if filteredUserUid == usersValue.0 {                               //check
                                                
                                                guard let url = (usersValue.1)["user_photoPathInStorage"] as? String else {
                                                fatalError()
                                                }
                                                
                                                
                                                self.filteredUsersPicUrl.append(url)
                                                
                                                FIRStorage.storage().referenceForURL(self.filteredUsersPicUrl[indexPath.row]).dataWithMaxSize(10 * 1024 * 1024, completion: { (data, error) -> Void in
                                                    if error != nil {return}
                                                    else{
                                                        dispatch_async(dispatch_get_main_queue()) {
                                                            cell.profileImage.image = UIImage(data: data!)
                                                            cell.profileImage.layer.masksToBounds = true
                                                            cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2
                                                            cell.profileImage.clipsToBounds = true
                                                        }
                                                    }})
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }


            
            cell.name.text = filteredusersName[indexPath.row]
            return cell
            
        } else {
        
            filteredUsersPicUrl = []
            //利用截取到的photoURL去Firebase上面load圖片
            //並且在Tableview cell上面顯示出來
//            FIRStorage.storage().referenceForURL(usersPicUrl[indexPath.row]).dataWithMaxSize(10 * 1024 * 1024, completion: { (data, error) -> Void in
//                if error != nil {return}
//                else{
//                    dispatch_async(dispatch_get_main_queue()) {
//                        cell.profileImage.image = UIImage(data: data!)
//                        cell.profileImage.layer.masksToBounds = true
//                        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2
//                        cell.profileImage.clipsToBounds = true
//                    }
//                }})
//            
//            
//        cell.name.text = usersName[indexPath.row]
//           
//        return cell
            
            
            FIRStorage.storage().referenceForURL(testDictionary[1][indexPath.row]).dataWithMaxSize(10 * 1024 * 1024, completion: { (data, error) -> Void in
                if error != nil {return}
                else{
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.profileImage.image = UIImage(data: data!)
                        cell.profileImage.layer.masksToBounds = true
                        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2
                        cell.profileImage.clipsToBounds = true
                    }
                }})
            
            cell.name.text = testDictionary[0][indexPath.row]

            return cell
            
        }
    }
    
}


extension FriendSearchTableViewController : UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        FIRAnalytics.logEventWithName("UseFriendSearchBar", parameters: nil)
        
        guard let searchText = searchController.searchBar.text else {
            
            return
            
        }
        
//        filteredusersName = usersName.filter({ (userName) -> Bool in
//            return userName.lowercaseString.containsString(searchText.lowercaseString)
//        })

        filteredusersName = testDictionary[0].filter({ (userName) -> Bool in
            
            return userName.lowercaseString.containsString(searchText.lowercaseString)
        })
        
  
    }
    
}




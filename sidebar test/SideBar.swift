//
//  SideBar.swift
//  sidebar test
//
//  Created by alden lamp on 8/25/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

var currentImage : UIImage?

struct NavigationNotifications {
    static let toggleMenu = "toggleMenuNotifictaion"
    static let first = "firstSelected"
    //    static let second = "secondSelected"
    //    static let third = "thirdSelected"
}

class SideBar: UIViewController{//, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        //let button = UIButton()
        //button.setTitle("test", for: .normal)
        //button.frame=CGRect(x: 0, y: 0, width: 50, height: 50)
        //button.addTarget(self, action: #selector(tes), for: .touchUpInside)
        //self.view.addSubview(button)
        //
        
        
        
        //        self.view.addSubview(tableView)
        //        tableView.frame =  CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        //        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        //        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        //        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        //        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        //
        
        
        //        tableView.translatesAutoresizingMaskIntoConstraints = false
        //
        //        tableView.delegate = self
        //        tableView.dataSource = self
        
        //Current User still == nil
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "setUpUserAttributesSideBar"), object: nil, queue: nil) { (notification) in
            if FIRAuth.auth()?.currentUser != nil{
                do{
                    try currentImage = UIImage(data: Data(contentsOf: (FIRAuth.auth()?.currentUser?.photoURL)!))!
                    self.setUpImage(image: currentImage!)
                }catch{
                    self.setUpImage(image: #imageLiteral(resourceName: "rejected-red"))
                }
            }else{
                
            }
        }
    }
    
    func setUpImage(image: UIImage){
        let imageView = UIImageView()
        imageView.image = image
        imageView.heightAnchor.constraint(equalToConstant: 59).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 58).isActive = true
        
        imageView.layer.cornerRadius = 29
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.alpha = 0.7
        
        self.view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 83).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 23))
        label.text = FIRAuth.auth()?.currentUser?.email
        label.font = UIFont(name: "Avenir-Medium", size: 16)
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 25).isActive = true
        label.heightAnchor.constraint(equalToConstant: 23).isActive = true
        label.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: -25).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        
        let logout = UIButton(type: .system)
        logout.setTitle("Log Out", for: .normal)
        logout.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16)
        logout.titleLabel?.textColor = UIColor(hex: "55596B", alpha: 1)
        logout.tintColor = UIColor(hex: "55596B", alpha: 1)
        logout.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        logout.titleLabel?.textAlignment = .center
        
        self.view.addSubview(logout)
        logout.translatesAutoresizingMaskIntoConstraints = false
        
        logout.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        logout.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        logout.heightAnchor.constraint(equalToConstant: 22).isActive = true
        logout.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        
        
    }
    
    @objc func logOut(){
        
        
        
        
        do{
            try FIRAuth.auth()?.signOut()
            GIDSignIn.sharedInstance().signOut()
            
            for i in self.view.subviews{
                i.removeFromSuperview()
            }
            
            
            
            NotificationCenter.default.post(Notification(name: ReturnToLoginNotificationName))
        }catch{
            let alert = UIAlertController(title: "Error", message: "There was an error logging out", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dissmiss", comment: "Default action"), style: .default, handler: { _ in
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    //
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 3 }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = UITableViewCell()
    //        cell.textLabel?.text = "\(indexPath.row)"
    //        return cell
    //    }
    //
    //
    //
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    ////        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.toggleMenu), object: self))
    ////        postNotification((indexPath as NSIndexPath).row)
    //    }
    
    //
    //    func postNotification(_ index: Int){
    //        let notificationCenter = NotificationCenter.default
    //        switch index {
    //        case 0:
    //            notificationCenter.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.first), object: self))
    //        case 1:
    //            //            notificationCenter.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.second), object: self))
    //            break
    //        case 2:
    //            break
    //        //            notificationCenter.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.third), object: self))
    //        default:
    //            break
    //        }
    //    }
}


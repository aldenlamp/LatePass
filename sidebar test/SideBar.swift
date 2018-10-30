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

enum NavigationNotifications: String {
    case toggleMenu = "toggleMenuNotifictaion"
    case home = "Home"
    case allItemController = "All History Items"
    case statViewController = "Analysis"
}

class SideBar: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let tableView = UITableView()
    
    let imageView = UIImageView()
    let label = UILabel()
    
    let logout = UIButton(type: .system)
    
    var didLoadImage = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        setUpView()
        setUpTableView()
        updateViews()
        
        
        //Current User still == nil
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "setUpUserAttributesSideBar"), object: nil, queue: nil) { [weak self] (notification) in
            self?.updateViews()
        }
    }
    
    private func updateViews(){
        let email: String
        let image: UIImage
        if Auth.auth().currentUser != nil{
            do{
                email = (Auth.auth().currentUser?.email)!
                try image = UIImage(data: Data(contentsOf: (Auth.auth().currentUser?.photoURL)!))!
            }catch{
                image = #imageLiteral(resourceName: "icons8-user_filled")
            }
        }else{
            image = #imageLiteral(resourceName: "icons8-user_filled")
            email = "NO WIFI"
        }
        self.label.text = email
        self.imageView.image = image
    }
    
    private func setUpView(){
        didLoadImage = true
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
        
        label.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 23)
        label.text = Auth.auth().currentUser?.email ?? "NO WIFI"
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
        print(GoogleDataClass.isPullingData)
        if !GoogleDataClass.isPullingData{
            do{
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance().signOut()
                NotificationCenter.default.post(Notification(name: ReturnToLoginNotificationName))
            }catch{
                let alert = UIAlertController(title: "Error", message: "There was an error logging out", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dissmiss", comment: "Default action"), style: .default, handler: { _ in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: - Table View
    
    var selectionTableView = UITableView()
    
    var selectionArr = [(NavigationNotifications.home, #imageLiteral(resourceName: "approved-purple"))]
    
    private func getUpdatesForSelection(){
        NotificationCenter.default.addObserver(forName: userDataDidLoadNotif, object: nil, queue: nil) { [weak self] (notification) in
//            if firebaseData.currentUser.userType == .student{
                self?.selectionArr = [(NavigationNotifications.home, #imageLiteral(resourceName: "icons8-home_filled")), (NavigationNotifications.allItemController, #imageLiteral(resourceName: "icons8-list_filled")), (NavigationNotifications.statViewController, #imageLiteral(resourceName: "icons8-statistics_filled"))]
//            }else{
//                self?.selectionArr = [(NavigationNotifications.home, #imageLiteral(resourceName: "approved-purple")), (NavigationNotifications.allItemController, #imageLiteral(resourceName: "approved-blue")), (NavigationNotifications.statViewController, #imageLiteral(resourceName: "approved-lightBlue"))]
//            }
            self?.selectionTableView.reloadData()
        }
    }
    
    private func setUpTableView(){
        self.view.addSubview(selectionTableView)
        selectionTableView.translatesAutoresizingMaskIntoConstraints = false
        selectionTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        selectionTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        selectionTableView.bottomAnchor.constraint(equalTo: self.logout.topAnchor, constant: -40).isActive = true
        selectionTableView.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 20).isActive = true
        
        selectionTableView.delegate = self
        selectionTableView.dataSource = self
        
        selectionTableView.register(selectionTableViewCell.self, forCellReuseIdentifier: "cell")
        getUpdatesForSelection()
        
        selectionTableView.separatorStyle = .none
        selectionTableView.isScrollEnabled = false
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return selectionArr.count }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 50 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! selectionTableViewCell
        let tuple = selectionArr[indexPath.row]
        cell.updateCell(withIcon: tuple.1, andNotification: tuple.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = (tableView.cellForRow(at: indexPath) as! selectionTableViewCell)
        cell.isSelected = false
        cell.isHighlighted = false
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: cell.notification.rawValue), object: self))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.toggleMenu.rawValue), object: self))
    }
    
    
    class selectionTableViewCell: UITableViewCell{
        var titleLabel = UILabel()
        var iconImageView = UIImageView()
        var notification: NavigationNotifications!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            self.contentView.addSubview(iconImageView)
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
            iconImageView.widthAnchor.constraint(equalToConstant: 38).isActive = true
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor, constant: 0).isActive = true
            
            self.contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
            titleLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 15).isActive = true
            titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.font = UIFont(name: "Avenir-Book", size: 19)
            titleLabel.textColor = UIColor.textColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateCell(withIcon icon: UIImage, andNotification notif: NavigationNotifications){
            self.notification = notif
            self.titleLabel.text = notif.rawValue
            self.iconImageView.image = icon
        }
    }
}


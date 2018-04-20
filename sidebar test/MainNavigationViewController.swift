//
//  MainNavigationViewController.swift
//  FlightBites
//
//  Created by Avery Lamp on 5/25/16.
//  Copyright © 2016 David Jenkins. All rights reserved.
//

import UIKit

class MainNavigationViewController: UINavigationController {
    
    fileprivate var homeSelectedObserver: NSObjectProtocol?
    fileprivate var allTableViewSelectedObserver: NSObjectProtocol?
    fileprivate var statViewControllerSelectedObserver: NSObjectProtocol?
    fileprivate var logInObserver: NSObjectProtocol?
    
//    public var homeVC: Home!
    
    private let plusButton = UIButton()
    
    var plusButtonIsHidden: Bool = false {
        willSet{
            plusButton.isHidden = newValue
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isNavigationBarHidden = false
        addObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    
    //MARK: - NavigationItem
    
    let leftMenuButton: UIButton = {
        let menuButton = UIButton()
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        menuButton.addTarget(self, action: #selector(openSideBar), for: .touchUpInside)
        
        let openImageView = UIImageView()
        menuButton.addSubview(openImageView)
        openImageView.image = #imageLiteral(resourceName: "icons8-menu_filled").withRenderingMode(.alwaysOriginal)
        openImageView.translatesAutoresizingMaskIntoConstraints = false
        openImageView.heightAnchor.constraint(equalToConstant: 23).isActive = true
        openImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        openImageView.centerXAnchor.constraint(equalTo: menuButton.centerXAnchor, constant: 0).isActive = true
        openImageView.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor, constant: 0).isActive = true
        
        return menuButton
    }()
    
    var rightRequestButton: UIButton = {
        let plusButton = UIButton()
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let plusImageView = UIImageView()
        plusButton.addSubview(plusImageView)
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.image = #imageLiteral(resourceName: "icons8-plus_math_filled").withRenderingMode(.alwaysOriginal)
        plusImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        plusImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        plusImageView.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor, constant: 0).isActive = true
        plusImageView.centerXAnchor.constraint(equalTo: plusButton.centerXAnchor, constant: 0).isActive = true
        
        return plusButton
    }()
    
    var rightInfoButton: UIButton = {
        let plusButton = UIButton()
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let plusImageView = UIImageView()
        plusButton.addSubview(plusImageView)
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.image = #imageLiteral(resourceName: "icons8-info").withRenderingMode(.alwaysOriginal)
        plusImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        plusImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        plusImageView.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor, constant: 0).isActive = true
        plusImageView.centerXAnchor.constraint(equalTo: plusButton.centerXAnchor, constant: 0).isActive = true
        
        return plusButton
    }()
    
    public func setUpNavigation(){
        self.navigationBar.backgroundColor = UIColor.white
        self.navigationBar.layer.borderColor = UIColor.white.cgColor
        self.navigationBar.layer.borderWidth = 0
        self.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationBar.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.navigationBar.layer.shadowRadius = 1
        self.navigationBar.layer.shadowOpacity = 0.3
    }
    
    @objc func openSideBar(){
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.toggleMenu.rawValue), object: self))
    }
    
    
    
    //MARK: - Switch View Observers
    
    func addObservers(){
        let notificationCenter = NotificationCenter.default
        homeSelectedObserver = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NavigationNotifications.home.rawValue), object: nil, queue: nil, using: { [weak self] (notification) in
            self?.switchViewToHome()
        })
        
        allTableViewSelectedObserver = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NavigationNotifications.allItemController.rawValue), object: nil, queue: nil, using: { [weak self] (notification) in
            self?.switchViewTo(AllItemsController())
        })
        
        statViewControllerSelectedObserver = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NavigationNotifications.statViewController.rawValue), object: nil, queue: nil, using: { [weak self] (notification) in
            self?.switchViewTo(StatsViewController())
        })
        
        notificationCenter.addObserver(forName: WifiDisconectedNotification, object: nil, queue: nil, using:  {(notification) in
            self.viewControllers.last?.alert(title: "No Wifi", message: "Please connect to WiFi", buttonTitle: "Okay")
        })
        
    }
    
    //This is for adding the recognizer for changing the home after the origional time it has been logged in
//    func oneMoreRecognizer(){
//        logInObserver = NotificationCenter.default.addObserver(forName: logInCompleteNotification, object: nil, queue: nil) { [weak self] (notification) in
//            self?.homeVC = Home()
////            self?.setViewControllers([self?.homeVC], animated: true)
//        }
//    }
    
    func switchViewTo(_ viewController: UIViewController){
//        if let vc = viewControllers.first as? Home{
//            homeVC = vc
//        }
        setViewControllers([viewController], animated: false)
    }
    
    func switchViewToHome(){
//        setViewControllers([self.homeVC], animated: false)
        setViewControllers([Home()], animated: false)
    }
    
//    func setNewHomeView(){
//        self.homeVC = Home()
//        switchViewToHome()
//    }
    
    func removeObservers(){
        let notificationCenter = NotificationCenter.default
        
        if homeSelectedObserver != nil{
            notificationCenter.removeObserver(homeSelectedObserver!)
        }
        
        if allTableViewSelectedObserver != nil{
            notificationCenter.removeObserver(allTableViewSelectedObserver!)
        }
        
        if statViewControllerSelectedObserver != nil{
            notificationCenter.removeObserver(statViewControllerSelectedObserver!)
        }
        
        if logInObserver != nil{
            notificationCenter.removeObserver(logInObserver!)
        }
    }
}

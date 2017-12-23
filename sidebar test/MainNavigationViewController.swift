//
//  MainNavigationViewController.swift
//  FlightBites
//
//  Created by Avery Lamp on 5/25/16.
//  Copyright © 2016 David Jenkins. All rights reserved.
//

import UIKit

class MainNavigationViewController: UINavigationController {
    
    fileprivate var firstSelectedObserver: NSObjectProtocol?
    fileprivate var secondSelectedObserver: NSObjectProtocol?
    fileprivate var thirdSelectedObserver: NSObjectProtocol?

    var mainVCS = [UIViewController]()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.isNavigationBarHidden = false
        addObservers()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    func addObservers(){
        let notificationCenter = NotificationCenter.default
        firstSelectedObserver = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NavigationNotifications.first), object: nil, queue: nil, using: { (notification) in
            self.storeVCs()
            if self.mainVCS.count > 0{
                self.setViewControllers(self.mainVCS, animated: true)
            }else{
                
                //WHAT IS HAPPENING HERE??????
                
                
                let mainVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "first")
                self.mainVCS = [mainVC]
                self.setViewControllers(self.mainVCS, animated: true)
            }
        })
        notificationCenter.addObserver(forName: WifiDisconectedNotification, object: nil, queue: nil, using:  {(notification) in
            self.viewControllers.last?.alert(title: "No Wifi", message: "Please connect to WiFi", buttonTitle: "Okay")
        })
    }
    
    func storeVCs(){
        if (self.viewControllers.first as? Home) != nil{
            self.mainVCS = self.viewControllers
        }
    }
    
    func removeObservers(){
        let notificationCenter = NotificationCenter.default
        
        if firstSelectedObserver != nil{
            notificationCenter.removeObserver(firstSelectedObserver!)
        }
//        if secondSelectedObserver != nil{
//            notificationCenter.removeObserver(secondSelectedObserver!)
//        }
//        if thirdSelectedObserver != nil{
//            notificationCenter.removeObserver(thirdSelectedObserver!)
//        }
    }
}

    //
//  LogIn.swift
//  sidebar test
//
//  Created by alden lamp on 9/14/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LogIn: UIViewController, GIDSignInUIDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setUpView()
        setUpAuth()
        
        //Called after Login has been completed
        NotificationCenter.default.addObserver(forName: logInCompleteNotification, object: nil, queue: nil) { (notification) in
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "allowSideBarExtension")))
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "setUpUserAttributesSideBar")))
        }
    }
    
    func setUpAuth(){
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(googleSignIn))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        
        let button = UIView(frame: CGRect(x: self.view.frame.width/2 - 113, y: 500, width: 226, height: 50))
        button.addGestureRecognizer(gestureRecognizer)
        
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 500).isActive = true
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 226).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let gradient = CAGradientLayer()
        
        gradient.frame = button.bounds
        gradient.colors = [UIColor(hex: "79D6DC",alpha: 1).cgColor, UIColor(hex: "518CA9",alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.25)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        button.layer.insertSublayer(gradient, at: 0)
        
        button.layer.cornerRadius = button.frame.height/2
        button.layer.masksToBounds = true
        
        let userImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 19, height: 19))
        userImage.image = #imageLiteral(resourceName: "icons8-user_filled")
        userImage.translatesAutoresizingMaskIntoConstraints = false
        userImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
        userImage.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        button.addSubview(userImage)
        userImage.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: 0).isActive = true
        userImage.leftAnchor.constraint(equalTo: button.leftAnchor, constant: 17).isActive = true
        
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.text = "LOGIN WITH GOOGLE"
        label.textColor = UIColor.white
        label.textAlignment = .left
        
        button.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: 0).isActive = true
        label.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -17).isActive = true
        NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: userImage, attribute: .right, multiplier: 1, constant: 12).isActive = true
        
    }
    
    func googleSignIn(){ GIDSignIn.sharedInstance().signIn() }
    
    func setUpView(){
        let imageView = UIImageView(image: #imageLiteral(resourceName: "clock"))
        imageView.frame = CGRect(x: 0, y: 0, width: 91, height: 91)
        self.view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150).isActive = true
        
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 65))
        view.widthAnchor.constraint(equalToConstant: 240).isActive = true
        view.heightAnchor.constraint(equalToConstant: 65).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        let welcomeTo = UILabel()
        welcomeTo.text = "Welcome to"
        welcomeTo.font = UIFont(name: "Avenir-Medium", size: 18)
        welcomeTo.textColor = UIColor(hex: "647492", alpha: 1)
        welcomeTo.textAlignment = .center
        view.addSubview(welcomeTo)
        welcomeTo.translatesAutoresizingMaskIntoConstraints = false
        
        welcomeTo.heightAnchor.constraint(equalToConstant: 25).isActive = true
        welcomeTo.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        welcomeTo.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        welcomeTo.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        let latePass = UILabel()
        latePass.text = "LATE PASS"
        latePass.font = UIFont(name: "Avenir-Black", size: 26)
        latePass.textColor = UIColor(hex: "53C1C8", alpha: 1)
        latePass.textAlignment = .center
        view.addSubview(latePass)
        latePass.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedString = NSMutableAttributedString(string: latePass.text!)
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(3.0), range: NSRange(location: 0, length: attributedString.length))
        latePass.attributedText = attributedString
        
        latePass.heightAnchor.constraint(equalToConstant: 36).isActive = true
        latePass.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        latePass.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        NSLayoutConstraint(item: latePass, attribute: .top, relatedBy: .equal, toItem: welcomeTo, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        self.view.addSubview(view)
        
        view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 36).isActive = true
    }

}
    
    
    
    

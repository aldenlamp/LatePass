//
//  LoadingView.swift
//  sidebar test
//
//  Created by alden lamp on 5/4/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

class LoadingView: UIView{
    
    let activityIndicator = UIActivityIndicatorView()
    var label = UILabel()
    var viewHeight: CGFloat = 150
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        self.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        
        label.font = UIFont(name: "Avenir-Medium", size: 24)
        label.textColor = UIColor.textColor
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: viewHeight / 5).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.darkText
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -(viewHeight / 6)).isActive = true
        activityIndicator.startAnimating()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeMessage(message: String){
        self.label.text = message
    }
    
}

extension UIViewController{
    
    static var loadingView = LoadingView()
    static var currentBackgroundColor = UIColor.white
    static var loadingViewConstraints = [NSLayoutConstraint]()
    
    func addLoadingView(with message: String){
        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        UIViewController.currentBackgroundColor = self.view.backgroundColor!
        
        self.view.backgroundColor = UIColor(red: 0.835, green: 0.839, blue: 0.859, alpha: 1.00)
        for i in self.view.subviews{
            i.alpha = 0.3
        }
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.886, green: 0.886, blue: 0.902, alpha: 1.00)
        
        self.view.addSubview(UIViewController.loadingView)
        
        UIViewController.loadingViewConstraints.append(UIViewController.loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0))
        UIViewController.loadingViewConstraints.append(UIViewController.loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0))
        UIViewController.loadingViewConstraints.append(UIViewController.loadingView.widthAnchor.constraint(equalToConstant: (self.view.frame.width * 2)/3))
        UIViewController.loadingViewConstraints.append(UIViewController.loadingView.heightAnchor.constraint(equalToConstant: 150))
        UIViewController.loadingView.changeMessage(message: message)
        UIViewController.loadingViewConstraints.forEach() { $0.isActive = true }
        print("testing")
    }
    
    func removeLoadingView(completion: @escaping () -> ()){
        
        DispatchQueue.main.async {
            var contains = false
            for i in self.view.subviews{
                if i == UIViewController.loadingView{
                    contains = true
                    break
                }
            }
            
            if contains{
                
                UIView.animate(withDuration: 0.5, animations: {
                    UIViewController.loadingView.alpha = 0
                    self.view.backgroundColor = UIViewController.currentBackgroundColor
                    for i in self.view.subviews{
                        if i != UIViewController.loadingView{
                            i.alpha = 1
                        }
                    }
                    self.navigationController?.navigationBar.barTintColor = UIColor.white
                    
                }) { (randomBool) in
                    UIViewController.loadingView.alpha = 1
                    UIViewController.loadingView.removeFromSuperview()
                    UIViewController.loadingView.removeConstraints(UIViewController.loadingViewConstraints)
                    UIViewController.loadingViewConstraints.removeAll()
                    //                UIViewController.loadingView.removeConstraints(UIViewController.loadingView.constraints)
                    print("test")
                    completion()
                }
                
                self.view.isUserInteractionEnabled = true
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
            }
        }
    }
}





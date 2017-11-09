//
//  ExpandedCell.swift
//  sidebar test
//
//  Created by alden lamp on 9/22/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit

class ExpandedCell: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setUpCancelButton()
        setUpTitleLabels()
    }
    
    //MARK: - Title Label
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "Avenir-Light", size: 22)
        titleLabel.textColor = UIColor(hex: "3D4C68", alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return titleLabel
    }()
    
    let dateLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "Avenir-Light", size: 22)
        titleLabel.textColor = UIColor(hex: "3D4C68", alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        titleLabel.text = "May 23, 2017"
        return titleLabel
    }()
    
    let breakView: UIView = {
        let breakView = UIView()
        breakView.backgroundColor = UIColor(hex: "79D6DC", alpha: 1)
        breakView.translatesAutoresizingMaskIntoConstraints = false
        breakView.widthAnchor.constraint(equalToConstant: 92).isActive = true
        breakView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return breakView
    }()
    
    func setUpTitleLabels(){
        self.view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 73).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
//        dateLabel.text = "" //Change Later
        self.view.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        self.view.addSubview(breakView)
        breakView.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 17).isActive = true
        breakView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    }
    
    //MARK: - Cancel Button
    func setUpCancelButton(){
        let button = UIButton()
        button.image(for: .normal)
        button.setImage(#imageLiteral(resourceName: "icons8-delete_sign_filled"), for: .normal)
        button.frame = CGRect(x: 28, y: 41, width: 21, height: 21)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc private func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

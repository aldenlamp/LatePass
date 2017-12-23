//
//  UserCell.swift
//  sidebar test
//
//  Created by alden lamp on 11/23/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import Foundation
import UIKit


class UserCell: UITableViewCell{
    //height = 58 - 68
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let userImageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = (45/2)
        view.layer.masksToBounds = true
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.widthAnchor.constraint(equalToConstant: 45).isActive = true
        return view
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        return label
    }()
    
    let userEmailLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir-Medium", size: 16)
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.heightAnchor.constraint(equalToConstant: 23).isActive = true
        return label
    }()
    
    let sep: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    func addSeparator(){
        self.contentView.addSubview(sep)
        sep.leftAnchor.constraint(equalTo: userImageView.leftAnchor, constant: 0).isActive = true
        sep.rightAnchor.constraint(equalTo: userNameLabel.rightAnchor, constant: 0).isActive = true
    }
    
    private func setUpView(){
        self.contentView.addSubview(userImageView)
        userImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
        userImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        
        self.contentView.addSubview(userNameLabel)
        userNameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20).isActive = true
        
        self.contentView.addSubview(userEmailLabel)
        userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 0).isActive = true
        userEmailLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8).isActive = true
        userEmailLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20).isActive = true
    }
    
    func cellFromUser(user: User){
        self.userEmailLabel.text = user.userEmail
        self.userNameLabel.text = user.userName
        self.userImageView.image = user.userImage
    }
    
}

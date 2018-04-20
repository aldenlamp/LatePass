//
//  StatUserCell.swift
//  sidebar test
//
//  Created by alden lamp on 4/17/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

class StatUserCell: UITableViewCell{
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
        view.layer.cornerRadius = (40/2)
        view.layer.masksToBounds = true
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir-Medium", size: 20)
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir-Medium", size: 25)
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        label.widthAnchor.constraint(equalToConstant: 40).isActive = true
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
        sep.rightAnchor.constraint(equalTo:  self.contentView.rightAnchor, constant: 0).isActive = true
        sep.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
    }
    
    private func setUpView(){
        self.contentView.addSubview(userImageView)
        userImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 20).isActive = true
        userImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        
        self.contentView.addSubview(countLabel)
        countLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -15).isActive = true
        countLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        
        self.contentView.addSubview(userNameLabel)
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        userNameLabel.rightAnchor.constraint(equalTo: countLabel.leftAnchor, constant: -20).isActive = true
    }
    
    func cellFromUser(user: User, withCount count: Int, withBackgroundAlpha alpha: Int){
        self.userNameLabel.text = user.userName
        self.userImageView.image = user.userImage
        self.countLabel.text = "\(count)"
        self.contentView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(alpha))
    }
    
}


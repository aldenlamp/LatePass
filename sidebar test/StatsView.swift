//
//  StatsView.swift
//  sidebar test
//
//  Created by alden lamp on 1/26/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

class StatsView: UIView {
    
    //INDEX 0: this week, 1: this month, 2: this year
    var lateCounts = [0, 0, 0]{
        didSet{
            updateStatView()
        }
    }
    
    
    private var numberArr = [UILabel]()
    
    func setUpStats(){
        var statArr = [UIView]()
        statArr.append(createStatView(name: "This Year", count: lateCounts[2], index: 0))
        statArr.append(createStatView(name: "This Month", count: lateCounts[1], index: 1))
        statArr.append(createStatView(name: "This Week", count: lateCounts[0], index: 2))
        
        let stackView = UIStackView(arrangedSubviews: statArr)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
    }
    
    private func createStatView(name: String, count: Int, index: Int) -> UIView{
        let numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 70))
        numberArr.append(numberLabel)
        numberLabel.text = "\(count)"
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont(name: "Avenir-Heavy", size: 51)
        numberLabel.tag = 1
        switch index {
        case 0: numberLabel.textColor = UIColor(hex: "8FB3FB", alpha: 1)
        case 1: numberLabel.textColor = UIColor(hex: "BB8FF1", alpha: 1)
        case 2: numberLabel.textColor = UIColor(hex: "79D6DC", alpha: 1)
        default: break
        }
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 23))
        titleLabel.text = name
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 15.75)
        titleLabel.textColor = UIColor(hex: "798CAD", alpha: 1)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 93))
        containerView.backgroundColor = UIColor.clear
        
        containerView.addSubview(numberLabel)
        containerView.addSubview(titleLabel)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: numberLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: numberLabel, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: numberLabel, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: numberLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        return containerView
    }
    
    private func updateStatView(){
        for i in 0...2{
            numberArr[2-i].text = String(lateCounts[i])
        }
    }
    
}

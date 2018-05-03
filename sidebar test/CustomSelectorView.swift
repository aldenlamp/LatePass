//
//  CustomSelector.swift
//  sidebar test
//
//  Created by alden lamp on 4/25/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

protocol CustomSelectorDelegate: class {
    func selectionSwitched(to index: Int)
}


class CustomSelectorView: UIView{
    
    //The different sections of the View
    var sections: [String]! {
        didSet{
            updateView()
        }
    }
    var numberOfItems: Int{
        return sections.count
    }
    
    //Represents the current Section index
    var currentSection: Int = 0
    
    //The section title
    private var titleLabel = UILabel()
    
    //Controller Buttons
    private var leftButton = UIButton()
    private var rightButton = UIButton()
    
    //Boarder Views
    private let topView = UIView()
    private let bottomView = UIView()
    
    //The delegate
    var delegate: CustomSelectorDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setUpBoarder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews(){
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setImage(#imageLiteral(resourceName: "icons8-back_filled"), for: .normal)
        leftButton.addTarget(self, action: #selector(left), for: .touchUpInside)
        
        self.addSubview(leftButton)
        leftButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        leftButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        leftButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setImage(#imageLiteral(resourceName: "icons8-forward_filled"), for: .normal)
        rightButton.addTarget(self, action: #selector(right), for: .touchUpInside)
        
        self.addSubview(rightButton)
        rightButton.heightAnchor.constraint(equalTo: leftButton.heightAnchor, multiplier: 1).isActive = true
        rightButton.widthAnchor.constraint(equalTo: leftButton.widthAnchor, multiplier: 1).isActive = true
        rightButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        rightButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 19)
        titleLabel.textColor = UIColor.textColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightButton.leftAnchor, constant: -10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftButton.rightAnchor, constant: 10).isActive = true
    }
    
    private func setUpBoarder(){
        addSubview(topView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        topView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        topView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        topView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        bottomView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    
    @objc private func left(){
        currentSection -= 1
        delegate.selectionSwitched(to: currentSection)
        updateView()
    }
    
    @objc private func right(){
        currentSection += 1
        delegate.selectionSwitched(to: currentSection)
        updateView()
    }
    
    
    func updateView(){
        rightButton.isEnabled = currentSection != numberOfItems - 1
        rightButton.alpha = currentSection == numberOfItems - 1 ? 0.7 : 1
        leftButton.isEnabled = currentSection != 0
        leftButton.alpha = currentSection == 0 ? 0.7 : 1
        rightButton.isHidden = !rightButton.isEnabled && !leftButton.isEnabled
        leftButton.isHidden = !rightButton.isEnabled && !leftButton.isEnabled
        
        titleLabel.text = sections[currentSection]
    }
}

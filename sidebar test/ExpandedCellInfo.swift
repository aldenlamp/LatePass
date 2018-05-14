//
//  ExpandedCellInfo.swift
//  sidebar test
//
//  Created by alden lamp on 5/8/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

protocol ExpandCellInfoDelegate: class {
    func shouldShowSelectTeacher()
}


class ExpandedCellInfo: UIView, UITextFieldDelegate{
    
    let title = UILabel()
    let info = UILabel()
    private var inputTextField = UITextField()
    private var inputTeacherView = UIView()
    
    weak var delegate: ExpandCellInfoDelegate?
    
    var superWidth = CGFloat()
    
    init(){
        super.init(frame: CGRect())
    }

    init(superWidth: CGFloat, isReason reason: Bool = false){
        super.init(frame: CGRect())
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.superWidth = superWidth
        if !reason{
            self.addSep()
        }
        setUpTitle()
        setUpInfo(withReason: reason)
        setUpPicker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpTitle(){
        title.font = UIFont(name: "Avenir-Medium", size: 15)
        title.textColor = UIColor.textColor
        title.textAlignment = .left
        
        self.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.heightAnchor.constraint(equalToConstant: 60).isActive = true
        title.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        title.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
    }
    
    private func setUpInfo(withReason reason: Bool){
        info.textColor = UIColor.textColor
        info.font = UIFont(name: "Avenir-Medium", size: 16)
        info.textAlignment = .right
        info.adjustsFontSizeToFitWidth = true
        if reason{
            info.numberOfLines = 3
            
            let maxSize = CGSize(width: superWidth - (90), height: CGFloat.greatestFiniteMagnitude)
            let requiredSize = info.sizeThatFits(maxSize)
            info.heightAnchor.constraint(equalToConstant: requiredSize.height + 50).isActive = true
        }
        
        
        self.addSubview(info)
        info.translatesAutoresizingMaskIntoConstraints = false
        info.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        info.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 115).isActive = !reason
        info.widthAnchor.constraint(equalToConstant: (superWidth - (90) - 100)).isActive = reason
        info.heightAnchor.constraint(equalToConstant: 60).isActive = !reason
        info.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = !reason
        info.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = reason
    }
    
    public func setViews(title: String, info: String, isSelecting: Bool = false){
        self.title.text = title
        self.info.text = info
        if isSelecting{
            self.info.isHidden = true
            self.inputTeacherView.isHidden = false
        }else{
            self.info.isHidden = false
            self.inputTeacherView.isHidden = true
        }
    }
    
    
    func setUpPicker(){
        inputTeacherView = createQuestion(placeholder: "Select destination", num : 0)
        
        inputTeacherView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(inputTeacherView)
        
        inputTeacherView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
//        inputTeacherView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 115).isActive = true
        inputTeacherView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
    }
    
    
    
    func createQuestion(placeholder: String, num: Int) -> UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3)
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        inputTextField.adjustsFontSizeToFitWidth = true
        inputTextField.backgroundColor = UIColor(hex: "F9F9F9", alpha: 1)
        inputTextField.setLeftPaddingPoints(16)
        inputTextField.setRightPaddingPoints(16)
        
        inputTextField.attributedPlaceholder = NSAttributedString(string: "\(placeholder)", attributes: [NSAttributedStringKey.foregroundColor: UIColor(hex: "8290AB", alpha: 1), NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 16)!])
        inputTextField.font = UIFont(name: "Avenir-Medium", size: 16)
        inputTextField.textColor = UIColor.textColor
        inputTextField.tintColor = UIColor.textColor
        
        inputTextField.layer.borderColor = UIColor(hex: "E7E7E7", alpha: 1).cgColor
        inputTextField.layer.borderWidth = 1
        inputTextField.layer.masksToBounds = true
        inputTextField.layer.cornerRadius = 11
        
        view.addSubview(inputTextField)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        inputTextField.delegate = self
        
        return view
    }
    
    //Text Field Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let del = delegate{
            del.shouldShowSelectTeacher()
        }
        return false
    }
    

    
}

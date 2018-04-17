//
//  Request.swift
//  sidebar test
//
//  Created by alden lamp on 9/1/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase

class Request: UIViewController, UITextFieldDelegate, UITextViewDelegate, SelectTeacherDelegate {
   
    
    
    var selectedPeople: [User]?
    var toTeacher: User?
    var didEdit: Bool = false
    
    var isEditable = true
    
    //Needs 2 vcs for select Teachers
    //Those will be used to refrence and also to save data and to reload data wihtout th eporblem of deiniting
    //Only init the notification once in this vc in didappear
    
    var selectOne = SelectTeachers()
    let selectTwo = SelectTeachers()
    
    
    let selectTest = SelectTeachers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        selectedPeople = nil
        toTeacher = nil
        didEdit = false
        
//        selectOne.selectStudents = firebaseData.currentUser.userType != .student
//        selectOne.isFirstSelecion = firebaseData.currentUser.userType == .student
//
        if firebaseData.currentUser.userType != .student{
            selectOne.selectStudents = true
            selectOne.isFirstSelecion = false
        }else{
            selectOne.isFirstSelecion = true
            selectOne.selectStudents = false
        }
        
        selectTest.isFirstSelecion = false
        selectTest.selectStudents = false
        
        selectOne.delegate = self
        selectTwo.delegate = self
        
        setUpCancelButton()
        setUpTitleView()
        setUpPicker()
        setUpRequest()
        setUpDetailsView()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Request.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        
        print("\n\nPLSSSSSS DEINIT\n\n")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // User better methose of passing data between views such as a delgate and protocol
        
        // Pulling the data from select Teacher view Comtroller
        
        //TODO: - Save the people to be requested
//        if (selectedPeople != nil && selectedPeople! != []) || didEdit{
//            var listOfPeople = ""
//            for i in selectedPeople!{ listOfPeople += "\(i.userName), " }
//            listOfPeople = String(listOfPeople.dropLast(2))
//            
//            firstTextField.text = "\(listOfPeople)"
//            firstTextField.textColor = UIColor.textColor
//        }
//        if toTeacher != nil{
//            secondTextField.text = "\(String(describing: toTeacher!.userName))"
//            secondTextField.textColor = UIColor.textColor
//        }
    }
    
     func didSelectDestination(user: User) {
        toTeacher = user
        didEdit = true

        secondTextField.text = "\(String(describing: toTeacher!.userName))"
        secondTextField.textColor = UIColor.textColor
    }

    func didSelectFirst(users: [User]) {
        selectedPeople = users
        didEdit = true

        var listOfPeople = ""
        for i in selectedPeople!{ listOfPeople += "\(i.userName), " }
        listOfPeople = String(listOfPeople.dropLast(2))
        firstTextField.text = "\(listOfPeople)"
        firstTextField.textColor = UIColor.textColor
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
    
    //MARK: - Title
    
    let titleLabel = UILabel()
    let breakView = UIView()
    
    func setUpTitleView(){
        titleLabel.text = "Request Late Pass" // Create Late Pass -> for teachers
        titleLabel.font = UIFont(name: "Avenir-Light", size: 25)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.textColor
        
        titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        
        self.view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 75).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        breakView.backgroundColor = UIColor(hex: "79D6DC", alpha: 1)
        
        self.view.addSubview(breakView)
        breakView.translatesAutoresizingMaskIntoConstraints = false
        
        breakView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 17).isActive = true
        breakView.widthAnchor.constraint(equalToConstant: 92).isActive = true
        breakView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        breakView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    }
    
    //MARK: - Selecting teachers
    
    var firstView = UIView()
    var secondView = UIView()
    let breakView2 = UIView()
    
    let firstTextField = UITextField()
    let secondTextField = UITextField()
    
    func setUpPicker(){
        firstView = createQuestion(placeholder: "Select \(firebaseData.currentUser.userType == .student ? "Teacher" : "Students")", question: firebaseData.currentUser.userType == .student ? "Where are you comming from?" : "Who will be late?", num : 0)
        secondView = createQuestion(placeholder: "Select Teacher\(firebaseData.currentUser.userType == .student ? "" : " (OPTIONAL)")", question: "Who are \(firebaseData.currentUser.userType == .student ? "you" : "they") going to?", num: 1)
        
        firstView.translatesAutoresizingMaskIntoConstraints = false
        secondView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(firstView)
        self.view.addSubview(secondView)
        
        firstView.topAnchor.constraint(equalTo: breakView.bottomAnchor, constant: 24).isActive = true
        firstView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        secondView.topAnchor.constraint(equalTo: firstView.bottomAnchor, constant: 24).isActive = true
        secondView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        breakView2.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        breakView2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.view.addSubview(breakView2)
        breakView2.translatesAutoresizingMaskIntoConstraints = false
        breakView2.topAnchor.constraint(equalTo: secondView.bottomAnchor, constant: 24).isActive = true
        breakView2.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -23).isActive = true
        breakView2.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 23).isActive = true
        
    }
    
    func createQuestion(placeholder: String, question: String, num: Int) -> UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 285).isActive = true
        view.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        let labelView = UILabel()
        labelView.text = question
        labelView.font = UIFont(name: "Avenir-Medium", size: 15)
        labelView.textColor = UIColor.textColor
        labelView.textAlignment = .left
        
        view.addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.heightAnchor.constraint(equalToConstant: 19).isActive = true
        labelView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        labelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        labelView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        let textField = num == 0 ? firstTextField : secondTextField
        textField.adjustsFontSizeToFitWidth = true
        textField.backgroundColor = UIColor(hex: "F9F9F9", alpha: 1)
        textField.setLeftPaddingPoints(16)
        textField.setRightPaddingPoints(16)
        
        textField.attributedPlaceholder = NSAttributedString(string: "\(placeholder)", attributes: [NSAttributedStringKey.foregroundColor: UIColor(hex: "8290AB", alpha: 1), NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 16)!])
        textField.font = UIFont(name: "Avenir-Medium", size: 16)
        textField.textColor = UIColor.textColor
        textField.tintColor = UIColor.textColor
        
        textField.layer.borderColor = UIColor(hex: "E7E7E7", alpha: 1).cgColor
        textField.layer.borderWidth = 1
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 11
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 47).isActive = true
        textField.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 8).isActive = true
        textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        textField.delegate = self
        
        return view
    }
    
    //Text Field Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // isEditable is false when user is editing the textView
        
        if isEditable{
            
            //Determing which textField it is to choose with selectTexther view to show
            if textField == firstTextField{
                present(selectOne, animated: true, completion: nil)
            }else{
                present(selectTwo, animated: true, completion: nil)
            }
        }
        return false
    }
    
    //MARK: - Set up reasoning
    
    var topViewConst = NSLayoutConstraint()
    var topViewConst2 = NSLayoutConstraint()
    var bottomViewConst = NSLayoutConstraint()
    var heightConst = NSLayoutConstraint()
    let requestingView = UIView()
    
    let reasoning: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        view.font = UIFont(name: "Avenir-Medium", size: 15)
        view.text = "Reason for late pass"
        view.textColor = UIColor(hex: "8290AB", alpha: 1)
        view.tintColor = UIColor.textColor
        view.backgroundColor = UIColor(hex: "F9F9F9", alpha: 1)
        
        view.layer.borderColor = UIColor(hex: "E7E7E7", alpha: 1).cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 11
        view.setLeftPaddingPoints()
        
        view.returnKeyType = .done
        
        return view
    }()
    
    func setUpDetailsView(){
        
        self.view.addSubview(requestingView)
        requestingView.translatesAutoresizingMaskIntoConstraints = false
        requestingView.widthAnchor.constraint(equalToConstant: 285).isActive = true
        requestingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        requestingView.topAnchor.constraint(equalTo: self.breakView2.bottomAnchor, constant: 25).isActive = true
        requestingView.bottomAnchor.constraint(equalTo: self.requestButton.topAnchor, constant: -25).isActive = true
        
        let labelView = UILabel()
        labelView.text = "Additional Details"
        labelView.font = UIFont(name: "Avenir-Medium", size: 15)
        labelView.textColor = UIColor.textColor
        labelView.textAlignment = .left
        
        view.addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.heightAnchor.constraint(equalToConstant: 19).isActive = true
        labelView.leftAnchor.constraint(equalTo: requestingView.leftAnchor, constant: 0).isActive = true
        labelView.topAnchor.constraint(equalTo: requestingView.topAnchor, constant: 0).isActive = true
        
        self.view .addSubview(reasoning)
        reasoning.delegate = self
        reasoning.rightAnchor.constraint(equalTo: requestingView.rightAnchor, constant: 0).isActive = true
        reasoning.leftAnchor.constraint(equalTo: requestingView.leftAnchor, constant: 0).isActive = true
        
        topViewConst = NSLayoutConstraint(item: reasoning, attribute: .top, relatedBy: .equal, toItem: labelView, attribute: .bottom, multiplier: 1, constant: 8)
        topViewConst2 = NSLayoutConstraint(item: reasoning, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 100)
        
        topViewConst2.isActive = false
        topViewConst.isActive = true
        
        bottomViewConst = NSLayoutConstraint(item: reasoning, attribute: .bottom, relatedBy: .equal, toItem: requestingView, attribute: .bottom, multiplier: 1, constant: -1)
        bottomViewConst.isActive = true
    }
    
    
    //Text View Functions
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        print("firstView: \(view.frame) \t\t ")
        
        
        textView.textColor = UIColor.textColor
        if textView.text == "Reason for late pass"{
            textView.text = ""
        }
        self.view.layoutIfNeeded()
        
        topViewConst.isActive = false
        topViewConst2.isActive = true
        bottomViewConst.isActive = false
        heightConst = NSLayoutConstraint(item: reasoning, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -290)
        heightConst.isActive = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.decreaseAlpha()
        })
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        heightConst.isActive = false
        topViewConst2.isActive = false
        topViewConst.isActive = true
        bottomViewConst.isActive = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.increaseAlpha()
        })
        
        if textView.text == ""{
            textView.textColor = UIColor(hex: "8290AB", alpha: 1)
            textView.text = "Reason for late pass"
        }
    }
    
    //Setting up background on annimation
    func decreaseAlpha(){
        self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0.5)
        for view in self.view.subviews{
            if view != reasoning{
                view.alpha = 0.1
            }else{
            }
        }
        isEditable = false
    }
    
    func increaseAlpha(){
        self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(1)
        for view in self.view.subviews{
            view.alpha = 1
        }
        isEditable = true
    }
    
    @objc func dismissKeyboard() { view.endEditing(true) }
    
    
    //MARK: - Request Button
    
    let requestButton = UIButton(type: .system)
    
    func setUpRequest(){
        requestButton.setTitle("REQUEST", for: .normal)
        requestButton.titleLabel?.textColor = UIColor.white
        requestButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 14)
        requestButton.titleLabel?.textAlignment = .center
        requestButton.frame.size = CGSize(width: 225, height: 45)
        requestButton.tintColor = UIColor.white
        requestButton.addTarget(self, action: #selector(makeRequest), for: .touchUpInside)
        
        let gradient = CAGradientLayer()
        
        gradient.frame = requestButton.bounds
        gradient.colors = [UIColor(hex: "79D6DC",alpha: 1).cgColor, UIColor(hex: "518CA9",alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.25)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        requestButton.layer.insertSublayer(gradient, at: 0)
        
        requestButton.layer.cornerRadius = 22.5
        requestButton.layer.masksToBounds = true
        
        self.view.addSubview(requestButton)
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.widthAnchor.constraint(equalToConstant: 225).isActive = true
        requestButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        requestButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -44).isActive = true
        requestButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
    }
    
    @objc func makeRequest(){
        if isEditable{
            if selectedPeople != nil && toTeacher != nil{
                FirebaseRequests.makeRequest(from: selectedPeople!, toTeacher: toTeacher ?? User(email: nil), reason:  self.reasoning.text == "Reason for late pass" ? "" : self.reasoning.text!, completion: { [weak self] (title, message, buttonTitle, worked) in
                    
                    if (!worked){
                        self?.alert(title: title, message: message, buttonTitle: buttonTitle)
                    }else{
                        self?.dismiss(animated: true, completion: nil)
                    }
                    
                })
            }
        }
    }
}

//MARK: - Extensions

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextView{
    func setLeftPaddingPoints(){
        self.textContainerInset = UIEdgeInsetsMake(8,16,8,16) //top right bottom left
    }
}


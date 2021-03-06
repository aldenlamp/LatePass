//
//  SelectTeachers.swift
//  sidebar test
//
//  Created by alden lamp on 9/24/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase

protocol SelectTeacherDelegate: class {
    func didSelectDestination(user: User)
    func didSelectFirst(users: [User])
}


class SelectTeachers: UIViewController, UserTableViewDelegate, CustomSelectorDelegate{
    
    //This is if a student is selecting, is he selecting the first teacher or the second teahcer
    //LONG STORY SHORT: different thatn selectStudents
    //And very much necessary
    var isFirstSelecion = false
    var selectStudents = false
    var singleConfirmation = false
    weak var delegate: SelectTeacherDelegate!
    
    //This is the user tableView
    let tableView: UserTableView = UserTableView()
    
    //The data that we will be using
    var users: [[User]]!
    
    var numberOfTables: Int{
        get{
            return users.count
        }
    }
    
    //the segmented controller
    let customSelector = CustomSelectorView()
//    let segmentedController = UISegmentedControl()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        print(firebaseData.allTeachers)
        
        setUpBarButtons()
        setUpTitle()
        setUpSearchBar()
        if !GoogleDataClass.isPullingData{
            setUpCustomSelector()
            setUpTableView()
            setUpNoUsersLabel()
        }else{
            addLoading()
            shouldReformat = true
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectTeachers.dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Testing Pulling data to reload tableViews and such
        
        //This will be the mechanism for reloading the tableView if it has not loaded yet
        NotificationCenter.default.addObserver(self, selector: #selector(testingReloadTableview), name: userDataLoadedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadGCData), name: GCUsersLoaded, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(testingReloadTableview), name: teacherDataLoaded, object: nil)
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "testingReloadTableView"), object: nil)
//                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "testingReloadTableView"), object: nil)
    }
    

    @objc func testingReloadTableview(){
        print("shit is happeneing")
        if (selectStudents && allStudentsLoaded) || (!selectStudents && allTeachersLoaded){
            tableView.update()
        }
    }

    var shouldReformat = false
    
    var loadingView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "Loading Users Table"
        label.font = UIFont(name: "Avenir-Medium", size: 21)
        label.textColor = UIColor.textColor
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.textColor
        activityIndicator.isHidden = false
        if activityIndicator.isAnimating == false{
            activityIndicator.startAnimating()
        }
        activityIndicator.hidesWhenStopped = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        view.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return view
    }()
    
    func addLoading(){
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loadingView)
        loadingView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        loadingView.topAnchor.constraint(equalTo: self.searchView.bottomAnchor, constant: 30).isActive = true
    }
    
    func removeLoading(){
        self.loadingView.removeFromSuperview()
    }
    
    @objc func reloadGCData(){
        if shouldReformat{
            removeLoading()
            setUpCustomSelector()
            setUpTableView()
            setUpNoUsersLabel()
            self.shouldReformat = false
            //TODO: - Do Stuff
        }
        selectionSwitched(to: customSelector.currentSection)
    }
    
    @objc func dismissKeyboard() { view.endEditing(true) }
    
    //MARK: - Cancel Button
    
    func setUpBarButtons(){
        let button = UIButton()
        button.image(for: .normal)
        button.setImage(#imageLiteral(resourceName: "icons8-delete_sign_filled"), for: .normal)
        button.frame = CGRect(x: 28, y: 41, width: 21, height: 21)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(button)
        
        
        //TODO: - Only allow for teachers
        if isFirstSelecion && selectStudents{
            let rbutton = UIButton()
            rbutton.image(for: .normal)
            rbutton.setImage(#imageLiteral(resourceName: "icons8-checkmark_filled"), for: .normal)
            rbutton.frame = CGRect(x: self.view.frame.width - 49, y: 41, width: 21, height: 21)
            rbutton.addTarget(self, action: #selector(finish), for: .touchUpInside)
            self.view.addSubview(rbutton)
        }
    }
    
    @objc private func cancel(){
        tableView.selectedArray = [User]()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func finish(){
        //TODO: - Make a delegate functions to return the list of teachers
        if self.tableView.selectedArray.isEmpty{
            alert(title: "No Students Selected", message: "Please select one or more students", buttonTitle: "Done")
            return
        }
        
        delegate.didSelectFirst(users: tableView.selectedArray)
        self.dismiss(animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("View deInited")
        tableView.selectedArray.removeAll()
    }
    
    //MARK: - Title
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Light", size: 22)
        label.textColor = UIColor.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.widthAnchor.constraint(equalToConstant: 190).isActive = true
        return label
    }()
    
    func setUpTitle(){
        titleLabel.text = selectStudents ? "Select Students" : "Select Teacher"
        self.view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 73).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    }
    
    //MARK: - Search Bar
    
    let searchTextField : UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.clear
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont(name: "Avenir-Medium", size: 15)
        textField.textColor = UIColor(hex: "55596B", alpha: 1)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        
        return textField
    }()
    
    let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let topBoarder = UIView()
        view.addSubview(topBoarder)
        topBoarder.translatesAutoresizingMaskIntoConstraints = false
        topBoarder.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        topBoarder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        topBoarder.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        topBoarder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        topBoarder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        let bottomBoarder = UIView()
        view.addSubview(bottomBoarder)
        bottomBoarder.translatesAutoresizingMaskIntoConstraints = false
        bottomBoarder.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        bottomBoarder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomBoarder.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        bottomBoarder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        bottomBoarder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "icons8-search_filled")
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 27).isActive = true
        imageView.tag = 9
        
        return view
    }()
    
    func setUpSearchBar(){
        
        searchView.addSubview(searchTextField)
        searchTextField.heightAnchor.constraint(equalToConstant: 25).isActive = true
        searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor, constant: 0).isActive = true
        searchTextField.leftAnchor.constraint(equalTo: (searchView.viewWithTag(9)?.rightAnchor)!, constant: 8).isActive = true
        searchTextField.rightAnchor.constraint(equalTo: searchView.rightAnchor, constant: -20).isActive = true
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor(hex: "8290AB", alpha: 1), NSAttributedStringKey.font : UIFont(name: "Avenir-Medium", size: 15)!]
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search For \(selectStudents ? "Student" : "Teacher")", attributes: attributes)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        self.view.addSubview(searchView)
        searchView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        searchView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        searchView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: 42).isActive = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        tableView.textDidChange(to: textField.text!.lowercased())
    }
    
    //MARK: - Segmented Controller
    
    func setUpCustomSelector(){
        
        if !selectStudents{
            customSelector.sections = firebaseData.currentUser.userType == .student ? ["Google Classroom Teachers", "All Teachers"] : ["Teachers"]
        }else{
            customSelector.sections = firebaseData.googleData.courseNames
        }
        
        customSelector.translatesAutoresizingMaskIntoConstraints = false
        customSelector.delegate = self
        
        self.view.addSubview(customSelector)
        customSelector.heightAnchor.constraint(equalToConstant: 60).isActive = true
        customSelector.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        customSelector.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        customSelector.topAnchor.constraint(equalTo: self.searchView.bottomAnchor, constant: 0).isActive = true
    }
    
    func selectionSwitched(to index: Int) {
        
        let users: [User]
        if firebaseData.currentUser.userType == .student{
            //users = firebaseData.allTeachers
            users = firebaseData.googleData.teachers[index]
        }else{
            // users = selectStudents ? firebaseData.allStudents : firebaseData.allTeachers
            
            if selectStudents{
                users = firebaseData.googleData.students[index]
            }else{
                users = firebaseData.allTeachers.excluding(user: firebaseData.currentUser.userEmail)
            }
        }
        tableView.userList = users
        tableView.update()
        if users.isEmpty && firebaseData.googleData.studentsLoaded && firebaseData.googleData.teachersLoaded{
            tableView.isHidden = true
            noUsersLabel.isHidden = false
        }else{
            tableView.isHidden = false
            noUsersLabel.isHidden = true
        }
    }
    
    
    
    //MARK: - TableView
    
    let noUsersLabel = UILabel()
    
    func setUpTableView(){
        tableView.delegate = self
        let users: [User]
        
        
        if firebaseData.currentUser.userType == .student{
//            users = firebaseData.allTeachers
            if firebaseData.googleData.teachers.count == 0{
                self.shouldReformat = true
                return
            }
            users = firebaseData.googleData.teachers[customSelector.currentSection]
        }else{
//            users = selectStudents ? firebaseData.allStudents : firebaseData.allTeachers
            
            if selectStudents{
                if firebaseData.googleData.students.count == 0{
                    self.shouldReformat = true
                    return
                }
                users = firebaseData.googleData.students[customSelector.currentSection]
            }else{
                if firebaseData.googleData.students.count == 0{
                    self.shouldReformat = true
                    return
                }
                users = firebaseData.allTeachers.excluding(user: firebaseData.currentUser.userEmail)
//                users = firebaseData.GCAllTeachers
            }
        }
        
        if users.isEmpty && firebaseData.googleData.studentsLoaded && firebaseData.googleData.teachersLoaded{
            tableView.isHidden = true
            noUsersLabel.isHidden = false
        }else{
            tableView.isHidden = false
            noUsersLabel.isHidden = true
        }
        
        tableView.setUpTableView(withUsers: users, multipleSelect: selectStudents)
        
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints  = false
        tableView.topAnchor.constraint(equalTo: customSelector.bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive  = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
    }
    
    func setUpNoUsersLabel(){
        noUsersLabel.text = "There are not Users in this list"
        noUsersLabel.font = UIFont(name: "Avenir-Medium", size: 21)
        noUsersLabel.textColor = UIColor.textColor
        noUsersLabel.textAlignment = .center
        noUsersLabel.adjustsFontSizeToFitWidth = true
        noUsersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(noUsersLabel)
        noUsersLabel.topAnchor.constraint(equalTo: customSelector.bottomAnchor, constant: 30).isActive = true
        noUsersLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        noUsersLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        noUsersLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        noUsersLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
    }
    
    func singleUserSelected(selectedUser: User) {
        searchTextField.text = ""
        searchTextField.endEditing(true)
        

        
        
        if isFirstSelecion {
            delegate.didSelectFirst(users: [selectedUser])
            dismiss(animated: true, completion: nil)
        }else if singleConfirmation{
            
            
            let alert = UIAlertController(title: "Destination", message: "Are you sure \(selectedUser.userName) is your destination?", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Yes", style: .default) { [weak self] (handler) in
                self?.delegate.didSelectDestination(user: selectedUser)
                alert.dismiss(animated: true, completion: nil)
                self?.dismiss(animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "No", style: .default) { (handler) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(doneAction)
            self.present(alert, animated: true, completion: nil)
            
        }else{
            delegate.didSelectDestination(user: selectedUser)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    
}


extension SelectTeachers: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        searchTextField.endEditing(true)
        return self.searchTextField.isEditing
    }
}

//
//  SelectTeachers.swift
//  sidebar test
//
//  Created by alden lamp on 9/24/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase




class SelectTeachers: UIViewController{
    
    var selectedArray = [User]()
    var filteredUsers = [User]()
    var isSearching = false
    var isFirstSelecion = false
    
    var selectStudents = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        print(firebaseData.allTeachers)
        
        setUpCancelButton()
        setUpTitle()
        setUpSearchBar()
        setUpTableView()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectTeachers.dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Testing Pulling data to reload tableViews and such
        
        //This will be the mechanism for reloading the tableView if it has not loaded yet
        NotificationCenter.default.addObserver(self, selector: #selector(testingReloadTableview), name: studentDataLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(testingReloadTableview), name: teacherDataLoaded, object: nil)
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "testingReloadTableView"), object: nil)
//                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "testingReloadTableView"), object: nil)
//
        
        
    }
    
    
        @objc func testingReloadTableview(){
            print("shit is happeneing")
            if (selectStudents && allStudentsLoaded) || (!selectStudents && allTeachersLoaded){ tableView.reloadData() }
        }
    
    @objc func dismissKeyboard() { view.endEditing(true) }
    
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
        selectedPeople = selectedArray.reversed()
        didEdit = true
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Title
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Light", size: 22)
        label.textColor = UIColor(hex: "3D4C68", alpha: 1)
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
        filteredUsers.removeAll()
        let text = textField.text!.lowercased()
        if text == ""{
            isSearching = false
        }else{
            isSearching = true
            for i in selectStudents ? firebaseData.allStudents : firebaseData.allTeachers{
                if i.userName.lowercased().contains(text) || i.userEmail.lowercased().contains(text){
                    filteredUsers.append(i)
                }
            }
            
        }
        tableView.reloadData()
    }
    
    //MARK: - TableView
    let tableView: UITableView = UITableView()
    
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints  = false
        tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0).isActive = true // Change to search bar
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive  = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
    }
}


extension SelectTeachers: UITableViewDelegate,  UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 65 }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredUsers.count : selectStudents ? firebaseData.allStudents.count : firebaseData.allTeachers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userCell = isSearching ? filteredUsers[indexPath.row] : selectStudents ? firebaseData.allStudents[indexPath.row] : firebaseData.allTeachers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        cell.userNameLabel.text = userCell.userName
        cell.userImageView.image = userCell.userImage
        cell.userEmailLabel.text = userCell.userEmail
        
        if indexPath.row != 0 { cell.addSeparator() }
        
        if selectStudents && !userCell.isChosen{
            cell.contentView.alpha = 0.65
        }else{
            cell.contentView.alpha = 1
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UserCell
        
        if !selectStudents{
            //TODO: - dissmiss view and return the user
            let user = isSearching ? filteredUsers[indexPath.row] : firebaseData.allTeachers[indexPath.row]
//            toTeacher = user
            if isFirstSelecion {
                selectedArray.removeAll()
                selectedArray.append(user)
                cancel()
            }else{
                toTeacher = user
            }
            
            
            self.dismiss(animated: true, completion: nil)
        }else{
            let user = isSearching ? filteredUsers[indexPath.row] : firebaseData.allStudents[indexPath.row]
            
            if user.isChosen{
                user.isChosen = false
                cell.contentView.alpha = 0.65
                //more away from the top of the array
                
                if indexPath.row != User.numberOfSelected{
                    let removedUser = firebaseData.allStudents.remove(at: user.userIndex!)
                    if !isSearching{ tableView.deleteRows(at: [indexPath], with: .automatic) }
                    firebaseData.allStudents.insert(removedUser, at: User.numberOfSelected)
                    if !isSearching{ tableView.insertRows(at: [ IndexPath(row: User.numberOfSelected,section: 0) ] , with: .automatic) }
                }
                
                selectedArray.remove(at: selectedArray.index(of: user)!)
                
                firebaseData.resetingUserIndex()
                
            }else{
                user.isChosen = true
                cell.contentView.alpha = 1
                //move to the top of the array
                
                if indexPath.row != 0{
                    let removedUser = firebaseData.allStudents.remove(at: user.userIndex!)
                    if (!isSearching){ tableView.deleteRows(at: [indexPath], with: .automatic) }
                    firebaseData.allStudents.insert(removedUser, at: 0)
                    if (!isSearching){ tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic) }
                }
                
                selectedArray.append(user)
                
                firebaseData.resetingUserIndex()
            }
        }
        
        if selectStudents{
            searchTextField.text = ""
            isSearching = false
            searchTextField.endEditing(true)
        }
        

        //For testing if the order is in the right way wiht the User index only for the teachers
//        for i in firebaseData.userSelection{
//            print("INDEX: \(i.userIndex)\t\tuserName: \(i.userName)\temail: \(i.userEmail)")
//        }
//        print("\n\n\n")
//
    }
}


extension SelectTeachers: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        searchTextField.endEditing(true)
        return self.searchTextField.isEditing
    }
}

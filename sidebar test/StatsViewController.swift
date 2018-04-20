//
//  StatsViewController.swift
//  sidebar test
//
//  Created by alden lamp on 4/17/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit


class StatsViewController: UIViewController{
    
    //Hold the data for a teachers view: Search by student
    internal var teacherUserTable: [User: [User : [HistoryData]]] = [User: [User : [HistoryData]]]()
    internal var teacherCountTable: [User: Int] = [User: Int]()
    internal var teacherSortedUsers: [User]{
        get{
            var arr = Array(teacherCountTable.keys)
            for _ in 0..<arr.count{
                for i in 1..<arr.count{
                    if teacherCountTable[arr[i - 1]]! < teacherCountTable[arr[i]]!{
                        let temp = arr[i-1]
                        arr[i-1] = arr[i]
                        arr[i] = temp
                    }
                }
            }
            return arr
        }
    }
    
    //This holds the data for a student view: Search by teacher
    internal var studentUserTable: [User : [HistoryData]] = [User : [HistoryData]]()
    internal var studentSortedUsers: [User] {
        get{
            var arr = Array(studentUserTable.keys)
            for _ in 0..<arr.count{
                for i in 1..<arr.count{
                    if studentUserTable[arr[i - 1]]!.count < studentUserTable[arr[i]]!.count{
                        let temp = arr[i-1]
                        arr[i-1] = arr[i]
                        arr[i] = temp
                    }
                }
            }
            return arr
        }
    }
    
    //TableView for displaying the users
    internal let statTableView = UITableView()
    
    //This is for when a teacher expands a student to see from which teachesr
    internal let expandTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        setUpNavigation()
        sortData()
        setUpSearchBar()
        setUpMainTableView()
     
        
        var str = ""
        
        for i in studentSortedUsers{
            str += "\(i.userName) "
        }
        print("Student List: \(str)")
        
        var str2 = ""
        
        for i in teacherSortedUsers{
            str2 += "\(i.userName) "
        }
        
        print("Teacher Sorted List: \(str2)")
        
        
    }
    
    //MARK: - Navigation
    
    var titleLabelView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.textColor = UIColor.textColor
        label.font = UIFont(name: "Avenir-Black", size: 20)
        label.text = "Analysis"
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 24).isActive = true
        view.widthAnchor.constraint(equalToConstant: 160).isActive = true
        return view
    }()
    
    private func setUpNavigation(){
        guard let navController = navigationController as? MainNavigationViewController else{
            print("something went wrong")
            return
        }
        navigationItem.titleView = titleLabelView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navController.leftMenuButton)
        navController.rightInfoButton.addTarget(self, action: #selector(displayInfoController), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navController.rightInfoButton)
    }
    
    
    @objc func displayInfoController(){
        if firebaseData.currentUser.userType == .student{
            alert(title: "Analysis View", message: "This is a list of all the teachers you have been late to", buttonTitle: "Done")
        }else{
            alert(title: "Analysis View", message: "This is a list of all the people who have been late to your class including how many times and from which teachers", buttonTitle: "Done")
        }
    }

    
    //MARK: - Sorting Data
    func sortData(){
        if firebaseData.currentUser.userType == .student{
            for i in firebaseData.studentItems{
                if let _ = studentUserTable[i.destination!]{
                    studentUserTable[i.destination!]?.append(i)
                }else{
                    studentUserTable[i.destination!] = [i]
                }
            }
        }else{
            for i in firebaseData.toItems{
                if let count = teacherCountTable[i.student] {
                    teacherCountTable[i.student] = count + 1
                }else{
                    teacherCountTable[i.student] = 1
                }
                
                if let studentStatus = teacherUserTable[i.student]{
                    if let _ = studentStatus[i.origin]{
                        teacherUserTable[i.student]![i.origin]?.append(i)
                    }else{
                        teacherUserTable[i.student]![i.origin] = [i]
                    }
                }else{
                    teacherUserTable[i.student] = [i.origin : [i]]
                }
                
            }
        }
        
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
    
    let searchResult: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 15)
        label.textAlignment = .right
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
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
        
        searchView.addSubview(searchResult)
        searchResult.rightAnchor.constraint(equalTo: searchView.rightAnchor, constant: -20).isActive = true
        searchResult.heightAnchor.constraint(equalToConstant: 30).isActive = true
        searchResult.centerYAnchor.constraint(equalTo: searchView.centerYAnchor, constant: 0).isActive = true
        searchResult.widthAnchor.constraint(equalToConstant: 50).isActive = true
        searchResult.text = "\(firebaseData.currentUser.userType == .student ? studentUserTable.count : teacherUserTable.count)"
        
        searchView.addSubview(searchTextField)
        searchTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor, constant: 0).isActive = true
        searchTextField.leftAnchor.constraint(equalTo: (searchView.viewWithTag(9)?.rightAnchor)!, constant: 8).isActive = true
        searchTextField.rightAnchor.constraint(equalTo: searchResult.rightAnchor, constant: -8).isActive = true
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor(hex: "8290AB", alpha: 1), NSAttributedStringKey.font : UIFont(name: "Avenir-Medium", size: 15)!]
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search For Passes", attributes: attributes)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.delegate = self
        
        //It looks weird to have nothing above it
        self.view.addSubview(searchView)
        //        searchView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        searchView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 65).isActive = true
        searchView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        searchView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
}

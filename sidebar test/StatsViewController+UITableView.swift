//
//  StatsViewController+UITableView.swift
//  sidebar test
//
//  Created by alden lamp on 4/17/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

extension StatsViewController: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    //TODO: - Move this to a better place
    @objc func textFieldDidChange(_ textField: UITextField){
//        historyTableView.filterString = textField.text!.lowercased()
    }
    
    
    func setUpMainTableView(){
        statTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(statTableView)
        statTableView.topAnchor.constraint(equalTo: self.searchView.bottomAnchor, constant: 0).isActive = true
        statTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        statTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        statTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        statTableView.separatorColor = UIColor.clear
        statTableView.register(StatUserCell.self, forCellReuseIdentifier: "Cell")
        
        statTableView.delegate = self
        statTableView.dataSource = self
    }
    
    
    //MARK: - TableView Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if firebaseData.currentUser.userType == .student{
            print(studentUserTable.count)
            return studentUserTable.count
        }else{
            print(teacherUserTable.count)
            return teacherUserTable.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //TODO: - Make sure this measuremnt works
        //TODO: - implement expanding cell
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = statTableView.dequeueReusableCell(withIdentifier: "Cell") as! StatUserCell
        
        if firebaseData.currentUser.userType == .student{
            let user = studentSortedUsers[indexPath.row]
            cell.cellFromUser(user: user, withCount: studentUserTable[user]!.count, withBackgroundAlpha: 0)
        }else{
            let user = teacherSortedUsers[indexPath.row]
            cell.cellFromUser(user: user, withCount: teacherCountTable[user]!, withBackgroundAlpha: 0)
        }
        cell.addSeparator()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: - Either go to a new view controller with the history data or expand downard
    }
    
    
    
}

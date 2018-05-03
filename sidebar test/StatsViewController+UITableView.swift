//
//  StatsViewController+UITableView.swift
//  sidebar test
//
//  Created by alden lamp on 4/17/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

extension StatsViewController: UITableViewDelegate, UITableViewDataSource{
    
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
            return studentSortedUsers.count
        }else{
            return teacherSortedUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return CGFloat((tableView.cellForRow(at: indexPath) as! StatUserCell).height)
        }else{
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = statTableView.dequeueReusableCell(withIdentifier: "Cell") as! StatUserCell
        
        if firebaseData.currentUser.userType == .student{
            let user = studentSortedUsers[indexPath.row]
            cell.cellFromUser(user: user, withCount: studentUserTable[user]!.count, withBackgroundAlpha: 0)
        }else{
            let user = teacherSortedUsers[indexPath.row]
            if selectedIndex == indexPath.row{
                
                cell.cellFromUser(user: user, withCount: teacherCountTable[user]!, withBackgroundAlpha: 0, isOpen: true, data: teacherUserTable[user])
                cell.statTableView.delegate = self
            }else{
                cell.cellFromUser(user: user, withCount: teacherCountTable[user]!, withBackgroundAlpha: 0)
            }
            
        }
        cell.addSeparator()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if firebaseData.currentUser.userType == .student {
            goToView(from: studentUserTable[studentSortedUsers[indexPath.row]]!, teacherUser: studentSortedUsers[indexPath.row])
        }else{
            let cell = (tableView.cellForRow(at: indexPath) as! StatUserCell)
            if selectedIndex == indexPath.row{
                selectedIndex = -1
            }else{
                selectedIndex = indexPath.row
                let user = teacherSortedUsers[indexPath.row]
                cell.setNumOfRows(data: teacherUserTable[user]!)
                cell.statTableView.delegate = self
            }
            cell.isSelected = false
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func didSelectRow(at index: Int, with user: User) {
        goToView(from: teacherUserTable[teacherSortedUsers[selectedIndex]]![user]!, studentUser: teacherSortedUsers[selectedIndex],teacherUser: user)
    }
    
    
    func goToView(from data: [HistoryData], studentUser: User? = nil, teacherUser: User){
        
        let str: String
        if studentUser == nil{
            str = "Passes To \(teacherUser.userName)"
        }else{
            str = "Passes From \(teacherUser.userName) for \(studentUser!.userName)"
        }
        
        let vc = ExpandStatViewController()
        vc.historyData = data
        vc.titleString = str
        show(vc, sender: nil)
    }

    
    
}

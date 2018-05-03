//
//  UserTableView.swift
//  sidebar test
//
//  Created by alden lamp on 2/18/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import UIKit

protocol UserTableViewDelegate: class{
    func singleUserSelected(selectedUser: User)
}

//TODO: - Make userTable be a tableViewController
class UserTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var selectedArray = [User]()
    
    var isSearching = false
    var multipleSelect = false
    
    var tableView = UITableView()
    
    var userList = [User]()
    var filteredList = [User]()
    
    var currentSearchText = ""
    
    weak var delegate: UserTableViewDelegate!
    
    func setUpTableView(withUsers users : [User], multipleSelect style: Bool){
        userList = users
        multipleSelect = style
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    func update(){
        tableView.reloadData()
    }
    
    deinit {
        print("tableView did Deinit")
    }
    
    func textDidChange(to text: String){
        currentSearchText = text
        filteredList.removeAll()
        
        if text == ""{
            isSearching = false
        }else{
            isSearching = true
            for i in userList{
                if i.userName.lowercased().contains(text.lowercased()) || i.userEmail.lowercased().contains(text.lowercased()){
                    filteredList.append(i)
                }
            }
        }
        update()
    }

    
    //MARK: - Table View Functions
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return isSearching ? filteredList.count : userList.count }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 65 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userData: User = isSearching ? filteredList[indexPath.row] : userList[indexPath.row]
        let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        userCell.cellFromUser(user: userData)
        
        if indexPath.row != 0 { userCell.addSeparator() }
        
        if multipleSelect && !selectedArray.contains(userData){
            userCell.contentView.alpha = 0.7
        }else{
            userCell.contentView.alpha = 1
        }
        
        userCell.selectionStyle = .none
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! UserCell
        let selectedUser = isSearching ? filteredList[indexPath.row] : userList[indexPath.row]
        
        if multipleSelect{
            if selectedArray.contains(selectedUser){
                //move Away from the top and remove from selected
                
                selectedCell.contentView.alpha = 0.7
                
                selectedArray.remove(at: selectedArray.index(of: selectedUser)!)
                
                //Moving the cell
                if indexPath.row != selectedArray.count{//User.numberOfSelected{
                    let removedUser = userList.remove(at: userList.index(of: selectedUser)!)
                    if !isSearching{ tableView.deleteRows(at: [indexPath], with: .automatic) }
                    userList.insert(removedUser, at: selectedArray.count)
                    if !isSearching{ tableView.insertRows(at: [ IndexPath(row: selectedArray.count,section: 0) ] , with: .automatic) }
                }
            }else{
                //Moving cell to the top and selecting
                
//                selectedUser.isChosen = true
                selectedCell.contentView.alpha = 1
                selectedArray.append(selectedUser)
                
                if indexPath.row != 0{
                    let removedUser = userList.remove(at: userList.index(of: selectedUser)!)
                    if (!isSearching){ tableView.deleteRows(at: [indexPath], with: .automatic) }
                    userList.insert(removedUser, at: 0)
                    if (!isSearching){ tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic) }
                }
            }
        }else{
            delegate.singleUserSelected(selectedUser: selectedUser)
        }
    }
}

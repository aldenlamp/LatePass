//
//  StatTableView.swift
//  sidebar test
//
//  Created by alden lamp on 4/20/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

protocol StatTableViewDelegate: class {
    func didSelectRow(at index: Int, with user: User)
}


class StatTableView: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    private var tableView = UITableView()
    
    weak var delegate: StatTableViewDelegate!
    
    var data = [User: [HistoryData]]() {
        didSet{
            tableView.reloadData()
        }
    }
    private var sortedUserList: [User]{
        get{
            var arr = Array(data.keys)
            for _ in 0..<arr.count{
                for i in 1..<arr.count{
                    if data[arr[i - 1]]!.count < data[arr[i]]!.count{
                        let temp = arr[i-1]
                        arr[i-1] = arr[i]
                        arr[i] = temp
                    }
                }
            }
            return arr
        }
    }
    
    var totalHeight: Int{ get{ return data.count * 50 } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        
        tableView.register(StatUserCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    
    //MARK: - tableView functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! StatUserCell
        let user = sortedUserList[indexPath.row]
        cell.cellFromUser(user: user, withCount: data[user]!.count, withBackgroundAlpha: 0, isCompressed: true)
        cell.addSeparator()
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: - handle the tableView touch
        delegate.didSelectRow(at: indexPath.row, with: sortedUserList[indexPath.row])
    }
    
}


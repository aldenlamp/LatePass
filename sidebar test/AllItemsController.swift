//
//  AllItemsController.swift
//  sidebar test
//
//  Created by alden lamp on 3/2/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import UIKit

class AllItemsController: UIViewController, FirebaseProtocol, HistoryTableViewDelegate {
    
    
    
    let historyTableView = HistoryTableView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setUpNavigation()
        setUpTableView()
        
    }
    
    
    //MARK: - Navigation Functions
    
    var titleLabelView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.textColor = UIColor.textColor
        label.font = UIFont(name: "Avenir-Black", size: 20)
        label.text = "All History"
        
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
        
    }
    
    @objc func openSideBar(){
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.toggleMenu.rawValue), object: self))
    }
    
    
    //MARK: - History Table View Functions
    
    private func setUpTableView(){
        self.view.addSubview(historyTableView)
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        //TODO: - Add constraints to the table View
        
        
        if firebaseData.allItems.isEmpty{
            historyTableView.infoArray = firebaseData.allItems
        }else{
            
            
        }
    }
    
    func historyArrayDidLoad() {
//        <#code#>
    }
    
    func userDataDidLoad() {
//        <#code#>
    }
    
    func historyTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with historyData: HistoryData) {
//        <#code#>
    }
    
    
    
    
    
    
    
    
    
}

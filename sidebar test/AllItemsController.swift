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
        
        self.view.addSubview(historyTableView)
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        //TODO: - Add constraints to the table View
        
        
        if firebaseData.allItems.isEmpty{
            historyTableView.infoArray = firebaseData.allItems
        }else{
         
            
        }
    }
    
    
    //MARK: - History Table View Functions
    
    private func setUpTableView(){
        
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

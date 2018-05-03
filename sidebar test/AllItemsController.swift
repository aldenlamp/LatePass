//
//  AllItemsController.swift
//  sidebar test
//
//  Created by alden lamp on 3/2/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import UIKit

class AllItemsController: UIViewController, HistoryTableViewDelegate, UITextFieldDelegate {
    
    let historyTableView = HistoryTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setUpNavigation()
//        setUpTitle()
        setUpSearchBar()
        setUpTableView()
        
    }
    
    //MARK: - Navigation Functions
    
    var titleLabelView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.textColor = UIColor.textColor
        label.font = UIFont(name: "Avenir-Black", size: 20)
        label.text = "All History"
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
        
    }
    
    @objc func openSideBar(){
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.toggleMenu.rawValue), object: self))
    }
    
    //MARK: - Title

    //Currently not using title but imma keep it here in case I change my mind
//    let titleLabel : UILabel = {
//        let label = UILabel()
//        label.font = UIFont(name: "Avenir-Light", size: 22)
//        label.textColor = UIColor.textColor
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        label.widthAnchor.constraint(equalToConstant: 190).isActive = true
//        return label
//    }()
//
//    func setUpTitle(){
//        titleLabel.text = firebaseData.currentUser.userName//"All History"
//        self.view.addSubview(titleLabel)
//        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 73).isActive = true
//        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
//    }
    
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
        searchResult.text = "\(firebaseData.allItems.count)"
        
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
        searchView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 64).isActive = true
        searchView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        searchView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField){
        historyTableView.filterString = textField.text!.lowercased()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - History Table View Functions
    
    private func setUpTableView(){
        self.view.addSubview(historyTableView)
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        historyTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        historyTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        historyTableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0).isActive = true
        
        historyTableView.infoArray = firebaseData.allItems
        historyTableView.historyDelegate = self
        
//      ??? Why did i have this
//        if firebaseData.allItems.isEmpty{
//            historyTableView.infoArray = firebaseData.allItems
//        }else{
//
//        }
    }
    
    
    func historyTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with historyData: HistoryData) {
        let vc = ExpandedCellTeacher()
        vc.historyData = historyData
        print("ExpandedCellID: \(historyData.ID)")
        
        vc.titleLabel.text = historyData.toStringReadable()
        vc.dateLabel.text = historyData.getDateString()
        self.present(vc, animated: true, completion: nil)
    }
    
    func searchDidFinish(withCount count: Int) {
        searchResult.text = "\(count)"
    }
    
    
}

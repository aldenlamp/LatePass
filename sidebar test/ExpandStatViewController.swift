//
//  ExpandStatViewController.swift
//  sidebar test
//
//  Created by alden lamp on 4/20/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

class ExpandStatViewController: UIViewController, HistoryTableViewDelegate, UITextFieldDelegate, ExpandedViewControllerDelegate{
    
    let historyTableView = HistoryTableView()
    
    var historyData: [HistoryData]!
    var titleString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        expandVC.delegate = self
        
        setUpNavigation()
        setUpTitle()
        setUpSearchBar()
        setUpTableView()
        
    }
    
    //MARK: - Navigation
    
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
        
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        backView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Back"
        label.font = UIFont(name: "Avenir-Book", size: 21)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.textColor
        
        backView.addSubview(label)
        label.widthAnchor.constraint(equalTo: backView.widthAnchor, multiplier: 1).isActive = true
        label.heightAnchor.constraint(equalTo: backView.heightAnchor, multiplier: 1).isActive = true
        label.centerYAnchor.constraint(equalTo: backView.centerYAnchor, constant: 0).isActive = true
        label.centerXAnchor.constraint(equalTo: backView.centerXAnchor, constant: 0).isActive = true
        
        
        
        
        let backBut = UIBarButtonItem(customView: backView)
        
        //TODO: - Make a left bar button to go back
//        navigationItem.setLeftBarButton(backBut, animated: false)
        
//        navigationController?.navigationBar.backItem?.backBarButtonItem = backBut
        
    }
    
    
    //MARK: - Title
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Light", size: 22)
        label.textColor = UIColor.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    func setUpTitle(){
        titleLabel.text = firebaseData.currentUser.userName//"All History"
        self.view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 95).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        titleLabel.text = titleString
    }
    
    
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
        searchResult.text = "\(historyData.count)"
        
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
        searchView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 40).isActive = true
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
    
    let expandVC = ExpandedCellTeacher()
    
    private func setUpTableView(){
        self.view.addSubview(historyTableView)
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        historyTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        historyTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        historyTableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0).isActive = true
        
        historyTableView.infoArray = historyData
        historyTableView.historyDelegate = self
    }
    
    var isExpanded = false
    
    func historyTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with historyData: HistoryData) {
        
        expandVC.update(from: historyData)
        print("ExpandedCellID: \(historyData.ID)")
        
//        vc.titleLabel.text = historyData.toStringReadable()
//        vc.dateLabel.text = historyData.getDateString()
        
        if !isExpanded{
            self.present(expandVC, animated: true, completion: nil)
            isExpanded = true
        }
        
    }
    
    func willDismiss() {
         isExpanded = false
    }
    
    func searchDidFinish(withCount count: Int) {
        searchResult.text = "\(count)"
    }
    
    
}

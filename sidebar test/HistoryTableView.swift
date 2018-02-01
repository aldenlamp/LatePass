//
//  HistoryTableView.swift
//  sidebar test
//
//  Created by alden lamp on 1/26/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

protocol HistoryTableViewDelegate{
    func historyTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with historyData: HistoryData)
}
class HistoryTableView: UIView, UITableViewDelegate, UITableViewDataSource{
    
    //The historyTableView is on the shadowView to create a shadow on the keyView
    private let historyTableView = UITableView()
    private let shadowView = UIView()
    private let keyView = UIView()
    
    var historyDelegate: HistoryTableViewDelegate!
    
    var infoArray = [HistoryData]() {
        didSet{
            historyTableView.reloadData()
        }
    }
    
    func start(){
        setUpKey()
        setUpTableView()
    }
    
    var tableViewIsHidden = false {
        willSet{
            historyTableView.isHidden = newValue
        }
    }
    
    //MARK: - Key
    private func setUpKey(){
        keyView.frame = CGRect(x: 0, y: 230, width: self.frame.width, height: 50)
        
        self.addSubview(keyView)
        
        keyView.backgroundColor = UIColor.white
        
        keyView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        keyView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        keyView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        keyView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        keyView.translatesAutoresizingMaskIntoConstraints = false
        
        keyView.layer.borderColor = UIColor.white.cgColor
        keyView.layer.borderWidth = 0
        keyView.layer.shadowColor = UIColor.lightGray.cgColor
        keyView.layer.shadowOffset = CGSize(width: 1, height: -2)
        keyView.layer.shadowRadius = 1
        keyView.layer.shadowOpacity = 0.3
        
        let approved = makeKeyView(key: 0)
        approved.tag = 0
        let pending = makeKeyView(key: 1)
        let declined = makeKeyView(key: 2)
        
        let stackView = UIStackView(arrangedSubviews: [approved, pending, declined])
        stackView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 20)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        keyView.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: keyView.leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: keyView.rightAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: keyView.bottomAnchor, constant: -15).isActive = true
        stackView.topAnchor.constraint(equalTo: keyView.topAnchor, constant: 15).isActive = true
    }
    
    private func makeKeyView(key: Int) -> UIView{
        let imageView = UIImageView()
        let title = UILabel()
        
        switch(key){
        case 0:
            imageView.image = #imageLiteral(resourceName: "approved-lightGrey")
            title.text = "Approved"
        case 1:
            imageView.image = #imageLiteral(resourceName: "pending-grey")
            title.text = "Pending"
        case 2:
            imageView.image = #imageLiteral(resourceName: "rejected-grey")
            title.text = "Declined"
        default: break
        }
        
        let view = UIView(frame: CGRect(x: 200, y: 210, width: 95, height: 20))
        view.addSubview(imageView)
        view.addSubview(title)
        
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        title.adjustsFontSizeToFitWidth = true
        title.frame = CGRect(x: 0, y: 0, width: 61, height: 20)
        title.font = UIFont(name: "Avenir-Medium", size: 14)
        title.textColor = UIColor(hex: "435575", alpha: 1)
        title.textAlignment = .left
        
        title.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        title.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        
        NSLayoutConstraint(item: title, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1.0, constant: 10.0).isActive = true
        
        return view
    }
    
    //MARK: - TableView
    
    
    private func setUpTableView(){
        shadowView.addSubview(historyTableView)
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.borderColor = UIColor.white.cgColor
        shadowView.layer.borderWidth = 0
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: -2)
        shadowView.layer.shadowRadius = 1
        shadowView.layer.shadowOpacity = 0.3
        
        self.addSubview(shadowView)
        
        shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        shadowView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        shadowView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        NSLayoutConstraint(item: shadowView, attribute: .top, relatedBy: .equal, toItem: keyView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
//        historyTopAnchor = historyTableView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 0)
//        historyBottomAnchor = historyTableView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 0)
//        historyLeftAnchor = historyTableView.leftAnchor.constraint(equalTo: shadowView.leftAnchor, constant: 0)
//        historyRightAnchor = historyTableView.rightAnchor.constraint(equalTo: shadowView.rightAnchor, constant: 0)
        historyTableView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 0).isActive = true
        historyTableView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 0).isActive = true
        historyTableView.leftAnchor.constraint(equalTo: shadowView.leftAnchor, constant: 0).isActive = true
        historyTableView.rightAnchor.constraint(equalTo: shadowView.rightAnchor, constant: 0).isActive = true
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        historyTableView.register(HistoryCell.self, forCellReuseIdentifier: "Cell")
        
//        historyTableView.removeFromSuperview()
    }
    
//    var tableViewIsShown = false
    
//    func tableViewExists(){
//        if !tableViewIsShown && firebaseData.allItems.count > 0{
//
//            shadowView.addSubview(historyTableView)
//            setHistoryAnchors(to: true)
//
//            tableViewIsShown = !tableViewIsShown
//        }else if tableViewIsShown && firebaseData.allItems.count == 0{
//
//            setHistoryAnchors(to: false)
//            historyTableView.removeFromSuperview()
//            tableViewIsShown = !tableViewIsShown
//        }
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 90 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryCell
        let historyData = infoArray[indexPath.row]
        cell.updateWithHistoryData(data: historyData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HistoryCell
        cell.setSelected(false, animated: true)
        
        let data = infoArray[indexPath.row]
        
        historyDelegate.historyTableView(tableView, didSelectRowAt: indexPath, with: data)
        
//        let cell = tableView.cellForRow(at: indexPath) as! HistoryCell
//        cell.setSelected(false, animated: true)
//
//        let data = firebaseData.allItems[indexPath.row]
//
//
//        // Creating the new cell with attributes
//        let vc = ExpandedCell()
//        vc.historyData = data
//        vc.titleLabel.text = cell.titleLabel.text
//        vc.dateLabel.text = cell.dateLabel.text
    }
    
    
    
}

//
//  HistoryTableView.swift
//  sidebar test
//
//  Created by alden lamp on 1/26/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

protocol HistoryTableViewDelegate: class{
    func historyTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with historyData: HistoryData)
    func searchDidFinish(withCount count: Int)
}
class HistoryTableView: UIView, UITableViewDelegate, UITableViewDataSource{
    
    //The historyTableView is on the shadowView to create a shadow on the keyView
    private let historyTableView = UITableView()
    private let shadowView = UIView()
    private let keyView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private let simpleLabel = UILabel()
    
    //For scrolling through the recent items
    private var highlightedIndex = -1
    private var didReload = false
    
    weak var historyDelegate: HistoryTableViewDelegate?
    
    //In order to search the historyItems
    public var filterString = ""{
        didSet{
            filterItems()
        }
    }
    private var filteredInfoArray = [HistoryData]()
    private var resultCount = 0
    
    var infoArray = [HistoryData]() {
        didSet{
            didReload = true
            filterItems()
            simpleLabel.isHidden = !infoArray.isEmpty
            historyTableView.reloadData()
            tableViewIsHidden = infoArray.isEmpty
            stopActivityIndicator()
            clearHighlights()
        }
    }
    
    deinit{
        print("History Table View did DeInit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpKey()
        setUpTableView()
        setUpActivityIndicator()
        setUpNoHistory()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var animateActivityIndicator: Bool = false{
        willSet{
            if newValue{
                self.startActivityIndicator()
            }else{
                self.stopActivityIndicator()
            }
        }
    }
    
    var tableViewIsHidden = false {
        willSet{
            historyTableView.isHidden = newValue
            self.animateActivityIndicator = newValue
        }
    }
    
    
    //MARK: - Activity Indicator
    
    private func setUpActivityIndicator(){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor(hex: "55596B", alpha: 1)
        activityIndicator.sizeThatFits(CGSize(width: 100, height: 100))
        
        addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: keyView.bottomAnchor, constant: 40).isActive = true
    }
    
    private func startActivityIndicator(){
        if !activityIndicator.isAnimating{
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    
    private func stopActivityIndicator(){
        if activityIndicator.isAnimating{
            activityIndicator.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
    
    
    //MARK: - No History

    private func setUpNoHistory(){
        simpleLabel.text = "No New Notifications"
        simpleLabel.font = UIFont(name: "Avenir-Book", size: 19)
        simpleLabel.textColor = UIColor(hex: "435575", alpha: 1)
        simpleLabel.adjustsFontSizeToFitWidth = true
        simpleLabel.textAlignment = .center

        simpleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(simpleLabel)
        simpleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        simpleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        simpleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        simpleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 100).isActive = true
        simpleLabel.isHidden = true
        historyTableView.isHidden = true
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
    
    //MARK: - Search Table View Functions
    
    func filterItems(){
        filteredInfoArray.removeAll()
        resultCount = 0
        if self.filterString == ""{
            historyTableView.reloadData()
            resultCount = infoArray.count
        }else{
            for i in infoArray{
                if i.origin.userName.lowercased().contains(filterString) ||  i.student.userName.lowercased().contains(filterString) ||  i.reason.lowercased().contains(filterString) || (i.destination != nil && (i.destination?.userName.lowercased().contains(filterString))!){
                    
                    filteredInfoArray.append(i)
                    resultCount += 1
                }
            }
            historyTableView.reloadData()
        }
        historyDelegate?.searchDidFinish(withCount: resultCount)
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
        
        historyTableView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 0).isActive = true
        historyTableView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 0).isActive = true
        historyTableView.leftAnchor.constraint(equalTo: shadowView.leftAnchor, constant: 0).isActive = true
        historyTableView.rightAnchor.constraint(equalTo: shadowView.rightAnchor, constant: 0).isActive = true
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        historyTableView.register(HistoryCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func highlightObject(data: HistoryData) -> Bool{
        
        guard let index = infoArray.index(of: data) else{
            return false
        }
        let indexPath = IndexPath(row: Int(index), section: 0)
        
        guard let cell = historyTableView.cellForRow(at: indexPath) as? HistoryCell else{
            return false
        }
        
        if !didReload{
            clearHighlights()
        }
        
        didReload = false
        
        cell.shouldHighlight = true
        highlightedIndex = Int(index)
        return true
    }
    
    func clearHighlights(){
        if highlightedIndex == -1{ return }
        
        let indexPath = IndexPath(row: highlightedIndex, section: 0)
        
        guard let cell = historyTableView.cellForRow(at: indexPath) as? HistoryCell else{ return }
        
        cell.shouldHighlight = false
        highlightedIndex = -1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !filteredInfoArray.isEmpty{
            return filteredInfoArray.count
        }else{
            return infoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 90 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryCell
        cell.setSelected(false, animated: true)
        let historyData: HistoryData
        if !filteredInfoArray.isEmpty{
            historyData = filteredInfoArray[indexPath.row]
        }else{
            historyData = infoArray[indexPath.row]
        }
        
        cell.createCellWith(data: historyData)
        
        cell.selectionStyle = .none
        cell.isHighlighted = false
        
//
//
        if indexPath.row == highlightedIndex{
            cell.shouldHighlight = true
        }else{
            cell.shouldHighlight = false
        }
//
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! HistoryCell
        cell.setSelected(false, animated: true)
        
        let historyData: HistoryData
        if !filteredInfoArray.isEmpty{
            historyData = filteredInfoArray[indexPath.row]
        }else{
            historyData = infoArray[indexPath.row]
        }
        
        historyDelegate?.historyTableView(tableView, didSelectRowAt: indexPath, with: historyData)
    }
    
    
    
}

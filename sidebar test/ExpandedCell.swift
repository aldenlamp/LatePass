//
//  ExpandedCell.swift
//  sidebar test
//
//  Created by alden lamp on 9/22/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit

class ExpandedCell: UIViewController {
    
    var historyData: HistoryData!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setUpCancelButton()
        setUpTitleLabels()
        setUpInfoDisplay()
    }
    
    //MARK: - Title Label
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "Avenir-Light", size: 22)
        titleLabel.textColor = UIColor(hex: "3D4C68", alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return titleLabel
    }()
    
    let dateLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "Avenir-Light", size: 22)
        titleLabel.textColor = UIColor(hex: "3D4C68", alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        titleLabel.text = "May 23, 2017"
        return titleLabel
    }()
    
    let breakView: UIView = {
        let breakView = UIView()
        breakView.backgroundColor = UIColor(hex: "79D6DC", alpha: 1)
        breakView.translatesAutoresizingMaskIntoConstraints = false
        breakView.widthAnchor.constraint(equalToConstant: 92).isActive = true
        breakView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return breakView
    }()
    
    func setUpTitleLabels(){
        self.view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 73).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
//        dateLabel.text = "" //Change Later
        self.view.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        self.view.addSubview(breakView)
        breakView.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 17).isActive = true
        breakView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    }
    
    //MARK: - Cancel Button
    func setUpCancelButton(){
        let button = UIButton()
        button.image(for: .normal)
        button.setImage(#imageLiteral(resourceName: "icons8-delete_sign_filled"), for: .normal)
        button.frame = CGRect(x: 28, y: 41, width: 21, height: 21)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc private func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //TODO: - Make the bottom view
    
    //TODO: - Make the approved rejected view
    
    //TODO: - Allow pending passes to be accepted or rejceted
    
    var infoDisplay: UIView = UIView()
    
    func setUpInfoDisplay(){
        let timeRequested = getTimeView(fromAccepted: false)
        let timeApproved = getTimeView(fromAccepted: true)
        let reasonView = getReasonView()
        
        reasonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        timeApproved.bottomAnchor.constraint(equalTo: reasonView.topAnchor, constant: 0).isActive = true
        timeRequested.bottomAnchor.constraint(equalTo: timeApproved.topAnchor, constant: 0).isActive = true
    }
    
    
    func getTimeView(fromAccepted style: Bool) -> UIView{
        //height = 60
        //distToSide = 45
        
        let timeView = UIView()
        self.view.addSubview(timeView)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        timeView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45).isActive = true
        timeView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 45).isActive = true
        
        let timeIdentifier = UILabel()
        timeIdentifier.text = style ? "Time Approved" : "Time Requested"
        timeIdentifier.font = UIFont(name: "Avenir-Medium", size: 15)
        timeIdentifier.textColor = UIColor(hex: "3D4C68", alpha: 1)
        timeIdentifier.textAlignment = .left
        
        timeView.addSubview(timeIdentifier)
        timeIdentifier.translatesAutoresizingMaskIntoConstraints = false
        timeIdentifier.heightAnchor.constraint(equalToConstant: 60).isActive = true
        timeIdentifier.centerYAnchor.constraint(equalTo: timeView.centerYAnchor, constant: 0).isActive = true
        timeIdentifier.leftAnchor.constraint(equalTo: timeView.leftAnchor, constant: 0).isActive = true
        
        let time = UILabel()
        time.text = getTimeString(fromAccepted: style)
        time.textColor = UIColor(hex: "3D4C68", alpha: 1)
        time.font = UIFont(name: "Avenir-Medium", size: 16)
        time.textAlignment = .right
        time.adjustsFontSizeToFitWidth = true
    
        timeView.addSubview(time)
        time.translatesAutoresizingMaskIntoConstraints = false
        time.heightAnchor.constraint(equalToConstant: 60).isActive = true
        time.rightAnchor.constraint(equalTo: timeView.rightAnchor, constant: 0).isActive = true
        time.leftAnchor.constraint(equalTo: timeView.leftAnchor, constant: 115).isActive = true
        time.centerYAnchor.constraint(equalTo: timeView.centerYAnchor, constant: 0).isActive = true
    
        let sep = UIView()
        sep.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        
        timeView.addSubview(sep)
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        sep.rightAnchor.constraint(equalTo: timeView.rightAnchor, constant: 0).isActive = true
        sep.leftAnchor.constraint(equalTo: timeView.leftAnchor, constant: 0).isActive = true
        sep.bottomAnchor.constraint(equalTo: timeView.bottomAnchor, constant: 0).isActive = true
        
        return timeView
    }
    
    func getReasonView() -> UIView{
        
        let reasonView = UIView()
        
        self.view.addSubview(reasonView)
        reasonView.translatesAutoresizingMaskIntoConstraints = false
        
        let reasonIdentifier = UILabel()
        reasonIdentifier.text = "Reason"
        reasonIdentifier.font = UIFont(name: "Avenir-Medium", size: 15)
        reasonIdentifier.textColor = UIColor(hex: "3D4C68", alpha: 1)
        reasonIdentifier.textAlignment = .left
        
        reasonView.addSubview(reasonIdentifier)
        reasonIdentifier.translatesAutoresizingMaskIntoConstraints = false
        reasonIdentifier.topAnchor.constraint(equalTo: reasonView.topAnchor, constant: 15).isActive = true
        reasonIdentifier.leftAnchor.constraint(equalTo: reasonView.leftAnchor, constant: 0).isActive = true
        
        let reason = UILabel()
        reason.text = historyData.reason == "" ? "..." : historyData.reason
//        reason.text = "THIS IS A REALLY LONG MESSAGE IN ORDDER TO TEST THINGS"
        reason.textColor = UIColor(hex: "3D4C68", alpha: 1)
        reason.font = UIFont(name: "Avenir-Medium", size: 16)
        reason.textAlignment = .right
        reason.numberOfLines = 3
        
        let maxSize = CGSize(width: self.view.frame.width - (90), height: CGFloat.greatestFiniteMagnitude)
        let requiredSize = reason.sizeThatFits(maxSize)
        print(requiredSize.height)
        
        reasonView.addSubview(reason)
        reason.translatesAutoresizingMaskIntoConstraints = false
        reason.topAnchor.constraint(equalTo: reasonView.topAnchor, constant: 15).isActive = true
        reason.rightAnchor.constraint(equalTo: reasonView.rightAnchor, constant: 0).isActive = true
        reason.widthAnchor.constraint(equalToConstant: (self.view.frame.width - (90) - 100)).isActive = true
        
        
        reasonView.heightAnchor.constraint(equalToConstant: requiredSize.height + 50).isActive = true
        reasonView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45).isActive = true
        reasonView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 45).isActive = true
        
        
        /*
         
         */
        
        
//        timeView.addSubview(reason)
//        reason.translatesAutoresizingMaskIntoConstraints = false
//        reason.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        reason.rightAnchor.constraint(equalTo: timeView.rightAnchor, constant: 0).isActive = true
//        reason.centerYAnchor.constraint(equalTo: timeView.centerYAnchor, constant: 0).isActive = true
        
        
        
        /*
         cell.firstLabel.text = keys[indexPath.row]
         cell.firstLabel.frame = firstViewHeight(indexPath: indexPath)
         cell.firstVie.frame.size = CGSize(width: firstViewHeight(indexPath: indexPath).width, height: firstViewHeight(indexPath: indexPath).height)// + 16)
         cell.constraint.constant = firstViewHeight(indexPath: indexPath).height
         cell.summaryLabel.frame = caluclateSummaryLabelFrame(cell: cell, indexPath: indexPath)
         cell.summaryLabel.text = values[indexPath.row]
         */
        return reasonView
    }
    
    
    
    
    
    func getTimeFrom(fromAccepted style: Bool) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm "
        let timeInterval = TimeInterval(historyData.timeStarted)
        return formatter.string(from: Date(timeIntervalSince1970: timeInterval))
    }
    
    func getTimeString(fromAccepted style: Bool) -> String{
        if style && historyData.timeCompleted == nil{
            return "..."
        }
        let date = Date(timeIntervalSince1970: TimeInterval((style ? historyData.timeCompleted : historyData.timeStarted)!))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        var hour = Int(formatter.string(from: date))!
        if (hour > 12){
            hour -= 12
        }
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = ":mm a"
        
        return "\(hour)\(formatter.string(from: date))"
    }
    
    
}





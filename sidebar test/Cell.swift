//
//  Cell.swift
//  sidebar test
//
//  Created by alden lamp on 11/22/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import Foundation
import UIKit


class Cell{
    var ID: String!
    var destination: String?
    var origin: String?
    var student: String?
    var timeStarted: Int?
    var timeCompleted: Int?
    var reason: String?
    var status: acceptedStatus?
    var thisCellType: cellTypes!
    var thisTimeFrame: timeFrames!
    
    func initData(ID: String, origin: String, destination: String, student: String, timeStarted: Int, timeCompleted: Int?, reason: String, status: acceptedStatus, cellType: cellTypes){
        self.origin = origin
        self.destination = destination
        self.student = student
        self.timeStarted = timeStarted
        self.timeCompleted = timeCompleted
        self.status = status
        self.reason = reason
        self.thisCellType = cellType
        if isThis(timeFrame: "week", timeInterval: Double(timeStarted)){
            thisTimeFrame = .thisWeek
        }else if isThis(timeFrame: "month", timeInterval: Double(timeStarted)){
            thisTimeFrame = .thisMonth
        }else{
            thisTimeFrame = .thisYear
        }
        self.ID = ID
        
    }
    
    func toHistoryCell() -> HistoryCell{
        let historyCell = HistoryCell()
        switch thisCellType {
        case .studentHistory:
            historyCell.setUpCell(titleLabel: "\(String(describing: origin!)) to \(String(describing: destination!))", status: status!, unixDate: timeStarted!, cell: self, thisTimeFrame: thisTimeFrame)
        case .toHistory:
            historyCell.setUpCell(titleLabel: "\(String(describing: student!)) will be late", status: status!, unixDate: timeStarted!, cell: self, thisTimeFrame: thisTimeFrame)
        case .fromHistory:
            historyCell.setUpCell(titleLabel: "\(String(describing: student!)) left late", status: status!, unixDate: timeStarted!, cell: self, thisTimeFrame: thisTimeFrame)
        case .request:
            historyCell.setUpCell(titleLabel: "\(String(describing: student!)) requests a latepass", status: status!, unixDate: timeStarted!, cell: self, thisTimeFrame: thisTimeFrame)
        default: print("something went wrong")
        }
        return historyCell
    }
    
    //MARK: - Date related functions
    
    // returns true for
    func isThis(timeFrame: String, timeInterval: Double) -> Bool{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let realDate = NSDate(timeIntervalSince1970: timeInterval)
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let date1 = NSDate(timeIntervalSinceNow: 0)
        let calenderUnit = timeFrame == "week" ? NSCalendar.Unit.weekOfYear : NSCalendar.Unit.month
        let weekOfYear1 = calendar!.component(calenderUnit, from: realDate as Date)
        let weekOfYear2 = calendar!.component(calenderUnit, from: date1 as Date)
        let year1 = calendar!.component(NSCalendar.Unit.year, from: date1 as Date)
        let year2 = calendar!.component(NSCalendar.Unit.year, from: realDate as Date)
        if weekOfYear1 == weekOfYear2 && year1 == year2 {
            return true
        } else {
            return false
        }
        
    }
}



class HistoryCell: UITableViewCell{
    let iconImage = UIImageView()
    var dateLabel = UILabel()
    var timeLabel = UILabel()
    var titleLabel = UILabel()
    var thisTimeFrame: timeFrames!
    var cell: Cell!
    
    func setUpCell(titleLabel: String, status: acceptedStatus, unixDate: Int, cell: Cell, thisTimeFrame: timeFrames){
        self.cell = cell
        dateLabel.text = getDateString(unix: Double(unixDate)/1000.0)
        timeLabel.text = getTimeString(unix: Double(unixDate)/1000.0)
        self.titleLabel.text = titleLabel
        //        iconImage.image = #imageLiteral(resourceName: "approved-lightBlue")
        
        
        
        //
        switch status {
        case .accepted:
            
            switch thisTimeFrame{
            case .thisWeek:
                iconImage.image = #imageLiteral(resourceName: "approved-lightBlue")
                break
            case .thisMonth:
                iconImage.image = #imageLiteral(resourceName: "approved-purple")
                break
            case .thisYear:
                iconImage.image = #imageLiteral(resourceName: "approved-blue")
                break
            }
        case .pending:
            iconImage.image = #imageLiteral(resourceName: "pending-lightBlue")
            break
        case .rejected:
            iconImage.image = #imageLiteral(resourceName: "rejected-red")
            break
        }
        
        self.contentView.addSubview(iconImage)
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        let imSize: CGFloat = iconImage.image != #imageLiteral(resourceName: "pending-lightBlue") ? 45 : 40
        iconImage.widthAnchor.constraint(equalToConstant: imSize).isActive = true
        iconImage.heightAnchor.constraint(equalToConstant: imSize).isActive = true
        iconImage.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 22.5).isActive = true
        //        iconImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -22.5).isActive = true
        iconImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 30).isActive = true
        
        let textView = addTextView()
        self.contentView.addSubview(textView)
        
        NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: iconImage, attribute: .right, multiplier: 1, constant: 35).isActive = true
        textView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 51).isActive = true
        textView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20).isActive = true
    }
    
    //MARK: - Setting up view
    
    func addTextView() -> UIView{
        
        let finalView = UIView()
        finalView.translatesAutoresizingMaskIntoConstraints = false
        finalView.frame = CGRect(x: 0, y: 0, width: 300, height: 51)
        finalView.addSubview(titleLabel)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: finalView.leftAnchor, constant: 0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: finalView.topAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: finalView.rightAnchor, constant: 0).isActive = true
        
        titleLabel.textColor = UIColor(hex: "55596B", alpha: 1)
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 19)
        
        
        let dateView = UIView()
        dateView.translatesAutoresizingMaskIntoConstraints = false
        
        dateView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        dateView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let dateIcon = UIImageView()
        dateIcon.translatesAutoresizingMaskIntoConstraints = false
        dateIcon.image = #imageLiteral(resourceName: "dateIcon")
        dateIcon.heightAnchor.constraint(equalToConstant: 19).isActive = true
        dateIcon.widthAnchor.constraint(equalToConstant: 17).isActive = true
        
        dateView.addSubview(dateIcon)
        
        dateIcon.topAnchor.constraint(equalTo: dateView.topAnchor, constant: 0.5).isActive = true
        dateIcon.bottomAnchor.constraint(equalTo: dateView.bottomAnchor, constant: -0.5).isActive = true
        dateIcon.leftAnchor.constraint(equalTo: dateView.leftAnchor, constant: 0).isActive = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = UIColor(hex: "55596B", alpha: 1)
        dateLabel.font = UIFont(name: "Avenir-Medium", size: 15)
        
        dateView.addSubview(dateLabel)
        //        dateLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: dateView.rightAnchor, constant: 0).isActive = true
        dateLabel.topAnchor.constraint(equalTo: dateView.topAnchor, constant: 0).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 0).isActive = true
        
        NSLayoutConstraint(item: dateLabel, attribute: .left, relatedBy: .equal, toItem: dateIcon, attribute: .right, multiplier: 1, constant: 5).isActive = true
        
        
        let timeView = UIView()
        timeView.translatesAutoresizingMaskIntoConstraints = false
        
        //        timeView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        timeView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let timeIcon = UIImageView()
        timeIcon.translatesAutoresizingMaskIntoConstraints = false
        timeIcon.image = #imageLiteral(resourceName: "timeIcon")
        timeIcon.heightAnchor.constraint(equalToConstant: 19).isActive = true
        timeIcon.widthAnchor.constraint(equalToConstant: 19).isActive = true
        
        timeView.addSubview(timeIcon)
        
        timeIcon.topAnchor.constraint(equalTo: timeView.topAnchor, constant: 0.5).isActive = true
        timeIcon.bottomAnchor.constraint(equalTo: timeView.bottomAnchor, constant: -0.5).isActive = true
        timeIcon.leftAnchor.constraint(equalTo: timeView.leftAnchor, constant: 0).isActive = true
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = UIColor(hex: "55596B", alpha: 1)
        timeLabel.font = UIFont(name: "Avenir-Medium", size: 15)
        
        
        timeView.addSubview(timeLabel)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        
        //        timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: timeView.rightAnchor, constant: 0).isActive = true
        timeLabel.topAnchor.constraint(equalTo: timeView.topAnchor, constant: 0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: timeView.bottomAnchor, constant: 0).isActive = true
        
        NSLayoutConstraint(item: timeLabel, attribute: .left, relatedBy: .equal, toItem: timeIcon, attribute: .right, multiplier: 1, constant: 5).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [dateView, timeView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 6//CGFloat(width) - (timeView.frame.width + dateView.frame.width)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        finalView.addSubview(stackView)
        stackView.bottomAnchor.constraint(equalTo: finalView.bottomAnchor, constant: 0).isActive = true
        stackView.leftAnchor.constraint(equalTo: finalView.leftAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: finalView.rightAnchor, constant: 0).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 5).isActive = true
        
        return finalView
        
    }
    
    func getDateString(unix: Double) -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(unix))
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    func getTimeString(unix: Double) -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(unix))
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





class UserCell: UITableViewCell{
    //height = 58 - 68
    
    var userType: userType?
    var userName: String?
    var userID: String?
    var userEmail: String?
    var userImage: UIImage?
    
    var isChosen = true
    
    var containsSeparator = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let userImageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //        view.alpha = 0.7
        view.layer.cornerRadius = (45/2)
        view.layer.masksToBounds = true
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.widthAnchor.constraint(equalToConstant: 45).isActive = true
        return view
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        return label
    }()
    
    let userEmailLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir-Medium", size: 16)
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.heightAnchor.constraint(equalToConstant: 23).isActive = true
        return label
    }()
    
    let sep: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    func addSeparator(){
        if !containsSeparator{
            self.contentView.addSubview(sep)
            sep.leftAnchor.constraint(equalTo: userImageView.leftAnchor, constant: 0).isActive = true
            sep.rightAnchor.constraint(equalTo: userNameLabel.rightAnchor, constant: 0).isActive = true
        }
        containsSeparator = true
    }
    
    func setAlpha(userImageAlpha: Double){
        userImageView.alpha = CGFloat(userImageAlpha)
    }
    
    func setName(name: String){
        self.userName = name
        self.userNameLabel.text = name
    }
    
    func setEmail(email: String){
        self.userEmail = email
        self.userEmailLabel.text = email
    }
    
    func setimage(image: UIImage){
        self.userImage = image
        self.userImageView.image = image
    }
    
    func setBlankImage(){
        userImageView.image = #imageLiteral(resourceName: "BlankUser")
        userImage = #imageLiteral(resourceName: "BlankUser")
    }
    
    func setUpPotentialCell(type: userType, name: String, email: String){
        self.userName = name
        self.userEmail = email
        self.userType = type
        self.userImage = #imageLiteral(resourceName: "BlankUser")
        
        userImageView.image = #imageLiteral(resourceName: "BlankUser")
        userNameLabel.text = name
        userEmailLabel.text = email
        
        setUpView()
    }
    
    
    func setUpCell(id: String, type: userType, image: UIImage, name: String, email: String){//, containsSeparator: Bool, userImageAlpha: Double){
        
        userType = type
        userName = name
        userEmail = email
        userImage = image
        userID = id
        
        userImageView.image = userImage
        userNameLabel.text = name
        userEmailLabel.text = email
        
        setUpView()
    }
    
    func setUpView(){
        self.contentView.addSubview(userImageView)
        userImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
        userImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        
        self.contentView.addSubview(userNameLabel)
        userNameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20).isActive = true
        
        self.contentView.addSubview(userEmailLabel)
        userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 0).isActive = true
        userEmailLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8).isActive = true
        userEmailLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20).isActive = true
    }
    
    
}

//
//  HistoryCell.swift
//  sidebar test
//
//  Created by alden lamp on 11/23/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell{
    let iconImage = UIImageView()
    var dateLabel = UILabel()
    var timeLabel = UILabel()
    var titleLabel = UILabel()
    var thisTimeFrame: timeFrames!
    
    
    func updateWithHistoryData(data: HistoryData){
        
        switch data.thisCellType {
        case .studentHistory:
            setUpCell(titleLabel: "\(data.origin!) to \(String(describing: data.destination!))", status: data.status!, unixDate: data.timeStarted!, thisTimeFrame: data.thisTimeFrame)
            break
        case .toHistory:
            setUpCell(titleLabel: "\(String(describing: data.student!)) will be late", status: data.status!, unixDate: data.timeStarted!, thisTimeFrame: data.thisTimeFrame)
            break
        case .fromHistory:
            setUpCell(titleLabel: "\(String(describing: data.student!)) left late", status: data.status!, unixDate: data.timeStarted!, thisTimeFrame: data.thisTimeFrame)
            break
        case .request:
            setUpCell(titleLabel: "\(String(describing: data.student!)) requests a latepass", status: data.status!, unixDate: data.timeStarted!, thisTimeFrame: data.thisTimeFrame)
            break
        default: print("something went wrong")
        }
    }
    
    private func setUpCell(titleLabel: String, status: acceptedStatus, unixDate: Int, thisTimeFrame: timeFrames){
        dateLabel.text = getDateString(unix: Double(unixDate))
        timeLabel.text = getTimeString(unix: Double(unixDate))
        self.titleLabel.text = titleLabel
        timeLabel.adjustsFontSizeToFitWidth = true
        
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
        
        iconImage.widthAnchor.constraint(equalToConstant: 45).isActive = true
        iconImage.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        iconImage.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 22.5).isActive = true
        //        iconImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -22.5).isActive = true
        iconImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 30).isActive = true
        
        let textView = generateLabelView()
        self.contentView.addSubview(textView)
        
        NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: iconImage, attribute: .right, multiplier: 1, constant: 35).isActive = true
        textView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 51).isActive = true
        textView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20).isActive = true
    }
    
    //MARK: - Setting up view
    
    private func generateLabelView() -> UIView{
        
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



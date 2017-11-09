//
//  FirebaseData.swift
//  sidebar test
//
//  Created by alden lamp on 10/27/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum userType{
    case student
    case teacher
    case admin
}

var userTier: userType?

enum acceptedStatus{
    case accepted
    case rejected
    case pending
}

enum cellTypes{
    case request
    case toHistory
    case fromHistory
    case studentHistory
}

protocol FirebaseProtocol {
    func uesrDataDidLoad()
    func historyArrayDidLoad()
}

class FirebaseDataClass{
    var userID: String?
    var currentUser: UserCell?
    var firebaseDataDelegate: FirebaseProtocol!
    
    var historyItems = [Cell]()
    var requestItems = [Cell]()
    
    var allItemsSorte = [Cell]()
    
    init() {
        let ref = FIRDatabase.database().reference()
        
        guard let currUserID = FIRAuth.auth()?.currentUser?.uid else{
            print("user not logged in")
            NotificationCenter.default.post(Notification(name: ReturnToLoginNotificationName))
            return
        }
        userID = currUserID
        
        let thisUserRef = ref.child("users").child(userID!)
        
        
        
        
        
        // Needed to set up a user cell: id, name, email, image, userType
        thisUserRef.observe(.value, with: { [weak self] (snapshot) in
            var data = snapshot.value as! [String: Any]
            
            print(data["history"])
            
            
            let name = data["name"] as! String
            let email = data["name"] as! String
            
            let tierNum = data["tier"] as! Int
            var tier = userType.student
            switch(data["tier"] as! Int){
            case 0: tier = .student
            case 1: tier = .teacher
            case 2: tier = .admin
            default: tier = .student
            }
            
            let photoID = data["photoURL"] as! String
            var image = UIImage()
            do{
                try image = UIImage(data: Data(contentsOf: URL(string: photoID)!))!
            }catch{
                print("\n\n\n\n\nimage Failed\n\n\n\n")
            }
            
            self?.currentUser = UserCell()
            self?.currentUser!.setUpCell(id: self!.userID!, type: tier, image: image, name: name, email: email)
            self?.firebaseDataDelegate.uesrDataDidLoad()
            
            }, withCancel: {(error) in
                print(error)
        })
        
        
        
        //getting the history item and request items
        
        
        thisUserRef.child("history").observe(.value, with: {(snapshot) in
            if snapshot.exists(){
                let values = snapshot.value as! [String : String]
                let historyKeys = Array(values.keys)
                
                var historyCount = historyKeys.count
                
                // Increased when the data is pulled from the follwing users: Student, origin, destination
                // when all are equil to history keys.count * 2 (one is left out because of above), deleage data realoaded called
                var userCount = 0
                
                print(historyCount)
                
                for key in historyKeys{
                    let cell = Cell()
                    
                    // origin, destination, student, cellType, timeStart, timeEnd
                    //Get each item as a key
                    
                    ref.child("history").child(key).observe(.value, with: { [weak self] (snapshot) in
                        let historyValues = snapshot.value as! [String: Any]
                        
                        let originID = historyValues["origin"] as! String
                        let destinationID = historyValues["destination"] as! String
                        let studentID = historyValues["student"] as! String
                        
                        var originName: String? = ""
                        var destinationName: String? = ""
                        var studentName: String? = ""
                        
                        //finding the cell type by matching the uid to the person
                        var cellType: cellTypes = .studentHistory
                        if studentID != self?.userID{
                            if originID == self?.userID{
                                cellType = .fromHistory
                                originName = self?.currentUser?.userName
                            }else if destinationID == self?.userID{
                                cellType = .toHistory
                                destinationName = self?.currentUser?.userName
                            }else{
                                print("\n\nNO CELL TYPE\n\n")
                            }
                        }else{
                            studentName = self?.currentUser?.userName
                        }
                        
                        
                        //Getting the user names from the IDs to put into the cell
                        if cellType != .fromHistory{
                            ref.child("users").child(originID).child("name").observe(.value, with: { (originNameSnapshot) in
                                
                                // A check and alternate pull from the database is necessary in order to find potential users
                                // (those in our school who did not sign up)
                                // The key in this is not a UID it is the users' email
                                if originNameSnapshot.exists(){
                                    originName = originNameSnapshot.value as? String
                                    cell.origin = originName
                                    userCount += 1
                                    if userCount == historyKeys.count * 2{
                                        self?.firebaseDataDelegate.historyArrayDidLoad()
                                    }
                                }else{
                                    ref.child("potentialTeachers").child(originID).observe(.value, with: { (potentialOriginNameSnapshot) in
                                        originName = potentialOriginNameSnapshot.value as? String
                                        cell.origin = originName
                                        userCount += 1
                                        if userCount == historyKeys.count * 2{
                                            self?.firebaseDataDelegate.historyArrayDidLoad()
                                        }
                                    })
                                }
                            })
                        }
                        
                        if cellType != .toHistory{
                            ref.child("users").child(destinationID).child("name").observe(.value, with: { (destinationNameSnapshot) in
                                if destinationNameSnapshot.exists(){
                                    destinationName = destinationNameSnapshot.value as? String
                                    cell.destination = destinationName
                                    userCount += 1
                                    if userCount == historyKeys.count * 2{
                                        self?.firebaseDataDelegate.historyArrayDidLoad()
                                    }
                                }else{
                                    ref.child("potentialTeachers").child(destinationID).observe(.value, with: { (potentialDestinationNameSnapshot) in
                                        destinationName = potentialDestinationNameSnapshot.value as? String
                                        cell.destination = destinationName
                                        userCount += 1
                                        if userCount == historyKeys.count * 2{
                                            self?.firebaseDataDelegate.historyArrayDidLoad()
                                        }
                                    })
                                }
                            })
                        }
                        
                        if cellType != .studentHistory{
                            ref.child("users").child(studentID).child("name").observe(.value, with: { (studentNameSnapshot) in
                                if studentNameSnapshot.exists(){
                                    studentName = studentNameSnapshot.value as! String
                                    cell.student = studentName
                                    userCount += 1
                                    if userCount == historyKeys.count * 2{
                                        self?.firebaseDataDelegate.historyArrayDidLoad()
                                    }
                                }else{
                                    ref.child("potentialStudents").child(studentID).observe(.value, with: { (potentialStudentNameSnapshot) in
                                        studentName = potentialStudentNameSnapshot.value as? String
                                        cell.student = studentName
                                        userCount += 1
                                        if userCount == historyKeys.count * 2{
                                            self?.firebaseDataDelegate.historyArrayDidLoad()
                                        }
                                    })
                                }
                            })
                        }
                        
                        var status: acceptedStatus = .pending
                        
                        let statusInt = historyValues["status"] as! Int
                        switch(statusInt){
                        case 0: status = .rejected
                        case 2: status = .accepted
                        default: status = .pending
                        }
                        
                        let timeCreated = historyValues["time"] as! Int
                        let timeCompleted = historyValues["timeCompleted"] as? Int
                        
                        let reason = historyValues["reason"] as! String
                        cell.initData(origin: originName!, destination: destinationName!, student: studentName!, timeStarted: timeCreated, timeCompleted: timeCompleted, reason: reason, status: status, cellType: cellType)
                        
                        self?.historyItems.append(cell)
                        historyCount -= 1
                    })
                }
            }
        })
        
        thisUserRef.child("requests").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                
                
                
            }
        })
        
        
        
        
    }
}



class Cell{
    var destination: String?
    var origin: String?
    var student: String?
    var timeStarted: Int?
    var timeCompleted: Int?
    var reason: String?
    var status: acceptedStatus?
    var thisCellType: cellTypes!
    
    func initData(origin: String, destination: String, student: String, timeStarted: Int, timeCompleted: Int?, reason: String, status: acceptedStatus, cellType: cellTypes){
        self.origin = origin
        self.destination = destination
        self.student = student
        self.timeStarted = timeStarted
        self.timeCompleted = timeCompleted
        self.status = status
        self.reason = reason
        self.thisCellType = cellType
    }
    
    func toHistoryCell() -> HistoryCell{
        let historyCell = HistoryCell()
        switch thisCellType {
        case .studentHistory:
            historyCell.setUpCell(titleLabel: "\(String(describing: origin!)) to \(String(describing: destination!))", status: status!, unixDate: timeStarted!, cell: self)
        case .toHistory:
            historyCell.setUpCell(titleLabel: "\(String(describing: student!)) will be late", status: status!, unixDate: timeStarted!, cell: self)
        case .fromHistory:
            historyCell.setUpCell(titleLabel: "\(String(describing: student!)) left late", status: status!, unixDate: timeStarted!, cell: self)
        case .request:
            historyCell.setUpCell(titleLabel: "\(String(describing: student!)) requests a latepass", status: status!, unixDate: timeStarted!, cell: self)
        default: print("something went wrong")
        }
        return historyCell
    }
}



class HistoryCell: UITableViewCell{
    let iconImage = UIImageView()
    var dateLabel = UILabel()
    var timeLabel = UILabel()
    var titleLabel = UILabel()
    var cell: Cell!
    
    func setUpCell(titleLabel: String, status: acceptedStatus, unixDate: Int, cell: Cell){
        self.cell = cell
        dateLabel.text = getDateString(unix: Double(unixDate)/1000.0)
        timeLabel.text = getTimeString(unix: Double(unixDate)/1000.0)
        self.titleLabel.text = titleLabel
        
        switch status {
        case .accepted:
            if isThis(timeFrame: "week"){
                iconImage.image = #imageLiteral(resourceName: "approved-lightBlue")
                break
            }else if isThis(timeFrame: "month"){
                iconImage.image = #imageLiteral(resourceName: "approved-purple")
                break
            }else{
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
        timeLabel.adjustsFontSizeToFitWidth = true
        
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
    
    
    //MARK: - Date related functions
    
    func isThis(timeFrame: String) -> Bool{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let realDate = formatter.date(from: dateLabel.text!)
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        
        let date1 = NSDate(timeIntervalSinceNow: 0)
        
        let calenderUnit = timeFrame == "week" ? NSCalendar.Unit.weekOfYear : NSCalendar.Unit.month
        
        let weekOfYear1 = calendar!.component(calenderUnit, from: realDate!)
        let weekOfYear2 = calendar!.component(calenderUnit, from: date1 as Date)
        
        let year1 = calendar!.component(NSCalendar.Unit.year, from: date1 as Date)
        let year2 = calendar!.component(NSCalendar.Unit.year, from: realDate!)
        
        if weekOfYear1 == weekOfYear2 && year1 == year2 {
            return true
        } else {
            return false
        }
        
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
    //    var userImageAlpha: Double?
    
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
    
    func setUpCell(id: String, type: userType, image: UIImage, name: String, email: String){//, containsSeparator: Bool, userImageAlpha: Double){
        
        userType = type
        userName = name
        userEmail = email
        userImage = image
        userID = id
        
        userImageView.image = userImage
        userNameLabel.text = name
        userEmailLabel.text = email
        
        //        self.setAlpha(userImageAlpha: userImageAlpha)
        
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
        
        //        if containsSeparator{ addSeparator() }
    }
    
    
}

//
//  Cell.swift
//  sidebar test
//
//  Created by alden lamp on 11/22/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import Foundation
import UIKit


class HistoryData: Hashable{
    var hashValue: Int{
        get{
            return ID.hashValue
        }
    }
    
    static func == (lhs: HistoryData, rhs: HistoryData) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    static func == (lhs: HistoryData, rhs: String) -> Bool {
        return lhs.ID == rhs
    }
    
    var ID: String
//    var destination: String?
//    var origin: String
//    var student: String
    var destination: User?
    var origin: User
    var student: User
    var timeStarted: Int
    var timeCompleted: Int?
    var reason: String
    var status: acceptedStatus
    var thisCellType: cellTypes!
    var thisTimeFrame: timeFrames
    
    public var image: UIImage {
        get{
            switch status{
            case .accepted:
                switch thisTimeFrame {
                case .thisWeek:
                    return #imageLiteral(resourceName: "approved-lightBlue")
                case .thisMonth:
                    return #imageLiteral(resourceName: "approved-purple")
                case .thisYear:
                    return #imageLiteral(resourceName: "approved-blue")
                }
            case .pending:
                return #imageLiteral(resourceName: "pending-lightBlue")
            case .rejected:
                return #imageLiteral(resourceName: "rejected-red")
            }
        }
    }
    
    public init(ID: String, origin: User, destination: User?, student: User, timeStarted: Int, timeCompleted: Int?, reason: String, status: acceptedStatus, cellType: cellTypes){
        
        func isThis(timeFrame: String, timeInterval time: Int) -> Bool{
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let timeInterval = TimeInterval(time)
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
        
        self.origin = origin
        self.destination = destination
        self.student = student
        self.timeStarted = timeStarted
        self.timeCompleted = timeCompleted
        self.status = status
        self.reason = reason
        self.thisCellType = cellType
        if isThis(timeFrame: "week", timeInterval: timeStarted){
            thisTimeFrame = .thisWeek
        }else if isThis(timeFrame: "month", timeInterval: timeStarted){
            thisTimeFrame = .thisMonth
        }else{
            thisTimeFrame = .thisYear
        }
        
        self.ID = ID
    }    
    
    func toStringReadable() -> String{
        switch thisCellType! {
        case .studentHistory:   return "\(origin.userName) to \(destination?.userName ?? "..." )"
        case .toHistory:        return "\(student.userName) will be late"
        case .fromHistory:      return "\(student.userName) left late"
        case .request:          return "\(student.userName) requests a latepass"
        case .studentRequest:   return "\(student.userName) left late"
        }
    }
    
    func getDateString() -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(timeStarted))
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    func getTimeString(fromStarted started: Bool = true) -> String{
        let date: Date
        if !started{
            guard let tc = timeCompleted else{
                return "..."
            }
            date = Date(timeIntervalSince1970: TimeInterval(tc))
        }else{
            date = Date(timeIntervalSince1970: TimeInterval(timeStarted))
        }
        
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
    
    func isWithinTime() -> Bool{
        return Int(Date().timeIntervalSince1970) - self.timeStarted < (45 * 60)
    }
    
}



//
//  Cell.swift
//  sidebar test
//
//  Created by alden lamp on 11/22/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import Foundation
import UIKit


class HistoryData{
    var ID: String!
    var destination: String!
    var origin: String!
    var student: String!
    var timeStarted: Int!
    var timeCompleted: Int?
    var reason: String!
    var status: acceptedStatus!
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
        if isThis(timeFrame: "week", timeInterval: timeStarted){
            thisTimeFrame = .thisWeek
        }else if isThis(timeFrame: "month", timeInterval: timeStarted){
            thisTimeFrame = .thisMonth
        }else{
            thisTimeFrame = .thisYear
        }
        self.ID = ID
        
    }
    
   
    
    //MARK: - Date related functions
    
    // returns true for
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
}



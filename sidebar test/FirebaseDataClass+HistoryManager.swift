//
//  FirebaseDataClass+HistoryManager.swift
//  sidebar test
//
//  Created by alden lamp on 4/7/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation


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
    case studentRequest
}

enum timeFrames{
    case thisWeek
    case thisMonth
    case thisYear
}

extension FirebaseDataClass{
    
    //Sets filteredItems for data to be included on the home page
//    private func filteringHistoryData(){
//        let type: [cellTypes] = self.currentUser.userType == .student ? [cellTypes.studentHistory, cellTypes.studentRequest] : [cellTypes.toHistory, cellTypes.request]
//        var arr = [HistoryData]()
//        for i in allItems{
//            for j in type{
//                if i.thisCellType == j{
//                    arr.append(i)
//                    break
//                }
//            }
//        }
//        self.filteredItems = arr
//    }
    
    
    //For interall use only to see if data pull is messing up
    private func analyzeData(arr: [HistoryData]){
        
        var dict = [HistoryData : Int]()
        for i in arr{
            if let a = dict[i]{
                dict[i] = a + 1
            }else{
                dict[i] = 1
            }
        }
        
        for (key, value) in dict{
            if value > 1{
                print("\(key.ID)\t has \(value)\t coppies")
            }
        }
        print("FINISHED Total number of items: \(arr.count)")
        
        
    }
    
    private func historyCellsDidLoad(){
//        if fromHistory{
            isPullingHistory = false
//        }else{
//            isPullingRequest = false
//        }
//
//
//        self.allItems.removeAll()
//        allItems += historyItems

        if !allItems.isEmpty{
            historyQuickSort(lowerIndex: 0, higherIndex: firebaseData.allItems.count - 1)
            self.analyzeData(arr: allItems)
        }
        
//        if !isPullingRequest && !isPullingHistory{
            //TODO: - Maybe use a notification make sure the HOmeViewController tableView Reloads
            firebaseDataDelegate?.historyArrayDidLoad()
//        }
        
    }
    
    //quick sort for sorting the history items by time
    private func historyQuickSort(lowerIndex: Int, higherIndex: Int){
        var lower = lowerIndex
        var higher = higherIndex
        let pivot = firebaseData.allItems[lower + (higher - lower) / 2].timeStarted
        while(lower <= higher){
            while(firebaseData.allItems[lower].timeStarted > pivot){ lower += 1 }
            while(firebaseData.allItems[higher].timeStarted < pivot){ higher -= 1 }
            if lower <= higher{
                exchangeNumbers(lower: lower, higher: higher)
                lower += 1
                higher -= 1
            }
        }
        if lowerIndex < higher{ historyQuickSort(lowerIndex: lowerIndex, higherIndex: higher) }
        if lower < higherIndex{ historyQuickSort(lowerIndex: lower, higherIndex: higherIndex) }
    }
    
    func exchangeNumbers(lower: Int, higher: Int){
        let temp = firebaseData.allItems[lower]
        firebaseData.allItems[lower] = firebaseData.allItems[higher]
        firebaseData.allItems[higher] = temp
    }
    
    func getHistoryItems(){
        
        self.ref.child("users").child(userID).child("history").observe(.value, with: { [weak self] (snapshot) in
            
            if snapshot.exists(){//} && !(self?.isPullingHistory)!{
                //                self?.isPullingHistory = true
                //                self?.historyItems.removeAll()
                self?.isPullingHistory = true
                self?.allItems.removeAll()
                
                let values = snapshot.value as! [String : String]
                let historyKeys = Array(values.keys)
                print("values: \(historyKeys)")
                print("historyKeyCount: \(historyKeys.count)")
                // Increased when the data is pulled from the follwing users: Student, origin, destination
                // when all are equil to history keys.count * 2 (one is left out because of above), deleage data realoaded called
                var userCount = 0
                
                for key in historyKeys{
//                    let cell = HistoryData()
                    
                    // origin, destination, student, cellType, timeStart, timeEnd
                    //Get each item as a key
                    
                    self?.ref.child("history").child(key).observe(.value, with: { [weak self] (snapshot) in
                        if snapshot.exists(){
                            //This needs to be here in case the database changes at this level
                            //                            if !(self?.isPullingData)!{
                            //                                self?.reloadHistoryData()
                            //                                return
                            //                            }
                            
                            
                            
                            let historyValues = snapshot.value as! [String: Any]
                            
                            var status: acceptedStatus = .pending
                            
                            let statusInt = historyValues["status"] as! Int
                            switch(statusInt){
                            case 0: status = .rejected
                            case 2: status = .accepted
                            default: status = .pending
                            }
                            
                            let originID = (historyValues["origin"] as! String).replacingOccurrences(of: "%2E", with: ".")
                            let destinationID = (historyValues["destination"] as? String ?? "").replacingOccurrences(of: "%2E", with: ".")
                            let studentID = (historyValues["student"] as! String).replacingOccurrences(of: "%2E", with: ".")
                            
//                            let studentString: String
//                            let originString: String
//                            let destinationString: String
                            
                            
                            guard let student = self?.allStudents.userFrom(ID: studentID) else{
                                for _ in 0...5{
                                    print("STUDENT USER NAME FAILED")
                                }
                                return
                            }
                            
                            guard let origin = self?.allTeachers.userFrom(ID: originID) else{
                                for _ in 0...5{
                                    print("ORIGIN USER NAME FAILED")
                                }
                                return
                            }

                            let destination: User? = self?.allTeachers.userFrom(ID: destinationID)
                            
//                            guard let destination = self?.allTeachers.userFrom(ID: destinationID) else{
//                                for _ in 0...5{
//                                    print("DESTINATION USER NAME FAILED")
//                                }
//                                return
//                            }
                            
                            //Getting the name from the userID to put into the cell
//                            studentString = student.userName
//                            originString = origin.userName
//                            destinationString = destination.userName
                            
                            //finding the cell type by matching the uid to the person
                            var cellType: cellTypes = .studentHistory
                            if studentID != self?.userID{
                                if originID == self?.userID{
                                    cellType = status == .pending ? .request : .fromHistory
                                }else if destinationID == self?.userID{
                                    cellType = .toHistory
                                }
                            }                            
                            
                            let timeCreated = (historyValues["time"] as! Int) / 1000
                            var timeCompleted = historyValues["timeCompleted"] as? Int
                            if timeCompleted != nil { timeCompleted = timeCompleted! / 1000 }
                            
                            let reason = historyValues["reason"] as! String
                            let cell = HistoryData(ID: key, origin: origin, destination: destination, student: student, timeStarted: timeCreated, timeCompleted: timeCompleted, reason: reason, status: status, cellType: cellType)
                            
                            //makes sure that the pass is not a destination request
                            
                            if !(self?.currentUser.userType != .student && status == .pending && cellType == .toHistory){
                                if (self?.allItems.contains(cell))!{
                                    self?.allItems.remove(at: (self?.allItems.index(of: cell))!)
                                    
                                }
                                self?.allItems.append(cell)
                            }
                            userCount += 1
                            if userCount == historyKeys.count || !(self?.isPullingHistory)!{
                                self?.historyCellsDidLoad()
                            }
                        }
                    })
                    
                }
            }else{
                self?.allItems.removeAll()
                self?.historyCellsDidLoad()
            }
        })
    }
}

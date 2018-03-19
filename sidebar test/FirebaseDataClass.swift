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
import GoogleSignIn
import GoogleAPIClientForREST

enum userType: String{
    case student = "Student"
    case teacher = "Teacher"
    case admin = "Admin"
}

let userTypeForString = ["Student" : userType.student,
                         "Teacher" : userType.teacher,
                         "Admin" : userType.admin]

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

protocol FirebaseProtocol: class {
    func historyArrayDidLoad()
    func userDataDidLoad()
}

var allStudentsLoaded = false
var allTeachersLoaded = false

class FirebaseDataClass{
    
    var userID: String!
    var currentUser: User!
    weak var firebaseDataDelegate: FirebaseProtocol!
    
    let ref = FIRDatabase.database().reference()
    
    var historyItems = [HistoryData]()
    var requestItems = [HistoryData]()
    
    var allItems = [HistoryData]()
    var filteredItems = [HistoryData]()
    
    var allStudents = [User]()
    var allTeachers = [User]()
    
    var googleData = GoogleDataClass()
    
    var savedUserType: userType!
    
//    var isPullingData = false
    
    init() {
        
        guard let currUserID = FIRAuth.auth()?.currentUser?.uid else{
            print("user not logged in")
            NotificationCenter.default.post(Notification(name: ReturnToLoginNotificationName))
            return
        }
        
        userID = currUserID
        
        print(userID)
        
        //Saving the userType in StandardUserDefaults
        //for Key : "userType"
        //for Value: userType   //["Student", "Teacher", "Admin"]
        
        //        UserDefaults.standard.set(userType.student, forKey: "userType")
        
        let savedUserResult = UserDefaults.standard.value(forKey: "userType")
        if let savedUserTypeResult = savedUserResult as? String{
            
            print("\(savedUserTypeResult)\n\n\n")
            savedUserType = userTypeForString[savedUserTypeResult]
            //            firebaseDataDelegate.intiViewWith(userType: savedUserTypeResult)
        }else{
            savedUserType = nil
            //            firebaseDataDelegate.intiViewWith(userType: nil)
        }
        
        
        
    }
    
    deinit {
        print("Firebase database did deinit")
    }
    
    func pullingAllData(){
        getCurrentUser()
    }
    
    func reloadHistoryData(){
//        if !isPullingData{
//            isPullingData = true
            getHistoryItems()
            getRequestItems()
//        }
    }
    
    
    func resetingUserIndex (){ for i in allStudents{ i.userIndex = allStudents.index(of: i) } }
    
    func sortHistoryData(){//} -> [HistoryData]{
        let type: [cellTypes] = self.currentUser.userType == .student ? [cellTypes.studentHistory, cellTypes.studentRequest] : [cellTypes.toHistory, cellTypes.request]
        var arr = [HistoryData]()
        for i in allItems{
            for j in type{
                if i.thisCellType == j{
                    arr.append(i)
                    break
                }
            }
        }
        self.filteredItems = arr
    }
    
    //MARK: - Current User
    
    func getCurrentUser(){
        self.ref.child("users").child(userID).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            var data = snapshot.value as! [String: Any]
            
            
            let name = data["name"] as! String
            let email = data["email"] as! String
            
            var tier = userType.student
            switch(data["tier"] as! Int){
            case 0: tier = .student
            case 1: tier = .teacher
            case 2: tier = .admin
            default: tier = .student
            }
            
            if self?.savedUserType == nil{
                UserDefaults.standard.set(tier.rawValue, forKey: "userType")
            }else if tier != self?.savedUserType{
                print("\n\n\nERRRORRR INCORRECT USER TYPE\n\n\n")
            }
            
            let photoID = data["photoURL"] as! String
            var image = UIImage()
            do{
                try image = UIImage(data: Data(contentsOf: URL(string: photoID)!))!
            }catch{
                print("\n\n\n\n\nimage Failed\n\n\n\n")
            }
            
            self?.currentUser = User(type: tier, image: image, name: name, email: email, stringID: (self?.userID)!)
            
            self?.firebaseDataDelegate.userDataDidLoad()
            NotificationCenter.default.post(Notification(name: userDataDidLoadNotif))
            
            self?.getStudentList(studentType: "teachers", potentialItem: "potentialTeachers")
//            if self?.currentUser.userType != .student {
                self?.getStudentList(studentType: "students", potentialItem: "potentialStudents")
//            }
            
            //            self?.getStudentList(studentType: self?.currentUser.userType != .student ? "students" : "teachers", potentialItem: self?.currentUser.userType != .student ? "potentialStudents" : "potentialTeachers")
        })
    }
    
    
    
    //MARK: - Get history items
    
    //    var historyLoaded = false
    //    var requestsLoaded = false
    
    var isPullingHistory = false
    var isPullingRequest = false
    
    func historyCellsDidLoad(fromHistory: Bool){
        if fromHistory{
            isPullingHistory = false
        }else{
            isPullingRequest = false
        }
        
        self.allItems.removeAll()
        allItems += historyItems
        allItems += requestItems
        if !allItems.isEmpty{
            historyQuickSort(lowerIndex: 0, higherIndex: firebaseData.allItems.count - 1)
            self.sortHistoryData()
        }
        firebaseDataDelegate.historyArrayDidLoad()
        if !isPullingRequest && !isPullingHistory{
//            isPullingData = false
            print("FInished")
        }
        
    }
    
    //quick sort for sorting the history items by time
    func historyQuickSort(lowerIndex: Int, higherIndex: Int){
        var lower = lowerIndex
        var higher = higherIndex
        let pivot = firebaseData.allItems[lower + (higher - lower) / 2].timeStarted!
        while(lower <= higher){
            while(firebaseData.allItems[lower].timeStarted! > pivot){ lower += 1 }
            while(firebaseData.allItems[higher].timeStarted! < pivot){ higher -= 1 }
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
                
                let values = snapshot.value as! [String : String]
                let historyKeys = Array(values.keys)
                
                // Increased when the data is pulled from the follwing users: Student, origin, destination
                // when all are equil to history keys.count * 2 (one is left out because of above), deleage data realoaded called
                var userCount = 0
                
                for key in historyKeys{
                    let cell = HistoryData()
                    
                    // origin, destination, student, cellType, timeStart, timeEnd
                    //Get each item as a key
                    
                    self?.ref.child("history").child(key).observe(.value, with: { [weak self] (snapshot) in
                        if snapshot.exists(){
                            //This needs to be here in case the database changes at this level
//                            if !(self?.isPullingData)!{
//                                self?.reloadHistoryData()
//                                return
//                            }
                            self?.isPullingHistory = true
                            self?.historyItems.removeAll()
                            
                            
                            let historyValues = snapshot.value as! [String: Any]
                            
                            let originID = (historyValues["origin"] as! String).replacingOccurrences(of: "%2E", with: ".")
                            let destinationID = (historyValues["destination"] as! String).replacingOccurrences(of: "%2E", with: ".")
                            let studentID = (historyValues["student"] as! String).replacingOccurrences(of: "%2E", with: ".")
                            
                            let studentString: String
                            let originString: String
                            let destinationString: String
                            
                            
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
                            
                            guard let destination = self?.allTeachers.userFrom(ID: destinationID) else{
                                for _ in 0...5{
                                    print("DESTINATION USER NAME FAILED")
                                }
                                return
                            }
                            
                            //Getting the name from the userID to put into the cell
                            studentString = student.userName
                            originString = origin.userName
                            destinationString = destination.userName
                            
                            //finding the cell type by matching the uid to the person
                            var cellType: cellTypes = .studentHistory
                            if studentID != self?.userID{
                                if originID == self?.userID{
                                    cellType = .fromHistory
//                                    originString = self?.currentUser.userName

                                }else if destinationID == self?.userID{
                                    cellType = .toHistory
//                                    cell.destination = self?.currentUser.userName
                                }
                            }
//                            }else{
//                                cell.student = self?.currentUser.userName
//                            }
                            
                            
                            
                            
                            
                            
                            //Getting the user names from the IDs to put into the cell
//                            if cellType != .fromHistory{
//                                self?.ref.child("users").child(originID).child("name").observeSingleEvent(of: .value, with: { [weak self] (originNameSnapshot) in
//
//                                    // A check and alternate pull from the database is necessary in order to find potential users
//                                    // (those in our school who did not sign up)
//                                    // The key in this is not a UID it is the users' email
//                                    if originNameSnapshot.exists(){
//                                        cell.origin = originNameSnapshot.value as? String// originName
//                                        userCount += 1
//                                        if userCount == historyKeys.count * 2{
//                                            self?.historyCellsDidLoad(fromHistory: true)
//                                        }
//                                    }else{
//                                        self?.ref.child("potentialTeachers").child(originID).observeSingleEvent(of: .value, with: { [weak self] (potentialOriginNameSnapshot) in
//                                            cell.origin = potentialOriginNameSnapshot.value as? String// originName
//                                            userCount += 1
//                                            if userCount == historyKeys.count * 2{
//                                                self?.historyCellsDidLoad(fromHistory: true)
//                                            }
//                                        })
//                                    }
//                                })
//                            }
//
//                            if cellType != .toHistory{
//                                self?.ref.child("users").child(destinationID).child("name").observeSingleEvent(of: .value, with: { [weak self] (destinationNameSnapshot) in
//                                    if destinationNameSnapshot.exists(){
//                                        cell.destination = destinationNameSnapshot.value as? String// destinationName
//                                        userCount += 1
//                                        if userCount == historyKeys.count * 2{
//                                            self?.historyCellsDidLoad(fromHistory: true)
//                                        }
//                                    }else{
//                                        self?.ref.child("potentialTeachers").child(destinationID).observeSingleEvent(of: .value, with: { [weak self] (potentialDestinationNameSnapshot) in
//                                            cell.destination = potentialDestinationNameSnapshot.value as? String// destinationName
//                                            userCount += 1
//                                            if userCount == historyKeys.count * 2{
//                                                self?.historyCellsDidLoad(fromHistory: true)
//                                            }
//                                        })
//                                    }
//                                })
//                            }
//
//                            if cellType != .studentHistory{
//                                self?.ref.child("users").child(studentID).child("name").observeSingleEvent(of: .value, with: { [weak self] (studentNameSnapshot) in
//                                    if studentNameSnapshot.exists(){
//                                        cell.student = studentNameSnapshot.value as? String
//                                        userCount += 1
//                                        if userCount == historyKeys.count * 2{
//                                            self?.historyCellsDidLoad(fromHistory: true)
//                                        }
//                                    }else{
//                                        self?.ref.child("potentialStudents").child(studentID).observeSingleEvent(of: .value, with: { [weak self] (potentialStudentNameSnapshot) in
//                                            //                                        studentName = potentialStudentNameSnapshot.value as? String
//                                            cell.student = potentialStudentNameSnapshot.value as? String//studentName
//                                            userCount += 1
//                                            if userCount == historyKeys.count * 2{
//                                                self?.historyCellsDidLoad(fromHistory: true)
//                                            }
//                                        })
//                                    }
//                                })
//                            }
                            
                            var status: acceptedStatus = .pending
                            
                            let statusInt = historyValues["status"] as! Int
                            switch(statusInt){
                            case 0: status = .rejected
                            case 2: status = .accepted
                            default: status = .pending
                            }
                            
                            let timeCreated = (historyValues["time"] as! Int) / 1000
                            var timeCompleted = historyValues["timeCompleted"] as? Int
                            if timeCompleted != nil { timeCompleted = timeCompleted! / 1000 }
                            
                            let reason = historyValues["reason"] as! String
                            cell.initData(ID: key, origin: originString, destination: destinationString, student: studentString, timeStarted: timeCreated, timeCompleted: timeCompleted, reason: reason, status: status, cellType: cellType)
                            
                            if !(self?.currentUser.userType == .teacher && cell.status == .pending){
                                self?.historyItems.append(cell)
                            }
                            userCount += 1
                            if userCount == historyKeys.count{
                                self?.historyCellsDidLoad(fromHistory: true)
                            }
                        }
                    })
                    
                }
                
                print("finished")
            }else{
                self?.historyItems.removeAll()
                self?.historyCellsDidLoad(fromHistory: true)
            }
        })
    }
    
    func getRequestItems(){
        
        self.ref.child("users").child(userID).child("requests").observe(.value, with: { [weak self] (snapshot) in
            //            print(self?.isPullingRequest)!)
            
            
            if snapshot.exists() && !(self?.isPullingRequest)!{
                
                
                let requestKeys = (snapshot.value as! [String: String]).keys
                var requestCount = 0
                
                for key in requestKeys{
                    
                    let cell = HistoryData()
                    self?.ref.child("requests").child(key).observeSingleEvent(of: .value, with: { [weak self] (requestSnapshot) in
                        if requestSnapshot.exists(){
//                            if !(self?.isPullingData)!{
//                                self?.reloadHistoryData()
//                                return
//                            }
                            self?.isPullingRequest = true
                            self?.requestItems.removeAll()
                            
                            
                            let requestData = requestSnapshot.value as! [String: Any]
                            let destinationID = requestData["destination"] as! String
                            let studentID = requestData["student"] as! String
                            
                            
                            guard let student = self?.allStudents.userFrom(ID: studentID) else{
                                for _ in 0...5{
                                    print("STUDENT USER NAME FAILED")
                                }
                                return
                            }
                            
                            guard let destination = self?.allTeachers.userFrom(ID: destinationID) else{
                                for _ in 0...5{
                                    print("DESTINATION USER NAME FAILED")
                                }
                                return
                            }
                            
                            
                            
                            
//
//                            self?.ref.child("users").child(destinationID).child("name").observe(.value, with: { [weak self] (destinationNameSnapshot) in
//                                //                                if !(self?.isPullingRequest)!{
//                                //                                    self?.reloadHistoryData()
//                                //                                    return
//                                //                                }
//                                if destinationNameSnapshot.exists(){
//                                    cell.destination = destinationNameSnapshot.value as? String
//                                    requestCount += 1
//                                    if requestCount == requestKeys.count * 2{
//                                        self?.historyCellsDidLoad(fromHistory: false)
//                                    }
//                                }else{
//
//                                    self?.ref.child("potentialTeachers").child(destinationID).observeSingleEvent(of: .value, with: { [weak self] (potentialDestinationNameSnapshot) in
//                                        cell.destination = potentialDestinationNameSnapshot.value as? String
//                                        requestCount += 1
//                                        if requestCount == requestKeys.count * 2{
//                                            self?.historyCellsDidLoad(fromHistory: false)
//                                        }
//                                    })
//                                }
//                            })
//
//                            self?.ref.child("users").child(studentID).child("name").observeSingleEvent(of: .value, with: { [weak self] (studentNameSnapshot) in
//                                if studentNameSnapshot.exists(){
//                                    cell.student = studentNameSnapshot.value as? String
//                                    requestCount += 1
//                                    if requestCount == requestKeys.count * 2{
//                                        self?.historyCellsDidLoad(fromHistory: false)
//                                    }
//                                }else{
//                                    self?.ref.child("potentialStudent").child(studentID).observeSingleEvent(of: .value, with: { [weak self] (potentialStudentNameSnapshot) in
//                                        cell.student = potentialStudentNameSnapshot.value as? String
//                                        requestCount += 1
//                                        if requestCount == requestKeys.count * 2  {
//                                            self?.historyCellsDidLoad(fromHistory: false)
//                                        }
//                                    })
//                                }
//                            })
                            
                            let timeCreated = (requestData["time"] as! Int) / 1000
                            let reason = requestData["reason"] as! String
                            
                            cell.initData(ID: key, origin: (self?.currentUser.userName)!, destination: destination.userName, student: student.userName, timeStarted: timeCreated, timeCompleted: nil, reason: reason, status: .pending, cellType: .request)
                            self?.requestItems.append(cell)
                            requestCount += 1
                            if requestCount == requestKeys.count{
                                self?.historyCellsDidLoad(fromHistory: false)
                            }
                        }
                    })
                }
            }else{
                self?.requestItems.removeAll()
                self?.historyCellsDidLoad(fromHistory: false)
            }
        })
    }
    
    
    //MARK: - Getting Student or Teacher List
    
    func finishedPullingAll(){
        if allStudentsLoaded && allTeachersLoaded{
//        if finishedPullingStudents && finishedPullingTeachers{
        
            reloadHistoryData()
        }
    }
    
    func getStudentList(studentType: String, potentialItem: String){
        //real means all initialized students loaded
        //imaginary means all uninited '
        var realStudents = false
        var imaginaryStudents = false
        
        self.ref.child(studentType).observe(.value, with: { [weak self] (snapshotStudents) in
            realStudents = false
            imaginaryStudents = false
            let studentKeys = Array((snapshotStudents.value! as! [String: Bool]).keys)
            var finishCount = 0
            print(studentKeys.count)
            for i in studentKeys{
                
//                if studentType == "students" || (self?.currentUser.userStringID)! != i{
                
                    let userCell = User()
                    userCell.userType = .student
                    userCell.userStringID = i
                
                
                    
                    self?.ref.child("users").child(i).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                        userCell.userName = snapshot.value! as! String
                        finishCount += 1
                        if finishCount == studentKeys.count * 3{
                            realStudents = true
                            if imaginaryStudents == true{
                                if studentType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                                NotificationCenter.default.post(name: studentType == "students" ? studentDataLoaded : teacherDataLoaded, object: nil)
                                self?.finishedPullingAll()
                            }
                        }
                    })
                    
                    self?.ref.child("users").child(i).child("email").observeSingleEvent(of: .value, with: { (snapshot) in
                        userCell.userEmail = snapshot.value! as! String
                        finishCount += 1
                        if finishCount == studentKeys.count * 3{
                            realStudents = true
                            if imaginaryStudents == true{
                                if studentType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                                NotificationCenter.default.post(name: studentType == "students" ? studentDataLoaded : teacherDataLoaded, object: nil)
                                self?.finishedPullingAll()
                            }
                        }
                    })
                    
                    self?.ref.child("users").child(i).child("photoURL").observeSingleEvent(of: .value, with: {(snapshot) in
                        let photoString = snapshot.value! as! String
                        do{
                            let image = try UIImage(data: Data(contentsOf: URL(string: photoString)!))!
                            userCell.userImage = image
                        }catch{
                            print("\nimage Failed with id: \(i)\n")
                            userCell.userImage = #imageLiteral(resourceName: "BlankUser")
                        }
                        finishCount += 1
                        if finishCount == studentKeys.count * 3{
                            realStudents = true
                            if imaginaryStudents == true{
                                if studentType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                                NotificationCenter.default.post(name: studentType == "students" ? studentDataLoaded : teacherDataLoaded, object: nil)
                                self?.finishedPullingAll()
                            }
                        }
                    })
                    
                    if studentType == "students"{
                        self?.allStudents.append(userCell)
                        userCell.userIndex = (self?.allStudents.count)! - 1
                    }else{
                        self?.allTeachers.append(userCell)
                        userCell.userIndex = (self?.allTeachers.count)! - 1
                    }
//                }
            }
        })
        
        self.ref.child(potentialItem).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if snapshot.exists() {
                let data = snapshot.value! as! [String: String]
                for (key, value) in data{
                    let cell = User(type: .student, name: value, email: key.replacingOccurrences(of: "%2E", with: "."))
                    
                    if studentType == "students"{
                        self?.allStudents.append(cell)
                        cell.userIndex = (self?.allStudents.count)! - 1
                    }else{
                        self?.allTeachers.append(cell)
                        cell.userIndex = (self?.allTeachers.count)! - 1
                    }
                }
                imaginaryStudents = true
                if realStudents == true{
                    if studentType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                    NotificationCenter.default.post(name: studentType == "students" ? studentDataLoaded : teacherDataLoaded, object: nil)
                    self?.finishedPullingAll()
                }
            }else{
                imaginaryStudents = true
                if realStudents == true{
                    if studentType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                    NotificationCenter.default.post(name: studentType == "students" ? studentDataLoaded : teacherDataLoaded, object: nil)
                    self?.finishedPullingAll()
                }
            }
        })
    }
}

extension Array where Element:User{
    func userFrom(ID: String) -> User?{
        for i in self{
            if i == ID{
                return i
            }
        }
        return nil
    }
}



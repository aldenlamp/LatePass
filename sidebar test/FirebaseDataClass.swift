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

enum timeFrames{
    case thisWeek
    case thisMonth
    case thisYear
}

@objc
protocol FirebaseProtocol {
    func uesrDataDidLoad()
    func historyArrayDidLoad()
    func requestArrayDidLoad()
//    @objc optional func realStudentsDidLoad()
//    @objc optional func potentialStudentsDidLoad()
//    @objc optional func realTeachersDidLoad()
//    @objc optional func potentialTeachersDidLoad()
}

var allStudentsLoaded = false
var allTeachersLoaded = false

class FirebaseDataClass{
    var userID: String?
    var currentUser: UserCell?
    var blankUser: UserCell!
    var firebaseDataDelegate: FirebaseProtocol!
    
    let ref = FIRDatabase.database().reference()
//    let thisUserRef = self?.ref.child("users").child(userID!)
    
    var historyItems = [Cell]()
    var requestItems = [Cell]()
    
    var allItems = [Cell]()
    
    var allTeachers = [UserCell]() //This does include the admins
    var allStudents = [UserCell]()
    
    init() {
        
        blankUser = UserCell()
        blankUser.setUpPotentialCell(type: .student, name: "test ing", email: "test@ing.com")
        
        guard let currUserID = FIRAuth.auth()?.currentUser?.uid else{
            print("user not logged in")
            NotificationCenter.default.post(Notification(name: ReturnToLoginNotificationName))
            return
        }
        userID = currUserID
        
        
        // Needed to set up a user cell: id, name, email, image, userType
        self.ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            var data = snapshot.value as! [String: Any]
            
            
            let name = data["name"] as! String
            let email = data["name"] as! String
            
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
            
        })
        
        
        
        //getting the history item and request items
        self.ref.child("users").child(userID!).child("history").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if snapshot.exists(){
                let values = snapshot.value as! [String : String]
                let historyKeys = Array(values.keys)
                
                print(historyKeys.count)
                
                // Increased when the data is pulled from the follwing users: Student, origin, destination
                // when all are equil to history keys.count * 2 (one is left out because of above), deleage data realoaded called
                var userCount = 0
                
                for key in historyKeys{
                    let cell = Cell()
                    
                    // origin, destination, student, cellType, timeStart, timeEnd
                    //Get each item as a key
                    
                    self?.ref.child("history").child(key).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                        let historyValues = snapshot.value as! [String: Any]
                        
                        let originID = historyValues["origin"] as! String
                        let destinationID = historyValues["destination"] as! String
                        let studentID = historyValues["student"] as! String
                        
                        //finding the cell type by matching the uid to the person
                        var cellType: cellTypes = .studentHistory
                        if studentID != self?.userID{
                            if originID == self?.userID{
                                cellType = .fromHistory
                                //                                originName = self?.currentUser?.userName
                                cell.origin = self?.currentUser?.userName
                            }else if destinationID == self?.userID{
                                cellType = .toHistory
                                //                                destinationName = self?.currentUser?.userName
                                cell.destination = self?.currentUser?.userName
                            }else{
                                print("\n\nNO CELL TYPE\n\n")
                            }
                        }else{
                            //                            studentName = self?.currentUser?.userName
                            cell.student = self?.currentUser?.userName
                        }
                        
                        
                        //Getting the user names from the IDs to put into the cell
                        if cellType != .fromHistory{
                            self?.ref.child("users").child(originID).child("name").observeSingleEvent(of: .value, with: { [weak self] (originNameSnapshot) in
                                
                                // A check and alternate pull from the database is necessary in order to find potential users
                                // (those in our school who did not sign up)
                                // The key in this is not a UID it is the users' email
                                if originNameSnapshot.exists(){
                                    //                                    originName = originNameSnapshot.value as? String
                                    cell.origin = originNameSnapshot.value as? String// originName
                                    userCount += 1
                                    if userCount == historyKeys.count * 2{
                                        self?.firebaseDataDelegate.historyArrayDidLoad()
                                    }
                                }else{
                                    self?.ref.child("potentialTeachers").child(originID).observeSingleEvent(of: .value, with: { [weak self] (potentialOriginNameSnapshot) in
                                        //                                        originName = potentialOriginNameSnapshot.value as? String
                                        cell.origin = potentialOriginNameSnapshot.value as? String// originName
                                        userCount += 1
                                        if userCount == historyKeys.count * 2{
                                            self?.firebaseDataDelegate.historyArrayDidLoad()
                                        }
                                    })
                                }
                            })
                        }
                        
                        if cellType != .toHistory{
                            self?.ref.child("users").child(destinationID).child("name").observeSingleEvent(of: .value, with: { [weak self] (destinationNameSnapshot) in
                                if destinationNameSnapshot.exists(){
                                    cell.destination = destinationNameSnapshot.value as? String// destinationName
                                    userCount += 1
                                    if userCount == historyKeys.count * 2{
                                        self?.firebaseDataDelegate.historyArrayDidLoad()
                                    }
                                }else{
                                    self?.ref.child("potentialTeachers").child(destinationID).observeSingleEvent(of: .value, with: { [weak self] (potentialDestinationNameSnapshot) in
                                        cell.destination = potentialDestinationNameSnapshot.value as? String// destinationName
                                        userCount += 1
                                        if userCount == historyKeys.count * 2{
                                            self?.firebaseDataDelegate.historyArrayDidLoad()
                                        }
                                    })
                                }
                            })
                        }
                        
                        if cellType != .studentHistory{
                            self?.ref.child("users").child(studentID).child("name").observeSingleEvent(of: .value, with: { [weak self] (studentNameSnapshot) in
                                if studentNameSnapshot.exists(){
                                    cell.student = studentNameSnapshot.value as? String
                                    userCount += 1
                                    if userCount == historyKeys.count * 2{
                                        self?.firebaseDataDelegate.historyArrayDidLoad()
                                    }
                                }else{
                                    self?.ref.child("potentialStudents").child(studentID).observeSingleEvent(of: .value, with: { [weak self] (potentialStudentNameSnapshot) in
                                        //                                        studentName = potentialStudentNameSnapshot.value as? String
                                        cell.student = potentialStudentNameSnapshot.value as? String//studentName
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
                        cell.initData(ID: key, origin: "", destination: "", student: "", timeStarted: timeCreated, timeCompleted: timeCompleted, reason: reason, status: status, cellType: cellType)
                        
                        if !(self?.currentUser?.userType == .teacher && cell.status == .pending){
                            self?.historyItems.append(cell)
                        }
                        
                    })
                }
            }
        })

        
        self.ref.child("users").child(userID!).child("requests").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if snapshot.exists(){
                // needed: timeCreated, to, student, reason,
                let requestKeys = (snapshot.value as! [String: String]).keys
                var requestCount = 0
                
                for key in requestKeys{
                    
                    let cell = Cell()
                    self?.ref.child("requests").child(key).observeSingleEvent(of: .value, with: { [weak self] (requestSnapshot) in
                        let requestData = requestSnapshot.value as! [String: Any]
                        
                        let destinationID = requestData["destination"] as! String
                        
                        let studentID = requestData["student"] as! String
                        
                        self?.ref.child("users").child(destinationID).child("name").observeSingleEvent(of: .value, with: { [weak self] (destinationNameSnapshot) in
                            if destinationNameSnapshot.exists(){
                                cell.destination = destinationNameSnapshot.value as? String
                                requestCount += 1
                                if requestCount == requestKeys.count * 2{
                                    self?.firebaseDataDelegate.requestArrayDidLoad()
                                }
                            }else{
                                
                                self?.ref.child("potentialTeachers").child(destinationID).observeSingleEvent(of: .value, with: { [weak self] (potentialDestinationNameSnapshot) in
                                    cell.destination = potentialDestinationNameSnapshot.value as? String
                                    requestCount += 1
                                    if requestCount == requestKeys.count * 2{
                                        self?.firebaseDataDelegate.requestArrayDidLoad()
                                    }
                                })
                            }
                        })
                        
                        self?.ref.child("users").child(studentID).child("name").observeSingleEvent(of: .value, with: { [weak self] (studentNameSnapshot) in
                            if studentNameSnapshot.exists(){
                                cell.student = studentNameSnapshot.value as? String
                                requestCount += 1
                                if requestCount == requestKeys.count * 2{
                                    self?.firebaseDataDelegate.requestArrayDidLoad()
                                }
                            }else{
                                self?.ref.child("potentialStudent").child(studentID).observeSingleEvent(of: .value, with: { [weak self] (potentialStudentNameSnapshot) in
                                    cell.student = potentialStudentNameSnapshot.value as? String
                                    requestCount += 1
                                    if requestCount == requestKeys.count * 2  {
                                        self?.firebaseDataDelegate.requestArrayDidLoad()
                                    }
                                })
                            }
                        })
                        
                        let timeCreated = requestData["time"] as! Int
                        let reason = requestData["reason"] as! String
                        
                        cell.initData(ID: key, origin: (self?.currentUser?.userName)!, destination: "", student: "", timeStarted: timeCreated, timeCompleted: nil, reason: reason, status: .pending, cellType: .request)
                        self?.requestItems.append(cell)
                    })
                }
            }
        })
        
        //getting all users for the select user list
//        self.ref.child("")
        
        //getting regestered students
        
        //real means all initialized students loaded
        //imaginary means all uninited '            '
        var realStudents = false
        var imaginaryStudents = false
        
        self.ref.child("students").observeSingleEvent(of: .value, with: { [weak self] (snapshotStudents) in
            let studentKeys = Array((snapshotStudents.value! as! [String: Bool]).keys)
            var finishCount = 0
            
            for i in studentKeys{
                
                let userCell = UserCell()
                userCell.setUpView()
                userCell.userID = i
                userCell.userType = .student
                
                self?.ref.child("users").child(i).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                    userCell.setName(name: snapshot.value! as! String)
                    finishCount += 1
                    if finishCount == studentKeys.count * 3{
                        realStudents = true
                        if imaginaryStudents == true{
                            allStudentsLoaded = true
                        }
                    }
                })
                
                self?.ref.child("users").child(i).child("email").observeSingleEvent(of: .value, with: { (snapshot) in
                    userCell.setEmail(email: snapshot.value! as! String)
                    finishCount += 1
                    if finishCount == studentKeys.count * 3{
                        realStudents = true
                        if imaginaryStudents == true{
                            allStudentsLoaded = true
                        }
                    }
                })
                
                self?.ref.child("users").child(i).child("photoURL").observeSingleEvent(of: .value, with: {(snapshot) in
                    let photoString = snapshot.value! as! String
                    do{
                        let image = try UIImage(data: Data(contentsOf: URL(string: photoString)!))!
                        userCell.setimage(image: image)
                    }catch{
                        print("\nimage Failed with id: \(i)\n")
                        userCell.setBlankImage()
                    }
                    finishCount += 1
                    if finishCount == studentKeys.count * 3{
                        realStudents = true
                        if imaginaryStudents == true{
                            allStudentsLoaded = true
                        }
                    }
                })
                self?.allStudents.append(userCell)
            }
        })
        
        self.ref.child("potentialStudents").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            let data = snapshot.value! as! [String: String]
            for (key, value) in data{
                let cell = UserCell()
                cell.setUpPotentialCell(type: .student, name: value, email: key.replacingOccurrences(of: "%2E", with: "."))
                self?.allStudents.append(cell)
            }
            imaginaryStudents = true
            if realStudents == true{
                allStudentsLoaded = true
            }
        })
        
        //pulling for all the data in the teacher user array
        
        var realTeachers = false
        var imaginaryTeacher = false
        
        self.ref.child("teachers").observeSingleEvent(of: .value, with: { [weak self] (teacherKeysSnapshot) in
            let teacherKeys = Array((teacherKeysSnapshot.value! as! [String:Bool]).keys)
            var finishCount = 0
            
            for i in teacherKeys{
                let userCell = UserCell()
                userCell.setUpView()
                userCell.userType = .teacher
                userCell.userID = i
                
                self?.ref.child("users").child(i).child("name").observeSingleEvent(of: .value, with: {(snapshot) in
                    userCell.setName(name: snapshot.value! as! String)
                    finishCount += 1
                    if finishCount == teacherKeys.count * 3{
                        realTeachers = true
                        if imaginaryTeacher == true{
                            allTeachersLoaded = true
                        }
                    }
                    
                })
                
                self?.ref.child("users").child(i).child("email").observeSingleEvent(of: .value, with: { (snapshot) in
                    userCell.setEmail(email: (snapshot.value! as! String).replacingOccurrences(of: "%2E", with: "."))
                    finishCount += 1
                    if finishCount == teacherKeys.count * 3{
                        realTeachers = true
                        if imaginaryTeacher == true{
                            allTeachersLoaded = true
                        }
                    }
                })
                
                self?.ref.child("users").child(i).child("photoURL").observeSingleEvent(of: .value, with: { (snapshot) in
                    let photoString = snapshot.value! as! String
                    do{
                        let image = try UIImage(data: Data(contentsOf: URL(string: photoString)!))!
                        userCell.setimage(image: image)
                    }catch{
                        print("\nimage Failed with id: \(i)\n")
                        userCell.setBlankImage()
                    }
                    finishCount += 1
                    if finishCount == teacherKeys.count * 3{
                        realTeachers = true
                        if imaginaryTeacher == true{
                            allTeachersLoaded = true
                        }
                    }
                })
                self?.allTeachers.append(userCell)
            }
        })
        
        self.ref.child("potentialTeachers").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            let data = snapshot.value! as! [String: String]
            for (key, value) in data{
                let userCell = UserCell()
                userCell.setUpPotentialCell(type: .teacher, name: value, email: key.replacingOccurrences(of: "%2E", with: "."))
                self?.allTeachers.append(userCell)
            }
            imaginaryTeacher = true
            if realTeachers == true{
                allTeachersLoaded = true
            }
        })
        
    }
}



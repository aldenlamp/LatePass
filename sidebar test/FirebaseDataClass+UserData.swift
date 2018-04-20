//
//  FirebaseDataClass+UserData.swift
//  sidebar test
//
//  Created by alden lamp on 4/5/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import UIKit

enum userType: String{
    case student = "Student"
    case teacher = "Teacher"
    case admin = "Admin"
}

let userTypeForString = ["Student" : userType.student, "Teacher" : userType.teacher, "Admin" : userType.admin]

var allStudentsLoaded = false
var allTeachersLoaded = false

extension FirebaseDataClass{
    
    func finishedPullingAll(){
        if allStudentsLoaded && allTeachersLoaded{
            print("All users finished loading")
            NotificationCenter.default.post(name: userDataLoadedNotification, object: nil)
            getHistoryItems()
//            getRequestItems()
            
        }
    }
    
    func getStudentList(itemType: String, potentialItem: String){
        
        //real means all initialized students loaded
        //imaginary means all uninited '
        
        //Did Load functions
        var realStudents = false
        var imaginaryStudents = false
        
        //Getting real Students
        self.ref.child(itemType).observeSingleEvent(of: .value, with: { [weak self] (snapshotStudents) in
            
            let studentKeys = Array((snapshotStudents.value! as! [String: Bool]).keys)
            var finishCount = 0
            
            //This is called at the completion of any property to determine when the full list is finished pulling
            func pulledAProperty(){
                finishCount += 1
                if finishCount == studentKeys.count * 3{
                    realStudents = true
                    if imaginaryStudents == true{
                        if itemType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                        self?.finishedPullingAll()
                    }
                }
            }
            
            for i in studentKeys{
                
                let userCell = User(email: nil)
                userCell.userType = .student
                userCell.userStringID = i
                
                
                self?.ref.child("users").child(i).child("name").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                    userCell.userName = snapshot.value! as! String
//                    pulledAProperty()
                    finishCount += 1
                    if finishCount == studentKeys.count * 3{
                        realStudents = true
                        if imaginaryStudents == true{
                            if itemType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                            self?.finishedPullingAll()
                        }
                    }
                })
                
                self?.ref.child("users").child(i).child("email").observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                    userCell.userEmail = snapshot.value! as! String
//                    pulledAProperty()
                    finishCount += 1
                    if finishCount == studentKeys.count * 3{
                        realStudents = true
                        if imaginaryStudents == true{
                            if itemType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                            self?.finishedPullingAll()
                        }
                    }
                })
                
                self?.ref.child("users").child(i).child("photoURL").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                    if let image = try? UIImage(data: Data(contentsOf: URL(string: (snapshot.value! as! String))!)){
                        userCell.userImage = image!
                    }else{
                        userCell.userImage = #imageLiteral(resourceName: "BlankUser")
                    }
//                    pulledAProperty()
                    finishCount += 1
                    if finishCount == studentKeys.count * 3{
                        realStudents = true
                        if imaginaryStudents == true{
                            if itemType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                            self?.finishedPullingAll()
                        }
                    }
                })
                
                if itemType == "students"{ self?.allStudents.append(userCell) }else{ self?.allTeachers.append(userCell) }
            }
        })
        
        
        //Getting all imaginary students
        self.ref.child(potentialItem).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in

            if snapshot.exists() {
                let data = snapshot.value! as! [String: String]
                
                for (key, value) in data{
                    let cell = User(type: .student, name: value, email: key.replacingOccurrences(of: "%2E", with: "."))
                    
                    if itemType == "students"{ self?.allStudents.append(cell) }else{ self?.allTeachers.append(cell) }
                }
            }
            
            imaginaryStudents = true
            if realStudents == true{
                if itemType == "students"{ allStudentsLoaded = true }else{ allTeachersLoaded = true }
                self?.finishedPullingAll()
            }
            
        })
    }
}

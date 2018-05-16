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

protocol FirebaseProtocol: class {
    func historyArrayDidLoad()
    func userDataDidLoad()
}

class FirebaseDataClass{
    //Current user variables
    var userID: String!
    var currentUser: User!
    
    var isPullingHistory = false
    var isPullingRequest = false
    
    //Delegate
    weak var firebaseDataDelegate: FirebaseProtocol?
    
    //Firebase Ref
    let ref = FIRDatabase.database().reference()
    
    //All History Items
    var allItems = [HistoryData]()
    var getAllItems: [HistoryData]{
        var arr = [HistoryData]()
        for i in allItems{
            if !(i.status == .rejected && i.destination == firebaseData.currentUser){
                arr.append(i)
            }
        }
        return arr
    }
    
    //All History Items specific for the user homepage
    private final let studentFilterSettings: [cellTypes] = [cellTypes.studentHistory, cellTypes.studentRequest]
    private final let teacherFilterSettings: [cellTypes] = [cellTypes.toHistory, cellTypes.request]
    var filteredItems: [HistoryData]{
        get{
            var arr = [HistoryData]()
            for i in allItems{
                for j in currentUser.userType == .student ? studentFilterSettings : teacherFilterSettings{
                    if i.thisCellType == j && !(i.status == .rejected && i.destination == firebaseData.currentUser){
                        arr.append(i)
                        break
                    }
                }
            }
            return arr
        }
    }
    
    //For the stat table views
    var toItems: [HistoryData] {
        get{
            var arr = [HistoryData]()
            for i in allItems{
                if i.thisCellType == cellTypes.toHistory && i.status == .accepted{
                    arr.append(i)
                }
            }
            return arr
        }
    }
    
    var studentItems: [HistoryData]{
        get{
            var arr = [HistoryData]()
            for i in allItems{
                if i.thisCellType == cellTypes.studentHistory && i.status == .accepted{
                    arr.append(i)
                }
            }
            return arr
        }
    }
    
    //All the users in the database
    var allStudents = [User]()
    var allTeachers = [User]()
    
    //All the users in the database including google classroom
    var GCAllStudents: [User]{
        var arr = [User]()
        for i in allStudents{
            arr.append(i)
        }
        for i in googleData.allStudents{
            arr.append(i)
        }
        return arr
    }
    
    var GCAllTeachers: [User]{
        var arr = [User]()
        for i in allTeachers{
            arr.append(i)
        }
        for i in googleData.allTeachers{
            arr.append(i)
        }
        return arr
    }
    
    //Google Data
    //TODO: - Implement a better data management
    var googleData: GoogleDataClass!
    
    //Pulling from Standard User Defaults
    //TODO: - Fully check standard user defaults pull
    var savedUserType: userType!
    
    init() {
        
        googleData = GoogleDataClass()
        
        guard let currUserID = FIRAuth.auth()?.currentUser?.uid else{
            print("user not logged in")
            NotificationCenter.default.post(Notification(name: ReturnToLoginNotificationName))
            return
        }
        
        userID = currUserID
        print(userID!)
        
        //TODO: - Rewrite this system with user ID as key
        let savedUserResult = UserDefaults.standard.value(forKey: "userType")
        if let savedUserTypeResult = savedUserResult as? String{
            
            print("\(savedUserTypeResult)\n\n\n")
            savedUserType = userTypeForString[savedUserTypeResult]
            //firebaseDataDelegate.intiViewWith(userType: savedUserTypeResult)
        }else{
            savedUserType = nil
            //firebaseDataDelegate.intiViewWith(userType: nil)
        }
    }
    
    deinit {
        print("Firebase database did deinit")
        //TODO: - Fix for setting it with the User ID
        UserDefaults.standard.set(nil, forKey: "userType")
        googleData = nil
    }
    
    func pullingAllData(){
        //All the data is pulled at the end of getting the current user
        getCurrentUser()
    }
    
    //Not sure If i actually need this
//  func resetingUserIndex (){ for i in allStudents{ i.userIndex = allStudents.index(of: i) } }
    
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
            
            //TODO: - Fix the standard User Defaults function for this
            if self?.savedUserType == nil{
                UserDefaults.standard.set(tier.rawValue, forKey: "userType")
            }else if tier != self?.savedUserType{
                print("\n\n\nERRRORRR INCORRECT USER TYPE\n\n\n")
                self?.savedUserType = tier
            }
            
            
            let photoID = data["photoURL"] as! String
            var image = UIImage()
            try? image = UIImage(data: Data(contentsOf: URL(string: photoID)!))!
            
            self?.currentUser = User(email: email, type: tier, name: name, image: image, stringID: self?.userID!, isPotential: false)
            
            //Delegate call to userDidLoad
            print("Current User data Did load")
            self?.firebaseDataDelegate?.userDataDidLoad()
            NotificationCenter.default.post(Notification(name: userDataDidLoadNotif))
            
            //Pulling all the users in the database....
            self?.getStudentList(itemType: "teachers", potentialItem: "potentialTeachers")
            self?.getStudentList(itemType: "students", potentialItem: "potentialStudents")
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

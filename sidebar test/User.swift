//
//  UserData.swift
//  sidebar test
//
//  Created by alden lamp on 11/23/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import Foundation
import UIKit

class User: Hashable{
    
    var hashValue: Int {
        return Int(userID)
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    
    var userType: userType
    var userName: String
    private var userID: UInt32
    var userEmail: String
    var userImage: UIImage
    var userIndex: Int?
    var userStringID: String?
    
    public static var numberOfSelected = 0
    private static var allUserIds = [UInt32]()
    
    var isChosen: Bool { didSet{ if isChosen { User.numberOfSelected += 1 } else { User.numberOfSelected -= 1 } } }
    
    init(){
        self.userType = .student
        self.userName = ""
        self.userEmail = ""
        self.userImage = #imageLiteral(resourceName: "BlankUser")
        var id: UInt32 = 0
        while(true){
            id = arc4random_uniform(UInt32.max)
            if !User.allUserIds.contains(id) { break }
        }
        self.userID = id
        self.isChosen = false
        User.numberOfSelected = 0
        User.allUserIds.append(id)
    }
    
    init(type: userType, name: String, email: String){
        self.userType = type
        self.userName = name
        self.userEmail = email
        self.userImage = #imageLiteral(resourceName: "BlankUser")
        var id: UInt32 = 0
        while(true){
            id = arc4random_uniform(UInt32.max)
            if !User.allUserIds.contains(id) { break }
        }
        self.userID = id
        self.isChosen = false
        User.numberOfSelected = 0
        User.allUserIds.append(userID)
    }
    
    init(type: userType, image: UIImage, name: String, email: String, stringID: String){
        userType = type
        userName = name
        userEmail = email
        userImage = image
        var id: UInt32 = 0
        while(true){
            id = arc4random_uniform(UInt32.max)
            if !User.allUserIds.contains(id) { break }
        }
        self.userID = id
        self.userStringID = stringID
        self.isChosen = false
        User.numberOfSelected = 0
        User.allUserIds.append(userID)
    }
    
//    private func makeNewUID() -> Int{
//        while(true){
//            let newRand = Int(arc4random_uniform(UInt32(Int.max)))
//            if !User.allUserIds.contains(newRand) {
//                return newRand
//            }
//        }
//    }
}

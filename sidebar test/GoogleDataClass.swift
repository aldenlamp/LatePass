//
//  GoogleDataClass.swift
//  sidebar test
//
//  Created by alden lamp on 2/18/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import Firebase
import Google
import GoogleSignIn
import GoogleAPIClientForREST

protocol GoogleClassroomDelegate: class{
    func allUsersLoaded()
}

class GoogleDataClass: NSObject{//, GIDSignInDelegate{
    //Just as a note, I changed the podCode from requiring SIGNIN function to optional (GIDSignInDelegate)
    
    //This is determining if we should allow passes to be made from teacher and students who are not in the database
    final var ALLOW_NONDATABASE_USERS = false
    
    var courses = [GTLRClassroom_Course]()
    
    var courseNames: [String]{
        var arr = [String]()
        for i in courses{
            arr.append(i.name!)
        }
        arr.append("All Users")
        return arr
    }
    
    var coursesExist = false
    var allClassroomTeachers = [GTLRClassroom_Teacher]()
    var allClassroomStudents = [GTLRClassroom_Student]()
    
    var teachersLoaded = false
    var studentsLoaded = false
    
    var simpleTeachers = [User]()
    
    private var internalTeacher = [[User]()]
    private var internalStudent = [[User]()]
    
    var teachers: [[User]]{// = [[User]]()
        get{ return internalTeacher }
        set{
            internalTeacher = [[User]]()
            for i in newValue{
                print("\nTeachersList: \(i.sorted(by:{$0.userName.split(separator: " ")[1] < $1.userName.split(separator: " ")[1]}))")
                internalTeacher.append(i.sorted(by:{$0.userName.split(separator: " ")[1] < $1.userName.split(separator: " ")[1]}))
            }
            
        }
    }
    var students: [[User]]{
        get{ return internalStudent }
        set{
            internalStudent = [[User]]()
            for i in newValue{ internalStudent.append(i.sorted(by: {$0.userName.split(separator: " ")[1] < $1.userName.split(separator: " ")[1] })) }
        }
    }
    
    var allTeachers: [User]{
        var arr = [User]()
        for i in teachers{
            for j in i{
                arr.append(j)
            }
        }
        return arr
    }
    
    var allStudents: [User]{
        var arr = [User]()
        for i in students{
            for j in i{
                arr.append(j)
            }
        }
        return arr
    }
    
    static var isPullingData = false
    
    weak var delegate: GoogleClassroomDelegate?
    
    private var observer : NSObjectProtocol!
    
    private let service = GTLRClassroomService()
    override init(){
        super.init()
        
        
        if GIDSignIn.sharedInstance().currentUser?.authentication.fetcherAuthorizer() != nil{
            if !GoogleDataClass.isPullingData{
                print("HelloWOlrd")
                print(GIDSignIn.sharedInstance().currentUser.authentication.refreshToken)
                self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
                self.fetchCourses()
               GoogleDataClass.isPullingData = true
            }
        }
        
        observer = NotificationCenter.default.addObserver(forName: logInCompleteNotification, object: nil, queue: nil) { [weak self] (notification) in
            if !(GoogleDataClass.isPullingData){
                print("HelloWOlrdasdfasdf")
                self?.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
                self?.fetchCourses()
                GoogleDataClass.isPullingData = true
            }
        }
    }
    
    deinit{
        print("Google Data Pull did DeInit")
        NotificationCenter.default.removeObserver(observer)
    }
    
    
    
    
    //MARK: - Google Stuff
    
    private func fetchCourses() {
        print("Getting courses...\n\n\n")
        let query = GTLRClassroomQuery_CoursesList.query()
        service.executeQuery(query, delegate: self, didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc private func displayResultWithTicket(ticket: GTLRServiceTicket, finishedWithObject result : GTLRClassroom_ListCoursesResponse, error : NSError?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        guard let courses = result.courses, !courses.isEmpty else {
            print("No Courses")
            teachers = [[User](), firebaseData.allTeachers]
//            teachers.append(firebaseData.allTeachers)
//            students.append(firebaseData.allStudents)
            students = [[User](), firebaseData.allStudents]
            GoogleDataClass.isPullingData = false
            return
        }
        self.coursesExist = true
        
        
        var outputText = "Courses:\n"

        courses.forEach() { if $0.courseState == "ACTIVE"{ self.courses.append($0) } }
        for course in self.courses {
            outputText += "\(course.name ?? "")\t\t (\(course.identifier!))\n"
        }
        print("\(outputText)\n\n")
        getTeachers()
        getStudents()
    }
    
    private func getTeachers(){
        var count = 0
        for course in courses{
            let query = GTLRClassroomQuery_CoursesTeachersList.query(withCourseId: course.identifier!)
            service.executeQuery(query, completionHandler: { [weak self](ticket, result, error) in
                if let error = error{
                    print("\nERROR: \(error.localizedDescription)\n")
//                    self?.teachers = [[User]]()
//                    self?.simpleTeachers.append([User]())
                    return
                }
                
                guard let teachers = result as? GTLRClassroom_ListTeachersResponse else{
                    print("Error getting teachesr\n\n")
//                    self?.simpleTeachers.append([User]())
//                    self?.teachers = [[User]]()
                    return
                }
                
                teachers.teachers!.forEach(){
                    self?.allClassroomTeachers.append($0)
                    var added = false
                    if let index = firebaseData.allTeachers.index(of: User(email: $0.profile!.emailAddress!, isPotential: false)){
                        self?.simpleTeachers.append(firebaseData.allTeachers[index])
                        added = true
                    }else{
                        if (self?.ALLOW_NONDATABASE_USERS)!{
                            self?.simpleTeachers.append(User(type: .student, name: "\($0.profile!.name!.fullName!)", email: "\($0.profile!.emailAddress!)"))
                            added = true
                        }
                    }
                    print("TeacherUSER: \($0.userId!) \tEMAIL: \($0.profile!.emailAddress!) \tNAME:\($0.profile!.name!.fullName!)\(added ? "\t\twas Added" : "")")
                }
//                self?.simpleTeachers.append(firTeachers)
                count += 1
                if count == self?.courses.count{
                    self?.teachers = [[User]]()
                    self?.teachers.append((self?.simpleTeachers)!)
                    self?.teachers.append(firebaseData.GCAllTeachers)
                    self?.teachersLoaded = true
                    self?.usersLoaded()
                }
            })
            
        }
    }
    
    private func getStudents(){
        var count = 0
        for course in courses{
            let query = GTLRClassroomQuery_CoursesStudentsList.query(withCourseId: course.identifier!)
            service.executeQuery(query, completionHandler: { [weak self] (ticket, result, error) in
                var isFirst = true
                if let error = error{
                    print("Error: \(error)")
                    self?.students.append([User]())
//                    self?.students = [[User]]()
                    return
                }
                
                guard let students = result as? GTLRClassroom_ListStudentsResponse else{
                    print("Error getting students")
                    self?.students.append([User]())
//                    self?.students = [[User]]()
                    return
                }
                
                var firStudents = [User]()
                
                
                students.students!.forEach() {
                    self?.allClassroomStudents.append($0)
//                    print("StudentUSER: \($0.userId!) \tEMAIL: \($0.profile!.emailAddress!) \tNAME:\($0.profile!.name!.fullName!)")
                    var added = false
                    if let index = firebaseData.allStudents.index(of: User(email: $0.profile!.emailAddress!, isPotential: false)){
                        firStudents.append(firebaseData.allStudents[index])
                        added = true
                    }else{
                        if (self?.ALLOW_NONDATABASE_USERS)!{
                            firStudents.append(User(type: .student, name: "\($0.profile!.name!.fullName!)", email: "\($0.profile!.emailAddress!)"))
                            added = true
                        }
                    }
                    print("StudentUSER: \($0.userId!) \tEMAIL: \($0.profile!.emailAddress!) \tNAME:\($0.profile!.name!.fullName!)\(added ? "\t\twas Added" : "")")
                }
                if isFirst{
                    self?.students = [[User]]()
                    isFirst = false
                }
                self?.students.append(firStudents)
                count += 1
                if count == self?.courses.count{
                    self?.students.append(firebaseData.GCAllStudents)
                    self?.studentsLoaded = true
                    self?.usersLoaded()
                }
            })
        }
    }
    
    private func usersLoaded(){
        if teachersLoaded && studentsLoaded{
            GoogleDataClass.isPullingData = false
            NotificationCenter.default.post(Notification(name: GCUsersLoaded))
        }
    }
    
    private func cleanArray(){
        
        
        
    }
}

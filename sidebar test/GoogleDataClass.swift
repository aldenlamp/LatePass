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
    
    var courses = [GTLRClassroom_Course]()
    var coursesExist = false
    var allClassroomTeachers = [GTLRClassroom_Teacher]()
    var allClassroomStudents = [GTLRClassroom_Student]()
    
    var teachersLoaded = false
    var studentsLoaded = false
    
    var teachers = [[User]]()
    var students = [[User]]()
    
    static var isPullingData = false
    
    weak var delegate: GoogleClassroomDelegate?
    
    private var observer : NSObjectProtocol!
    
    private let service = GTLRClassroomService()
    override init(){
        super.init()
        
        
        if GIDSignIn.sharedInstance().currentUser?.authentication.fetcherAuthorizer() != nil{
            if !GoogleDataClass.isPullingData{
                print("HelloWOlrd")
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
            print("No Courses\n")
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
                    self?.teachers.append([User]())
                    return
                }
                
                guard let teachers = result as? GTLRClassroom_ListTeachersResponse else{
                    print("Error getting teachesr\n\n")
                    self?.teachers.append([User]())
                    return
                }
                
                var firTeachers = [User]()
                
                teachers.teachers!.forEach(){
                    self?.allClassroomTeachers.append($0)
                    print("TeacherUSER: \($0.userId!) \tEMAIL: \($0.profile!.emailAddress!) \tNAME:\($0.profile!.name!.fullName!)")
                    if let index = firebaseData.allTeachers.index(of: User(email: $0.profile!.emailAddress!)){
                        firTeachers.append(firebaseData.allTeachers[index])
                    }
                }
                self?.teachers.append(firTeachers)
                count += 1
                if count == self?.courses.count{
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
                if let error = error{
                    print("Error: \(error)")
                    self?.students.append([User]())
                    return
                }
                
                guard let students = result as? GTLRClassroom_ListStudentsResponse else{
                    print("Error getting students")
                    self?.students.append([User]())
                    return
                }
                
                var firStudents = [User]()
                
                students.students!.forEach() {
                    self?.allClassroomStudents.append($0)
                    print("StudentUSER: \($0.userId!) \tEMAIL: \($0.profile!.emailAddress!) \tNAME:\($0.profile!.name!.fullName!)")
                    if let index = firebaseData.allStudents.index(of: User(email: $0.profile!.emailAddress!)){
                        firStudents.append(firebaseData.allStudents[index])
                    }
                }
                self?.students.append(firStudents)
                count += 1
                if count == self?.courses.count{
                    self?.studentsLoaded = true
                    self?.usersLoaded()
                }
            })
        }
    }
    
    private func usersLoaded(){
        if teachersLoaded && studentsLoaded{
            GoogleDataClass.isPullingData = false
        }
    }
}

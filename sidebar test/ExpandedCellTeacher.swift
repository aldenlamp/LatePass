//
//  ExpandedCell.swift
//  sidebar test
//
//  Created by alden lamp on 9/22/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase

protocol ExpandedViewControllerDelegate: class {
    func willDismiss()
}

class ExpandedCellTeacher: UIViewController, ExpandCellInfoDelegate, SelectTeacherDelegate {
    
    
    
    private var historyData: HistoryData!
    
    private var viewDidInit = false
    
    weak public var delegate: ExpandedViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    func update(from data: HistoryData){
        
        historyData = data
        
        if !viewDidInit{
            setUpCancelButton()
            setUpTitleLabels()
            setUpInfoDisplay()
            setUpSelectionView()
            setUpCenterView()
            viewDidInit = true
        }
        
        dateLabel.text = data.getDateString()
        titleLabel.text = data.toStringReadable()
        
        if data.thisCellType == .request && firebaseData.currentUser.userType == .teacher{
            centerSectionView.isHidden = true
            centerSelectionView.isHidden = false
        }else{
            centerSelectionView.isHidden = true
            centerSectionView.isHidden = false
        }
        updateCenterViews(with: data)
        
        reasonView.setViews(title: "Reason", info: data.reason == "" ? "..." : data.reason)
        timeApproved.setViews(title: "Time Accepted", info: data.getTimeString(fromStarted: false))
        timeRequested.setViews(title: "Time Requested", info: data.getTimeString())
        
        if firebaseData.currentUser.userType != .student{
            originDestination.setViews(title: data.thisCellType == cellTypes.toHistory ? "Origin" : "Destination", info: data.thisCellType == cellTypes.toHistory ? data.origin.userName : data.destination?.userName ?? "...")
            originDestination.isHidden = false
        }else{
            if data.destination == nil{
                originDestination.setViews(title: "Destination", info: "", isSelecting: true)
                originDestination.isHidden = false
            }else{
                originDestination.isHidden = true
            }
            
        }
        
    }
    
    //MARK: - Title Label
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "Avenir-Light", size: 22)
        titleLabel.textColor = UIColor.textColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return titleLabel
    }()
    
    let dateLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "Avenir-Light", size: 22)
        titleLabel.textColor = UIColor.textColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return titleLabel
    }()
    
    let breakView: UIView = {
        let breakView = UIView()
        breakView.backgroundColor = UIColor(hex: "79D6DC", alpha: 1)
        breakView.translatesAutoresizingMaskIntoConstraints = false
        breakView.widthAnchor.constraint(equalToConstant: 92).isActive = true
        breakView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return breakView
    }()
    
    func setUpTitleLabels(){
        self.view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 73).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        
        //        dateLabel.text = "" //Change Later
        self.view.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        self.view.addSubview(breakView)
        breakView.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 17).isActive = true
        breakView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    }
    
    //MARK: - Cancel Button
    func setUpCancelButton(){
        let button = UIButton()
        button.image(for: .normal)
        button.setImage(#imageLiteral(resourceName: "icons8-delete_sign_filled"), for: .normal)
        button.frame = CGRect(x: 28, y: 41, width: 21, height: 21)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc private func cancel(){
        if let del = delegate{
            del.willDismiss()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //TODO: - Allow pending passes to be accepted or rejceted
    
    //MARK: - Info Display
    
    
    var originDestination = ExpandedCellInfo()
    var timeRequested = ExpandedCellInfo()
    var timeApproved = ExpandedCellInfo()
    var reasonView = ExpandedCellInfo()
    
    func setUpInfoDisplay(){
        let width = self.view.frame.width
        
        reasonView = ExpandedCellInfo(superWidth: width, isReason: true)
        self.view.addSubview(reasonView)
        reasonView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45).isActive = true
        reasonView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 45).isActive = true
        reasonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -35).isActive = true
        
        timeApproved = ExpandedCellInfo(superWidth: width)
        self.view.addSubview(timeApproved)
        timeApproved.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45).isActive = true
        timeApproved.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 45).isActive = true
        timeApproved.bottomAnchor.constraint(equalTo: reasonView.topAnchor, constant: 0).isActive = true
        
        timeRequested = ExpandedCellInfo(superWidth: width)
        self.view.addSubview(timeRequested)
        timeRequested.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45).isActive = true
        timeRequested.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 45).isActive = true
        timeRequested.bottomAnchor.constraint(equalTo: timeApproved.topAnchor, constant: 0).isActive = true
        
        originDestination = ExpandedCellInfo(superWidth: width)
        originDestination.delegate = self
        self.view.addSubview(originDestination)
        originDestination.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45).isActive = true
        originDestination.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 45).isActive = true
        originDestination.bottomAnchor.constraint(equalTo: timeRequested.topAnchor, constant: 0).isActive = true
    }
    
    let selectedVC = SelectTeachers()
    func shouldShowSelectTeacher() {
        selectedVC.delegate = self
        selectedVC.singleConfirmation = true
        selectedVC.isFirstSelecion = false
        present(selectedVC, animated: true, completion: nil)
    }
    
    
    func didSelectDestination(user: User) {
        
        let userString = user.isPotential ? user.userEmail.replacingOccurrences(of: ".", with: "%2E") : user.userStringID
//
//            else{
//            selectedVC.dismiss(animated: true, completion: nil)
//            alert(title: "Not an Existing User", message: "The user you selected is not currently in our database. A new feature will shortly be added to automatically email them instead", buttonTitle: "Done")
//            return
//        }
        
        if user == historyData.origin{
            selectedVC.dismiss(animated: true, completion: nil)
            alert(title: "Bad Destination", message: "A destination cannot be the same as the origin")
            return
        }
        
        self.addLoadingView(with: "Adding Destination")
        FirebaseRequests.addDestination(to: historyData.ID, withUser: userString!) { [weak self] (title, message, buttonTitle, worked) in
            
            self?.removeLoadingView{
                
                if worked{
                    if let data = self?.historyData{
                        let newData = HistoryData(ID: data.ID, origin: data.origin, destination: user, student: data.student, timeStarted: data.timeStarted, timeCompleted: data.timeCompleted, reason: data.reason, status: data.status, cellType: data.thisCellType)
                        self?.update(from: newData)
                    }
                    //                    self?.historyData.destination = user
                    
                }else{
                    self?.alert(title: title, message: message, buttonTitle: buttonTitle)
                }
            }
        }
        
        
    }
    
    func didSelectFirst(users: [User]) {
    }
    
    //MARK: - Center View
    
    let centerSectionView = UIView()
    let centerTitleLabel = UILabel()
    let centerImageView = UIImageView()
    
    func setUpCenterView(){
        self.view.addSubview(centerSectionView)
        centerSectionView.translatesAutoresizingMaskIntoConstraints = false
        centerSectionView.topAnchor.constraint(equalTo: breakView.bottomAnchor, constant: 10).isActive = true
        centerSectionView.bottomAnchor.constraint(equalTo: firebaseData.currentUser.userType == .student ? timeRequested.topAnchor : originDestination.topAnchor, constant: -10).isActive = true
        
        let centerView = UIView()
        centerSectionView.addSubview(centerView)
        centerView.backgroundColor = UIColor(hex: "F8F8F8", alpha: 1)
        centerView.translatesAutoresizingMaskIntoConstraints = false
        centerView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        centerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -35).isActive = true
        centerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 35).isActive = true
        centerView.centerYAnchor.constraint(equalTo: centerSectionView.centerYAnchor, constant: 0).isActive = true
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        
        centerView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 160).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerView.centerYAnchor, constant: 0).isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerView.centerXAnchor, constant: 0).isActive = true
        
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(centerImageView)
        centerImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        centerImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        centerImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        centerImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        centerTitleLabel.font = UIFont(name: "Avenir-Book", size: 22)
        centerTitleLabel.textColor = UIColor.textColor
        centerTitleLabel.textAlignment = .right
        
        centerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(centerTitleLabel)
        centerTitleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        centerTitleLabel.leftAnchor.constraint(equalTo: centerImageView.rightAnchor, constant: 10).isActive = true
        centerTitleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        centerTitleLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func updateCenterViews(with data: HistoryData){
        switch data.status {
        case .accepted:
            centerTitleLabel.text = "Approved"
        case .pending:
            centerTitleLabel.text = "Pending"
        case .rejected:
            centerTitleLabel.text = "Rejected"
        }
        
        centerImageView.image = data.image
    }
    
    //MARK: - Selection View
    
    
    let centerSelectionView = UIView()
    
    func setUpSelectionView(){
        self.view.addSubview(centerSelectionView)
        
        centerSelectionView.translatesAutoresizingMaskIntoConstraints = false
        centerSelectionView.topAnchor.constraint(equalTo: breakView.bottomAnchor, constant: 10).isActive = true
        centerSelectionView.bottomAnchor.constraint(equalTo: timeRequested.topAnchor, constant: -10).isActive = true
        centerSelectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        centerSelectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        let centerView = UIView()
        centerSelectionView.addSubview(centerView)
        centerView.translatesAutoresizingMaskIntoConstraints = false
        centerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        centerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -35).isActive = true
        centerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 35).isActive = true
        centerView.centerYAnchor.constraint(equalTo: centerSelectionView.centerYAnchor, constant: 0).isActive = true
        
        let acceptView = UIButton()
        centerView.addSubview(acceptView)
        acceptView.addTarget(self, action: #selector(tapAccepted), for: .touchUpInside)
        acceptView.backgroundColor = UIColor(hex: "F6F6F6", alpha: 1)
        acceptView.translatesAutoresizingMaskIntoConstraints = false
        acceptView.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 0).isActive = true
        acceptView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 0).isActive = true
        acceptView.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 0).isActive = true
        
        let acceptImageView = UIImageView()
        acceptImageView.image = #imageLiteral(resourceName: "approved-lightBlue")
        acceptImageView.translatesAutoresizingMaskIntoConstraints = false
        acceptView.addSubview(acceptImageView)
        acceptImageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        acceptImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        acceptImageView.centerXAnchor.constraint(equalTo: acceptView.centerXAnchor, constant: 0).isActive = true
        acceptImageView.topAnchor.constraint(equalTo: acceptView.topAnchor, constant: 10).isActive = true
        
        
        let acceptLabel = UILabel()
        acceptLabel.text = "Accept"
        acceptLabel.font = UIFont(name: "Avenir-Book", size: 20)
        acceptLabel.textColor = UIColor.textColor
        acceptLabel.textAlignment = .center
        
        acceptLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptView.addSubview(acceptLabel)
        acceptLabel.topAnchor.constraint(equalTo: acceptImageView.bottomAnchor, constant: 0).isActive = true
        acceptLabel.rightAnchor.constraint(equalTo: acceptView.rightAnchor, constant: 0).isActive = true
        acceptLabel.leftAnchor.constraint(equalTo: acceptView.leftAnchor, constant: 0).isActive = true
        acceptLabel.bottomAnchor.constraint(equalTo: acceptView.bottomAnchor, constant: 0).isActive = true
        
        let rejectView = UIButton()
        centerView.addSubview(rejectView)
        rejectView.addTarget(self, action: #selector(tapRejected), for: .touchUpInside)
        
        rejectView.backgroundColor = UIColor(hex: "F6F6F6", alpha: 1)
        rejectView.translatesAutoresizingMaskIntoConstraints = false
        rejectView.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 0).isActive = true
        rejectView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 0).isActive = true
        rejectView.rightAnchor.constraint(equalTo: centerView.rightAnchor, constant: 0).isActive = true
        rejectView.leftAnchor.constraint(equalTo: acceptView.rightAnchor, constant: 20).isActive = true

        NSLayoutConstraint(item: rejectView, attribute: .width, relatedBy: .equal, toItem: acceptLabel, attribute: .width, multiplier: 1, constant: 0).isActive = true
        
        let rejectImageView = UIImageView()
        rejectImageView.image = #imageLiteral(resourceName: "rejected-red")

        rejectImageView.translatesAutoresizingMaskIntoConstraints = false
        rejectView.addSubview(rejectImageView)
        rejectImageView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        rejectImageView.widthAnchor.constraint(equalToConstant: 42).isActive = true
        rejectImageView.centerXAnchor.constraint(equalTo: rejectView.centerXAnchor, constant: 0).isActive = true
        rejectImageView.topAnchor.constraint(equalTo: rejectView.topAnchor, constant: 10).isActive = true


        let rejectLabel = UILabel()
        rejectLabel.text = "Reject"
        rejectLabel.font = UIFont(name: "Avenir-Book", size: 20)
        rejectLabel.textColor = UIColor.textColor
        rejectLabel.textAlignment = .center

        rejectLabel.translatesAutoresizingMaskIntoConstraints = false
        rejectView.addSubview(rejectLabel)
        rejectLabel.topAnchor.constraint(equalTo: rejectImageView.bottomAnchor, constant: 0).isActive = true
        rejectLabel.rightAnchor.constraint(equalTo: rejectView.rightAnchor, constant: 0).isActive = true
        rejectLabel.leftAnchor.constraint(equalTo: rejectView.leftAnchor, constant: 0).isActive = true
        rejectLabel.bottomAnchor.constraint(equalTo: rejectView.bottomAnchor, constant: 0).isActive = true
        
        self.view.layoutIfNeeded()
    }
    
    //MARK: - Accept or Reject LatePass
    
    @objc func tapAccepted(){ respondToRequest(withAccept: true) }
    
    @objc func tapRejected(){ respondToRequest(withAccept: false) }
    
    func respondToRequest(withAccept accepted: Bool){
//        print("pass is \(accepted ? "accepted" : "rejected")")
        
        self.addLoadingView(with: "\(accepted ? "Accepting" : "Rejecting") Pass")
        FirebaseRequests.acceptPass(withStatus: accepted, data: historyData) { [weak self] (title, message, buttonTitle, worked) in
            print("\(title)\t\(message)\t\(buttonTitle)\t\(worked)")
            self?.removeLoadingView {
                if worked{
                    if let del = self?.delegate{
                        del.willDismiss()
                    }
                    self?.dismiss(animated: true, completion: nil)
                }else{
                    self?.alert(title: title, message: message, buttonTitle: buttonTitle)
                }
            }
        }
    }
    
}


extension UIView{
    func addSep(){
        let sep = UIView()
        sep.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        
        self.addSubview(sep)
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        sep.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        sep.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        sep.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
}




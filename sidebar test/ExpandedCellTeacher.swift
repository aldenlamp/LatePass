//
//  ExpandedCell.swift
//  sidebar test
//
//  Created by alden lamp on 9/22/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase

class ExpandedCellTeacher: UIViewController {
    
    var historyData: HistoryData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setUpCancelButton()
        setUpTitleLabels()
        setUpInfoDisplay()
        if historyData.thisCellType == .request && firebaseData.currentUser.userType == .teacher{
            setUpSelectionView()
        }else{
            setUpCenterView()
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
        //        titleLabel.text = "May 23, 2017"
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
        self.dismiss(animated: true, completion: nil)
    }
    
    //TODO: - Allow pending passes to be accepted or rejceted
    
    //MARK: - Info Display
    
    
    var timeRequested = UIView()
    var timeApproved = UIView()
    var reasonView = UIView()
    
    func setUpInfoDisplay(){
        timeRequested = getTimeView(fromAccepted: false)
        timeApproved = getTimeView(fromAccepted: true)
        reasonView = getReasonView()
        
        reasonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        timeApproved.bottomAnchor.constraint(equalTo: reasonView.topAnchor, constant: 0).isActive = true
        timeRequested.bottomAnchor.constraint(equalTo: timeApproved.topAnchor, constant: 0).isActive = true
    }
    
    
    func getTimeView(fromAccepted style: Bool) -> UIView{
        let timeView = UIView()
        self.view.addSubview(timeView)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        timeView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45).isActive = true
        timeView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 45).isActive = true
        
        let timeIdentifier = UILabel()
        timeIdentifier.text = style ? "Time Approved" : "Time Requested"
        timeIdentifier.font = UIFont(name: "Avenir-Medium", size: 15)
        timeIdentifier.textColor = UIColor.textColor
        timeIdentifier.textAlignment = .left
        
        timeView.addSubview(timeIdentifier)
        timeIdentifier.translatesAutoresizingMaskIntoConstraints = false
        timeIdentifier.heightAnchor.constraint(equalToConstant: 60).isActive = true
        timeIdentifier.centerYAnchor.constraint(equalTo: timeView.centerYAnchor, constant: 0).isActive = true
        timeIdentifier.leftAnchor.constraint(equalTo: timeView.leftAnchor, constant: 0).isActive = true
        
        let time = UILabel()
        time.text = getTimeString(fromAccepted: style)
        time.textColor = UIColor.textColor
        time.font = UIFont(name: "Avenir-Medium", size: 16)
        time.textAlignment = .right
        time.adjustsFontSizeToFitWidth = true
        
        timeView.addSubview(time)
        time.translatesAutoresizingMaskIntoConstraints = false
        time.heightAnchor.constraint(equalToConstant: 60).isActive = true
        time.rightAnchor.constraint(equalTo: timeView.rightAnchor, constant: 0).isActive = true
        time.leftAnchor.constraint(equalTo: timeView.leftAnchor, constant: 115).isActive = true
        time.centerYAnchor.constraint(equalTo: timeView.centerYAnchor, constant: 0).isActive = true
        
        let sep = UIView()
        sep.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        
        timeView.addSubview(sep)
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        sep.rightAnchor.constraint(equalTo: timeView.rightAnchor, constant: 0).isActive = true
        sep.leftAnchor.constraint(equalTo: timeView.leftAnchor, constant: 0).isActive = true
        sep.bottomAnchor.constraint(equalTo: timeView.bottomAnchor, constant: 0).isActive = true
        
        return timeView
    }
    
    func getReasonView() -> UIView{
        
        let reasonView = UIView()
        
        self.view.addSubview(reasonView)
        reasonView.translatesAutoresizingMaskIntoConstraints = false
        
        let reasonIdentifier = UILabel()
        reasonIdentifier.text = "Reason"
        reasonIdentifier.font = UIFont(name: "Avenir-Medium", size: 15)
        reasonIdentifier.textColor = UIColor.textColor
        reasonIdentifier.textAlignment = .left
        
        reasonView.addSubview(reasonIdentifier)
        reasonIdentifier.translatesAutoresizingMaskIntoConstraints = false
        reasonIdentifier.topAnchor.constraint(equalTo: reasonView.topAnchor, constant: 15).isActive = true
        reasonIdentifier.leftAnchor.constraint(equalTo: reasonView.leftAnchor, constant: 0).isActive = true
        
        let reason = UILabel()
        reason.text = historyData.reason == "" ? "..." : historyData.reason
        //        reason.text = "THIS IS A REALLY LONG MESSAGE IN ORDDER TO TEST THINGS"
        reason.textColor = UIColor.textColor
        reason.font = UIFont(name: "Avenir-Medium", size: 16)
        reason.textAlignment = .right
        reason.numberOfLines = 3
        
        let maxSize = CGSize(width: self.view.frame.width - (90), height: CGFloat.greatestFiniteMagnitude)
        let requiredSize = reason.sizeThatFits(maxSize)
        
        reasonView.addSubview(reason)
        reason.translatesAutoresizingMaskIntoConstraints = false
        reason.topAnchor.constraint(equalTo: reasonView.topAnchor, constant: 15).isActive = true
        reason.rightAnchor.constraint(equalTo: reasonView.rightAnchor, constant: 0).isActive = true
        reason.widthAnchor.constraint(equalToConstant: (self.view.frame.width - (90) - 100)).isActive = true
        
        
        reasonView.heightAnchor.constraint(equalToConstant: requiredSize.height + 50).isActive = true
        reasonView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45).isActive = true
        reasonView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 45).isActive = true
        return reasonView
    }
    
    func getTimeString(fromAccepted style: Bool) -> String{
        if style && historyData.timeCompleted == nil{
            return "..."
        }
        let date = Date(timeIntervalSince1970: TimeInterval((style ? historyData.timeCompleted : historyData.timeStarted)!))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        var hour = Int(formatter.string(from: date))!
        if (hour > 12){
            hour -= 12
        }
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = ":mm a"
        
        return "\(hour)\(formatter.string(from: date))"
    }
    
    //MARK: - Center View
    
    func setUpCenterView(){
        
        let centerSectionView = UIView()
        self.view.addSubview(centerSectionView)
        centerSectionView.translatesAutoresizingMaskIntoConstraints = false
        centerSectionView.topAnchor.constraint(equalTo: breakView.bottomAnchor, constant: 10).isActive = true
        centerSectionView.bottomAnchor.constraint(equalTo: timeRequested.topAnchor, constant: -10).isActive = true
        
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
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "pending-lightBlue")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = historyData.image
        
        switch historyData.status {
        case .accepted:
            labelView.text = "Approved"
        case .pending:
            labelView.text = "Pending"
        case .rejected:
            labelView.text = "Rejected"
        }
        
        labelView.font = UIFont(name: "Avenir-Book", size: 22)
        labelView.textColor = UIColor.textColor
        labelView.textAlignment = .right
        
        containerView.addSubview(labelView)
        labelView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        labelView.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        labelView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        labelView.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    
    
    
    //MARK: - Selection View
    func setUpSelectionView(){
        
        let centerSectionView = UIView()
        self.view.addSubview(centerSectionView)
        
        centerSectionView.translatesAutoresizingMaskIntoConstraints = false
        centerSectionView.topAnchor.constraint(equalTo: breakView.bottomAnchor, constant: 10).isActive = true
        centerSectionView.bottomAnchor.constraint(equalTo: timeRequested.topAnchor, constant: -10).isActive = true
        centerSectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        centerSectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        let centerView = UIView()
        centerSectionView.addSubview(centerView)
        centerView.translatesAutoresizingMaskIntoConstraints = false
        centerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        centerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -35).isActive = true
        centerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 35).isActive = true
        centerView.centerYAnchor.constraint(equalTo: centerSectionView.centerYAnchor, constant: 0).isActive = true
        
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
        
        FirebaseRequests.acceptPass(withStatus: accepted, data: historyData) { (title, message, buttonTitle, worked) in
            print("\(title)\t\(message)\t\(buttonTitle)\t\(worked)")
            if worked{
                self.dismiss(animated: true, completion: nil)
            }else{
                self.alert(title: title, message: message, buttonTitle: buttonTitle)
            }
        }
        
        
//        
//        let rqID = historyData.ID
//        
//        FIRAuth.auth()!.currentUser!.getTokenForcingRefresh(true, completion: { [weak self] (token, error) in
//            if error == nil{
//                
//                let requestURL = "https://us-central1-late-pass-lab.cloudfunctions.net/app/approve"
//                var request = URLRequest(url: URL(string: requestURL)!)
//                request.httpMethod = "POST"
//                request.addValue("application/json", forHTTPHeaderField: "Content-type")
//                request.addValue(token!, forHTTPHeaderField: "Authorization")
//                
//                request.httpBody = "{\"request\":\"\(rqID)\",\"approval\":\(accepted)}".data(using: String.Encoding.utf8)
//                
//                print(String(data: request.httpBody!, encoding: String.Encoding.utf8)!)
//                
//                URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, _) in
//                    
//                    let responseMessage: String = String(data: data!, encoding: String.Encoding.utf8)!
//                    print("\nData: \(responseMessage) \n\n")
//                    
//                    if responseMessage != ""{
//                        self?.alert(title: "Request Error: \(responseMessage)", message: "A LatePass Could not Be Created", buttonTitle: "Okay")
//                        if let httpResponse = response as? HTTPURLResponse { print("response: \(httpResponse.statusCode)\n") }
//                        if let httpResponse = response as? HTTPURLResponse { print("response: \(httpResponse)\n\n") }
//                    }else{
//                        
//                        //TODO: - create a notification for updating the tableView in new tableView View
////                        (self?.navigationController!.viewControllers[0] as! Home).historyTableView.reloadData()
//                        self?.dismiss(animated: true, completion: nil)
//                    }
//                }).resume()
//            }else{
//                print("FIRSTERROR: \(String(describing: error))")
//            }
//        })
    }
    
    
    
}





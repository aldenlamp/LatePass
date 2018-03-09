//
//  NotificationView.swift
//  sidebar test
//
//  Created by alden lamp on 3/1/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import UIKit

protocol NotificationDelegate: class{
    func didDissmissView()
    func didRespondTo(historyData data: HistoryData, with accepted: Bool)
}

class NotificationView: UIView{
    
    var delegate: NotificationDelegate?
    
    //TODO: - This is temporary
    var noNotifications = UILabel()
    
    let iconImage = UIImageView()
    var titleLabel = UILabel()
    
    var dateLabel = UILabel()
    var timeLabel = UILabel()
    
    var stackView = UIStackView()
    
    var dismissView = UIButton()
    var responseView = UIStackView()
    
    var currentHistoryData: HistoryData?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateViewWith(historyData data: HistoryData?){
        currentHistoryData = data
        if let data = data{
            iconImage.image = data.image
            titleLabel.text = data.toStringReadable()
            dateLabel.text = data.getDateString()
            timeLabel.text = data.getTimeString()
            stackView.isHidden = false
            iconImage.isHidden = false
            titleLabel.isHidden = false
            dismissView.isHidden = data.status == .pending
            responseView.isHidden = data.status != .pending
            noNotifications.isHidden = true
        }else{
            stackView.isHidden = true
            iconImage.isHidden = true
            titleLabel.isHidden = true
            dismissView.isHidden = true
            responseView.isHidden = true
            noNotifications.isHidden = false
            //TODO: - Show empty view
        }
    }
    
    //MARK: - User Response
    
    @objc func didAccept(){
        delegate?.didRespondTo(historyData: currentHistoryData!, with: true)
    }
    
    @objc func didReject(){
        delegate?.didRespondTo(historyData: currentHistoryData!, with: false)
    }
    
    @objc func didDismiss(){
        delegate?.didDissmissView()        
    }
    
    //MARK: - Setting Up Views
    
    private func setUpViews(){
        setUpImageView()
        setUpTitleView()
        setUpDateAndTime()
        setUpNoNotifications()
        setUpDismissView()
        setUpResponseView()
        updateViewWith(historyData: nil)
    }
    
    private func setUpNoNotifications(){
        noNotifications = createLabel(withSize: 19)
        noNotifications.textAlignment = .center
        noNotifications.text = "There are no recent responses"
        noNotifications.isHidden = true
        
        self.addSubview(noNotifications)
        noNotifications.topAnchor.constraint(equalTo: self.topAnchor, constant: 90).isActive = true
        noNotifications.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        noNotifications.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    private func setUpImageView(){
        self.addSubview(iconImage)
        
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iconImage.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        iconImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
    }
    
    private func setUpTitleView(){
        titleLabel = createLabel(withSize: 19)
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.iconImage.bottomAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    private func setUpDateAndTime(){
        dateLabel = createLabel(withSize: 15)
        timeLabel = createLabel(withSize: 15)
        
        stackView = UIStackView(arrangedSubviews: [createImagedLabel(image: #imageLiteral(resourceName: "timeIcon"), isDate: false), createImagedLabel(image: #imageLiteral(resourceName: "dateIcon"), isDate: true)])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 6
        
        self.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
    }
    
    private func setUpDismissView(){
        dismissView = createButton()
        dismissView.setTitle("Dismiss", for: .normal)
        
        dismissView.addTarget(self, action: #selector(didDismiss), for: .touchUpInside)
        
        self.addSubview(dismissView)
        dismissView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        dismissView.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 20).isActive = true
    }
    
    private func setUpResponseView(){
        let accept = createButton()
        accept.setTitle("Accept", for: .normal)
        accept.addTarget(self, action: #selector(didAccept), for: .touchUpInside)
        
        let reject = createButton()
        reject.setTitle("Reject", for: .normal)
        reject.addTarget(self, action: #selector(didReject), for: .touchUpInside)
        
        responseView = UIStackView(arrangedSubviews: [accept, reject])
        responseView.translatesAutoresizingMaskIntoConstraints = false
        responseView.axis = .horizontal
        responseView.distribution = .fill
        responseView.alignment = .center
        responseView.spacing = 8
        
        self.addSubview(responseView)
        responseView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        responseView.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 20).isActive = true
        responseView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        responseView.widthAnchor.constraint(equalToConstant: 258).isActive = true
    }
    
    private func createImagedLabel(image: UIImage, isDate: Bool) -> UIView{
        
        let label = isDate ? dateLabel : timeLabel
        
        let totalView = UIView()
        totalView.translatesAutoresizingMaskIntoConstraints = false
        totalView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        totalView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = image
        icon.heightAnchor.constraint(equalToConstant: 19).isActive = true
        icon.widthAnchor.constraint(equalToConstant: isDate ? 17 : 19).isActive = true
        
        totalView.addSubview(icon)
        
        icon.topAnchor.constraint(equalTo: totalView.topAnchor, constant: 0.5).isActive = true
        icon.bottomAnchor.constraint(equalTo: totalView.bottomAnchor, constant: -0.5).isActive = true
        icon.leftAnchor.constraint(equalTo: totalView.leftAnchor, constant: 0).isActive = true
        
        totalView.addSubview(label)
        
        label.rightAnchor.constraint(equalTo: totalView.rightAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: totalView.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: totalView.bottomAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 5).isActive = true
        
        return totalView
    }
    
    private func createButton() -> UIButton{
        let button = UIButton()
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)
        button.setTitleColor(UIColor(hex: "55596B", alpha: 1), for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 125).isActive = true
        return button
    }
    
    private func createLabel(withSize size: Int) -> UILabel{
        let label = UILabel()
        label.textColor = UIColor(hex: "55596B", alpha: 1)
        label.font = UIFont(name: "Avenir-Medium", size: CGFloat(size))
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
}


//
//  NotificationTableViewCell.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 07/04/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var telNumberLabel: UILabel!
    @IBOutlet weak var propertyCodeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func bibdData(notification: FBNotification) {
        
        var phone = notification.phoneNumber
        
        if notification.additionalPhoneNumber != "" {
            phone = phone + ", " + notification.additionalPhoneNumber
        }
        
        let newDateFormatter = dateFormatter()
        newDateFormatter.dateFormat = "dd.MM.YYYY"
        
        fullNameLabel.text = notification.buyerFullName
        telNumberLabel.text = phone
        
        propertyCodeLabel.text = notification.propertyReference
        dateLabel.text = newDateFormatter.string(from: notification.createdAt)
    }

}

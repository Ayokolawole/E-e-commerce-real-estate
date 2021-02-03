//
//  FBNotification.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 06/04/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import Foundation

class FBNotification {
    
    var notificationId: String
    let createdAt: Date
    
    let propertyReference: String
    let propertyObjectId: String
    let buyerFullName: String
    var buyerId: String
    var agentId: String
    var phoneNumber: String
    var additionalPhoneNumber: String
    
    //MARK: Initializers
    
    init(_buyerId: String, _agentId: String, _createdAt: Date, _phoneNumber: String, _additionalPhoneNumber: String = "", _buyerFullName: String, _propertyReference: String, _propertyObjectId: String) {
        
        notificationId = ""
        
        createdAt = _createdAt
        buyerFullName = _buyerFullName
        
        buyerId = _buyerId
        agentId = _agentId
        phoneNumber = _phoneNumber
        additionalPhoneNumber = _additionalPhoneNumber
        propertyReference = _propertyReference
        propertyObjectId = _propertyObjectId
    }
    
    init(_dictionary: NSDictionary) {
        
        notificationId = _dictionary[kNOTIFICATIONID] as! String
        
        if let created = _dictionary[kCREATEDAT] {
            
            createdAt = dateFormatter().date(from: created as! String)!
        } else {
            createdAt = Date()
        }
        
        if let bId = _dictionary[kBUYERID] {
            buyerId = bId as! String
        } else {
            buyerId = ""
        }
        
        if let fname = _dictionary[kBUYERFULLNAME] {
            buyerFullName = fname as! String
        } else {
            buyerFullName = ""
        }
        
        if let aId = _dictionary[kAGENTID] {
            agentId = aId as! String
        } else {
            agentId = ""
        }
        
        if let phone = _dictionary[kPHONE] {
            phoneNumber = phone as! String
        } else {
            phoneNumber = ""
        }
        
        if let addphone = _dictionary[kADDPHONE] {
            additionalPhoneNumber = addphone as! String
        } else {
            additionalPhoneNumber = ""
        }
        
        if let propRef = _dictionary[kPROPERTYREFERENCEID] {
            propertyReference = propRef as! String
        } else {
            propertyReference = ""
        }
        
        if let propObjId = _dictionary[kPROPERTYOBJECTID] {
            propertyObjectId = propObjId as! String
        } else {
            propertyObjectId = ""
        }
        
    }
    
} //End of class

//MARK: Save notifications

func saveNotificationInBackground(fbNotification: FBNotification, completion: @escaping (_ error: Error?)-> Void) {
    
    let ref = notifRef.childByAutoId()
    
    fbNotification.notificationId = ref.key
    
    ref.setValue(notificationDictionaryFrom(fbNotification: fbNotification)) { (error, ref) in
        
        completion(error)
    }
}

func saveNotificationInBackground(fbNotification: FBNotification) {
    
    let ref = notifRef.childByAutoId()
    
    fbNotification.notificationId = ref.key
    ref.setValue(notificationDictionaryFrom(fbNotification: fbNotification))
    
}

func fetchAgentNotification(agentId: String, completion: @escaping (_ allNotifications: [FBNotification])->Void) {
    
    print("agent id = \(agentId)")
    var allNotifications: [FBNotification] = []
    var counter = 0
        
    notifHadler = firebase.child(KFBNOTIFICATIONS).queryOrdered(byChild: kAGENTID).queryEqual(toValue: agentId).observe(.value, with: { (snapshot) in
        
        if snapshot.exists() {
            print("exist")
            let allFbn = ((snapshot.value as! NSDictionary).allValues as NSArray)
            
            for fbNot in allFbn {
                print("we have notification")
                let fbNotification = FBNotification(_dictionary: fbNot as! NSDictionary)
                allNotifications.append(fbNotification)
                counter += 1
            }
            
            //check if done and return
            
            if counter == allFbn.count {
                notifRef.removeObserver(withHandle: notifHadler)
                completion(allNotifications)
            }
            
        } else {
            notifRef.removeObserver(withHandle: notifHadler)
            completion(allNotifications)
        }
        
        
    })
}

func deleteNotification(fbNotification: FBNotification) {
    
    notifRef.child(fbNotification.notificationId).removeValue()
}

func notificationDictionaryFrom(fbNotification: FBNotification) -> NSDictionary {
    
    let createdAt = dateFormatter().string(from: fbNotification.createdAt)
    
    return NSDictionary(objects: [fbNotification.notificationId, createdAt, fbNotification.buyerFullName, fbNotification.buyerId, fbNotification.agentId, fbNotification.phoneNumber, fbNotification.additionalPhoneNumber, fbNotification.propertyReference, fbNotification.propertyObjectId], forKeys: [kNOTIFICATIONID as NSCopying, kCREATEDAT as NSCopying, kBUYERFULLNAME as NSCopying, kBUYERID as NSCopying, kAGENTID as NSCopying, kPHONE as NSCopying, kADDPHONE as NSCopying, kPROPERTYREFERENCEID as NSCopying, kPROPERTYOBJECTID as NSCopying])
    
 }



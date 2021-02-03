//
//  Constants.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 14/03/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import Foundation
import Firebase

var backendless = Backendless.sharedInstance()
var firebase = Database.database().reference()

var notifHadler: UInt = 0
let notifRef = firebase.child(KFBNOTIFICATIONS)

let propertyTypes = ["Select", "Appartment", "House", "Villa", "Land", "Flat"]
let advertismentTypes = ["Select", "Sale", "Rent", "Exchange"]

//IDS AND Key
public let kONESIGNALAPPID = "8f335806-f573-44a4-b0ed-7552fdc71ace"
public let kFILEREFERENCE = "gs://university-project-912aa.appspot.com"

//FUser (FirebaseUsers)
public let kOBJECTID = "objectId"
public let kUSER = "User"
public let kCREATEDAT = "createdAt"
public let kUPDATEDAT = "updatedAt"
public let kCOMPANY = "company"
public let kPHONE = "phone"
public let kADDPHONE = "addphone"

public let kCOINS = "coins"
public let kPUSHID = "pushId"
public let kFIRSTNAME = "firstname"
public let kLASTNAME = "lastname"
public let kFULLNAME = "fullname"
public let kAVATAR = "avatar"
public let kCURRENTUSER = "currentUser"
public let kISONLINE = "isOnline"
public let kVERIFICATIONCODE = "firebase_verification"
public let kISAGENT = "isAgent"
public let kFAVORIT = "favoritProperties"

//Property
public let kMAXIMAGENUMBER = 10
public let kRECENTPROPERTYLIMIT = 20

//FBNotification
public let KFBNOTIFICATIONS = "Notifications"
public let kNOTIFICATIONID = "notificationId"
public let kPROPERTYREFERENCEID = "referenceId"
public let kPROPERTYOBJECTID = "propertyObjectedId"
public let kBUYERFULLNAME = "buyerFullName"
public let kBUYERID = "buyerId"
public let kAGENTID = "agentId"

//Push
public let kDEVICEID = "deviceId"

//other
public let kTEMPFAVORITID = "tempID"


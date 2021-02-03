//
//  FUser.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 14/03/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import Foundation
import Firebase


class FUser {
    
    let objectId: String
    var pushId: String?
    
    let createdAt: Date
    var updatedAt: Date
    
    var coins: Int
    var companyName: String
    var firstName: String
    var lastName: String
    var fullName: String
    var avatar: String
    var phoneNumber: String
    var additionalPhoneNumber: String
    var isAgent: Bool
    var favouritProperties: [String]
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _firstName: String, _lastName: String, _avatar: String = "", _phoneNumber: String = "" ) {
        
        objectId = _objectId
        pushId = _pushId
        
        createdAt = _createdAt
        updatedAt = _updatedAt
        
        coins = 10
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + "" + _lastName
        avatar = _avatar
        isAgent = false
        companyName = ""
        favouritProperties = []
        
        phoneNumber = _phoneNumber
        additionalPhoneNumber = ""
        
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        if let created = _dictionary[kCREATEDAT] {
            createdAt = dateFormatter().date(from: created as! String)!
        }else{
           createdAt = Date()
        }
        if let updated = _dictionary[kUPDATEDAT] {
            updatedAt = dateFormatter().date(from: updated as! String)!
        }else{
           updatedAt = Date()
        }
        if let dcoin = _dictionary[kCOINS] {
            coins = dcoin as! Int
        }else{
            coins = 0
        }
        if let comp = _dictionary[kCOMPANY] {
            companyName = comp as! String
        }else{
           companyName = ""
        }
        if let fname = _dictionary[kFIRSTNAME] {
            firstName = fname as! String
        }else{
           firstName = ""
        }
        if let lname = _dictionary[kLASTNAME] {
            lastName = lname as! String
        }else{
           lastName = ""
        }
        fullName = firstName + " " + lastName
        if let avat = _dictionary[kAVATAR] {
            avatar = avat as! String
        }else{
            avatar = ""
        }
        if let agent = _dictionary[kISAGENT] {
            isAgent = agent as! Bool
        }else{
            isAgent = false
        }
        if let phone = _dictionary[kPHONE] {
            phoneNumber = phone as! String
        }else{
            phoneNumber = ""
        }
        if let addphone = _dictionary[kADDPHONE] {
            additionalPhoneNumber = addphone as! String
        }else{
            additionalPhoneNumber = ""
        }
        if let favProp = _dictionary[kFAVORIT] {
            favouritProperties = favProp as! [String]
        }else{
            favouritProperties = []
        }
    }
    
    class func currentId() -> String {
        
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> FUser? {
        
        if Auth.auth().currentUser != nil {
            
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                
                return FUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    }
    
    class func registerUserWith(email: String, password: String, firstName: String, lastName: String, completion: @escaping (_ error: Error?)-> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (firUser, error) in
            
            if error != nil {
                completion(error)
                return
            }
            
            let fUser = FUser(_objectId: firUser!.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _firstName: firstName, _lastName: lastName)
            
            saveUserLocally(fUser: fUser)
            saveUserInBackground(fUser: fUser)
            
            completion(error)
        }
    }
    
    class func registerUserWith(phoneNumber: String, verificationCode: String, completion: @escaping (_ error: Error?, _ shouldLogin: Bool)-> Void) {
        
        let verificationID = UserDefaults.standard.value(forKey: kVERIFICATIONCODE)
        
        let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationID as! String, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credentials) { (firUser, error) in
            
            if error != nil{
                completion(error!, false)
                return
            }
            
            //check if user is logged in else register
            fetchUserWith(userId: firUser!.uid) { (user) in
                
                if user != nil && user!.firstName != "" {
                    
                    //we have user, login
                    saveUserLocally(fUser: user!)
                    completion(error, true)
                }else{
                    
                    //we have no user, register user
                    let fUser = FUser(_objectId: firUser!.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _firstName: "", _lastName: "", _phoneNumber: firUser!.phoneNumber!)
                    
                    saveUserLocally(fUser: fUser)
                    saveUserInBackground(fUser: fUser)
                    completion(error, false)
                }
            }
        }
    }
    
    //MARK: Login
    
    class func loginUserWith(email: String, password: String, withBlock: @escaping (_ error: Error?)->Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (firUser, error) in
            
            if error != nil{
                withBlock(error)
            } else {
                
                fetchUserWith(userId: firUser!.uid) { (fUser) in
                    
                    saveUserLocally(fUser: fUser!)
                }
            }
                
        }
    }
    
    //MARK: Logout
    
    class func logoutCurrentUser(withBlock: @escaping (_ succss: Bool)->Void) {
        
        UserDefaults.standard.removeObject(forKey: "OneSignalId")
        removeOneSignalId()
        
        UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
        UserDefaults.standard.synchronize()
        
        do{
            try Auth.auth().signOut()
            withBlock(true)
            
        }catch let error as NSError {
            print("logging out\(error.localizedDescription)")
            withBlock(false)
            
        }
        
        
    }
    
    class func deleteUser(completion: @escaping (_ error: Error?)->Void) {
        
        let user = Auth.auth().currentUser
        
        user?.delete(completion: { (error) in
            
            completion(error)
        })
    }
    
    
    
    

} // end of class

//MARK: Saving user

func saveUserInBackground(fUser: FUser) {
    
    let ref = firebase.child(kUSER).child(fUser.objectId)
    ref.setValue(userDictionaryFrom(user: fUser))
}

func saveUserLocally(fUser: FUser) {
    
    UserDefaults.standard.set(userDictionaryFrom(user: fUser), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}
//MARK: Helper functions

func fetchUserWith(userId: String, completion: @escaping (_ user: FUser?)->Void) {
    
    firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observeSingleEvent(of: .value) { (snapshot) in
        
        if snapshot.exists(){
            
            let userDictionary = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary
            
            let user = FUser(_dictionary: userDictionary)
            completion(user)
            
        
        }else{
           completion(nil)
        }
    }
}

func userDictionaryFrom(user: FUser) -> NSDictionary {
    
    let createdAt = dateFormatter().string(from: user.createdAt)
    let updatedAt = dateFormatter().string(from: user.updatedAt)
    
     return NSDictionary(objects: [user.objectId, createdAt, updatedAt, user.companyName, user.pushId!, user.firstName, user.lastName, user.fullName, user.avatar, user.phoneNumber, user.additionalPhoneNumber, user.isAgent, user.coins, user.favouritProperties],  forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kCOMPANY as NSCopying, kPUSHID as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kAVATAR as NSCopying, kPHONE as NSCopying, kADDPHONE as NSCopying, kISAGENT as NSCopying, kCOINS as NSCopying, kFAVORIT as NSCopying])
}



func updateCurrentUser(withValues: [String : Any], withBlock: @escaping (_ success: Bool)->Void)
   {
   
    if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
        
        let currentUser = FUser.currentUser()!
        
        let userObject = userDictionaryFrom(user: currentUser).mutableCopy() as! NSMutableDictionary
        
        userObject.setValuesForKeys(withValues)
        
        let ref = firebase.child(kUSER).child(currentUser.objectId)
        
        ref.updateChildValues(withValues) { (error, ref) in
        
            if error != nil {
                withBlock(false)
                return
            }
            
            UserDefaults.standard.setValue(userObject, forKey: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            
            withBlock(true)
        }
    }
    
}

func isUserLoggedIn(viewController: UIViewController) -> Bool {
    
    if FUser.currentUser() != nil {
        return true
    } else {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterView") as! RegisterViewController
        
        viewController.present(vc, animated: true, completion: nil)
        return false
    }
    
    
}



//MARK: OneSignal

func updateOneSignalId() {
    
    if FUser.currentUser() != nil {
        
        if let pushId = UserDefaults.standard.string(forKey: "OneSignalId") {
            setOneSignalId(pushId: pushId)
        } else {
            removeOneSignalId()
        }
    }
}

func setOneSignalId(pushId: String)  {
    updateCurrentUserOneSignald(newId: pushId)
    
    
}

func removeOneSignalId() {
    updateCurrentUserOneSignald(newId: "")
    
}

func updateCurrentUserOneSignald(newId: String){
    
    updateCurrentUser(withValues: [kPUSHID : newId, kUPDATEDAT : dateFormatter().string(from: Date())]) { (success) in
        
        print("One signal id was updated - \(success)")
    }
    
}

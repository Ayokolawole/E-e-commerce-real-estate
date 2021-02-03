//
//  Property.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 15/03/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import Foundation

@objcMembers
class Property: NSObject {
    
    var objectId : String?
    var referenceCode : String?
    var ownerId: String?
    var title: String?
    var numberOfRooms: Int = 0
    var numberOfBathrooms: Int = 0
    var size: Double = 0.0
    var balconySize: Double = 0.0
    var parking: Int = 0
    var floor: Int = 0
    var address: String?
    var city: String?
    var country: String?
    var propertyDescription: String?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var advertisementType: String?
    var availableFrom: String?
    var imageLinks: String?
    var buildYear: String?
    var price: Int = 0
    var propertyType: String?
    var titleDeeds: Bool = false
    var centralHeating: Bool = false
    var solarWaterHeating: Bool = false
    var airConditioner: Bool = false
    var storeRoom: Bool = false
    var isFurnished: Bool = false
    var isSold: Bool = false
    var inTopUntil: Date?
    
    //MARK: Save Function
    
    func saveProperty() {
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.save(self)
    }
    
    func saveProperty(completion: @escaping (_ value: String)-> Void) {
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.save(self, response: { (result) in
            completion("Success")
            
        }) { (fault: Fault?) in
            completion(fault!.message)
        }
    }
    
    //MARK: Delete functions
    
    func deleteProperty(property: Property) {
        
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.remove(property)
        
    }
    
    func deleteProperty(property: Property, completion: @escaping(_ value: String)-> Void){
        
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.remove(property, response: { (result) in
            completion("Success")
            
        }) { (fault : Fault?) in
            completion(fault!.message)
        }
    }
    
    //MARK: Search Functions
    
    class func fetchRecentProperties(limitNumber: Int, completion: @escaping (_ properties: [Property?])->Void) {
        
        let quiryBuilder = DataQueryBuilder()
        quiryBuilder!.setSortBy(["inTopUntil DESC"])
        quiryBuilder!.setPageSize(Int32(limitNumber))
        quiryBuilder!.setOffset(0)
        
        let dataStore = backendless!.data.of(Property().ofClass())
        
        dataStore!.find(quiryBuilder, response: { (backendlessProperties) in
            
            completion(backendlessProperties as! [Property])
            
        }) { (fault : Fault?) in
            print("Error, couldnt get recent properties \(fault!.message)")
            completion([])
        }
    }
    
    class func fetchAllProperties(completion: @escaping (_ properties: [Property?])->Void) {
        
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.find({ (allProperties) in
            
            completion(allProperties as! [Property])
            
        }) { (fault : Fault?) in
            print("Error, couldnt get recent properties \(fault!.message)")
            completion([])
        }
    }
    
    class func fetchPropertiesWith(whereClause: String, completion: @escaping (_ properties: [Property?])->Void) {
        
        let quiryBuilder = DataQueryBuilder()
        quiryBuilder!.setWhereClause(whereClause)
        quiryBuilder!.setSortBy(["inTopUntil DESC"])
  
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.find(quiryBuilder, response: { (allProperties) in
            
             completion(allProperties as! [Property])
            
        }) { (fault : Fault?) in
            print("Error, couldnt get recent properties \(fault!.message)")
            completion([])
        }
    }
    
    
} //end of class

func canUserPostProperty(completion: @escaping (_ canPost: Bool)->Void) {
    
    let queryBuilder = DataQueryBuilder()
    let whereClause = "ownerId = '\(FUser.currentUser())'  "
    queryBuilder!.setWhereClause(whereClause)
    
    let dataStore = backendless!.data.of(Property().ofClass())
    
    dataStore!.find(queryBuilder, response: { (allProperties) in
        
        allProperties!.count == 0 ? completion(true) : completion(false)
        
    }) { (fault : Fault?) in
        print("fault where clause \(fault!.message)")
        completion(true)
    }
}


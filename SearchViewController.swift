//
//  SearchViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 10/04/2020.
//  Copyright © 2020 Ayobami Kolwole. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PropertyCollectionViewCellDelegate, SearchParametersViewControllerDelegate{
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var properties: [Property] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: IBActions
    
    @IBAction func mixerButtonPressed(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchParameterVC") as! SearchParametersViewController
        
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: CollectionviewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PropertyCollectionViewCell
        
        cell.delegate = self
        cell.generateCell(property: properties[indexPath.row])
        
        return cell
        
    }
    
    //MARK: CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let property = properties[indexPath.row]
        
        let propertyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PropertyView") as! PropertyViewController
        
        propertyVC.property = property
        self.present(propertyVC, animated: true, completion: nil)
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           
           return CGSize(width: collectionView.bounds.size.width, height: CGFloat(254))
       }
    
    //MARK: PropertyCollectionViewCellDelegate
    
    func didClickStarButton(property: Property) {
        
              //check if we have a user
              if FUser.currentUser() != nil {
                  
              let user = FUser.currentUser()
                  
                  //check if the property is in favorit
                  if (user?.favouritProperties.contains(property.objectId!))!{ //Checks the array has this property id has current property
                  //    remove from favorit list
                  let index = user?.favouritProperties.index(of: property.objectId!)
                  user?.favouritProperties.remove(at: index!)
                      
                  updateCurrentUser(withValues: [kFAVORIT : user?.favouritProperties ]) { (success) in
                          
                  if !success {
                      print("error removing favatit")
                  } else {
                              
                      self.collectionView.reloadData()
                      ProgressHUD.showSuccess("Removed from the list")
                  }
                     }
                  } else {
                      //add to fav
                  user?.favouritProperties.append(property.objectId!)
                      
                  updateCurrentUser(withValues: [kFAVORIT : user?.favouritProperties ]) { (success) in
                                        
                  if !success {
                      print("error adding property")
                  } else {
                                            
                  self.collectionView.reloadData()
                  ProgressHUD.showSuccess("Added to the list")
               }
             }
           }
                
                  
          } else {
                  
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterView") as! RegisterViewController
                
                self.present(vc, animated: true, completion: nil)
         }
        
    }
    
   //MARK: SearchParameterDelegate
    
    func didFinishSettingParameters(whereClause: String) {
        loadProperties(whereClause: whereClause)
    }
    
    //MARK: Load Properties
    
    func loadProperties(whereClause: String) {
        
        self.properties = []
        
        Property.fetchPropertiesWith(whereClause: whereClause) { (allProperties) in
            
            if allProperties.count > 0 {
                
                self.properties = allProperties as! [Property]
                self.collectionView.reloadData()
            } else {
                
                ProgressHUD.showError("No properties for your search")
                print("no properties found")
                self.collectionView.reloadData()
            }
        }
        
    }
}

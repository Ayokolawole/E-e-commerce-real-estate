//
//  RecentViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 15/03/2020.
//  Copyright © 2020 Ayoabmi Kolawole. All rights reserved.
//

import UIKit

class RecentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PropertyCollectionViewCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var numberOfPropertiesTextField: UITextField?
    
    var properties: [Property] = []
    
    
    override func viewWillLayoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //load properties
        
        loadProperties(limitNumber: kRECENTPROPERTYLIMIT)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: CollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return properties.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PropertyCollectionViewCell
        
      cell.delegate = self
      cell.generateCell(property: properties[indexPath.row])
        
        return cell
        
    }
    
    //MARK: CollectionView Delgate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //show property
        let propertyView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PropertyView") as! PropertyViewController
        
        propertyView.property = properties[indexPath.row]
        self.present(propertyView, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(254))
    }
    
    //MARK: Load Properties
    
    func loadProperties(limitNumber: Int) {
        
        Property.fetchRecentProperties(limitNumber: limitNumber) { (allProperties) in
            
            if allProperties.count != 0 {
                self.properties = allProperties as! [Property]
                self.collectionView.reloadData()
            }
        }
        
    }
    
    //MARK: IBaction
    
    @IBAction func mixerButtonPressed(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Update", message: "Set the number of propeties to display", preferredStyle: .alert)
        
        alertController.addTextField { (numberOfProperties) in
            
            numberOfProperties.placeholder = "Number of Properties"
            numberOfProperties.borderStyle = .roundedRect
            numberOfProperties.keyboardType = .numberPad
            
            self.numberOfPropertiesTextField = numberOfProperties
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            
            if self.numberOfPropertiesTextField?.text != "" && self.numberOfPropertiesTextField!.text != "0" {
                
               ProgressHUD.show("Updating...")
               self.loadProperties(limitNumber: Int(self.numberOfPropertiesTextField!.text!)!)
            }
        }
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(updateAction)
        
        self.present(alertController, animated: true, completion: nil )
        
    }
    
    //MARK: PropertyCollectionViewDelegate
    
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
    

}

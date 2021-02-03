//
//  FavoriteViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 27/03/2020.
//  Copyright © 2020 Ayobami. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PropertyCollectionViewCellDelegate {

    @IBOutlet weak var noPropertyLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var properties: [Property] = []
    
    override func viewWillLayoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
    //if the user is logged in
        if !isUserLoggedIn(viewController: self) {
            return
        } else {
            loadProperties()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PropertyCollectionViewCell
        
        cell.delegate = self
        cell.generateCell(property: properties[indexPath.row])
        
        return cell
    }
    
    //MARK: CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let propertyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PropertyView") as! PropertyViewController
        
        propertyVC.property = properties[indexPath.row]
        self.present(propertyVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(254))
    }
    
    //MARK: LoadProperties
    
    func loadProperties() {
        
        self.properties = []
        
        let user = FUser.currentUser()!
        
        let stringArray = user.favouritProperties
        let string = "'" + stringArray.joined(separator: "', '") + "'"
        
        if  user.favouritProperties.count > 0 {
            
            let whereClause = "objectId IN (\(string))"
            
            Property.fetchPropertiesWith(whereClause: whereClause, completion:  { (allProperties) in
                
                if allProperties.count != 0 {
                    self.properties = allProperties as! [Property]
                    self.collectionView.reloadData()
                }
            })
        } else {
            self.noPropertyLabel.isHidden = false
            self.collectionView.reloadData()
        }
    }
    
    //MARK: PropertyCollectionViewCellDelegate
    
    func didClickStarButton(property: Property) {
        
        if FUser.currentUser() != nil {
            
            let user = FUser.currentUser()!
            
            if user.favouritProperties.contains(property.objectId!) {
                
                //remove from list
                let index = user.favouritProperties.index(of: property.objectId!)
                user.favouritProperties.remove(at: index!)
                
                updateCurrentUser(withValues: [kFAVORIT : user.favouritProperties]) { (success) in
                    
                    if !success {
                        print("error removing property")
                    } else {
                        self.loadProperties()
                        ProgressHUD.showSuccess("Removed from list")
                    }
                }
                
            } else {
                
                //add to the list
                user.favouritProperties.append(property.objectId!)
                updateCurrentUser(withValues: [kFAVORIT : user.favouritProperties]) { (success) in
                    
                    if !success {
                        print("error adding property")
                    } else {
                        self.loadProperties()
                        ProgressHUD.showSuccess("Added to the list")
                    }
                }
                
            }
            
            
            //we have a user
        } else {
            //no current user
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterView") as! RegisterViewController
            
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
}

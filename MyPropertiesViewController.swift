//
//  MyPropertiesViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 03/04/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit

class MyPropertiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PropertyCollectionViewCellDelegate {
    
  
    @IBOutlet weak var collectionView: UICollectionView!
    
    var properties: [Property] = []
    
    override func viewWillLayoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    if !isUserLoggedIn(viewController: self) {
        return
    } else {
        loadProperties()
      }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: collectionViewDataSource
    
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
        
        let userId = FUser.currentId()
        
        let whereClause = "ownerId = '\(userId)'"
        
        Property.fetchPropertiesWith(whereClause: whereClause) { (allProperties) in
            
            self.properties = allProperties as! [Property]
            self.collectionView.reloadData()
        }
    }
    
    //MARK: PropertyCollectionViewCellDelegate
    
    func didClickMenuButton(property: Property) {
        
        let soldStatus = property.isSold ? "Mark Available" : "Mark Sold"
        var topStatus = "Promote"
        var isInTop = false
        
        if property.inTopUntil != nil && property.inTopUntil! > Date() {
            isInTop = true
            topStatus = "Already in top"
        }
        
        let optionMenu = UIAlertController(title: "Property Menu", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit property", style: .default) { (alert) in
            
            let addPropertyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPropertyVC") as! AddPropertyViewController
            
            addPropertyVC.property = property
            self.present(addPropertyVC, animated: true, completion: nil)
        }
        
        let makeTop = UIAlertAction(title: topStatus, style: .default) { (action) in
            
            let coins = FUser.currentUser()!.coins
            
            if coins >= 1 && !isInTop {
                
                updateCurrentUser(withValues: [kCOINS : coins - 1]) { (success) in
                    
                    if success {
                        
                        let expDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                        
                        property.inTopUntil = expDate
                        property.saveProperty()
                        self.loadProperties()//refresh
                    }
                }
                
            } else {
                
                if isInTop {
                    ProgressHUD.showError("Already in Top!")
                } else {
                    ProgressHUD.showError("Insuffucuent coins!")
                }
            }
        }
        
        let soldAction = UIAlertAction(title: soldStatus, style: .default) { (action) in
            
            property.isSold = !property.isSold
            property.saveProperty()
            self.loadProperties()//refresh
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            ProgressHUD.show("Deleting...")
            property.deleteProperty(property: property) { (message) in
                
                ProgressHUD.showSuccess("Deleted!")
                self.loadProperties() //Refresh
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(makeTop)
        optionMenu.addAction(soldAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
        
    }
}

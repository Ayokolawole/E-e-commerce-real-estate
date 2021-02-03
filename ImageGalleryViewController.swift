//
//  ImageGalleryViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 05/04/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit
import ImagePicker
import IDMPhotoBrowser

protocol ImageGalleryViewControllerDelegate {
    func didFinishEditingImages(allImages: [UIImage])
}

class ImageGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImageGallaryCollectionViewCellDelegate, ImagePickerDelegate {
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var property: Property?
    var allImages: [UIImage] = []
    var delegate: ImageGalleryViewControllerDelegate?
    
    override func viewWillLayoutSubviews() {
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if property != nil {
            
           getPropertyImages(property: property!)
        }

       
    }
    
    //MARK: CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return allImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageGallaryCollectionViewCell
        
        cell.generateCell(image: allImages [indexPath.row], indexPath: indexPath)
        cell.delegate = self
        
        return cell 
    }
    
    //MARK: UICollectionViewDelegate
    
    //called when user taps on image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photos = IDMPhoto.photos(withImages: allImages)
        let browser = IDMPhotoBrowser(photos: photos)!
        browser.setInitialPageIndex(UInt(indexPath.row))
        
        self.present(browser, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width / 2 - 7, height: CGFloat(115))
    }
    
    
    //MARK: IBAction

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        delegate!.didFinishEditingImages(allImages: allImages)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = kMAXIMAGENUMBER
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: ImageGalleryCellDelegate
    
    func didClickDeleteButton(indexPath: IndexPath) {
        allImages.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    
    //MARK: Helpers
    
    func getPropertyImages(property: Property) {
        
        if property.imageLinks != "" && property.imageLinks != nil {
            
            //We have images
            downloadImages(urls: property.imageLinks!) { (images) in
                
                self.allImages = images as! [UIImage]
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.collectionView.reloadData()
            }
            
        } else {
            
            //we have no images
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.collectionView.reloadData() //refresh
        }
    }
    
    //MARK: ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        self.allImages = allImages + images
        self.collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancelled")
        
        self.dismiss(animated: true, completion: nil)
    }
}

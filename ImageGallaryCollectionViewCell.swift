//
//  ImageGallaryCollectionViewCell.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 06/04/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit

protocol ImageGallaryCollectionViewCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class ImageGallaryCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    var indexPath: IndexPath!
    var delegate: ImageGallaryCollectionViewCellDelegate?
    
    func generateCell(image: UIImage, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        self.imageView.image = image
        
    }
    
    @IBAction func deletedButtonPressed(_ sender: Any) {
        delegate?.didClickDeleteButton(indexPath: self.indexPath)
    }
    
    
}

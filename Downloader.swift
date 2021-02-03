//
//  Downloader.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 20/03/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import Foundation
import Firebase

let storage = Storage.storage()

//Function download images
func downloadImages(urls: String, withBlock: @escaping (_ image: [UIImage?])->Void) {
    
    let linkArray = separateImageLinks(allLinks: urls)
    var imageArray: [UIImage] = []
    
    var downloadCounter = 0
    
    for link in linkArray {
        
        let url = NSURL(string: link )
        
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            
            downloadCounter += 1
            
            let data = NSData(contentsOf: url! as URL)
            
            if data != nil {
                
                imageArray.append(UIImage(data: data! as Data)!)
                
                if downloadCounter == imageArray.count {
                    
                    DispatchQueue.main.async {
                        withBlock(imageArray)
                    }
                }
            } else {
                print("couldnt download image")
                withBlock(imageArray)
            }
        }
    }
}

//Upload function
func uploadImages(images: [UIImage], userId: String, referenceNumber: String, withBlock: @escaping (_ imageLink: String?) -> Void) { //Link string
    
    print("start uploading")
    convertImagesToData(images: images) { (pictures) in //Convert uiimage into NSDATA
        
        print("received images \(pictures.count)")
        
        var uploadCounter = 0 //Keeps track of how many pictures are being uploaded
        var nameSuffix = 0
        
        var linkString = ""
        
        for picture in pictures {
            
            let fileName = "PropetyImages/" + userId + "/" + referenceNumber + "/image" + "\(nameSuffix)" + ".jpg"
            
            nameSuffix += 1
            
            let storageRef = storage.reference(forURL: kFILEREFERENCE).child(fileName)
            
            var task: StorageUploadTask!
            
            task = storageRef.putData(picture, metadata: nil, completion: { (metadata, error) in
                
                uploadCounter += 1
                
                
                if error != nil {
                    print("error uploading picture \(error!.localizedDescription)")
                    return
                }
                
                print("metadata \(metadata?.downloadURL())")
                let link = metadata!.downloadURL() //Getting the link where firebase has seaved image to download
                linkString = linkString + link!.absoluteString + "," //Adds to current link string with comma
                
                if uploadCounter == pictures.count { //Check if images are uploaded
                    
                    print("finished all uploads \(linkString)")
                    task.removeAllObservers()
                    withBlock(linkString)
                    
                }
            })
        }
    }
}

//MARK: Helpers

func convertImagesToData(images: [UIImage], withBlock: @escaping(_ datas: [Data])->Void) {
    
    var dataArray: [Data] = []
    
    for image in images {
        dataArray.append(UIImageJPEGRepresentation(image, 0.5)!)
        
    }
    
    withBlock(dataArray)
}

//Return a string for the url image and puts in commas
func separateImageLinks(allLinks: String) -> [String] {
    
    var linkArray = allLinks.components(separatedBy: ",")
    linkArray.removeLast()
    
    return linkArray
}

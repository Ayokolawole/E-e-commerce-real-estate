//
//  FinishRegistrationViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 11/04/2020.
//  Copyright © 2020 Ayobami Kolawole All rights reserved.
//

import UIKit
import ImagePicker

class FinishRegistrationViewController: UIViewController, ImagePickerDelegate {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    
    var avatarImage: UIImage?
    var avatar = ""
    var company = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: IBActions
    
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func finishRegistrationButtonPressed(_ sender: Any) {
        
        if nameTextField.text != "" && surnameTextField.text != "" {
            
            ProgressHUD.showError("Registring...")
            
            if self.avatarImage != nil {
                let image = UIImageJPEGRepresentation(avatarImage!, 0.6)
                avatar = image!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            
            if companyTextField.text != "" {
                company = companyTextField.text!
            }
            
            register()
            
            
        } else {
            ProgressHUD.showError("Please input credentials")
        }
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        
        //delete user
        self.deleteUser()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Helper functions
    
    func deleteUser() {
        
        let userId = FUser.currentId()
        
        //delete user locally
        
        UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
        UserDefaults.standard.removeObject(forKey: "OneSignalId")
        UserDefaults.standard.synchronize()
        
        //log out user and delete
        
        firebase.child(kUSER).child(userId).removeValue { (error, ref) in
            
            if error != nil {
                
                print("couldnt deleteUser \(error?.localizedDescription)")
                return
            }
            
        }
        
        FUser.deleteUser { (error) in
            
            if error != nil {
                print("Error deleting \(error?.localizedDescription)")
                return
            }
            
            self.goToApp()
        }
    }
    
    
    
    func register() {
        
        let user = FUser.currentUser()!
        
        user.firstName = nameTextField.text!
        user.lastName = surnameTextField.text!
        user.fullName = nameTextField.text! + " " + surnameTextField.text!
        user.avatar = avatar
        user.companyName = company
        
        updateCurrentUser(withValues: [kFIRSTNAME: user.firstName, kLASTNAME: user.lastName, kFULLNAME : user.fullName, kAVATAR : user.avatar, kCOMPANY : user.companyName ]) { (success) in
            
            ProgressHUD.dismiss()
            
            if !success {
                print("error updating user")
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" :
            FUser.currentId()])
            
            self.goToApp()
            
        }
        
    }
    
    func goToApp() {
           
           let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
           
           self.present(mainView, animated: true, completion: nil)
           
       }
    
    
    
    //MARK: ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
          
    }
      
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
          
        avatarImage = images.first
        avatarImageView.image = avatarImage!.circleMasked
        self.dismiss(animated: true, completion: nil)
    }
      
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

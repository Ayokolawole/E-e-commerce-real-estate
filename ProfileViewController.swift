//
//  ProfileViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 06/04/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit
import ImagePicker

class ProfileViewController: UIViewController, ImagePickerDelegate {
  
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var coinLabel: UILabel!
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surenameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var additionalTextField: UITextField!
    
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()

    }
    
    //MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        
        let user = FUser.currentUser()!
        
        let optionMenu = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        let accountTypeString = user.isAgent ? "You are Agent" : "Become an Agent"
        
        let accountTypeAction = UIAlertAction(title: accountTypeString, style: .default) { (alert) in
            
        }
        
        let restorePurchaseAction = UIAlertAction(title: "Restore", style: .default) { (alert) in
            
        }
        
        let buyCoins = UIAlertAction(title: "Buy Coins", style: .default) { (alert) in
            
        }
        
        let saveChangesAction = UIAlertAction(title: "Save Chanages", style: .default) { (alert) in
            
            self.saveChanges()
        }
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { (alert) in
            
            FUser.logoutCurrentUser { (success) in
                
                if success {
                    
                    let recentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC")
                    self.present(recentVC, animated: true, completion: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        optionMenu.addAction(saveChangesAction)
        optionMenu.addAction(buyCoins)
        optionMenu.addAction(accountTypeAction)
        optionMenu.addAction(restorePurchaseAction)
        optionMenu.addAction(logOutAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    @IBAction func changeAvatarButtonPressed(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func buyCoinsButtonPressed(_ sender: Any) {
    }
    
    //MARK: Helpers
    
    func saveChanges() {
        
        var addPhone = ""
        
        if additionalTextField.text != "" {
            addPhone = additionalTextField.text!
        }
        
        if nameTextField.text != "" && surenameTextField.text != "" {
            
            ProgressHUD.show("Saving..:)")
            
            var values = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surenameTextField.text!, kADDPHONE : addPhone]
            
            if avatarImage != nil {
                
                let image = UIImageJPEGRepresentation(avatarImage!, 0.6)
                let avatarString = image!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                values = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surenameTextField.text!, kADDPHONE : addPhone, kAVATAR : avatarString]
            }
            
            updateCurrentUser(withValues: values) { (success) in
                
                if !success {
                    ProgressHUD.showError("Couldn't Update User")
                    
                } else {
                    ProgressHUD.showSuccess("Saved!")
                }
            }
            
        } else {
            
            ProgressHUD.showError("Name and Surename can not be empty")
        }
        
    }
    
    func updateUI() {
        
        let mobileImageView = UIImageView(image: UIImage(named: "Mobile"))
        mobileImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        mobileImageView.contentMode = .scaleAspectFit
        
        let mobileImageView1 = UIImageView(image: UIImage(named: "Mobile"))
        mobileImageView1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        mobileImageView1.contentMode = .scaleAspectFit
        
        let contactImageView = UIImageView(image: UIImage(named: "ContactLogo"))
        contactImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        contactImageView.contentMode = .scaleAspectFit
        
        let contactImageView1 = UIImageView(image: UIImage(named: "ContactLogo"))
        contactImageView1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        contactImageView1.contentMode = .scaleAspectFit
        
        nameTextField.leftViewMode = .always
        nameTextField.leftView = contactImageView
        nameTextField.addSubview(contactImageView)
        
        surenameTextField.leftViewMode = .always
        surenameTextField.leftView = contactImageView1
        surenameTextField.addSubview(contactImageView1)
        
        mobileTextField.leftViewMode = .always
        mobileTextField.leftView = mobileImageView
        mobileTextField.addSubview(mobileImageView)
        
        additionalTextField.leftViewMode = .always
        additionalTextField.leftView = mobileImageView1
        additionalTextField.addSubview(mobileImageView1)
        
        let user = FUser.currentUser()!
        
        nameTextField.text = user.firstName
        surenameTextField.text = user.lastName
        mobileTextField.text = user.phoneNumber
        additionalTextField.text = user.additionalPhoneNumber
        coinLabel.text = "\(user.coins)"
        
        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (image) in
                
                self.avatarImageView.image = image!.circleMasked
            }
        }

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

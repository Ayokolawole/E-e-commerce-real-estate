//
//  RegisterViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 14/03/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var requestButtonOutlet: UIButton!
    
    //Email reg
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: IBAction
    
    @IBAction func requestButtonPressed(_ sender: Any) {
        
        if phoneNumberTextField.text != "" {
            
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberTextField.text!, uiDelegate: nil, completion: { (verificationID, error) in
                
                if error != nil {
                    print("error phone number \(error?.localizedDescription)")
                    return
                }
                
                self.phoneNumber = self.phoneNumberTextField.text!
                self.phoneNumberTextField.text = ""
                self.phoneNumberTextField.placeholder = self.phoneNumber!
                
                self.phoneNumberTextField.isEnabled = false
                self.codeTextField.isHidden = false
                self.requestButtonOutlet.setTitle("Register", for: .normal)
                
                UserDefaults.standard.set(verificationID, forKey: kVERIFICATIONCODE)
                UserDefaults.standard.synchronize()
                
            })
        }
        
        if codeTextField.text != "" {
            
            FUser.registerUserWith(phoneNumber: phoneNumber!, verificationCode: codeTextField.text!) { (error, shouldLogin) in
                
                if error != nil{
                    print("error \(error?.localizedDescription)")
                    return
                }
                
                if shouldLogin {
                    
                    //go to main view
                    print("go to main view")
                    
                } else {
                    
                    //go to finish register view
                    print("go to finish reg view")
                    self.performSegue(withIdentifier: "registerToFinishRegisterSeg", sender: self)
                }
            }
        }
    }
    
    @IBAction func emailRegisterButtonPressed(_ sender: Any) {
        
        if emailTextField.text != "" && nameTextField.text != "" && lastNameTextField.text != ""
            && passwordTextField.text != "" {
            
            FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, firstName: nameTextField.text!, lastName: lastNameTextField.text!) { (error) in
                
                if error != nil {
                    print("Error registering user with emial: \(error?.localizedDescription)")
                    return
                }
                
                self.goToApp()
                
            }
            
        } else if emailTextField.text != "" && passwordTextField.text != "" {
            
            FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                } else {
                    self.goToApp()
                }
            }
        }
        
        
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        goToApp()
    }
    
    //MARK: Helper functions
    
    func goToApp() {
        
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
        
    }
}

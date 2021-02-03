//
//  AddPropertyViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 16/03/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit
import ImagePicker

class AddPropertyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, MapViewDelegate, ImagePickerDelegate, ImageGalleryViewControllerDelegate {
    
    var yearArray: [Int] = []
    
    var datePicker = UIDatePicker()
    var propertyTypePicker = UIPickerView()
    var advertisementTypePicker = UIPickerView()
    var yearPicker = UIPickerView()
    
    var locationManager: CLLocationManager?
    var locationCoordinates: CLLocationCoordinate2D?
    
    var activeField: UITextField?
    
    
    @IBOutlet weak var cameraButtonOutlet: UIButton!
    @IBOutlet weak var vcTitleLabel: UILabel!
    
    @IBOutlet weak var backButtonOutlet: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var referenceCodeTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var roomsTextField: UITextField!
    @IBOutlet weak var bathroomsTextField: UITextField!
    @IBOutlet weak var propertySizeTextField: UITextField!
    @IBOutlet weak var balconySizeTextField: UITextField!
    @IBOutlet weak var parkingTextField: UITextField!
    @IBOutlet weak var floorTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var advertismentTypeTextField: UITextField!
    @IBOutlet weak var availableFromTextField: UITextField!
    @IBOutlet weak var buildYearTextField: UITextField!
    @IBOutlet weak var propertyTypeTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    //switches
    
    @IBOutlet weak var titleDeedSwitch: UISwitch!
    @IBOutlet weak var centralHeatingSwitch: UISwitch!
    @IBOutlet weak var solarWaterHeatingSwitch: UISwitch!
    @IBOutlet weak var StoreroomSwitch: UISwitch!
    @IBOutlet weak var airConditionerSwitch: UISwitch!
    @IBOutlet weak var furnishedSwitch: UISwitch!
    
    var user: FUser?
    var property: Property?
    
    var titleDeedSwitchValue = false
    var centralHeatingSwitchValue = false
    var solarWaterHeatingSwitchValue = false
    var StoreroomSwitchValue = false
    var airConditionerSwitchValue = false
    var furnishedSwitchValue = false
    
    var propertyImages: [UIImage] = []
    
    override func viewWillAppear(_ animated: Bool) {
        if !isUserLoggedIn(viewController: self) {
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
       locationManagerStop()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        
        referenceCodeTextField.delegate = self
        titleTextField.delegate = self
        roomsTextField.delegate = self
        bathroomsTextField.delegate = self
        propertySizeTextField.delegate = self
        balconySizeTextField.delegate = self
        parkingTextField.delegate = self
        floorTextField.delegate = self
        addressTextField.delegate = self
        cityTextField.delegate = self
        countryTextField.delegate = self
        advertismentTypeTextField.delegate = self
        availableFromTextField.delegate = self
        buildYearTextField.delegate = self
        propertyTypeTextField.delegate = self
        priceTextField.delegate = self
        
        setupPickers()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: topView.frame.size.height)
        
        if property != nil {
            //edit property
            setUIForEdit()
        }
    }
    
    //MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        user = FUser.currentUser()!
        
        if !user!.isAgent {
        //check if user can post
          
            canUserPostProperty { (canPost) in
                
                if canPost {
                    self.save()
                } else {
                    ProgressHUD.showError("You have reached your post limit!")
                }
            }
            
        } else {
            save()
            
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        if property != nil {
            
            //editing
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageGallery") as! ImageGalleryViewController
            
            vc.property = property
            vc.delegate = self
            present(vc, animated: true, completion: nil)
            return
        }
        
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = kMAXIMAGENUMBER
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func currentLocationButtonPressed(_ sender: Any) {
        print("Current Location")
        locationMangerStart()
    }
    
    @IBAction func mapPinButtonPressed(_ sender: Any) {
        //show map so the user can pick a location
        
        let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        mapView.delegate = self
        self.present(mapView, animated: true, completion: nil) //Prsent mapview
    }
    
    //MARK: Helper functions
    
    func setupYearArray() {
        
        for i in 1900...2020 {
            yearArray.append(i)
        }
        yearArray.reverse()
        
    }
    
    func save() {
        
        if titleTextField.text != "" && referenceCodeTextField.text != "" && advertismentTypeTextField.text != "" && propertyTypeTextField.text != "" && priceTextField.text != "" {
            
            //Create new property
            
            var newProperty = Property()
            
            if property != nil {
                
                //editing property
                newProperty = property!
            }
            
            ProgressHUD.show("Saving...")
            
            newProperty.referenceCode = referenceCodeTextField.text!
            newProperty.ownerId = user!.objectId
            newProperty.title = titleTextField.text!
            newProperty.advertisementType = advertismentTypeTextField.text!
            newProperty.price = Int(priceTextField.text!)!
            newProperty.propertyType = propertyTypeTextField.text!
            
            if balconySizeTextField.text != "" {
                newProperty.balconySize = Double(balconySizeTextField.text!)!
            }
            if bathroomsTextField.text != "" {
                newProperty.numberOfBathrooms = Int(bathroomsTextField.text!)!
            }
            if buildYearTextField.text != "" {
                newProperty.buildYear = buildYearTextField.text!
            }
            if parkingTextField.text != "" {
                newProperty.parking = Int(parkingTextField.text!)!
            }
            if roomsTextField.text != "" {
                newProperty.numberOfRooms = Int(roomsTextField.text!)!
            }
            if propertySizeTextField.text != ""{
                newProperty.address = addressTextField.text!
            }
            if addressTextField.text != "" {
                newProperty.address = addressTextField.text!
            }
            if cityTextField.text != "" {
                newProperty.city = cityTextField.text!
            }
            if countryTextField.text != "" {
                newProperty.country = countryTextField.text!
            }
            if availableFromTextField.text != "" {
                newProperty.availableFrom = availableFromTextField.text!
            }
            if floorTextField.text != "" {
                newProperty.floor = Int(floorTextField.text!)!
            }
            if descriptionTextField.text != "" && descriptionTextField.text != "Description" {
                newProperty.propertyDescription = descriptionTextField.text!
            }
            if locationCoordinates != nil {
                newProperty.latitude = locationCoordinates!.latitude
                newProperty.longitude = locationCoordinates!.longitude
            }
            
            newProperty.titleDeeds = titleDeedSwitchValue
            newProperty.centralHeating = centralHeatingSwitchValue
            newProperty.solarWaterHeating = solarWaterHeatingSwitchValue
            newProperty.airConditioner = airConditionerSwitchValue
            newProperty.storeRoom = StoreroomSwitchValue
            newProperty.isFurnished = furnishedSwitchValue
            
            //check for property images
            if propertyImages.count != 0 {
                print("uploading")
                uploadImages(images: propertyImages, userId: user!.objectId, referenceNumber: newProperty.referenceCode!) { (linkString) in //Upload all images that has been saved
                    
                    newProperty.imageLinks = linkString
                    newProperty.saveProperty()
                    ProgressHUD.showSuccess("Saved!")
                    self.dismissView()
                    
                }
                
            } else {
                newProperty.saveProperty()
                ProgressHUD.showSuccess("Saved!")
                self.dismissView()
            }
            
           
        } else {
            
            ProgressHUD.showError("Error: Missing required fields")
        }
    }
    
    func dismissView() {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
        self.present(vc, animated: true, completion: nil)
    }
    
    //Switches
    
    @IBAction func titleDeedSwitch(_ sender: Any) {
       titleDeedSwitchValue = !titleDeedSwitchValue
    }
    @IBAction func centralHeatingSwitch(_ sender: Any) {
       centralHeatingSwitchValue = !centralHeatingSwitchValue
    }
    @IBAction func solarWaterSwitch(_ sender: Any) {
       solarWaterHeatingSwitchValue = !solarWaterHeatingSwitchValue
    }
    @IBAction func storeRoomSwitch(_ sender: Any) {
       StoreroomSwitchValue = !StoreroomSwitchValue
    }
    @IBAction func airConditionerSwitch(_ sender: Any) {
       airConditionerSwitchValue = !airConditionerSwitchValue
    }
    @IBAction func furnishedSwitch(_ sender: Any) {
       furnishedSwitchValue = !furnishedSwitchValue
    }
    
    //MARK: ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapper")
        self.dismiss(animated: true, completion: nil)

    }
       
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        propertyImages = images
        self.dismiss(animated: true, completion: nil)
    }
       
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)

    }
    
    //MARK: PickerView
    
    func setupPickers() {
    
        yearPicker.delegate = self
        propertyTypePicker.delegate = self
        advertisementTypePicker.delegate = self
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed))
        
        toolbar.setItems([flexibleBar, doneButton], animated: true)
        
        buildYearTextField.inputAccessoryView = toolbar
        buildYearTextField.inputView = yearPicker
        
        availableFromTextField.inputAccessoryView = toolbar
        availableFromTextField.inputView = datePicker
        
        propertyTypeTextField.inputAccessoryView = toolbar
        propertyTypeTextField.inputView =  propertyTypePicker
        
        advertismentTypeTextField.inputAccessoryView = toolbar
        advertismentTypeTextField.inputView =  advertisementTypePicker
    }
    
    @objc func doneButtonPressed() {
        
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == propertyTypePicker {
            return propertyTypes.count
        }
        
        if pickerView == advertisementTypePicker {
            return advertismentTypes.count
        }
        
        if pickerView == yearPicker {
            return yearArray.count
        }
        
        return 0
    }
    
    //Function to display title of each pickerview
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == propertyTypePicker {
            return propertyTypes[row]
    }
              
        if pickerView == advertisementTypePicker {
            return advertismentTypes[row]
    }
              
        if pickerView == yearPicker {
            return "\(yearArray[row])" //cov to string due yearArray as int
    }
              
            return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var rowValue = row
        
        if pickerView == propertyTypePicker {
            if rowValue == 0 { rowValue = 1 }
            propertyTypeTextField.text = propertyTypes[rowValue]
        }
                   
        if pickerView == advertisementTypePicker {
            if rowValue == 0 { rowValue = 1 }
            advertismentTypeTextField.text = advertismentTypes[rowValue]
        }
                   
        if pickerView == yearPicker {
            buildYearTextField.text = "\(yearArray[row])"
        }
        
    }
    
    @objc func dateChanged(_ sender: UIDatePicker){
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        
        if activeField == availableFromTextField {
            availableFromTextField.text = "\(components.day!)/\(components.month!)/\(components.year!)"
        }
    }
    
    //MARK: UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    //MARK: Location Manager
    
    func locationMangerStart() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.startUpdatingLocation()
    }
    
    func locationManagerStop() {
        if locationManager != nil{
            locationManager!.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Faild to get the Location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .restricted:
            //case like parential control
            break
        case .denied:
            locationManager = nil
            ProgressHUD.showError("Please enable location from the settings")
            print("location denied")
            //show user a notification to enable location from settings
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("updated location")
        locationCoordinates = locations.last!.coordinate
        
    }
   
   // MARK: MapViewDelegate
    
    //Function called everytime user drops pin
    func didFinishWith(coordinate: CLLocationCoordinate2D) {
        
        self.locationCoordinates = coordinate
        print("coordinate = \(coordinate)")
    }
    
   //MARK: Edit Property
    
    func setUIForEdit() {
        
        self.vcTitleLabel.text = "Edit Property"
        self.cameraButtonOutlet.setImage(UIImage(named: "Picture"), for: .normal)
        self.backButtonOutlet.isHidden = false
        
        referenceCodeTextField.text = property!.referenceCode
        titleTextField.text = property!.title
        advertismentTypeTextField.text = property!.advertisementType
        priceTextField.text = "\(property!.price)"
        propertyTypeTextField.text = property!.propertyType
        
        balconySizeTextField.text = "\(property!.balconySize)"
        bathroomsTextField.text = "\(property!.numberOfBathrooms)"
        buildYearTextField.text = property!.buildYear
        parkingTextField.text = "\(property!.parking)"
        roomsTextField.text = "\(property!.numberOfRooms)"
        propertySizeTextField.text = "\(property!.size)"
        addressTextField.text = property!.address
        availableFromTextField.text = property!.availableFrom
        floorTextField.text = "\(property!.floor)"
        descriptionTextField.text = property!.propertyDescription
        cityTextField.text = property!.city
        countryTextField.text = property!.country
        
        titleDeedSwitchValue = property!.titleDeeds
        centralHeatingSwitchValue = property!.centralHeating
        solarWaterHeatingSwitchValue = property!.solarWaterHeating
        StoreroomSwitchValue = property!.storeRoom
        airConditionerSwitchValue = property!.airConditioner
        furnishedSwitchValue = property!.isFurnished
        
        if property!.latitude != 0.0 && property!.longitude != 0.0 {
           
            locationCoordinates?.latitude = property!.latitude
            locationCoordinates?.longitude = property!.longitude
        }
        
        updateSwitches()
        
    }
    
    func updateSwitches() {
        
        titleDeedSwitch.isOn = titleDeedSwitchValue
        centralHeatingSwitch.isOn = centralHeatingSwitchValue
        solarWaterHeatingSwitch.isOn = solarWaterHeatingSwitchValue
        StoreroomSwitch.isOn = StoreroomSwitchValue
        airConditionerSwitch.isOn = airConditionerSwitchValue
        furnishedSwitch.isOn = furnishedSwitchValue
    }
    
    //MARK: ImageGalleryDelegate
    
    func didFinishEditingImages(allImages: [UIImage]) {
        self.propertyImages = allImages 
        
    }
}

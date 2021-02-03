//
//  SearchParametersViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 10/04/2020.
//  Copyright © Ayobami Kolawole. All rights reserved.
//

import UIKit

protocol SearchParametersViewControllerDelegate {
    func didFinishSettingParameters(whereClause: String)
}

class SearchParametersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

   
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var advertisementTypeTextField: UITextField!
    @IBOutlet weak var propertyTypeTextField: UITextField!
    @IBOutlet weak var bedroomsTextField: UITextField!
    @IBOutlet weak var bathroomsTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var buildYearTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var CountryTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    
    var delegate: SearchParametersViewControllerDelegate?
    
    var furnishedSwitchValue = false
    var centralHeatingSwitchValue = false
    var airConditionierSwitchValue = false
    var solarWaterSwitchValue = false
    var storegeRoomSwitchValue = false
    
    var propertyTypePicker = UIPickerView()
    var advertisementTypePicker = UIPickerView()
    var bedroomPicker = UIPickerView()
    var bathroomPicker = UIPickerView()
    var pricePicker = UIPickerView()
    var yearPicker = UIPickerView()
    
    var yearArray: [String] = []
    let minPriceArray = ["Minimum", "Any", "10000", "2000", "30000", "40000", "50000", "60000", "70000", "80000", "90000", "100000", "200000", "500000"]
    let maxPriceArray = ["Maximum", "Any", "10000", "2000", "30000", "40000", "50000", "60000", "70000", "80000", "90000", "100000", "200000", "500000"]
    
    var bathroomArray = ["Any", "1+", "2+", "3+"]
    var bedroomsArray = ["Any", "1+", "2+", "3+", "4+", "5+"]
    
    var activeTextField: UITextField?
    
    var minPrice = ""
    var maxPrice = ""
    var whereClause = ""
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
        
        setupArray()
        setupPickers()
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: mainView.frame.size.height + 30)
       }
    
    
    //MARK: IBActions
   
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if advertisementTypeTextField.text != "" && propertyTypeTextField.text != "" {
            
            //SQL search parameter
            whereClause = "advertisementType = '\(advertisementTypeTextField.text!)' and propertyType = '\(propertyTypeTextField.text!)' "
            
            //Optional search parameters
            if bedroomsTextField.text != "" && bedroomsTextField.text != "Any" {
                
                let index = bedroomsTextField.text!.index(bedroomsTextField.text!.startIndex, offsetBy: 0)
                
                let bedroomNumber = bedroomsTextField.text![index]
                whereClause = whereClause + " and numberOfRooms >= \(bedroomNumber)"
            }
            
            if bathroomsTextField.text != "" && bathroomsTextField.text != "Any" {
                let index = bathroomsTextField.text!.index(bathroomsTextField.text!.startIndex, offsetBy: 0)
                let bathroomNumber = bathroomsTextField.text![index]
                whereClause = whereClause + " and numberOfBathrooms >= \(bathroomNumber)"
                print(whereClause)
            }
            
            if priceTextField.text != "" && priceTextField.text != "Any-Any" {
                minPrice = priceTextField.text!.components(separatedBy: "-").first!
                maxPrice = priceTextField.text!.components(separatedBy: "-").last!
                
                if minPrice == ""{minPrice = "Any"}
                if maxPrice == ""{maxPrice = "Any"}
                
                if minPrice == "Any" && maxPrice != "Any" {
                    whereClause = whereClause + " and price <= \(maxPrice) "
                }
                
                if maxPrice == "Any" && minPrice != "Any" {
                    whereClause = whereClause + " and price >= \(minPrice) "
                }
                
                if maxPrice != "Any" && minPrice != "Any" {
                    whereClause = whereClause + " and price > \(minPrice) and price < \(maxPrice)"
                }
            }
            
            if buildYearTextField.text != "" && buildYearTextField.text != "Any" {
                
                whereClause = whereClause + " and buildYear = '\(buildYearTextField.text!)'"
                print(whereClause)
            }
            
            if cityTextField.text != "" {
                
                whereClause = whereClause + " and city = '\(cityTextField.text!)'"
                print(whereClause)
            }
            
            if CountryTextField.text != "" {
                whereClause = whereClause + " and country = '\(CountryTextField.text!)'"
                print(whereClause)
            }
            
            if areaTextField.text != "" {
                whereClause = whereClause + " and size = >= \(areaTextField.text!)"
                print(whereClause)
            }
            
            //Switches
            
            if furnishedSwitchValue {
                whereClause = whereClause + " and isFurnished = \(furnishedSwitchValue)"
            }
            if centralHeatingSwitchValue {
                whereClause = whereClause + " and centralHeating = \(centralHeatingSwitchValue)"
            }
            if airConditionierSwitchValue {
                whereClause = whereClause + " and airConditioner = \(airConditionierSwitchValue)"
            }
            if solarWaterSwitchValue {
                whereClause = whereClause + " and solarWaterHeating = \(solarWaterSwitchValue)"
            }
            if storegeRoomSwitchValue {
                whereClause = whereClause + " and storeRoom = \(storegeRoomSwitchValue)"
            }
            
            print(whereClause)
            
            delegate!.didFinishSettingParameters(whereClause: whereClause)
            self.dismiss(animated: true, completion: nil)
            
            
        } else {
            ProgressHUD.showError("Missing required fields!")
            print("Invalid search parameters")
        }
        
    }
    
    
    
    @IBAction func furnishedSwitchValueChanged(_ sender: Any) {
        furnishedSwitchValue = !furnishedSwitchValue
    }
    
    @IBAction func centralHeatingSwitchValueChanged(_ sender: Any) {
        centralHeatingSwitchValue = !centralHeatingSwitchValue
    }
    
    @IBAction func airConditionSwitchValueChanged(_ sender: Any) {
        airConditionierSwitchValue = !airConditionierSwitchValue
    }
    
    @IBAction func solarWaterSwitchValueChanged(_ sender: Any) {
        solarWaterSwitchValue = !solarWaterSwitchValue
    }
    
    @IBAction func storageSwitchValueChanged(_ sender: Any) {
        storegeRoomSwitchValue = !storegeRoomSwitchValue
    }
    
    //MARK: PickerviewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView == pricePicker {
            return 2
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case propertyTypePicker:
            return propertyTypes.count
        case advertisementTypePicker:
            return advertismentTypes.count
        case yearPicker:
            return yearArray.count
        case pricePicker:
            return minPriceArray.count
        case bedroomPicker:
            return bedroomsArray.count
        case bathroomPicker:
            return bathroomArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
         switch pickerView {
         case propertyTypePicker:
             return propertyTypes[row]
         case advertisementTypePicker:
             return advertismentTypes[row]
         case yearPicker:
             return yearArray[row]
         case pricePicker:
            
            if component == 0 {
                return minPriceArray[row]
            } else {
                return maxPriceArray[row]
            }
            
         case bedroomPicker:
             return bedroomsArray[row]
         case bathroomPicker:
             return bathroomArray[row]
         default:
             return ""
         }
    }
    
    //MARK: PickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var rowValue = row
        
        switch pickerView {
        case propertyTypePicker:
            if rowValue == 0 {rowValue = 1}
            propertyTypeTextField.text = propertyTypes[rowValue]
        case advertisementTypePicker:
            if rowValue == 0 {rowValue = 1}
            advertisementTypeTextField.text = advertismentTypes[rowValue]
        case yearPicker:
            buildYearTextField.text = yearArray[row]
            
        case pricePicker:
           
            if rowValue == 0 {rowValue = 1}
            
            if component == 0 {
               minPrice = minPriceArray[rowValue]
           } else {
                maxPrice = maxPriceArray[rowValue]
           }
            priceTextField.text = minPrice + "-" + maxPrice
           
        case bedroomPicker:
            bedroomsTextField.text = bedroomsArray[row]
        case bathroomPicker:
            bathroomsTextField.text = bathroomArray[row]
            
        default: break
        }
        
    }
    
    //MARK: Helper
    
    func setupPickers() {
        
        yearPicker.delegate = self
        propertyTypePicker.delegate = self
        advertisementTypePicker.delegate = self
        bedroomPicker.delegate = self
        bathroomPicker.delegate = self
        pricePicker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissButtonPressed))
        
        toolBar.setItems([flexibleBar, doneButton], animated: true)
        
        buildYearTextField.inputAccessoryView = toolBar
        buildYearTextField.inputView = yearPicker
        
        propertyTypeTextField.inputAccessoryView = toolBar
        propertyTypeTextField.inputView = propertyTypePicker
        
        advertisementTypeTextField.inputAccessoryView = toolBar
        advertisementTypeTextField.inputView = advertisementTypePicker
        
        bedroomsTextField.inputAccessoryView = toolBar
        bedroomsTextField.inputView = bedroomPicker
        
        bathroomsTextField.inputAccessoryView = toolBar
        bathroomsTextField.inputView = bathroomPicker
        
        priceTextField.inputAccessoryView = toolBar
        priceTextField.inputView = pricePicker
    }
    
   @objc  func dismissButtonPressed() {
        
    self.view.endEditing(true)
    }
    
    func setupArray() {
        
        for i in 1800...2022 {
            yearArray.append("\(i)")
        }
        
        yearArray.append("Any")
        yearArray.reverse()
    }
}

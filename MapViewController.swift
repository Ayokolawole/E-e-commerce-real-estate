//
//  MapViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 24/03/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewDelegate {
    
    func didFinishWith(coordinate: CLLocationCoordinate2D)
}

class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: MapViewDelegate?
    var pinCoordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.hadleLongTouch))
        
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        var region = MKCoordinateRegion()
        region.center.latitude = 52.3555
        region.center.longitude = 1.1743
        region.span.latitudeDelta = 100
        region.span.longitudeDelta = 100
        
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if mapView.annotations.count == 1 && pinCoordinates != nil {
            
            delegate!.didFinishWith(coordinate: pinCoordinates!)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    //MARK: Helper functions
    
    @objc func hadleLongTouch(gesterRecognizer: UILongPressGestureRecognizer) {
        
        if gesterRecognizer.state == .began {
            
            let location = gesterRecognizer.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            
            //drop pin
            dropPin(coordinate: coordinates)
            
        }
    }
    
    func dropPin(coordinate: CLLocationCoordinate2D) {
        
        //remove all the existing pins from the map
        mapView.removeAnnotations(mapView.annotations)
        
        pinCoordinates = coordinate //Update global var coordinates
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation) //Drop pin on mapView
    }
    
}

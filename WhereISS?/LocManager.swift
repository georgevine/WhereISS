//
//  LocManager.swift
//  WhereISS?
//
//  Created by George on 10/1/15.
//  Copyright © 2015 George Vine. All rights reserved.
//

import Foundation
import CoreLocation

class LocManager: NSObject, CLLocationManagerDelegate {
    var userLat: Float
    var userLong: Float
    var locationManager: CLLocationManager!
    
    override init(){
        userLat = 0
        userLong = 0
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    //will allow location service to run for one second in order to get user location.
    func update(){
        locationManager.startUpdatingLocation()
        sleep(1)
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        userLat = Float(newLocation.coordinate.latitude)
        userLong = Float(newLocation.coordinate.longitude)
    }
}
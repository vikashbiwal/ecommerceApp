//
//  Location.swift
//  manup
//
//  Created by Yudiz Solutions Pvt. Ltd. on 26/01/16.
//  Copyright © 2016 The App Developers. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

enum LocationPermission: Int {
    case accepted;
    case denied;
    case error;
}

class UserLocation: NSObject  {
    
    static let  sharedInstance = UserLocation()
    // MARK: - Variables
    var locationManger: CLLocationManager = {
        let lm = CLLocationManager()
        lm.activityType = .other
        lm.desiredAccuracy = kCLLocationAccuracyBest
        return lm
    }()
    
    // Will be assigned by host controller. If not set can throw Exception.
    typealias LocationBlock = (CLLocation?, NSError?)->()
    var completionBlock : LocationBlock? = nil
    weak var controller: UIViewController!
    
    // MARK: - Init
    
    // MARk: - Func
    func fetchUserLocationForOnce(_ controller: UIViewController, block: LocationBlock?) {
        self.controller = controller
        locationManger.delegate = self
        completionBlock = block
        if checkAuthorizationStatus() {
            locationManger.startUpdatingLocation()
        }
    }
    
    func checkAuthorizationStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        // If status is denied or only granted for when in use
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            _ = "Location services are off"
            _ = "To use location you must turn on 'WhenInUse' in the location services settings"
            return false
        } else if status == CLAuthorizationStatus.notDetermined {
            locationManger.requestWhenInUseAuthorization()
			//locationManger.requestAlwaysAuthorization()
            return false
        } else if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
            return true
        }
        return false
    }
 
}

// MARK: - Location manager Delegation
extension UserLocation: CLLocationManagerDelegate {
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        println(":: Location object got ::")
        self.completionBlock?(lastLocation,nil)
        locationManger.delegate = nil
        completionBlock = nil
    }
    
    func addressFromlocation(_ location: CLLocation, block: @escaping (String)->()){
        let geoLocation = CLGeocoder()
        geoLocation.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            if let pmark = placeMarks, pmark.count > 0 {
                let place :CLPlacemark = pmark.last! as CLPlacemark
                if let addr = place.addressDictionary {
                    println("The address dictionary : \(String(describing: place.addressDictionary))")
                    let cityName = addr["City"] as! NSString?
                    let countryName = addr["Country"] as! NSString?
                    var locationString :String = ""
                    if let cityN = cityName {
                        locationString += cityN as String
                    }
                    if let countN = countryName {
                        locationString += ", "
                        locationString += countN as String
                    }
                    block(locationString)
                }
            }
        })
    }
	func cityFromlocation(_ location: CLLocation, block: @escaping (String)->()){
		let geoLocation = CLGeocoder()
		geoLocation.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
			if let pmark = placeMarks, pmark.count > 0 {
				let place :CLPlacemark = pmark.last! as CLPlacemark
				if let addr = place.addressDictionary {
					println("The address dictionary : \(String(describing: place.addressDictionary))")
					let cityName = addr["City"] as! NSString?
					var locationString :String = ""
					if let cityN = cityName {
						locationString += cityN as String
					}

					block(locationString)
				}
			}
		})
	}

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManger.delegate = nil
        self.completionBlock?(nil,error as NSError?)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if checkAuthorizationStatus() {
            locationManger.startUpdatingLocation()
        }
    }
}







    
    /*
    func stopUpdatingLocation() {
        locationManger.delegate = nil
        locationManger.stopUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        if #available(iOS 8.0, *) {
            // We would need always authorization
            requestAlwaysAuthorization()
            // requestWhenInUseAuthorization()
        }
        locationManger.delegate = self
        locationManger.startUpdatingLocation()
    }
    

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        jprint("Got error while getting location: \(error.localizedDescription)")
        completionBlock?(.Error, nil, error)
    }
    
    // Called only if iOS is of 8.0 or above.
    func requestAlwaysAuthorization() {
        if #available(iOS 8.0, *) {
            let status = CLLocationManager.authorizationStatus()
            // If status is denied or only granted for when in use
            if status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.AuthorizedWhenInUse {
                var title : NSString
                if status == CLAuthorizationStatus.Denied {
                    title = "Location services are off"
                } else {
                    title = "Background location is not enabled"
                }
                let msg = "To use background location you must turn on 'Always' in the location services settings"
                
                let alert = UIAlertView(title: title as String, message: msg, delegate: self, cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Settings")
                alert.show()
            } else if status == CLAuthorizationStatus.NotDetermined {
                locationManger.requestAlwaysAuthorization()
            }  else if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
                completionBlock?(.Accepted, nil, nil)
            }
        }
    }
    
    // Called only if iOS is of 8.0 or above.
    func requestWhenInUseAuthorization() {
        if #available(iOS 8.0, *) {
            let status = CLLocationManager.authorizationStatus()
            // If status is denied or only granted for when in use
            if status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted {
                completionBlock?(.Denied,nil,nil)
            } else if status == CLAuthorizationStatus.NotDetermined {
                locationManger.requestWhenInUseAuthorization()
            } else if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
                completionBlock?(.Accepted,nil,nil)
            }
        }
    }
    
    func checkAlwaysAuthorizationForSettings() {
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted {
            if #available(iOS 8.0, *) {
                let title = "Location services are off"
                let msg = "To use location you must turn on 'WhenInUse' in the location services settings"
                let alert = UIAlertView(title: title, message: msg, delegate: self, cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Settings")
                alert.show()
                completionBlock?(.Denied,nil,nil)
            } else {
                self.showAlert("No permission", message: "Please go to settings and allow us to use your location.")
            }
        } else if status == CLAuthorizationStatus.NotDetermined {
                if #available(iOS 8.0, *) {
                     locationManger.requestAlwaysAuthorization()
                }
        }
        // Check for authorization
         if #available(iOS 8.0, *) {
            if  status == CLAuthorizationStatus.AuthorizedWhenInUse ||
                status == CLAuthorizationStatus.AuthorizedAlways {
                 completionBlock?(.Accepted,nil,nil)
            }
         } else {
            if status == CLAuthorizationStatus.Authorized {
               completionBlock?(.Accepted,nil,nil)
            }
        }
    }
    
  
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if #available(iOS 8.0, *) {
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(url!)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Close")
        alert.show()
    }
    */
    


/*
class SurpriseeMonitor: NSObject, CLLocationManagerDelegate {
    
    var manager: CLLocationManager
    var delegateBlock: ((CLRegion) -> ())?
    var testBlock: ((String) -> ())?

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.startMonitoringSignificantLocationChanges()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .Other
        checkAlwaysAuthorizationForSettings()
    }
    
    func checkAlwaysAuthorizationForSettings() {
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted {
            if #available(iOS 8.0, *) {
                let title = "Location services are off"
                let msg = "To use location you must turn on 'WhenInUse' in the location services settings"
                let alert = UIAlertView(title: title, message: msg, delegate: self, cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Settings")
                alert.show()
            } else {
                self.showAlert("No permission", message: "Please go to settings and allow us to use your location.")
            }
        } else if status == CLAuthorizationStatus.NotDetermined {
            if #available(iOS 8.0, *) {
                manager.requestAlwaysAuthorization()
            }
        }
    }

    func showAlert(title:String, message:String) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Close")
        alert.show()
    }
    
    /**
     This will Register box for geo Monitoring. It will first check if its already been registered or not.
     
     - parameter box:         box object
     
     - returns: If monitoring was already started then it will give false otherwise true
     */
    func registerRegionWithBoxIfNot(box: Box) -> Bool {
        let contained = manager.monitoredRegions.contains { (region) -> Bool in
                return region.identifier == box.key
            }
        if contained {
            return false
        }
        let overlay = MKCircle(centerCoordinate: CLLocationCoordinate2D(latitude: box.latitiude, longitude: box.longitude), radius: Double(box.radius))
        var radius = overlay.radius
        if radius > manager.maximumRegionMonitoringDistance {
            radius = manager.maximumRegionMonitoringDistance
            jprint("Monitoring region has been Compramized to maximum of location manager")
        }
        let geoRegion = CLCircularRegion(center: overlay.coordinate, radius: radius, identifier: box.key)
        manager.startMonitoringForRegion(geoRegion)
        return true
    }
    
    func registerRegionForLocalNotification(box: Box) -> Bool {
        
        // Check all registered local notifications
        if let monitoredRegions = UIApplication.sharedApplication().scheduledLocalNotifications{
            let contained = monitoredRegions.contains { (notification) -> Bool in
                return (notification.userInfo!["key"] as! String) == box.key
            }
            if contained {
                return false
            }
        }
        
        let overlay = MKCircle(centerCoordinate: CLLocationCoordinate2D(latitude: box.latitiude, longitude: box.longitude), radius: Double(box.radius))
        var radius = overlay.radius
        if radius > manager.maximumRegionMonitoringDistance {
            radius = manager.maximumRegionMonitoringDistance
            jprint("Monitoring region has been Compramized to maximum of location manager")
        }
        
        let geoRegion = CLCircularRegion(center: overlay.coordinate, radius: radius, identifier: box.key)
        let lclNotification = UILocalNotification()
        if #available(iOS 8.0, *) {
            lclNotification.region = geoRegion
            lclNotification.alertBody = "You picked new surprisee from \(box.from.displayName)"
            if #available(iOS 8.2, *) {
                lclNotification.alertTitle = "Surprisee Unlocked"
            }
            lclNotification.alertAction = "View"
            lclNotification.userInfo = ["key":box.key]
            UIApplication.sharedApplication().scheduleLocalNotification(lclNotification)
            return false
        } else {
            // Fallback on earlier versions
            return false
        }
        
    }
    
    // MARK: - Delegate
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        if state == CLRegionState.Inside {
            jprint("User did enter the region: \(region)")
            delegateBlock?(region)
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        jprint("Got Error while monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        jprint("Monitoring Starter for region with identifier: \(region.identifier)")
    }
    
    // MARK: - Test Cases
    func testRegionEntranceForAnybox() {
        let key = "VmWJTOSwHXKwSf6z"
        jprint("Testing: User did enter the region for key : \(key)")
        testBlock?(key)
    }
    
}
*/

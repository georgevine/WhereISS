//
//  AppDelegate.swift
//  WhereISS?
//
//  Created by George on 9/28/15.
//  Copyright © 2015 George Vine. All rights reserved.
//

import Cocoa
import CoreLocation
import Alamofire








//
//  AppDelegate.swift
//  WhereISS?
//
//  Created by George on 9/28/15.
//  Copyright © 2015 George. All rights reserved.
//

import Cocoa
import CoreLocation
import Alamofire



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    
    //status bar item
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    //will handle getting and passing of user location
    var locationManager: CLLocationManager!
    var loc_manager = LocManager()
    //menu that will drop down when the icon is clicked
    let menu = NSMenu()
    
    //function called when the application loads
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //initialize button with icon and menu
        if let button = statusItem.button {
            button.image = NSImage(named: "statusimage")
            button.action = Selector("response:")
            //add items to menu
            self.menu.addItem(NSMenuItem(title: "Next Pass: ", action: "",keyEquivalent:""))
            self.menu.addItem(NSMenuItem.separatorItem())
            self.menu.addItem(NSMenuItem(title: "Quit", action: Selector("quit:"), keyEquivalent:"Q"))
            //add menu to button
            self.statusItem.menu = menu
            
        }
        
        //get current location
        self.loc_manager.update()
        //set up variables
        var passStartTime = NSDate() //will hold the pass start time for the next pass
        var passEndTime = NSDate() //will hold the pass end time for the next pass
        var duration = -1 //will hold the duration for the next pass
        var haveNextPass = false //true if a next pass has been identified
        var lat = Float(-360) //user latittude
        var long = Float(-360) //user longitude
        var loopCount = 0 //will hold the number of loops run since the last location update
        var currentlyPassing = false //true if a pass is currently happening
        var tzOffset = 0 //time offset to account for timezones
        
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { //create a new thread? (To be honest can't remember what exactly this is for)
            while(true){ //will run continuously until the app is closed
                self.statusItem.button!.image = NSImage(named: "statusimage") //set the icon to the white image
                sleep(1)
                
                if(!currentlyPassing){
                    if(loopCount == 200){ //reset the counter after 200 loops
                        loopCount = 0
                    }
                    if(loopCount == 0){ //if the counter has just been reset, update location.
                        self.loc_manager.update()
                        lat = self.loc_manager.userLat
                        long = self.loc_manager.userLong
                        haveNextPass = false
                        
                    }
                    
                    if(loopCount == 0 || loopCount % 10 == 0){ //run this bloack of code every 10 loops
                        Alamofire.request(.GET, "http://api.open-notify.org/iss-pass.json?lat="+String(lat)+"&lon="+String(long)+"&n=1") //request an update by passing lat and log to the API
                            .responseJSON { response in
                                let json = JSON(data: response.data!) //convert the response to JSON
                                if json["message"].stringValue == "success" {
                                    if(!haveNextPass){ //if the request was succesful and we don't already have the next pass, set all nesecary variables to new data and update the menu
                                        passStartTime = (NSDate(timeIntervalSince1970: NSTimeInterval(json["response"][0]["risetime"].floatValue)))
                                        duration = (json["response"][0]["duration"]).intValue
                                        //calculate the timezone offset and add it to the start and end time
                                        tzOffset = NSTimeZone.localTimeZone().secondsFromGMTForDate(passStartTime)
                                        passStartTime = passStartTime.dateByAddingTimeInterval(NSTimeInterval(tzOffset))
                                        passEndTime = passStartTime.dateByAddingTimeInterval(NSTimeInterval(duration))
                                        haveNextPass = true
                                        self.statusItem.menu?.itemAtIndex(0)?.title = "Next Pass: " + String(passStartTime).substringToIndex(String(passStartTime).characters.indexOf("+")!)
                                    }
                                    
                                    
                                }
                        }
                    }
                    //if the current time is between the next pass start time and pass end time, the ISS is currently passing
                    if(NSDate().dateByAddingTimeInterval(NSTimeInterval(tzOffset)).timeIntervalSinceReferenceDate > passStartTime.timeIntervalSinceReferenceDate && NSDate().dateByAddingTimeInterval(NSTimeInterval(tzOffset)).timeIntervalSinceReferenceDate < passEndTime.timeIntervalSinceReferenceDate){
                        currentlyPassing = true
                    }
                }
                
                if(currentlyPassing){
                    //if it is now later than the pass end time, the ISS is no longer passing, reset variables to default values
                    if(NSDate().dateByAddingTimeInterval(NSTimeInterval(tzOffset)).timeIntervalSinceReferenceDate > passEndTime.timeIntervalSinceReferenceDate){
                        currentlyPassing = false
                        haveNextPass = false
                        lat = Float(-360)
                        long = Float(-360)
                        passStartTime = NSDate()
                        passEndTime = NSDate()
                        duration = -1
                        loopCount = -1
                    }
                    //otherwise set the icon to the blue image
                    self.statusItem.button!.image = NSImage(named: "statusimage_blue")
                }
                
                loopCount++
                sleep(1)
            }
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    func showAlertView(){
        
    }
    
    private func startLocationUpdate() {
        
    }
    
    func quit(Sender: AnyObject){
        exit(0)
    }
    
    
    
    
    
    
}
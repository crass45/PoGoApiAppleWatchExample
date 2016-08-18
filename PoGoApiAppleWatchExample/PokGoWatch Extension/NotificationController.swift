//
//  NotificationController.swift
//  PGoApi
//
//  Created by Jose Luis on 17/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

var applicationData = [String: AnyObject]()


class NotificationController: WKUserNotificationInterfaceController,WCSessionDelegate {
    @IBOutlet var label: WKInterfaceLabel!        

    @IBOutlet var imagen: WKInterfaceImage!
    var session:WCSession!
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        self.label.setText("HA APARECIDO UN POKEMON SALVAJE")
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 3
        
        
        
        let optionalString0 = formatter.stringFromNumber(localNotification.userInfo!["pokemonId"]as! Int)
        
        if optionalString0 != nil {
            imagen.setImage(UIImage(named: optionalString0!))
        }
        applicationData["encounterID"] = localNotification.userInfo!["encounterID"]
        applicationData["pokemonId"] = localNotification.userInfo!["pokemonId"]
        applicationData["spawnPointId"] = localNotification.userInfo!["spawnPointId"]
        
        completionHandler(.Custom)
    }
}

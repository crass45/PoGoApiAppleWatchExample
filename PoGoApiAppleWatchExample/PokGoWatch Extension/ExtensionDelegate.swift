//
//  ExtensionDelegate.swift
//  PokGoWatch Extension
//
//  Created by Jose Luis on 16/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class ExtensionDelegate: NSObject, WKExtensionDelegate,WCSessionDelegate {

    
    
    var session:WCSession!
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }    

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject]) {
                                
        let applicationData = ["counterValue":String(10)]
        
        
        
        
        session.sendMessage(applicationData, replyHandler: {(respuesta)->Void in
            print(respuesta)
            
            // handle reply from iPhone app here
            }, errorHandler: {(error )->Void in
                // catch any errors here
                print(error.localizedDescription)
        })
    }

}

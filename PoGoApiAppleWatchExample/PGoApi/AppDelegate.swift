//
//  AppDelegate.swift
//  PGoApi
//
//  Created by Jose Luis on 5/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity
import PGoApi



//Default object to controll the PGOApi events
let pokemonGoApi = PGOApiController()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    /// Default WatchConnectivity session for communicating with the watch.
    let session = WCSession.defaultSession()
    
    /// Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let modifyAction :UIMutableUserNotificationAction =
            UIMutableUserNotificationAction()
        modifyAction.identifier = "MODIFY_IDENTIFIER"
        modifyAction.title = "Capturar"
        modifyAction.destructive = false
        modifyAction.authenticationRequired = false
        modifyAction.activationMode =
            UIUserNotificationActivationMode.Foreground
        
        let notificationCategory:UIMutableUserNotificationCategory =
            UIMutableUserNotificationCategory()
        
        notificationCategory.identifier = "REMINDER_CATEGORY"
        
        notificationCategory.setActions([/*repeatAction, */modifyAction],
                                        forContext: UIUserNotificationActionContext.Default)
        let types:UIUserNotificationType = ([.Alert, .Badge, .Sound])
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes:types, categories: (NSSet(array:[notificationCategory]) as! Set<UIUserNotificationCategory>)))
        
        
        
        // Initialize the `WCSession` and the `CLLocationManager`.
        session.delegate = self
        session.activateSession()
        
        
        
        //configure the manager
        ///PON LA RUTA EN MADRID ANDAAAAAA
        
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //filter location manager event 5 metters
        manager.distanceFilter = 5
        
        manager.startUpdatingLocation()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        
        //        manager.stopUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        print("SE CIERRA LA APP")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print(notification)
        UIAlertView(title: notification.alertTitle, message: "Notificacion", delegate: self, cancelButtonTitle: "OK").show()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        UIAlertView(title: "SIN HANDEL", message: notification.alertBody, delegate: self, cancelButtonTitle: "CANCEL").show()
    }
    
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        UIAlertView(title: "CON HANDLE", message: "", delegate: self, cancelButtonTitle: "CANCEL").show()
    }
    
    
    //MARK SESSION DELEGATE
    
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        
        print(message)
        
        //        let responseDict = ["Respuesta":"Esta es mi respuesta"]
        //        replyHandler(responseDict)
        
        if message["accion"] as? String == "LanzaPokeball" {
            let spawn = message["spawnPointId"] as! String
            
            let encounter = UInt64(bitPattern: Int64(message["encounterID"] as! Int))
            pokemonGoApi.encounterPokemon(encounter, spawnPointId: spawn, replyHandler: replyHandler)
        }
    }
    
    //MARK LOCATION DELEGATE
    
    func applicationSignificantTimeChange(application: UIApplication) {
        print("SIGNIFICANT TIME CHANGE")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocationCoordinate = locations.last!.coordinate
        
        
        updateLocation(lastLocationCoordinate.latitude, lon: lastLocationCoordinate.longitude)
        
        pokemonGoApi.getMapObject()
        NSNotificationCenter.defaultCenter().postNotificationName(UPDATE_LOCATION_NOTIFICATION, object: nil)
        
    }
    
    
    
    /// Log any errors to the console.
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error occured: \(error.localizedDescription).")
    }
    
    
    //URLSCHEME POKESNIPER2
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        let pokemonName = url.host!.uppercaseString
        var latitud:Double = 0
        var longitud:Double = 0
        
        if url.pathComponents?.count > 1 {
            let coordenadas = url.pathComponents![1]
            
            let separatedCoord = coordenadas.componentsSeparatedByString(",")
            if separatedCoord.count > 1 {
                
                
                let lat = Double(separatedCoord[0])
                let lon = Double(separatedCoord[1])
                
                if lat != nil && lon != nil {
                    latitud = lat!
                    longitud = lon!
                }
            }
        }
        
        print("Preparando snipe para \(pokemonName) en lat:\(latitud), lon:\(longitud)")
        
        //llamamos al sniper
        let sniper = SnipeController(pokeName: pokemonName, lat: latitud, lon: longitud, latAntique: userLocation.latitude, lonAntique: userLocation.longitude)
        sniper.snipe()        
        return true
    }
    
    
}

func updateLocation(lat:Double, lon:Double){
    userLocation = CLLocationCoordinate2DMake(lat, lon)
    request.setLocation(userLocation.latitude, longitude: userLocation.longitude, altitude: 1)
}


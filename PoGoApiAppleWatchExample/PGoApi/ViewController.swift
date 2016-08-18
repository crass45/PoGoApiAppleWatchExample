//
//  ViewController.swift
//  PGoApi
//
//  Created by Jose Luis on 5/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import UIKit
import PGoApi
import MapKit
import WatchConnectivity
import CoreLocation


let NEW_POKEMONS_NOTIFICATION = "NEW_POKEMONS_NOTIFICATION"
let UPDATE_LOCATION_NOTIFICATION = "UPDATE_LOCATION_NOTIFICATION"

let UPDATE_LOG = "UPDATE_LOG"

//var userLocation = CLLocationCoordinate2DMake(34.008064, -118.499052)
var userLocation = CLLocationCoordinate2DMake(0, 0)
var fechaUltimaComprobacion = NSDate()

var textoLog = ""

var pokesNotificados:[String] = []

var catchablePokes:[Pogoprotos.Map.Pokemon.MapPokemon] = []

var gimnasios:[Pogoprotos.Map.Fort.FortData] = []
var request = PGoApiRequest()
var loginOK = false

class ViewController: UIViewController, PGoAuthDelegate, PGoApiDelegate, WCSessionDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tfPass: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var acountTypeSegment: UISegmentedControl!
    var auth: PtcOAuth!
    var gogleAuth: GPSOAuth!
    
    var canSimulateAppStart = false
    
    /// Default WatchConnectivity session for communicating with the watch.
    let session = WCSession.defaultSession()
    
    /// Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    
    /// Indicates whether the location manager is updating location.
    var isUpdatingLocation = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        startStopUpdatingLocation(self)
    }
    
    func startStopUpdatingLocation(sender: AnyObject) {
        if isUpdatingLocation {
            stopUpdatingLocation(commandedFromPhone: true)
        }
        else {
            startUpdatingLocationAllowingBackground(commandedFromPhone: true)
        }
    }
    
    func commonInit() {
        // Initialize the `WCSession` and the `CLLocationManager`.
        session.delegate = self
        session.activateSession()
        
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
    }
    
    func startUpdatingLocationAllowingBackground(commandedFromPhone commandedFromPhone: Bool) {
        self.manager.requestAlwaysAuthorization()
        isUpdatingLocation = true
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }
    
    /**
     Informs the manager to stop updating location, invalidates the timer, and
     updates the view.
     
     If the command comes from the phone, this method sends a state update to
     the watch to inform the watch that location updates have stopped.
     */
    func stopUpdatingLocation(commandedFromPhone commandedFromPhone: Bool) {
        isUpdatingLocation = false
        
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
    }
    
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        
        print(message)
        
        let responseDict = ["Respuesta":"Esta es mi respuesta"]
        replyHandler(responseDict)
        
        if message["accion"] as? String == "LanzaPokeball" {
            let spawn = message["spawnPointId"] as! String
            
            let encounter = UInt64(bitPattern: Int64(message["encounterID"] as! Int))
            
            
            encounterPokemon(encounter, spawnPointId: spawn, delegate: self)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocationCoordinate = locations.last!.coordinate
        
        let elapsedTime = Int(NSDate().timeIntervalSinceDate(fechaUltimaComprobacion))
        print(elapsedTime)
        
        if userLocation.latitude != lastLocationCoordinate.latitude || userLocation.longitude != lastLocationCoordinate.longitude || elapsedTime > 180 {
            fechaUltimaComprobacion = NSDate()
            userLocation = CLLocationCoordinate2DMake(lastLocationCoordinate.latitude, lastLocationCoordinate.longitude)
            
            let altitude = Double(CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude).altitude)
            
            print(altitude)
            request.setLocation(userLocation.latitude, longitude: userLocation.longitude, altitude: 1)
            NSNotificationCenter.defaultCenter().postNotificationName(UPDATE_LOCATION_NOTIFICATION, object: nil)
            if canSimulateAppStart {
                canSimulateAppStart = false
                request.simulateAppStart()
                request.makeRequest(.Login, delegate: self)
            }else {
                if loginOK {
                    request.getMapObjects()
                    request.makeRequest(.GetMapObjects, delegate: self)
                }
            }
        }
        
        
    }
    
    /// Log any errors to the console.
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error occured: \(error.localizedDescription).")
    }
    
    
    func didReceiveAuth() {
        print("Auth received!!")
        print("Starting simulation...")
        
        // Init with auth
        request = PGoApiRequest(auth: auth)
        
        // Simulate the start
        canSimulateAppStart = true
        
    }
    
    func didNotReceiveAuth() {
        print("Failed to auth!")
    }
    
    func didReceiveApiResponse(intent: PGoApiIntent, response: PGoApiResponse) {
        print("Got that API response: \(intent)")
        if (intent == .Login) {
            loginOK = true
            request.getMapObjects()
            request.makeRequest(.GetMapObjects, delegate: self)
            
        }
        
        if (intent == .EncounterPokemon){
            print("CAZANDO POKEMON!")
            print(response.response)
            print(response.subresponses)
            
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.EncounterResponse {
                    if r.status == .EncounterSuccess {
                        let wPokem = r.wildPokemon
                        cazaPokemonConPokeBall(wPokem.encounterId, spawnPointId: wPokem.spawnPointId, delegate: self)
                    }
                    
                    
                }
                
            }
            textoLog += "\(response.response)"
            textoLog += "\(response.subresponses)"
            
            NSNotificationCenter.defaultCenter().postNotificationName(UPDATE_LOG, object: nil)
        }
        
        if (intent == .CatchPokemon){
            print("CAZANDO POKEMON!")
            print(response.response)
            print(response.subresponses)
            
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.CatchPokemonResponse {
                    let status = r.status.toString()
                    print(status)
                    
                    session.sendMessage(["status":status], replyHandler: {(respuesta)->Void in
                        print(respuesta)
                        
                        // handle reply from iPhone app here
                        }, errorHandler: {(error )->Void in
                            // catch any errors here
                            print(error.localizedDescription)
                    })
                    if r.status == .CatchSuccess {
                        //TODO se ha capturado correctamente al pokemon
                        
                        print("CATCH SUCCESS")
                    }
                    
                    if r.status == .CatchFlee {
                        //
                        print("CATCHFLEE")
                    }
                    
                    if r.status == .CatchError {
                        print("CATCH ERROR")
                    }
                    
                    if r.status == .CatchMissed {
                        print("CATCH MISSED")
                    }
                    
                    if r.status == .CatchEscape {
                        print("CATCH ESCAPE")
                    }
                }
            }
            
            textoLog += "\(response.response)"
            textoLog += "\(response.subresponses)"
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            NSNotificationCenter.defaultCenter().postNotificationName(UPDATE_LOG, object: nil)
        }
        
        if (intent == .GetMapObjects) {
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.GetMapObjectsResponse {
                    
                    for cell in r.mapCells {
                        
                        catchablePokes.appendContentsOf(cell.catchablePokemons)
                        gimnasios.appendContentsOf(cell.forts)
                        
                        
                    }
                    
                    for fort in gimnasios {
                        //                        print(fort.hasActiveFortModifier)
                    }
                    
                    //            request.getInventory()
                    //            request.makeRequest(.GetInventory, delegate: self)
                }
            }
            performSegueWithIdentifier("mainSegue", sender: self)
            
        }
        
        if (intent == .GetInventory){
            //            print("Got INVENTORY!")
            //            print(response.response)
            //            print(response.subresponses)
            
            
            //            let r = response.subresponses[0] as! Pogoprotos.Networking.Responses.GetInventoryResponse
            //            let inventarioJugador = r.inventoryDelta.inventoryItems[0].inventoryItemData.playerStats//.pokemonData
            //            let pokemonsInventario = r.inventoryDelta.inventoryItems[0].inventoryItemData.pokemonData
            //            let caramelos = r.inventoryDelta.inventoryItems[0].inventoryItemData.candy
            
            
            
            //            let r = response.subresponses[0] as! Pogoprotos.Networking.Responses.GetInventoryResponse
            //            let cell = r.inventoryDelta.inventoryItems[0]
            //            print(cell.inventoryItemData.eggIncubators)
            //            print(cell.wildPokemons)
            //            print(cell.catchablePokemons)
        }
        
        if catchablePokes.count > 0 {
            
            for poke in catchablePokes {
                if !pokesNotificados.contains(poke.spawnPointId){
                    
                    pokesNotificados.append(poke.spawnPointId)
                    poke.spawnPointId
                    print("PokemonID:\(poke.pokemonId.hashValue)")
                    let not = UILocalNotification()
                    not.soundName = UILocalNotificationDefaultSoundName
                    not.alertBody = "\(poke.pokemonId.toString()) CERCANO"
                    not.alertTitle = "Tienes Cerca un \(poke.pokemonId.toString())"
                    not.category = "REMINDER_CATEGORY"
                    
                    var infoNotif = [String: AnyObject]()
                    infoNotif["encounterID"] = poke.encounterId.hashValue
                    infoNotif["pokemonId"] = poke.pokemonId.hashValue
                    infoNotif["spawnPointId"] = poke.spawnPointId
                    
                    not.userInfo = infoNotif
                    //        not.fireDate = currentDate
                    UIApplication.sharedApplication().scheduleLocalNotification(not)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(NEW_POKEMONS_NOTIFICATION, object: nil)
                    
                    //                    encounterPokemon(poke.encounterId, spawnPointId: poke.spawnPointId, delegate: self)
                }
            }
        }
        
        
        //        if gimnasios.count>0{
        //
        //            for gim in gimnasios {
        //                let not = UILocalNotification()
        //                not.soundName = UILocalNotificationDefaultSoundName
        //                not.alertBody = "GIMNASIO CERCANO"
        //                not.alertTitle = "Tienes Cerca un Gimnasio:\(gim.guardPokemonId.toString())"
        //                not.category = "REMINDER_CATEGORY"
        //                //        not.fireDate = currentDate
        //                UIApplication.sharedApplication().scheduleLocalNotification(not)
        //            }
        //
        //        }
        
    }
    
    func didReceiveApiError(intent: PGoApiIntent, statusCode: Int?) {
        print("API Error: \(statusCode)")
        UIAlertView(title: "API ERROR", message: "\(statusCode)", delegate: self, cancelButtonTitle: "OK").show()
        
    }
    
    
    
    
    @IBAction func logIn(sender: AnyObject) {
        
        if acountTypeSegment.selectedSegmentIndex == 0 {
            
            let username = tfUsername.text
            let password = tfPass.text
            auth = PtcOAuth()
            auth.delegate = self
            auth.login(withUsername: username!, withPassword: password!)
            
        }
        else{
            
            self.gogleAuth = GPSOAuth()
            self.gogleAuth.delegate = self
            
            let username = tfUsername.text
            let password = tfPass.text
            auth.login(withUsername: username!, withPassword: password!)
            
        }
        
    }
    
}

func encounterPokemon(encounterId:UInt64, spawnPointId:String,delegate:PGoApiDelegate){
    request.encounterPokemon(encounterId, spawnPointId: spawnPointId)
    request.makeRequest(.EncounterPokemon, delegate: delegate)
    
}

func cazaPokemonConPokeBall(encounterId:UInt64, spawnPointId:String,delegate:PGoApiDelegate){
    request.catchPokemon(encounterId, spawnPointId: spawnPointId, pokeball: Pogoprotos.Inventory.Item.ItemId.ItemPokeBall, hitPokemon: true, normalizedReticleSize: 1, normalizedHitPosition: 1, spinModifier: 1)
    request.makeRequest(.CatchPokemon, delegate: delegate)
}




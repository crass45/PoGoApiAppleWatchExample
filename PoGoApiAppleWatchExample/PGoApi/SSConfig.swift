//
//  SSConfig.swift
//  PGoApi
//
//  Created by Jose Luis on 19/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import PGoApi
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
var nearbyPokes:[[String:AnyObject]] = []

var gimnasios:[Pogoprotos.Map.Fort.FortData] = []
var request = PGoApiRequest()
var loginOK = false




var user:String? {
get{
    let settings = NSUserDefaults.standardUserDefaults()
    return settings.stringForKey("user")
    
}

set(newVal){
    let settings = NSUserDefaults.standardUserDefaults()
    settings.setObject(newVal, forKey: "user")
    settings.synchronize()
}
}


var pass:String? {
get{
    let settings = NSUserDefaults.standardUserDefaults()
    return settings.stringForKey("pass")
    
}

set(newVal){
    let settings = NSUserDefaults.standardUserDefaults()
    settings.setObject(newVal, forKey: "pass")
    settings.synchronize()
}
}


var botStart:Bool? {
get{
    let settings = NSUserDefaults.standardUserDefaults()
    return settings.boolForKey("botStart")
    
}

set(newVal){
    let settings = NSUserDefaults.standardUserDefaults()
    settings.setBool(newVal!, forKey: "botStart")
    settings.synchronize()
}
}

var authType:Int? {
get{
    let settings = NSUserDefaults.standardUserDefaults()
    return settings.integerForKey("authType")
    
}

set(newVal){
    let settings = NSUserDefaults.standardUserDefaults()
    settings.setInteger(newVal!, forKey: "authType")
    settings.synchronize()
}
}

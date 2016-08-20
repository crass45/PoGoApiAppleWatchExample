//
//  PGOApiController.swift
//  PGoApi
//
//  Created by Jose Luis on 19/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import PGoApi

class SnipeController: AnyObject, PGoApiDelegate {
    
    var pokemonName:String
    var latitude:Double
    var longitude:Double
    var antiqueLatitude:Double
    var antiqueLongitude:Double
    
    var wPokem:Pogoprotos.Map.Pokemon.WildPokemon!
    
    init(pokeName:String, lat:Double, lon:Double, latAntique:Double, lonAntique:Double)
    {
        pokemonName = pokeName
        latitude = lat
        longitude = lon
        antiqueLatitude = latAntique
        antiqueLongitude = lonAntique
        
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func didReceiveApiResponse(intent: PGoApiIntent, response: PGoApiResponse) {
        print("Got that API response: \(intent)")
        if (intent == .EncounterPokemon){
            print("ENCOUNTER POKEMON!")
            //            print(response.response)
            //            print(response.subresponses)
            
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.EncounterResponse {
                    if r.status == .EncounterSuccess {
                        updateLocation(antiqueLatitude, lon: antiqueLongitude)
                        appDelegate.manager.startUpdatingLocation()
                        wPokem = r.wildPokemon
                        cazaPokemonConPokeBall(wPokem.encounterId, spawnPointId: wPokem.spawnPointId)
                        
                    }
                }
            }
        }
        
        if (intent == .CatchPokemon){
            print("CAZANDO POKEMON!")
            
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.CatchPokemonResponse {
                    let status = r.status.toString()
                    print(status)
                    
                    if r.status == .CatchSuccess {
                        //TODO se ha capturado correctamente al pokemon
                        
                        print("CATCH SUCCESS")
                        
                        UIAlertView(title: "POKEMON SNIPEADO", message: "", delegate: self, cancelButtonTitle: "OK").show()
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
                        cazaPokemonConPokeBall(wPokem.encounterId, spawnPointId: wPokem.spawnPointId)
                    }
                    
                    if r.status == .CatchEscape {
                        print("CATCH ESCAPE")
                        cazaPokemonConPokeBall(wPokem.encounterId, spawnPointId: wPokem.spawnPointId)
                    }
                }
            }
            
            
        }
        
        if (intent == .GetMapObjects) {
            //            print(response)
            //            print(response.subresponses)
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.GetMapObjectsResponse {
                    
                    for cell in r.mapCells {
                        for poke in cell.catchablePokemons {
                            
                            //agarramos el pokemon
                            if poke.pokemonId.toString() == pokemonName {
                                request.encounterPokemon(poke.encounterId, spawnPointId: poke.spawnPointId)
                                request.makeRequest(.EncounterPokemon, delegate: self)
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func didReceiveApiError(intent: PGoApiIntent, statusCode: Int?) {
        print("API Error: \(statusCode)")
        UIAlertView(title: "API ERROR", message: "\(statusCode)", delegate: self, cancelButtonTitle: "OK").show()
        
    }
    
    func snipe(){
        appDelegate.manager.stopUpdatingLocation()
        updateLocation(latitude, lon: longitude)
        request.getMapObjects()
        request.makeRequest(.GetMapObjects, delegate: self)
    }
    
    
    func cazaPokemonConPokeBall(encounterId:UInt64, spawnPointId:String){
        request.catchPokemon(encounterId, spawnPointId: spawnPointId, pokeball: Pogoprotos.Inventory.Item.ItemId.ItemPokeBall, hitPokemon: true, normalizedReticleSize: 1, normalizedHitPosition: 1, spinModifier: 1)
        request.makeRequest(.CatchPokemon, delegate: self)
    }
    
    
}
//
//  BotController.swift
//  PGoApi
//
//  Created by Jose Luis on 24/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import PGoApi

class BotController: AnyObject, PGoApiDelegate {
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var wPokem:Pogoprotos.Map.Pokemon.WildPokemon!
    
    var tempEncounterId:UInt64?
    var tempSpawnPoint:String?
    
    func didReceiveApiResponse(intent: PGoApiIntent, response: PGoApiResponse) {
        print("Got that API response: \(intent)")
        if (intent == .Login) {
            loginOK = true
            request.getMapObjects()
            request.makeRequest(.GetMapObjects, delegate: self)
            
        }
        if (intent == .EncounterPokemon){
            print("ENCOUNTER POKEMON!")
            //            print(response.response)
            
            
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.EncounterResponse {
                    if r.status == .EncounterSuccess {
                        let wPokem = r.wildPokemon
                        cazaPokemonConPokeBall(wPokem.encounterId, spawnPointId: wPokem.spawnPointId)
                        print("PELEANDO CON POKEMON")
                        print(wPokem.pokemonData.pokemonId.toString())
                        print("IV ATACK:")
                        print(wPokem.pokemonData.individualAttack)
                        print("IV DEFENSE:")
                        print(wPokem.pokemonData.individualDefense)
                        print("IV STAMINIA:")
                        print(wPokem.pokemonData.individualStamina)
                    }
                }
            }
        }
        
        if (intent == .CatchPokemon){
            print("CAZANDO POKEMON!")
            print(response)
            print(response.subresponses)
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.CatchPokemonResponse {
                    let status = r.status.toString()
                    print(status)
                    
                    if r.status == .CatchSuccess {
                        print("CATCH SUCCESS")
                    }
                    
                    if r.status == .CatchFlee {
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
                        print(wPokem.encounterId)
                        print(wPokem.spawnPointId)
                        cazaPokemonConPokeBall(wPokem.encounterId, spawnPointId: wPokem.spawnPointId)
                    }
                }
            }
            
            
        }
        
        if (intent == .FortDetails){
            print(response)
            print(response.subresponses)
        }
        if (intent == .DiskEncounter){
            print("DISK ENCOUNTER")
            print(response)
            print(response.subresponses)
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.DiskEncounterResponse {
                    print(r.pokemonData)
                    cazaPokemonConPokeBall(tempEncounterId!, spawnPointId: tempSpawnPoint!)
                    //                    cazaPokemonConPokeBall(r.pokemonData.id, spawnPointId: "")
                }
            }
        }
        if (intent == .FortSearch){
            print(response)
            print(response.subresponses)
        }
        
        if (intent == .GetMapObjects) {
            //            print(response)
            print(response.subresponses)
            print(response.subresponses.count)
            print(response.subresponses.last)
            if response.subresponses.count > 0 {
                catchablePokes = []
                gimnasios = []
                nearbyPokes = []
                for resp in response.subresponses {
                    if let r = resp as? Pogoprotos.Networking.Responses.GetMapObjectsResponse {
                        if r.status == .Success {
                            for cell in r.mapCells {
                                catchablePokes.appendContentsOf(cell.catchablePokemons)
                                
                                gimnasios.appendContentsOf(cell.forts)
                                print(cell.nearbyPokemons.count)
                                
                                //                                for pokewild in cell.wildPokemons {
                                //                                    print(pokewild)
                                //                                    self.encounterPokemon(pokewild.encounterId, spawnPointId: pokewild.spawnPointId)
                                //                                }
                                
                                //                                for nearbyPoke in cell.nearbyPokemons {
                                ////                                    self.encounterPokemon(nearbyPoke.encounterId, spawnPointId: "0")
                                //                                }
                            }
                            
                            
                            for poke in catchablePokes {
                                //todo esperar un tiempo aleatorio
                                //                                self.encounterPokemon(poke.encounterId, spawnPointId: poke.spawnPointId)
                            }
                            
                            for fort in gimnasios {
                                if fort.types == .Checkpoint {
                                    let distance = PGoLocationUtils().getDistanceBetweenPoints(userLocation.latitude, startLongitude: userLocation.longitude, endLatitude: fort.latitude, endLongitude: fort.longitude)
                                    
                                    if (distance < 35){
                                        // se puede girar
                                        if fort.cooldownCompleteTimestampMs == 0 {
                                            request.fortSearch(fort.id, fortLatitude: fort.latitude, fortLongitude: fort.longitude)
                                            request.makeRequest(.FortSearch, delegate: self)
                                        }
                                    }
                                    
                                    if (fort.hasLureInfo){
                                        
                                        print(fort.activeFortModifier)
                                        print(fort.lureInfo)
                                        
                                        //                                        cazaPokemonConPokeBall(fort.lureInfo.encounterId, spawnPointId: "")
                                        
                                        //                                        cazaPokemonConPokeBall(fort.lureInfo.encounterId, spawnPointId: fort.id)
                                        //                                        request.diskEncounter(fort.lureInfo.encounterId, fortId: fort.id)
                                        //                                        request.makeRequest(.DiskEncounter, delegate: self)
                                    }
                                    //                                    request.fortDetails(fort.id, fortLatitude: fort.latitude, fortLongitude: fort.longitude)
                                    //                                    request.makeRequest(.FortDetails, delegate: self)
                                    
                                }
                            }
                        }else{
                            print(r.status.toString())
                            //                            UIAlertView(title: "Error", message: r.status.toString(), delegate: self, cancelButtonTitle: "OK").show()
                        }
                    }else{
                        print("No es del tipo")
                    }
                }
                NSNotificationCenter.defaultCenter().postNotificationName(NEW_POKEMONS_NOTIFICATION, object: nil)
            }
            
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
        //        UIAlertView(title: "API ERROR", message: "\(statusCode)", delegate: self, cancelButtonTitle: "OK").show()
        
    }
    
    func getMapObject(){
        updateLocation(userLocation.latitude, lon: userLocation.longitude)
        request.getMapObjects()
        request.makeRequest(.GetMapObjects, delegate: self)
    }
    
    
    func encounterPokemon(encounterId:UInt64, spawnPointId:String){
        request.encounterPokemon(encounterId, spawnPointId: spawnPointId)
        request.makeRequest(.EncounterPokemon, delegate: self)
        
    }
    
    func cazaPokemonConPokeBall(encounterId:UInt64, spawnPointId:String){
        //
        
        request.catchPokemon(encounterId, spawnPointId: spawnPointId, pokeball: Pogoprotos.Inventory.Item.ItemId.ItemPokeBall, hitPokemon: true, normalizedReticleSize: 1, normalizedHitPosition: 1, spinModifier: 1)
        request.makeRequest(.CatchPokemon, delegate: self)
    }
    
    
}

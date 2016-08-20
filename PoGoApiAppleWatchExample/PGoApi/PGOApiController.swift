//
//  PGOApiController.swift
//  PGoApi
//
//  Created by Jose Luis on 19/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import PGoApi

class PGOApiController: AnyObject, PGoApiDelegate {
    
    
    var replyHandler: ([String: AnyObject] -> Void)?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
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
            //            print(response.subresponses)
            
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.EncounterResponse {
                    if r.status == .EncounterSuccess {
                        let wPokem = r.wildPokemon
                        cazaPokemonConPokeBall(wPokem.encounterId, spawnPointId: wPokem.spawnPointId)
                    }else {
                        if replyHandler != nil {
                            replyHandler!(["status":r.status.toString()])
                        }
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
                    if self.replyHandler != nil {
                        replyHandler!(["status":status])
                    }
                    
                    //                    appDelegate.session.sendMessage(["status":status], replyHandler: {(respuesta)->Void in
                    //                        print(respuesta)
                    //
                    //                        // handle reply from iPhone app here
                    //                        }, errorHandler: {(error )->Void in
                    //                            // catch any errors here
                    //                            print(error.localizedDescription)
                    //                    })
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
            //            print(response)
            //            print(response.subresponses)
            if response.subresponses.count > 0 {
                if let r = response.subresponses[0] as? Pogoprotos.Networking.Responses.GetMapObjectsResponse {
                    
                    catchablePokes = []
                    gimnasios = []
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
            
            NSNotificationCenter.defaultCenter().postNotificationName(NEW_POKEMONS_NOTIFICATION, object: nil)
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
                    UIApplication.sharedApplication().scheduleLocalNotification(not)
                    
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
    
    func getMapObject(){
        request.getMapObjects()
        request.makeRequest(.GetMapObjects, delegate: self)
    }
    
    
    func encounterPokemon(encounterId:UInt64, spawnPointId:String, replyHandler: [String: AnyObject] -> Void){
        request.encounterPokemon(encounterId, spawnPointId: spawnPointId)
        request.makeRequest(.EncounterPokemon, delegate: self)
        
        self.replyHandler = replyHandler
        
    }
    
    func cazaPokemonConPokeBall(encounterId:UInt64, spawnPointId:String){
        request.catchPokemon(encounterId, spawnPointId: spawnPointId, pokeball: Pogoprotos.Inventory.Item.ItemId.ItemPokeBall, hitPokemon: true, normalizedReticleSize: 1, normalizedHitPosition: 1, spinModifier: 1)
        request.makeRequest(.CatchPokemon, delegate: self)
    }
    
    
}
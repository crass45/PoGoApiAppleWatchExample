//
//  InterfaceController.swift
//  PokGoWatch Extension
//
//  Created by Jose Luis on 16/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    var session:WCSession!
    
    @IBOutlet var lbPokesCerca: WKInterfaceLabel!
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var lbTitle: WKInterfaceLabel!
    @IBOutlet var grupoBolas: WKInterfaceGroup!
    @IBOutlet var grupoSplash: WKInterfaceGroup!
    @IBOutlet var groupIndicator: WKInterfaceGroup!
    
    var nearbyPokes:[[String:AnyObject]] = []
    
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if applicationData.count > 0 {
            grupoSplash.setHidden(true)
            grupoBolas.setHidden(false)
        }else{
            grupoSplash.setHidden(false)
            grupoBolas.setHidden(true)
        }
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        let datosMessage = ["accion":"getNearPokes"]
        
        
        session.sendMessage(datosMessage, replyHandler: {(respuesta)->Void in
            // handle reply from iPhone app here
            if respuesta.count > 0 {
                if let nearby = respuesta["NearbyPokes"] as? [[String:AnyObject]] {
                    self.nearbyPokes = nearby
                    self.configureTableWithData()
//                    self.lbPokesCerca.setText("\(self.nearbyPokes.count)")
                }else {
                    
                }
            }
            else{
                self.lbTitle.setText("Respuesta count 0")
            }
            
            
            }, errorHandler: {(error )->Void in
                // catch any errors here
                print(error.localizedDescription)
        })

    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
    }
    
    
    
    // se llama cuando se pulsa una acción en la notificación
    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject]) {
        
    }
    
    
    func configureTableWithData() {
        self.table.setNumberOfRows(nearbyPokes.count, withRowType: "mainRowType")
        
        for i in 0 ..< self.table.numberOfRows {
            let theRow = self.table.rowControllerAtIndex(i) as? MainRowType
            let pokemon = nearbyPokes[i]
            let pokemonName = pokemon["pokemonId"] as? String
            let metros = pokemon["distance"] as? Float
            
            
            theRow?.rowDescription.setText("\(pokemonName!) a \(metros!)m")
        }
        
//        for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
//            MainRowType* theRow = [self.table rowControllerAtIndex:i];
//            MyDataObject* dataObj = [dataObjects objectAtIndex:i];
//            
//            [theRow.rowDescription setText:dataObj.text];
//            [theRow.rowIcon setImage:dataObj.image];
//        }
    }
    
    
    func testCatchHandler( message: [String : AnyObject]) {
        if message.count > 0 {
            if let status = message["status"] as? String {
                
                if status == "CATCH_ESCAPE"{
                    let h0 = { print("ok")}
                    let h1 = {
                        applicationData = [String: AnyObject]()
                        self.willActivate()
                    }
                    let action1 = WKAlertAction(title: "Reintentar", style: .Default, handler:h0)
                    let action2 = WKAlertAction(title: "Abandonar", style: .Default, handler:h1)
                    presentAlertControllerWithTitle("Resultado", message: status, preferredStyle: .ActionSheet, actions: [action1,action2])
                    
                }
                
                else {
                    
                    let h1 = {
                        applicationData = [String: AnyObject]()
                        self.willActivate()
                    }
                    
                    let action = WKAlertAction(title: "OK", style: .Default, handler:h1)
                    
                    presentAlertControllerWithTitle("Resultado", message: status, preferredStyle: .ActionSheet, actions: [action])
                }
            }
        }else {
            let h0 = { print("ok")}
            
            let action1 = WKAlertAction(title: "OK", style: .Default, handler:h0)
            
            presentAlertControllerWithTitle("Error", message: "Ha ocurrido un error al capturar el Pokemon", preferredStyle: .ActionSheet, actions: [action1])
        }
    }
    
    
    func muestraIndicador(){
        groupIndicator.setHidden(false)
        grupoBolas.setHidden(true)
    }
    
    func ocultaIndicador(){
        groupIndicator.setHidden(true)
        grupoBolas.setHidden(false)
    }
    
    
    
    func lanzaBola(action:String){
        var datosPokeball = applicationData
        datosPokeball["accion"] = action
        
        muestraIndicador()
        
        session.sendMessage(datosPokeball, replyHandler: {(respuesta)->Void in
            print(respuesta)
            // handle reply from iPhone app here
            if respuesta.count > 0 {
                if let status = respuesta["status"] as? String {
                    
                }else {
                    
                }
            }
            else{
                self.lbTitle.setText("Respuesta count 0")
            }
            self.ocultaIndicador()
            self.testCatchHandler(respuesta)
            
            
            
            }, errorHandler: {(error )->Void in
                // catch any errors here
                self.ocultaIndicador()
                print(error.localizedDescription)
                self.testCatchHandler(["error":"error"])
        })
    }
    
    @IBAction func lanzaPokeball() {
        lanzaBola("LanzaPokeball")
        
    }
    @IBAction func lanzaSuperBall() {
        lanzaBola("LanzaSuperBall")
    }
    
    @IBAction func lanzaUltraBall() {
        lanzaBola("LanzaUltraBall")
    }
    
    
}


class MainRowType: NSObject {
    @IBOutlet weak var rowDescription: WKInterfaceLabel!
    @IBOutlet weak var rowIcon: WKInterfaceImage!
}

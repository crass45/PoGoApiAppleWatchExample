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
    
    @IBOutlet var lbTitle: WKInterfaceLabel!
    @IBOutlet var grupoBolas: WKInterfaceGroup!
    @IBOutlet var grupoSplash: WKInterfaceGroup!
    
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
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
    }
    
    
    
    // se llama cuando se pulsa una acción en la notificación
    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject]) {
        
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
    
    
    @IBAction func lanzaPokeball() {
        var datosPokeball = applicationData
        datosPokeball["accion"] = "LanzaPokeball"
        
        self.lbTitle.setText("WAITING HANDLER")
        session.sendMessage(datosPokeball, replyHandler: {(respuesta)->Void in
            print(respuesta)
            
            // handle reply from iPhone app here
            self.lbTitle.setText("HANDLER")
            if respuesta.count > 0 {
                if let status = respuesta["status"] as? String {
                    self.lbTitle.setText(status)
                }else {
                    self.lbTitle.setText("No hay status")
                }
            }
            else{
                self.lbTitle.setText("Respuesta count 0")
            }
            self.testCatchHandler(respuesta)
            
            
            }, errorHandler: {(error )->Void in
                // catch any errors here
                print(error.localizedDescription)
        })
    }
    @IBAction func lanzaSuperBall() {
        var datosPokeball = applicationData
        datosPokeball["accion"] = "LanzaSuperBall"
        session.sendMessage(datosPokeball, replyHandler: {(respuesta)->Void in
            print(respuesta)
            
            // handle reply from iPhone app here
            }, errorHandler: {(error )->Void in
                // catch any errors here
                print(error.localizedDescription)
        })
    }
    
    @IBAction func lanzaUltraBall() {
        var datosPokeball = applicationData
        datosPokeball["accion"] = "LanzaUltraBall"
        session.sendMessage(datosPokeball, replyHandler: {(respuesta)->Void in
            print(respuesta)
            
            // handle reply from iPhone app here
            }, errorHandler: {(error )->Void in
                // catch any errors here
                print(error.localizedDescription)
        })
    }
    
}

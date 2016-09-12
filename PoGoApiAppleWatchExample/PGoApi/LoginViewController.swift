//
//  ViewController.swift
//  PGoApi
//
//  Created by Jose Luis on 5/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import UIKit
import MapKit
import PGoApi


class LoginViewController: UIViewController, PGoAuthDelegate {
    
    @IBOutlet weak var startBot: UISwitch!
    @IBOutlet weak var tfPass: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var acountTypeSegment: UISegmentedControl!
    var ptcAuth: PtcOAuth!
    var gogleAuth: GPSOAuth!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            tfUsername.text = user
            tfPass.text = pass
        }
        
    }            
    
    
    func didReceiveAuth() {
        print("Auth received!!")
        
        performSegueWithIdentifier("mainSegue", sender: self)
        // Init with auth
        if authType == 0 {
            request = PGoApiRequest(auth: ptcAuth)
        }
        else{
            request = PGoApiRequest(auth: gogleAuth)
        }
        
        print("Starting simulation...")
        request.setLocation(userLocation.latitude, longitude: userLocation.longitude, altitude: 1)
        request.simulateAppStart()
        
        if (botStart!) {
            request.makeRequest(.Login, delegate: botController)
        }else{
            request.makeRequest(.Login, delegate: pokemonGoApi)
        }
        
        
    }
    
    func didNotReceiveAuth() {
        print("Failed to auth!")
    }
        
    
    @IBAction func logIn(sender: AnyObject) {
        
        
        user = tfUsername.text
        pass = tfPass.text
        authType = acountTypeSegment.selectedSegmentIndex
        
        logIn()
        
        
    }
    
    
    
    func logIn(){
        botStart = startBot.on
        
        if botStart! {
        
            //TODO START BOT
            
            //Nos posicionamos en retiro madrid
            userLocation = CLLocationCoordinate2DMake(40.4174945, -3.6832152)
            //arrancamos el bot
            
            botController.getMapObject()
        }else {
            appDelegate.searchTimer?.invalidate()
            appDelegate.searchTimer = nil
            appDelegate.manager.startUpdatingLocation()
            appDelegate.searchTimer = NSTimer.scheduledTimerWithTimeInterval(appDelegate.SEARCH_BOT_TIME, target: appDelegate, selector: #selector(AppDelegate.timerBotAction), userInfo: nil, repeats: true)
        }
        
        if authType == 0 {
            self.ptcAuth = PtcOAuth()
            self.ptcAuth.delegate = self
            self.ptcAuth.login(withUsername: user!, withPassword: pass!)
        }
        else{
            self.gogleAuth = GPSOAuth()
            self.gogleAuth.delegate = self
            self.gogleAuth.login(withUsername: user!, withPassword: pass!)
            
        }
    }
    
}




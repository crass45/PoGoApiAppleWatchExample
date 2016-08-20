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
    
    @IBOutlet weak var tfPass: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var acountTypeSegment: UISegmentedControl!
    var ptcAuth: PtcOAuth!
    var gogleAuth: GPSOAuth!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            logIn()
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
        request.makeRequest(.Login, delegate: pokemonGoApi)
        
        
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




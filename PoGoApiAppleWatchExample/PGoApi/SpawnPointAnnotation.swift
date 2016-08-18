//
//  SpawnPointAnnotation.swift
//  PGoApi
//
//  Created by Jose Luis on 16/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import UIKit
import MapKit
import PGoApi

class SpawnPointAnnotation:NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String? = ""
    var subtitle: String? = ""
    var pokemon:Pogoprotos.Map.SpawnPoint?
    
    
    init(poke:Pogoprotos.Map.SpawnPoint){
        self.coordinate = CLLocationCoordinate2DMake(Double(poke.latitude), Double(poke.longitude))
        self.pokemon = poke
//        title = poke..pokemonId.toString()
//        subtitle = "\(poke.expirationTimestampMs)"
        
    }
    
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect)
     {
     // Drawing code
     }
     */
    
}

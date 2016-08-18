//
//  ArticuloAnnotation.swift
//  Exploravia
//
//  Created by Jose Luis on 5/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import UIKit
import MapKit
import PGoApi

class PokemonAnnotation:NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String? = ""
    var subtitle: String? = ""
    var pokemon:Pogoprotos.Map.Pokemon.MapPokemon?
    var imagenString = ""
    
    
    init(poke:Pogoprotos.Map.Pokemon.MapPokemon){
        self.coordinate = CLLocationCoordinate2DMake(Double(poke.latitude), Double(poke.longitude))
        self.pokemon = poke
        title = poke.pokemonId.toString()
        subtitle = "\(poke.expirationTimestampMs)"
        
        
        
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 3
        
        let optionalString0 = formatter.stringFromNumber(poke.pokemonId.hashValue)
        
        if optionalString0 != nil {
            imagenString = optionalString0!
        }
        
        
        
        
        
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

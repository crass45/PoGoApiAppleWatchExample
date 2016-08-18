//
//  FortAnnotation.swift
//  PGoApi
//
//  Created by Jose Luis on 16/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import MapKit
import PGoApi

class FortAnnotation:NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String? = ""
    var subtitle: String? = ""
    var fort:Pogoprotos.Map.Fort.FortData?
    
    
    init(poke:Pogoprotos.Map.Fort.FortData){
        self.coordinate = CLLocationCoordinate2DMake(Double(poke.latitude), Double(poke.longitude))
        self.fort = poke
        if fort!.hasActiveFortModifier {
            
            title = "POKEPARADA"
            subtitle = ""
        }else{
            title = "GYM"
            subtitle = "\(poke.gymPoints)"
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


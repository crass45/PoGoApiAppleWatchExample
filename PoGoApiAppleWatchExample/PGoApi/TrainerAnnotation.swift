//
//  InfoAnnotation.swift
//  Exploravia
//
//  Created by Jose Luis on 5/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import UIKit
import MapKit

class TrainerAnnotation:NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String? = ""
    var subtitle: String? = ""
    
    
    override init(){
        self.coordinate = userLocation
        
        title = "Entrenador"
        subtitle = "Eres tu"
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
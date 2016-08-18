//
//  MapViewController.swift
//  PGoApi
//
//  Created by Jose Luis on 16/8/16.
//  Copyright © 2016 crass45. All rights reserved.
//

import UIKit
import MapKit
import PGoApi

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var usuAnotation = TrainerAnnotation()

    @IBOutlet weak var mapa: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        mapa.delegate = self
        // Do any additional setup after loading the view.
        
        let span = MKCoordinateSpan(latitudeDelta: Double(0.1), longitudeDelta: Double(0.1))
        
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapa.setRegion(region, animated: true)
        
        drawAnnotation()
        
        mapa.mapType = MKMapType.SatelliteFlyover
        
        
//        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.drawAnnotation), name: NEW_POKEMONS_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.drawTrainer), name: UPDATE_LOCATION_NOTIFICATION, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NEW_POKEMONS_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UPDATE_LOCATION_NOTIFICATION, object: nil)
    }
    
    
    
    func drawTrainer(){
        mapa.removeAnnotation(usuAnotation)
        
        usuAnotation = TrainerAnnotation()
        mapa.addAnnotation(usuAnotation)
    }
    
    func drawAnnotation(){
        mapa.removeAnnotations(mapa.annotations)
        
        drawTrainer()
        mapa.addAnnotation(usuAnotation)
        for poke in catchablePokes {
            let annotation = PokemonAnnotation(poke: poke)
            mapa.addAnnotation(annotation)
        }
        
        for fort in gimnasios {
            let annotation = FortAnnotation(poke: fort)
            mapa.addAnnotation(annotation)
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "pin"
        let aview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        
        if let trainer = annotation as? TrainerAnnotation {
            aview.pinColor = MKPinAnnotationColor.Red
            aview.canShowCallout = true
        }
        
        if let poke = annotation as? PokemonAnnotation{
            let pokemonView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pokemon")
            pokemonView.image = UIImage(named: poke.imagenString)
            
            pokemonView.canShowCallout = true
            return pokemonView
            
//            aview.pinColor = MKPinAnnotationColor.Green
//            aview.canShowCallout = true
        }
        
        if let poke = annotation as? FortAnnotation{
            aview.pinColor = MKPinAnnotationColor.Purple
            aview.canShowCallout = true
        }
        
        if let poke = annotation as? SpawnPointAnnotation{
            aview.pinColor = MKPinAnnotationColor.Red
            aview.canShowCallout = true
        }
        
        return aview
    }

}

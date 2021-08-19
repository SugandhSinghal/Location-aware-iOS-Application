//
//  HomeScreenViewController.swift
//  MelbourneBotanicalGardens
//  Main screen map screen
//  Created by Sugandh Singhal on 6/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// annoationUpdate is the delegate to update the annoation and its in ExhibitionDetailViewController
class HomeScreenViewController: UIViewController, MKMapViewDelegate,annoationUpdate, CLLocationManagerDelegate {
   
    // I have writen this method but I don't know where to call it so it is not being used.
    func update(exhibition: Exhibition) {
        for exAnnotation in exhibitionAnnotation {
            if exAnnotation.id == exhibition.id{
                mapView.removeAnnotation(exAnnotation)
                mapView.addAnnotation(exAnnotation)
            }
               }
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    // variable declaration
    var exhibitionList: [Exhibition] = []
    var plantList: [Plant] = []
    var exhibitionAnnotation: [ExhibitionAnnotation] = []
    var coordinate: [CLLocationCoordinate2D] = []
    var annotationSelected: ExhibitionAnnotation?
    var getTheSelectedAnnoation: UUID? =  nil
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Checking so that default value of exhibition and plant  is added just once to the core data
        if UserDefaults.standard.bool(forKey: "value") != true {
            createDataBase()
            UserDefaults.standard.set(true, forKey: "value")
        }
       // used for geofencing
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        
        locationManager.distanceFilter = 50
        
         mapView.showsUserLocation = true

    }
    
    // Used from reference material to check the location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for currentLocation in locations{
            print("\(String(describing: index)): \(currentLocation)")
        }
    }
    
    
    // reference : https://github.com/ElectronicArmory/tutorial-ios-locations/blob/master/Location/ViewController.swift
    //https://www.raywenderlich.com/5470-geofencing-with-core-location-getting-started
    func createGeofence(coordinates: CLLocationCoordinate2D, name: String){
        let geotificationCoordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let region = CLCircularRegion(center: geotificationCoordinate, radius: 10, identifier: name)
         region.notifyOnEntry = true
         region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
        
    }
    

        
    
    

    
    
    /* Method used to dequeue and reuse annoation view
     Reference: https://www.techotopia.com/index.php?title=Working_with_MapKit_Local_Search_in_iOS_8_and_Swift&mobileaction=toggle_view_desktop */
    
    override func viewWillAppear(_ animated: Bool) {
        // I tried removing all the exhibitions before adding it but there was some mistake coming in.
           // exhibitionAnnotation.removeAll()
           // Setting the value from the exhibitionList to exhibitionAnnotation List
           createAnnotationsObject()
           mapView.delegate = self
        
           // To set the default location of the map near the botanical garden
           let defalutzoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -37.829162, longitude:144.977978 ), latitudinalMeters: 1500, longitudinalMeters: 1500)
        
           mapView.setRegion(mapView.regionThatFits(defalutzoomRegion), animated: true)
            
            // to remove old annotations
             let annoation = mapView.annotations
             mapView.removeAnnotations(annoation)
        
        
           // to added annoation on the map using addAnnoation
           for annotation in exhibitionAnnotation {
               mapView.addAnnotation(annotation)
           }
        
         // function that we call in ExhibitionTableViewController to show the location on map if we select row in table.
          if getTheSelectedAnnoation != nil
          {
            for annotation in exhibitionAnnotation{
                  let id = annotation.id
                  if id == getTheSelectedAnnoation {
                      self.mapView.selectAnnotation(annotation, animated: true)
                  }
              }
            
        }
        
    }

    
    // This method basically sets the map view that is sthe name of annoation, image, subtitle etc.
    // I have used MKMarkerAnnotation I could have used MkAnnotation to make changes to the annoation but I made changes to the marker.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            
            guard let annotation = annotation as? ExhibitionAnnotation else{
                return nil
            }
            let identity = "marker"
            var annotationview: MKMarkerAnnotationView
            // dequeu the annotation
            if let viewDequeued = mapView.dequeueReusableAnnotationView(
                withIdentifier: identity)
                as? MKMarkerAnnotationView {
                viewDequeued.annotation = annotation
                annotationview = viewDequeued
            } else {
                annotationview =
                    MKMarkerAnnotationView(annotation: annotation,
                                           reuseIdentifier: identity)
                annotationview.subtitleVisibility = MKFeatureVisibility.visible
                annotationview.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                annotationview.canShowCallout = true
                let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 35, height: 35))
                imageView.image = UIImage(named: annotation.image!)
                 annotationview.leftCalloutAccessoryView = imageView
            }
            return annotationview
            
    }
    
    
    // Function to set focus on the map
    func focusOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    // Perform Segue for moving to the detail exhibition screen and also pass selected exhibition between screens
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailExhibitionSegue"{
            let destination = segue.destination as! ExhibitionDetailViewController
            destination.exhibitionSelected  = annotationSelected
            destination.delegate = self

        }
    }
    
    // When annoation is clicked
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,calloutAccessoryControlTapped control: UIControl){
        self.annotationSelected = view.annotation as? ExhibitionAnnotation
        performSegue(withIdentifier: "detailExhibitionSegue", sender: self)
        
    }
    
    
    
    
    // Storing default value to the core data for plant and exhibition
    
    func createDataBase(){
        
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        
        let contextManager = appDelegate.persistentContainer.viewContext
        
        print ("Entering default plant details")
        let firstPlant = Plant(context: contextManager)
        firstPlant.id = UUID()
        firstPlant.name = "Plant 1"
        firstPlant.scientificName = "Araucaria columnaris"
        firstPlant.url = "https://bs.floristic.org/image/o/1a03948baf0300da25558c2448f086d39b41ca30"
        firstPlant.discoveryYear = "1851"
        firstPlant.family = "Araucariaceae"
        
        let secondPlant = Plant(context: contextManager)
        secondPlant.id = UUID()
        secondPlant.name = "Plant 2"
        secondPlant.scientificName = "Yucca Brevifolia"
        secondPlant.url = "https://bs.floristic.org/image/o/05c2f3cf28a921235daece7b31806741c7251784"
        secondPlant.discoveryYear = "1857"
        secondPlant.family = "Arid"
        
        
        let thirdPlant = Plant(context: contextManager)
        thirdPlant.id = UUID()
        thirdPlant.name = "Plant 3"
        thirdPlant.scientificName = "Trifolium pratense"
        thirdPlant.url = "https://bs.floristic.org/image/o/2292b670683abdaac354389514105df0018d9ef8"
        thirdPlant.discoveryYear = "2000"
        thirdPlant.family = "Arid"
        
        
        
        let fourthPlant = Plant(context: contextManager)
        fourthPlant.id = UUID()
        fourthPlant.name = "Plant 4"
        fourthPlant.scientificName = "Dracaena draco"
        fourthPlant.url = "https://bs.floristic.org/image/o/c6d9a5222b6ef0e3a7bdef3350278718d3097bce"
        fourthPlant.discoveryYear = "1990"
        fourthPlant.family = "Arid"
        
        
        let fifthPlant = Plant(context: contextManager)
        fifthPlant.id = UUID()
        fifthPlant.name = "Plant 5"
        fifthPlant.scientificName = "Camellia lutchuensis"
        fifthPlant.url = "https://bs.floristic.org/image/o/46619775d4319328b2fad6f1ba876ccca2d03534"
        fifthPlant.discoveryYear = "1941"
        fifthPlant.family = "Camellia"
        
        
        let sixthPlant = Plant(context: contextManager)
        sixthPlant.id = UUID()
        sixthPlant.name = "Plant 6"
        sixthPlant.scientificName = "Lepidozamia peroffskyana Burrawang"
        sixthPlant.url = "https://bs.floristic.org/image/o/c766ed84c547abac6021244bc0014d665ba7726f"
        sixthPlant.discoveryYear = "1990"
        sixthPlant.family = "Cycad"
        
        
        let sevenPlant = Plant(context: contextManager)
        sevenPlant.id = UUID()
        sevenPlant.name = "Plant 7"
        sevenPlant.scientificName = "Revoluta Sago"
        sevenPlant.url = "https://bs.floristic.org/image/o/84ef20b0276c3e0a6d32dd97a7b987b510feb961"
        sevenPlant.discoveryYear = "1991"
        sevenPlant.family = "Cycad"
        
        let eightPlant = Plant(context: contextManager)
        eightPlant.id = UUID()
        eightPlant.name = "Plant 8"
        eightPlant.scientificName = "Macrozamia"
        eightPlant.url = "https://bs.floristic.org/image/o/7eb243363838c9975c57204057e63fa8101c26d8"
        eightPlant.discoveryYear = "1992"
        eightPlant.family = "Cycad"
        
        let exhibition1 = Exhibition(context: contextManager)
        exhibition1.id = UUID()
        exhibition1.name = "Oak Lawn"
        exhibition1.describe = "Exhibition 1"
        exhibition1.lat = -37.830923
        exhibition1.long = 144.977978
        exhibition1.icon = "1"
        exhibition1.plants = NSSet.init(array: [firstPlant, secondPlant, thirdPlant])
        
        let exhibition2 = Exhibition(context: contextManager)
        exhibition2.id = UUID()
        exhibition2.name = "Western Lawn"
        exhibition2.describe = "Exhibition 2"
        exhibition2.lat = -37.830169
        exhibition2.long = 144.977581
        exhibition2.icon = "2"
        exhibition2.plants = NSSet.init(array: [firstPlant, secondPlant, thirdPlant])
        
        let exhibition3 = Exhibition(context: contextManager)
        exhibition3.id = UUID()
        exhibition3.name = "Herb Garden"
        exhibition3.describe = "Exhibition 3"
        exhibition3.lat = -37.831381
        exhibition3.long = 144.979362
        exhibition3.icon = "3"
        exhibition3.plants = NSSet.init(array: [firstPlant, secondPlant, fifthPlant])
        
        
        let exhibition4 = Exhibition(context: contextManager)
        exhibition4.id = UUID()
        exhibition4.name = "Rose Pavilion"
        exhibition4.describe = "Exhibition 4"
        exhibition4.lat = -37.829162
        exhibition4.long = 144.979290
        exhibition4.icon = "1"
        exhibition4.plants = NSSet.init(array: [firstPlant, fourthPlant, thirdPlant])
        
        
        let exhibition5 = Exhibition(context: contextManager)
        exhibition5.id = UUID()
        exhibition5.name = "Hopetown Lawn"
        exhibition5.describe = "Exhibition 5"
        exhibition5.lat = -37.828637
        exhibition5.long = 144.978882
        exhibition5.icon = "2"
        exhibition5.plants = NSSet.init(array: [firstPlant, eightPlant, sevenPlant])
        
        do{
            try contextManager.save()
            print("Data is saved")
        }catch let error as NSError{
            print("cannot save \(error), \(error.userInfo)")
        }
        
        
        
    }
    
    // function to create list of ExhibitionAnnotation
    func createAnnotationsObject(){
        //exhibitionAnnotation.removeAll()
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        _ = appDelegate.persistentContainer.viewContext
        let contextManager = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        do{
            let listExhibition  = try contextManager.fetch(fetchRequest)
            for exhibition in listExhibition{
                let exId = exhibition.id!
                let exName = exhibition.name ?? ""
                let exDescription = exhibition.describe ?? " "
                let exLat = exhibition.lat
                let exLong = exhibition.long
                let exImg =  exhibition.icon

                let exCoordinates = CLLocationCoordinate2D(latitude: exLat, longitude: exLong)
                let exAnnotation = ExhibitionAnnotation(id: exId, title: exName, subtitle: exDescription, coordinate: exCoordinates, image: exImg!
 )
                exhibitionAnnotation.append(exAnnotation)
                print(exhibitionAnnotation.count)
                createGeofence(coordinates: exCoordinates, name: exName)
            }
        }catch
        {
            print("Error in creating annotation")
        }
    }

    
}

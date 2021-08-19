//
//  ExhibitionAnnotation.swift
//  MelbourneBotanicalGardens
//
//  Created by Sugandh Singhal on 6/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit

// NSObject of ExhibitionAnnotation
class ExhibitionAnnotation: NSObject, MKAnnotation {
    // Declaration
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: String?
   // Constrain
    init(id: UUID,title: String, subtitle: String, coordinate: CLLocationCoordinate2D, image: String){
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.coordinate = coordinate
        super.init()
    }
    // another class that call out to each annotation

}

//
//  VolumeData.swift
//  MelbourneBotanicalGardens
//
//  Created by Sugandh Singhal on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class VolumeData: NSObject, Decodable {
    
    // Used for API search of plants
    var plants: [PlantData]?
    
    private enum CodingKeys: String, CodingKey {
       
        case plants = "data"
    }

}

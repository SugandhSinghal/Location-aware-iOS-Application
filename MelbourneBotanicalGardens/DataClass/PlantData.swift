//
//  PlantData.swift
//  MelbourneBotanicalGardens
//
//  Created by Sugandh Singhal on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class PlantData: NSObject, Decodable {
    
    // Used for API search
     var discoveryYear: String?
     var family: String?
     var name: String?
     var scientificName: String?
     var url: String?

    
    private enum RootKeys: String, CodingKey {
     case discoveryYear = "year"
     case family
     case name = "common_name"
     case scientificName = "scientific_name"
     case url = "image_url"
    }
    
    private struct ImageURIs: Decodable {
    var png: String? }
    
    required init(from decoder: Decoder) throws {
        
    let container = try decoder.container(keyedBy: RootKeys.self)
        discoveryYear = try? "\(container.decode(Int.self, forKey: .discoveryYear))"
        family = try? container.decode(String.self, forKey: .family)
        name = try? container.decode(String.self, forKey: .name)
        scientificName = try? container.decode(String.self, forKey: .scientificName)
        url = try? container.decode(String.self, forKey: .url)
    }
     
}

//
//  PlantSearchData.swift
//  MelbourneBotanicalGardens
//
//  Created by Sugandh Singhal on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

// For API search for plants
struct  SearchResult: Decodable {
    let data: [DataResult]?
}


struct DataResult: Decodable {
    let image_url: String?
    let scientific_name: String?
    let family: String?
    let year: Int16?
    let common_name: String?
}

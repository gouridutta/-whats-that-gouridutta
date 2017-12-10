//
//  FoursquareStructs.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/4/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import Foundation
struct Root: Codable {
    let responses: [Responses]
}
struct Responses: Codable {
    let labelAnnotations: [LabelAnnotations]
}
struct LabelAnnotations: Codable {
    let mid: String
    let description: String
    let score: Double
}




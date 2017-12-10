//
//  GoogleVisionResult.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/3/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import Foundation

struct GoogleVisionResult: Decodable {
    let mid: String
    let description : String
    let score : Double
    
    enum Codingkeys: String, CodingKey {
        case mid
        case description
    }
}



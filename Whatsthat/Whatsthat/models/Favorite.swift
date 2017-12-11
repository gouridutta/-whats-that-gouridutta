//
//  Favorite.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/11/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import Foundation

class Favorite : NSObject {
    let title: String
    let pathToImage: String
    
    let titleKey = "title"
    let pathToImageKey = "pathToImage"
    
    init(title: String, pathToImage: String) {
        self.title = title
        self.pathToImage = pathToImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: titleKey) as! String
        pathToImage = aDecoder.decodeObject(forKey: pathToImageKey) as! String
    }
    
}

extension Favorite: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: titleKey)
        aCoder.encode(pathToImage, forKey: pathToImageKey)
    }
}

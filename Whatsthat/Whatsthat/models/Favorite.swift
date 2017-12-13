//
//  Favorite.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/11/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import Foundation

class Favorite : NSObject {
    let favoriteId : String
    let title: String
    let pathToImage: String
    
    let idKey = "favoriteId"
    let titleKey = "title"
    let pathToImageKey = "pathToImage"
    
    init(title: String, pathToImage: String) {
        self.favoriteId = UUID().uuidString
        self.title = title
        self.pathToImage = pathToImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        favoriteId = aDecoder.decodeObject(forKey: idKey) as! String
        title = aDecoder.decodeObject(forKey: titleKey) as! String
        pathToImage = aDecoder.decodeObject(forKey: pathToImageKey) as! String
    }
    
}

extension Favorite: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(favoriteId, forKey: idKey)
        aCoder.encode(title, forKey: titleKey)
        aCoder.encode(pathToImage, forKey: pathToImageKey)
    }
}

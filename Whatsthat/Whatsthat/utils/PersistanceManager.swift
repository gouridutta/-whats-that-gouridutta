//
//  PersistanceManager.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/11/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import Foundation
import UIKit
class PersistanceManager {
    static let sharedInstance = PersistanceManager()
    
    let favoritesKey = "favorites"
    
    func fetchFavorites() -> [Favorite]{
        let userDefaults = UserDefaults.standard
        
        let data = userDefaults.object(forKey: favoritesKey) as? Data
        
        if let data = data {
            //data is not nil, so use it
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Favorite] ?? [Favorite]()
        }
        else {
            //data is nil
            return [Favorite]()
        }
    }
    
    func saveToFavorites(favorite : Favorite) {
        let userDefaults = UserDefaults.standard
        var favorites = fetchFavorites()
        favorites.append(favorite)
        let data = NSKeyedArchiver.archivedData(withRootObject: favorites)
        
        userDefaults.set(data, forKey: favoritesKey)
    }
    
    func saveImageInDocumentDirectory (fileName: String, image : UIImage) -> Bool {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                try imageData.write(to: fileURL)
                return true
            }
        } catch {
            print(error)
        }
        return false
    }
    
}

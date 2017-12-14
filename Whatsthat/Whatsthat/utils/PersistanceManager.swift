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
            let favorites = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Favorite] ?? [Favorite]()
            return favorites.sorted {
                $0.title < $1.title
            }
            
        }
        else {
            //data is nil
            return [Favorite]()
        }
    }
    
    func saveToFavorites(favorite : Favorite) -> Bool {
        let userDefaults = UserDefaults.standard
        var favorites = fetchFavorites()
        if (getIndexOfTitleInFavorites(title: favorite.title, favorites: favorites) >= 0) { return false }
        favorites.append(favorite)
        let data = NSKeyedArchiver.archivedData(withRootObject: favorites)
        userDefaults.set(data, forKey: favoritesKey)
        return true
    }
    
    func deleteFromFavorites(title: String) {
        let userDefaults = UserDefaults.standard
        var favorites = fetchFavorites()
        let index = getIndexOfTitleInFavorites(title: title, favorites: favorites)
        if (index < 0) {
            return
        }
        deleteImageFromDocumentDirectory(fileName: favorites[index].pathToImage)
        favorites.remove(at: index)
        userDefaults.removeObject(forKey: favoritesKey)
        let data = NSKeyedArchiver.archivedData(withRootObject: favorites)
        userDefaults.set(data, forKey: favoritesKey)
        
    }
    
    func getIndexOfTitleInFavorites(title: String, favorites:[Favorite]) -> Int {
        return binarySearch(title: title, favorites: favorites, start: 0, end: favorites.count-1)
    }
    
    func binarySearch(title: String, favorites:[Favorite],start: Int,end: Int) -> Int{
        if(start > end) {
            return -1
        }
        let mid = (start + end) / 2
        if (favorites[mid].title == title) {
            return mid
        } else if (favorites[mid].title > title) {
            return binarySearch(title: title,favorites: favorites, start: start, end: mid - 1)
        } else {
            return binarySearch(title: title,favorites: favorites, start: mid + 1, end: end)
        }
    }
    
    func saveImageInDocumentDirectory (fileName: String, image : UIImage) {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                try imageData.write(to: fileURL)
            }
        } catch {
            print(error)
        }
    }
    
    func getImageFromDocumentDirectory(fileName: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let getImage = paths.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: getImage)
    }
    
    func deleteImageFromDocumentDirectory(fileName: String) {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            try fileManager.removeItem(at: fileURL)
            print(fileName)
        } catch {
            print(error)
        }
    }
    
}

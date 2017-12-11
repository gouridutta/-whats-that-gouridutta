//
//  FavoritePhotosTableViewController.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 11/26/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//


import UIKit

class FavoritePhotosTableViewController: UITableViewController {
    var favorites : [Favorite]!
    var selectedRow = Int()
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Favorites", for: indexPath)
        let favoriteIndexPath = indexPath.row
        cell.textLabel?.text = favorites[favoriteIndexPath].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        performSegue(withIdentifier: "FavoriteDetailSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favorites = PersistanceManager.sharedInstance.fetchFavorites()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoriteDetailSegue" {
            if let photoDetailsViewController = segue.destination as? PhotoDetailsViewController {
                photoDetailsViewController.titleFromTableView = favorites[self.selectedRow].title
                //photoDetailsViewController.image = self.catchImage
            }
        }
    }
    
    
}
